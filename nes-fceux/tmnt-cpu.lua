

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

--[[

	future notes:
	04:B9AF: possibly related to spawning fixed-position items
	(i.e. not randomly placed enemies, but the pre-set pizzas and pickups)

	memory.registerexec(0xb9af) -> writebyte(0x0002, desired_spawn_thing)

	00	despawns
	01	full pizza
	02	half pizza
	03	quarter pizza
	04	???
	05	shuriken pickup
	06	triple stars pickup
	07	boomerang pickup
	08	scroll
	09	?
	0a	?
	0b	turtle head pickup, invuln
	0c	missile pickup
	0d	rope pickup
	0e	?????????????????????????????
	...

--]]

spawnID	= 1
function spawnThing()
	memory.writebyte(0x02, spawnID)
end
memory.registerexec(0xb9a6, spawnThing)


count = {}

function registercount(addr)
	count[addr]	= (count[addr] or 0) + 1
end

memory.registerexec(0x800E, registercount)
memory.registerexec(0x8030, registercount)
memory.registerexec(0xC3A0, registercount)


local turtles	= MemoryCollection{
	current		= MemoryAddress.new(0x0067, "byte", false),
	health0		= MemoryAddress.new(0x0077, "byte", false),
	health1		= MemoryAddress.new(0x0078, "byte", false),
	health2		= MemoryAddress.new(0x0079, "byte", false),
	health3		= MemoryAddress.new(0x007a, "byte", false),
	}


local test		= turtles['bogus']

local camera	= MemoryCollection {
	xLo			= MemoryAddress.new(0x00fd, "byte", false),
	xHi			= MemoryAddress.new(0x0050, "byte", false),
	y			= MemoryAddress.new(0x0051, "word", false),
	}

local game		= MemoryCollection {
	currentArea		= MemoryAddress.new(0x0048, "byte", false),
	currentSubArea	= MemoryAddress.new(0x005d, "byte", false),
	enemySet		= MemoryAddress.new(0x0604, "byte", false),
	enemySetRank			= MemoryAddress.new(0x0614, "byte", false),
	slowTimer		= MemoryAddress.new(0x009d, "word", false),
	frameTimer		= MemoryAddress.new(0x001e, "byte", false),
	}

local scores		= MemoryCollection {
	scoreLo			= MemoryAddress.new(0x00C2, "byte", false),
	scoreMed		= MemoryAddress.new(0x00C3, "byte", false),
	scoreHi			= MemoryAddress.new(0x00C4, "byte", false),
	areaScoreLo		= MemoryAddress.new(0x00C5, "byte", false),
	areaScoreMed		= MemoryAddress.new(0x00C6, "byte", false),
	areaScoreHi		= MemoryAddress.new(0x00C7, "byte", false),
	highScoreLo		= MemoryAddress.new(0x00C8, "byte", false),
	highScoreMed	= MemoryAddress.new(0x00C9, "byte", false),
	highScoreHi		= MemoryAddress.new(0x00CA, "byte", false),
	}
		
	
objects			= {}
objectHealth	= {}
for i = 0, 0xF do
	objects[i]		= MemoryCollection {
		id					= MemoryAddress.new(0x0400 + i, "byte", false),
		idCounter			= MemoryAddress.new(0x0410 + i, "byte", false),
		timer				= MemoryAddress.new(0x0420 + i, "byte", false),
		hitAnimation		= MemoryAddress.new(0x0430 + i, "byte", false),
		characteristics1	= MemoryAddress.new(0x0440 + i, "byte", false),
		characteristics2	= MemoryAddress.new(0x0450 + i, "byte", false),
		y					= MemoryAddress.new(0x0460 + i, "byte", false),
		ySubpixel			= MemoryAddress.new(0x0470 + i, "byte", false),
		x					= MemoryAddress.new(0x0480 + i, "byte", false),
		xSubpixel			= MemoryAddress.new(0x0490 + i, "byte", false),
		u4a0				= MemoryAddress.new(0x04a0 + i, "byte", false),
		ySpeed				= MemoryAddress.new(0x04b0 + i, "byte", false),
		ySpeedSubpixel		= MemoryAddress.new(0x04c0 + i, "byte", false),
		u4d0				= MemoryAddress.new(0x04d0 + i, "byte", false),
		xSpeed				= MemoryAddress.new(0x04e0 + i, "byte", false),
		xSpeedSubpixel		= MemoryAddress.new(0x04f0 + i, "byte", false),

		invulnTimer			= MemoryAddress.new(0x0500 + i, "byte", false),
		u510				= MemoryAddress.new(0x0510 + i, "byte", false),
		u520				= MemoryAddress.new(0x0520 + i, "byte", false),
		u530				= MemoryAddress.new(0x0530 + i, "byte", false),
		u540				= MemoryAddress.new(0x0540 + i, "byte", false),
		u550				= MemoryAddress.new(0x0550 + i, "byte", false),
		health				= MemoryAddress.new(0x0560 + i, "byte", false),
		behaviorID			= MemoryAddress.new(0x0570 + i, "byte", false),
	}

	objectHealth[i]			= 0
end



function drawObjects()
	local cameraX	= camera.xHi * 0x100 + camera.xLo
	local cameraY	= camera.y
	local objX, objY = 0

	local full		= false
	local mouse		= input.mouse()
	if mouse.x < 30 then
		full		= true
	end


	for i = 0, 0xF do
		if objects[i].behaviorID ~= 0 or objects[i].characteristics1 ~= 0 or objects[i].id ~= 0 then
			objX	= objects[i].x
			objY	= objects[i].y
			if full then
				gui.text(  1,  20 + 8 * i, string.format("%X %2X %2d", i, objects[i].characteristics1, objects[i].health), "white", "black")
			else
				gui.text(  1,  20 + 8 * i, string.format("%X %2X", i, objects[i].characteristics1), "white", "black")

			end
			gui.line(objX - 4, objY    , objX + 4, objY    , 'white')
			gui.line(objX    , objY - 4, objX    , objY + 4, 'white')
			gui.text(objX + 2, objY + 2, string.format('%X', i), "white", "black")
			
			local objHealth	= objects[i].health
			if objHealth > 0 and objHealth ~= 0xFF then
				if objectHealth[i] == 0 then
					objectHealth[i]	= objHealth
				end
				drawBar(objX + 3, objY - 5, math.min(objectHealth[i], 20), 2, 0, objectHealth[i], objHealth, "P38", "P20", "P01", "black")
			else
				objectHealth[i]	= 0
			end

		else
			gui.text(  1,  20 + 8 * i, string.format("%X", i), "P01", "black")
			objectHealth[i]	= 0


		end

	end


end



function drawScoreInfo()
	local score		= tonumber(string.format("%02X%02X%02X0", scores.scoreHi, scores.scoreMed, scores.scoreLo), 10) or 0
	local highScore	= tonumber(string.format("%02X%02X%02X0", scores.highScoreHi, scores.highScoreMed, scores.highScoreLo), 10) or 0
	-- local areaScore	= tonumber(string.format("%02X%02X%02X0", scores.areaScoreHi, scores.areaScoreMed, scores.areaScoreLo), 10) or 0
	local areaScore	= tonumber(string.format("%02X%02X%02X0", 0 --[[scores.areaScoreHi]], scores.areaScoreMed, scores.areaScoreLo), 10) or 0


	gui.box( 8, 200, 90, 223, "black", "black")
	gui.text(8, 200, string.format("HS%7d\nSC%7d\nAR%7d", highScore, score, areaScore), "white", "clear")
	local diffShowTime = 60
	local diffFadeTime = 6
	if scoreHistory.score.score ~= score then
		scoreHistory.score.change	= score - scoreHistory.score.score
		scoreHistory.score.score	= score
		scoreHistory.score.time		= timer
	end
	if scoreHistory.highScore.score ~= highScore then
		scoreHistory.highScore.change	= highScore - scoreHistory.highScore.score
		scoreHistory.highScore.score	= highScore
		scoreHistory.highScore.time		= timer
	end
	if scoreHistory.areaScore.score ~= areaScore then
		scoreHistory.areaScore.change	= areaScore - scoreHistory.areaScore.score
		scoreHistory.areaScore.score	= areaScore
		scoreHistory.areaScore.time		= timer
	end
	if (scoreHistory.score.time) >= timer - diffShowTime then
		gui.text(64, 208, string.format("%+5d", scoreHistory.score.change), (scoreHistory.score.change > 0 and "green" or "red"), (scoreHistory.score.time >= timer - diffFadeTime) and "P00" or "black")
	end
	if (scoreHistory.highScore.time) >= timer - diffShowTime then
		gui.text(64, 200, string.format("%+5d", scoreHistory.highScore.change), (scoreHistory.highScore.change > 0 and "green" or "red"), (scoreHistory.highScore.time >= timer - diffFadeTime) and "P00" or "black")
	end
	if (scoreHistory.areaScore.time) >= timer - diffShowTime then
		gui.text(64, 216, string.format("%+5d", scoreHistory.areaScore.change), (scoreHistory.areaScore.change > 0 and "green" or "red"), (scoreHistory.areaScore.time >= timer - diffFadeTime) and "P00" or "black")
	end
end


function drawPlayerHealth()
	if turtles.current < 4 then
		drawBar(95, 201, 64, 5, 0, 127, turtles["health" .. turtles.current], "P16", "P20", "P01", "P0F")
		gui.text(142, 208, string.format("%3d", turtles["health" .. turtles.current]), "P01", "clear")
		gui.text(143, 207, string.format("%3d", turtles["health" .. turtles.current]), "P01", "clear")
		gui.text(143, 209, string.format("%3d", turtles["health" .. turtles.current]), "P01", "clear")
		gui.text(144, 208, string.format("%3d", turtles["health" .. turtles.current]), "P01", "clear")
		gui.text(144, 209, string.format("%3d", turtles["health" .. turtles.current]), "P01", "clear")
		gui.text(143, 208, string.format("%3d", turtles["health" .. turtles.current]), "white", "clear")
	end
end




enemyRank1	= nil
enemyRank2	= nil
function monitorRankCalculation1()
	enemyRank1	= memory.readbyte(0x0002)
	print(string.format("rank calc 1: %02X\r\n", enemyRank1))
end
function monitorRankCalculation2()
	enemyRank2	= memory.readbyte(0x0000)
	print(string.format("rank calc 2: %02X\r\n", enemyRank2))
end
function monitorRankCalculationReset()
	enemyRank2	= nil
	print(string.format("rank calc 1: reset\r\n"))
end

memory.registerexec(0x8196, monitorRankCalculation1)
memory.registerexec(0x819A, monitorRankCalculationReset)
memory.registerexec(0x81C5, monitorRankCalculation2)


scoreHistory = {
	score = { score = 0, change = 0, time = -10000 },
	areaScore = { score = 0, change = 0, time = -10000 },
	highScore = { score = 0, change = 0, time = -10000 }
	}


timer = 0
while true do

	-- if false and (timer % 10) == 0 then
	-- 	-- cycle the first palette color for fun
	-- 	local paltmp = memory.readbyte(0x5A1)
	-- 	local palbig = math.floor(paltmp / 0x10)
	-- 	local palsmol = (paltmp % 0x10)
	-- 	memory.writebyte(0x02B, 1)				-- set palette update request
	-- 	memory.writebyte(0x5A1, (palbig * 0x10 + ((palsmol % 0xC) + 1)))
	-- end
	


	drawBar(33,  2, 100, 5, 0, 2000, (count[0x800E] or 0), "red", "white", "black", "#bbbbbb", "black")
	if count[0x8030] then
		gui.text(2, 2, string.format("%5d", (count[0x8030] or 0)), "white", "#008000")
		drawBar(33,  5, 100, 2, 0, 2000, (count[0x8030] or 0), "green", "white", "black")
		-- drawBar(33,  2, 100, 5, 0, 2000, (count[0x8030] or 0), "green", "white", "black", "#bbbbbb", "black")
	else
		gui.text(2, 2, string.format("%5d", (count[0x800E] or 0)), "white", "#800000")
		-- drawBar(33,  2, 100, 5, 0, 2000, (count[0x800E] or 0), "red", "white", "black", "#bbbbbb", "black")
	end
	
	-- 1351: fully idle, nmi bails immediately ($1F = FF)
	-- 1327: nmi runs nmi / scroll update only ($1F = 01)
	-- 1115: intro copyright screen normally
	gui.text(1, 232, string.format("%4d", (count[0xC3A0] or 0)), "white", "#000050")
	drawBar(27, 233, 100, 4, 0, 1115, (count[0xC3A0] or 0), "P12", "P32", "black", "P02", "black")
	
	
	
	drawObjects()

	gui.text(180,  1, string.format("Area %d-%02d (%02X)", game.currentArea, game.currentSubArea, game.currentSubArea))
	gui.text(183,  9, string.format("EnSet %02X Rn%02X", game.enemySet, game.enemySetRank))

	gui.text(217, 17, string.format("%04X:%02X", game.slowTimer, game.frameTimer))

	--[[
	if (enemyRank1 ~= nil and enemyRank2 ~= nil) then
		gui.text(201, 33, string.format("Rank\n%2X+%2X", enemyRank1, enemyRank2))
	elseif (enemyRank1 ~= nil) then
		gui.text(201, 33, string.format("Rank\n%2X+??", enemyRank1))
	else
		gui.text(201, 33, string.format("Rank\n??+??"))
	end
	--]]

	if input.pressed("Y") then
		spawnID	= spawnID - 1
	elseif input.pressed("U") then
		spawnID = spawnID + 1
	end
	gui.text(150, 50, string.format("%02X", spawnID))

	drawScoreInfo()

	drawPlayerHealth()

	count = {}
	timer = timer + 1

	input.update()
	emu.frameadvance()
end
