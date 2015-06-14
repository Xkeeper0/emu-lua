require "x_functions";

if not x_requires then
	-- Sanity check. If they require a newer version, let them know.
	timer	= 1;
	while (true) do
		timer = timer + 1;
		for i = 0, 32 do
			gui.drawbox( 6, 28 + i, 250, 92 - i, "#000000");
		end;
		gui.text( 10, 32, string.format("This Lua script requires the x_functions library."));
		gui.text( 53, 42, string.format("It appears you do not have it."));
		gui.text( 39, 58, "Please get the x_functions library at");
		gui.text( 14, 69, "http://xkeeper.shacknet.nu/");
		gui.text(114, 78, "emu/nes/lua/x_functions.lua");

		warningboxcolor	= string.format("%02X", math.floor(math.abs(30 - math.fmod(timer, 60)) / 30 * 0xFF));
		gui.drawbox(7, 29, 249, 91, "#ff" .. warningboxcolor .. warningboxcolor);

		FCEU.frameadvance();
	end;

else
	x_requires(5);

end;




cursorx	= 0;
cursory	= 0;

while true do

	scrolltype	= memory.readbyte(0x00D8);
	playerx		= (memory.readbyte(0x0014) * 0x100) + memory.readbyte(0x0028);
	playery		= (memory.readbyte(0x001E) * 0x100) + memory.readbyte(0x0032);
	screenx		= memory.readbyte(0x04BE) * 0x100 + memory.readbyte(0x04C0);
	screeny		= memory.readbyte(0x00CA) * 0x100 + memory.readbyte(0x00CB);

	text(  8,  16, string.format("PX %04X  PY %04X", playerx, playery));
	text(  8,  24, string.format("SX %04X  SY %04X", screenx, screeny));
	text(  8,  32, string.format("ScrollType %02X", scrolltype));


	FCEU.frameadvance();
end;