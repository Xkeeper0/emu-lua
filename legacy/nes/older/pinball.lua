
require("x_functions");
x_requires(2);


-- Configuration --
alden			= false;		-- Alden mode. Basically, plays Alden's bot.

function readnumber(offset, length)
	val		= 0;

	for i = 1, length do
		inp	= memory.readbyte(offset + (i - 1));
		if (inp ~= 0x26) then val = val + inp * (10 ^ (length - i)); end;
	end;

	return val;
end;


function ballpath(ball, rate, length)
	ballx			= {};
	ballx[0]		= {};
	ballx[0]['x']	= ball['x'];
	ballx[0]['y']	= ball['y'];
	ratey			= rate['y'];
	
	for i = 1, length do
		ballx[i]		= {};
		ballx[i]['x']	= ballx[i-1]['x'] + rate['x'];
		ballx[i]['y']	= ballx[i-1]['y'] + ratey;
	
		line(ballx[i-1]['x'], ballx[i-1]['y'], ballx[i]['x'], ballx[i]['y'], "#ff0000");
		ratey			= ratey + 0.415;
--		text(200, 7 * i, string.format("%2.4f", rate2['y']));

	end;

	return ballx[length];

end;



-- checks if point is within area
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

--[[
	if	(b1x >= b2x1) and
		(b1y >= b2y1) and
		(b1x <= b2x2) and
		(b1y <= b2y2) then


		box(b2x1, b2y1, b2x2, b2y2, "#ffffff");
		return true;
	else
		box(b2x1, b2y1, b2x2, b2y2, "#888888");
		return false;
	end;
	]]

	return true;

end;



function gameloop()

	--check if it needs to be launched 
	if ball['x']==225 and ball['y']==154 and memory.readbyte(0x125)~=4 then 
		joypad.set(1,{B=true}) 
	end 

	if board == 1 then
		hitboxx1		= 117;
		hitboxx2		= 144;
		hitboxy			= 195;
		hitboxw			=  26;
		hitboxh			=  15;
	else	-- i.e., board2.
		hitboxx1		= 115;
		hitboxx2		= 144;
		hitboxy			= 195;
		hitboxw			=  28;
		hitboxh			=  20;
	end;

	--check left flipper 
	if hitbox(ball['x'] - 3, ball['y'] - 3, ball['x'] + 3, ball['y'] + 3, hitboxx1, hitboxy, hitboxx1 + hitboxw, hitboxy + hitboxh) then
		joypad.set(1,{up=true}) 
	end 

	--check right flipper 
	if hitbox(ball['x'] - 3, ball['y'] - 3, ball['x'] + 3, ball['y'] + 3, hitboxx2, hitboxy, hitboxx2 + hitboxw, hitboxy + hitboxh) then
		joypad.set(1,{A=true}) 
	end 

	for i = 1, 3 do
		ballm			= ballpath(ball, movement, i);										-- try to guess movement of the ball
		box(ballm['x'] - 3, ballm['y'] - 3, ballm['x'] + 3, ballm['y'] + 3, "#ffffff");

		--check left flipper 
		if hitbox(ballm['x'] - 3, ballm['y'] - 3, ballm['x'] + 3, ballm['y'] + 3, hitboxx1, hitboxy, hitboxx1 + hitboxw, hitboxy + hitboxh) then
			joypad.set(1,{up=true}) 
		end 

		--check right flipper 
		if hitbox(ballm['x'] - 3, ballm['y'] - 3, ballm['x'] + 3, ballm['y'] + 3, hitboxx2, hitboxy, hitboxx2 + hitboxw, hitboxy + hitboxh) then
			joypad.set(1,{A=true}) 
		end 
	
	end;

end;



function aldenloop()


	--check if it needs to be launched 
	if memory.readbyte(0x7)==225 and memory.readbyte(0x9)==154 and memory.readbyte(0x125)~=4 then 
		joypad.set(1,{B=true}) 
	end 

	

	--check right flipper 
--	if memory.readbyte(0x7) > 145 and memory.readbyte(0x7) < 175 and memory.readbyte(0x9) > 189 and memory.readbyte(0x9) < 226 then 
	if hitbox(ball['x'], ball['y'], ball['x'], ball['y'], 146, 189, 174, 226) then 
		 joypad.set(1,{A=true}) 
	end 

	--check left flipper 
--	if memory.readbyte(0x7) > 110 and memory.readbyte(0x7) < 138 and memory.readbyte(0x9) > 189 and memory.readbyte(0x9) < 226 then 
	if hitbox(ball['x'], ball['y'], ball['x'], ball['y'], 111, 189, 137, 226) then 
		 joypad.set(1,{up=true}) 
	end 

end;



function bonustable()

	mario		= memory.readbyte(0x00EC) + 116;
	box(mario, 184, mario + 23, 186, "#ffffff");

	pancakex	= memory.readbyte(0x00ED) +  72;
	pancakey	= memory.readbyte(0x011C) +  35;
	box(pancakex, pancakey, pancakex + 16, pancakey + 24, "#ff9999");

	if ball['x'] <= mario + 11 then
		joypad.set(1,{left=true});
	elseif ball['x'] > mario + 12 then
		joypad.set(1,{right=true});
	end;

end;


-- 0x7 is x of ball, 0x9 is y, 0x125 is amount launcher is pulled back 
ball			= {x = 0, y = 0};
movement		= {};
ballm			= {};
scores			= {};
game			= 1;
board			= 0;
gameover		= false;
ingame			= false;
lives			= 0;
timer			= 0;
gameovertimer	= 0;

while (true) do 

	ball['x']		= memory.readbyte(0x0016);
	ball['y']		= memory.readbyte(0x0018);
	movement['x']	= memory.readbytesigned(0x0019) /  6;
	movement['y']	= memory.readbytesigned(0x001a) /  8;
	ballm['x']		= ball['x'] + (movement['x']) * 1;
	ballm['y']		= ball['y'] + (movement['y']) * 1;
	lives			= memory.readbyte(0x0151);
--	ballpath(ball, movement, 60);

	filledbox(ball['x'] - 3, ball['y'] - 3, ball['x'] + 3, ball['y'] + 3, "#ffffff");
	line(ballm['x'], ballm['y'], ball['x'], ball['y'], "#00ff00");

	-- function graph(x, y, sx, sy, minx, miny, maxx, maxy, xval, yval, color, border, filled)
	graph(1, 108, 64, 64, -0x80, -0x80, 0x7F, 0x7F, 0, 0, "#888888", "#888888");
	graph(1, 108, 64, 64, -0x80, -0x80, 0x7F, 0x7F, memory.readbytesigned(0x0019), memory.readbytesigned(0x001a), "#ffffff");

--	graph(ball['x'] - 32, ball['y'] - 32, 64, 64, -0x80, -0x80, 0x7F, 0x7F, 0, 0, "#888888", "#888888");
--	graph(ball['x'] - 32, ball['y'] - 32, 64, 64, -0x80, -0x80, 0x7F, 0x7F, memory.readbytesigned(0x0019) / 2, memory.readbytesigned(0x001a) / 4, "#ffffff");

	temp		= memory.readbyte(0x07BA);
	if		temp == 0xED then	board	=  3;
	elseif	temp == 0x31 then	board	=  2;
	elseif	temp == 0x78 then	board	=  1;
	else						board	=  0;
	end;

	score		= readnumber(0x100, 5);
	maxpoints	= 0;
	for i = 1, game - 1 do
		text( 0,  8 + 7 * i, string.format("Game %02d:%05d", i, scores[i]));
		maxpoints	= maxpoints + scores[i];
	end;
	if game > 1 then
		maxpoints	= math.floor(maxpoints / (game - 1));
		text( 1,  8 + 7 * game, string.format("Average:%05d", maxpoints));
	end;

	if gameover == true then
		text( 0,  8 + 7 * (game + 3), "Game over");
	end;
	if ingame == true then
		spinnerpos	= math.floor(math.fmod(timer / 4, 4));
		text( 0,  8 + 7 * (game + 2), string.format("Score:   %05d %s", score, string.sub("/-\\|", spinnerpos + 1, spinnerpos + 1)));
	else
		text( 0,  8 + 7 * (game + 2), string.format("Score:   %05d", score));

	end;

	if alden == true and math.fmod(timer, 60) < 30 then
		text( 200,  8, "Alden mode");
	end;

	if ball['y'] >= 0xF0 and board == 1 and lives == 0 and gameover == false and gameovertimer >= 10 then
		scores[game]	= score;
		game			= game + 1;
		gameover		= true;
		ingame			= false;
--		FCEU.pause();
	
	elseif ball['y'] >= 0xF0 and board == 1 and lives == 0 and gameover == false and gameovertimer < 10 then
		gameovertimer	= gameovertimer + 1;

	
	elseif memory.readbyte(0x003) == 0x01 and ingame == false then
		text(50, 60, string.format("At title screen"));
		joypad.set(1,{start=true});


	elseif ingame == true and board == 3 then
		gameovertimer	= 0;
		if alden ~= true then 
			bonustable();
		end;

	elseif gameover ~= true and ingame == true then
		gameovertimer	= 0;
		if alden ~= true then 
			gameloop()
		else 
			aldenloop();
		end;

	
	elseif memory.readbyte(0x003) == 0x01 and ingame == false then
		text(50, 60, string.format("At title screen"));


	elseif memory.readbyte(0x151) >= 0x01 and ingame == false then
		ingame			= true;
		gameover		= false;

	else
--		text(50, 60, "?");

	end;


	timer	= timer + 1;


	FCEU.frameadvance();

end