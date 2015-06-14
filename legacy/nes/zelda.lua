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


healthb	= memory.readbyte(0x066F);
maxhp	= ((math.floor(healthb / 0x10) + 1) * 0x100);
curhp	= math.fmod(healthb, 0x10) * 0x100 + memory.readbyte(0x0670);
curhp2	= curhp;
curhp2s	= 0;
maxhp2	= math.ceil((maxhp / 0xFFF) * 251);
timer	= 0;

while true do

	timer	= timer + 1;

	healthb	= memory.readbyte(0x066F);
	maxhp	= ((math.floor(healthb / 0x10) + 1) * 0x100) - 1;
	curhp	= math.fmod(healthb, 0x10) * 0x100 + memory.readbyte(0x0670);
	if (math.abs(curhp - curhp2) < 1 and math.abs(curhp2s) < 1) then
		curhp2	= curhp;
		curhp2s	= 0;
	elseif (curhp2 ~= curhp) then
		curhp2s	= (curhp2s * 0.95) - (curhp2 - curhp) / 25;
	end;
	curhp2	= curhp2 + curhp2s;

	text(180, 30, string.format("%4X/%4X", curhp, maxhp));
	c		= "#ffffff";
	if (maxhp2 < math.ceil((maxhp / 0xFFF) * 251)) then
		maxhp2	= maxhp2 + 1;
		if (math.fmod(timer, 4) < 2) then
			c	= "#dd0000";
		end;
	elseif (maxhp2 ~= math.ceil((maxhp / 0xFFF) * 251)) then
		maxhp2	= math.ceil((maxhp / 0xFFF) * 251);
	end;

--	maxhp2	= 251;
	lifebar(math.min(251 - maxhp2, 206 - maxhp2 / 2), 56, maxhp2, 2, math.max(0, curhp2), maxhp, "#ff8888", "#880000", false, c);





	FCEU.frameadvance();
end