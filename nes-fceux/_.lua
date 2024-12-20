require("libs/toolkit")

local barw = 0
local timer = 0
local barstart = 141
local freezeSpeed = false

while true do

	--[[

		temp = memory.readword(0x3B5)
		--gui.text(0, 0, string.format("%04X", temp))
		
		if temp >= 0x1E00 then
			memory.writeword(0x3B5, temp - 0x100)
			barw = barw + 1
		end
		
		if barw > 0 then
			gui.box(barstart - 20, 208, barstart + barw, 215, "P16", "P16")
		end
		
	]]
	
	local speed = memory.readbyte(0x0094)
	if speed >= 3 then
		freezeSpeed = true
	end

	
	if freezeSpeed then
		memory.writebyte(0x0094, 3)
	end
	
	timer = timer + 1
	emu.frameadvance()
end
