
-- Valkyrie no Bouken stuffs
-- This game sucks, don't play it
-- Lovingly based off of 4matsy's SMB code, and then mutilated and mamed as required
-- Xkeeper          2008, September 12th

-- ************************************************************************************


require("libs/toolkit")
require("libs/functions")
-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")
input				= require("libs/input")

require("valkyrie-no-bouken-data")

black				= "black"		-- change to show covered areas
-- black				= "#00000080"		-- change to show covered areas
-- black				= "#ff000040"		-- change to show covered areas


cheats				= {
	-- autoheal	= true,
	-- automaxhp	= true,
	-- autohealmp	= true,
	-- automaxmp	= true,
	-- autoexp		= true,
	-- automoney	= true,
	}


function lifebar(x, y, sx, sy, a1, a2, oncolor, offcolor, outerborder, innerborder)
	-- function drawBar(x, y, w, h, min, max, val, fill, marker, background, border, outline)
	drawBar(x, y, sx, sy, 0, a2, a1, oncolor, "white", offcolor, outerborder and outerborder or "clear")
end




function truer_random()
	local rng	= math.random(0, 0xFF)
	memory.writebyte(0x0114, rng)
	cpuregisters.a	= rng
end
memory.registerexec(0xDCE8, truer_random)	-- end of ThrobRNG



-- ************************************************************************************
prevexplevel	= false
function doexp()

	-- the ones digit in-game is painted on
	local totalexp	= memory.readvnb(0x00d5, 5)
	local growth	= memory.readbyte(0x0111)
	local level		= memory.readbyte(0x00b9)
	local nextexplv	= memory.readbyte(0x00bb)
	local prevexp	= 0

	local expval	= {}
	expval.level	= 0
	expval.next	= 0
	expval.nextlvexp	= 0
	expval.prev	= 0
	expval.pct	= 0
	expval.exp	= 0
	expval.over	= false

	-- if level == 0 and nextexplv == 0 and then
	-- 	return expval
	-- end


	if growth ~= 3 then
		-- for the simple growth types, we can just get their values

		nextexp		= getexpforexplevel(nextexplv)
		prevexp		= getexpforexplevel(getexplevelforgrowth(growth, level))
		expval.nextlvexp	= nextexp

		if totalexp >= nextexp then
			-- over exp for that level; show the next level
			expval.over	= true
			nextexp		= getexpforexplevel(getexplevelforgrowth(growth, level + 2))
			prevexp		= getexpforexplevel(getexplevelforgrowth(growth, level + 1))
		end

	else
		nextexp		= getexpforexplevel(nextexplv)
		-- random growth type
		if not prevexplevel then
			local guess = math.max(-1, nextexplv - 5)
			local lvexp	= 0
			repeat
				guess		= guess + 1
				lvexp	= getexpforexplevel(guess + 1)
			until lvexp > totalexp
			prevexplevel	= guess
			print(string.format("Guessed previouse EXPLevel as %02X", prevexplevel))
		end
		prevexp	= getexpforexplevel(prevexplevel)
		expval.nextlvexp	= nextexp

		if totalexp >= nextexp then
			-- in this case just assume the worst case. maybe they'll be surprised
			expval.over	= true
			nextexp		= getexpforexplevel(nextexplv + 3)
			prevexp		= getexpforexplevel(nextexplv)
		end


	end

	expval.level	= level
	expval.exp	= totalexp
	expval.next	= nextexp - totalexp
	expval.prev	= prevexp
	expval.pct	= prevexp and (math.floor((totalexp - prevexp) / (nextexp - prevexp) * 100)) or 0

	if prevexp == -1 then
		expval.pct	= -1
	end

	return expval
end



function hpwidth(hp, wmin, wmax)
	local val	= ((math.max(32, hp) - 32) / 967) ^ 0.7 --((hp - 32) / 967)
	return math.ceil((val * (wmax - wmin)) + wmin)
end
function enemyhpwidth(hp, wmin, wmax)
	local val	= clamp((math.max(1, hp - 8) / 246) ^ 0.7, 0, 1)
	return math.ceil((val * (wmax - wmin)) + wmin)
end


-- stored as single digits per byte, 00-09, e.g. 04 03 02 01 = 1234
function memory.readvnb(offset, length)
	local val		= 0

	for i = 0, length do
		local inp	= memory.readbyte(offset + (i))
		if (inp ~= 0x26) then val = val + inp * (10 ^ i); end
	end
	return val
end
function memory.writevnb(offset, length, val)
	local val = clamp(val, 0, (10 ^ (length + 1)) - 1)
	for i = 0, length do
		local tmp = (val / (10 ^ i)) % 10
		-- write spaces instead of 0s
		if (val < (10 ^ (i - 1))) then tmp = 0x26; end
		memory.writebyte(offset + (i), tmp)
	end
	return val
end



function mapdot(x,y,color)
	gui.drawline(x - 1, y    , x + 1, y    , color)
	gui.drawline(x    , y - 1, x    , y + 1, color)
end

function worldmap()

	herox		= memory.readbyte(0x0080) + memory.readbyte(0x0081) * 256;		-- hero's X position
	heroy		= memory.readbyte(0x0082) + memory.readbyte(0x0083) * 256;		-- hero's current MP

	if mapstyle == 1 then
		mapx		= 8
		mapy		= 9
		mapw		= 60
		maph		= 37
	elseif mapstyle == 2 or mapstyle == 3 then

		mapx		= 8
		mapy		= 34
		mapw		= 240
		maph		= 147

	else
		return nil
	end

	if gamemode == 0x05 or gamemode == 0x01 or gamemode == 0x06 or gamemode == 0x08 then

		maphx		= math.ceil(herox / 3840 * mapw)
		maphy		= math.ceil(heroy / 2352 * maph)


		-- gui.box(mapx - 1, mapy - 1, mapx + mapw + 1, mapy + maph, "#000000")
		gui.box(mapx - 1, mapy - 1, mapx + mapw + 1, mapy + maph, "clear", "#ffffff")

		if mapstyle == 3 then
			for i = 0, 0xFF do

				mappx		= math.ceil((3840 / 16) * math.fmod(i, 0x10) / 3840 * mapw)
				mappy		= math.ceil((2352 / 16) * math.floor(i / 0x10) / 2352 * maph)
				mappx2		= math.ceil((3840 / 16) * (math.fmod(i, 0x10) + 1) / 3840 * mapw) - 1
				mappy2		= math.ceil((2352 / 16) * (math.floor(i / 0x10) + 1) / 2352 * maph) - 1
				tmp			= memory.readbyte(0x81E5 + i) * 2
				gui.box(mapx + mappx, mapy + mappy, mapx + mappx2, mapy + mappy2, string.format("#%02x%02x%02x", tmp, tmp, tmp))
				
			end
		end

		if math.fmod(timer, 60) >= 30 then
			color	= "#888888"
		else
			color	= "#bbbbbb"
		end


		-- gui.line(mapx, mapy + maphy, mapx + mapw, mapy + maphy, "#cccccc")
		-- gui.line(mapx + maphx, mapy, mapx + maphx, mapy + maph, "#cccccc")

		mapdist		= 51
		for i = 1, mappoints do
			mappx		= math.ceil(mapdots[i].x / 3840 * mapw)
			mappy		= math.ceil(mapdots[i].y / 2352 * maph)
			mapdot(mapx + mappx, mapy + mappy, mapdots[i].color)
			if mapdots[i].name then
				mapdotdist	= math.abs(mapdots[i].x - herox) + math.abs(mapdots[i].y - heroy)
				if mapdotdist < mapdist then
					mapdist		= mapdotdist
					mapdistn	= mapdots[i].name
				end
			end
		end
			
		if mapdist <= 50 then
			gui.text(90, 17, mapdistn)
		end
		gui.box(mapx + maphx - 0, mapy + maphy - 0, mapx + maphx + 0, mapy + maphy + 0, "#ffffff")
		gui.box(mapx + maphx - 1, mapy + maphy - 1, mapx + maphx + 1, mapy + maphy + 1, "clear", color)

		-- gui.text(mapx + 0, mapy + maph + 2, string.format("%04d, %04d", herox, heroy))


	end
end



-- ************************************************************************************
-- bepis
function gameloop()

	if gamemode == 0x01 and math.fmod(timer, 60) >= 30 then
		gui.text(105, 180, "< DEMO >")
	end

	if cheats.automaxhp then
		memory.writeword(0x00c4, clamp(memory.readword(0x00c4) + 1, 1, 999))
	end
	if cheats.automaxmp then
		memory.writeword(0x00c6, clamp(memory.readword(0x00c6) + 1, 1, 999))
	end

	herohp		= memory.readword(0x00c0)		-- hero's current HP
	heromp		= memory.readword(0x00c2)		-- hero's current MP
	heromaxhp	= memory.readword(0x00c4)		-- hero's maximum HP
	heromaxmp	= memory.readword(0x00c6)		-- hero's maximum MP
	money		= memory.readvnb(0x00d0, 4)
	gametime	= memory.readbyte(0x0031) * 60 + memory.readbyte(0x0030)		-- game-time
	gamehour	= math.floor(gametime / 320)
	gameminute	= math.floor((gametime - 320 * gamehour) / 320 * 60)
	expval		= doexp()

	worldmap()

	-- Clear status bar area
	gui.box(96, 194, 255, 244, black)

	-- if true then return end

	gui.text(229,   0, string.format("%02d:%02d", gamehour, gameminute))
	-- gui.text(188,  23, string.format("GameMode: %02x", gamemode))

	--      (x, y, sx, sy, a1, a2, oncolor, offcolor, outerborder, innerborder)
	lifebar(191,  16,  60,  2, gamehour, 24, "#ffffff", "#777777", "black")
	lifebar(191,  20,  60,  0, gameminute, 60, "#cccccc", "#555555", "black")


	local hpcolor	= "white"
	if herohp == heromaxhp then
		hpcolor		= "green"
	elseif herohp < heromaxhp * 0.25 then
		hpcolor		= "red"
	elseif herohp < heromaxhp * 0.50 then
		hpcolor		= "yellow"
	end
	gui.line(128, 203, 248, 203, "#880000")
	lifebar( 128, 198, hpwidth(heromaxhp, 16, 120),  5, herohp, heromaxhp, "#ff8800", "#880000", "black")
	gui.line(128, 205, 248, 205, "#0000dd")
	lifebar( 128, 205, hpwidth(heromaxmp, 16, 120),  3, heromp, heromaxmp, "#9999ff", "#0000dd", "black")

	gui.text(  96, 197, string.format("HP\nMP"), "gray", "clear")

	gui.text( 109, 197, string.format("%3d", herohp), hpcolor, "clear")
	textshadow( 230, 197, string.format("%3d", heromaxhp), "white", "black")

	gui.text( 109, 205, string.format("%3d", heromp), "white", "clear")
	textshadow( 230, 205, string.format("%3d", heromaxmp), "white", "black")


	if expval.pct ~= -1 then
		lifebar( 95, 224, 153,  2, expval.pct, 100, expval.over and "#ffaaff" or "#ff44ff", expval.over and "#ff44ff" or "#555555", "black")
	end

	textshadow(  96, 218, "Lv", "white", "black")
	textshadow( 116, 218, string.format("%2d", expval.level), "white", "black")
	if expval.over then
		-- warning for if you have a level pending
		if expval.over and expval.next < 0 then
			textshadow( 130, 218, "!!", timer % 30 < 15 and "red" or "yellow", "black")
		else
			textshadow( 130, 218, "+", timer % 90 < 45 and "gray" or "yellow", "black")
		end
	end
	textshadow(  96, 228, string.format("%d", expval.exp), "#aaaaaa", "black")
	textshadow( 213, 228, string.format("%6d", expval.nextlvexp), "#aaaaaa", "black")
	-- next number shows up when available, otherwise hidden
	if expval.next > 0 then
		gui.text( 213, 218, string.format("%6d", expval.next), "white", "clear")
	else
		gui.text( 239, 218, "--", "gray", "clear")
	end


	gui.text(217, 25, string.format("ATK %2d", memory.readbyte(0x00e7)))

	local money	= string.format("$%d", money)
	gui.text(171 - string.len(money) * 3, 229, money, "yellow", "#533b05ff")




	if not enemy then enemy	= {} end

	if gamemode == 0x05 or gamemode == 0x01 or gamemode == 0x06 then
		for i = 0, 5 do

			offset	= 0x500 + 0x10 * i

			if not enemy[i] then 
				enemy[i] = {}
			end

			if (memory.readbyte(offset) > 0) then

				if not enemy[i].maxhp then enemy[i].maxhp = 0 end

				enemy[i].t		= memory.readbyte(offset)
				enemy[i].x		= memory.readbyte(offset +  5)
				enemy[i].y		= memory.readbyte(offset +  6)
				enemy[i].hp		= memory.readbyte(offset + 15)
				enemy[i].maxhp	= math.max(enemy[i].maxhp, enemy[i].hp)

				enemy[i].item	= memory.readbyte(offset + 10)
				
				if enemy[i].t > 1 then
					-- an enemy of some kind
					lifebar(enemy[i].x - 4, enemy[i].y - 7, enemyhpwidth(enemy[i].maxhp, 8, 42),  0, enemy[i].hp, enemy[i].maxhp, "#ffcc00", "#dd0000", "black")
					textoutline2(enemy[i].x - 22, enemy[i].y - 7, string.format("%3d", enemy[i].hp), "white", "black")
					textoutline2(enemy[i].x - 22, enemy[i].y + 2, string.format("%2X", enemy[i].t), "red", "black")

				else
					-- not an enemy; something else
					if (enemy[i].item == 0x1C) then
						-- money bag, presumably
						if enemy[i].hp == 0 then enemy[i].hp = 10 end
						if enemy[i].hp == 9 then enemy[i].hp = 99 end
						textoutline2(enemy[i].x - 2 - math.min(math.floor(enemy[i].hp / 10) * 2, 2), enemy[i].y - 4, "$".. enemy[i].hp, "yellow", "black")
					else
						-- an item
						gui.box(enemy[i].x, enemy[i].y, enemy[i].x + 15, enemy[i].y + 15, "clear", "#ffffff")
						gui.text(enemy[i].x - string.len(itemlist[enemy[i].item]) * 1.75 + 0, enemy[i].y - 8, itemlist[enemy[i].item])
					
					end
				end
			
			else 
				enemy[i] = {}

			end
		end
	end

	for i = 0, 7 do
		offset	= 0x0160 + 0x02 * i
		item	= memory.readbyte(offset + 1)
		uses	= memory.readbyte(offset + 1)
		xo		= math.fmod(i, 4)
		yo		= math.floor(i / 4)
		if (item > 0 and (uses > 0 and uses < 255)) then
			gui.text(xo * 12 + 8, 194 + yo * 16, uses)
		end
	end




	if cheats.autoheal and (herohp < heromaxhp) and ((math.fmod(timer, 3) == 0)) then
		herohp	= herohp + 1
		memory.writeword(0x00c0, herohp)
	end
	if cheats.autohealmp and (heromp < heromaxmp) and ((math.fmod(timer, 3) == 0)) then
		heromp	= heromp + 1
		memory.writeword(0x00c2, heromp)
	end
	
	if cheats.autoexp and (timer % 3) == 0 and gamemode == 0x06 then
		local expboost	= memory.readvnb(0x00D5, 5)
		local exprate	= math.floor(math.min(1000 - math.random(0, 99), expboost * 0.01 + 1))
		memory.writevnb(0x00D5, 5, expboost + exprate)

		-- expbooster	= 0
		-- memory.writebyte(0x0d5, memory.readbyte(0x00d5) + 1)

		-- for i = 0,5 do
		-- 	inp	= memory.readbyte(0x00d5 + i)
		-- 	if (inp == 0x0a) then
		-- 		memory.writebyte(0x00d5 + (i + 1), memory.readbyte(0x00d5 + (i + 1)) + 1)
		-- 		memory.writebyte(0x00d5 + i, 0)

		-- 	elseif (inp == 0x27) then
		-- 		memory.writebyte(0x00d5 + i, 1)

		-- 	end
		-- end
	end

	if cheats.automoney and (timer % 3) == 0 and gamemode == 0x06 then
		local money		= memory.readvnb(0x00d0, 4)
		memory.writevnb(0x00d0, 4, money + math.random(1, 5))
	end



end




-- ************************************************************************************
-- Start / Character Creation menu
-- Hides the original text and writes new Lua-based descriptions
-- as well as showing the effects of various options
function charaselect()
	local asign			= memory.readbyte(0x0110)
	local btype			= memory.readbyte(0x0111)
	local currentoption	= memory.readbyte(0x002B)

	-- gui.line( 92,  30, 92, 130, "#ffffff")


	gui.box( 13,  48,  96,  64, black);		-- cover JP text
	gui.box( 13,  80,  96,  96, black);		-- cover JP text
	gui.box( 13, 112,  96, 128, black);		-- cover JP text
	gui.box(160,  48, 231,  64, black);		-- cover JP text

	gui.text( 74,  24, " Create your Valkyrie! ", "white", "clear")

	gui.text( 15,  53, "Astrological sign:", (currentoption == 0 and "white" or "gray"), "clear")
	gui.text(158,  53, asigns[asign], "white", "clear")
	if currentoption == 0 then
		gui.text(15, 62, "Determines your\nstarting HP/MP.", "gray", "clear")
	end

	gui.text( 41,  85, "Blood type:", (currentoption == 1 and "white" or "gray"), "clear")
	if currentoption == 1 then
		gui.text(15, 94, " Determines your\nEXP growth curve.", "gray", "clear")
	end

	--	gui.text(164,  83, string.format("%s (%X)", btypes[btype], btype))

	gui.text( 26, 117, "Clothing color:", (currentoption == 2 and "white" or "gray"), "clear")

	
	asign2	= math.fmod(asign, 4)
	if asign2 == 0 then
		shp	= 64
		smp	= 32
	elseif asign2 == 1 then
		shp	= 48
		smp	= 48
	elseif asign2 == 2 then
		shp	= 32
		smp	= 64
	elseif asign2 == 3 then
		shp	= 33
		smp	= 63
	end

	strength	= 10 + math.floor(shp / 32)

	gui.text(  8, 135, "Max HP:", "white", "clear")
	gui.text(  8, 143, "Max MP:", "white", "clear")
	gui.text( 47, 135, " ".. shp, "white", "clear")
	gui.text( 47, 143, " ".. smp, "white", "clear")

	local shpsize	= hpwidth(shp, 16, 100)
	local smpsize	= hpwidth(smp, 16, 100)

	lifebar( 68, 136, shpsize,  4, 64, 64, "#ffcc00", "#880000")
	lifebar( 68, 144, smpsize,  4, 64, 64, "#9999ff", "#0000dd")

	gui.text(214, 136, "STR: ".. strength, "white", "clear")
	gui.text(214, 146, "Starting\n Magic:", "white", "clear")
	if smp >= 40 then
		gui.text(223, 162, "Heal", "yellow", "clear")
	end
	if smp >= 60 then
		gui.text(217, 170, "Fireball", "yellow", "clear")
	end
	
	

	graphx	= 20
	graphy	= 160

	gui.text(graphx - 10, graphy + 65, "Lv.", "white", "clear")

	for i = 1, 12 do
		thispointx	= i * 15 + graphx
		gui.line(thispointx, graphy, thispointx, graphy + 63, "#000088")
		gui.text(thispointx - 4 - (string.len(string.format("%d", i)) - 1) * 3, graphy + 65, string.format("%d", i), "white", "clear")
	end


	for i = 0, 7 do
		lg			= i * 3
		thispointy	= graphy + 63 - (lg) * 3
		gui.line(graphx + 15, thispointy, graphx + 180, thispointy, "#000088")
	
		local exphdg	= getexpforexplevel(lg)
		gui.text(graphx - 16, thispointy - 2, string.format("%5d", exphdg), "#9999ff", "clear")

	end

	gui.line(graphx + 15, graphy     , graphx +  15, graphy + 63, "#9999ff")
	gui.line(graphx + 15, graphy + 63, graphx + 180, graphy + 63, "#9999ff")

	-- gui.box(graphx + 19, graphy + 1, graphx + 73, graphy + 8, "#666666")
	gui.text(graphx + 18, graphy + 2, "EXP Curve", "gray", "clear")


	local btypes	= { 0, 1, 2 }
	btypes[4]		= btype

	lastpointx	= graphx
	lastpointy	= graphy + 180
	for btypetoshow	= 1, 4 do
		lastpointx	= graphx
		lastpointy	= graphy + 180
		for i = 1, 12 do
			thispointx	= i * 15 + graphx
			thispointy	= graphy + 63 - (leveltable[btypes[btypetoshow]][i] * 3)
			if i > 1 then
				gui.line(lastpointx, lastpointy, thispointx, thispointy, btype == btypes[btypetoshow] and "white" or "#444444")
			end
			lastpointx	= thispointx
			lastpointy	= thispointy
		end
	end

	if btype == 3 then
		if (timer % 10) == 0 then
			leveltable[3]	= getrandomleveltable()
		end
		gui.text(graphx + 74, graphy + 28 + math.sin(timer / 12) * 2, " Random ", "yellow", "clear")
	end

end



do

	local password_state	= {
		level		= 1,
		expTarget	= 1,
		maxHP		= 64,
		maxMP		= 32,
		exp			= 0,
		gold		= 0,
		color		= 0,
		growth		= 0,
		astro		= 0,
		items		= {},
		shift		= 0,
		}

	local previous_password		= nil
	local password_glow			= {}
	local generating_active		= false
	local generating_timer		= 0
	local generatedpassword		= ""
	local generatedbytes		= nil

	function numberbuttons(x, y, n)
		local change	= 0
		for i = 0, n do
			if button(  x + i * 6 - 1, y - 7, 6, 5, "gray") then
				change = change + math.pow(10, n - i)
			end
			if button(  x + i * 6 - 1, y + 8, 6, 5, "gray") then
				change = change - math.pow(10, n - i)
			end
		end
		if change > 0 then
			mem.byte[0x338]	= 0x01		-- beep
		elseif change < 0 then
			mem.byte[0x339]	= 0x01		-- boop
		end
		return change
	end

	function passwordscreen()
		local x, y = 10, 135
	
		x, y = 10, 135
		gui.text( x,      y, "Max HP:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.maxHP))
		password_state.maxHP = clamp(password_state.maxHP + numberbuttons(x + 40, y, 2), 1, 999)

		x, y = 10, 160
		gui.text( x,      y, "Max MP:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.maxMP))
		password_state.maxMP = clamp(password_state.maxMP + numberbuttons(x + 40, y, 2), 0, 999)

		x, y = 80, 135
		gui.text( x,      y, "Level:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.level))
		password_state.level = clamp(password_state.level + numberbuttons(x + 40, y, 2), 0, 0x7F)

		x, y = 80, 160
		gui.text( x,      y, "Next:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.expTarget))
		local expnext	= getexpforexplevel(password_state.expTarget)
		local expnexts	= expnext <= 999999 and string.format("%6d", expnext) or string.format("%.2f M", expnext / 1000000)
		gui.text( x +  0, y + 8, expnexts, "#8888ff", "clear")
		password_state.expTarget = clamp(password_state.expTarget + numberbuttons(x + 40, y, 2), 0, 0xFF)

		x, y = 80, 185
		gui.text( x,      y, "EXP:", "white", "clear")
		gui.text( x + 28, y, string.format("%6d", password_state.exp))
		password_state.exp = clamp(password_state.exp / 10 + numberbuttons(x + 28, y, 4), 0, 60159) * 10	-- based on testing, 60159 is valid but 60160 isn't

		x, y = 10, 185
		gui.text( x,      y, "Gold:", "white", "clear")
		gui.text( x + 34, y, string.format("%4d0", password_state.gold))
		password_state.gold = clamp(password_state.gold + numberbuttons(x + 34, y, 3), 0, 0x1FFF)

		x, y = 150, 135
		gui.text( x,      y, "Sign:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.astro))
		password_state.astro = (password_state.astro + numberbuttons(x + 40, y, 0)) % 0x10
		gui.text( x + 50, y, asigns[password_state.astro] and asigns[password_state.astro] or "(Invalid)",  "#8888ff", "clear")

		x, y = 150, 160
		gui.text( x,      y, "Growth:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.growth))
		password_state.growth = (password_state.growth + numberbuttons(x + 40, y, 0)) % 0x04
		gui.text( x + 50, y, growthrates[password_state.growth] and growthrates[password_state.growth] or "(Invalid)",  "#8888ff", "clear")

		x, y = 150, 185
		gui.text( x,      y, "Color:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.color))
		password_state.color = (password_state.color + numberbuttons(x + 40, y, 0)) % 0x04
		gui.box( x + 50, y, x + 64, y + 6, string.format("P%02X", playercolors[password_state.color]))

		x, y = 130, 216
		gui.text( x,      y, "Shift:", "white", "clear")
		gui.text( x + 30, y, string.format("%d", password_state.shift))
		password_state.shift = (0x8 + password_state.shift + numberbuttons(x + 30, y, 0)) % 0x8

		x, y = 10, 210
		gui.text( x,      y, "Items:", "white", "clear")
		x, y = 50, 210
		for k,v in pairs(valkyriepw_bit2item) do
			local t = button( x - 3,  y - 3, 37, 12, password_state.items[v] and "#008800" or "#444444")
			if t then 
				mem.byte[0x338 + (password_state.items[v] and 1 or 0)] = 1	-- beep boop
				password_state.items[v] = not password_state.items[v]
			end

			gui.text( x,      y, v,  password_state.items[v] and "white" or "black", "clear")
			x	= x + 40
			if x > 120 then
				x	= x - 120
				y	= y + 14
			end
		end

		generatedpassword, generatedbytes	= valkyriepw_getpassword(password_state)
		if not previous_password then
			for i = 0, 17 do
				password_glow[i]	= 0
			end
		else
			local plen = string.len(generatedpassword)
			for i = 0, 17 do
				local op = string.sub(previous_password, i + 1, i + 1)
				local np = string.sub(generatedpassword, i + 1, i + 1)
				if op ~= np then
					password_glow[i]	= clamp(password_glow[i] + 60, 0, 120)
				end
			end
		end
		previous_password	= generatedpassword


		local fancy		= 0
		local fancy2	= 0
		local plen = string.len(generatedpassword)
		for i = 1, plen do
			fancy	= math.sin((timer + i * 3) / 25) * 3
			fancy2	= clamp(math.ceil(password_glow[i - 1] / 5), 0, 3) * 0x10
			
			local color = string.format("P%02X", fancy2 + 0x01 + ((timer / 5 + i / 3) % 10))
			gui.text(51 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), color, "clear")
			-- gui.text(51 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), "#00000040", "clear")
			gui.text(50 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), color, "clear")
		end


		for i = 0, 17 do
			password_glow[i]	= math.max(0, password_glow[i] - 1)
		end


		x, y = 175, 207
		local do_generate	= button(x, y, 70, 23, "#008000")
		gui.text( x + 14, y + 8, "Generate!", "white", "clear")
		if do_generate then
			generating_active	= true
			generating_timer	= 40 + math.random(0, 60)
		end


		if generating_active then
			local ptmp		= 0
			local did_any	= false
			for i = 0, 17 do
				ptmp	= mem.byte[0x120 + i]
				if (generating_timer > 0 or ptmp ~= generatedbytes[i]) then
					if math.random(0, 5) > 2 then
						mem.byte[0x120 + i]	= (ptmp + 1) % 0x20
						ptmp	= ptmp + 1 -- break below condition
					end
					if ptmp == generatedbytes[i] then
						password_glow[i]	= 21
					end
					did_any	= true
				else
					password_glow[i]	= 90
				end
			end
			generating_timer	= math.max(0, generating_timer - 1)
			if not did_any then
				generating_active = false
			end
		end
	end
end





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

memory.register(0x0026, keyintercept)



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






timer		= 0
mapstyle	= 1			-- 0 = hidden, 1 = mini, 2 = bigmap
gamemode	= 0
subgamemode	= 0
prevexplevel	= false
enablemaphook	= false

lastpassword	= false

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

	timer		= timer + 1
	input.update()
	emu.frameadvance()

end
