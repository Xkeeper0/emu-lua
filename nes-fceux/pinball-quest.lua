


require("libs/toolkit")
require("libs/functions")
require("pinball-quest-data")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")
timer				= 0


procBase			= 0x15F

local game		= MemoryCollection {
	ballX		= MemoryAddress.new(0x0062, "word", false),
	ballY		= MemoryAddress.new(0x0060, "word", false),
	cameraX		= MemoryAddress.new(0x008D, "byte", false),
	cameraY		= MemoryAddress.new(0x008E, "byte", false),
	}

--[[

	proc memory layout:

	00	status flags, maybe?
	01w	Y position (+0x1000)
	03w	X position (+0x1000)

	0B	Y hitbox size (downwards)
	0C	X hitbox size (rightwards)

	20	hit points(?)

	21	three-byte y speed. negative = highest bit set
	24	three-byte x speed


--]]




callsTo0000			= {}
callsTo0000Count	= 0
function trackCallsTo0000(addr)
	local addr						= memory.readword(0x0003)
	local index						= memory.readbyte(addr)
	local target					= memory.readword(0xC100 + index * 2)
	local bank						= memory.readbyte(0xBFF9)	-- currently loaded bank. honk
	local o0092						= (memory.readword(0x0092) - procBase) / 0x30
	target	= routines[index] or string.format("%2X undefined", index)
	callsTo0000Count				= callsTo0000Count + 1
	callsTo0000[callsTo0000Count]	= { bank = bank, addr = addr, index = index, target = target, o0092 = o0092 }
end


function drawCallsTo0000()
	local last0092	= nil
	local colorN	= 0
	local colorT	= {}
	colorT[0]		= "darkblue"
	colorT[1]		= "black"
	for i = 1, callsTo0000Count do
		if callsTo0000[i]['o0092'] ~= last0092 then
			colorN = 1 - colorN
		end
		last0092	= callsTo0000[i]['o0092']
		gui.text(0, 8 * (i - 1), string.format("[%2X] %X:%04X > %s", callsTo0000[i]['o0092'], callsTo0000[i]['bank'], callsTo0000[i]['addr'], callsTo0000[i]['target']), "white", colorT[colorN])
	end
	callsTo0000Count	= 0
	callsTo0000			= {}
end

memory.registerexec(0x0000, trackCallsTo0000)



function drawProc(proc)
	local baseAddr	= 0x15F + proc * 0x30
	local str		= ""
	for i = 0, 0x2F do
		if (i % 0x08) == 0 then
			str		= str .. string.format("\n %02X |", i)
		end
		str			= str .. string.format(" %02X", memory.readbyte(baseAddr + i))
	end

	gui.text(0, 0, string.format("%02X [$%04X]:%s", proc, baseAddr, str))

end


function drawProcPositions()


	for i = 0, 0x1B do
		local baseAddr	= 0x15F + i * 0x30
		if memory.readbyte(baseAddr) ~= 0 then
			
			local posTLX, posTLY = realToRelative(memory.readword(baseAddr + 3), memory.readword(baseAddr + 1))
			local posBRX, posBRY = realToRelative(memory.readword(baseAddr + 3) + memory.readbyte(baseAddr + 0x0C), memory.readword(baseAddr + 1) + memory.readbyte(baseAddr + 0x0B))
			gui.box(posTLX, posTLY, posBRX, posBRY, "clear", "red")
			
			
			drawInGamePosition(
				memory.readword(baseAddr + 3),
				memory.readword(baseAddr + 1),
				memory.readbyte(baseAddr + 0) ~= 0 and "white" or "gray",
				string.format("%X", i)
			)
			
		end

	end
end


function realToRelative(x, y)
	local relX	= math.max(0, math.min(255, (x - 0x1000) - game.cameraX))
	local relY	= math.max(0, math.min(240, (y - 0x1000) - game.cameraY))
	return relX, relY
end

function relativeToReal(x, y)
	local realX	= x + 0x1000 + game.cameraX
	local realY = y + 0x1000 + game.cameraY
	return realX, realY
end


function drawInGamePosition(x, y, color, text)
	local relX	= math.max(0, math.min(255, (x - 0x1000) - game.cameraX))
	local relY	= math.max(0, math.min(240, (y - 0x1000) - game.cameraY))
	local color	= color and color or "red"

	gui.line(relX - 2, relY    , relX + 2, relY    , color)
	gui.line(relX    , relY - 2, relX    , relY + 2, color)
	if text then
		gui.text(relX + 2, relY - 8, text, color, "black")
	end

end




scoreAlerts		= {}
scoreAlertIdx	= 1
scoreAlertTime	= 60
function addScoreAlert(x, y, points)
	local str	= string.format("%d", points)
	local xpos	= math.max(0, x - (string.len(str) * 3)) + 1
	scoreAlerts[scoreAlertIdx]	= { x = xpos, y = y, points = str, timer = 0}
	scoreAlertIdx	= (scoreAlertIdx % 3) + 1
end

function drawScoreAlerts()
	for i = 1, 3 do
		if scoreAlerts[i] and scoreAlerts[i]['timer'] <= scoreAlertTime then
			if (scoreAlerts[i]['timer'] <= 20) then
				if (scoreAlerts[i]['timer'] <= 10) then
					scoreAlerts[i]['y']	= scoreAlerts[i]['y'] - 1
				end
				scoreAlerts[i]['y']	= scoreAlerts[i]['y'] - 1
			end
			scoreAlerts[i]['timer']	= scoreAlerts[i]['timer'] + 1

			local screenY	= math.min(math.max(1, scoreAlerts[i]['y'] - game.cameraY), 220)
			gui.text(scoreAlerts[i]['x'], screenY, scoreAlerts[i]['points'], "white", "black")

		end
	end
end



local lastGold		= -1
local show0000		= false
local showTimers	= false
local monitoredProc	= -1

while true do

	if input.pressed("O") then
		show0000	= not show0000
	end

	if input.pressed("T") then
		monitoredProc	= math.max(-1, monitoredProc - 1)
	end
	if input.pressed("Y") then
		monitoredProc	= math.min(0x1B, monitoredProc + 1)
	end


	gold	= (memory.readbyte(0x0084) * 0x10000 + memory.readbyte(0x0083) * 0x100 + memory.readbyte(0x0082)) * 10
	gui.text(19, 233, string.format("G   %6d", gold), "white", "black")


	realBallX	= game.ballX - 0x1000
	realBallY	= game.ballY - 0x1000
	screenBallX	= realBallX - game.cameraX
	screenBallY	= realBallY - game.cameraY

	if lastGold < gold and lastGold ~= -1 then
		addScoreAlert(realBallX, realBallY - 16, gold - lastGold)
	end
	lastGold	= gold


	--gui.text(0, 8, string.format("%3d %3d %3d", realBallX, realBallY, game.cameraY))
	--gui.text(realBallX, screenBallY, "o")
	gui.line(screenBallX - 2, screenBallY    , screenBallX + 2, screenBallY    , "red")
	gui.line(screenBallX    , screenBallY - 2, screenBallX    , screenBallY + 2, "red")

	drawScoreAlerts()

	if show0000 then
		drawCallsTo0000()
	else
		-- drawProcPositions()
	end

	if monitoredProc >= 0 then
		drawProc(monitoredProc)
	end
	
	--	relOffset	= memory.readword(0x0092)
	--	gui.text(232, 0, string.format("%04X", relOffset), "white", "black")

	if showTimers then
		for i = 0, 0xF do
			local tmp = memory.readbyte(0x00A7 + i)
			gui.text(227, 8 + 8 * i, string.format("%2d    ", tmp), "white", "black")
			gui.line(239 + i+1, 9 + 8 * i, 239 + i+1, 14 + 8 * i, "#008000")
			gui.line(239 + tmp, 9 + 8 * i, 239 + tmp, 14 + 8 * i, "green")
		end
	end


	if input.held("leftclick") then
		local mousePos		= input.mouse()
		local realX, realY = relativeToReal(mousePos.x, mousePos.y)
		memory.writeword(0x15F + 0x01, realY)
		memory.writeword(0x15F + 0x03, realX)

		-- memory.writebyte(0x15F + 0x23, 0x00)
		-- memory.writebyte(0x15F + 0x26, 0x00)
	end


	timer = timer + 1
	input.update()
	emu.frameadvance()

end
