require "x_functions";

savetofilename	= "andrewg-speedrun.xrp";


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



function memwatch(y, address, title)

	if not title then
		title	= "";
	else
		title	= " - ".. title;
	end;

	text(8, y * 8 + 8, string.format("0x%04X: %02X%s", address, memory.readbyte(address), title));
	
	return true;
end;


while (true) do


	joystuck	= joypad.read(1);
	if joystuck['up'] and not upheld then
		memory.writebyte(0x0750, 0xc2);
		memory.writebyte(0x0751, math.random(0x00, 0x09));
		memory.writebyte(0x0752, math.random(0x01, 0x03));
		memory.writebyte(0x0772, 0x00);
		upheld	= true;
	elseif joystuck['up'] and upheld then
		upheld	= true;
	else
		upheld	= false;
	end;


	memwatch( 0, 0x0772, "Loading?");
	memwatch( 1, 0x0760, "Area#");

	memwatch( 2, 0x0750, "NextArea");
	memwatch( 3, 0x0751, "NextPage");
	memwatch( 4, 0x0752, "AltEntranceCtrl");
	
	-- AltEntranceCtrl determines how the game loads the next area.
	-- 00: Lives counter transition, the works. Seems to ignore page data...
	-- 01: Standard entrance for that level
	-- 02: Comes out of pipe
	-- 03: Falls from ceiling
	-- 04: "Freezes". Waiting for vine?
	-- 05 and above: untested. Mostly. 5 drops him at the leftmost edge of the screen, broken; 6 does it too.

	text(140, 8, "Trigger warp with up");



	FCEU.frameadvance();

end;
