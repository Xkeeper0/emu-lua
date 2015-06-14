while true do

	haha	= false;
	for i = 1, 5 do
		etype		= memory.readbyte(0x0015 + i);
--		text(8, 20 + i * 8, string.format("%02X", etype));
		if etype >= 0x1B and etype <= 0x22 then
			memory.writebyte(0x0057 + i, 0x80);
			memory.writebyte(0x009f + i, math.fmod(memory.readbyte(0x009F + i) - 1, 0x20));
			haha	= true;
		end;
	end;

	if haha then
		gui.text(65, 31, " You're screwed now! :D ");
	else
		gui.drawpixel(1, 1, "clear");
	end;


	FCEU.frameadvance();
end;