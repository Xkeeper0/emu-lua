-- NES Braidulator VERSION 1
--(C) Antony Lavelle 2009       got_wot@hotmail.com      http://www.the-exp.net
-- A Lua script that allows 'Braid' style time reversal for Nes games being run in FCEUX
--'Braid' is copyright Jonathan Blow, who is not affiliated with this script, but you should all buy his game because it's ace.
--This is my first ever time scripting in Lua, so if you can improve on this idea/code please by all means do and redistribute it, just please be nice and include original credits along with your own :)



function do_hud()
	thour	= math.floor(nocrash / (216000));
	tmin	= math.floor(math.fmod(nocrash, 216000) / (3600));
	tsec	= math.floor(math.fmod(nocrash, 3600) / (60));
	tusec	= math.floor(math.fmod(nocrash, 60) / 60 * 100);

	mhour	= math.floor(mnocrash / (216000));
	mmin	= math.floor(math.fmod(mnocrash, 216000) / (3600));
	msec	= math.floor(math.fmod(mnocrash, 3600) / (60));
	musec	= math.floor(math.fmod(mnocrash, 60) / 60 * 100);
	
--	gui.text(183,  0, string.format("Top%2d:%02d:%02d.%02d", mhour, mmin, msec, musec));
--	gui.text(199,  8, string.format("%2d:%02d:%02d.%02d", thour, tmin, tsec, tusec));
	gui.text(186,  0, string.format("%5db %5s", funtimes, string.format("1/%d", divisor+1)));

	

	gui.box(0,238,255,239, "black");
	gui.box(0,238,wow - 1,239, "white");
	if framewow >= 1 then
		gui.box(0,238,framewow - 1,239, "red");
	end;
	--gui.text(0,230, string.format("W:%4d B:%3d", wow, framewow ));

	wow	= 0;
	framewow = 0;

	
end;



function crash_recover() 
	
	derp	= math.ceil((crashdetect * 2)/ saveinterval);

	for i = 1, derp do

		if rewindCount==0 then
			--makes sure you can't go back too far could also include other things in here, left empty for now.	
		else	
			savestate.load(saveArray[saveCount]);
			saveCount = saveCount-1;
			rewindCount = rewindCount-1;
			if saveCount==0 then		
				saveCount = saveMax-1;
			end;
		end;
		
		gui.text(8,8, " REV ".. crashretries);
		do_hud();
		FCEU.frameadvance();
		
	end;

end;



function do_timewarp_save()

	if math.fmod(timer, saveinterval) == 0 then
		saveCount=saveCount+1;
		if saveCount==saveMax then
			saveCount = 1;
		end
		rewindCount = rewindCount+1;
		if rewindCount==saveMax-1 then
			rewindCount = saveMax-2;
		end;
		save = savestate.create();
		savestate.save(save);
		saveArray[saveCount] = save;
	end;

end;


function wowcoolfactsaboutgaming()

	wow = wow + 1;
	keys = {};
	
	if math.random(0, divisor) == 0 then

		if math.random(0, 1) == 0 then

			keys['A'] = true;
		else
		
			keys['S'] = true;
		end;
		framewow	= framewow + 1;
	end;



	if keys['A'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		--gui.text(0, 8 * (framewow - 1), string.format("%03X=%02X", bang1, bang2));
	end;
	if keys['S'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= memory.readbyte(bang1) + (math.random(0, 1) * 2 - 1);
		if bang2 == -1 then 
			bang2 = 0xFF;
		end;
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		--gui.text(0,  8 * (framewow - 1), string.format("%03X+%02X", bang1, math.min(0xFF, bang2)));
	end;

	

end;


--Change these settings to adjust options


--Which key you would like to function as the "rewind key"

rewindKey = 'Z'


--How much rewind power would you like? (The higher the number the further back in time you can go, but more computer memory is used up)
--Do not set to 0!
wow = 0;
framewow = 0;
memory.registerwrite(0x0000, wowcoolfactsaboutgaming)

saveMax = 500;



funtimes	= 0;
txttime		= 0;
nocrash		= 0;
divisor		= 100;
mnocrash	= 0;

--The stuff below is for more advanced users, enter at your own peril!


crashdetect	= 30;
last9		= 0;
last9c	= 0;
saveArray = {};--the Array in which the save states are stored
saveCount = 1;--used for finding which array position to cycle through
save = nil; -- the variable used for storing the save state
rewindCount = 0;--this stops you looping back around the array if theres nothing at the end
savePreventBuffer = 1;--Used for more control over when save states will be saved, not really used in this version much.


timer			= 0;
saveinterval	= 1;

crashgracemax	=  90;
crashretriesmax	= 1;
crashgrace		= 0;
crashretries	= crashretriesmax;


while (true) do

	timer		= timer + 1;
	crashgrace	= crashgrace - 1;
	
	do_timewarp_save();
	
	--[[
	if crashgrace == 0 then
		crashgrace		= crashgracemax;
		crashretries	= crashretriesmax;
	end;
	--]]

	memory.writebyte(0x07a2, 0x00);

	if (last9 == memory.readbyte(0x09)) then
		last9c	= last9c + 1;
		if last9c > crashdetect then
			
			-- If we've crashed...
			if crashgrace <= 0 then
				-- Game hasn't crashed recently
				-- Try recovering from the crash fresh
				crashretries	= crashretriesmax;
				crashgrace		= crashgracemax;
				crash_recover();
			
			elseif crashgrace > 0 and crashretries > 0 then
				-- Game didn't successfully un-freeze, try again
				crashretries	= crashretries - 1;
				crashgrace		= crashgracemax;
				crash_recover();

			elseif crashretries == 0 then
				-- Game failed to recover after a few retries; give up and reset
				funtimes	= 0
				emu.softreset();
				nocrash		= 0;
				last9c		= 0;
				divisor		= math.random(10, 499);
				
			end;
		end;
	else
		last9c	= 0;
	end;

	if crashgrace > 0 then
		gui.text(8,8, " FWD ".. crashretries);
		gui.text(8,16,string.format("WAIT %2d", crashgrace));
	elseif crashgrace > -30 then
		if crashretries == 0 then
			gui.text(8,8, "RESET ");
	
		else
			gui.text(8,8, "     ".. crashretries);
		end;
		gui.text(8,16, "  OK  ");
	end;
	
	
	last9	= memory.readbyte(0x09);

	
	keys	= input.get();
	reset	= 0;
	--[[
	if math.random(0, divisor) == 0 then

		if math.random(0, 3) == 0 then

			keys['A'] = true;
		else
		
			keys['S'] = true;
		end;
	end;
	--]]

	-- Scramble world location endlessly
	bang2	= math.random(0, 0xFF);
	memory.writebyte(0x750, bang2);

	--[[
	if keys['A'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(0, 0, "RND");
	end;
	if keys['S'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= memory.readbyte(bang1) + (math.random(0, 1) * 2 - 1);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(0, 0, "INC");
	end;
	if keys['Q'] then

		bang1	= math.random(0x6000, 0x7FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;

--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	--]]
	if reset == 1 then
		txttime	= 0;
	end;
	if txttime < 20 then
		--gui.text(220, 0, string.format("%6d", funtimes));
	end;


	txttime	= txttime + 1;
	
	do_hud();
	
	FCEU.frameadvance();
	
	nocrash = nocrash + 1;
	mnocrash = math.max(mnocrash, nocrash)
end;
