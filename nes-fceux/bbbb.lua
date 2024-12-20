-- bugs bunny birthday blowout


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")




count = {}

entryPoint = 0
idleCount = 0
function registerEntry(addr)
	entryPoint	= getReturnAddress()
	idleCount	= 0
	print(string.format("Entry %04X\n", entryPoint))
end

function registerIdle(addr)
	idleCount	= idleCount + 1
	-- if entryPoint == 0xE864 then
	-- 	memory.writebyte(0x0F0, 0x00)
	-- end
end

function registerExit(addr)
	print(string.format("Entry %04X - loops %d\n", entryPoint, idleCount))
end

memory.registerexec(0xEC7D, registerEntry)
memory.registerexec(0xEC85, registerIdle)
memory.registerexec(0xEC89, registerExit)

-- EC7D


timer = 0
while true do

	count = {}
	timer = timer + 1

	input.update()
	emu.frameadvance()
end
