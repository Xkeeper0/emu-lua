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



function drawpos(cx, cy, ex, ey, n, i)
	sx	= ex - cx;
	sy	= ey - cy;
	
	num	= "";
	if n then
		num	= string.format("%02X", n);	
	end;

	if sx >= 0 and sx <= 255 and sy >= 0 and sy <= 244 then
		line(sx, sy, sx + 16, sy +  0, "red");
		line(sx, sy, sx +  0, sy + 16, "red");
	
		if (i ~= nil and i == 0) then
			num	= num .. " [O/P]";
		end;
		text(sx, math.max(0, sy - 8), num);

	elseif sx < 0 and sy >= 0 and sy <= 244 then
		line(0, sy, 16, sy, "red");
		text(4, sy, num);

	elseif sx > 255 and sy >= 0 and sy <= 244 then
		line(239, sy, 255, sy, "red");
		text(243, sy, num);

	elseif sy < 0 and sx >= 0 and sx <= 256 then
		line(sx, 8, sx, 24, "red");
		text(sx, 8, num);

	elseif sy > 244 and sx >= 0 and sx <= 256 then
		line(sx, 212, sx, 244, "red");
		text(sx, 216, num);
	
	end;

	gpx		= math.floor(ex / 0x20);
	gpy		= math.floor(ey / 0x20);
	box      (gposx + gpx, gposy + gpy, gposx + gpx +  1, gposy + gpy +  1, "red");


end;


lagdetectorold	= 0;
timer			= 0;
lagframes		= 0;
lastlag			= 0;
gposx			= 120;
gposy			= 9;

inpt			= {};
inptold			= {};

forcefull		= false;

while (true) do 

	inptold		= inpt;
	inpt		= input.get();

	spr1		= memory.readbyte(0x104);
	spr2		= memory.readbyte(0x106);
	enef		= memory.readbyte(0x7680);
	
	if (inpt['shift']) and math.fmod(timer, 2) == 0 then
		inptold	= {};
		
	end;
	
	if (inpt['I'] and not inptold['I']) then
		memory.writebyte(0x104, spr1 + 1);
	end
	if (inpt['U'] and not inptold['U']) then
		memory.writebyte(0x104, spr1 - 1);
	end
	if (inpt['K'] and not inptold['K']) then
		memory.writebyte(0x106, spr2 + 1);
	end
	if (inpt['J'] and not inptold['J']) then
		memory.writebyte(0x106, spr2 - 1);
	end
	
	if (inpt['P'] and not inptold['P']) then
		memory.writebyte(0x7680, enef + 1);
	end
	if (inpt['O'] and not inptold['O']) then
		memory.writebyte(0x7680, enef - 1);
	end


	if (inpt['Q'] and not inptold['Q']) then
		forcefull	= not forcefull;
	end
	
	
	
	gui.text(180, 30, string.format("1: %02X [I/U]\n2: %02X [J/K]", spr1, spr2));
	
	
	timer	= timer + 1;

	lagdetector	= memory.readbyte(0x00f5);
--	if lagdetector == lagdetectorold then
	if AND(lagdetector, 0x20) == 0x20 then
--	if lagdetector == 0x0C then
		lagframes	= lagframes + 1;
	else
		if lagframes ~= 0 then 
			lastlag = lagframes;
		end;
		lagframes	= 0;
		lagdetectorold	= lagdetector;
	end;
	memory.writebyte(0x00f5, OR(lagdetector, 0x20));

	if forcefull then
		gui.text(180, 50, "MaxSize");
		memory.writebyte(0x0461, 0);
		memory.writebyte(0x0460, 0);
		
		memory.writebyte(0x0463, 0);
		memory.writebyte(0x0462, 0);

		memory.writebyte(0x0465, 0x0F);
		memory.writebyte(0x0464, 0x00);
		
		memory.writebyte(0x0467, 0x00);
		memory.writebyte(0x0466, 0xEF);
	end
	
	playerx	= memory.readbyte(0x0432) + memory.readbyte(0x0433) * 0x100;
	playery	= memory.readbyte(0x0435) + memory.readbytesigned(0x0436) * 0x100;
	screenx	= memory.readbyte(0x0456) + memory.readbyte(0x0457) * 0x100;
	screeny	= memory.readbyte(0x0458) + memory.readbytesigned(0x0459) * 0x100;
	gpx		= math.floor(playerx / 0x20);
	gpy		= math.floor(playery / 0x20);
	gsx		= math.floor(screenx / 0x20);
	gsy		= math.floor(screeny / 0x20);

	text(  8,   8, string.format("%04X, %04X", playerx, AND(playery, 0xFFFF)));
	text(  8,  16, string.format("%04X, %04X", screenx, AND(screeny, 0xFFFF)));


	areaxs		= memory.readbytesigned(0x0461) * 0x100 + memory.readbyte(0x0460);
	areaxe		= memory.readbytesigned(0x0465) * 0x100 + memory.readbyte(0x0464);
	areays		= memory.readbytesigned(0x0463) * 0x100 + memory.readbyte(0x0462);
	areaye		= memory.readbytesigned(0x0467) * 0x100 + memory.readbyte(0x0466);
	
	text(  8,  26, string.format("%04X, %04X\n%04X, %04X", areaxs, areays, areaxe, areaye));
	
	
	asxs		= math.floor(areaxs / 0x20);
	asxe		= math.floor(areaxe / 0x20);
	asys		= math.floor(areays / 0x20);
	asye		= math.floor(areaye / 0x20);



	filledbox(gposx      , gposy      , gposx + 8 * 0x10, gposy + 7 * 2   , "black");
	filledbox(gposx + asxs - 1, gposy + asys - 1, gposx + asxe +  7 + 1, gposy + asye +  7 + 1, "blue");
	box(gposx + asxs - 1, gposy + asys - 1, gposx + asxe +  7 + 1, gposy + asye +  7 + 1, "white");
	filledbox(gposx + gsx, gposy + gsy, gposx + gsx +  7, gposy + gsy +  7, "gray");

	

	
	if math.fmod(timer, 20) <= 10 then
		c	= "white";
	else
		c	= "black";
	end;

	drawpos(screenx, screeny, playerx, playery);
	box      (gposx + gpx, gposy + gpy, gposx + gpx +  1, gposy + gpy +  1, c);


	tmp		= 0;
	for i = 0, 0xb do
		
		offset	= 0x7680 + i * 0x20;
	
		enemyt	= memory.readbyte(offset);
		enemyx	= memory.readbyte(offset + 2) + memory.readbyte(offset + 3) * 0x100;
		enemyy	= memory.readbyte(offset + 4) + memory.readbyte(offset + 5) * 0x100;

		if enemyt ~= 0xff then
--			text(160, 8 + 8 * tmp, string.format("%02X: %02X <%04X, %04X>", i, enemyt, enemyx, enemyy));
			drawpos(screenx, screeny, enemyx, enemyy, enemyt, i);
			tmp	= tmp + 1;
		end
	end;


	

--	text(142, 192, string.format("%02d lag frames", lastlag));
--	text(142, 216, string.format("%02d active sprites", tmp));
--	lifebar(144, 200, 100, 4, lastlag, 8, "#ffcc22", "#000000");
--	lifebar(144, 208, 100, 4, tmp, 12,    "#4488ff", "#000000");

	FCEU.frameadvance();

end;















