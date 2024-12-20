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


inputlast	= {};
life		= 30;
timer		= 0;

while true do

	timer		= timer + 1;

	inputthis	= joypad.read(1);
	if inputthis['A'] and not inputlast['A'] then
		life	= life - 1;
	elseif inputthis['B'] and not inputlast['B'] then
		life	= life + 1;
	end;
	inputlast	= table.clone(inputthis);

	if life > 20 or math.fmod(timer, math.ceil(life / 2)) >= 1 then
		c		= "#ffffff";
	else
		c		= "#dd0000";
	end;

	lifebar(8, 8, 200, 4, life, 100, c, "#000000", "#000000", "#dd0000");
	text(8, 16, string.format("%3d/100", life));



	FCEU.frameadvance();
end;