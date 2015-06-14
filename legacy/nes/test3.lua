require("x_functions");

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
	x_requires(2);
end;


--[[

function drawloop()
	timer		= os.clock();
	text(8, 24, string.format("%0.3f", timer - timerold));
	lifebar(38, 26, 200, 3, timer - timerold, 1, "#ffffff", "#000088");
	text(8, 32, string.format("%0.3f", etimer - etimerold));
	lifebar(38, 34, 200, 3, etimer - etimerold, 1, "#ffffff", "#000088");
	timerold	= timer;
	text(8, 16, "GUI register loop");

	text(8, 228, string.format("%6.3f", os.clock()));

end;

timerold	= 0;
etimer		= 0;
etimerold	= 0;

--]]
timer		= 0;
-- gui.register(drawloop);


while (true) do

	timer = timer + 1;

	lifebar(50, 50, 100, 3, math.sin((timer +  0) / 50) * 50 + 50, 100, "#ffffff", "#00ff00");
	lifebar(50, 60, 100, 3, math.sin((timer + 20) / 50) * 50 + 50, 100, "#ffffff", "#00ff00", "#ff0000");
	lifebar(50, 70, 100, 3, math.sin((timer + 40) / 50) * 50 + 50, 100, "#ffffff", "#00ff00", "#ff0000", "#0000ff");
	lifebar(50, 80, 100, 3, math.sin((timer + 60) / 50) * 50 + 50, 100, "#ffffff", "#00ff00", false);
	lifebar(50, 90, 100, 3, math.sin((timer + 80) / 50) * 50 + 50, 100, "#ffffff", "#00ff00", true);
--[[

	etimer		= os.clock();

	text(8, 40, "Emulation loop");
	etimerold	= etimer;
--]]
	FCEU.frameadvance();


end;



