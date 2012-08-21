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
	x_requires(4);
end;


function hex2dec(hexval) 

	tens	= math.floor(hexval / 0x10) * 10;
	ones	= math.fmod(hexval, 0x10);

	return tens + ones;
end;

player	= {};
screen	= {};

while true do

	player['hp']	= hex2dec(memory.readbyte(0x009A)) * 100 + hex2dec(memory.readbyte(0x0099));
	player['mhp']	= hex2dec(memory.readbyte(0x009C)) * 100 + hex2dec(memory.readbyte(0x009B));
	player['mp']	= hex2dec(memory.readbyte(0x009E)) * 100 + hex2dec(memory.readbyte(0x009D));
	player['mmp']	= hex2dec(memory.readbyte(0x00A0)) * 100 + hex2dec(memory.readbyte(0x009F));
	player['sword']	= memory.readbyte(0x008F);
	player['boots']	= memory.readbyte(0x0096);
	player['xpos']	= memory.readbyte(0x0707) * 0x100 + memory.readbyte(0x0708);
	player['ypos']	= memory.readbyte(0x0705) * 0x100 + memory.readbyte(0x0706);

	temp			= math.floor(memory.readbyte(0x0021) / 2);
	screen['xpos']	= (memory.readbyte(0x006D) - 0x11 * temp) * 0x100 + memory.readbyte(0x0030);
	screen['ypos']	= memory.readbyte(0x0701) * 0x100 + memory.readbyte(0x0702);

	lifebar(  77, 209, 100, 4, player['hp'], player['mhp'], "#ffaaaa", "#990000", "#000000", "#ff0000");
	lifebar(  77, 217, 100, 2, player['mp'], player['mmp'], "#88ffff", "#003399", "#000000", "#6699ff");

	text(   8, 11, string.format("Sword: %2d", player['sword']));
	text(   8, 19, string.format("Boots: %2d/3", player['boots']));

	text( 178, 11, string.format("C %5d %5d", screen['xpos'], screen['ypos']));
	text( 178, 19, string.format("P %4X %4X", player['xpos'], player['ypos']));

	text(50, 50, string.format("%02X %02X %02X", memory.readbyte(0x0021), memory.readbyte(0x006D), memory.readbyte(0x0030)));

	text(  92, 200, string.format("HP %4d/%4d", player['hp'], player['mhp']));
	text(  92, 222, string.format("MP %4d/%4d", player['mp'], player['mmp']));

--	temp	= (screen['xpos'] / 160);
--	line(temp, 64, temp, 90, "#ffffff");

	temp	= (player['xpos'] / 16);
	line(temp, 64, temp, 90, "#ffffff");


	base	= 0x0763;
	for e = 0, 1 do
		eoffset	= base + e * 0x0C;

		out	= string.format("%d>", e);

		for i = 0, 0xA do
			if i < 0x6 or i > 0x09 then
				out	= out .. string.format(" %2X", memory.readbyte(eoffset + i));
--			else
--				out	= out .. " XX";
			end;
		end;
	
		ex		= memory.readbyte(eoffset + 0x08) * 0x100 + memory.readbyte(eoffset + 0x09);
		ey		= memory.readbyte(eoffset + 0x06) * 0x100 + memory.readbyte(eoffset + 0x07);
		
		text(   8, 28 + e * 8, out);
		text( 172, 28 + e * 8, string.format("E%1d %4X %4X", e, ex, ey));
	end;


	FCEU.frameadvance();

end