-- smb1 autocorrupt script
-- load mario 1, load this, watch chaos
-- flashing warning: it causes a lot of full-screen flashing/glitching by nature
--
-- note:
-- push the "P" button on your keyboard to disable corruption
-- and clear entered game genie codes
--
-- disabling this script without cleanly stopping it this way may
-- result in left-over game genie codes

-- a lot of stuff below here is based off of a manual corrupt script,
-- which was intended to be used while playing
-- it has been hastily modified to mostly work with smb1
-- and do its corruptions automatically
--
-- you may have to make a lot of adjustments to use this
-- in anything other than my very specific circumstances



-- Amount of frames to allow rewinding
-- Higher == MORE MEMORY INTENSIVE.
-- Don't set this too high or else
rewindMax	= 30;

-- Time between full resets, in seconds
-- crashes reset this timer
-- independent of framerate - slower framerates 
-- will still reset every x seconds
resetInterval	= 300

keyBindings	= {
	rewind	= "Z",	-- rewind button (important)

	ramrnd	= "A",	-- 0000-07FF random-bytes
	raminc	= "S",	-- 0000-07FF +/- 1
	extrnd	= "Q",	-- 6000-7FFF random bytes
	extinc	= "W",	-- 6000-7FFF +/- 1
	ggadd	= "X",	-- Game genie code add (random)
	ggdel	= "C",	-- Game genie code del (random)
	ramswap	= "G",	-- Game genie code del (random)
	extswap	= "T",	-- Game genie code del (random)
	showHUD	= "N",	-- Toggle corruption HUD
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




function swapBytes(rangeLow, rangeHigh)

	local byte1	= math.random(rangeLow + 1, rangeHigh - 1)
	local byte2	= byte1 - 1 + (math.random(0, 1) * 2)

	local	byte1val	= memory.readbyte(byte1)
	local	byte2val	= memory.readbyte(byte2)
	memory.writebyte(byte1, byte2val)
	memory.writebyte(byte2, byte1val)

	corruptBytes	= corruptBytes + 1
end



function statusLights(x, y, flags)

	x	= x + 10;

	gui.box(x - 10, y, x + 28, y + 8, "#000000a0", "#000000a0")
	gui.text(x -  9, y + 1, "C", table.getn(gameGenieCodes) > 0 and "white" or "gray", "clear")
	gui.text(x -  1, y + 1, "R", flags['ramrnd'] and "white" or "gray", "clear")
	gui.text(x +  8, y + 1, "I", flags['raminc'] and "white" or "gray", "clear")
	gui.text(x + 15, y + 1, "E", flags['extrnd'] and "white" or "gray", "clear")
	gui.text(x + 23, y + 1, "S", flags['extinc'] and "white" or "gray", "clear")

	if ggtimer > -120 then
		local numCodes	= table.getn(gameGenieCodes)
		local displayCodes	= math.min(3, numCodes)
		if numCodes > 0 then
			gui.box(x - 10, y + 9, x + 28, y + 10 + 8 * displayCodes, "#000000a0", "#000000a0")
		end
		for i, v in ipairs(gameGenieCodes) do
			if (i > numCodes - displayCodes) then
				gui.text(x - 9, y + 3 + 8 * (i - (numCodes - displayCodes)), v, "white", "clear")
			end
		end
		if numCodes > displayCodes then
			gui.text(x - 9, y + 3 + 8 * 4, string.format(" +%3d  ", numCodes - displayCodes), "white", "black")
		end
	end

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





do
	local rewindMode	= 0
	local crashCheck	= 0
	local retries		= 1
	local triedFix		= false


	function resetCrashDetection()
		crashCheck	= 0
		timer = 0
	end

	function doCrashCheck()

		--[[
		if nmiRuns > 0 then
			crashCheck	= 0
		else
			crashCheck	= crashCheck + 1
		end
		--]]
		
		-- --[[
		if writes0000 <= 20 or writes0000 >= 120 then	-- @todo: configurable
			crashCheck	= crashCheck + 1
		else
			crashCheck	= 0
		end
		

		if crashCheck > 1 and not triedFix then
			-- Sets the "wait for sprite zero hit" check to branch 0 (don't wait)
			-- Sprite zero is the coin in the status bar, used to split the screen
			triedFix	= true
			emu.addgamegenie("AAIATP")

		elseif triedFix then
			-- Remove the "fix" to see if it will work again
			triedFix	= false
			emu.delgamegenie("AAIATP")
		end
		-- --]]

		if crashCheck > 10 then
			-- try to get it back on the rails
			-- by forcing it to the idle wait loop
			memory.setregister("pc", 0x8057)
		end

		if crashCheck > 15 then	-- @todo: configurable
			return true
		end
		return false
	end


	function undoCrash()
		local i = 0
		for retry = 1, retries do
			for i = 1, rewindMax do
				doRewind(true)
				rewindArrow(220, 230, saveIndex - saveIndexMin, rewindMax, true);
				gui.box(227 - 10, 0, 227 + 28, 0 + 8, "#000000a0", "#000000a0")
				gui.text(227 -  9, 0 + 2, "Crashed", "red", "clear")
				advanceFrame(true)
			end
			local crashed	= false
			for i = 1, rewindMax do
				doRewind(false)
				rewindArrow(220, 230, saveIndex - saveIndexMin, rewindMax, false);
				crashed		= crashed or doCrashCheck()
				gui.box(227 - 10, 0, 227 + 28, 0 + 8, "#000000a0", "#000000a0")
				gui.text(227 -  9, 0 + 2, "Crashed", "red", "clear")
				advanceFrame(false)
			end

			if not crashed then
				return true
			end
		end

		return false
	end
end




function doRewind(rewinding)

	if rewinding and saveStates[saveIndex] then
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
end


function rewindArrow(x, y, v, max, rewinding)

	local rwx	= x;
	local rwy	= y;

	local pct	= math.min(math.max(0, v / max), 1)

	gui.box(x + 0, y + 2, x + 31, y + 6, "#000000b0", "black")

	local barsize	= math.round(pct * 30)
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
			gui.line(rwx +  0 + rw, rwy - 1 - math.floor(rw / 2), rwx +  0 + rw, rwy + 1 + math.floor(rw / 2), "black")
			gui.line(rwx +  1 + rw, rwy - 1 - math.floor(rw / 2), rwx +  1 + rw, rwy + 1 + math.floor(rw / 2), "black")
			gui.line(rwx +  9 + rw, rwy - 1 - math.floor(rw / 2), rwx +  9 + rw, rwy + 1 + math.floor(rw / 2), "black")
			gui.line(rwx + 10 + rw, rwy - 1 - math.floor(rw / 2), rwx + 10 + rw, rwy + 1 + math.floor(rw / 2), "black")

			if rw >= 0 then
				gui.line(rwx + 0 + rw, rwy - math.floor(rw / 2), rwx + 0 + rw, rwy + math.floor(rw / 2), "white")
				gui.line(rwx + 9 + rw, rwy - math.floor(rw / 2), rwx + 9 + rw, rwy + math.floor(rw / 2), "white")
			end
		end
	else
		for rw = 0, 8 do
			gui.line(rwx +  5 + rw, rwy - 1 - math.floor((7 - rw) / 2), rwx +  5 + rw, rwy + 1 + math.floor((7 - rw) / 2), "black")
			gui.line(rwx +  6 + rw, rwy - 1 - math.floor((7 - rw) / 2), rwx +  6 + rw, rwy + 1 + math.floor((7 - rw) / 2), "black")

			if rw >= 1 then
				gui.line(rwx + 5 + rw, rwy - math.ceil((7 - rw) / 2), rwx + 5 + rw, rwy + math.ceil((7 - rw) / 2), "white")
			end
		end


	end


end


function wipeGGCodes()
	while table.getn(gameGenieCodes) > 0 do
		emu.delgamegenie(gameGenieCodes[table.getn(gameGenieCodes)])
		table.remove(gameGenieCodes)
	end
end


function advanceFrame(rewinding)
	gui.box(0, 0, 80, 12, "#000000")
	if not rewinding then
		table.insert(writes0000Graph, writes0000)
		if table.getn(writes0000Graph) > 60 then
			table.remove(writes0000Graph, 1)
		end
	end

	if not rewinding then
		table.insert(nmiRunsGraph, nmiRuns)
		if table.getn(nmiRunsGraph) > 60 then
			table.remove(nmiRunsGraph, 1)
		end
	end

	-- --[[
	local c	= "#ffffff"
	for k,v in pairs(writes0000Graph) do
		c	= "#ffffff"
		if v <= 20 or v >= 120 then
			c	= "#ff0000"
		elseif v <= 40 then
			c	= "#ffff00"
		elseif v <= 80 then
			c	= "#00ff00"
		end
		gui.pixel(k + 19, 12 - (math.min(100, math.max(0, v - 20)) / 100 * 12), c)
	end
	gui.text(1, 3, string.format("%3d", writes0000), c, "clear")
	--]]

	--[[
	local c	= "white"
	for k,v in pairs(nmiRunsGraph) do
		c	= "white"
		if v == 0 then
			c	= "red"
		elseif v == 1 then
			c	= "white"
		else
			c	= "gray"
		end
		gui.line(k + 19, 5, k + 19, 7, c)
	end
	gui.text(1, 3, string.format("%3d", nmiRuns), c, "clear")

	if not rewinding then
		gui.text( 1, 210, string.format("%1d", nmiRuns), "white", "black")
	else
		gui.text( 1, 210, "-", "white", "black")
	end
	--]]
	--[[
	--]]


	--8492, 848F
	local registerS		= memory.getregister("s")
	local registerPC	= memory.getregister("pc")
	local bunkString	= ""
	--[[

	if registerPC ~= 0x8492 and registerPC ~= 0x848F then
		pcBunkFrames	= pcBunkFrames + 1
	else
		pcBunkFrames	= 0
	end
	if pcBunkFrames > 60 then
		bunkString	= " uh".. string.rep(".", math.min(12, (pcBunkFrames - 60) / 30))
	end
	if pcBunkFrames > 300 then
		bunkString	= " ...it's probably dead"
	end
	if pcBunkFrames > 480 then
		bunkString	= " RESET"
		pcBunkFrames	= 0
		wipeGGCodes()
		emu.poweron()
	end
	gui.text( 1, 232, string.format("SP=%02X PC=%04X%s", registerS, registerPC, bunkString), "white", "black")
	--]]

	local colS = "green"
	if (registerS < 0xF0) then
		colS = "red"
	elseif (registerS < 0xFF) then
		colS = "yellow"
	end

	local colPC = "green"
	if (registerPC < 0x8000) or (registerPC >= 0xFFF0) then
		colPC = "red"
	elseif (registerPC ~= 0x8057) then
		colPC = "yellow"
	end

	local timeLeft	= nextReset - os.time()
	local timeLeftM	= math.floor(timeLeft / 60)
	local timeLeftS = timeLeft % 60
	gui.text(  1, 224, string.format("%d'%02d\"", timeLeftM, timeLeftS), "white", "black")
	gui.text(  1, 232, string.format("SP=   PC=", registerS, registerPC), "white", "black")
	gui.text( 18, 232, string.format("%02X", registerS), colS, "black")
	gui.text( 53, 232, string.format("%04X", registerPC), colPC, "black")

	--[[
	for k,v in ipairs(thisFramePC) do
		gui.text(1, 15 + k * 8, string.format("%04X", v), "white", "black")
	end
	thisFramePC		= {}
	--]]
	writes0000		= 0
	nmiRuns			= 0
	timer	= timer + 1
	emu.frameadvance()
end



function memoryCheck()
	writes0000	= writes0000 + 1
	--local registerPC	= memory.getregister("pc")
	--thisFramePC[#thisFramePC + 1]	= registerPC
end

function nmiCheck()
	nmiRuns	= nmiRuns + 1
end

function areaRandomize()
	randomLevel			= memory.readbyte(0xFEE5 + math.random(0, 99))
	memory.writebyte(0x196, randomLevel)
end

memory.registerwrite(0x0000, memoryCheck)

do
	local nmiAddress	= memory.readbyte(0xFFFB) * 0x100 + memory.readbyte(0xFFFA)
	memory.registerexec(nmiAddress, nmiCheck)
end

function uhohIRQ()
	-- oh no you dont
	memory.setregister("pc", 0x8057)
end

memory.registerexec(0xFFF0, uhohIRQ)

memory.registerwrite(0x0196, areaRandomize)

writes0000		= 0
nmiRuns			= 0
writes0000Graph	= {}
nmiRunsGraph	= {}
corruptBytes	= 0
timer			= 0

pcBunkFrames	= 0

randomLevel		= 0

inpt			= {}
inpto			= {}

gameGenieCodes	= {}
ggtimer			= 0

showHUD			= true

saveStates		= {}
saveIndex		= 0
saveIndexMin	= 0

corruptChance	= 5

corruptKeys		= { 'ramrnd', 'raminc', 'ramswap', 'ggadd'}

shutdown		= false
nextReset		= os.time() + resetInterval
--thisFramePC		= {}

while true do

	memory.writebyte(0x07A2, 0)											-- start demo immediately
	memory.writebyte(0x0750, math.random(0, 0xFF))						-- write random areas
	memory.writebyte(0x0717, math.fmod(memory.readbyte(0x0717), 0x10))	-- keep demo going infinitely

	--[[
	if memory.readbyte(0x0141) >= 3 then									-- start demo faster (let intro music play)
		memory.writebyte(0x0141, 2)
	end
	--memory.writebyte(0x0196, math.random(0, 0xFF))							-- random doors for demo mode (EF normal max)
	gui.text(1, 224, string.format("D=%02X", randomLevel))
	--]]

	inpto	= inpt;
	inpt	= input.get()

	local rewinding	= false
	if inpt[keyBindings['rewind']] then
		rewinding	= true
	end

	doRewind(rewinding)


	if shutdown or inpt['P'] then
		shutdown		= true
		wipeGGCodes()
		gui.text(60, 110, "  corruption engine disabled  ", "white", "black")
		gui.text(61, 118, "  ready for script restart  ", "white", "black")
	end


	if not shutdown and math.random(1, corruptChance) == 1 then
		local corruptType	= math.random(1, 3)

		if math.random(1, 20) == 1 then
			corruptType	= 4
		end
		inpt[keyBindings[corruptKeys[corruptType]]]	= true
	end


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


	if inpt[keyBindings['ramswap']] then
		swapBytes(0x0000, 0x07FF)
		corruptionFlag['ramrnd']	= true;
	end
	if inpt[keyBindings['extswap']] then
		swapBytes(0x6000, 0x7FFF)
		corruptionFlag['raminc']	= true;
	end


	if inpt[keyBindings['ggadd']] and math.fmod(math.max(0, ggtimer), 6) == 0 then
		local code	= randomGameGenieCode()
		emu.addgamegenie(code)
		table.insert(gameGenieCodes, code)
	end

	if inpt[keyBindings['ggdel']] and math.fmod(math.max(0, ggtimer), 6) == 0 then
		if table.getn(gameGenieCodes) > 0 then
			emu.delgamegenie(gameGenieCodes[table.getn(gameGenieCodes)])
			table.remove(gameGenieCodes)
		end
	end


	if inpt[keyBindings['ggadd']] or inpt[keyBindings['ggdel']] then
		ggtimer	= math.max(1, ggtimer + 1)
	else
		ggtimer	= math.min(0, ggtimer - 1)
	end


	if inpt[keyBindings['showHUD']] and not inpto[keyBindings['showHUD']] then
		showHUD	= not showHUD
	end



	if showHUD then
		rewindArrow(220, 230, saveIndex - saveIndexMin, rewindMax, rewinding);
		statusLights( 217, 0, corruptionFlag)
	end


	if os.time() > nextReset then
		print "Full reset interval fired, resetting"
		wipeGGCodes()
		resetCrashDetection()
		emu.poweron()
		corruptChance	= math.random(1, 10);
		nextReset		= os.time() + resetInterval
	end


	if timer > 60 and doCrashCheck() then
		wipeGGCodes()
		if undoCrash() then
			print "ok, undid crash"
		else
			print "couldn't recover, resetting"
			corruptChance	= math.random(1, 10);
			emu.poweron()
			resetCrashDetection()
			nextReset		= os.time() + resetInterval
		end
	end
	emu.message("")

	advanceFrame(rewinding)

	-- easter egg to write out "D0NAT30" as the (high) score
	-- to disable these, remove the first two --s below:
	--[[

	if math.random(0, 2500) == 0 then
		local sofs = 0
		local eggtype = math.random(0, 100)
		if (eggtype > 0) then
			if math.random(0, 1) == 0 then
				sofs = 6
			end
			-- one in 2500 chance to write "d0nat3" to the
			-- current score or high score values
			-- (happens fairly often but actually seeing it
			-- requires the game redrawing the title without
			-- clearing memory from hard/soft reset)
			memory.writebyte(0x07D7 + sofs, 0x0D)
			memory.writebyte(0x07D8 + sofs, 0x00)
			memory.writebyte(0x07D9 + sofs, 0x17)
			memory.writebyte(0x07DA + sofs, 0x0A)
			memory.writebyte(0x07DB + sofs, 0x1D)
			memory.writebyte(0x07DC + sofs, 0x03)
		else
			-- mario sez trans rights
			-- the chance of this triggering and being visible is very low
			-- as it has a 1-in-250000 chance per frame to activate
			-- and also has to be rendered by the game without getting wiped
			memory.writebyte(0x07D7, 0x1D) -- T
			memory.writebyte(0x07D8, 0x1B) -- R
			memory.writebyte(0x07D9, 0x0A) -- A
			memory.writebyte(0x07DA, 0x17) -- N
			memory.writebyte(0x07DB, 0x1C) -- S
			memory.writebyte(0x07DC, 0x24) --
			memory.writebyte(0x07DE, 0x1B) -- R
			memory.writebyte(0x07DF, 0x12) -- I
			memory.writebyte(0x07E0, 0x10) -- G
			memory.writebyte(0x07E1, 0x11) -- H
			memory.writebyte(0x07E2, 0x1D) -- T
			memory.writebyte(0x07E3, 0x1C) -- S
		end
	end

	--]]
end



