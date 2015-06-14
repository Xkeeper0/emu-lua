require "socket.core"

startTime	= socket.gettime()

-- Use the shitty old method that was buggy
useShitMethod	= false

-- Constantly drop and climb instead of cycling. Maybe slower but steady point gain
constantScoring	= false

-- Distance to close the range of climbing
rangeShrink		= 0


function getPiecePosition()
	return {
		x			= memory.readbyte(0xAF80),
		y			= memory.readbyte(0xAF81),
		orientation	= memory.readbyte(0xAF82),
		type		= memory.readbyte(0xAF85)
		}

end


pieceTypes	= {}
-- n: name
-- x: x position pre-rotate
-- o: orientation for pre-rotate
-- Prior to actually making this I thought they might be different `w';
pieceTypes[0]	= { n	= 'I',	x	= 1,	o	= 3,	y = 0x0E }
pieceTypes[1]	= { n	= 'T',	x	= 1,	o	= 3,	y = 0x0F }
pieceTypes[2]	= { n	= 'Z',	x	= 1,	o	= 3,	y = 0x0F }
pieceTypes[3]	= { n	= 'S',	x	= 1,	o	= 3,	y = 0x0F }
pieceTypes[4]	= { n	= 'J',	x	= 1,	o	= 3,	y = 0x0F }
pieceTypes[5]	= { n	= 'L',	x	= 1,	o	= 3,	y = 0x0F }
pieceTypes[6]	= { n	= 'O',	trash	= true }



function moveToTarget()

	local piece	= getPiecePosition()
	while (pieceTypes[piece.type].trash) do
		-- print "Dumping trash";
		joypad.set(1, { down = 1 })
		frameAdvance()
		joypad.set(1, { right = 1 })
		frameAdvance()
		piece	= getPiecePosition()
	end

	while piece.orientation ~= pieceTypes[piece.type].o do
		-- print(string.format("Reorienting piece (current = %d, desired = %d)", piece.orientation, pieceTypes[piece.type].o))

		local button	= {}
		if piece.orientation == 0 then
			button.B = true
		else
			button.A = true
		end

		joypad.set(1, button)
		frameAdvance()
		joypad.set(1, {})
		frameAdvance()
		piece	= getPiecePosition()
	end	

	while piece.x ~= pieceTypes[piece.type].x do
		-- print(string.format("Repositioning piece (current = %d, desired = %d)", piece.x, pieceTypes[piece.type].x))
		joypad.set(1, { left = true })
		frameAdvance()
		joypad.set(1, {})
		frameAdvance()
		piece	= getPiecePosition()
	end	

end


function elevatePiece()

	moveToTarget()
	local piece	= getPiecePosition()
	while (piece.y > (constantScoring and (pieceTypes[piece.type].y - 1) or (0x01 + math.floor(rangeShrink / 2)))) do
		-- print(string.format("Elevating piece (current Y = %d)", piece.y))

		if (useShitMethod) then
			joypad.set(1, { A = 1 })
			frameAdvance()
			joypad.set(1, { B = 1, left = 1 })
			frameAdvance()

		else
			joypad.set(1, { A = 1 })
			frameAdvance()
			joypad.set(1, { B = 1 })
			frameAdvance()
			joypad.set(1, { left = 1 })
			frameAdvance()

		end

		piece	= getPiecePosition()

	end
end

function dropPiece()

	local piece	= getPiecePosition()
	while (piece.y < (pieceTypes[piece.type].y - math.max(0, (math.floor(rangeShrink / 2) - 1)))) do
		-- print(string.format("Dropping piece (current Y = %d)", piece.y))
		joypad.set(1, { down = 1 })
		frameAdvance()
		joypad.set(1, {})
		frameAdvance()
		piece	= getPiecePosition()
	end

end


function formatTime(t)

	local d		= math.floor(t / 86400)
	local h		= math.floor(t / 3600) % 24
	local m		= math.floor(t / 60) % 60
	local s		= math.fmod(t, 60)

	if d > 0 then
		return string.format("%2dd%02d:%02d:%05.2f", d, h, m, s)

	elseif h > 0 then
		return string.format("   %2d:%02d:%05.2f", h, m, s)

	elseif m > 0 then
		return string.format("      %2d:%05.2f", m, s)

	else
		return string.format("         %5.2f", s)

	end

end


function drawScoreBars(score)

	--local score		= getScore()
	local hundred	= score % 100
	gui.box(0, 143 - 101, 7, 143, 0x000000C0, 0x000000C0)
	gui.box(5, 142 - hundred + 1, 6, 142, "black")
	gui.box(4, 142 - hundred, 5, 142, "white")

	local thousands	= math.floor(score / 1000) % 10
	local typos		= 145
	local tysize	= 2
	local hypos		= 145
	local hysize	= 1
	for t = 1, 10 do
		typos	= 145 - t * 4
		tysize	= 2
		if thousands >= t then
			gui.box(1 + 1, typos + 1, 2 + 1, typos + tysize - 1 + 1, "black")
			gui.box(1, typos, 2, typos + tysize - 1, "white")
		else
			gui.box(1 + 1, typos + 1, 2 + 1, typos + tysize - 1 + 1, "black")
			gui.box(1, typos, 2, typos + tysize - 1, 0x444444FF)
		end


	end

	local hundreds	= math.floor(score / 100) % 10
	hypos	= typos - 1 - 10 * 2
	hysize	= 20
	gui.box(1, hypos, 2, hypos + hysize - 1, "black")
	gui.box(1 + 1, hypos + 1, 2 + 1, hypos + hysize - 1 + 1, "black")

	for t = 1, 10 do
		hypos	= typos - 1 - t * 2
		hysize	= 1
		if hundreds >= t then
			gui.box(1, hypos, 2, hypos + hysize - 1, "white") -- 0xaa88ccff) -- thanks buggy vba-rr
		else
			gui.box(1, hypos, 2, hypos + hysize - 1, 0x443366ff)
		end

	end

end


function drawTimer()

	local score		= getScore()
	local time		= finishTime and finishTime or socket.gettime()

	if not finishTime then
		drawScoreBars(score)
	end

	--gui.text(1, 0, string.format("%4.1f/s", (getScore() - startScore) / (socket.gettime() - startReal)))
	--gui.text(1, 8, string.format("%2d (%2d)", rangeShrink, rangeShrinkWait));


	gui.box(103, 135, 160, 144, 0x00000080, 0x00000000)

	local estimateD	= estimate - (time - estimatedAt)
	local estimateN	= newEstimate - (time - estimatedAt)

	if time > nextModeSwitch then
		currentModeOfs	= 18
		currentMode		= currentMode == "timer" and "estimate" or "timer"
		nextModeSwitch	= time + modeSwitchDelay[currentMode]
	end

	local topText	= formatTime(time - startTime)
	local botText	= (estimate ~= 0 and formatTime(estimateD) or "    -:--:--.--")
	--local c1		= "white"
	local ca		= 255 - math.floor((math.sin(time * math.pi * 2) + 1) * 100);
	local c1		= "white"
	local c2		= "cyan" -- 0xFFFFFFFF - (0x01000000 * math.floor(ca / 4)) - (0x00010000 * math.floor(ca / 3))

	if finishTime then
		local flasher	= math.fmod(socket.gettime(), 0.1)
		if flasher < 0.05 then
			c1		= "white"
		else
			c1		= "yellow"
		end
	end

	if currentMode == "estimate" then
		local t		= botText
		botText		= topText
		topText		= t
		local c		= c1
		c1			= c2
		c2			= c
	end

	gui.text(105, 138 + currentModeOfs, topText, 0x000000FF, 0x00000000)
	gui.text(105, 137 + currentModeOfs, topText, 0x000000FF, 0x00000000)
	gui.text(104, 138 + currentModeOfs, topText, 0x000000FF, 0x00000000)
	gui.text(104, 137 + currentModeOfs, topText, c1, 0x00000000)

	gui.text(105, 138 + 17 - currentModeOfs, botText, 0x000000FF, 0x00000000)
	gui.text(105, 137 + 17 - currentModeOfs, botText, 0x000000FF, 0x00000000)
	gui.text(104, 138 + 17 - currentModeOfs, botText, 0x000000FF, 0x00000000)
	gui.text(104, 137 + 17 - currentModeOfs, botText, c2, 0x00000000)

	if currentModeOfs > 0 then
		currentModeOfs	= math.max(0, currentModeOfs - 0.5)
	end



	if estimate ~= 0 then
		if newEstimate ~= estimate then
			--gui.text(113, 108, formatTime(estimateN), 0x000000FF, 0x00000000)
			--gui.text(112, 107, formatTime(estimateN), "white", 0x000000FF)
			local diff	= (estimate - newEstimate);
			local diffC	= diff * 0.01;
			if math.abs(diff) < 0.025 then
				estimate	= newEstimate
			else
				local dir	= (estimate > newEstimate) and -1 or 1
				estimate	= estimate + math.max(0.025, math.abs(diffC)) * dir
			end
			--gui.text(112, 117, formatTime(math.abs(diff), "white", 0x000000FF))
		end
		--gui.text(113, 128, formatTime(estimateD), 0x000000FF, 0x00000000)
		--gui.text(112, 127, formatTime(estimateD), "white", 0x000000FF)
	end

end


function getScore()

	local b1	= memory.readbyte(0xAF89)
	local b2	= memory.readbyte(0xAF8A)
	local b3	= memory.readbyte(0xAF8B)
	local b4	= memory.readbyte(0xAF8C)

	return	(math.floor(b4 / 16) * 10 + b4 % 16) * 1000000
			+ (math.floor(b3 / 16) * 10 + b3 % 16) * 10000
			+ (math.floor(b2 / 16) * 10 + b2 % 16) *   100
			+ (math.floor(b1 / 16) * 10 + b1 % 16) *     1

end


gui.register(drawTimer)


function frameAdvance()
	emu.frameadvance()
end


function calculateEstimate()

	local score				= getScore()
	local time				= socket.gettime()
	local remaining			= 9999999 - score
	--local remainingSession	= 9999999 - startScore
	local scored			= score - startScore
	local timeRan			= time - startReal
	local scoreRate			= (timerate ~= 0 and (scored / timeRan) or 0.001)
	local lestimate			= remaining / scoreRate
	local lestimatedAt		= time

	return lestimate, lestimatedAt

end


-- startTime	= socket.gettime()
-- Manually set the start time to some value in the past
startTime		= 1413319354
finishTime		= false
startReal		= socket.gettime()
startScore		= getScore()
rangeShrinkD	= 1
rangeShrinkStop	= {}
rangeShrinkStop[-1]	= 10
rangeShrinkStop[ 1]	= 60
rangeShrinkWait	= 0

modeSwitchDelay	= {
			timer		= 15,
			estimate	= 5,
		}
nextModeSwitch	= socket.gettime() + 5
currentMode		= "timer"
currentModeOfs	= 0

estimate		= 0
estimatedAt		= 0
newEstimate		= 0

while true do

	elevatePiece()
	dropPiece()

	if getScore() == 9999999 then
		finishTime		= socket.gettime()
		nextModeSwitch	= socket.gettime() + 864000
		currentMode		= "timer"
		currentModeOfs	= 0
		local state		= "losing"
		local gameOverWait	= 60 * 35 - 500
		while true do
			if state == "losing" then
				joypad.set(1, { down = 1 })
				frameAdvance()
				frameAdvance()
				if memory.readbyte(0xaf87) ~= 1 then
					state	= "waiting"
				end
			end
			if state == "waiting" then
				gameOverWait	= gameOverWait - 1
				gui.text(0, 137, string.format("%2d", gameOverWait / 60), "white", "clear")
				if gameOverWait == 0 then
					joypad.set(1, { A = 1 })
					state		= "gameover"
				end
			end
	
			emu.frameadvance()
		end
	end

	--print("Wait timer: " .. rangeShrinkWait)

	if rangeShrinkWait <= 0 then
		rangeShrink		= math.max(0, math.min(15, rangeShrink + rangeShrinkD))
		if rangeShrink == 15 or rangeShrink == 0 then
			newEstimate, estimatedAt	= calculateEstimate()
			if estimate == 0 then
				estimate	= newEstimate
			end
			rangeShrinkWait	= rangeShrinkStop[rangeShrinkD]
			rangeShrinkD	= rangeShrinkD * -1
		end
	else
		rangeShrinkWait	= rangeShrinkWait - 1
	end

end
