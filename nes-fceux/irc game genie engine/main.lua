
-- Twitch.tv
local user			= "xkeeper_"
local pass			= "*"
local ircserver		= "irc.twitch.tv"
local ircchannel	= "#xkeeper_"


package.path = package.path .. ";./?/init.lua"


local playBoy	= nil -- the PlayBoy instance.
local chat		= nil

local socket	= require("socket")


ggCodeMaxLife	= 5000


resetStrings	= {
					"GAMEOVER ... Wiping codes.",
					"Your codes suck. NoFun Try that again.",
					"CatBag AndKnuckles Clearing codes.",
					"WanWan MiniK MiniC CatBagChamp Nice crash!",
					"WanWan WanBag woof AWOO",
					"CatBagSleeper game froze.",
					"CabBag Restarting driver.",
					"GatoBolso Empezar de nuevo.",
					"BlushBag that was interesting.",
					"FeaturingDanteFromTheDevilMayCrySeries AndKnuckles and also resets.",
					"BlushBag CatBagBack GatoBolso BagCat CatBagChamp CatBag CatBagSleeper SwagBag WanBag",
					"FrankerZ LilZ GAMEOVER ZliL ZreknarF",
					"GAMEOVER AndKnuckles",
					"NoFun CatBagSleeper",
					"WanWan bark",
				}

resetStringsC	= 15



function displayGGCodes()
	local x		= 227
	local y		= -13
	if timer - 3 < timergg or true then
		--if table.getn(gameGenieCodes) > 0 then
		--	gui.box(x - 10, y + 9, x + 28, y + 10 + 8 * table.getn(gameGenieCodes), "#000000a0", "#000000a0")
		--end
		local n	= 1

		local rem	= nil
		local codes	= table.getn(gameGenieCodes)
		for k, v in ipairs(gameGenieCodes) do
			-- --[[
			local lifepct	= v.life / ggCodeMaxLife
			if not rem and v.life <= 0 then
				rem	= v.code
			end
			v.life		= v.life - (codes - k)
			local c			= ((v.life / codes) < 30) and (math.fmod(gtimer, 2) == 0 and "white" or "#ffffff") or "#ffffff"

			local cdisplay	= v.isRAM and string.format("%03X=%02X", v.code, v.value) or v.code
			if v.isRAM then
				-- what a great place to write this, ne?
				memory.writebyte(v.code, v.value)
			end


			gui.box(x - 10, y + 10 + 11 * k, x - 10 + (lifepct * 38), y + 10 + 11 * k + 2, "#ffffff", "black")
			--]]
			gui.box(x - 10, y + 2 + 11 * k, x + 28, y + 2 + 11 * k + 10, "#000000a0", "#000000a0")
			gui.text(x - 9, y + 3 + 11 * k, cdisplay, c, "clear")

			n	= n + 1
		end

		if rem then
			removeGGCode(rem)
		end
	end
end


function isGGCodeActive(code)

	for k, v in ipairs(gameGenieCodes) do
		if v.code == code then
			return k
		end
	end
	return false

end


function addGGCode(code, name, isRAM, value)
	timergg		= timer

	if not isGGCodeActive(code) then
		table.insert(gameGenieCodes, { code = code, life = ggCodeMaxLife, isRAM = isRAM, value = value })
		if not isRAM then
			emu.addgamegenie(code)
		end
	else
		-- removeGGCode(code)
		-- addGGCode(code)		
	end
end

function wipeGGCodes()
	for k, v in ipairs(gameGenieCodes) do
		if not v.isRAM then
			emu.delgamegenie(v.code)
		end
	end
	gameGenieCodes	= {}
end

function removeGGCode(code)
	local codeNum	= isGGCodeActive(code)
	if codeNum then
		if not gameGenieCodes[codeNum].isRAM then
			emu.delgamegenie(code)
		end
		table.remove(gameGenieCodes, codeNum)
	end
end




do
	local crashCheck	= 0


	function resetCrashDetection()
		crashCheck	= 0
	end

	function doCrashCheck()

		--gui.text(1, 1, writes0000)

		if writes0000 <= 20 or writes0000 >= 120 then	-- @todo: configurable
		--if writes0000 < 1 or writes0000 >= 10 then	-- @todo: configurable
			crashCheck	= crashCheck + 1
		else
			crashCheck	= 0
		end

		if crashCheck > 15 then	-- @todo: configurable
			return true
		end
		return false
	end

end


function memoryCheck()
	writes0000	= writes0000 + 1
end








function doIRCBullshit()

	timer	= timer + 1/59

	if timer - 5 > timer2 then
		chat:sendCommand("PING", ":".. tostring(math.random(0, 9999999)))
		timer2	= timer
	end

	repeat
		message	= playBoy:update(dt)

		if message then
			-- :Xkeeper!xkeeper@netadmin.badnik.net PRIVMSG #fart :gas

			--local name, key		= string.match(message, ":(.+)!.+ PRIVMSG #.+ :([^ ]+)")

			--* :irc.glados.tv PONG :irc.glados.tv 5831781
			--* :Xkeeper!Xkeeper@ip.Xkeeper.chat.hitbox.tv PRIVMSG #xkeeper :reset			

			local name, msg		= string.match(message, "^:([^!]+)![^ ]+ PRIVMSG #.+ :(.*)")
			code				= nil
			if msg then

				code			= string.match(msg, "^([AEPOZXLUGKISTVYNaepozxlugkistvyn]+)")
				raddr, rvalue, rimm	= string.match(msg, "^([0-9A-Fa-f]+)[ =]+([0-9A-Fa-f]+)(!?)")

				if string.lower(msg:sub(1, 6)) == "remove" then
					code			= string.match(msg:sub(8), "^([AEPOZXLUGKISTVYNaepozxlugkistvyn]+)")
					if code and string.len(code) == 6 then
						code	= string.upper(code)
						removeGGCode(code)
						print(name .. "> Removing code ".. code)
					end

				elseif raddr and rvalue then
					local addr	= tonumber(raddr, 16)
					local value	= tonumber(rvalue, 16)
					if (addr <= 0x7FF) and (value <= 0xFF) then
						if rimm and rimm == "!" then 
							-- One time write
							print(name .." > Write immediate: ".. string.format("%04X = %02X", addr, value))
							memory.writebyte(addr, value)
						else
							print(name .." > Adding mem: ".. string.format("%04X = %02X", addr, value))
							-- game genie add here
							addGGCode(addr, nil, true, value)

						end

					end

				elseif code and string.len(code) == 6 then
					code	= string.upper(code)
					print(name .." > Adding code: ".. code)
					-- game genie add here
					addGGCode(code)

				elseif string.lower(msg) == "clear" then
					-- Clear all game genie codes
					print(name .." > Clearing all codes")
					wipeGGCodes()

				elseif string.lower(msg) == "reset" then
					-- Reset the game
					print(name .." > Resetting game")
					resetGame()

				else
					print(name .."> ".. msg)

				end
			else
				print("* ".. message);
			end
		end

	until not message



end


function resetGame()
	--savestate.load(state)
	emu.poweron()

end



lastcrashmsg	= 0
crashtimer		= 0

gtimer			= 0


timer			= 0
timer2			= 0

timergg			= 0
gameGenieCodes	= {}

writes0000		= 0
memory.registerwrite(0x0000, memoryCheck)

state			= savestate.object(1)
-- --[[
playBoy = require("playboy"):new(ircserver, 6667, user, user, user, ircchannel, pass)
playBoy:connect()
chat	= playBoy:returnChat()
chat:sendChatMessage(ircchannel, "[*] connected to chat. let's get this party started WanWan")
--]]

while true do

	memory.writebyte(0x07A2, 0)											-- start demo immediately
	memory.writebyte(0x0750, math.random(0, 0xFF))						-- write random areas
	memory.writebyte(0x0717, math.fmod(memory.readbyte(0x0717), 0x10))	-- keep demo going infinitely

	doIRCBullshit()
	displayGGCodes()

	local crashed	= doCrashCheck()

	inpt	= input.get()
	if inpt['X'] then
		wipeGGCodes()
	end

	if crashed then
		print("RIP. CT = ".. crashtimer)
		if crashtimer <= 60 then
			wipeGGCodes()
			if lastcrashmsg < 0 then

				local chatMsg	= resetStrings[math.random(1, resetStringsC)]

				chat:sendChatMessage(ircchannel, "[*] " .. chatMsg)
				lastcrashmsg	= 600
			end
		end
		resetGame()
		crashtimer	= 0
		resetCrashDetection()
	end
	writes0000		= 0
	emu.frameadvance()
	crashtimer	= crashtimer + 1
	gtimer			= gtimer + 1
	lastcrashmsg	= lastcrashmsg - 1
end

