require "x_functions";



-- Set to "true" to disable all hotkeys
-- Set to "false" to enable hotkeys
NO_HOT_KEYS	= true



-- -------------------------------------------------------------------------------

function forcez()
	if memory.readdwordsigned(0x800BA028) == 32768 then
		memory.writedword(0x800BA028, 26000);
	end;

end;

function drawmap(x, y)

	--gui.gdoverlay(0, 0, mapimage, 0.25);
	
	locx		= memory.readdwordsigned(0x800BA024);
	locy		= memory.readdwordsigned(0x800BA02C);
	drawmapdot(x, y, locx, locy, "#ff00ff");

--[[
	locx	= 623575;
	locy	= 502062;
	drawmapdot(x, y, locx, locy);

	locx	=  82662;
	locy	= 230944;
	drawmapdot(x, y, locx, locy);

	locx	= 0;
	locy	= 0;
	drawmapdot(x, y, locx, locy, "#ff0000");

	locx	= 0;
	locy	= -1500000;
	drawmapdot(x, y, locx, locy, "#ff00ff");
--]]
end;


function drawmapdot(x, y, posx, posy, c)
	if not c then
		c	= "#ffffff";
	end;

	xadd	= 1622739;
	xdiv	=   17500;
	yadd	=  987500;
	ydiv	=   17500;

	mapx	=       math.floor((posx + xadd) / xdiv);
	mapy	= 112 - math.floor((posy + yadd) / ydiv);
	
	if (mapx < 0 or mapx > 160) and mapy >= 0 and mapy <= 120 then
		if mapx < 0 then
			line(   4 + x, mapy + y - 2,    5 + x, mapy + y - 2, c);
			line(   2 + x, mapy + y - 1,    5 + x, mapy + y - 1, c);
			line(   0 + x, mapy + y + 0,    5 + x, mapy + y + 0, c);
			line(   2 + x, mapy + y + 1,    5 + x, mapy + y + 1, c);
			line(   4 + x, mapy + y + 2,    5 + x, mapy + y + 2, c);
			text(   7 + x, mapy + y - 3, string.format("%d", mapx * -1));
		else
			line( 155 + x, mapy + y - 2,  156 + x, mapy + y - 2, c);
			line( 155 + x, mapy + y - 1,  158 + x, mapy + y - 1, c);
			line( 155 + x, mapy + y + 0,  160 + x, mapy + y + 0, c);
			line( 155 + x, mapy + y + 1,  158 + x, mapy + y + 1, c);
			line( 155 + x, mapy + y + 2,  156 + x, mapy + y + 2, c);
			text( 139 + x, mapy + y - 3, string.format("%4d", mapx - 160));
		end;
	elseif (mapx >= 0 and mapx <= 160) and (mapy < 0 or mapy >= 120) then
		if mapy < 0 then
			line(  -2 + mapx + x, y +   4, -2 + mapx + x, y +   5, c);
			line(  -1 + mapx + x, y +   2, -1 + mapx + x, y +   5, c);
			line(   0 + mapx + x, y +   0,  0 + mapx + x, y +   5, c);
			line(   1 + mapx + x, y +   2,  1 + mapx + x, y +   5, c);
			line(   2 + mapx + x, y +   4,  2 + mapx + x, y +   5, c);
			text(  -5 + mapx + x, y +   6, string.format("%3d", mapy * -1));
		else
			line(  -2 + mapx + x, y +  -5 + 120, -2 + mapx + x, y +  -4 + 120, c);
			line(  -1 + mapx + x, y +  -5 + 120, -1 + mapx + x, y +  -2 + 120, c);
			line(   0 + mapx + x, y +  -5 + 120,  0 + mapx + x, y +  -0 + 120, c);
			line(   1 + mapx + x, y +  -5 + 120,  1 + mapx + x, y +  -2 + 120, c);
			line(   2 + mapx + x, y +  -5 + 120,  2 + mapx + x, y +  -4 + 120, c);
			text(  -5 + mapx + x, y + -12 + 120, string.format("%3d", mapy - 120));
		end;
	else
		box  (mapx - 1 + x, mapy - 1 + y, mapx + 1 + x, mapy + 1 + y, c);
		pixel(mapx - 1 + x, mapy - 1 + y, mapx + 1 + x, mapy + 1 + y, c);
	end;
end;



function quickscreen(x, y, fmt, addr, isnotaddr)

	local crud	= addr;
	if not isnotaddr then
		-- double negatives
		crud	= memory.readdwordsigned(addr);
	end;
		
	gui.text(x, y * 8, string.format(fmt, crud));

end;
function quickscreen2(x, y, fmt, addr, isnotaddr)

	local crud	= addr;
	if not isnotaddr then
		-- double negatives
		crud	= memory.readwordsigned(addr);
	end;
		
	gui.text(x, y * 8, string.format(fmt, crud));

end;


function forcecam()
	-- Force X, Y, Z
	memory.writedword(0x800B9D20, memory.readdwordsigned(0x800BA024));
	memory.writedword(0x800B9D28, memory.readdwordsigned(0x800BA02C));
	memory.writedword(0x800B9D24, memory.readdwordsigned(0x800BA028) - 0xC000);
	-- Z is set a ways above the player to give top-down perspective
	
	-- Force straight-down
	memory.writeword(0x800B9D8a, 0);
	memory.writeword(0x800B9D88, -1000);
	memory.writeword(0x800B9D8c, 0);
	
end;


function rangediv(min, max, val, mlt)
	if not mlt then
		mlt	= 1;
	end;

	local base	= min + max;
	local val2	= val + min;
	return math.min(math.max(0, val2 / base), 1) * mlt;

end;




derp		= false;
fcam		= false;

-- memory.register(0x0BA028, forcez);

last		= {};

--[[
mapfile		= assert(io.open("lua\\map.gd", "rb"));
mapimage	= mapfile:read("*all");
io.close(mapfile);
--]]


mspeed		= 100;
timer		= 0;
inkey		= input.get();


showcam		= false;
camforce	= {
	x		= 0,
	y		= 0,
	z		= -0xC000,
	pan		= 0,
	tilt	= -1000,
	roll	= 0
	}

camforcel	= {
	min	= {
		x		= -0x80000,
		y		= -0x80000,
		z		= -0xC000,
		pan		= -2000,
		tilt	= -1000,
		roll	= 0
		},
	max	= {
		x		= 0x80000,
		y		= 0x80000,
		z		= 0xC000,
		pan		= 2000,
		tilt	= -1000,
		roll	= 0
		}
	};

	


while true do

	timer	= timer + 1;

	lastkey	= table.clone(inkey);
	inkey	= input.get();

	if NO_HOT_KEYS then
		inkey	= {}
		inkey.xmouse	= 0
		inkey.ymouse	= 0
	end

	
	if inkey['P'] and not lastkey['P'] then
		showcam	= not showcam;
	end;
	
	

	-- Status goes yellow below 0550 (1360)
	-- Status goes orange below 0410 (1040)
	-- -- Status pulsates faster if health goes below 0320 ( 800)
	-- Status goes red if below 0270 ( 624)
	-- -- Pulsates even faster   if health goes below 00A0 ( 160)
	-- Health drinks recover 640 HP

	if inkey['numpad3'] or (inkey['numpad6'] and not lastkey['numpad6']) then
		hpt	= hpt + 1;
		hp2	= math.floor(hpt / 0x100);
		hp1	= math.fmod(hpt, 0x100);
		memory.writeword(0x800BA0BE, hp2);
		memory.writebyte(0x800BA0BD, hp1);

	elseif inkey['numpad2'] or (inkey['numpad5'] and not lastkey['numpad5']) then
		hpt	= hpt - 1;
		hp2	= math.floor(hpt / 0x100);
		hp1	= math.fmod(hpt, 0x100);
		memory.writeword(0x800BA0BE, hp2);
		memory.writebyte(0x800BA0BD, hp1);
	end;

--	if (inkey['M']) then
--		memory.writebyte(0x80B9FC8, 9);
--		text(1, 1, "fart");
--	end;
	--[[

	loct		= memory.readdwordsigned(0x800B9E08);
	camt		= memory.readdwordsigned(0x801FFD70);
	text( 100,  176, string.format("C Pos %8d %8d", loct, camt));
	--]]
	
	
	
	quickscreen(200,  1, "X %8d", 0x800BA024);
	quickscreen(200,  2, "Y %8d", 0x800BA02C);
	quickscreen(200,  3, "Z %8d", 0x800BA028);
	quickscreen(200,  4, "A %8.2f", memory.readdwordsigned(0x800BA030) / 0x0FFFFFFF * 360, true);

	quickscreen(260,  1, "DCamX %8d", 0x800B9D14);
	quickscreen(260,  2, "DCamY %8d", 0x800B9D1C);
	quickscreen(260,  3, "DCamZ %8d", 0x800B9D18);

	quickscreen(260,  5, "Cam X %8d", 0x800B9D20);
	quickscreen(260,  6, "Cam Y %8d", 0x800B9D28);
	quickscreen(260,  7, "Cam Z %8d", 0x800B9D24);
	quickscreen(260,  8, "Cam ? %8d", 0x800B9D2C);
	
	quickscreen2(260, 10, "Pan   %8d", 0x800B9D8a);
	quickscreen2(260, 11, "Tilt  %8d", 0x800B9D88);
	quickscreen2(260, 12, "Roll  %8d", 0x800B9D8c);

	quickscreen2(240, 20, "HP %d/1600", 0x800BA0BD);
	quickscreen(240, 21, "Winded: %8d", 0x800BA108);
	
	
--[[
	quickscreen(130,  1, "Z1 %8d", 0x800B9DE8);
	quickscreen(130,  2, "Z2 %8d", 0x800B9DF0);
	quickscreen(130,  3, "Z3 %8d", 0x800BA028);
	quickscreen(130,  4, "Z4 %8d", 0x800BA0F8);
	quickscreen(130,  5, "Z5 %8d", 0x800C459C);
--]]
	
	if inkey['Y'] then
		memory.writedword(0x800B9DE8, 0);
		memory.writedword(0x800B9DF0, 0);
		memory.writedword(0x800BA028, 0);
		memory.writedword(0x800BA0F8, 0);
		memory.writedword(0x800C459C, 0);
	end;
	
	

	if inkey['P'] then
		test	= math.abs(math.sin(timer / 50) * 0xFFFF);
		memory.writedword(0x800BC360, test);
	end;

	
	
	
	--[[

	-- Camera movement speed; lock to 0 to stop camera from moving
	quickscreen(260,  9, "CSpd? %8d", 0x800B9D30);
	quickscreen(260, 10, "Cspd? %8d", 0x800B9D34);
	quickscreen(260, 11, "Cspd? %8d", 0x800B9D38);
	quickscreen(260, 12, "Cspd? %8d", 0x800B9D3C);

	
	quickscreen2(260, 14, "RCm A %8d", 0x800B9D80);
	quickscreen2(260, 15, "RCm B %8d", 0x800B9D82);
	quickscreen2(260, 16, "RCm C %8d", 0x800B9D84);
	quickscreen2(260, 17, "RCm D %8d", 0x800B9D86);
	quickscreen2(260, 18, "RCm E %8d", 0x800B9D88);
	quickscreen2(260, 19, "RCm F %8d", 0x800B9D8a);
	quickscreen2(260, 20, "RCm G %8d", 0x800B9D8c);
	quickscreen2(260, 21, "RCm H %8d", 0x800B9D8e);
	--]]

	if inkey['U'] then
		gui.text(0, 20, "uuuuuuuuuuuuuuuu");
		pukemode	= math.ceil(math.sin(timer / 50) * 0x7FF);
		
		--	memory.writeword(0x800B9D80, pukemode);
		--	memory.writeword(0x800B9D82, pukemode);
		--	memory.writeword(0x800B9D84, pukemode);
		--	memory.writeword(0x800B9D86, pukemode);
			memory.writeword(0x800B9D88, 0);
			memory.writeword(0x800B9D8a, pukemode);
			memory.writeword(0x800B9D8c, 0);
		--	memory.writeword(0x800B9D8e, pukemode);
	end;
	


	
	--quickscreen(260, 8, "Cam ? %8d", 0x800B9D2C);
	--quickscreen(260, 9, "Cam ? %8.2f", memory.readdwordsigned(0x800B9D2C) / 0xFFFF * 360, true);
	
	
	if inkey['M'] then
		forcecam();
	else
		fcam	= false;
	end;
	if inkey['N'] then
		memory.writedword(0x800B9D2C,
		memory.readdwordsigned(0x800B9D2C) + 0x1000
			);
		gui.text(0, 8, "fart plus PLUS");
	end;
	
	
	
		wind		= memory.readdword(0x800BA108);

		
	
	


	mspeed	= math.min(500, mspeed);

	if inkey['left'] then
		memory.writedword(0x800BA024, memory.readdwordsigned(0x800BA024) - mspeed);
		text(100, 169, "LEEEEEEEFT");
		mspeed	= mspeed + 10;
	elseif inkey['right'] then
		memory.writedword(0x800BA024, memory.readdwordsigned(0x800BA024) + mspeed);
		text(100, 169, "RIIIIIIGHT");
		mspeed	= mspeed + 10;

	elseif inkey['up'] then
		memory.writedword(0x800BA02C, memory.readdwordsigned(0x800BA02C) + mspeed);
		text(100, 169, "UUUUUUUP");
		mspeed	= mspeed + 10;

	elseif inkey['down'] then
		memory.writedword(0x800BA02C, memory.readdwordsigned(0x800BA02C) - mspeed);
		text(100, 169, "DOOOOOOWN");
		mspeed	= mspeed + 10;

	elseif inkey['numpad1'] then
		memory.writedword(0x800BA028, memory.readdwordsigned(0x800BA028) + mspeed);
		text(100, 169, "HIGHHERRRRRRR");
		mspeed	= mspeed + 10;

	elseif inkey['numpad0'] then
		memory.writedword(0x800BA028, memory.readdwordsigned(0x800BA028) - mspeed);
		text(100, 169, "LOWWWWERRRRRR");
		mspeed	= mspeed + 10;

	else
		mspeed	= 100;

	end;


	temp1		= memory.readword(0x8006A5B8);
	temp2		= memory.readword(0x8006A5BA);
	temp3		= memory.readword(0x8006A594);
	temp4		= memory.readword(0x8006A596);

--	text(   1,  30, string.format("??  %04X %04X %04X %04X", temp1, temp2, temp3, temp4));

--	text(   0, 130, string.format("0x800B9DFC = %08X", memory.readdword(0x800B9DFC)));
--	text(   0, 137, string.format("0x800B9FC8 = %08X", memory.readdword(0x800B9FC8)));

	addresses	 = {
		0x800B9DE4,		-- X?
		0x800B9DEC,		-- Y? Seems higher than the other one
		0x800B9DF4,		-- Z? Bigger, doesn't react to input
		0x800B9DFC,		-- Z? Smaller, doesn't react to input either

		0x800B9E24,		-- Y? Seems lower than the other one
		0x800B9E2C,		-- ?
--		0x800B9DE1,
--		0x800B9DE2,
--		0x800B9DE3,
--		0x800B9DE9,
--		0x800B9DEA,
--		0x800B9DEB,
--		0x800B9DED,
--		0x800B9E21,
--		0x800B9E22,
--		0x800B9E23,
--		0x800B9D45,
--		0x800B9D46,
--		0x800B9D47,
--		0x800B9DE0,
--		0x800B9DE4,
--		0x800B9DE8,
--		0x800B9DEC,
	}


	i = 1;
	for k, v in pairs(addresses) do
		i = i + 1;
		vnow	= memory.readdwordsigned(v);
--		text(1, i * 7 + 30, string.format("%08X = %12d", v, vnow));

		update	= true;
		if last[v] then
			chg	= vnow - last[v][2];
			if chg == 0 and not last[v][3] then
				update	= false;
			end;
			m	= 1;
			if chg == 0 and last[v][1] then
				chgd	= last[v][1];
			else
				chgd	= chg;
			end;
			if chgd < 0 then
				m	= -1;
			end;
--			box( 100, i * 7 + 33,  100 + math.sqrt(math.abs(chgd)) * m, i * 7 + 34, "#ff0000");
			--text( 100, i * 7 + 30, math.sqrt(chg));
		end;
		if update then
			last[v]	= {chg, vnow};
		else
			last[v][3]	= true;
		end;

	end;


--	pos1	= memory.readdwordsigned(0x800B9DE4);
--	lifebar(  50,   1, 200, 8, pos1 + 0x80000, 770000, "#ffffff", "#000000");
--	text(    120,   4, string.format("%11d", pos1));
--	pos2	= memory.readdwordsigned(0x800B9DEC);
--	lifebar(  50,  12, 200, 8, pos2 + 0x80000, 0xFFFFF, "#ffffff", "#000000");
--	text(    120,  15, string.format("%11d", pos2));

--	temp1		= memory.readdword(0x800B9D14);
--	text(   1,  30, string.format("%08X", temp1));

	
	spd1	= last[0x800B9DE4][1];
	spd2	= last[0x800B9DEC][1];

	if spd1 and spd2 then
		text(100, 100, string.format("%12d\n%12d", spd1, spd2));
		spd1	= spd1 / 37.8;
		spd2	= spd2 / -37.8;
		line(128, 128, 128 + spd1, 128 + spd2, "#ffffff");
	end;


	xpos	= memory.readdwordsigned(0x800B9DE4);
	ypos	= memory.readdwordsigned(0x800B9DEC);

	--[[
	xpos2	= 300000 + xpos;
	xmax	= 300000 + 770000;

	ypos2	= 900000 - ypos;
	ymax	= 300000 + 600000;

	xposa	= xpos2 / xmax * 100 + 150;
	yposa	= ypos2 / ymax * 100 +  50;

--	box ( 150,  50, 250, 150, "#ffffff");
--	line( xposa, 40, xposa, 160, "#ffffff");
--	line( 140, yposa, 255, yposa, "#ffffff");
	
--	text(150, 50, string.format("X %d - Y %d", xposa, yposa));
	--]]




	if inkey['Z'] then
		walkthroughwalls	= true;
	elseif inkey['X'] then
		walkthroughwalls	= false;
	end;

	if walkthroughwalls then
		text( 255, 10, "NOCLIP");
		memory.writeword(0x8006A5B8, 0xA997);
		memory.writeword(0x8006A5BA, 0x0801);
		memory.writeword(0x8006A694, 0xA9AE);
		memory.writeword(0x8006A696, 0x0801);

--		memory.writeword(0x800BC35C, 0x0100);	-- flashlight

	else
		memory.writeword(0x8006A5B8, 0x000C);
		memory.writeword(0x8006A5BA, 0x1040);
		memory.writeword(0x8006A694, 0x0134);
		memory.writeword(0x8006A696, 0xAFA9);

--		memory.writeword(0x800BC35C, 0x0000);

	end;


--	memory.writedword(0x800BCC08, 0xFFFFFFFF);
--	memory.writedword(0x800BCC0C, 0xFFFFFFFF);
--	memory.writedword(0x800BCC10, 0xFFFFFFFF);


	drawmap(0, 0);

	
	--[[
		strange values:
		0x800BC37A
		0x800BC3AE
		0x800BC4B2
		0x800C4186
	
		0x800CC933
		0x800DDABE
		0x800DFA39
		0x801EEE12
		
	
	]]

--[[
	memory.writebyte(0x800BC37A, 0xFF);
	memory.writebyte(0x800BC3AE, 0xFF);
	memory.writebyte(0x800BC4B2, 0xFF);
	memory.writebyte(0x800C4186, 0xFF);

	memory.writebyte(0x800CC933, 0xFF);
	memory.writebyte(0x800DDABE, 0xFF);
	memory.writebyte(0x800DFA39, 0xFF);
	memory.writebyte(0x801EEE12, 0xFF);
--]]
--[[
	memory.writedword(0x800BC378, 0x00000000);
	memory.writedword(0x800BC3AC, 0x00000000);
	memory.writedword(0x800BC4B0, 0x00000000);

	memory.writedword(0x800C4180, 0x44444444);
--]]	

	-- This magical piece of code turns the lights on (sometimes)

	--quickscreen(0, 1, "%08x", 0x800C4180)
	
	magic		= 0x60606060
--	magic		= magic * 0x00000001
--	magic		= 0x20202020
	for i = 0x00, 0x8F do
		--quickscreen(0 + 40 * math.fmod(i, 4), math.floor(i / 4), "%08x", 0x800C4180 + 4 * i)
		memory.writedword(0x800C4180 + 4 * i, magic);

		--[[
		-- wtf were these for again
		memory.writedword(0x800CC930 + 4 * i, magic);
		memory.writedword(0x800CC980 + 4 * i, magic);
		memory.writedword(0x800DDAB0 + 4 * i, magic);
		memory.writedword(0x801EEE10 + 4 * i, magic);
--]]

	end;
	memory.writedword(0x800C4180, 0x00000000);

	--	memory.writedword(0x801A9150 + 4 * i, 0x10101010);
--	memory.writedword(0x801A9220 + 4 * i, 0x10101010);

	
--	text(240, 100, string.format("0x800BC37A = %02X", memory.readbyte(0x800BC37A)));




	if showcam then
		gui.box(0, 0, 100, 100, 0xffffffff);
		
		menux	= rangediv(camforcel['min']['x'], camforcel['max']['x'], camforce['x'], 100);
		menuy	= rangediv(camforcel['min']['y'], camforcel['max']['y'], camforce['y'], 100);
		
		gui.line(0, menuy, 100, menuy, 0xffffffff);
		gui.line(menux, 0, menux, 100, 0xffffffff);
		
		if hitbox(inkey['xmouse'], inkey['ymouse'], inkey['xmouse'], inkey['ymouse'], 0, 0, 100, 100, "white", "red") then
			gui.text(0, 0, "welp");
		end;
		
		
		--inpt['xmouse'] < 100 and inpt['ymouse'] < 100 then
			
		
	end;





	pcsx.frameadvance();
end;