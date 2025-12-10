
-- Valkyrie no Bouken stuffs
-- This game sucks, don't play it
-- Lovingly based off of 4matsy's SMB code, and then mutilated and mamed as required
-- Xkeeper          2008, September 12th
-- 2025 note: this code is one year away from being able to vote :(
-- i feel old

-- ************************************************************************************

cheats				= {
	-- autoheal	= true,
	-- autohealmp	= true,
	-- automaxhp	= true,
	-- automaxmp	= true,
	-- autoexp		= true,
	-- automoney	= true,
	}



require("libs/toolkit")
require("libs/functions")
-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")
input				= require("libs/input")

black				= "black"		-- change to show covered areas
-- black				= "#00000080"		-- change to show covered areas
-- black				= "#ff000040"		-- change to show covered areas


require("valkyrie/data")
require("valkyrie/functions")
require("valkyrie/exp")
require("valkyrie/minimap")
require("valkyrie/clock")
require("valkyrie/jukebox")
require("valkyrie/chara-setup")
require("valkyrie/main-ui")
require("valkyrie/passwords")
require("valkyrie/inventory")




function truer_random()
	local rng	= math.random(0, 0xFF)
	memory.writebyte(0x0114, rng)
	cpuregisters.a	= rng
end
-- memory.registerexec(0xDCE8, truer_random)	-- end of ThrobRNG


-- ************************************************************************************
function keyintercept()
	if not enablemaphook then
		return
	end
	tmp		= memory.readbyte(0x0026)

	if AND(tmp, 0x04) == 0x04 then
		mapstyle		= math.fmod(mapstyle + 1, 3)
	end

	memory.writebyte(0x0026, AND(tmp, 0xFB))
end
-- memory.register(0x0026, keyintercept)



do
	local oldmaxhp	= 0
	local oldmaxmp	= 0

	function hook_prelevelup()
		-- player leveled up!
		prevexplevel	= memory.readbyte(0x00BB)	-- EXPNextLevel
		oldmaxhp		= memory.readword(0x00c4)
		oldmaxmp		= memory.readword(0x00c6)
	end
	function hook_postlevelup()
		-- after the level up is finished, on RTS
		local maxhp		= memory.readword(0x00c4)
		local maxmp		= memory.readword(0x00c6)
		local explevel	= memory.readbyte(0x00BB)

		print(string.format("Leveled up!  Lv %d", memory.readbyte(0x00B9)))
		print(string.format("EXP level: %d -> %d (+%d)", prevexplevel, explevel, explevel - prevexplevel))
		print(string.format("Max HP: %d -> %d (+%d)", oldmaxhp, maxhp, maxhp - oldmaxhp))
		print(string.format("Max MP: %d -> %d (+%d)", oldmaxmp, maxmp, maxmp - oldmaxmp))
	end
	function hook_postlevelupcheck()
		-- end of level up check, no level up
	end
end

memory.registerexec(0xEA62, hook_prelevelup)
memory.registerexec(0xEB33, hook_postlevelup)
memory.registerexec(0xEB36, hook_postlevelupcheck)



do
	local n1	= 0
	local n2	= 0

	function hook_division_start()
		n1		= mem.word[0x0010]
		n2		= mem.byte[0x0012]
	end
	function hook_division_end()
		local n3	= mem.byte[0x0013]
		print(string.format("%d / %d = %d (remainder %d)", n1, n2, mem.word[0x0010], n3))
	end
	-- memory.registerexec(0xDD28, hook_division_start)
	-- memory.registerexec(0xDD45, hook_division_end)
end


function tempoverlay()

	local x		= 164
	local y		= 4

	--[[
	gui.text(x, y, "PlStatus")
	dipswitchMenu(x + 42, y, mem.byte[0x03D])
	y			= y + 8
	gui.text(x, y, "ArStatus")
	dipswitchMenu(x + 42, y, mem.byte[0x03E])

	y			= y + 8
	gui.text(x, y, "EqStatus")
	dipswitchMenu(x + 42, y, mem.byte[0x0E9])
	y			= y + 8
	gui.text(x, y, "ItStatus")
	dipswitchMenu(x + 42, y, mem.byte[0x0EA])
	y			= y + 8
	--]]


	-- 0x600 = static spawns list
	-- 0x80 = 128 entries
	-- &= $80: don't spawn/collected
	-- &= $01: currently spawned
	local bsize	= 5
	y			= y + 16
	local color	= "white"
	local bval	= 0
	local bflip	= false
	for i = 0, 0xFF do
		local xpos	= i % 0x10
		local ypos	= math.floor(i / 0x10)
		bval		= mem.byte[0x600 + i]
		color		= (AND(0x80, bval) == 0x80) and "red" or ((AND(0x01, bval) == 0x01) and ((timer % 4 < 2) and "white" or "blue") or "gray")
		bflip		= button(x + xpos * bsize, y + ypos * bsize, bsize - 1, bsize - 1, color)
		if bflip then
			mem.byte[0x600 + i]	= 0
		end
	end

	local x	= 5
	local y = 180
	gui.text(x, y, hexs(mem.byte[0x67]))

end





-- function handleSpecialTile()
-- 	gui.text(50, 20, string.format("Special tile: %02X", cpuregisters.a))
-- end
-- memory.registerexec(0xE315, handleSpecialTile)



timer		= 0
mapstyle	= 1			-- 0 = hidden, 1 = mini, 2 = bigmap
gamemode	= 0
subgamemode	= 0
prevexplevel	= false
enablemaphook	= false

lastpassword	= false
showjukebox		= false

while (true) do

	gamemode	= memory.readbyte(0x0029)			-- game mode
	subgamemode	= memory.readbyte(0x002A)			-- sub game mode


	-- for i = 0, 5 do
	-- 	gui.text(40 + 20 * i, 0, string.format("%02X\n%02X", 0x18 + i, memory.readbyte(0x0018 + i)))
	-- end

	enablemaphook	= false
	if gamemode == 0x05 or gamemode == 0x01 or gamemode == 0x06 or gamemode == 0x08 then
		enablemaphook	= true
		gameloop()
		inventory()

	elseif gamemode == 0x03 then
		passwordscreen()

	elseif gamemode == 0x02 then
		charaselect()
	else


		gametimer1	= memory.readbyte(0x0031)
		gametimer2	= memory.readbyte(0x0030)

		gui.text(190, 8, string.format("Timer: %02X %02X", gametimer1, gametimer2))
		gui.text(100, 0, string.format("GameMode: %02X:%02X", gamemode, subgamemode))
		lifebar(191,  16, 60,  2, gametimer1, 0x80, "#ffffff", "#777777", "black")
		lifebar(191,  20, 60,  0, gametimer2, 0x3c, "#cccccc", "#555555", "black")
	end


	-- if button(150, 10, 51, 10, "blue") then
	-- 	lastpassword	= valkyriepw_getpassword(valkyriepw_getgamestate())
	-- end
	-- gui.text(157, 12, "Password", "white", "clear")
	-- if lastpassword then
	-- 	local fancyy	= 0
	-- 	local plen = string.len(lastpassword)
	-- 	for i = 1, plen do
	-- 		fancy	= math.sin((timer + i * 5) / 17) * 3
	-- 		gui.text(34 + i * 8, 71 + fancy, string.sub(lastpassword, i, i))
	-- 	end
	-- end

	-- showmouse(true)

	local jx = 0
	local jy = 50
	if button(jx, jy, 41, 10, "gray") then
		showjukebox	= not showjukebox
	end
	gui.text(jx + 3, jy + 2, "Jukebox", "white", "clear")
	if showjukebox then
		jukeboxControls(60, 10)
	end

	-- tempoverlay()

	timer		= timer + 1
	input.update()
	emu.frameadvance()

end
