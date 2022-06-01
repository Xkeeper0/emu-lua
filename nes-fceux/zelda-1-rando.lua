
-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

-- There's no technical need for these to be separate collections,
-- it's just a little more organized that way i guess

zelda			= {}

zelda.game		= MemoryCollection{
	mode		= MemoryAddress.new(0x0012, "byte", false),
	routine		= MemoryAddress.new(0x0013, "byte", false),

	framecount	= MemoryAddress.new(0x0015, "byte", false),

	saveSlot	= MemoryAddress.new(0x0016, "byte", false),

	timer		= MemoryAddress.new(0x0029, "byte", false),


	scrollV		= MemoryAddress.new(0x005C, "byte", false),

	dungeonFloorItem		= MemoryAddress.new(0x0097, "byte", false),

	paused		= MemoryAddress.new(0x00e0, "byte", false),
	itemMenuScroll	= MemoryAddress.new(0x00e1, "byte", false),
	scrolling	= MemoryAddress.new(0x00e8, "byte", false),
	
	}

zelda.player	= MemoryCollection{
	screen		= MemoryAddress.new(0x00eb, "byte", false),	-- current screen we're on
	screenNext	= MemoryAddress.new(0x00ec, "byte", false),
	screenOverworld	= MemoryAddress.new(0x0526, "byte", false),	-- what screen we'reon on theoverworld

	enemyKillCount	= MemoryAddress.new(0x052a, "byte", false),	-- 0~9 enemies killed
	enemyKillCountScreen	= MemoryAddress.new(0x0627, "byte", false),	-- "Number of killed enemies in current screen"
	
	swordDisabled	= MemoryAddress.new(0x052e, "byte", false), -- 0:no 1:red bubble disabled
	
	candleUsed	= MemoryAddress.new(0x0513, "byte", false), -- 0:no 1:candle used on screen

	sword			= MemoryAddress.new(0x0657, "byte", false),	-- 0:none 1:wooden 2:white 3:magical
	arrows			= MemoryAddress.new(0x0659, "byte", false),	-- 0:none 1:wooden 2:silver
	bombs			= MemoryAddress.new(0x0658, "byte", false),	-- quantity
	candle			= MemoryAddress.new(0x065b, "byte", false), -- 0:none 1:blue 2:red
	whistle			= MemoryAddress.new(0x065c, "byte", false),	-- 0:no 1:yes
	bait			= MemoryAddress.new(0x065d, "byte", false),	-- 0:no 1:yes
	potion			= MemoryAddress.new(0x065e, "byte", false),	-- 0:no 1:blue 2:red   (0:letter)
	magicalRod		= MemoryAddress.new(0x065f, "byte", false),	-- 0:no 1:yes
	raft			= MemoryAddress.new(0x0660, "byte", false),	-- 0:no 1:yes
	book			= MemoryAddress.new(0x0661, "byte", false),	-- 0:no 1:yes
	ring			= MemoryAddress.new(0x0662, "byte", false),	-- 0:no 1:blue 2:red
	stepladder		= MemoryAddress.new(0x0663, "byte", false),	-- 0:no 1:yes
	magicalKey		= MemoryAddress.new(0x0664, "byte", false),	-- 0:no 1:yes
	powerBracelet	= MemoryAddress.new(0x0665, "byte", false),	-- 0:no 1:yes
	letter			= MemoryAddress.new(0x0666, "byte", false),	-- 0:no 1:yes 2:shown to woman

	-- maybe consider doing something special for these
	compassFlagsA	= MemoryAddress.new(0x0667, "byte", false),	-- 87654321 bit flags
	mapFlagsA		= MemoryAddress.new(0x0668, "byte", false),	-- 87654321 bit flags
	compassFlagsB	= MemoryAddress.new(0x0669, "byte", false),	-- .......9 bit flags
	mapFlagsB		= MemoryAddress.new(0x066A, "byte", false),	-- .......9 bit flags

}

while true do

	local i = 0
	for k,v in pairs(zelda.game._m) do
		gui.text(1, 8 * i + 1, string.format("%02X %s", zelda.game[k], k))
		i = i + 1
	end

	i = i + 1
	for k,v in pairs(zelda.player._m) do
		gui.text(1, 8 * i + 1, string.format("%02X %s", zelda.player[k], k))
		i = i + 1
	end
	-- gui.text( 1, 1, "Hello world" )
	emu.frameadvance()

end