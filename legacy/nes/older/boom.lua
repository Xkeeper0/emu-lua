funtimes = 0;

txttime	= 0;
while true do

	keys	= input.get();
	
	reset	= 0;
	if keys['A'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['Q'] then

		bang1	= math.random(0x6000, 0x7FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;

--		print(string.format("%04X => %02X", bang1, bang2));
	end;

	if reset == 1 then
		if txttime > 35 then
			txttime	= -5;
		elseif txttime == -5 then
			-- do nothing
		
		elseif txttime >= 0 then
			txttime	= 0
		end;
	end;
--[[
	if txttime < 0 then
		gui.text(0, 230 + (txttime / 5 * -10), "Total bytes corrupted: ".. funtimes);
	elseif txttime < 30 then
		gui.text(0, 230, "Total bytes corrupted: ".. funtimes);
	elseif txttime < 35 then
		gui.text(0, 230 + (txttime - 30) * 2, "Total bytes corrupted: ".. funtimes);
	else
		gui.pixel(0, 0, 0);
	end;
--]]	
	txttime	= txttime + 1;
	emu.frameadvance();

end;