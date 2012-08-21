
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
	x_requires(4);
end;


speedgraph		= {};
timer			= 0;
graphlen		= 240;

while (true) do 
	
	joyin	= joypad.read(1);
	if joyin['up'] then
--		memory.writebyte(0x009F, -5);
--		memory.writebyte(0x07F8, 9);
	end;

	
	timer				= timer + 1;

	maxspeed			= 0x28;
	marioxspeed			= memory.readbytesigned(0x0057);
	marioxspeed2		= math.abs(marioxspeed);
--[[
	speedgraph[timer]	= marioxspeed2;
	if timer > graphlen then
		temp				= timer - graphlen - 1;
		speedgraph[temp]	= nil;
	end;
--]]

	text(maxspeed * 3 + 2, 221, string.format(" %2d", marioxspeed2));

	box(5, 221, maxspeed * 3 + 5, 230, "#000000");
	box(5, 222, maxspeed * 3 + 5, 229, "#000000");
	box(5, 223, maxspeed * 3 + 5, 228, "#000000");
	box(5, 224, maxspeed * 3 + 5, 227, "#000000");
	box(5, 225, maxspeed * 3 + 5, 226, "#000000");

	if marioxspeed2 > 0 then 
		for bl = 1, marioxspeed2 do
		
			pct		= bl / maxspeed;
			if pct < 0.50 then
				val		= math.floor(pct * 2 * 0xFF);
				segcolor	= string.format("#%02XFF00", val);

			elseif pct < 0.90 then
				val		= math.floor(0xFF - (pct - 0.5) * 100/40 * 0xFF);
				segcolor	= string.format("#FF%02X00", val);

			elseif bl < maxspeed then
				val	= math.floor((pct - 0.90) * 10 * 0xFF);
				segcolor	= string.format("#FF%02X%02X", val, val);

			else
				segcolor	= "#ffffff";
			end;

			yb			= math.max(math.min(3, (bl - 0x18)), 0);
			box(bl * 3 + 3, 225 - yb, bl * 3 + 4, 229, segcolor);
--			box(bl * 3 + 3, 218, bl * 3 + 4, 225, segcolor);
--			line(bl * 3 + 4, 218, bl * 3 + 4, 225, segcolor);
		end;
	end;
		

--[[
	for i = timer - graphlen, timer do
		if speedgraph[i] then
			xp		= ((i + 3) - timer) + graphlen;

--			pixel(((i + 3) - timer) + 60, 50 - speedgraph[i], "#ffffff");
			line(xp, 50 - speedgraph[i], xp, 50, "#0000ff");
			pixel(xp, 50 - speedgraph[i], "#ffffff");

--			pixel(((i + 3) - timer) + 60, 50 - speedgraph[i], "#ffffff");
		end;
	end;

]]

	FCEU.frameadvance();
end;