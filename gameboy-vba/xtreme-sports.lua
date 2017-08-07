
-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")




local player	= MemoryCollection {
	x1		= MemoryAddress.new(0xFFB5, "word", false),
	x2		= MemoryAddress.new(0xFFB9, "word", false),
	--x3		= MemoryAddress.new(0xFFCA, "word", false),
	--x4		= MemoryAddress.new(0xFFDA, "word", false),
	--x5		= MemoryAddress.new(0xFFDC, "word", false),
	}


local camera	= MemoryCollection {
	left		= MemoryAddress.new(0xC800, "word", false),
	top			= MemoryAddress.new(0xC802, "word", false),
	right		= MemoryAddress.new(0xC804, "word", false),
	bottom		= MemoryAddress.new(0xC806, "word", false),
	x			= MemoryAddress.new(0xC8E0, "word", false),
	y			= MemoryAddress.new(0xC8E2, "word", false),

	}


local player2	= MemoryCollection {
	x1		= MemoryAddress.new(0xFF42, "byte", false),
	x2		= MemoryAddress.new(0xFF43, "byte", false),
	}


shit = false
count	= 0

mv		= 0xFFB5

function fuck()
	if shit then
		return
	end
	shit = true
	local rv	= math.random(0x310, 0x3F0)
	memory.writeword(0xFFB5, rv)
	memory.writeword(0xFFB9, rv)
	count	= count + 1
	shit = false
end


function welp()
	gui.text(50, 50, string.format("%04X", memory.readword(0xD1EC)))
end

--memory.register(0xFFB5, fuck)
--memory.register(0xFFB9, fuck)
memory.register(0xD1EC, welp)

cameraLock	= false
desiredCam	= { x = 0, y = 0 }

cspd			= 0x2

while true do


	gui.text(50, 70, string.format("%04X", memory.readword(0xD1EC)))
	local b	= memory.readbyte(0xFF70)
	for i = 0, 0x7 do
		memory.writebyte(0xFF70, i)
		gui.text(1, 1 + i * 10, string.format("%02X: %04X", i, memory.readword(0xD1EC)))
	end
	memory.writebyte(0xFF70, b)
	
	--[[
	inputi, inputc	= input.update()

	gui.text(1, 1, string.format("   %04X\n%04X  %04X\n   %04X\n\n%04X %04X", camera.top, camera.left, camera.right, camera.bottom, camera.x, camera.y))
	
	gui.text(1, 100, count)
	count	= 0
	--gui.text(1, 1, string.format("%04X %04X", camera.x, camera.y))


	for i = 1, 2 do
		gui.text(100, 10 * i, string.format("%04X", player["x" .. i]))

	end

	if inputc.left then
		camera.x	= math.max(0, camera.x - cspd)
	end

	if inputi.Z then
		cameraLock	= not cameraLock
		print("Toggling camera lock state to [" .. tostring(cameraLock) .."]")
		if not cameraLock then
			camera.top		= 0x0000
			camera.left		= 0x0000
			camera.bottom	= 0x7FFF
			camera.right	= 0x7FFF
		end
	end

	if inputc.left then
		desiredCam.x	= math.max(0, desiredCam.x - cspd)
	end
	if inputc.right then
		desiredCam.x	= math.min(0x7FFF, desiredCam.x + cspd)
	end
	if inputc.up then
		desiredCam.y	= math.max(0, desiredCam.y - cspd)
	end
	if inputc.down then
		desiredCam.y	= math.min(0x7FFF, desiredCam.y + cspd)
	end

	if cameraLock then
		gui.text(50, 7, "Locked")
		camera.top		= math.max(desiredCam.y - 1, 0)
		camera.left		= math.max(desiredCam.x - 1, 0)
		camera.bottom	= desiredCam.y
		camera.right	= desiredCam.x
	end

	--]]
	emu.frameadvance()
end
