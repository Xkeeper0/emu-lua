

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")



local game		= MemoryCollection {
	currentStage	= MemoryAddress.new(0x00A2, "byte", false),
	}


local names = {"rayjack", "kaliva", "barusa", "toby"}
local charStats	= {}
-- Current player stats are stored at $009B
charStats['current']	= MemoryCollection{
	dead		= MemoryAddress.new(0x009b + 0, "byte", false),	-- 0:alive 1:dead
	health		= MemoryAddress.new(0x009b + 1, "byte", false),	-- max 12
	weapon		= MemoryAddress.new(0x009b + 2, "byte", false),	-- 0-3
	defense		= MemoryAddress.new(0x009b + 3, "byte", false),	-- 0-3
	speed		= MemoryAddress.new(0x009b + 4, "byte", false),	-- 0-7
	jump		= MemoryAddress.new(0x009b + 5, "byte", false),	-- 0-7
	elements	= MemoryAddress.new(0x009b + 6, "byte", false), -- bitfield (.... 4321)
	}

-- Character stats for other characters are in $05ea, 7 bytes ea
for k, v in pairs(names) do
	local baseOfs = (k - 1) * 7
	charStats[v]	= MemoryCollection{
		dead		= MemoryAddress.new(0x05ea + baseOfs + 0, "byte", false),
		health		= MemoryAddress.new(0x05ea + baseOfs + 1, "byte", false),
		weapon		= MemoryAddress.new(0x05ea + baseOfs + 2, "byte", false),
		defense		= MemoryAddress.new(0x05ea + baseOfs + 3, "byte", false),
		speed		= MemoryAddress.new(0x05ea + baseOfs + 4, "byte", false),
		jump		= MemoryAddress.new(0x05ea + baseOfs + 5, "byte", false),
		elements	= MemoryAddress.new(0x05ea + baseOfs + 6, "byte", false),
		}
end

-- 
function drawStatBar(x, y, val, max, color, bgColor)
	y = y - 1
	for i = 1, max do
		local lit = val >= i
		gui.box(x + i * 3, y, x + i * 3 + 3, y + 8, "P0F", "P0F")
		if lit then
			gui.box(x + i * 3, y + 1, x + i * 3 + 3, y + 7, (lit and (color and color or "P30") or (bgColor and bgColor or "P00")), "P0F")

		else
			gui.box(x + i * 3, y + 2, x + i * 3 + 3, y + 6, (lit and (color and color or "P30") or (bgColor and bgColor or "P00")), "P0F")
		end
	end
end

function drawElementBar(x, y, val, color, bgColor)
	y = y - 1
	-- todo: fancy colors
	

	for i = 1, 4 do
		local hasIt = AND(val, BIT(i - 1))
		gui.box(x + i * 3, y, x + i * 3 + 3, y + 8, (hasIt ~= 0 and (color and color or "P30") or (bgColor and bgColor or "P00")), "P0F")
	end
end

function drawCharacterStats(x, y, character)

	-- name   hp xxxxxxxxxxxx
	-- at xxx  sp xxxxxxx
	-- df xxx  jm xxxxxxx


	gui.text(x     , y     , string.format("HP %2d     : * ", character.health) , (character.dead == 0 and "P30" or "P26"), "P0F")
	gui.text(x     , y +  8, string.format("AT %d    \nDF %d    ", character.weapon, character.defense), "P10", "P0F")
	gui.text(x + 40, y +  8, string.format("SP %d\nJM %d", character.speed, character.jump), "P10", "P0F")
	
	drawStatBar(x + 27, y +  0, character.health, 12, "P37", "P07")

	drawElementBar(x + 70, y +  0, character.elements, "P30", "P00")

	drawStatBar(x + 21, y +  8, character.weapon, 3, "P35", "P05")
	drawStatBar(x + 21, y + 16, character.defense, 3, "P32", "P02")

	drawStatBar(x + 61, y +  8, character.speed, 7, "P29", "P09")
	drawStatBar(x + 61, y + 16, character.jump, 7, "P23", "P03")

end



---
--   DF |||
--   AT |::



currentSoundEffect = nil
lastSoundEffect = 0
lastMusic = 0
function hijackSoundEffect()
	lastSoundEffect = memory.getregister("a")
	print(string.format("called sfx %02x", lastSoundEffect))
	-- if setting sounds, overwrite it
	if currentSoundEffect then
		memory.setregister("a", currentSoundEffect)
		print(string.format("overwrote sfx with %02x", currentSoundEffect))
	end
end
memory.registerexec(0xB17E, hijackSoundEffect)

function hijackMusic()
	lastMusic = memory.getregister("a")
	print(string.format("called music %02x", lastMusic))
	-- if setting sounds, overwrite it
	-- if currentSoundEffect then
	-- 	memory.setregister("a", currentSoundEffect)
	-- 	print(string.format("overwrote sfx with %02x", currentSoundEffect))
	-- end
end
memory.registerexec(0xBCFD, hijackMusic)


while true do
	input.update()

	
	if input.pressed("Y") then
		-- if [null], then 0
		-- otherwise, increment + rollover protect
		-- yes, it's stupid
		currentSoundEffect = (currentSoundEffect and ((currentSoundEffect + 1) % 0x100) or 0)
	elseif input.pressed("U") then
		currentSoundEffect = (currentSoundEffect and ((0x100 + (currentSoundEffect - 1)) % 0x100) or 0)
	elseif input.pressed("H") then
		currentSoundEffect = nil
	end

	if currentSoundEffect then
		gui.text(180, 212, string.format("SFX: %02X", currentSoundEffect))
	end
	gui.text(180, 220, string.format("Last SFX %02X", lastSoundEffect))
	gui.text(180, 228, string.format("Last MUS %02X", lastMusic))


	-- gui.text(125, 120, string.format("%02X", memory.readbyte(0x0078)))


	--[[
	for k, v in pairs(names) do
		local xP	= 50 * (k - 1)
		gui.text(0 + xP, 10, string.format("%s\ndead %d\nHP %2d/12\nWP %d/3\nDF %d/3\nSP %d/7\nJP %d/7\nE %X",
			v,
			charStats[v].unknown,
			charStats[v].health,
			charStats[v].weapon,
			charStats[v].defense,
			charStats[v].speed,
			charStats[v].jump,
			charStats[v].elements
			))
	end
	--]]

	-- gui.text(42, 5, string.format("%2d", charStats.current.health))
	-- drawStatBar(50, 5, charStats.current.health, 12, "P32")

	-- for i = 3, 7 do
	-- 	drawStatBar(10, 8 * i, 5, i, "P32")
	-- end
	
	for k, v in pairs(names) do
		drawCharacterStats(1, 1 + (k - 1) * 25, charStats[v])
		
	end		
	drawCharacterStats(170, 1, charStats.current)
	emu.frameadvance()
end


