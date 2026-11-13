-- mesen pinball quest variant

require "libs/functions"
tools = require "libs/toolkit"



c = {}
c.ballSpeedY = 0x13C
c.ballSpeedX = 0x13E
c.ballSpeedZ = 0x140


function mainfunc()
	-- textoutline2(1, 1, string.format("PC=%04X S=%02X A=%02X X=%02X Y=%02X",
	-- 	cpuregisters.pc, cpuregisters.sp,
	-- 	cpuregisters.a, cpuregisters.x, cpuregisters.y
	-- 	)
	-- )

	-- textoutline2(1, 10, string.format("X=%+5d Y=%+5d Z=%+5d",
	-- 	mem.sword[c.ballSpeedX],
	-- 	mem.sword[c.ballSpeedY],
	-- 	mem.sword[c.ballSpeedZ]
	-- 	)
	-- )

	if true and tools.keyPressed("rightclick") then
		-- textoutline2(1, 20, "crazyball")
		fuckSize = 100
		mem.sword[c.ballSpeedX]	= mem.sword[c.ballSpeedX] + math.random(-fuckSize, fuckSize)
		mem.sword[c.ballSpeedY]	= mem.sword[c.ballSpeedY] + math.random(-fuckSize, fuckSize)
		mem.sword[c.ballSpeedZ]	= mem.sword[c.ballSpeedZ] + math.random(-fuckSize, fuckSize)
	end


end
emu.addEventCallback(mainfunc, emu.eventType.endFrame)
