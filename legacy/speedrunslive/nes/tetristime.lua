function shiftleft(inpt)

	return math.floor(inpt / 16);


end;


function getbcd(v)

	local v2	= shiftleft(v)
	local v1	= v - (v2 * 16);
	
	return (v2 * 10 + v1);
	
end;



function getlines()

	return (getbcd(memory.readbyte(0x0051)) * 100 + getbcd(memory.readbyte(0x0050)));
	--[[
	local lines_l		= memory.readbyte(0x0050);
	local lines_h		= memory.readbyte(0x0051);

	local lines_d2	= shiftleft(lines_l)
	local lines_d1	= lines_l - (lines_d2 * 16);
	local lines_d4	= shiftleft(lines_h)
	local lines_d3	= lines_h - (lines_d4 * 16);

	local ret = lines_d4 * 1000 + lines_d3 * 100 + lines_d2 * 10 + lines_d1;
	
	return ret

	--]]

end


function getscore()
	
	local score1	= getbcd(memory.readbyte(0x0053));
	local score2	= getbcd(memory.readbyte(0x0054));
	local score3	= getbcd(memory.readbyte(0x0055));

	return score3 * 10000 + score2 * 100 + score1;
	
end





gframes		= 0;
gstarted	= false;

goal		= "score";
goalamt		= 200000;

scoredisp		= 0;
score			= 0;
lines			= 0;
scoreold		= 0;
scoredisptimer	= 0;
finished		= false;
globaltimer		= 0;
while true do
	globaltimer	= globaltimer + 1;

	if not gstarted and memory.readbyte(0x00b7) ~= 0 then
		gstarted = true;
	end;

	lines		= getlines();
	scoreold	= score;
	score		= getscore() + 0;

	
	if gstarted and not finished then
		gframes = gframes + 1;
	end;

	if (goal == "score" and score >= goalamt) or (goal == "lines" and lines >= goalamt) then
		finished	= true;
	end;
	
	

	msec	= math.fmod(gframes, 60) / 60 * 100;
	sec		= math.fmod(math.floor(gframes / 60), 60);
	min		= math.fmod(math.floor(gframes / 3600), 60);

	if (score - scoreold) >= 20 then
		scoredisptimer	= 30;
	
	elseif (score - scoreold) ~= 0 and (scoreold == scoredisp) then
		scoredisptimer	= math.max(scoredisptimer, 15);
	
	end;
	
	if scoredisp ~= score then
		scoredisptimer	= scoredisptimer - 1;
		
		if scoredisptimer < 0 then
			scoredisp	= math.min(score, scoredisp + math.max(1, (score - scoredisp) * 0.05));
		end;
	end;
	
	gui.drawbox( 7, 15, 87, 64 + 24, "black", "black");
	
	if goal == "lines" then
	
		goalpct	= math.min(1, lines / goalamt);
		goalbar	= math.ceil(65 * goalpct + 14);
	
		gui.text(16, 19, "Lines:", "gray", "clear")
		gui.text(27, 29, string.format("%3d", lines), "white", "clear");
		gui.text(51, 29, string.format("/ %3d", goalamt), "#8080ff", "clear");
		
		gui.drawbox(14, 40, 79, 43, "blue", "white");
		gui.drawbox(14, 40, goalbar, 43, "white", "white");
		
		gui.text(16, 41 + 10, "Score:", "gray", "clear");
		gui.text(30, 51 + 10, string.format("%6dpts", scoredisp), "white", "clear");
		scoredispy	= 70;
		
	end;


	if goal == "score" then
	
		goalpct	= math.min(1, scoredisp / goalamt);
		goalbar	= math.ceil(65 * goalpct + 14);
	
		gui.text(16, 19, "Lines:", "gray", "clear")
		gui.text(62, 29, string.format("%3d", lines), "white", "clear");
		
		gui.text(16, 41, "Score:", "gray", "clear");
		gui.text(30, 51, string.format("%6dpts", scoredisp), "white", "clear");
		gui.text(19, 60, string.format("/ %6dpts", goalamt), "#8080ff", "clear");

		gui.drawbox(14, 70, 79, 73, "blue", "white");
		gui.drawbox(14, 70, goalbar, 73, "white", "white");
	
		scoredispy	= 76;
	
	end;

	if (score - scoredisp) > 0 then
		if (scoredisptimer >= 0) and (scoredisp + 200 < score) and (math.mod(globaltimer, 6) < 3) then
			color	= "white";
		else
			color	= "#80ff80";
		end;
		
		gui.text(18, scoredispy, string.format("+ %6dpts", (score - scoredisp)), color, "clear");
	end;

	
	if finished and math.fmod(globaltimer, 6) < 3 then
		color	= "#80ff80";
	else
		color	= "#ffffff";
	end;
	
	gui.text(88, 35, string.format("   TIME  %d'%02d\"%02d ", min, sec, msec), color, "black");


	
	
	emu.frameadvance();



end;