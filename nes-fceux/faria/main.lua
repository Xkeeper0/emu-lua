


	display		= require("display")
	expTable	= require("exptable")
	player		= require("player")
	gameState	= require("gamestate")


	timer	= 0

	lastfun		= 0
	lastfun2	= 0
	funcount	= 0

	function getLastPointerOffTheStackFuck()
		local s	= memory.getregister("s")
		local a	= memory.readbyte(0x100 + s + 1) + memory.readbyte(0x100 + s + 2) * 0x100
		return a
	end

	function fun(a)
		local v	= memory.readbyte(0x00e9)
		if v == 1 then
			lastfun		= memory.getregister("pc")
			lastfun2	= getLastPointerOffTheStackFuck()
			funcount	= funcount + 1
		end
	end

	--memory.registerwrite(0x00E9, fun)

	while true do

		inpt	= input.get()

		if inpt['M'] then
			memory.writebyte(0x6914, memory.readbyte(0x6915))
		end

		local playerStatus		= player:getStatus()
		local currentGameState	= gameState.get()
		if currentGameState == "battle" or currentGameState == "dungeon" then
			display.inBattle(playerStatus)
			if currentGameState == "dungeon" then
				display.towerMap(playerStatus)
			end
		end

		timer	= timer + 1



		--gui.text(1, 1, string.format("MusPo: %4X\n%s", gameState.getMusicPointer(), gameState.get()))

		--gui.text(1, 50, string.format("%04X %04X %d", lastfun, lastfun2, funcount))
		funcount	= 0


		--[[
		gui.line(inpt.xmouse, inpt.ymouse, inpt.xmouse + 2, inpt.ymouse + 0, "red")
		gui.line(inpt.xmouse, inpt.ymouse, inpt.xmouse + 0, inpt.ymouse + 2, "red")
		gui.text(inpt.xmouse + 5, inpt.ymouse + 5, string.format("%d,%d", inpt.xmouse, inpt.ymouse), "black", "clear")
		gui.text(inpt.xmouse + 4, inpt.ymouse + 4, string.format("%d,%d", inpt.xmouse, inpt.ymouse), "white", "clear")
		--]]


		emu.frameadvance();

	end
