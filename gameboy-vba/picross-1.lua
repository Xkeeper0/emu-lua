inpt	= input.get()
old		= {}

local screen	= 0
local subscr	= 0
local writes	= true
while true do

	old		= inpt
	inpt	= input.get()

	if not inpt['control'] then

		if inpt.down and not old.down then
			screen	= screen - 1
		elseif inpt.up and not old.up then
			screen	= screen + 1
		elseif inpt.left and not old.left then
			subscr	= subscr - 1
		elseif inpt.right and not old.right then
			subscr	= subscr + 1
		elseif inpt.Z and not old.Z then
			writes	= not writes
		end

	end

	if writes then
		gui.text(1, 0, string.format("%02X %02X", screen, subscr))

		memory.writebyte(0xD634, screen) -- se
		memory.writebyte(0xD635, subscr) -- unknown
	else
		gui.text(1, 0, string.format("%02X %02X", screen, subscr), 0xFFFFFFB0, 0x00000030)

		gui.text(1, 7, string.format("%02X %02X", memory.readbyte(0xD634), memory.readbyte(0xD635)))

	end

	emu.frameadvance()
end