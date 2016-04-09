


inpt	= input.get()
old		= {}

while true do

	old		= inpt
	inpt	= input.get()

	if inpt['Z'] then
		memory.writebyte(0xCDC5, 0x0A)
		memory.writebyte(0xCDC6, 0x00)
	end

	local screen	= memory.readbyte(0xCDC5)
	local screenm	= memory.readbyte(0xCDC6)

	local level		= memory.readword(0xD6AD)
	local key		= memory.readbyte(0xDFC4)
	local panel		= memory.readbyte(0xD6CB)
	local bgm		= memory.readbyte(0xD568)
	local se		= memory.readbyte(0xD569)
	local unknown	= memory.readbyte(0xD6B0)

	gui.box(-1, -1, 21, 43, 0x000000B0, 0x00000000)
	gui.box(110, -1, 161, 8, 0x000000B0, 0x00000000)

	gui.text(112,  0, string.format("Screen %02X-%02X", screen, screenm))

	gui.text(  0,  0, string.format("L %03d", level))
	gui.text(  0,  7, string.format("Ky %02X", key))
	gui.text(  0, 14, string.format("Pa %02X", panel))
	gui.text(  0, 21, string.format("BG %02X", bgm))
	gui.text(  0, 28, string.format("SE %02X", se))
	gui.text(  0, 35, string.format("UK %02X", unknown))

	--[[
	memory.writeword(0xD6AD, 0) -- level
	memory.writebyte(0xDFC4, 1) -- key
	memory.writebyte(0xD6CB, 10) -- panel
	memory.writebyte(0xD568, 0) -- bgm
	memory.writebyte(0xD569, 0) -- se
	memory.writebyte(0xD6B0, 0) -- unknown
	--]]

	emu.frameadvance()


end