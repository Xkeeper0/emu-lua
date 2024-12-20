

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

timer = 0

while true do

	if input.pressed("A") then
		memory.writebyte(0x058, 3)
		forceJSR(0xC9DB)
	end


	timer = timer + 1
	input.update()
	emu.frameadvance()

end
