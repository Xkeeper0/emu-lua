-- NES Braidulator VERSION 1
--(C) Antony Lavelle 2009       got_wot@hotmail.com      http://www.the-exp.net
-- A Lua script that allows 'Braid' style time reversal for Nes games being run in FCEUX
--'Braid' is copyright Jonathan Blow, who is not affiliated with this script, but you should all buy his game because it's ace.
--This is my first ever time scripting in Lua, so if you can improve on this idea/code please by all means do and redistribute it, just please be nice and include original credits along with your own :)



--Change these settings to adjust options


--Which key you would like to function as the "rewind key"

local rewindKey = 'Z'


--How much rewind power would you like? (The higher the number the further back in time you can go, but more computer memory is used up)
--Do not set to 0!

local saveMax = 5000;



funtimes	= 0;
txttime		= 0;
nocrash		= 0;
divisor		= 3;
mnocrash	= 0;

--The stuff below is for more advanced users, enter at your own peril!


local last9		= 0;
local last9c	= 0;
local saveArray = {};--the Array in which the save states are stored
local saveCount = 1;--used for finding which array position to cycle through
local save; -- the variable used for storing the save state
local rewindCount = 0;--this stops you looping back around the array if theres nothing at the end
local savePreventBuffer = 1;--Used for more control over when save states will be saved, not really used in this version much.
while (true) do

	memory.writebyte(0x07a2, 0x00);

	if (last9 == memory.readbyte(0x09)) then
		last9c	= last9c + 1;
		if last9c > 10 then
			funtimes	= 0
			emu.softreset();
			nocrash		= 0;
			last9c		= 0;
			divisor		= math.random(0, 15);
		end;
	else
		last9c	= 0;
	end;
	last9	= memory.readbyte(0x09);

	--[[
	savePreventBuffer = savePreventBuffer-1;
	if savePreventBuffer==0 then
		savePreventBuffer = 1;
	end;
	joyput	= input.get();
	if joyput[rewindKey] then
		savePreventBuffer = 5;
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
		local HUDMATH = rewindCount / saveMax;--Making the rewind time a percentage.
		-- gui.text(0,0, string.format("%.2f%%", HUDMATH * 100));--Displaying the time onscreen.
	end;
	if savePreventBuffer==1 then
		--gui.text(80,15,"");
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
	--]]
	
	keys	= input.get();
	reset	= 0;
	if math.random(0, divisor) == 0 then
		keys['A'] = true;
	end;
	if keys['A'] then

		bang1	= math.random(0x0000, 0x07FF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['Q'] then

		bang1	= math.random(0x6000, 0x7FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;

--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if reset == 1 then
		txttime	= 0;
	end;
	if txttime < 20 then
		--gui.text(220, 0, string.format("%6d", funtimes));
	end;


	txttime	= txttime + 1;
	
	
	thour	= math.floor(nocrash / (216000));
	tmin	= math.floor(math.fmod(nocrash, 216000) / (3600));
	tsec	= math.floor(math.fmod(nocrash, 3600) / (60));
	tusec	= math.floor(math.fmod(nocrash, 60) / 60 * 100);

	mhour	= math.floor(mnocrash / (216000));
	mmin	= math.floor(math.fmod(mnocrash, 216000) / (3600));
	msec	= math.floor(math.fmod(mnocrash, 3600) / (60));
	musec	= math.floor(math.fmod(mnocrash, 60) / 60 * 100);
	
	gui.text(183,  0, string.format("Top%2d:%02d:%02d.%02d", mhour, mmin, msec, musec));
	gui.text(199,  8, string.format("%2d:%02d:%02d.%02d", thour, tmin, tsec, tusec));
	gui.text(198, 16, string.format("%4db %4s", funtimes, string.format("1/%d", divisor+1)));
	
	FCEU.frameadvance();
	
	nocrash = nocrash + 1;
	mnocrash = math.max(mnocrash, nocrash)
end;
