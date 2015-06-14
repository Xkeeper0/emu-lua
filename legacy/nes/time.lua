tzofs	= 3600 * 0; -- DISTANCE FROM PST. EST = 3
timeto	= 1293416391;

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

require 'ul_time';

ys	= 8;

dots	= {};
--[[
for i = 1, 255 do
	dots[i]	= {
		x	= i,
		xs	= math.random(25) / 100 + .25;
		y	= math.random(198);
		ys	= math.random(300) / 100 + 1;
		c	= math.random(50);
		}
--]]

--[[
for i = 9, 198 do
	dots[i]	= {
		y	= i,
		ys	= 0;
		x	= math.random(256);
		xs	= -1 * (math.random(500) / (1000 + (i + 2) * 50)) - (0.3 - i * 0.001);
		c	= math.random(50);
		}

--]]

for i = 0, 200 do
	dots[i]	= {
		y	= math.random(198),
		ys	= math.random(1000) / 2500 + 0.05,
		x	= math.random(256),
		xs	= math.random(1000) / 2500 + 0.05,
		c	= math.random(200) + 150;
		}
end;



function dodots()
--[[
	for k, v in pairs(dots) do
		v['y']	= math.fmod(198 + v['y'] + v['ys'], 198);
		v['x']	= math.fmod(255 + v['x'] + v['xs'], 255);
		pixel(v['x'], v['y'], "#4444ff");
		pixel(v['x'], v['y'], "#ffffff");
	end;
--]]
	for k, v in pairs(dots) do
		if v['y'] >= 198 then
			v['c']	= v['c'] - 1;
			if v['c'] == 0 then
				v['y']	= -1;
				v['ys']	= math.random(1000) / 2500 + 0.05;
				v['x']	= math.random(256);
				v['xs']	= math.random(1000) / 2500 + 0.05;
				v['c']	= math.random(200) + 150;
			end;
		else
			v['y']	= v['y'] + v['ys'];
			v['x']	= v['x'] + v['xs'];
			if v['x'] < 0 then
				v['x']	= 255;
			elseif v['x'] >= 256 then
				v['x']	= 0;
			end;
		end;


		
--		pixel(v['x'], v['y'], "#4444ff");
		local col	= "white";
		if v['c'] < 150 then
			col		= "#8888ff";
		end;
		if v['c'] < 50 then
			col		= "#4444ff";
		end;
		pixel(v['x'], v['y'], col);
		

	end;


end;


local balls = {}
local ballsptr=1

function doballs()
	count	= 0;
	for k, v in pairs(balls) do
		
		v['x']		= v['x'] + v['xs'];
		v['y']		= v['y'] + v['ys'];
		if(v.id~=1) then
			v['ys']		= v['ys'] * 0.95 + 0.02;
			v['xs']		= v['xs'] * 0.95;
		end
		v['life']	= v['life'] - 1;

--		if v['x'] < 0 or v['x'] > 254 or v['y'] < 0 or v['y'] > 243 then
		if v['x'] < 0 or v['x'] > 254 then
			balls[k]	= nil;
		elseif v['life'] < 0 then
			balls[k] = nil
		else
		
			balls[k]	= v;
			colkey		= math.ceil(255 * (5 - math.max(math.min(5, (v['life'] / 15)), 0)) / 5);
			
			if(v.id==1) then
				color = "white"
			elseif v['c'] <= 10 then
				color	= string.format("#%02XFF00", (v['c']) * 25);

			elseif v['c'] <= 20 then
				color	= string.format("#00%02XFF", (v['c'] - 10) * 15 + 100);

			elseif v['c'] <= 30 then
				color	= string.format("#FF%02X%02X", (v['c'] - 20) * 10 + 150, (v['c'] - 20) * 10 + 150);

			elseif v['c'] <= 40 then
				color	= string.format("#%02X%02X%02X", (v['c'] - 30) * 10 + 150, (v['c'] - 30) * 10 + 150, (v['c'] - 30) * 10 + 150);

			else
				color	= string.format("#%02XFF00", v['c'] * -1);
			end;

			if v['life'] > 10 or v.id==1 then
				box(v['x'], v['y'], v['x'] + 1, v['y'] + 1, color);
			else
				pixel(v['x'], v['y'], color);
			end;
			count		= count + 1;
		end;
	end;

	return count;

end;

function spawnfireworkx(x, y, p, l, a)
	return 0;
end;

function spawnfirework(x, y, p, l, a)
	fw		= fw + 1;
--	x		= math.random(20, 230);
--	y		= math.random(30, 150);
--	p		= p + 0.2;
--	a		= a + 100;
	local px	= x
	local py	= y + 30
	c			= math.random(0, 3) * 10;
	
	local pow	= math.random(0, 5);

	for i = 1,a do
		local temp	= math.random(0, 200000) / 100000 * math.pi * 2;
		local temp2	= math.random(0 + pow * 45, 250) / 100;
		local xs			= math.sin(temp) * temp2 * p;
		local ys			= math.cos(temp) * temp2 * p - 4 * p;

		balls[ballsptr]	= {id=0, x = px, y = py, xs = xs, ys = ys, life = math.random(70, 120) * l, c = c + math.random(0, 9)}
		ballsptr = ballsptr + 1
	end;
end;



ms3	= 999;
ms2	= 999;
ms1	= 999;
s2	= 999;
s1	= 999;
m2	= 999;
m1	= 999;
h2	= 999;
h1	= 999;
zt	= 0;
dts	= 0;
fw	= 0;
last	= 0;
hide	= 0;
mode	= 0;
introdelay	= 180;
barwidth	= 120;
lpadding	= 0;
lastfwork	= 0;

function magic()

	lastfwork	= lastfwork + 1;

	if introdelay > 0 then
		if introdelay < 10 then
			text( 50, 10 - (10 - introdelay), "Press [ or ] to hide/reveal timer.");
			for i = 1, 9 do
				line(50, i, 210, i, "clear");
			end;
		else
			if mode == 1 and introdelay > 10 then 
				introdelay = 10
			end;
			text( 50, 10, "Press [ or ] to hide/reveal timer.");
		end;
		introdelay	= introdelay - 1;
	end;

	t, t2	= time.sec_usec();
	tt		= t + t2 / 1000000 + tzofs;
	tl		= math.floor((timeto - tt) * 10000) / 10000;
--	text(8, 8, tl);

	if tl < 0 then
		mode	= 1;
		tl	= 0;
		zt	= zt + 1;
		if (dts < 1500 and lastfwork > 0) or dts < 750 then 
			spawnfirework(math.random(20, 230), math.random(40, 170), 1.1, 0.8, math.random(200, 400));
			last	= zt;
			lastfwork = math.random(-20, -5);
		end;
	end;

	inkey	= input.get();
	if inkey['leftbracket'] then
		mode	= 1;
	elseif inkey['rightbracket'] then
		mode	= 0;
	end;
	
	if mode == 0 and hide > 0 then
		hide	= hide - 1;
	elseif mode == 1 and hide < 72 then
		hide	= hide + 1;
	end;

	barwidth	= math.max(0, 120 - math.pow(hide, 2) / 25);
	lpadding	= 60 - (barwidth / 120 * 60) + math.min(5, math.max(0, (hide - 55) * 1.25));

	oldms3	= ms3;
	oldms2	= ms2;
	oldms1	= ms1;
	olds2	= s2;
	olds1	= s1;
	oldm2	= m2;
	oldm1	= m1;
	oldh2	= h2;
	oldh1	= h1;

	ms3		= math.fmod(math.floor(tl * 1000), 10);
	ms2		= math.fmod(math.floor(tl * 100), 10) + ms3 / 10;
	ms1		= math.fmod(math.floor(tl * 10), 10) + ms2 / 10;
	s2		= math.fmod(math.floor(tl / 1), 10) + ms1 / 10;
	s1		= math.fmod(math.floor(tl / 10), 6) + s2 / 10;
	m2		= math.fmod(math.floor(tl / 60), 10) + s1 / 6;
	m1		= math.fmod(math.floor(tl / 600), 6) + m2 / 10;
--	h2		= math.fmod(math.floor(tl / 3600), 10) + m1 / 6;
--	h1		= math.floor(tl / 36000) + h2 / 10;
	h2		= math.fmod(math.floor(math.fmod(tl, 86400) / 3600), 10) + m1 / 6;
	h1		= math.floor(math.fmod(tl, 86400) / 36000) + h2 / 10;

	times	= math.floor(math.fmod(tl * 100, 6000)) / 100;
	timem	= math.fmod(math.floor(tl / 60), 60);
	timeh	= math.fmod(math.floor(tl / 3600), 24);
	timed	= math.floor(tl / 86400);


--	line( 86, 166, 162, 166, "blue");
--	line( 86, 174, 162, 174, "blue");

	if hide <= 70 then
	
		cv		= tl;
		vp		= -1;
		for i = 1, 8 do
			p	= math.pow(10, (i - 3))
			v	= cv / p;
			v	= v - math.floor(v / 10) * 10;
			for ii = -2, 1 do
				if i > 2 then
					ip	= 2
				else
					ip	= 0;
				end;
				
				if i <= 2 then --and v < 10 then
					vp	= 172 - (math.fmod(v * 100, 100) / 100 * 8) + 8;
				elseif i == 3 and math.fmod(v * 10, 10) <= 1 then
					vp	= 172 - (math.fmod(v * 100, 10) / 10 * 8) + 8;
				elseif math.fmod(v * 10, 10) >= 1 then
					vp	= 172 - (math.fmod(0, 100) / 100 * 8);
				end;

				text(160 - 8 * i - ip, vp + ii * 8 - 7, string.format("%d", math.fmod(v + ii + 10, 10)));
			end;
		end;

		for i = 8, 20 do
			line( 80, 170 - i, 160, 170 - i, "clear");
			line( 80, 170 + i, 160, 170 + i, "clear");
		end;
		
		text(162, 164, "sec");

		if hide >= 63 then
			box(92, 162 + (hide - 62), 162, 178 - (hide - 62), "#4444ff");
			for i = 0, (hide - 63) do
				line(92, 162 + i, 182, 162 + i, "clear");
				line(92, 178 - i, 182, 178 - i, "clear");
			end;
		else
			box(92, 162, 162, 178, "#4444ff");
		end;

		
		if (tl > 86400) then
			d1	= math.floor(tl / 86400 / 10);
			d2	= math.floor(tl / 86400);
			text(    60 + lpadding,  3 * ys, string.format("%d", d1));
			text(    60 + lpadding,  4 * ys, string.format("%d", d2));
			lifebar( 70 + lpadding,  3 * ys + 2, barwidth, 12, (tl - 86400) / 86400, 14, "#ffffff", "#000066", "#4444ff", "black");
		end;

		text(    60 + lpadding,  6 * ys, string.format("%d", h1));
		text(    60 + lpadding,  7 * ys, string.format("%d", h2));
		lifebar( 70 + lpadding,  6 * ys + 2, barwidth, 12, h1 * 10, 24, "#ffffff", "#000066", "#4444ff", "black");


		text(    60 + lpadding,  9 * ys, string.format("%d", m1));
		lifebar( 70 + lpadding,  9 * ys + 2, barwidth, 2, m1, 6, "#cccccc", "#000066", "#4444ff", "black");
		text(    60 + lpadding, 10 * ys, string.format("%d", m2));
		lifebar( 70 + lpadding, 10 * ys + 2, barwidth, 2, m2, 10, "#cccccc", "#000066", "#4444ff", "black");

		text(    60 + lpadding, 12 * ys, string.format("%d", s1));
		lifebar( 70 + lpadding, 12 * ys + 2, barwidth, 2, s1, 6, "#8888ff", "#000066", "#4444ff", "black");
		text(    60 + lpadding, 13 * ys, string.format("%d", s2));
		lifebar( 70 + lpadding, 13 * ys + 2, barwidth, 2, s2, 10, "#8888ff", "#000066", "#4444ff", "black");

		text(    60 + lpadding, 15 * ys, string.format("%d", ms1));
		lifebar( 70 + lpadding, 15 * ys + 2, barwidth, 2, ms1, 10, "#4444ff", "#000066", "#4444ff", "black");
		text(    60 + lpadding, 16 * ys, string.format("%d", ms2));
		lifebar( 70 + lpadding, 16 * ys + 2, barwidth, 2, ms2, 10, "#4444ff", "#000066", "#4444ff", "black");
		text(    60 + lpadding, 17 * ys, string.format("%d", ms3));
		lifebar( 70 + lpadding, 17 * ys + 2, barwidth, 2, ms3, 10, "#4444ff", "#000066", "#4444ff", "black");
	--]]

		
		if hide >= 55 and hide <= 70 then
			for i = 0, math.min((hide - 55) * 2, 14) do
--				line( 115 + i, 3 * ys, 115 + i, 18 * ys + 4, "red");
				line( 139 - i, 3 * ys, 139 - i, 18 * ys + 4, "clear");
			end;
		elseif hide >= 70 then
			hide	= 69;
		end;
	
	end;
	
	if hide > 60 then
		timet	= string.format("%2dd %02d:%02d:%04.1f ", timed, timeh, timem, times);
		if tl == 0 then
			timet	= string.format(" %4d particles ", dts);
		end;
		if hide < 71 then
			text( 88, 217 - (70 - hide), timet)
			for i = 0, 10 - (hide - 60) do
				line(88, 217 - i, 170, 217 - i, "clear");
			end;
		else
			text( 88, 218, timet);
			if tl == 0 then
				line( 90, 229, 169, 229, "blue");
				line( 90 + 66, 229, 169, 229, "#4444ff");

				local bs	= (dts / 1800 * 79);

				line( 90, 229, 90 + bs, 229, "#8888ff");
				if (bs > 66) then
					line( 90 + 66, 229, 90 + bs, 229, "white");
				end;
			end;
		end;
	end;
	
	
	
	groundcol	= "#000088";
	
	line(0, 198, 255, 198, groundcol);
	line(0, 199, 255, 199, groundcol);
	line(0, 201, 255, 201, groundcol);
	line(0, 203, 255, 203, groundcol);
	line(0, 206, 255, 206, groundcol);
	line(0, 210, 255, 210, groundcol);
	line(0, 216, 255, 216, groundcol);


	dodots();
	dts	= doballs();

--	text(187, 188 - math.max(3 - (zt - last) * 2, 0), string.format("%5d hanabi!", fw));
--	text(199, 7, string.format("%5d dots", dts));

--[[
	if h2 > oldh2 then		spawnfirework(64,  5 * ys + 4, 1.5, 1.5, 500);	end;
	if m1 > oldm1 then		spawnfirework(64,  6 * ys + 4, 1.5, 1.5, 400);	end;
	if m2 > oldm2 then		spawnfirework(64,  8 * ys + 4, 1.2, 1.2, 300);	end;
	if s1 > olds1 then		spawnfirework(64,  9 * ys + 4, 1.0, 1.1, 200);	end;
	if s2 > olds2 then		spawnfirework(64, 11 * ys + 4,  .8, 1.0, 100);	end;
	if ms1 > oldms1 then	spawnfirework(64, 12 * ys + 4,  .5, 0.8,  50);	end;
	if ms2 > oldms2 then	spawnfirework(64, 14 * ys + 4,  .3,  .3, 10);	end;
--]]
	
end;

gui.register(magic);

while true do
	FCEU.frameadvance();
end;
