


	display		= require("display")
	expTable	= require("exptable")
	player		= require("player")
	gameState	= require("gamestate")


	timer	= 0

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

		

		gui.text(1, 1, string.format("MusPo: %4X\n%s", gameState.getMusicPointer(), gameState.get()))


		gui.line(inpt.xmouse, inpt.ymouse, inpt.xmouse + 2, inpt.ymouse + 0, "red")
		gui.line(inpt.xmouse, inpt.ymouse, inpt.xmouse + 0, inpt.ymouse + 2, "red")
		gui.text(inpt.xmouse + 5, inpt.ymouse + 5, string.format("%d,%d", inpt.xmouse, inpt.ymouse), "black", "clear")
		gui.text(inpt.xmouse + 4, inpt.ymouse + 4, string.format("%d,%d", inpt.xmouse, inpt.ymouse), "white", "clear")


		emu.frameadvance();

	end
