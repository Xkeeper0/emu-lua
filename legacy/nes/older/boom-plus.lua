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



funtimes = 0;
txttime	= 0;



--The stuff below is for more advanced users, enter at your own peril!



local saveArray = {};--the Array in which the save states are stored
local saveCount = 1;--used for finding which array position to cycle through
local save; -- the variable used for storing the save state
local rewindCount = 0;--this stops you looping back around the array if theres nothing at the end
local savePreventBuffer = 1;--Used for more control over when save states will be saved, not really used in this version much.

timer			= 0;
saveinterval	= 1;
while (true) do
	timer = timer + 1;

	gui.pixel(0, 0, "clear");
	
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
		--gui.text(0,0, string.format("%.2f%%", HUDMATH * 100));--Displaying the time onscreen.
		
		if HUDMATH > 0.25 or math.fmod(timer, 20) < 10 then
		
			rwy	= 16;
			
			for rwarrow = -1, 7 do
				gui.line(220 + rwarrow, rwy - 1 - math.floor(rwarrow / 2), 220 + rwarrow, rwy + 1 + math.floor(rwarrow / 2), "black");
				gui.line(221 + rwarrow, rwy - 1 - math.floor(rwarrow / 2), 221 + rwarrow, rwy + 1 + math.floor(rwarrow / 2), "black");
				gui.line(229 + rwarrow, rwy - 1 - math.floor(rwarrow / 2), 229 + rwarrow, rwy + 1 + math.floor(rwarrow / 2), "black");
				gui.line(230 + rwarrow, rwy - 1 - math.floor(rwarrow / 2), 230 + rwarrow, rwy + 1 + math.floor(rwarrow / 2), "black");

			end;
			for rwarrow = 0, 7 do
				c1	= "white";
				if (rwarrow / 7) >= (HUDMATH / 0.9) then
					c1	= "red";
				end;
				c2	= "white";
				if (rwarrow / 7) > (HUDMATH - .90) * 10 then
					c2	= "red";
				end;
				
				gui.line(220 + rwarrow, rwy - math.floor(rwarrow / 2), 220 + rwarrow, rwy + math.floor(rwarrow / 2), c1);
				gui.line(229 + rwarrow, rwy - math.floor(rwarrow / 2), 229 + rwarrow, rwy + math.floor(rwarrow / 2), c2);
			end;
--			gui.text(220, 8, "<<");
		end;
	end;
	if math.fmod(timer, saveinterval) == 0 and savePreventBuffer==1 then
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
	
	
	keys	= input.get();
	reset	= 0;
	if keys['A'] then

		crap	= true
		while crap do
			bang1	= math.random(0x0000, 0x07FF)
			if not (bang1 >= 0x100 and bang1 <= 0x1ff) then
				crap = false;
			end 
		end;
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(220, 8, "RAM");
--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['S'] then

		crap	= true
		while crap do
			bang1	= math.random(0x0000, 0x07FF)
			if not (bang1 >= 0x100 and bang1 <= 0x1ff) then
				crap = false;
			end 
		end;
		bang2	= memory.readbyte(bang1) + (math.random(0, 1) * 2 - 1);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(220, 14, "INC");
--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['Q'] then

		bang1	= math.random(0x6000, 0x7FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(220 + 6 * 3, 8, "SAV");

--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['W'] then

		bang1	= math.random(0x6000, 0x7FFF)
		bang2	= memory.readbyte(bang1) + (math.random(0, 1) * 2 - 1);
		memory.writebyte(bang1, bang2);
		funtimes	= funtimes + 1;
		reset		= 1;
		gui.text(220 + 6 * 3, 14, "SIN");

--		print(string.format("%04X => %02X", bang1, bang2));
	end;
	if reset == 1 then
		txttime	= 0;
	end;
	if txttime < 20 then
		gui.text(220, 0, string.format("%6d", funtimes));
	end;

	txttime	= txttime + 1;
	
	FCEU.frameadvance();
end;
