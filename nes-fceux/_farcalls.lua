-- faria

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

local farstack = {}
local farcount = 0
function farcall()
	local fcid = memory.getregister("a")
	local fcx = memory.getregister("x")
	local fcy = memory.getregister("y")
	farcount = farcount + 1
	farstack[farcount] = { a = fcid, x = fcx, y = fcy }
	print( string.rep("-- ", farcount - 1) .. string.format("%02X [X%02X Y%02X]", fcid, fcx, fcy) )
end

function farcallrts()
	if (farcount == 0) then return end
	farstack[farcount] = nil
	farcount = farcount - 1
end

function farcallstring()
	local out = ""
	for k,v in ipairs(farstack) do
		out = out .. string.format("%02X\n", v.a)
	end
	return out
end

memory.registerexec(0xC075, farcall)
memory.registerexec(0xC0B4, farcallrts)



while true do

	gui.text(0, 0, farcallstring())
	input.update()
	emu.frameadvance()

end