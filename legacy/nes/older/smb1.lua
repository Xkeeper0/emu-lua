
require("x_functions");

if not x_requires then
	-- Sanity check. If they require a newer version, let them know.
	timer	= 1;
	while (true) do
		timer = timer + 1;
		for i = 0, 30 do
			gui.drawbox( 8, 30 + i, 248, 90 - i, "#000000");
		end;
		gui.text( 10, 32, string.format("This Lua script requires the x_functions library."));
		gui.text( 53, 40, string.format("It appears you do not have it."));
		gui.text( 39, 60, "Please get the x_functions library at");
		gui.text( 14, 70, "http://xkeeper.shacknet.nu/");
		gui.text(111, 78, "emu/nes/lua/x_functions.lua");
		if math.fmod(timer, 60) < 30 then
			gui.drawbox(7, 29, 249, 91, "#ff0000");
		else 
			gui.drawbox(7, 29, 249, 91, "#ffffff");
		end;

		FCEU.frameadvance();
	end;

else
	x_requires(2);
end;

function graph(x, y, sx, sy, minx, miny, maxx, maxy, xval, yval, color, border, filled)


	if (filled ~= nil) then
		filledbox(x + 1, y + 1, x+sx, y+sy, "#000000");
	end;
	if (border ~= nil) then
		box(x, y, x+sx+1, y+sy+1, color);
	end;
	

	xp	= (xval - minx) / (maxx - minx) * sx;
	yp	= (yval - miny) / (maxy - miny) * sy;

	line(x + 1     , yp + y + 1, x + sx + 1, yp + y + 1, color, true);
	line(xp + x + 1, y + 1     , xp + x + 1, y + sy + 1, color, true);

	return true;
end;


while (true) do

--	0x9F=FB-04   0x57=28
	marioyspeed			= memory.readbytesigned(0x009F);
	marioxspeed			= memory.readbytesigned(0x0057);

	graph( 16, 10, 160, 27, -40, -5, 40, 4, 0, 0, "#888888", true, true);
	graph( 16, 10, 160, 27, -40, -5, 40, 4, marioxspeed, marioyspeed, "#ffffff");
	text(18, 29, string.format("%d, %d", marioxspeed, marioyspeed));


	FCEU.frameadvance();
end;



