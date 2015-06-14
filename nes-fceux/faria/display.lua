

	local display	= {}


	function display.progressBar(x, y, w, h, value, maximum, minimum, colors)

		local minimum	= minimum and minimum or 0
		local maximum	= maximum and maximum or 1

		local colors	= colors and colors or {}

		local bColors	= {
			fill		= colors.fill and colors.fill or "black",
			empty		= colors.empty and colors.empty or "green",
			border		= colors.border and colors.border or "white"
			}

		-- w - 2 for border or something
		local rw	= w - 2
		local bwp	= (value - minimum) / (maximum - minimum)
		local bw	= math.floor(math.min(1, math.max(0, bwp)) * rw)

		gui.box(x, y, x + w, y + h, bColors.empty, bColors.border)
		if bw > 0 then
			gui.box(x + 1, y + 1, x + 1 + bw, y + 1 + h - 2, bColors.fill, bColors.fill)
		end


	end

	function display.textDropShadow(x, y, s, ff, bb)
		local f	= ff and ff or "white"
		local b	= bb and bb or "black"
		gui.text(x    , y + 1, s, b, "clear")
		gui.text(x + 1, y    , s, b, "clear")
		gui.text(x + 1, y + 1, s, b, "clear")
		gui.text(x    , y    , s, f, "clear")
	end

	
	local hpBarColors	= {
		fill	= "red",
		empty	= "white",
		border	= "black"
		}
	
	local expBarColors	= {
		fill	= "blue",
		empty	= "white",
		border	= "black"
		}


	local mapX		= 210
	local mapY		= 4
	local mapSize	= 5
	function display.towerMap(playerState)

		local x, y	= 0, 0
		for x = 0, 7 do
			for y = 0, 7 do
				local xp	= mapX + x * mapSize
				local yp	= mapY + y * mapSize
				gui.box(xp, yp, xp + mapSize, yp + mapSize, "black", "gray")

			end
		end

		local xp	= mapX + playerState.location.towerRoom.x * mapSize
		local yp	= mapY + playerState.location.towerRoom.y * mapSize
		if math.fmod(timer, 30) < 15 then
			gui.box(xp, yp, xp + mapSize, yp + mapSize, "white", "white")
		else
			gui.box(xp, yp, xp + mapSize, yp + mapSize, "red", "white")
		end

		display.textDropShadow(mapX - 14, mapY + 2, string.format("%dF", playerState.location.towerFloor + 1))

	end



	function display.inBattle(playerState)

		-- P21 is the obnoxious palette color used for the background of the status bar

		gui.box( 13, 181, 241, 198, "P11", "black")
		gui.line( 241, 183, 241, 198, "white")
		gui.line( 14, 198, 241, 198, "white")


		display.textDropShadow(  17, 185, string.format("%3d", playerState['hp']))
		display.textDropShadow(  34, 186, string.format("/", playerState['maxHp']), "P31")
		display.textDropShadow(  40, 187, string.format("%d", playerState['maxHp']), "P31")

		display.progressBar(60, 185, 100, 8, playerState['hp'], playerState['maxHp'], nil, hpBarColors)


		display.textDropShadow( 175, 186, "Lv", "P31")
		display.textDropShadow( 189, 186, string.format("%2d", playerState['level']))
		display.progressBar(204, 185, 32, 8, playerState.levelExp, playerState.levelLen, nil, expBarColors)

		gui.box( 218, 166, 255, 175, "P11")
		gui.line( 217, 166, 217, 175, "black")
		gui.line( 218, 165, 255, 165, "black")
		display.textDropShadow(220, 167, string.format("%6s", string.format("$%d", playerState['gold'])))



	end


	return display