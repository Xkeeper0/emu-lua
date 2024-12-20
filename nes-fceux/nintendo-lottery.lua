-- lottery


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


injected = false

function injectMusic(addr)
	if not injected then
		injected = true
		forceJSR(0xF044)
	end
end

function uninjectMusic(addr)
	if injected then
		injected = false
	end
end

memory.registerexec(0xC327, injectMusic)
memory.registerexec(0xC329, uninjectMusic)







timer = 0
while true do
	timer = timer + 1


	input.update()
	emu.frameadvance()
end
