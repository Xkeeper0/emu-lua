
goaltext	= "SMB1 warpless";

gframes		= 0;
gstarted	= false;
gfinished	= false;

globaltimer	= 0;





if goaltext ~= "" then
	goaltext	= " - ".. goaltext;
end;

while true do

	globaltimer	= globaltimer+1;
	
	inpt	= input.get();

	if not gstarted and inpt['Z'] then
		gstarted = true;
	end;

	if gstarted and inpt['X'] then
		gfinished = true;
	end;

	
	if gstarted and not gfinished then
		gframes = gframes + 1;
	end;

	if (goal == "score" and score >= goalamt) or (goal == "lines" and lines >= goalamt) then
		finished	= true;
	end;
	
	

	msec	= math.fmod(gframes, 60) / 60 * 100;
	sec		= math.fmod(math.floor(gframes / 60), 60);
	min		= math.fmod(math.floor(gframes / 3600), 60);
	hour	= math.fmod(math.floor(gframes / 216000), 60);

	
	
	if gfinished and math.fmod(globaltimer, 6) < 3 then
		color	= "#80ff80";
	else
		color	= "#ffffff";
	end;
	
	gui.drawbox( 0, 0, 255, 9, "black", "black");
	gui.text(1, 1, string.format("%2d:%02d'%02d\"%02d%s", hour, min, sec, msec, goaltext), color, "black");


	
	
	emu.frameadvance();



end;