while true do

	keys	= input.get();
	if keys['A'] then

		bang1	= math.random(0x9800, 0xFFFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);

		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['S'] then

		bang1	= math.random(0x9800, 0xFFFF)
		bang2	= AND(memory.readbyte(bang1) + math.random(-1, 1), 0xFF);
		memory.writebyte(bang1, bang2);

		print(string.format("%04X => %02X", bang1, bang2));
	end;

	-- KABLOOEY
	if keys['M'] then

		for i = 0, 0xF do
			bang1	= math.random(0xA000, 0xFFFF)
			bang2	= math.random(0x00, 0xFF);
			memory.writebyte(bang1, bang2);
		
			print(string.format("%04X => %02X", bang1, bang2));
		end;
	end;

	if keys['Q'] then

		bang1	= math.random(0x8000, 0x9FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);

		print(string.format("%04X => %02X", bang1, bang2));
	end;
	
	vba.frameadvance();

end;