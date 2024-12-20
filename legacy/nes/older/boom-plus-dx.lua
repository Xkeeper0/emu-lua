

-- Amount of frames to allow rewinding
-- Higher == MORE MEMORY INTENSIVE.
-- Don't set this too high or else
rewindMax	= 2500;


keyBindings	= {
	rewind	= "Z",	-- rewind button (important)

	ramrnd	= "A",	-- 0000-07FF random-bytes
	raminc	= "S",	-- 0000-07FF +/- 1
	extrnd	= "Q",	-- 6000-7FFF random bytes
	extinc	= "W",	-- 6000-7FFF +/- 1
	ggadd	= "X",	-- Game genie code add (random)
	ggdel	= "C",	-- Game genie code del (random)
}


-- -------------------------------- --
-- Nonconfigurable stuff below here --
-- -------------------------------- --




function math.round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end



function corruptByte(rangeLow, rangeHigh, inc)

	local byte	= math.random(rangeLow, rangeHigh)
	local value	= math.random(0x00, 0xFF)
	if inc then
		value	= memory.readbyte(byte) - 1 + (math.random(0, 1) * 2)
	end

	memory.writebyte(byte, value)

	corruptBytes	= corruptBytes + 1
end



function statusLights(x, y, flags)

	gui.box(x, y, x + 27, y + 8, "black")
	gui.text(x +  1, y + 1, "R", flags['ramrnd'] and "white" or "gray", "black")
	gui.text(x +  9, y + 1, "I", flags['raminc'] and "white" or "gray", "black")
	gui.text(x + 15, y + 1, "E", flags['extrnd'] and "white" or "gray", "black")
	gui.text(x + 22, y + 1, "S", flags['extinc'] and "white" or "gray", "black")

end


function randomGameGenieCode()

	local ggLetters	= 'AEPOZXLUGKISTVYN'
	local ret		= ''
	for i = 1, 6 do
		local letter	= math.random(1, 16)
		ret			= ret .. ggLetters:sub(letter, letter)
	end

	return ret

end






function rewindArrow(x, y, v, max, rewinding)

	local rwx	= x;
	local rwy	= y;

	local pct	= math.min(math.max(0, v / max), 1)

	gui.box(x + 0, y + 2, x + 31, y + 6, "#444444", "black")

	local barsize	= math.round(pct * 30);
	local color		= "#9999ff"
	if pct < 0.25 then
		color	= "red"
	end
	if barsize > 0 then
		gui.box(x + 1, y + 3, x + 0 + barsize, y + 5, color, color)
	end

	rwx	= rwx + 7

	if rewinding and v == 0 then
		gui.box(rwx + 4, rwy - 4, rwx + 8, rwy + 4, "white", "black")
		gui.box(rwx + 10, rwy - 4, rwx + 14, rwy + 4, "white", "black")
	elseif rewinding then
		for rw = -1, 7 do
			gui.line(rwx +  0 + rw, rwy - 1 - math.floor(rw / 2), rwx +  0 + rw, rwy + 1 + math.floor(rw / 2), "black");
			gui.line(rwx +  1 + rw, rwy - 1 - math.floor(rw / 2), rwx +  1 + rw, rwy + 1 + math.floor(rw / 2), "black");
			gui.line(rwx +  9 + rw, rwy - 1 - math.floor(rw / 2), rwx +  9 + rw, rwy + 1 + math.floor(rw / 2), "black");
			gui.line(rwx + 10 + rw, rwy - 1 - math.floor(rw / 2), rwx + 10 + rw, rwy + 1 + math.floor(rw / 2), "black");

			if rw >= 0 then
				gui.line(rwx + 0 + rw, rwy - math.floor(rw / 2), rwx + 0 + rw, rwy + math.floor(rw / 2), "white");
				gui.line(rwx + 9 + rw, rwy - math.floor(rw / 2), rwx + 9 + rw, rwy + math.floor(rw / 2), "white");
			end
		end;
	else
		for rw = 0, 8 do
			gui.line(rwx +  5 + rw, rwy - 1 - math.floor((7 - rw) / 2), rwx +  5 + rw, rwy + 1 + math.floor((7 - rw) / 2), "black");
			gui.line(rwx +  6 + rw, rwy - 1 - math.floor((7 - rw) / 2), rwx +  6 + rw, rwy + 1 + math.floor((7 - rw) / 2), "black");

			if rw >= 1 then
				gui.line(rwx + 5 + rw, rwy - math.ceil((7 - rw) / 2), rwx + 5 + rw, rwy + math.ceil((7 - rw) / 2), "white");
			end
		end;


	end


end


corruptBytes	= 0
timer			= 0
inpt			= {}
inpto			= {}
gameGenieCodes	= {}
saveStates		= {}
saveIndex		= 0
saveIndexMin	= 0

while true do

	inpto	= inpt;
	inpt	= input.get()

	local rewinding	= false
	if inpt[keyBindings['rewind']] then
		rewinding	= true
	end

	if inpt[keyBindings['rewind']] and saveStates[saveIndex] then
		savestate.load(saveStates[saveIndex])
		if saveStates[saveIndex - 1] then
			saveIndex	= saveIndex - 1
		else
			saveIndexMin	= saveIndex;
		end
	else

		local save = savestate.create()
		savestate.save(save)
		saveIndexMin		= math.max(saveIndexMin, saveIndex - rewindMax)
		saveIndex			= saveIndex + 1
		saveStates[saveIndex] = save
		saveStates[saveIndexMin]	= nil
	end

	rewindArrow(220, 230, saveIndex - saveIndexMin, rewindMax, rewinding);




	local corruptionFlag	= {
		ramrnd	= false,
		raminc	= false,
		extrnd	= false,
		extinc	= false,
	}



	if inpt[keyBindings['ramrnd']] then
		corruptByte(0x0000, 0x07FF)
		corruptionFlag['ramrnd']	= true;
	end
	if inpt[keyBindings['raminc']] then
		corruptByte(0x0000, 0x07FF, true)
		corruptionFlag['raminc']	= true;
	end
	if inpt[keyBindings['extrnd']] then
		corruptByte(0x6000, 0x7FFF)
		corruptionFlag['extrnd']	= true;
	end
	if inpt[keyBindings['extinc']] then
		corruptByte(0x6000, 0x7FFF, true)
		corruptionFlag['extinc']	= true;
	end

	if inpt[keyBindings['ggadd']] and not inpto[keyBindings['ggadd']] then
		local code	= randomGameGenieCode()
		emu.addgamegenie(code)
		table.insert(gameGenieCodes, code);
		print(code)
	end

	if inpt[keyBindings['ggdel']] and not inpto[keyBindings['ggdel']] then
		local codes	= table.getn(gameGenieCodes);
		if codes > 0 then
			local code	= math.random(1, codes)
			emu.delgamegenie(gameGenieCodes[code])
			table.remove(gameGenieCodes, code)
		end
		print(gameGenieCodes)
	end

	statusLights( 228, 0, corruptionFlag)



--[[

	ramrnd	= "A",	-- 0000-07FF random-bytes
	raminc	= "S",	-- 0000-07FF +/- 1
	extrnd	= "Q",	-- 6000-7FFF random bytes
	extinc	= "W",	-- 6000-7FFF +/- 1
	ggadd	= "X",	-- Game genie code add (random)
	ggdel	= "C",	-- Game genie code del (random)
}

--]]




	timer	= timer + 1
	emu.frameadvance()

end



