require "x_functions";



enablemove	= 0
enablelight	= 0


print(" -- Hotkeys -- ");
print("P: Show coordinates")
print("O: Reset Z coordinate to 0 (maybe?)")
print("I: Hold to force camera position")
print("U: Enable force-movement with arrow keys")
print("Y: Enable force-lighting (flickery)")


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
	print(string.format(fmt, crud))

end;
function quickscreen2(x, y, fmt, addr, isnotaddr)

	local crud	= addr;
	if not isnotaddr then
		-- double negatives
		crud	= memory.readwordsigned(addr);
	end;
		
	gui.text(x, y * 8, string.format(fmt, crud));
	print(string.format(fmt, crud));

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


	
	if inkey['P'] and not lastkey['P'] then
		quickscreen(200,  1, "X %8d", 0x800BA024);
		quickscreen(200,  2, "Y %8d", 0x800BA02C);
		quickscreen(200,  3, "Z %8d", 0x800BA028);
		quickscreen(200,  4, "A %8.2f", memory.readdwordsigned(0x800BA030) / 0x0FFFFFFF * 360, true);
	end;
	
	
	--[[
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
	--]]
	
--[[
	quickscreen(130,  1, "Z1 %8d", 0x800B9DE8);
	quickscreen(130,  2, "Z2 %8d", 0x800B9DF0);
	quickscreen(130,  3, "Z3 %8d", 0x800BA028);
	quickscreen(130,  4, "Z4 %8d", 0x800BA0F8);
	quickscreen(130,  5, "Z5 %8d", 0x800C459C);
--]]

	if inkey['O'] then
		memory.writedword(0x800B9DE8, 0);
		memory.writedword(0x800B9DF0, 0);
		memory.writedword(0x800BA028, 0);
		memory.writedword(0x800BA0F8, 0);
		memory.writedword(0x800C459C, 0);
	end;


	if inkey['I'] then
		forcecam();
	else
		fcam	= false;
	end;


	mspeed	= math.min(500, mspeed);

	if inkey['U'] and not lastkey['U'] then
		enablemove	= 1 - enablemove
		print("Direct movement is now ".. enablemove)
	end

	if enablemove == 1 then
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
	end

	temp1		= memory.readword(0x8006A5B8);
	temp2		= memory.readword(0x8006A5BA);
	temp3		= memory.readword(0x8006A594);
	temp4		= memory.readword(0x8006A596);


--	pos1	= memory.readdwordsigned(0x800B9DE4);
--	lifebar(  50,   1, 200, 8, pos1 + 0x80000, 770000, "#ffffff", "#000000");
--	text(    120,   4, string.format("%11d", pos1));
--	pos2	= memory.readdwordsigned(0x800B9DEC);
--	lifebar(  50,  12, 200, 8, pos2 + 0x80000, 0xFFFFF, "#ffffff", "#000000");
--	text(    120,  15, string.format("%11d", pos2));

--	temp1		= memory.readdword(0x800B9D14);
--	text(   1,  30, string.format("%08X", temp1));


	-- This magical piece of code turns the lights on (sometimes)

	--quickscreen(0, 1, "%08x", 0x800C4180)
	if inkey['Y'] and not lastkey['Y'] then
		enablelight	= enablelight - 1
		print("Forcing light is now ".. enablelight)
	end

	if enablelight == 1 then

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
	end

	--	memory.writedword(0x801A9150 + 4 * i, 0x10101010);
--	memory.writedword(0x801A9220 + 4 * i, 0x10101010);

--	text(240, 100, string.format("0x800BC37A = %02X", memory.readbyte(0x800BC37A)));








	pcsx.frameadvance();
end;