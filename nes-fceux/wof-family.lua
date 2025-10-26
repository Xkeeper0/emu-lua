
-- wheel of fortune (family edition)

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")



function readPuzzle()
	local out = ""
	for y = 0, 3 do
		for x = 1, 0xE do
			local pl = AND(memory.readbyte(0x3D0 + (y * 0x10) + x), 0x7F)
			if pl == 0 then
				pl = 0x20 -- space
			elseif pl == 0x7F then
				pl = 0x2A -- *
			end
			out = out .. string.char(pl)
		end
		out = out .. "\n"
	end
	return out
end

musicQueued = false
function hookF80F()
	if musicQueued then
		memory.writebyte(0x024, musicQueued)
		print(string.format("M = %02X", musicQueued))
		musicQueued = false
		-- debugger.hitbreakpoint()
		forceJSR(0xF546) -- PlayMusic + skip ppu
		-- forceJSR(0xF593)  -- rts
		local pc = memory.getregister("pc")
		print(string.format("sanity check: pc = %04X", pc))
		-- debugger.hitbreakpoint()
	end
end

-- memory.registerexec(0x8BA0, hookF80F)
memory.registerexec(0x8B9B, hookF80F)

showJukebox = true
function jukebox()

	local xp = 1
	local yp = 9
	local xs = 16
	local ys = 14

	local xo = 180
	local yo = 30

	local clicked = button(xo + 15, yo - 7, 39, 13)
	gui.text(xo + 17, yo - 7 + 3, "Jukebox", "white", "clear")
	if clicked then
		showJukebox = not showJukebox
	end
	if not showJukebox then
		return
	end

	for i = 0, 0xF do

		local xc = i % 4
		local yc = math.floor(i / 4)

		local clicked = button(xo + xp + xs * xc, yo + yp + yc * ys, xs - 2, 12, "gray", "white")
		gui.text(xo + xp + xs * xc + 2, yo + yp + yc * ys + 3, string.format("%02X", i), "white", "black")
		if clicked == true then
			musicQueued = i
		end
	end

end


jumppads = { 
	0xA30A,			-- InitWheelSpinScreen
	-- 0xA30A			-- InitWheelSpinScreen
	}
function jumpbox()

	local xo = 1
	local yo = 33
	local yn = 0
	for k,v in ipairs(jumppads) do
		local clicked = button(xo, yo + (yn * 13), 28, 12, "gray", "white")
		gui.text(xo + 3, yo + (yn * 13) + 3, string.format("%04X", v), "white", "black")
		yn	= yn + 1
		if clicked == true then
			memory.writeword(0x00E, v)
		end
	end

end


throbCount = 0
throbLast = 0
function rngThrobCount()
	throbCount = throbCount + 1
end
function rngThrobReset()
	throbLast = throbCount
	throbCount = 0
end
memory.registerexec(0x8726, rngThrobCount)	-- ThrobRNG
memory.registerexec(0x8B3A, rngThrobReset)	-- NMI_0


function rngvis()
	local rng	= memory.readbyte(0x000B)	-- RandomNumber
	local frameTimer	= memory.readbyte(0x000A)	-- RandomNumberA
	local rngB	= memory.readbyte(0x000C)	-- RandomNumberB
	local rngC	= memory.readbyte(0x00FF)	-- RandomNumberC
	local r432	= memory.readbyte(0x0432)	-- 0x0432
	local rng16	= memory.readword(0x000B)	--

	gui.text(0, 70, string.format("#%4d\nR %04X\nT %02X\nC %02X\nN %02X",
		throbLast,
		rng16,
		frameTimer,
		rngC,
		r432))

end


lastPuzzleId	= 0
pzMax			= 0
pzMin			= 99999
function puzzleFromRNG(printit)

	local rngA	= memory.readbyte(0x000B)
	local rngB	= memory.readbyte(0x000C)
	local CARRY	= AND(memory.getregister("p"), 0x01)

	local A = AND(rngA - rngB - CARRY, 0x7F)
	local B = AND(rngA, 0x80) / 0x10	-- LSR 4x
	local t018	= A + B
	local t01A	= AND(rngA, 0x07)

	lastPuzzleId	= (t018 * 8 + t01A)
	pzMax			= math.max(lastPuzzleId, pzMax)
	pzMin			= math.min(lastPuzzleId, pzMin)

	gui.text(0, 170, string.format("%02X %d (%4d) C=%d", t018, t01A, lastPuzzleId, CARRY))
	gui.text(0, 180, string.format("%4d (%4d~%4d)", lastPuzzleId, pzMin, pzMax))

	if (puzzleTable[lastPuzzleId] and puzzleTable[lastPuzzleId] == 0) then
		puzzleCount	= puzzleCount + 1
	end
	puzzleTable[lastPuzzleId]	= puzzleTable[lastPuzzleId] + 1

	if printit then
		print(string.format("%02X %d (P=%4d) C=%d", t018, t01A, lastPuzzleId, CARRY))
	end
	return
end

puzzleTable = {}
puzzleCount = 0
for pn = 0, 1089 do
	puzzleTable[pn]	= 0
end
function drawPuzzleTable()
	local px = 0
	local py = 0
	local pn = 0
	gui.text(160, 120 - 9, string.format("%4d/1088", puzzleCount))
	gui.box(160 - 2, 120 - 2, 160 + 2 * 32 + 1, 120 + 2 * 34 + 1, "black")
	for y = 0, 34 do
		for x = 0, 31 do
			pn = (y * 32) + x
			px = 160 + x * 2
			py = 120 + y * 2
			if puzzleTable[pn] then
				local col = "gray"
				if puzzleTable[pn] >= 4 then
					col = (puzzleTable[pn] % 2) == 0 and "white" or "green"
				elseif puzzleTable[pn] >= 3 then
					col = "red"
				elseif puzzleTable[pn] >= 2 then
					col = "orange"
				elseif puzzleTable[pn] >= 1 then
					col = "blue"
				end
				gui.box(px, py, px + 1, py + 1, col)
			end
		end
	end

	px		= 160 + (lastPuzzleId % 32) * 2
	py		= 120 + (math.floor(lastPuzzleId / 32)) * 2
	gui.box(px - 2, py - 2, px + 3, py + 3, "clear", "black")
	gui.box(px - 1, py - 1, px + 2, py + 2, "clear", "white")

end

function hookPuzzleSel()
	if memory.readbyte(0x8032) ~= 0xBD then return end

	local x = memory.getregister("x")
	local y = memory.getregister("y")
	local p	= x * 8 + y
	print(string.format("X: %02X  Y: %02X   P: %4d", x, y, p))
	puzzleTable[p]	= puzzleTable[p] + 1
	puzzleFromRNG(true)
end
memory.registerexec(0x8032, hookPuzzleSel)



-- i should really write more comments in my code.
function bank3Write()
	-- hooked when 3:803E runs
	-- STA ($16),Y @ $AB48 = #$70

	local pc		= memory.getregister("pc")
	if memory.readbyte(pc) ~= 0xEA then return end	-- for when opcodes are nop'd out

	local origin	= memory.readword(0x014)
	local target	= memory.readword(0x016)
	local a			= memory.getregister("a")
	local y			= memory.getregister("y")
	local addr		= target + y
	print(string.format("[%04X] %04X  %02X => %04X (%04X,%02X)", pc, origin, a, addr, target, y))

	-- critically we have to actually skip this opcode
	-- or the game might try and write it and then explode, and that's bad.
	-- memory.setregister("pc", pc + 0)
	-- did u kno: messing with the pc during the active instruction causes
	-- Fun and Exciting New Problems

end
memory.registerexec(0x803E, bank3Write)
memory.registerexec(0x8042, bank3Write)




local puzzle = ""
while true do
	input.update()

	
	puzzle = readPuzzle()
	gui.text(1, 1, puzzle)

	jukebox()
	jumpbox()

	-- rngvis()

	-- puzzleFromRNG()
	-- drawPuzzleTable()

	gui.text(210,  0, string.format("N=$%04X", memory.readword(0x00E)))
	gui.text(210,  8, string.format("P=$%04X", memory.getregister("pc")))

	gui.text(220, 16, hexs(memory.readbyte(0x0067)))
	gui.text(220, 24, hexs(memory.readbyte(0x0099)))

	emu.frameadvance()
end