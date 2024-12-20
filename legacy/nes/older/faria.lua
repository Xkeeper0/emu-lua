
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



player		= {};



while true do

	player['overx']			= memory.readbyte(0x00c1);
	player['overy']			= memory.readbyte(0x00c2);
	player['townx']			= memory.readbyte(0x00b4);
	player['towny']			= memory.readbyte(0x00b5);
	player['battlex']		= memory.readbyte(0x0023);
	player['battley']		= memory.readbyte(0x0024);
	player['hp']			= memory.readbyte(0x6914);
	player['hpmax']			= memory.readbyte(0x6915);
	player['hpchargeb']		= math.fmod(memory.readbyte(0x7191), 0x40);
	player['hpchargeo']		= math.fmod(memory.readbyte(0x00EC), 0x08);

	if player['hp'] < 100 then
		memory.writebyte(0x6914, player['hpmax']);
	end;


	line(0, player['battley'], 255, player['battley'], "#ffffff");
	line(player['battlex'], 0, player['battlex'], 240, "#ffffff");

	text(  8,   8, string.format("HP: %3d/%3d (%2d%%, %02X)", player['hp'], player['hpmax'], math.floor(player['hpchargeb'] / 0x40 * 100), player['hpchargeo']));

	text(  8,  16, string.format("X: %02X  Y: %02X", player['overx'], player['overy']));
	text(  8,  24, string.format("X: %02X  Y: %02X", player['townx'], player['towny']));


	s	= "  ";
	o	= 0x00;
	for i = 0, 0xF do
		s	= s .. string.format(".%2X", i);
	end;
	text(   0, 190 - 9, s);


--[[

	Enemy data seems to be 0x2A bytes long. Starts at 0x700.

	00		X position
	01		Y position

	05		Type? Doesn't seem to have much of an effect.

	09		Mimics 0A. Unknown feature?
	0A		Seems to have something to do with palettes...?
			If >= 0x80, bag of money.

	0B		Size; 1 = 8x8, 2 = 16x16, 3 = 24x24, etc.

	20		HP remaining


**************************
	Enemy types:

	?	Green bug thing
	
	19	Crab-like thing (blue)
	25	Tentamouth (red)
	31	Bug (? sometimes shoots lasers?)
	3D	Octopus (red)
	49*	Invisible 16x16 enemy (shoots beams)
	55	Snail (blue)
	61	Slime (blue, 41HP)
	6D	Blob with legs
	6F	One-eyed tentacle thing (green)
	70	Headed warrior (orc?)
	73	Headless warrior
	78*	Maybe I'd find out if this game wasn't such a pain


--]]
	for eid = 0, 5 do
		ex	= memory.readbyte(0x700 + eid * 0x2a);
		ey	= memory.readbyte(0x701 + eid * 0x2a);
		es	= memory.readbyte(0x70b + eid * 0x2a);
		el	= memory.readbyte(0x720 + eid * 0x2a);
		et	= memory.readbyte(0x705 + eid * 0x2a);
		s	= string.format("%2X", eid * 0x2a + o);
		for i = 0, 0xF do
			s	= s .. string.format(".%02X", memory.readbyte(0x700 + eid * 0x2a + i + o));
		end;

		box(ex, ey, ex + es * 8, ey + es * 8, "#ffffff");
--		line(ex, 0, ex, 240, "#ffffff");
		text(ex - 1, ey - 10, string.format("%d: %02X %02X", eid, el, et));
		text(   0, 190 + eid * 8, s);
	end;






	FCEU.frameadvance();
end;