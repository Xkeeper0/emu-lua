

mapdots			= {}
mapdots[1]		= {x =  996, y = 1888,	color = "#4444ff"};		-- house
mapdots[2]		= {x =  773, y =  989,	color = "#4444ff"};		-- house
mapdots[3]		= {x =  266, y = 2263,	color = "#00ff00"};		-- warp point
mapdots[4]		= {x = 1800, y =  216,	color = "#00ff00"};		-- warp point
mapdots[5]		= {x =  776, y =  344,	color = "#00ff00"};		-- warp point
mapdots[6]		= {x = 2055, y = 2008,	color = "#00ff00"};		-- warp point
mapdots[7]		= {x = 1863, y = 2045,	color = "#dd0000", name = "South Pyramid"};		-- s.pyramid
mapdots[8]		= {x = 1607, y =  381,	color = "#dd0000", name = "North Pyramid"};		-- n.pyramid



mappoints		= table.maxn(mapdots)

function minimapDot(ox, oy, mw, mh, x, y, c, ol)
	-- ox/oy: map origin
	-- mw/mh: map size
	-- x / y: abs position of where dot should be on map
	-- c: color
	local mx		= math.floor(ox + (x / worldWidth) * mw)
	local my		= math.floor(oy + (y / worldHeight) * mh)
	gui.box(mx-1, my-1, mx+1, my+1, c and c or "white", ol and ol or "black")
	return mx, my
end


tmpSpawnCheck = 0
tmpSpawnTime = 0
do
	local function updateSpawn()
		tmpSpawnCheck	= mem.byte[0x078]
		tmpSpawnTime	= timer
	end
	memory.registerwrite(0x078, updateSpawn)
end


function minimap()
	local x		= 2
	local y		= 10
	local areaS	= mem.byte[0x03E]
	local inUW	= AND(areaS, 0x20) == 0x20

	local mapW	= 64			-- 64 pixels/px
	local mapH	= 40
	-- local mapW	= 220
	-- local mapH	= mapW * 0.625
	local dotc	= "white"
	local dotX, dotY = 0
	local sFlag	= 0
	gui.box(x - 1, y - 1, x + mapW + 1, y + mapH + 1, "#00000080", "white")

	-- area flags &= 0x20 = uw

	for k,v in pairs(spawnTable) do
		-- if AND(v.type
		if (v.x ~= 0 and vy ~= 0) and inUW == v.uw then
			sFlag		= getspawnflag(k, inUW)
			if AND(0x80, sFlag) == 0x80 then
				dotc	= "orange"
			elseif AND(0x01, sFlag) == 0x01 then
				dotc	= (timer % 16 < 8) and "white" or "red"
			else
				dotc	= "white"
			end
			dotX, dotY	= minimapDot(x, y, mapW, mapH, v.x * 16 - 0x78, v.y * 16 - 0x58, dotc, dotc)
			-- gui.text(dotX + 3, dotY - 3, hexs(k), dotc, "clear")
		end
	end

	local playerX	= mem.word[0x080]
	local playerY	= mem.word[0x082] - (inUW and worldHeight or 0)
	local playerC	= (timer % 30 < 15) and "white" or "green"
	minimapDot(x, y, mapW, mapH, playerX, playerY, playerC, playerC)

	-- gui.text(0, 70, string.format("%02X / %02X  %6d", getEnemySpawns(playerX, playerY, inUW), tmpSpawnCheck, timer - tmpSpawnTime))

end


function mapdot(x,y,color)
	gui.drawline(x - 1, y    , x + 1, y    , color)
	gui.drawline(x    , y - 1, x    , y + 1, color)
end

function worldmap()
	if true then
		return minimap()
	end

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
		gui.box(mapx - 1, mapy - 1, mapx + mapw + 1, mapy + maph, "#00000040", "#ffffff")

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

