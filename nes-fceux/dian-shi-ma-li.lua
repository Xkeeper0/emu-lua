-- lua


-- ---------------------------------
-- 00000001
-- 00000001 ; enum ControllerInput (bitfield)
-- 00000001 ControllerInput_Right: = 1
-- 00000002 ControllerInput_Left: = 2
-- 00000004 ControllerInput_Down: = 4
-- 00000008 ControllerInput_Up: = 8
-- 00000010 ControllerInput_Start: = $10
-- 00000020 ControllerInput_Select: = $20
-- 00000040 ControllerInput_B: = $40
-- 00000080 ControllerInput_A: = $80

-- cherry            1P A
-- apple             1P B
-- orange            1P Sel
-- lime              1P Start
-- bell              1P Up
-- melon             1P Down
-- star              1P Left
-- seven             1P Right
-- bar               2P A
-- start early       2P B

-- 06F8: dip sw1
-- 06FC: dip sw2

-- 1p/2p
-- up: go to double up
-- down: take winnings
-- in double up
-- 1P left: big  right: small
-- 2P sel: big  start: small


-- dip sw 1
-- 7    Does nothing; may have enabled checking DipSw2
-- ----
-- 6    Coupon (bill) value:   ON  120   OFF 100
-- ----
-- 5    Unknown; the value of these two flags is
-- 4 *  stored at $4AD but I'm not sure what that does
-- ----
-- 3 *  Unknown; sets to values to   * ON  20/180   OFF 10/90
-- ----
-- 2    Coin value:      ON / ON   50    OFF / ON   10
-- 1                   * ON / OFF  25    OFF / OFF   5
-- ----
-- 0    Force reset






require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


stringID = 0
function forceString()
	memory.setregister("a", stringID)
end

-- dian shi ma li: DrawString @ $9101
-- jackpot: DrawString @ $B328
-- memory.registerexec(0xB328, forceString)

function getDecimalValue(ofs, len)
	local r = 0
	for i = 0, len - 1 do
		r = r + (memory.readbyte(ofs + i) * (10 ^ i))
	end
	return r
end







timer = 0
while true do
	--[[
	if input.pressed("Y") then
		stringID	= stringID - 1
	elseif input.pressed("U") then
		stringID	= stringID + 1
	end
	gui.text(0, 0, string.format("%02X", stringID))
	--]]

	currentWinnings	= getDecimalValue(0x0634, 6)
	currentCredits	= getDecimalValue(0x0400, 6)
	val0431			= getDecimalValue(0x0431, 6)
	ratio			= currentCredits ~= 0 and (val0431 / currentCredits * 100) or 0
	gui.text(1, 1, string.format("%6d %5.2f%%\n%6d\n%6d", val0431, ratio, currentCredits, currentWinnings))








	timer = timer + 1

	input.update()
	emu.frameadvance()
end
