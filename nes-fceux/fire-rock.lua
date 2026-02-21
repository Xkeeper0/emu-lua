-- fire rock

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


function firerock()
	local out = {
		camy	= memory.readword(0x00B0),
		ballx	= memory.readword(0x00B6),
		bally	= memory.readword(0x00B8),
		ballxspd	= memory.readbytesigned(0x00BE),
		ballyspd	= memory.readbytesigned(0x00BF),
	}
	out.screenx	= out.ballx / 8
	out.screeny	= out.bally / 8 - out.camy

	return out
end

function moonball()
	local out = {
		camy	= memory.readword(0x0020),
		ballx	= memory.readword(0x0022),
		bally	= memory.readword(0x0024),
		ballxspd	= memory.readbytesigned(0x002E),
		ballyspd	= memory.readbytesigned(0x002F),
	}
	out.screenx	= out.ballx / 8
	out.screeny	= out.bally / 8 - out.camy

	return out
end



timer = 0
while true do

	local data = moonball()
	gui.line(data.screenx, 0, data.screenx, 100, "white")
	gui.line(0, data.screeny, 255, data.screeny, "white")
	gui.text(0, 0, string.format("%04X %04X", data.ballx, data.bally))
	gui.text(0, 8, string.format("%+4d %+4d", data.ballxspd, data.ballyspd))
	gui.text(0, 16, string.format("%04X %04X", 0, data.camy))

	input.update()
	timer = timer + 1
	emu.frameadvance()
end