
-- Auto-hit notes?
--autoplay	= false;

require("x_functions");
x_requires(4);

function pointer(addr)

	point	= memory.readbyte(addr) + memory.readbyte(addr + 1) * 0x0100;
	return point;

end;




channels	= {};
channels[0]	= {};
channels[1]	= {};
channels[2]	= {};
channels[3]	= {};
oldval		= {};

oldval		= {};
power		= {};

balls		= {};

--[[
oldval[0]	= {};
oldval[1]	= {};
oldval[2]	= {};
oldval[3]	= {};
]]

z			= 1;

count		= 0;
runningbeat	= 0;
last		= {};
timer		= 0;
hit			= 0;
lastbeat	= 0;
timing		= 0;
texttimer	= 0;
combo		= 0;
maxcombo	= 0;

if autoplay == true then
	perfectbang	= 250;
else
	perfectbang	= 250;
end;

while (true) do

	timer		= timer + 1;
	yspacing	= 10;

	spower		= 0;
	for i = 0, 3 do
	
		val	= memory.readbyte(0x0750 + i);
		color			= "";
		if val ~= 0 then
			oldval[i]	= val;
			color		= "#ffffff";
			power[i]	= 127;
			balls[z]	= {x = math.random(1, 254), y = 240, xs = math.random(-100, 100) / 50, ys = math.random(-700, -500) / 100, c=i};
			z			= z + 1;

			if i >= 1 and i <= 2 then beatframe = true; end;

			if 
				i >= 1 and 
				i <= 2 and 
				runningbeat == 0
				then lastbeat = timer;
			end;


			if i == 1 and lastbeat == timer and count < 1400 and autoplay == true then
				hit				= timer;
				counted			= false;
				fixed			= true;
				timing			= 0;
			end;

		elseif oldval[i] == nil then
			oldval[i]	= val;
			color		= "#9999ff";
			power[i]	= 0;

		else
			val			= oldval[i];
			color		= "#9999ff";
			power[i]	= math.floor(math.max(0, (power[i] - (128 - power[i]) * 0.25)));
			color		= string.format("#%02X%02X%02X", power[i], power[i], power[i]);

		end;
		lifebar( 2, 8 + yspacing * i, 249, 6, val, 0x3F, color, "#000000", "#000044", "#bbbbff");
		spower			= spower + power[i];

	end;

	inp	= joypad.read(1);
	if inp['A'] and last['A'] == nil then
--		for i = 0, 30 do
--			balls[z]	= {x = math.random(1, 254), y = 240, xs = math.random(-100, 100) / 50, ys = math.random(-700, -500) / 100, c=math.random(0,3)};
--			z			= z + 1;
--		end;
		hit				= timer;
		counted			= false;
		fixed			= false;
		timing			= -100;
	end;

	if (lastbeat - hit) < 18 and (lastbeat - hit) > -18 and timing == -100 then
		timing	= (lastbeat - hit);
		fixed	= false;
	else
		fixed	= true;
	end;

	if counted == false and fixed then
		counted		= true;
		texttimer	= 30;

		timing		= math.abs(timing);
		bc			= 0;
		if timing >= 17 then
			combo		= 0;
		elseif timing >= 12 then
			combo		= 0;
			bc			= 2;
		elseif timing >= 6 then
			combo		= combo + 1;
			bc			= 25;
		elseif timing >= 0 then
			combo		= combo + 1;
			if autoplay == true then
				bc		= perfectbang;
			else
				bc		= perfectbang + combo * 1.5;
			end;

		end;

		bxp			= math.random(40, 210);
		byp			= math.random(40, 210);
		for i = 0, bc do
			balls[z]	= {x = bxp + math.random(-4, 4), y = byp + math.random(-4, 4), xs = math.random(-100, 100) / 50, ys = math.random(-400, 100) / 100, c=4};
			z			= z + 1;
		end;

	end;
	texttimer	= texttimer - 1;

	if counted == true and texttimer > 0 then
		
		textxpos	= 100;
		textypos	= 100 - math.sin(texttimer / 10) * 20;
--		textypos	= 110;

		timing		= math.abs(timing);
		if timing >= 17 then
			text(textxpos - 1, textypos, "   Miss   ");
		elseif timing >= 12 then
			text(textxpos - 5, textypos, "   Close   ");
		elseif timing >= 6 then
			text(textxpos - 5, textypos, "   Great   ");
		elseif timing >= 0 then
			text(textxpos - 5, textypos, "  Perfect!  ");
		elseif timing < 0 then
			text(textxpos - 5, textypos, "  ????????  ");
		end;

	end;

	if combo > 2 then text(textxpos, 120, string.format("Combo%4d", combo)); end;

	last	= inp;

	color			= "";
	count			= 0;

	for k, v in pairs(balls) do
		
		v['x']	= v['x'] + v['xs'];
		v['y']	= v['y'] + v['ys'];
		v['ys']	= v['ys'] + 0.1;

		if v['x'] < 0 or v['x'] > 254 then
			v['xs']	= v['xs'] * -1;
			v['x']	= v['x'] + v['xs'] * 2;
		end;
		if v['x'] < 0 or v['x'] > 254 or v['y'] < 0 or v['y'] > 243 then
			balls[k]	= nil;
		else
			balls[k]	= v;
--			pixel(v['x'], v['y'], "#FFFFFF");
			colkey		= math.max(math.min(math.floor(5 - v['ys']) * 25, 255), 0);

			if     (v['c'] == 0) then color		= string.format("#%02X%02X%02X", colkey * 0.5, colkey * 0.1, colkey * 0.5);
			elseif (v['c'] == 1) then color		= string.format("#%02X%02X%02X", colkey * 1.0, colkey * 0.5, colkey * 0.5);
			elseif (v['c'] == 2) then color		= string.format("#%02X%02X%02X", colkey * 0.5, colkey * 0.5, colkey * 1.0);
			elseif (v['c'] == 3) then color		= string.format("#%02X%02X%02X", colkey * 0.5, colkey * 0.5, colkey * 0.5);
			elseif (v['c'] == 4) then color		= string.format("#%02X%02X%02X", colkey * 1.0, colkey * 1.0, colkey * 1.0);
			end;
			
			box(v['x'], v['y'], v['x'] + 1, v['y'] + 1, color);
			count		= count + 1;
		end;
	end;

--	lifebar( 2, 140, 249, 10, spower, 400, "#ffffff", "#000044", "#bbbbff");
	text(1, 220, string.format("%5d", count));

	maxcombo	= math.max(combo, maxcombo);
	text(200, 220, string.format("Best:%4d", maxcombo));
	lifebar( 1, 230, 200, 2, count, 2000, "#ffffff", "#000044");


--[[
	if memory.readbyte(0x0605) ~= 0x00 then
		lifebar( 80, 20 + 32 * 0, 160, 4, 0xFF - memory.readbyte(0x0605), 0xFF, "#ffffff", "#000044");
		lifebar( 80, 28 + 32 * 0, 160, 2,        memory.readbyte(0x0609), 0x20, "#ffffff", "#000044");
	end;

	if memory.readbyte(0x0625) ~= 0x00 then
		lifebar( 80, 20 + 32 * 1, 160, 4, 0xFF - memory.readbyte(0x0625), 0xFF, "#ffffff", "#000044");
		lifebar( 80, 28 + 32 * 1, 160, 2,        memory.readbyte(0x0629), 0x20, "#ffffff", "#000044");
	end;

	if memory.readbyte(0x0645) ~= 0x00 then
		lifebar( 80, 20 + 32 * 2, 160, 4, 0xFF - memory.readbyte(0x0645), 0xFF, "#ffffff", "#000044");
	end;
]]--





	if beatframe and runningbeat < 6 then runningbeat = runningbeat + 1;
	else runningbeat = 0;
	end;

	beatframe	= false;

	FCEU.frameadvance();

end;