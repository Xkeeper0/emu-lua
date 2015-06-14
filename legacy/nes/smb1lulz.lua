
require("x_functions");
x_requires(4);


function hitbox(b1x1, b1y1, b1x2, b1y2, b2x1, b2y1, b2x2, b2y2)

	boxes	= {
		{
			x	= {b1x1, b1x2},
			y	= {b1y1, b1y2},
			},
		{
			x	= {b2x1, b2x2},
			y	= {b2y1, b2y2},
			},
	};

	hit	= false;

	for xc = 1, 2 do
		for yc = 1, 2 do

			if	(boxes[1]['x'][xc] >= boxes[2]['x'][1]) and
				(boxes[1]['y'][yc] >= boxes[2]['y'][1]) and
				(boxes[1]['x'][xc] <= boxes[2]['x'][2]) and
				(boxes[1]['y'][yc] <= boxes[2]['y'][2]) then

				hit	= true;
			end;
		end;
	end;

	if hit == true then
		box(b2x1, b2y1, b2x2, b2y2, "#ffffff");
		return true;
	else
		box(b2x1, b2y1, b2x2, b2y2, "#dd0000");
		return false;
	end;

	return true;

end;


function doballs()

	count	= 0;
	for k, v in pairs(balls) do
		
		v['x']		= v['x'] + v['xs'];
		v['y']		= v['y'] + v['ys'];
		v['ys']		= v['ys'] + 0.1;
		v['life']	= v['life'] - 1;

		if v['x'] < 0 or v['x'] > 254 or v['y'] < 0 or v['y'] > 243 or v['life'] < 0 then
			balls[k]	= nil;
		else
			balls[k]	= v;
--			pixel(v['x'], v['y'], "#FFFFFF");
			colkey		= math.ceil(255 * (5 - math.max(math.min(5, (v['life'] / 15)), 0)) / 5);

			if v['c'] >= 0 then
				color	= string.format("#%02X%02X%02X", v['c'], v['c'], v['c']);
			else
				color	= string.format("#%02X0000", v['c'] * -1 , 0, 0);
			end;

			if v['life'] > 45 then 
				box(v['x'], v['y'], v['x'] + 1, v['y'] + 1, color);
			else
				pixel(v['x'], v['y'], color);
			end;
			count		= count + 1;
		end;
	end;

--	lifebar( 2, 140, 249, 10, spower, 400, "#ffffff", "#000044", "#bbbbff");
	return count;

end;








	
-- gui.register(gameloop);
balls		= {};
missile		= {target = 0};
z			= 0;
timer		= 0;
mlife		= 240;
msgdisp		= 300;
lastscreenpos	= 0;
while (true) do 
	timer	= timer + 1;

	if timer < msgdisp then
		yo	= (((math.max(0, (timer + 60) - msgdisp))) ^ 2) / 50;
		text(43, 64 - yo, "Press up to cast MAGIC MISSILE!");
	end;

	mlife	= math.min(240, mlife + 5);
	lifebar(5, 8, 240, 2, mlife, 240, "#8888ff", "#000000");
	
	
--[[
	bxp		= math.sin(timer / 120) * 64 + 127;
	byp		= math.cos(timer / 120) * 64 + 127;
	for i = 0, 0 do
		balls[z]	= {x = bxp + math.random(-100, 200) / 100, y = byp + math.random(-4, 4), xs = math.random(-100, 100) / 50, ys = math.random(-100, 100) / 100, life = math.random(60, 120), c = math.random(128, 255)};
		z			= z + 1;
	end;
]]

	
	doballs();

	local foreal = 0x04AC;  
    local blitted = 0x000E;  
	target	= -1;
    for i=1,6 do  
        if (memory.readbyte(blitted+i) ~= 0 and memory.readbyte(foreal+(i*4)) ~= 0xFF) and (memory.readbyte(0x0015 + i) ~= 0x30 and memory.readbyte(0x0015 + i) ~= 0x31) then  
            local x1 = memory.readbyte(foreal+(i*4));
            local y1 = memory.readbyte(foreal+(i*4)+1);
            local x2 = memory.readbyte(foreal+(i*4)+2);
            local y2 = memory.readbyte(foreal+(i*4)+3);
--            text(8,8+(i*8), string.format("%d - %3d,%3d  %3d,%3d", i, x1, y1, x2, y2));
--            box(x1,y1,x2,y2,"green");  
--			text(8, 16 + (i * 8), string.format("%d: %02X", i, memory.readbyte(0x0015+i)));

			target	= i;
			break;
		end;  
    end;  
	
	screenpos	= memory.readbyte(0x071C);
	if screenpos < lastscreenpos then
		movement	= lastscreenpos - 256 + screenpos;
	else
		movement	= screenpos - lastscreenpos;
	end;
	lastscreenpos	= screenpos;

	joyput	= joypad.read(1);
	if missile['target'] == 0 and joyput['up'] and mlife >= 0 then
		
		missile['x']		= memory.readbyte(0x4AC);
		missile['y']		= memory.readbyte(0x4AD);
		missile['ys']		= -5;
		missile['xs']		= 0;
		missile['target']	= target;
		missile['life']		= 240;
		mlife				= 0;
		missile['fired']	= timer;
	end;

	if missile['target'] ~= 0 then

		if memory.readbyte(0x000E + missile['target']) == 0xFF then
			missile['target']	= target;
		end;
		
		ex				= memory.readbyte(0x04AC + (missile['target'] * 4));
		ey				= memory.readbyte(0x04AC + (missile['target'] * 4) + 1);
		ex2				= memory.readbyte(0x04AC + (missile['target'] * 4) + 2);
		ey2				= memory.readbyte(0x04AC + (missile['target'] * 4) + 3);
		if missile['target'] > 0 then
			missile['xs']	= (missile['xs'] * .75) - (missile['x'] - (ex + ex2) * .5) / 25;
			missile['ys']	= (missile['ys'] * .75) - (missile['y'] - (ey + ey2) * .5) / 25;
		else
			missile['life']		= missile['life'];
			missile['ys']	= missile['ys'] * 0.95;
			missile['xs']	= missile['xs'] * 0.95;
		end;

		missile['life']		= missile['life'] - 1;
		missile['x']		= missile['x'] + missile['xs'] - movement;
		missile['y']		= missile['y'] + missile['ys'];

		lifebar(5, 14, 240, 2, missile['life'], 240, "#ff0000", "#000000");

		filledbox(missile['x'] - 2, missile['y'] - 2, missile['x'] + 2, missile['y'] + 2, "#dd0000");

		if missile['life'] <= 0 then
			missile['target']	= 0;
		else

			lasttarget	= -1;
			for i=1,6 do  
				if (memory.readbyte(0x000E+i) ~= 0 and memory.readbyte(0x04AC+(i*4)) ~= 0xFF) and (memory.readbyte(0x0015 + i) ~= 0x30 and memory.readbyte(0x0015 + i) ~= 0x31) then  
					e2x1 = memory.readbyte(0x04AC+(i*4));
					e2y1 = memory.readbyte(0x04AC+(i*4)+1);
					e2x2 = memory.readbyte(0x04AC+(i*4)+2);
					e2y2 = memory.readbyte(0x04AC+(i*4)+3);
					if hitbox(missile['x'] - 1, missile['y'] - 1, missile['x'] + 1, missile['y'] + 1, e2x1, e2y1, e2x2, e2y2) then
						memory.writebyte(0x04AC + i, 0xFF);
						memory.writebyte(0x000E + i, 0x00);
						missile['target']	= lasttarget;
						missile['fired']	= timer;
						missile['life']		= 240;
						missile['target']	= 0;
						for i = 0, 100 do
							balls[z]	= {x = missile['x'], y = missile['y'], xs = (missile['xs'] + math.random(-200, 100) / 100), ys =  (missile['ys'] + math.random(-200, 100) / 100), life = math.random(60, 120), c = -1 * math.random(128, 255)};
							z			= z + 1;
						end;
--						missile['target']	= 0;
--						missile['life']		= 0;
					else
						lasttarget = i;
					end;  

				end;  
				if missile['target'] == -1 then missile['target'] = lasttarget; end;
			end;  
			
			
			for i = 0, 5 do
				balls[z]	= {x = missile['x'], y = missile['y'], xs = -1 * (missile['xs'] + math.random(-100, 100) / 100), ys =  -1 * (missile['ys'] + math.random(-100, 100) / 100), life = math.random(30, 60), c = math.random(128, 255)};
				z			= z + 1;
			end;

			mtime	= timer - missile['fired'];
			boxsize	= math.max(5, (20 - mtime) * 2 + 5);
			if missile['target'] ~= -1 and math.fmod(timer, 3) <= 1 then
--			if mtime < 60 and missile['target'] ~= -1 and math.fmod(timer, 4) <= 1 then
				exc		= (ex + ex2) * .5;
				eyc		= (ey + ey2) * .5;
				box(exc - boxsize, eyc - boxsize, exc + boxsize, eyc + boxsize, "#FFFFFF");
			end;
		end;

	end;

	
	FCEU.frameadvance();
end;

