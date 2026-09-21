-- LADXR Autotracker support / AP support(?) for Mesen
-- modified from this original source:
--  https://magpietracker.us/static/bizhawk-ladxr.zip
-- Xkeeper 2026, LADXR discord #tracker-general channel :)


-- (mostly) original comments below --------------------------
-- SPDX-FileCopyrightText: 2023 Wilhelm Schürmann <wimschuermann@googlemail.com>
-- SPDX-License-Identifier: MIT
-- This script attempts to implement the basic functionality needed in order for
-- the LADXR Archipelago client to be able to talk to Mesen
-- by reproducing the RetroArch API with Mesen's Lua interface.
-- RetroArch UDP API: https://github.com/libretro/RetroArch/blob/master/command.c
--
-- Only
--  VERSION
--  GET_STATUS
--  READ_CORE_MEMORY
--  WRITE_CORE_MEMORY
-- commands are supported right now.
-- additionally, the extensions:
--  READ_ROM
--  WRITE_ROM
-- are provided (same syntax as READ/WRITE_CORE_MEMORY)
--
-- USAGE:
--  Load this script in Mesen (Debug > Script Window > File > Open...)
--
-- All inconsistencies (like missing newlines for some commands) of the RetroArch
-- UDP API (network_cmd_enable) are reproduced as-is in order for clients written to work with
-- RetroArch's current API to "just work"(tm).
--
-- NOTE:
--  Right now, no error-checking or communication tests are done.
-- end mostly original comments --------------------------------

-- not really used here but maybe useful
function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

function stripPrefix(s, p)
  return (s:sub(0, #p) == p) and s:sub(#p+1) or s
end

local socket = require("socket.core")
udp = socket.udp()

udp:setsockname('127.0.0.1', 55355)
udp:settimeout(0)

function on_vblank()

    local data, msg_or_ip, port_or_nil = udp:receivefrom()
    if data then
        -- "data" format is "COMMAND [PARAMETERS] [...]"
        local command = string.match(data, "%S+")
        if command == "VERSION" then
            -- 1.14 is the latest RetroArch release at the time of writing this, no other reason for choosing this here.
            -- "MESEN" is a special version string to say "yo we're mesen".
            udp:sendto("MESEN-LADXR\n", msg_or_ip, port_or_nil)
        elseif command == "GET_STATUS" then
            local status = "PLAYING"
            if client.ispaused() then
                status = "PAUSED"
            end

            if emu.getsystemid() == "GBC" then
                -- Actual reply from RetroArch's API:
                -- "GET_STATUS PLAYING game_boy,AP_62468482466172374046_P1_Lonk,crc32=3ecb7b6f"
                -- CRC32 isn't readily available through the Lua API.
                -- Nobody cares anyway so we don't either.
                local rominfo = emu.getRomInfo() -- name, path, fileSha1Hash

                udp:sendto(
                    "GET_STATUS " .. status .. " game_boy," ..
                    string.gsub(rominfo.name, "[%s,]", "_") ..
                    ",romhash=12345678\n",
                    msg_or_ip, port_or_nil
                )
            else -- No ROM loaded
                -- NOTE: No newline is intentional here for 1:1 RetroArch compatibility
                -- (this is likely not really possible to have happen in mesen)
                -- (dont worry about it)
                udp:sendto("GET_STATUS CONTENTLESS", msg_or_ip, port_or_nil)
            end

        elseif command == "READ_CORE_MEMORY" then
            local _, address, length = string.match(data, "(%S+) (%S+) (%S+)")
            address = stripPrefix(address, "0x")
            address = tonumber(address, 16)
            length = tonumber(length)

            local ret = {}
            for i = 1, length do
                ret[i]  = string.format("%02x", emu.read(address + i - 1, emu.memType.gameboyDebug))
            end
            local reply = string.format("%s %02x %s\n", command, address, table.concat(ret, " "))
            udp:sendto(reply, msg_or_ip, port_or_nil)


        elseif command == "WRITE_CORE_MEMORY" then
            emu.log(data)
            local _, address = string.match(data, "(%S+) (%S+)")
            address = stripPrefix(address, "0x")
            address = tonumber(address, 16)

            local i = 1
            for byte_str in string.gmatch(data, "%S+") do
                if i > 2 then
                    byte_str = stripPrefix(byte_str, "0x")
                    emu.write(address + i - 1, tonumber(byte_str, 16), emu.memType.gameboyDebug)
                end
                i = i + 1
            end

            local reply = string.format("%s %02x %d\n", command, address, i - 3)
            udp:sendto(reply, msg_or_ip, port_or_nil)


        -- ROM variants
        elseif command == "READ_ROM" then
            local _, address, length = string.match(data, "(%S+) (%S+) (%S+)")
            address = stripPrefix(address, "0x")
            address = tonumber(address, 16)
            length = tonumber(length)

            local ret = {}
            for i = 1, length do
                ret[i]  = string.format("%02x", emu.read(address + i - 1,emu.memType.gbPrgRom))
            end
            local reply = string.format("%s %02x %s\n", command, address, table.concat(ret, " "))
            udp:sendto(reply, msg_or_ip, port_or_nil)


        elseif command == "WRITE_ROM" then
            emu.log(data)
            local _, address = string.match(data, "(%S+) (%S+)")
            address = stripPrefix(address, "0x")
            address = tonumber(address, 16)

            local i = 1
            for byte_str in string.gmatch(data, "%S+") do
                if i > 2 then
                    byte_str = stripPrefix(byte_str, "0x")
                    emu.write(address + i - 1, tonumber(byte_str, 16), emu.memType.gbPrgRom)
                end
                i = i + 1
            end

            local reply = string.format("%s %02x %d\n", command, address, i - 3)
            udp:sendto(reply, msg_or_ip, port_or_nil)
        end
    end
end

-- event.onmemoryexecute(on_vblank, 0x40, "ap_connector_vblank")
emu.addEventCallback(on_vblank, emu.eventType.startFrame)

emu.displayMessage("Autotracker", "Loaded script")
