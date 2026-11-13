-- mesen pinball quest variant

require "libs/functions"
tools = require "libs/toolkit"

require "bit-gamblers/bit-functions"

ScrNum2	= sxp.readScrNum2Table()


local formatfunc	= {}
formatfunc[2]	= function (n) return string.format("%02d", decmem.dec2[n]) end
formatfunc[3]	= function (n) return string.format("%03d", decmem.dec3[n]) end
formatfunc[4]	= function (n) return string.format("%04d", decmem.dec4[n]) end
formatfunc[5]	= function (n) return string.format("%05d", decmem.dec5[n]) end
formatfunc[6]	= function (n) return string.format("%06d", decmem.dec6[n]) end




-- routines / labels
f = {}
f.JumpAdd1ToNumberInA		= 0xF021
f.JumpSub1FromNumberInA		= 0xF027
f.JumpCheckIfNumberInAIsZero		= 0xF024
f.LoadScreenNum2Data		= 0xF38D

fnames	= table.flip(f)

-- mem addresses
c = {}

c.RNG						= 0x00C		-- 5 bytes
c.frameTimer				= 0x014		-- 2 bytes

c.tempDecimal				= 0x01F		-- 6 bytes (dec)
c.tempBinary				= 0x025		-- 3 bytes (hex)

c.unkCodePointer			= 0x037		-- 2 byte word


c.totalCreditsInserted		= 0x30A		-- 6/10 digits
c.unknownCounter314			= 0x314		-- 6/10 digits
c.unknownCounter31E			= 0x31E		-- 2? 4?
c.unknownCounter322			= 0x322		-- 2? 4? 6?
c.totalGamesPlayed			= 0x328		-- 6

c.paylineBookkeeping		= 0x32E		-- 2b word x 9  32E~33F

c.playerCredits				= 0x372		-- 6 digits
c.currentRoundTotalBet		= 0x378		-- 2 digits
c.previousRoundTotalBet		= 0x37A		-- 2 digits
c.slotMachineBet			= 0x37C		-- 2 digits
c.currentPaytableValues		= 0x382		-- 6 digits x 9 lines, 382~3B7

c.gameMode					= 0x41D		-- byte

c.cheatHand					= 0x449
c.cheatHiLo					= 0x406
c.cheatSlot					= 0x510
c.cheatUnkn					= 0x568



cnames = table.flip(c)

function logretaddr(n)
	-- emu.log(string.format("from: $%04X (%d)", getReturnAddress(n), n or 0))
end

function getScrNum2Details(num)
	local n = ScrNum2[num]
	if not n then return "???" end
	local a = n.addr
	local aname = cnames[a] or hexs(a)
	local val = formatfunc[n.length + 1](a)
	return string.format("%s: %d", aname, val)
end

function hook_JumpAdd1ToNumberInA()
	emu.log(string.format("$%04X -> add 1: %s", getReturnAddress(0), getScrNum2Details(cpuregisters.a)))
	-- emu.log(string.format("$%04X -> add 1: %02X", getReturnAddress(0), cpuregisters.a))
end
function hook_JumpSub1FromNumberInA()
	emu.log(string.format("$%04X -> sub 1: %s", getReturnAddress(0), getScrNum2Details(cpuregisters.a)))
	-- emu.log(string.format("$%04X -> sub 1: %02X", getReturnAddress(0), cpuregisters.a))
end
function hook_JumpCheckIfNumberInAIsZero()
	emu.log(string.format("$%04X -> check if 0: %s", getReturnAddress(0), getScrNum2Details(cpuregisters.a)))
	-- emu.log(string.format("$%04X -> check if 0: %02X", getReturnAddress(0), cpuregisters.a))
end

function hook_LoadScreenNum2Data()
	-- emu.log(string.format("load: %02X", cpuregisters.a))
end

emu.addMemoryCallback(hook_LoadScreenNum2Data, emu.callbackType.exec, f.LoadScreenNum2Data)
emu.addMemoryCallback(hook_JumpAdd1ToNumberInA, emu.callbackType.exec, f.JumpAdd1ToNumberInA)
emu.addMemoryCallback(hook_JumpSub1FromNumberInA, emu.callbackType.exec, f.JumpSub1FromNumberInA)
-- emu.addMemoryCallback(hook_JumpCheckIfNumberInAIsZero, emu.callbackType.exec, f.JumpCheckIfNumberInAIsZero)


local gameCheats = {}
for i = 0, 0x15 do
	gameCheats[i]	= { addr = mem.byte[0xE96F + i], val = mem.byte[0xE99B + i] }
end 

function handleCheatOperations()
	-- cheat base: E96F
	-- cheats: 0x00 ~ 0x15

end







function showScr2()
	local px = 0
	local py = 30
	for i = 0, 0x19 - 1 do
		py = 30 + 8 * i
		local val	= formatfunc[ScrNum2[i].length + 1](ScrNum2[i].addr)

		-- if button(px, py, 50, 6, 0xFF0000, 1) == -1 then
		-- if (tools.frame % 0x19) == i then
			emu.drawRectangle(ScrNum2[i].scrX * 8, ScrNum2[i].scrY * 8, 8 * (ScrNum2[i].length + 1), 8, 0xFFFFFF)
			if (tools.frame % 180) < 60 then
				textoutline2(ScrNum2[i].scrX * 8 + 2, ScrNum2[i].scrY * 8, hexs(i))
			elseif (tools.frame % 180) < 120 then
				textoutline2(ScrNum2[i].scrX * 8 + 2, ScrNum2[i].scrY * 8, string.format("%04X", ScrNum2[i].addr), ScrNum2[i].addr == 0x01F and 0xFF0000 or 0xFFFF00)
			else
				textoutline2(ScrNum2[i].scrX * 8 + 2, ScrNum2[i].scrY * 8, val, 0xFF8080)
			end
		-- end

		-- emu.drawString(px + 5, py, string.format("$%04X %02X,%02X [%-6s]", 
		-- 	ScrNum2[i].addr,
		-- 	ScrNum2[i].scrX,
		-- 	ScrNum2[i].scrY,
		-- 	val
		-- ), 0xFFFFFF, 0x80000000)
	end
end


function checkifwaiting()
	local retaddr = getReturnAddress()
	-- textoutline2(1, 200, string.format("%04X", retaddr))
	if retaddr == 0x8030 then	-- this is our function :^)
		local retaddr2	= getReturnAddress(3)
		local color = (tools.frame % 60) < 30 and 0xFFFFFF or 0xAAAAAA
		textoutline2(220, 220, string.format(" WAIT\n$:%04X", retaddr2), color)
	end

end

function mainfunc()
	textoutline2(1, 232, string.format("PC=%04X S=%02X A=%02X X=%02X Y=%02X GM=%02X",
		cpuregisters.pc, cpuregisters.sp,
		cpuregisters.a, cpuregisters.x, cpuregisters.y,
		mem.byte[c.gameMode]
		)
	)

	-- textoutline2(1, 20, string.format("%6d %2d %2d",
	-- 	decmem.dec6[c.playerCredits],
	-- 	decmem.dec2[c.previousRoundTotalBet],
	-- 	decmem.dec2[c.currentRoundTotalBet]
	-- 	)
	-- )

	-- textoutline2(1, 70, string.format("T: %6d\n2: %6d\n3: %6d\n4: %6d\n5: %6d", 
	-- 	decmem.dec6[c.totalCreditsInserted],
	-- 	decmem.dec6[c.unknownCounter314],
	-- 	decmem.dec6[c.unknownCounter31E],
	-- 	decmem.dec6[c.unknownCounter322],
	-- 	decmem.dec6[c.totalGamesPlayed]
	-- ))


	-- textoutline2(1, 10, string.format("GM: %02X", mem.byte[c.gameMode]))

	-- decmem.dec2[c.previousRoundTotalBet] = math.random(0, 99)

	-- showScr2()

	checkifwaiting()

end


emu.addEventCallback(mainfunc, emu.eventType.endFrame)
