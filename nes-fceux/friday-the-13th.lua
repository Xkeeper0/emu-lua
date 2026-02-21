-- friday the 13th


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")
timer				= 0


local game		= MemoryCollection {
	u00A4			= MemoryAddress.new(0x00A4, "byte", false),

	jasonTimer1			= MemoryAddress.new(0x0587, "byte", false),
	jasonAttackTimer1	= MemoryAddress.new(0x058D, "byte", false),
	jasonTimer1			= MemoryAddress.new(0x0587, "byte", false),
	jasonHealth			= MemoryAddress.new(0x051C, "byte", false),

	otherCounselorsAlive	= MemoryAddress.new(0x0504, "byte", false),
	kidsAlive				= MemoryAddress.new(0x0503, "byte", false),

	dayNightCycle			= MemoryAddress.new(0x0508, "byte", false),
	cabinEnterCount			= MemoryAddress.new(0x0523, "byte", false),

	}

local player	= MemoryCollection {
	health			= MemoryAddress.new(0x0505, "byte", false),
	weapon			= MemoryAddress.new(0x0506, "byte", false),
	counselor		= MemoryAddress.new(0x0507, "byte", false),
	lighter			= MemoryAddress.new(0x0517, "byte", false),
	flashlight		= MemoryAddress.new(0x0518, "byte", false),
	vitamins		= MemoryAddress.new(0x0519, "byte", false),
	sweater			= MemoryAddress.new(0x051A, "byte", false),
	}



function H_83D6()
	local target	= memory.readword(0x0000)
	local len		= memory.readbyte(0x0002)
	print(string.format("Clearing memory: %04X, %02X (%d) bytes", target, len, len))
end
memory.registerexec(0x83D6, H_83D6)


local H_80B4_calls	= {}
function H_80B4()
	table.insert(H_80B4_calls, memory.readword(0x0020))
end
memory.registerexec(0x80B4, H_80B4)


function ShowCabinStatus(xp, yp)

	for i = 0, 9 do
		local x		= xp + 0
		local y		= yp + 0 + (i * 8)
		local cs	= mem.byte[0x074E + i]
		local ts	= ""
		for xx = 1, 5 do
			ts = ts .. (math.random(0, 100) < 50 and "." or "|")
		end
		gui.text(x, y, string.format("%X %02X %s", i, cs, thinbinary(cs)))
		-- dipswitchMenu(x + 25, y, cs)

	end
end


objaddrs	= {}
local oc = 0
-- for i = 0x420, 0x47F, 8 do
for i = 0x380, 0x3FF, 8 do
	oc = oc + 1
	objaddrs[oc] = i
end

objstart	= 0x300
function ShowObjectList(px, py)
	local px = px
	local py = py

	local r = 0

	if button(px, py, 8, 8) then
		objstart	= math.max(objstart - 0x80, 0x300)
	end
	if button(px, py + 8, 8, 8) then
		objstart	= math.clamp(objstart + 0x80, 0x300, 0x780)
	end

	for idx = objstart, objstart + 0x7F, 8 do
		local pyy = py + 8 * r
		gui.text(px + 10, pyy, string.format("%3X", idx))
		for i = 0, 7 do
			local pxx = px + 32 + 14 * (i)
			gui.text(pxx, pyy, hexs(mem.byte[idx + i]))
		end

		r = r + 1
	end
	--[[
	for objindex, objofs in ipairs(objaddrs) do
		local pxx = px + 12 + 13 * (objindex - 1)
		gui.text(pxx, py - 16, string.format("%2X", objofs % 0x100))
		for i = 0, 7 do
			local pyy = py + 8 * i
			gui.text(pxx, pyy, hexs(mem.byte[objofs + i]))
		end
	end
	--]]
end





while true do

	ShowCabinStatus(202, 0)
	ShowObjectList(0, 16)

	--[[
	local yo	= 140
	for k,v in pairs(game._m) do
		textshadow(0, yo, hexs(game[k]))
		textshadow(16, yo, k)
		yo		= yo + 8
	end
	--]]

	for k,v in ipairs(H_80B4_calls) do
		gui.text(10, k * 8, hexs(v, 4))
	end

	gui.text( 220, 120, hexs(cpuregisters.pc))
	gui.text( 220, 128, string.format("%02X %02X", mem.byte[0x0A4], mem.byte[0x0A9]))
	gui.text( 220, 136, string.format("%04X", mem.word[0x020]))
	gui.text( 220, 144, string.format("%04X", mem.word[0x0A5]))

	input.update()
	timer	= timer + 1
	emu.frameadvance()
end
