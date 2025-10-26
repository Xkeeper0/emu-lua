-- mighty bomb jack

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

-- enemy struct in memory
-- 0x1C bytes
-- + 0	status (01 = active, 08 sets back to 01?)
-- + 4  X velocity
-- + 5  X position (screen)
-- + A  Y velocity
-- + B  Y position (screen)
-- + E  sprite?
-- +10  animation offset?
-- +13	type
-- 
-- status:
-- 01 active
-- 02
-- 04
-- 08
-- 10
-- 20 collectible?
-- 40
-- 80 fucking dead (player)


soundsList = {
	{ 0x01, "Jump" },
	{ 0x03, "BonusCoinSpawn" },
	{ 0x04, "CoinCollected" },
	{ 0x07, "BombCollectedUnlit" },
	{ 0x08, "BombCollectedLit" },
	{ 0x0A, "1UP_Captive" },
	{ 0x0B, "CrystalBall" },
	{ 0x0D, "BonusStatueCollected" },
	{ 0x0E, "SecretBlockRevealed" },
	{ 0x0F, "Door" },
	{ 0x19, "BombChestBonus" },
	{ 0x1B, "Pause" },
	{ 0x1C, "Unpause" },
	{ 0x1D, "UsedMightyCoin" },
	{ 0x20, "BombBonus" },
	{ 0x21, "TimePickup" },
	}

musicList = {
	{ 0x00, "Silence" },
	{ 0x10, "Main" },
	{ 0x11, "TreasureRoom" },
	{ 0x12, "SideRoom" },
	{ 0x13, "Labyrinth" },
	{ 0x15, "Outside1" },
	{ 0x16, "MainWithIntro" },
	{ 0x17, "GameOver" },
	{ 0x18, "RoundClear" },
	{ 0x1E, "Outside2" },
	{ 0x1F, "TortureRoom" },
	{ 0x22, "Ending" },
	{ 0x23, "CollectedFullFamily" },
	{ 0x05, "PowerCoinSpawn" },
	{ 0x06, "PowerCoinMusic" },
	{ 0x09, "YouAreGreedy" },
	{ 0x02, "Death" },
	{ 0x1A, "1A" },
	}

function jukebox()
	local bx = 20
	local by = 150
	local bc = 0
	for i, v in pairs(musicList) do
		local btn = button(bx + bc * 7, by, 6, 6, "white", "red")
		if btn == -1 then
			gui.text(bx, by - 10, string.format("%02X %s", v[1], v[2]))
		elseif btn == true then
			memory.writebyte(0x432, 0x01)
			memory.writebyte(0x433, v[1])
		end
		bc = bc + 1
	end

	bc = 0
	for i, v in pairs(soundsList) do
		local btn = button(bx + bc * 7, by + 8, 6, 6, "gray", "red")
		if btn == -1 then
			gui.text(bx, by - 10, string.format("%02X %s", v[1], v[2]))
		elseif btn == true then
			memory.writebyte(0x432, 0x01)
			memory.writebyte(0x433, v[1])
		end
		bc = bc + 1
	end
end

--[[
function sub8D99()
	local dividend = memory.readbyte(0x028) + memory.readbyte(0x029) * 0x100
	local divisor = memory.readbyte(0x02a)
	print(string.format("%04X: %04X %% %02X (%5d %% %3d) = %d", getReturnAddress(), dividend, divisor, dividend, divisor, dividend % divisor))
end
function sub_8D99_end()
	print(string.format("  --> %d", memory.readbyte(0x2b)))
end
memory.registerexec(0x8D99, sub8D99)
memory.registerexec(0x8DC6, sub_8D99_end)
--]]


function calculateGDV()
	local gdvmem	= memory.readbyte(0x039B) -- bcd
	local gdv		= math.floor(gdvmem / 0x10) + (gdvmem % 0x10)

end


function showSoundEngine()

	local musOfs = 0x452
	-- size: 0x18 x 8local enemySize = 0x18

	local chOfs	= 0
	for ch = 0, 7 do
		chOfs = musOfs + ch * 0x18
		local active	= memory.readbyte(chOfs + 0x00)
		local delay		= memory.readbyte(chOfs + 0x01)
		local delayBase	= memory.readbyte(chOfs + 0x02)
		local offset	= memory.readword(chOfs + 0x03) -- w
		local volPtr	= memory.readword(chOfs + 0x05) -- w
		local volOfs	= memory.readbyte(chOfs + 0x07) -- w
		-- 08
		local offset2	= memory.readword(chOfs + 0x09) -- w
		-- 0B, 0C
		local volShift	= memory.readbyte(chOfs + 0x0D)
		local volDelay	= memory.readbyte(chOfs + 0x0E)
		local vol		= memory.readbyte(chOfs + 0x0F)
		-- 10
		local freq		= memory.readword(chOfs + 0x11) -- w
		local repeats	= memory.readbyte(chOfs + 0x13)
		local offsetAdd	= memory.readbyte(chOfs + 0x15)
		
		--[[
[1:28 PM]Acmlm: 11-12 looks like frequency register bytes
[1:31 PM]Acmlm: 0F is the cycle/volume register
[1:34 PM]Acmlm: 0E is the remaining length to next volume
[1:35 PM]Acmlm: 05 is the base address for that, 07 is offset
[1:39 PM]Acmlm: 0D is volume shift (down)
[1:42 PM]Acmlm: so that leaves 08 0B 0C 10 14-17, most of them never change in that video
		--]]


		local nb		= memory.readbyterange(offset, 4)
		--[[
		local cur		= ""
		for i = 1, 4 do
			cur			= cur .. string.format("%02X ", string.byte(nb, i))
		end
		cur				= string.sub(cur, 1, -2)
		--]]
		if active ~= 0 then
			gui.text(0, 174 + 8 * ch, string.format("%X:%04X:%3d/%3d %2d[%04X] %04X %02X %02X %02X %04X", ch, (offset + offsetAdd), delay, delayBase, repeats, offset2, volPtr + volOfs, volDelay, vol, volShift, freq, 1))
		else
			gui.text(0, 174 + 8 * ch, string.format("%X", ch))
		end
	end
end





-- -----------------------------------------------------------------
lastDoorCond		= 0
lastDoorCondTime	= 0

function doorCondHook()
	lastDoorCond		= memory.getregister("a")
	lastDoorCondTime	= timer

end
memory.registerexec(0xA991, doorCondHook)

-- -----------------------------------------------------------------


timer = 0
while true do

	m3CC	= memory.readbyte(0x3CC)
	gui.text(0, 0, string.format("%02X", m3CC))

	b1	= memory.readbyte(0x0B1)	-- alive enemy count
	d1	= memory.readbyte(0x0B3)	-- enemy speed modifier
	d2	= memory.readbyte(0x35E)	-- enemy spawn timer
	d3	= memory.readbyte(0x35F)	-- enemy tf timer
	gui.text(0, 9, string.format("%02X %02X %02X %02X", b1, d1, d2, d3))

	local DCT = timer - lastDoorCondTime
	gui.text(202,   0, string.format("%02X  [%4d]", lastDoorCond, DCT), (DCT < 5 and "white" or "red"), "black")
	gui.text(202,   8, string.format("%02X", memory.readbyte(0x0369)))
	gui.text(170,  16, string.format("%02X %02X %02X %02X %02X", 
	memory.readbyte(0x03BF),	-- CurrentRoomID
	memory.readbyte(0x03C5),	-- CurrentRoomIDBackup
	memory.readbyte(0x00E9),	-- CurrentRoomIDBackup2
	memory.readbyte(0x00EA),	-- CurrentRoomIDBackup3
	memory.readbyte(0x036A)		-- CurrentRoomIDBackup4

))

	-- showSoundEngine()
	jukebox()

	-- 6a6 enemy struct start
	-- 0x18 bytes ea

	dipswitchMenu(10, 30, memory.readbyte(0x3CE))
	for i = 0, 6 do
		dipswitchMenu(10, 38 + 7 * i, memory.readbyte(0x6A6 + i * 0x1C))
	end
	

	if false then
		local enemyOfs = 0x3CE
		local enemySize = 0x1C
		for i = 0, 0 do
			local localOfs = enemyOfs + enemySize * i
			local xstr = string.format("%3X", localOfs)
			if memory.readbyte(localOfs) ~= 0x00 then
				for ii = 0, enemySize - 1, 2 do
					local dot = (ii % 4 == 0) and "" or "."
					xstr = xstr .. string.format("\n%s%02X.%02X",
							dot,
							memory.readbyte(localOfs + ii),
							memory.readbyte(localOfs + ii + 1)
						)
				end
			else
				xstr = xstr .. "\n----"
			end
			gui.text(20 + 34 * i, 20, xstr, "white", "#000000A0")
		end

	end
	if false then
		-- 6a6 enemy struct start
		-- 0x18 bytes ea
		local enemyOfs = 0x6A6
		local enemySize = 0x1C
		-- local enemyOfs = 0x452
		-- local enemySize = 0x18
		for i = 0, 6 do
			local localOfs = enemyOfs + enemySize * i
			local xstr = string.format("%3X", localOfs)
			if memory.readbyte(localOfs) ~= 0x00 then
				for ii = 0, enemySize - 3, 2 do
					local dot = (ii % 4 == 0) and "" or "."
					xstr = xstr .. string.format("\n%s%02X%02X",
							dot,
							memory.readbyte(1 + localOfs + ii + 1),
							memory.readbyte(1 + localOfs + ii)
						)
					-- xstr = xstr .. string.format("\n%s%02X.%02X",
					-- 		dot,
					-- 		memory.readbyte(1 + localOfs + ii),
					-- 		memory.readbyte(1 + localOfs + ii + 1)
					-- 	)
				end
			else
				xstr = xstr .. "\n----"
			end
			gui.text(20 + 34 * i, 20, xstr, "white", "#000000A0")
		end
	end

	-- for i = 0, 0xC do
	-- 	gui.text(0, 28 + i * 8, string.format("%02X", i * 2 + 1))
	-- end

	input.update()
	timer	= timer + 1
	emu.frameadvance()
end
