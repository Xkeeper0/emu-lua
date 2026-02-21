
roomnames		= {}
roomnames[0x00]	= "Underground"	-- wide underground room
roomnames[0x01]	= "OutsideG"
roomnames[0x02]	= "OutsideA"
roomnames[0x03]	= "OutsideB"
roomnames[0x04]	= "OutsideC"
roomnames[0x05]	= "OutsideD"
roomnames[0x06]	= "OutsideE"
roomnames[0x07]	= "OutsideF"
roomnames[0x08]	= "TowerG"
roomnames[0x09]	= "TowerA"
roomnames[0x0A]	= "TowerB"
roomnames[0x0B]	= "TowerC"
roomnames[0x0C]	= "TowerD"
roomnames[0x0D]	= "TowerE"
roomnames[0x0E]	= "TowerF"
roomnames[0x0F]	= "ColdKillersRoom"
roomnames[0x10]	= "GreatBurnsRoom"
roomnames[0x11]	= "BeatPlantsRoom"
roomnames[0x12]	= "WheelersRoom"
roomnames[0x13]	= "CentipedesRoom"
roomnames[0x14]	= "GreatWingsRoom"
roomnames[0x15]	= "DeathBearsRoom"
roomnames[0x16]	= "ParallelUnder"
roomnames[0x17]	= "ParallelA"
roomnames[0x18]	= "ParallelC"
roomnames[0x19]	= "ParallelG"
roomnames[0x1A]	= "ParallelD"
roomnames[0x1B]	= "ParallelE"
roomnames[0x1C]	= "SecretG"
roomnames[0x1D]	= "? SecretF2"		-- unused?
roomnames[0x1E]	= "SecretBLower"
roomnames[0x1F]	= "SecretE1"
roomnames[0x20]	= "SecretE2"
roomnames[0x21]	= "SecretA"
roomnames[0x22]	= "SecretBUpper"
roomnames[0x23]	= "SecretC"
roomnames[0x24]	= "SecretF"
roomnames[0x25]	= "? Trap1"		-- "in a trap" 1
roomnames[0x26]	= "StartPoint"	-- starting room
roomnames[0x27]	= "? Trap2"		-- "in a trap" 2
roomnames[0x28]	= "PathA"		-- first castle layer (brown)
roomnames[0x29]	= "PathB"		-- second castle layer (green)
roomnames[0x2A]	= "PathC"		-- third castle layer (cyan)
roomnames[0x2B]	= "PathD"		-- fourth castle layer (white)
roomnames[0x2C]	= "PathE"		-- fifth castle layer (brown)
roomnames[0x2D]	= "PathF"		-- sixth castle layer (green)
roomnames[0x2E]	= "PathG"		-- seventh castle layer (cyan)
roomnames[0x2F]	= "PathH"		-- eighth castle layer (white)
roomnames[0x30]	= "? PathAShop"
roomnames[0x31]	= "PathBShop"
roomnames[0x32]	= "? PathCShop"
roomnames[0x33]	= "? PathDShop"
roomnames[0x34]	= "? PathEShop"
roomnames[0x35]	= "? PathFShop"
roomnames[0x36]	= "PathGShop"
roomnames[0x37]	= "? PathHShop"
roomnames[0x38]	= "DungeonRoom"
roomnames[0x39]	= "OutsideRubas"
roomnames[0x3A]	= "RubasBossA"
roomnames[0x3B]	= "RubasBossB"
roomnames[0x3C]	= "RubasBossC"
roomnames[0x3D]	= "DungeonShop"
roomnames[0x3E]	= "EndingScene"
roomnames[0x3F]	= ""

warplist		= {}
local warpcount		= 0x56		-- total count warps
function buildwarptable()
	local romofs	= 0xEE81	-- bank1 EE81

	for i = 0, warpcount - 1 do
		local wofs		= romofs + 8 * i
		warplist[i]		= {}
		for b = 0, 7 do
			warplist[i][b]	= romfile.byte[wofs + b]
		end
	end
end
buildwarptable()

xytargets		= {}
function buildxytargets()
	local xycount	= 0x6C
	local romofs	= 0xD36B	-- bank1 D36B
	for i = 0, xycount - 1 do
		local tofs	= romofs + 4 * i
		xytargets[i]	= {
			x		= romfile.byte[tofs + 1] + romfile.byte[tofs + 0] * 0x100,
			y		= romfile.byte[tofs + 3] + romfile.byte[tofs + 2] * 0x100,
			-- x		= romfile.byte[tofs + 0] + romfile.byte[tofs + 1] * 0x100,
			-- y		= romfile.byte[tofs + 2] + romfile.byte[tofs + 3] * 0x100,
			}
	end
end
buildxytargets()


roomsettings2	= {}
function buildroomsettings2()
	local count		= 0x56
	local romofs	= 0xF13E	-- bank1 F13E
	for i = 0, count - 1 do
		local tofs	= romofs + 2 * i
		roomsettings2[i]	= {}
		roomsettings2[i][0]	= romfile.byte[tofs + 0]
		roomsettings2[i][1]	= romfile.byte[tofs + 1]
	end
end
buildroomsettings2()


function forcewarp(id)
	local warp		= warplist[id]
	local bytes		= { 0x58, 0x55, 0x5e, 0x52, 0x5d, 0x5c, 0x02, 0x04 }
	local zeroes	= { 0x51, 0x53, 0x54, 0x03, 0x05 }

	for i = 1, 8 do
		mem.byte[bytes[i]]	= warplist[id][i - 1]
	end
	for i = 1, 5 do
		mem.byte[zeroes[i]]	= 0x00
	end
	for i = 0, 0x7F, 4 do
		mem.byte[0x700 + i]	= 0xF0
	end

	mem.byte[0x059]	= roomsettings2[id][0]
	mem.byte[0x05A]	= roomsettings2[id][1]

	game.gamestate	= 0x0A
	print(string.format("Forced warp to %02X", id))
end





local warpmenuindex		= 0
local warpmenuscroll	= 0

local lastbeep			= 0
local function beepeat()
	if timer - lastbeep < 6 then return end
	mem.byte[0x07F3]	= 0x07	-- cursor move
	lastbeep			= timer
end

local scrollactive		= false
local scrolltypes		= {}
local scrollcolors		= {}
scrolltypes[0]	= "H"
scrolltypes[1]	= "V"
scrolltypes[2]	= "S"
scrollcolors[0]	= "P29"
scrollcolors[1]	= "P24"
scrollcolors[2]	= "P37"

showwarpmenu	= false
function warpmenu()
	local scrollamount	= 16

	local xp	= 33
	local yp	= 70
	local opts	= 16
	local xs	= 210
	local ys	= 129
	local m			= input.mouse()
	if warpmenuscroll < 0 then
		local tmp		= warpmenuindex
		warpmenuindex	= math.max(0, warpmenuindex - 1)
		warpmenuscroll	= (warpmenuindex == tmp) and 0 or warpmenuscroll + 1
		beepeat()

	elseif warpmenuscroll > 0 then
		local tmp		= warpmenuindex
		warpmenuindex	= math.min(warpcount - opts, warpmenuindex + 1)
		warpmenuscroll	= (warpmenuindex == tmp) and 0 or warpmenuscroll - 1
		beepeat()
	end

	local ss = 5
	gui.box(xp - 3 + ss, yp - 3 + ss, xp + xs + ss, yp + ys + ss, "#00000080", "clear")
	gui.text(xp - 2 + ss, yp - 11 + ss - 1, " Dr. Warp ", "black", "#00000080")
	gui.text(xp +  80 + ss, yp - 11 + ss - 1, "Scrl", "black", "#00000080")
	gui.text(xp + 104 + ss, yp - 11 + ss - 1, " X/Y Pos ", "black", "#00000080")
	gui.text(xp + 166 + ss, yp - 11 + ss - 1, "$59/$5A", "black", "#00000080")

	gui.box(xp - 3, yp - 3, xp + xs, yp + ys, "#000080C0", "white")
	gui.text(xp - 2, yp - 11, " Dr. Warp ", "black", "white")
	gui.text(xp +  80, yp - 11, "Scrl", "white", "black")
	gui.text(xp + 104, yp - 11, " X/Y Pos ", "white", "black")
	gui.text(xp + 166, yp - 11, "$59/$5A", "white", "black")



	local scrollfg	= "black"
	local scrollbg	= "white"
	local sbarpos	= (warpmenuindex / (warpcount - opts)) * (ys - 10)
	if scrollactive or hitbox(m.x, m.y, xp + xs - 3, yp - 1, xp + xs + 3, yp + ys - 2) then
		gui.box(xp + xs - 3, yp - 1, xp + xs + 3, yp + ys - 2, "#FFFFFF80", "clear")
		scrollfg	= "black"
		scrollbg	= (timer % 30 < 15) and "P10" or "P20"
		if input.pressed("leftclick") then
			scrollactive	= true
		end
	end
	if scrollactive then
		if not input.held("leftclick") then
			scrollactive	= false
			return
		end
		local mousefrac		= clamp((m.y - (yp + 2)) / (ys - 7), 0, 1)
		local scrolltarget	= clamp(math.ceil(mousefrac * (warpcount - opts)), 0, warpcount - opts)
		if scrolltarget ~= warpmenuindex then
			beepeat()
			warpmenuindex	= scrolltarget
		end
		scrollfg	= "white"
		scrollbg	= "P21"
	end
	gui.text(xp + xs - 2, yp + sbarpos, "*", scrollfg, scrollbg)


	local bheight	= 55
	if button(xp - 14, yp - 3, 10, 10) then warpmenuscroll = -warpmenuindex; end
	if button(xp - 14, yp + ys - 9  , 10, 10) then warpmenuscroll = ((warpcount - opts) - warpmenuindex) + 1; end
	if button(xp - 14, yp + 8 , 10, bheight) then warpmenuscroll = warpmenuscroll - scrollamount; end
	if button(xp - 14, yp + ys - 10 - bheight, 10, bheight) then warpmenuscroll = warpmenuscroll + scrollamount; end
	textoutline(xp - 14 + 4, yp - 3 + 3, "^")		-- top
	textoutline(xp - 14 + 4, yp - 3 + 6, "^")
	textoutline(xp - 14 + 3, yp + ys - 7  , "v")	-- bottom
	textoutline(xp - 14 + 3, yp + ys - 9  , "v")
	textoutline(xp - 14 + 4, yp + 31, "^")			-- up
	textoutline(xp - 14 + 4, yp + 88, "v")			-- down




	for i = 0, opts - 1 do
		local ypos		= yp + i * 8
		local warpid	= i + warpmenuindex
		local warp		= warplist[warpid]

		if hitbox(m.x, m.y, xp + 2, ypos, xp + xs - 8, ypos + 6, "clear", "red") then
			gui.box(xp + 2, ypos, xp + xs - 8, ypos + 6, "P12")
			if not scrollactive and input.pressed("leftclick") then
				gui.box(xp + 2, ypos, xp + xs - 8, ypos + 6, "P22")
				
				forcewarp(warpid)
				showwarpmenu	= false
			end
		end
		-- gui.box(m.x, m.y, xp + 2, yp - 1, xp + xs + 3, yp + ys - 2)


		local roomname	= "???"
		if roomnames[warp[1]] and roomnames[warp[1]] ~= "" then
			roomname	= roomnames[warp[1]]
			roomcolor	= "white"
		else
			roomname	= string.format("[%02X]", warp[1])
			roomcolor	= "#00ffff"
		end
		if string.sub(roomname, 1, 1) == "?" then
			roomcolor	= "P23"
		end

		if warp[1] == game.room and timer % 30 < 15 then
			roomcolor	= "P26"
		end

		local xytargettext	= string.format("  [%02X?]", warp[2])
		if xytargets[warp[2]] then
			xytargettext	= string.format("%3X, %3X", xytargets[warp[2]].x, xytargets[warp[2]].y)
		end

		gui.text(xp +   3, ypos, hexs(warpid), "P21", "clear")
		gui.text(xp +  19, ypos, roomname, roomcolor, "clear")

		gui.text(xp +  90, ypos, scrolltypes[warp[0]], scrollcolors[warp[0]], "clear")
		gui.text(xp + 106, ypos, xytargettext, "white", "clear")

		gui.text(xp + 170, ypos, hexs(roomsettings2[warpid][0]), "white", "clear")
		gui.text(xp + 188, ypos, hexs(roomsettings2[warpid][1]), "white", "clear")

		-- almost always the high byte of the player's destination X (but sometimes one higher if it's close)
		-- gui.text(xp + 140, ypos, string.format("%X", warp[3]))
		-- always the same
		-- gui.text(xp + 150, ypos, string.format("%X", warp[4]), warp[3] == warp[4] and "green" or "white")
		-- always the same as warp[3] / 0x10 if level is vertical
		--gui.text(xp + 160, ypos, string.format("%02X", warp[5]), (warp[5] / 0x10) == warp[4] and "green" or "white")

		-- always (w3 & 1) if H
		-- gui.text(xp + 180, ypos, string.format("%X", warp[6]), (warp[6] == (warp[3] % 2)) and "green" or "white")
		-- always (w3 & 1) if V
		-- gui.text(xp + 190, ypos, string.format("%X", warp[7]), (warp[7] == (warp[3] % 2)) and "green" or "white")

	end

end