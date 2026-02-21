-- Mashou (Deadly Towers)


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

game		= MemoryCollection{
	joypad1		= MemoryAddress.new(0x000A),
	joypad2		= MemoryAddress.new(0x000B),
	joypadR		= MemoryAddress.new(0x0189),
	joypad2R	= MemoryAddress.new(0x0160),
	gamestate	= MemoryAddress.new(0x0050),
	
	room		= MemoryAddress.new(0x0055),
	lastwarp	= MemoryAddress.new(0x005B),

	dungeonNum	= MemoryAddress.new(0x0016),
	dungeonRoom	= MemoryAddress.new(0x0018),
	
	
	camx		= MemoryAddress.new(0x0003),
	camxhi		= MemoryAddress.new(0x0052),
	camy		= MemoryAddress.new(0x005C),
	camyhi		= MemoryAddress.new(0x005D),
	scrolltype	= MemoryAddress.new(0x0058),	-- 0=horiz, 1=vert, 2=single


	}

equipment	= MemoryCollection{
	greenNecklaceTimer	= MemoryAddress.new(0x0578),
	orangeNecklaceTimer	= MemoryAddress.new(0x0579),
	orangeNecklaceUsed	= MemoryAddress.new(0x057A),
	
	itemEffectFlags1	= MemoryAddress.new(0x01B0),
	itemEffectFlags2	= MemoryAddress.new(0x01B5),
	
	greenCrystalTimer	= MemoryAddress.new(0x04DA),
	blueNecklaceTimer	= MemoryAddress.new(0x04DB),
	magicMaceTimer		= MemoryAddress.new(0x04DC),
	
	figurineTimer		= MemoryAddress.new(0x04FB),
	}


player		= MemoryCollection{
	hp			= MemoryAddress.new(0x0099, "wordBE"),
	maxhp		= MemoryAddress.new(0x01B2, "wordBE"),
	ludder		= MemoryAddress.new(0x009B),
	invuln		= MemoryAddress.new(0x00A2),

	x			= MemoryAddress.new(0x00BC, "word"),
	y			= MemoryAddress.new(0x00BE, "word"),

	strength	= MemoryAddress.new(0x01B7),
	def			= MemoryAddress.new(0x0185),
	}

function letterindex(i)
	return i < 0x10 and string.format("%X", i) or string.char(70 + (i - 0xF))
end
function romaddr(addr, bank)
	return addr + (0x8000 * ((bank and bank or 0) - 1))
end


require("deadly-towers/items")
require("deadly-towers/jukebox")
require("deadly-towers/debug")
require("deadly-towers/rooms")
require("deadly-towers/dungeon")
require("deadly-towers/object")
require("deadly-towers/password")
require("deadly-towers/spawns")




function getcurrentbank()
	local bankIDs	= {}
	-- unique byte at $8003 ...              0  1  2[ 3] 4
	-- there might be a better way. oh well  |  |  |  |  |
	bankIDs[0x22]	= 0			-- bank 0 = 0F 11 38 22 0F
	bankIDs[0x16]	= 1			-- bank 1 = A2 00 A9 16 95 (LDX #0, LDA #$16, STA $30,X)
	bankIDs[0xA9]	= 2			-- bank 0 = 20 27 84 A9 00 (JSR $8427, LDA #0)
	bankIDs[0x27]	= 3			-- bank 0 = A2 00 A9 27 95 (LDX #0, LDA #$27, STA $30,X)
	return bankIDs[mem.byte[0x8003]] or false
end





lastroomchange	= 0
warpOverride	= 0xFF -- 0x20
function changeroom(addr)
	if getcurrentbank() ~= 1 then return end
	lastroomchange	= cpuregisters.a
	print(string.format("Warp: room %02X -> w.id %02X", game.room, lastroomchange))


	if warpOverride == 0xFF then return end
	cpuregisters.a	= warpOverride
	warpOverride	= 0xFF
	-- warpOverride			= warpOverride + 1
end
-- ChangeRoomFromTable
 memory.registerexec(0xEE26, changeroom)




function tb(n)
	return string.format("%02X %s", n, thinbinary(n))
end
function showEquipmentTimers()
	local xp		= 170
	local yp		= 50
	
	gui.text(xp,  yp - 8 * 1, string.format("DEF %3d", player.def), "white", "black")
	gui.text(xp,  yp - 8 * 2, string.format("STR %s", tb(player.strength)), "white", "black")

	gui.text(xp,  yp + 8 * 2, tb(equipment.itemEffectFlags1), "white", "P01")
	gui.text(xp,  yp + 8 * 3, tb(equipment.itemEffectFlags2), "white", "P03")
	gui.text(xp,  yp + 8 * 4, tb(equipment.orangeNecklaceUsed), "white", "P05")

	local tw = 15
	local oncolor	= "P00"
	local offcolor	= "black"
	gui.text(xp + tw * 0, yp + 8 * 0, string.format("%2X", equipment.greenNecklaceTimer), "green", equipment.greenNecklaceTimer ~= 0 and oncolor or offcolor)
	gui.text(xp + tw * 1, yp + 8 * 0, string.format("%2X", equipment.orangeNecklaceTimer), "orange", equipment.orangeNecklaceTimer ~= 0 and oncolor or offcolor)
	gui.text(xp + tw * 2, yp + 8 * 0, string.format("%2X", equipment.greenCrystalTimer), "green", equipment.greenCrystalTimer ~= 0 and oncolor or offcolor)
	gui.text(xp + tw * 0, yp + 8 * 1, string.format("%2X", equipment.blueNecklaceTimer), "P21", equipment.blueNecklaceTimer ~= 0 and oncolor or offcolor)
	gui.text(xp + tw * 1, yp + 8 * 1, string.format("%2X", equipment.magicMaceTimer), "white", equipment.magicMaceTimer ~= 0 and oncolor or offcolor)
	gui.text(xp + tw * 2, yp + 8 * 1, string.format("%2X", equipment.figurineTimer), "cyan", equipment.figurineTimer ~= 0 and oncolor or offcolor)


end


memory.registerexec(0xFF80, function (addr)
	if getcurrentbank() ~= 0 then return end
	print("pranked!")
	mem.byte[0x016E]	= 0
end)







numobjs		= 0x16
function renderobjects()
	local ofs			= 0
	for i = 0, numobjs do
		ofs				= 0x700 + i * 4
		local ypos		= mem.byte[ofs]
		local xpos		= mem.byte[ofs + 3]
		local type		= mem.byte[ofs + 1]
		if (ypos ~= 0xF0) and (xpos ~= 0 and ypos ~= 0) then
			gui.text(xpos, ypos, string.format("%02X:%02X", i, type))
		end
	end
end
function renderobjects2()
	local ofs			= 0
	local camxpos		= game.camx + game.camxhi * 0x100
	local endreached	= false
	for i = 0, numobjs do
		local type		= mem.byte[0x11F + i]
		local xpos		= mem.byte[0x320 + i]  + mem.byte[0x300 + i] * 0x100
		local ypos		= mem.byte[0x360 + i]
		local objtimer	= mem.byte[0x4C0 + i]
		local timer		= mem.byte[0x4C0 + i]
		gui.text(xpos - camxpos, ypos - 16, string.format("%02X\n%02X", i, type))
		if type ~= 0xFF then
			-- mem.byte[0x340 + i]	= math.random(0, 0x1F)
		else
			endreached		= true
		end
		gui.text(229, 30 + i * 8, string.format("%02X:%02X", i, type), endreached and "gray" or "white", "black")

	end
end

function renderobjectsmap()
	local xp		= 60
	local yp		= 10
	local scale		= 1 / 8
	local mwidth	= 256 * 8
	local mheight	= 256 * 1
	local camxpos	= game.camx + game.camxhi * 0x100
	local camypos	= game.camy + (3 - game.camyhi) * 0x100

	local scrolltype	= mem.byte[0x058]
	if scrolltype == 0x01 then
		mwidth		= 256
		mheight		= 256 * 4
		camxpos		= 0
	elseif scrolltype == 0x00 then
		mwidth		= 256 * 4
		mheight		= 256
		camypos		= 0
		if game.room == 0x00 or game.room == 0x16 then
			scale	= 1/12
			mwidth	= 256 * 8
		end
	else
		mwidth		= 256
		mheight		= 256
		camxpos		= 0
		camypos		= 0
	end

	gui.box(xp, yp, xp + mwidth * scale, yp + mheight * scale, "#00000080", "white")
	for i = 1, (mwidth / 256) - 1 do
		local x		= (256 * i) * scale
		gui.line(xp + x, yp + 1, xp + x, yp + (mheight * scale) - 1, "gray")
	end
	for i = 1, (mheight / 256) - 1 do
		local y		= (256 * i) * scale
		gui.line(xp + 1, yp + y, xp + (mwidth * scale) - 1, yp + y, "gray")
	end
	
	local camx		= camxpos * scale
	local camy		= camypos * scale
	gui.box(xp + camx, yp + camy, xp + camx + (256 * scale), yp + camy + (256 * scale), "#00ff0040", "green")

	local endreached	= false
	for i = 0, numobjs do
		local type		= mem.byte[0x11F + i]
		local xpos		= mem.byte[0x320 + i]  + mem.byte[0x300 + i] * 0x100
		local ypos		= mem.byte[0x360 + i]  + (((mheight / 256) - 1) - mem.byte[0x340 + i]) * 0x100
		local objtimer	= mem.byte[0x4C0 + i]
		local timer		= mem.byte[0x4C0 + i]
		if type ~= 0xFF and not endreached then
			local xpos		= xpos * scale
			local ypos		= ypos * scale
			local letter	= letterindex(i)
			textoutline(xp + xpos - 2, yp + ypos - 3, letter, "white", "P16")
		else
			endreached		= true
		end
	end

	local playerx	= camxpos + mem.byte[0x703]
	local playery	= camypos + mem.byte[0x700]

	local xpos		= playerx * scale
	local ypos		= playery * scale
	textoutline2(xp + xpos - 2, yp + ypos - 3, "*", "white", "P19", "clear")

end


-- memory.registerexec(0x93AB, function (addr)
-- 	if getcurrentbank() ~= 0 then return end
-- 	-- print(string.format("from: %04X", getReturnAddress()))
-- 	cpuregisters.pc = 0x93BD
-- 	-- debugger.hitbreakpoint()
-- 	-- cpuregisters.s	= cpuregisters.s + 2
-- end)



local comment = 0
local comments	= {
	"   Discovered a disabled cheat\n    on the password screen. ",
	" It would have worked by holding \n  anything on P2 when starting. ",
	" Every letter represents an item\n  that will be in your inventory. ",
	"        Game Genie codes:        \nXTKZYOGK + XZKXAOTI + AAKXPPOZ",
}
function showcommentary()
	if input.pressed("M") then
		comment = (comment + 1) % 5
	end
	if comments[comment] then
		gui.text(42, 210, comments[comment], "yellow", "black")
	end
end



function alternatehud()
	for i = 0, 0xFF, 4 do
		if (i >= 0x60 and i < 0x80)then
			local tt	= i < 0xE0 and (i - 0x60) or (i - 0xE0)
			local tc	= i < 0xE0 and "green" or "cyan"
			local sy	= mem.byte[0x600 + i]
			local st	= mem.byte[0x601 + i]
			local sa	= mem.byte[0x602 + i]
			local sx	= mem.byte[0x603 + i]
			gui.box(sx, sy, sx + 7, sy + 15, "clear", "red")
			textshadow(sx, sy + 16, string.format("%0X", tt), tc)
		end
	end

	mem.byte[0x6B]	= math.random(0, 9)
	mem.byte[0x6C]	= math.random(0, 9)
	mem.byte[0x6D]	= math.random(0, 9)
end



showobjects = false
showjukebox = false
showwarpmenu = false
showspawnlist = false


timer = 0
doom = 90
lastroom = 0
while true do

	gui.text(0, 30, string.format("Room %02X\n%s", game.room, roomnames[game.room] and roomnames[game.room] or "???"))
	if (roomnames[game.room] == "") then
		-- doom = doom - 1
		if doom < 0 then
			print(string.format("Name room %02X please", game.room))
			print(string.format("Arrived from %02X %s", lastroom, roomnames[lastroom]))
			emu.pause()
		end
	else
		lastroom = game.room
	end

	-- gui.text(0, 58, string.format("C:%02X", warpOverride))

	gui.text(0, 16, string.format("GS: %02X", game.gamestate))
	-- gui.text(0, 232, string.format("PC:%X:%04X", getcurrentbank(), cpuregisters.pc))
	
	if game.room == 0x38 or game.gamestate == 0x0C then
		gui.text(0, 100, string.format("Dungeon\n(%02X) %02X", game.dungeonNum, game.dungeonRoom))
		dungeonhandler()
	end


	if player.hp < player.maxhp then
		-- player.hp	= math.min(player.maxhp, player.hp + math.max(1, math.floor((player.maxhp - player.hp) / 20) + 2))
		player.hp		= player.maxhp
		-- player.invuln	= 0x20-5
	end
	-- if input.held('Z') then
	-- 	player.hp		= 1 -- math.max(1, player.hp - 1)
	-- 	player.maxhp	= 299
	-- 	equipment.itemEffectFlags1	= 0x10
	-- end
	gui.text(0, 0, string.format("%3d/%3d ", player.hp, player.maxhp))
	gui.text(0, 8, string.format("$%3d", player.ludder))
	drawBar(48, 2, player.maxhp / 2, 3, 0, player.maxhp, player.hp, "orange", "white", "#800000", "black", "white")

	-- joypad display
	-- gui.text(214,  0, string.format("%02X %s", game.joypad1, thinbinary(game.joypad1)), "white", "P06")
	-- gui.text(214,  8, string.format("%02X %s", game.joypad2, thinbinary(game.joypad2)), "white", "P01")
	-- gui.text(214, 16, string.format("%02X %s", game.joypadR, thinbinary(game.joypadR)), "white", "black")

	-- debugoptions()
	-- showEquipmentTimers()


	if game.gamestate == 0x00 and mem.byte[0x10] == 0x0D then
		passwordscreen()
	end
	
	-- renderobjects2()
	local toprightbg	= string.format("P%02X", 1 + (timer / 20) % 10)
	if game.gamestate == 0x03 or game.gamestate == 0x0C then
		renderobjectsmap()

		gui.text(223, 16, "Objs  ", "white", toprightbg)
		if button(249, 16, 6, 6, showobjects and "white" or "gray") then
			showobjects	= not showobjects
		end
		if showobjects then showobjectlist() end
	end

	gui.text(210, 0, "Jukebox  ", "white", toprightbg)
	if button(249, 0, 6, 6, showjukebox and "white" or "gray") then
		showjukebox	= not showjukebox
		showwarpmenu = showwarpmenu and not showjukebox
		showspawnlist = showspawnlist and not showjukebox
	end
	if showjukebox then jukebox() else
		-- showmusic(0, 58)
	end


	gui.text(223, 8, "Warp  ", "white", toprightbg)
	if button(249, 8, 6, 6, showwarpmenu and "white" or "gray") then
		showwarpmenu	= not showwarpmenu
		showjukebox = showjukebox and not showwarpmenu
		showspawnlist = showspawnlist and not showwarpmenu
	end
	if showwarpmenu then
		warpmenu()
	end

	gui.text(223, 24, "Spwn  ", "white", toprightbg)
	if button(249, 24, 6, 6, showspawnlist and "white" or "gray") then
		showspawnlist	= not showspawnlist
		showjukebox = showjukebox and not showspawnlist
		showobjects = showjukebox and not showspawnlist
	end
	if showspawnlist then
		spawnlistmenu()
	end

	if game.gamestate == 0x10 or game.gamestate == 0x11 then
		inventoryscreen()
	end

	showcommentary()

	-- gui.text(65, 183, string.format("%2X", mem.byte[0x0F7]))
	-- gui.text(42, 203, string.format("$%03X = %02X", mem.byte[0x0F7] + 0x120, mem.byte[0x120 + mem.byte[0x0F7]]))

	-- alternatehud()

	timer = timer + 1
	emu.frameadvance()
	input.update()

end
