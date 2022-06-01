-- Survival Kids

-- http://tasvideos.org/GameResources/GBx/SurvivalKids.html
-- mugg's lua stuff: https://pastebin.com/mUkJVFse
-- http://tasvideos.org/forum/viewtopic.php?p=405567#405567




-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


-- "F" values are fractional (0~255)
local world		= MemoryCollection{
	day			= MemoryAddress.new(0xCB9C, "byte", false),
	ticks		= MemoryAddress.new(0xC19D, "word", false),
	}

local player	= MemoryCollection{
	--x			= MemoryAddress.new(0xFFB5, "word", false),
	--x2			= MemoryAddress.new(0xFFB9, "word", false),

	life		= MemoryAddress.new(0xC5EE, "byte", false),
	hunger		= MemoryAddress.new(0xC5EF, "word", false),
	water		= MemoryAddress.new(0xC5F1, "word", false),
	fatigue		= MemoryAddress.new(0xC5F3, "word", false),
	-- hungerF		= MemoryAddress.new(0xC5EF, "byte", false),
	-- waterF		= MemoryAddress.new(0xC5F1, "byte", false),
	-- fatigueF	= MemoryAddress.new(0xC5F3, "byte", false),
	}




function drawHUD()
	gui.box(    0,  137, 160, 145, "white")
	gui.text(   5,  137, string.format("L %3d%%", player.life))
	gui.text(  35,  137, string.format("H %5.2f%%", player.hunger / 256))
	gui.text(  80,  137, string.format("W %5.2f%%", player.water / 256))
	gui.text( 120,  137, string.format("F %5.2f%%", player.fatigue / 256))


	-- 960 "ticks" per day
	-- "phase" = high byte of tick counter (0-3)
	-- phases correspond to day/night cycle:
	-- 0 = morning, 1 = day, 2 = evening, 3 = night
	-- every phase except "night" is 256 ticks;
	-- the "night" phase is shorter than the rest (192 ticks)
	
	-- 86400 seconds / 960 ticks = 90 seconds per tick

	local phase = math.floor(world.ticks / 0x100)
	local seconds = world.ticks * 90
	local hours = math.floor(seconds / 3600) 
	local minutes = math.mod(math.floor(seconds / 60), 60)
	local tickMax = (phase == 3 and 191 or 255) - (world.ticks % 256)
	gui.text( 140,    1, string.format("%02d:%02d\n%d %3d", hours, minutes, phase, tickMax))


end

gui.register(drawHUD)

while true do




	emu.frameadvance()
end