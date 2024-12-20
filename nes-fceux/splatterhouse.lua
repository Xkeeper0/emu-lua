require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")



local gameClock	= MemoryCollection{
	hours		= MemoryAddress.new(0x07C0, "byte", false),
	minutes		= MemoryAddress.new(0x07C1, "byte", false),
	seconds		= MemoryAddress.new(0x07C2, "byte", false),
	frames		= MemoryAddress.new(0x07C3, "byte", false),
	}

local game	= MemoryCollection{
	mode		= MemoryAddress.new(0x0070, "byte", false),
	submode		= MemoryAddress.new(0x0071, "byte", false),
	}
	
while true do

	gui.text(0, 0, string.format("%2d:%02d'%02d\"%02d", gameClock.hours, gameClock.minutes, gameClock.seconds, (gameClock.frames / 60 * 100)))
	gui.text(0, 8, string.format("%X-%02X", game.mode, game.submode))
	
	emu.frameadvance()
	input.update()

end
