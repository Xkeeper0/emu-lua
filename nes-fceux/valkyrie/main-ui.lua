

-- ************************************************************************************
-- bepis
function gameloop()

	if gamemode == 0x01 and (timer % 60) >= 30 then
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
	gametimef	= gametime % 6
	expval		= doexp()

	worldmap()

	-- Clear status bar area
	gui.box(96, 194, 255, 244, black)

	-- if true then return end

	drawclock()

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


	-- Attack power
	attackpow	= memory.readbyte(0x00e7)
	textshadow(60 + (attackpow < 100 and 3 or 0), 227, string.format("%2d", attackpow), "yellow", "black")

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
				enemy[i].x		= memory.readbyte(offset +   5)
				enemy[i].y		= memory.readbyte(offset +   6)
				enemy[i].hp		= memory.readbyte(offset + 0xF)
				enemy[i].maxhp	= math.max(enemy[i].maxhp, enemy[i].hp)

				enemy[i].uC		= memory.readbyte(offset + 0xC)
				enemy[i].item	= memory.readbyte(offset + 0xA)
				
				if enemy[i].t > 1 then
					-- an enemy of some kind
					lifebar(enemy[i].x - 4, enemy[i].y - 7, enemyhpwidth(enemy[i].maxhp, 8, 42),  0, enemy[i].hp, enemy[i].maxhp, "#ffcc00", "#dd0000", "black")
					textoutline2(enemy[i].x - 22, enemy[i].y - 7, string.format("%3d", enemy[i].hp), "white", "black")
					textoutline2(enemy[i].x - 22, enemy[i].y + 2, string.format("%2X", enemy[i].t), "red", "black")
					-- textoutline2(enemy[i].x - 22, enemy[i].y + 10, string.format("%2X", enemy[i].uC), "yellow", "black")

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


	-- inventory display
	-- for i = 0, 7 do
	-- 	offset	= 0x0160 + 0x02 * i
	-- 	item	= memory.readbyte(offset + 1)
	-- 	uses	= memory.readbyte(offset + 1)
	-- 	xo		= math.fmod(i, 4)
	-- 	yo		= math.floor(i / 4)
	-- 	if (item > 0 and (uses > 0 and uses < 255)) then
	-- 		local xpad = uses <= 9 and 3 or 0
	-- 		textshadow(10 + xo * 12 + xpad, 205 + yo * 16, uses, "white", "black")
	-- 	end
	-- end




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

