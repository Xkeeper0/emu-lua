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

local saveFrequency = 5; -- look at me mom, I'm editing LIVE!
local timer = -1;

while (true) do

	timer = timer + 1;
	
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
		gui.text(1,0, string.format("%.2f%%", HUDMATH * 100));--Displaying the time onscreen.
		
		if math.fmod(timer, 30) <= 15 then
			gui.text(138,8, "<<"); -- picky, picky
		end;
	end;
	if savePreventBuffer==1 and math.fmod(timer, saveFrequency) == 0 then
		-- gui.text(80,15,"");
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
	if keys['A'] then

		gui.text(1,137, "Random bytes"); -- picky, picky
		bang1	= math.random(0x9800, 0xFEFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);

		--print(string.format("%04X => %02X", bang1, bang2));
	end;
	if keys['S'] then

		gui.text(1,137, "+/- 1"); -- picky, picky
		bang1	= math.random(0x9800, 0xFEFF)
		bang2	= AND(memory.readbyte(bang1) + math.random(-1, 1), 0xFF);
		memory.writebyte(bang1, bang2);

		--print(string.format("%04X => %02X", bang1, bang2));
	end;

	-- KABLOOEY
	if keys['M'] then

		gui.text(1,137, "Power corruption!"); -- picky, picky
		for i = 0, 0xF do
			bang1	= math.random(0xA000, 0xFEFF)
			bang2	= math.random(0x00, 0xFF);
			memory.writebyte(bang1, bang2);
		
			--print(string.format("%04X => %02X", bang1, bang2));
		end;
	end;

	if keys['Q'] then

		gui.text(1,137, "Trashing VRAM"); -- picky, picky
		bang1	= math.random(0x8000, 0x9FFF)
		bang2	= math.random(0, 0xFF);
		memory.writebyte(bang1, bang2);

		--print(string.format("%04X => %02X", bang1, bang2));
	end;
	
	emu.frameadvance();
end;
