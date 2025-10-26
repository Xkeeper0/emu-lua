-- star soldier j

objStart = 0x400
objSize = 0x18



while true do

	for i = 0, objSize - 1 do
		local oType = memory.readbyte(objStart + i + objSize * 0)
		local oX = memory.readbyte(objStart + i + objSize * 1)
		local oY = memory.readbyte(objStart + i + objSize * 2)
		local o3 = memory.readbyte(objStart + i + objSize * 3)
		local o4 = memory.readbyte(objStart + i + objSize * 4)
		if (oType ~= 0) then
			gui.text(0, i * 8, string.format("%02X %02X %02X %02X", i, oType, o3, o4), "white", "#0000004F")
			gui.box(oX, oY, oX + 15, oY + 15, "clear", "red")
			gui.text(oX + 2, oY + 2, string.format("%02X", oType), "red", "black")
		else
			gui.text(0, i * 8, string.format("%02X", i))
		end
	end

	emu.frameadvance()

end