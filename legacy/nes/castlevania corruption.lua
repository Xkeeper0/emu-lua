while true do

	hurt = memory.readbyte(0x0159)
	if hurt == 0x12 then
		memory.writebyte(math.random(0x0000,0x07ff), math.random (0x00, 0xff));
		memory.writebyte(math.random(0x6000,0x7fff), math.random (0x00, 0xff));
	end;
	emu.frameadvance();
end;