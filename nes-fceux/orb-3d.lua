-- orb 3d

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

camOfsX			= 7
camOfsY			= 8



local game		= MemoryCollection {
	orb1X		= MemoryAddress.new(0x03EB, "byte", false),
	orb1Y		= MemoryAddress.new(0x03ED, "byte", false),
	orb1Z		= MemoryAddress.new(0x03EF, "byte", false),
	orb2X		= MemoryAddress.new(0x03F1, "byte", false),  -- maybe
	orb2Y		= MemoryAddress.new(0x03F3, "byte", false),  -- maybe
	orb2Z		= MemoryAddress.new(0x03F5, "byte", false),  -- maybe
	fuel		= MemoryAddress.new(0x03FD, "byte", false),
	}


function controlOrb()

	gui.line(game.orb1X - 2 + camOfsX, game.orb1Y     + camOfsY, game.orb1X + 2 + camOfsX, game.orb1Y     + camOfsY, "red")
	gui.line(game.orb1X     + camOfsX, game.orb1Y - 2 + camOfsY, game.orb1X     + camOfsX, game.orb1Y + 2 + camOfsY, "red")

	if input.held("leftclick") then
		local m = input.mouse()
		gui.text(1, 1, "ok")
		game.orb1X	= m.x - camOfsX
		game.orb1Y	= m.y - camOfsY
	end

end


function hookLevelCode()
	local x = memory.getregister("x")
	print(string.format("%8d %04X -> X = %2X", timer, memory.readword(0x30), x))
end
memory.registerexec(0xCEBB, hookLevelCode)

timer = 0
while true do

	controlOrb()
	--[[
	local tx = input.get()
	local ty = 0
	for k,v in pairs(tx) do
		gui.text(0, ty, string.format("%s: %s", tostring(k), tostring(v)))
		ty = ty + 8
	end
	--]]

	timer = timer + 1
	input.update()
	emu.frameadvance()

end