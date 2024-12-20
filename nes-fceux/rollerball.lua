


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")
timer				= 0


procBase			= 0x15F

local game		= MemoryCollection {
	currentS	= MemoryAddress.new(0x007B, "byte", false),	-- screen
	ball1X		= MemoryAddress.new(0x0080, "byte", false),
	ball2X		= MemoryAddress.new(0x0081, "byte", false),
	ball1Y		= MemoryAddress.new(0x0084, "byte", false),
	ball2Y		= MemoryAddress.new(0x0085, "byte", false),
	ball1S		= MemoryAddress.new(0x0088, "byte", false),
	ball2S		= MemoryAddress.new(0x0089, "byte", false),
	bonus		= MemoryAddress.new(0x06EB, "byte", false),
	bonusMulti	= MemoryAddress.new(0x06EE, "byte", false),
	}

function getPlayerScore(player)
	local ofs = 0x312 + 8 * (player - 1)
	local score = 0
	for i = 0, 7 do
		score = score * 10 + memory.readbyte(ofs + i)
	end
	return score * 10
end


scoreAlerts		= {}
scoreAlertIdx	= 1
scoreAlertTime	= 60
scoreAlertMax	= 5
function addScoreAlert(x, y, points)
	local str	= string.format("%d", points)
	local xpos	= math.max(0, x - (string.len(str) * 3)) + 1

	local colorbg = null
	local colorsh = null
	local colorfg = "white"
	local effect = null
	if points <= 100 then
		colorfg = "white"
		colorsh = "black"
	elseif points < 1000 then
		colorfg = "#bbbbbb"
		colorbg = "black"
	elseif points < 5000 then
		colorfg = "white"
		colorbg = "black"
	elseif points < 10000 then
		colorfg = "yellow"
		colorbg = "black"
		effect = "flash"
	else
		colorfg = "white"
		colorsh = "yellow"
		colorbg = "black"
		effect = "flash"
	end

	scoreAlerts[scoreAlertIdx]	= { x = xpos, y = y, points = str, timer = 0, colorfg = colorfg, colorsh = colorsh, colorbg = colorbg, effect = effect}
	scoreAlertIdx	= (scoreAlertIdx % scoreAlertMax) + 1
end

function drawScoreAlerts()
	for i = 1, scoreAlertMax do
		if scoreAlerts[i] and scoreAlerts[i]['timer'] <= scoreAlertTime then
			if (scoreAlerts[i]['timer'] <= 20) then
				if (scoreAlerts[i]['timer'] <= 10) then
					scoreAlerts[i]['y']	= scoreAlerts[i]['y'] - 1
				end
				scoreAlerts[i]['y']	= scoreAlerts[i]['y'] - 1
			end
			scoreAlerts[i]['timer']	= scoreAlerts[i]['timer'] + 1

			if scoreAlerts[i]['colorbg'] then
				-- if there is a background...

				if scoreAlerts[i]['colorsh'] then
					-- if there's a shadow, draw the shadow and then the real text
					gui.text(scoreAlerts[i]['x'] + 1, math.max(2, scoreAlerts[i]['y']) + 1, scoreAlerts[i]['points'], scoreAlerts[i]['colorsh'], scoreAlerts[i]['colorbg'])
					gui.text(scoreAlerts[i]['x'], math.max(2, scoreAlerts[i]['y']), scoreAlerts[i]['points'], scoreAlerts[i]['colorfg'], "clear")
				else
					-- just draw the real text
					gui.text(scoreAlerts[i]['x'] + 1, math.max(2, scoreAlerts[i]['y']), scoreAlerts[i]['points'], scoreAlerts[i]['colorsh'], scoreAlerts[i]['colorbg'])
					
				end
			else
				-- no background
				if scoreAlerts[i]['colorsh'] then
					gui.text(scoreAlerts[i]['x'] + 1, math.max(2, scoreAlerts[i]['y']) + 1, scoreAlerts[i]['points'], scoreAlerts[i]['colorsh'], "clear")
				end
				gui.text(scoreAlerts[i]['x'], math.max(2, scoreAlerts[i]['y']), scoreAlerts[i]['points'], scoreAlerts[i]['colorfg'], "clear")

			end
		end
	end
end



local lastGold		= -1
local lastBonus		= -1
local lastBonusM	= -1
local lastBonusT	= 0
local lastBonusMT	= 0


while true do

	gold	= getPlayerScore(1)
	if lastBonus ~= game.bonus then
		lastBonusT = timer + 30
		lastBonus = game.bonus
	end
	if lastBonusM ~= game.bonusMulti then
		lastBonusMT = timer + 30
		lastBonusM = game.bonusMulti
	end

	local bonusBG = ((lastBonusT - timer) > 0 and ((lastBonusT - timer) % 10) < 5) and "blue" or "#000080"
	local bonusMBG = ((lastBonusMT - timer) > 0 and ((lastBonusMT - timer) % 10) < 5) and "red" or "#800000"

	gui.text(14, 25, string.format("1P %8d", gold), "white", "black")
	gui.text(14, 34, string.format(" %3dK ", game.bonus), "white", bonusBG)
	gui.text(51, 34, string.format(" x %d ", game.bonusMulti), "white", bonusMBG)


	if lastGold < gold and lastGold ~= -1 then
		addScoreAlert(game.ball1X, game.ball1Y - 16, gold - lastGold)
	end
	lastGold	= gold


	--gui.text(0, 8, string.format("%3d %3d %3d", realBallX, realBallY, game.cameraY))
	--gui.text(realBallX, screenBallY, "o")
	gui.line(game.ball1X - 2, game.ball1Y    , game.ball1X + 2, game.ball1Y    , "red")
	gui.line(game.ball1X    , game.ball1Y - 2, game.ball1X    , game.ball1Y + 2, "red")

	drawScoreAlerts()


	-- if input.held("leftclick") then
	-- 	local mousePos		= input.mouse()
	-- 	local realX, realY = relativeToReal(mousePos.x, mousePos.y)
	-- 	memory.writeword(0x15F + 0x01, realY)
	-- 	memory.writeword(0x15F + 0x03, realX)

	-- 	-- memory.writebyte(0x15F + 0x23, 0x00)
	-- 	-- memory.writebyte(0x15F + 0x26, 0x00)
	-- end


	timer = timer + 1
	input.update()
	emu.frameadvance()

end
