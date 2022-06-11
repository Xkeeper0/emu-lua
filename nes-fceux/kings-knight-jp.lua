

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
	unknown		= MemoryAddress.new(0x009b + 0, "byte", false),
	health		= MemoryAddress.new(0x009b + 1, "byte", false),	-- 12
	weapon		= MemoryAddress.new(0x009b + 2, "byte", false),	-- 3
	defense		= MemoryAddress.new(0x009b + 3, "byte", false),	-- 3
	speed		= MemoryAddress.new(0x009b + 4, "byte", false),	-- 7
	jump		= MemoryAddress.new(0x009b + 5, "byte", false),	-- 7
	elements	= MemoryAddress.new(0x009b + 6, "byte", false), -- bitfield
	}

-- Character stats for other characters are in $05ea, 7 bytes ea
for k, v in pairs(names) do
	local baseOfs = (k - 1) * 7
	charStats[v]	= MemoryCollection{
		unknown		= MemoryAddress.new(0x05ea + baseOfs + 0, "byte", false),
		health		= MemoryAddress.new(0x05ea + baseOfs + 1, "byte", false),
		weapon		= MemoryAddress.new(0x05ea + baseOfs + 2, "byte", false),
		defense		= MemoryAddress.new(0x05ea + baseOfs + 3, "byte", false),
		speed		= MemoryAddress.new(0x05ea + baseOfs + 4, "byte", false),
		jump		= MemoryAddress.new(0x05ea + baseOfs + 5, "byte", false),
		elements	= MemoryAddress.new(0x05ea + baseOfs + 6, "byte", false),
		}
end




while true do
	input.update()

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




	emu.frameadvance()
end


