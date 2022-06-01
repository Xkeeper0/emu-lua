
-- Fix FCEUX fuckups
require("libs/toolkit")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


tileColors		= {}
tileColors[0x1]	= 'white'		-- flower
tileColors[0x2]	= 'yellow'		-- semi-solid floor
tileColors[0x3]	= 'black'		-- solid floor
tileColors[0x4]	= 'orange'		-- damage
tileColors[0x5]	= 'purple'		-- door
tileColors[0x6]	= 'blue'		-- background
tileColors[0x7]	= 'cyan'		-- under slope
tileColors[0x8]	= 'cyan'		-- slope \
tileColors[0x9]	= 'cyan'		-- slope /

tileColors[0xb]	= 'red'			-- death

tileColors[0xd]	= 'green'		-- breakable walls
tileColors[0xe]	= 'gray'		-- "mushroom block"
tileColors[0xf]	= 'brown'		-- crate




local camera	= MemoryCollection {
	x			= MemoryAddress.new(0x00fc, "word", false),
	y			= MemoryAddress.new(0x00fa, "word", false),
	}


local objects	= {}

for i = 0, 0xF do
	objects[i]		= MemoryCollection {
		flags1				= MemoryAddress.new(0x0400 + i, "byte", false),
		animationFrame		= MemoryAddress.new(0x0410 + i, "byte", false),
		animationID			= MemoryAddress.new(0x0420 + i, "byte", false),
		animationCounter	= MemoryAddress.new(0x0430 + i, "byte", false),
		u440				= MemoryAddress.new(0x0440 + i, "byte", false),
		u450				= MemoryAddress.new(0x0450 + i, "byte", false),
		ySubpixel			= MemoryAddress.new(0x0460 + i, "byte", false),
		xSubpixel			= MemoryAddress.new(0x0470 + i, "byte", false),
		u480				= MemoryAddress.new(0x0480 + i, "byte", false),
		timer				= MemoryAddress.new(0x0490 + i, "byte", false),
		u4a0				= MemoryAddress.new(0x04a0 + i, "byte", false),
		u4b0				= MemoryAddress.new(0x04b0 + i, "byte", false),
		u4c0				= MemoryAddress.new(0x04c0 + i, "byte", false),
		statusFlags			= MemoryAddress.new(0x04d0 + i, "byte", false),
		type				= MemoryAddress.new(0x04e0 + i, "byte", false),
		xLo					= MemoryAddress.new(0x04f0 + i, "byte", false),
		xHi					= MemoryAddress.new(0x0500 + i, "byte", false),
		yLo					= MemoryAddress.new(0x0510 + i, "byte", false),
		yHi					= MemoryAddress.new(0x0520 + i, "byte", false),
		xSpeedLo			= MemoryAddress.new(0x0530 + i, "byte", false),
		xSpeedHi			= MemoryAddress.new(0x0540 + i, "byte", false),
		ySpeedLo			= MemoryAddress.new(0x0550 + i, "byte", false),
		ySpeedHi			= MemoryAddress.new(0x0560 + i, "byte", false),
		flags2				= MemoryAddress.new(0x0570 + i, "byte", false),
		u580				= MemoryAddress.new(0x0580 + i, "byte", false),

	}

end




function drawMapGrid(camera)
	-- to avoid looking it up every time
	local cameraX = camera.x
	local cameraY = camera.y
	
	local addr	= 0
	local value	= 0
	local top, bottom = 0
	local xofs	= (0x200 - camera.x) % 0x200
	local yofs	= (0x100 - camera.y) % 0x200
	gui.text(1, 1, yofs)
	for y = 0, 0x7 do
		for x = 0, 0x1F do
			addr	= 0x600 + (y * 0x10) + (0x80 * math.floor(x / 0x10)) + (x % 0x10)
			value	= memory.readbyte(addr)
			bottom	= math.floor(value / 0x10)
			top		= value % 0x10



			local sx = (xofs + x * 16) % 512
			if (top ~= 0) then
				local sy = (yofs + y * 32 +  0) % (0x100)
				if (tileColors[top]) then
					gui.box(sx, sy, sx + 15, sy + 15, nil, tileColors[top])
				else
					gui.text( sx + 2, sy + 2, string.format("%1x", top))
				end
			end
			if (bottom ~= 0) then
				local sy = (yofs + y * 32 + 16) % (0x100)
				if (tileColors[bottom]) then
					gui.box(sx, sy, sx + 15, sy + 15, nil, tileColors[bottom])
				else
					gui.text( sx + 2, sy + 2, string.format("%1x", bottom))
				end
			end
		end
	end

end
	


while true do
	input.update()


	drawMapGrid(camera)


	emu.frameadvance()
end
