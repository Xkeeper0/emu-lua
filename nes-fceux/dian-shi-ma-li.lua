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
-- 7    Does nothing; may have enabled checking DipSw2*
-- ----
-- 6    Coupon (bill) value:   ON  120   OFF 100
-- ----
-- 5    Unknown; the value of these two flags is
-- 4 *  stored at $4AD but I'm not sure what that does
-- ----
-- 3 *  Max bet + ?; sets to values to   * ON  20/180   OFF 10/90
--      (second number is the max bet across all options)
-- ----
-- 2    Coin value:      ON / ON   50    OFF / ON   10
-- 1                   * ON / OFF  25    OFF / OFF   5
-- ----
-- 0    Force reset

-- dip sw 2
-- only enabled with dipsw1 high bit + rom patch
-- "XVZLSS" (BDA5:EA)
-- to use, toggle bit on and off
--
-- 7	forces hi/lo game to win. toggling more will add more wins.
--		after the amount of wins, the next game is a 100% loss.
--		allows queueing up to 6 wins (the limit of hi-lo)
-- 6	[?] block always awards double.
-- 5	
-- 4	[?] block always awards triple (green mushroom)
-- 3	Force square type 1 (one of the "three group" symbols)
-- 2	Force square type 2 (melon/coin/star/seven)
-- 1	Force square type 3 (melon/coin/star/melon)
-- 0	Force square type 4 (bar)

-- with dip sw 1 high bit + patch,
-- dip sw 3 / joypad 2 start will force a hi/lo loss



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

-- for reading / writing this game's particular
-- way of storing numbers (decimal, one byte per digit)
-- 123,456 = 06 05 04 03 02 01









bettingOptions = {
		{ offset = 0x0406, name = "cherry" },
		{ offset = 0x0408, name = "apple" },
		{ offset = 0x040A, name = "orange" },
		{ offset = 0x040C, name = "lime" },
		{ offset = 0x040E, name = "bell" },
		{ offset = 0x0410, name = "melon" },
		{ offset = 0x0412, name = "star" },
		{ offset = 0x0414, name = "seven" },
		{ offset = 0x0416, name = "bar" },
	}


-- dipswitch settings in memory
-- coinA / coinB don't end up getting used afaict,
-- coupon value is /10
local settings = MemoryCollection{
	-- 
	coinA   = MemoryAddress.new(0x0445, "decimal6", false), -- coin 1 (25)
	couponA = MemoryAddress.new(0x044B, "decimal6", false), -- cash A (100)
	coinB   = MemoryAddress.new(0x0451, "decimal6", false), -- coin 2
	couponB = MemoryAddress.new(0x0457, "decimal6", false), -- cash B

	showStats = MemoryAddress.new(0x0493, "byte", false),
	showDips = MemoryAddress.new(0x04A2, "byte", false),
	
	dipSw1 = MemoryAddress.new(0x06f8, "byte", false),
	dipSw2 = MemoryAddress.new(0x06fc, "byte", false),
	dipSw3 = MemoryAddress.new(0x04e4, "byte", false),

	u6FB = MemoryAddress.new(0x06FB, "byte", false),


	}

local game	= MemoryCollection{
	mode		= MemoryAddress.new(0x04a1, "byte", false),	-- game mode
	pendingCoins	= MemoryAddress.new(0x04a3, "byte", false),
	pendingCoupons	= MemoryAddress.new(0x04a4, "byte", false),

	credits		= MemoryAddress.new(0x0400, "decimal6", false),
	winnings	= MemoryAddress.new(0x0634, "decimal6", false),
	u_0431		= MemoryAddress.new(0x0431, "decimal6", false),
	}

local bets	= MemoryCollection{
	cherry	= MemoryAddress.new(0x0406, "decimal2", false),
	apple	= MemoryAddress.new(0x0408, "decimal2", false),
	orange	= MemoryAddress.new(0x040A, "decimal2", false),
	lime	= MemoryAddress.new(0x040C, "decimal2", false),
	bell	= MemoryAddress.new(0x040E, "decimal2", false),
	melon	= MemoryAddress.new(0x0410, "decimal2", false),
	star	= MemoryAddress.new(0x0412, "decimal2", false),
	seven	= MemoryAddress.new(0x0414, "decimal2", false),
	bar		= MemoryAddress.new(0x0416, "decimal2", false),
	}



local monitored = MemoryCollection{
	-- u_375 = MemoryAddress.new(0x0375, "byte", false),
	-- u_5e9 = MemoryAddress.new(0x05e9, "byte", false),
	-- u_632 = MemoryAddress.new(0x0632, "byte", false),
	-- u_48c = MemoryAddress.new(0x048c, "byte", false),
	-- u_646 = MemoryAddress.new(0x0646, "byte", false),
	-- u_023 = MemoryAddress.new(0x0023, "decimal6", false),
	-- u_609 = MemoryAddress.new(0x0609, "decimal6", false),
	-- u_023 = MemoryAddress.new(0x0023, "decimal6", false),
	-- u_023a = MemoryAddress.new(0x0023, "word", false),
	-- u_4FD = MemoryAddress.new(0x04fd, "word", false),
	-- u_4FF = MemoryAddress.new(0x04ff, "word", false),
	-- ch_49E = MemoryAddress.new(0x049e, "byte", false),

	-- HiLo = MemoryAddress.new(0x048e, "byte", false),
	-- c_64A = MemoryAddress.new(0x064a, "byte", false),
	-- c_628 = MemoryAddress.new(0x0628, "byte", false),
	-- Square = MemoryAddress.new(0x061a, "byte", false),

	-- h8D26 = MemoryAddress.new(0x062d, "byte", false),
}





stringsTable = {}


stringIndex = 0
function stringIndexWatch()
	stringIndex = memory.getregister("a")
end
function stringIndexEnd()
	print(string.format("%02X -- 0000: %04X - 0009: %04X - 44: %02X", stringIndex, memory.readword(0x0000), memory.readword(0x0009), memory.readbyte(0x0044)))
	local sx = memory.readbyte(0x0000)
	local sy = memory.readbyte(0x0001)
	local len = memory.readbyte(0x44) + 1
	if not stringsTable[sx] then
		stringsTable[sx] = {}
	end
	stringsTable[sx][sy] = string.format("%02X\n%0"..len.."d", stringIndex, getDecimalValue(memory.readword(0x0009), len))
end

-- memory.registerexec(0xAC6D, stringIndexWatch)
-- memory.registerexec(0xAC8E, stringIndexEnd)


local cobb = {}
function d_C0BB()
	print(string.format("%04X", getReturnAddress()))

	for i = 0x23, 0x2B do
		cobb[i] = memory.readbyte(i)
	end
end
function d_C0BB_C108() -- rts
	local o1 = ""
	local o2 = ""

	for i = 0x23, 0x2B do
		o1 = o1 .. string.format(" %02X", cobb[i])
		o2 = o2 .. string.format(" %02X", memory.readbyte(i))
	end

	-- print(o1)
	-- print(o2)
	-- print("---------")

	print(string.format("%04d => %04X (%4d)", getDecimalValue(0x023, 5), memory.readword(0x029), memory.readword(0x029)))
end
-- memory.registerexec(0xC0BB, d_C0BB)
-- memory.registerexec(0xC108, d_C0BB_C108)

function c064()
	local v = memory.readbyte(0x029) + memory.readbyte(0x02a) * 0x100 + memory.readbyte(0x02b) * 0x10000
	print(string.format("%04X: %06X (%d)", getReturnAddress(), v, v))
end
function c0ab()
	print(string.format("  --> %06d",getDecimalValue(0x023, 6)))
end
memory.registerexec(0xc064, c064)
memory.registerexec(0xc0ab, c0ab)





showDips = true


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

	ratio			= game.credits ~= 0 and (game.u_0431 / game.credits * 100) or 0
	--gui.text(1, 216, string.format("%6d %5.2f%%\n%6d\n%6d", game.u_0431, ratio, game.credits, game.winnings))


	--[[
	local tmp = 0
	for k,v in pairs(rawget(bets, "_m")) do
		if bets[k] > 0 then
			gui.text(210, 0 + tmp * 8, k)
			gui.text(243, 0 + tmp * 8, string.format("%02d", bets[k]))
			tmp = tmp + 1
		end
	end

	local tmp = 20
	for k,v in pairs(rawget(settings, "_m")) do
		gui.text(180, 0 + tmp * 8, k)
		gui.text(220, 0 + tmp * 8, string.format("%06d", settings[k]))
		tmp = tmp + 1
	end
	--]]

	--button(50, 50, 20, 5, "blue")


	--[[
	tmp = 0
	for k,v in pairs(input.get()) do
		gui.text(0, 50 + tmp * 8, k)
		tmp = tmp + 1
	end
	--]]
	if button(196, 1, 7, 7, showDips and "white" or "gray") then
		showDips = not showDips
	end
	gui.text(205, 1, "Dipsw Menu")
	if showDips then
			
		gui.text(164, 10, string.format("SW1 %02X          ", settings.dipSw1))
		local toggle = dipswitchMenu(200, 10, settings.dipSw1)
		if (toggle ~= 0) then
			settings.dipSw1 = XOR(settings.dipSw1, toggle)
		end

		gui.text(164, 19, string.format("SW2 %02X          ", settings.dipSw2))
		local toggle = dipswitchMenu(200, 19, settings.dipSw2)
		if (toggle ~= 0) then
			settings.dipSw2 = XOR(settings.dipSw2, toggle)
		end

		gui.text(164, 28, string.format("SW3 %02X          ", settings.dipSw3))
		local toggle = dipswitchMenu(200, 28, settings.dipSw3)
		if (toggle ~= 0) then
			settings.dipSw3 = XOR(settings.dipSw3, toggle)
		end
	end


	if button(0, 1, 7, 7, (settings.showStats ~= 0) and "white" or "gray") then
		if (settings.showStats ~= 1) then
			-- the game only checks for this flag at certain points.
			-- namely, after the title screen mario jump seq.
			-- so you could be waiting a while...
			settings.showStats = 1
		else
			-- you got it, boss
			-- this is probably fine.
			forceJSR(0xC125)
			-- memory.setregister("pc", 0xC125)
		end
	end
	gui.text(9, 1, "Stats")

	if button(40, 1, 7, 7, (settings.showDips ~= 0) and "white" or "gray") then
		if (settings.showDips ~= 1) then
			-- this is checked at the same time as the stats flag,
			-- so you could end up waiting for a while. or forever.
			settings.showDips = 1
		else
			-- hell yeah, let's go!
			forceJSR(0xC21E)
			-- memory.setregister("pc", 0xC21E)
		end
	end
	gui.text(49, 1, "Config")

	-- gui.text()



	if button(85, 1, 7, 7, game.pendingCoins ~= 0 and "white" or "gray") then
		game.pendingCoins = game.pendingCoins + 1
	end
	gui.text(94, 1, string.format("Coins: %d", game.pendingCoins))

	if button(140, 1, 7, 7, game.pendingCoupons ~= 0 and "white" or "gray") then
		game.pendingCoupons = game.pendingCoupons + 1
	end
	gui.text(149, 1, string.format("Cpn's: %d", game.pendingCoupons))



--	gui.text(input.xmouse - 15, input.ymouse + 10, string.format("%d,%d", input.xmouse, input.ymouse))

	local tmp = 0
	for k,v in pairs(rawget(monitored, "_m")) do
		gui.text(180, 220 + tmp * 8, k .. "     ", "white", "black")
		gui.text(220, 220 + tmp * 8, string.format("%6d", monitored[k]))
		tmp = tmp - 1
	end


	for x,v in pairs(stringsTable) do
		for y,vv in pairs(stringsTable[x]) do
			gui.text(x * 8, y * 8, stringsTable[x][y])
		end
	end

--[[
	gui.text(164, 110, string.format("6FB %02X          ", settings.u6FB))
	local toggle = dipswitchMenu(200, 110, settings.u6FB)
	if (toggle ~= 0) then
		settings.u6FB = XOR(settings.u6FB, toggle)
	end
--]]



	gui.text(217, 230, string.format("mode %2X", game.mode))

	timer = timer + 1
	input.update()
	emu.frameadvance()
end
