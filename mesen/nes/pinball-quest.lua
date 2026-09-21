-- mesen pinball quest variant

require "libs/functions"
tools = require "libs/toolkit"

local function prgofs(b, n)
	if (n >= 0xC000) then return 0x1C000 + (n - 0xC000) end
	return (n - 0x8000) + (b * 0x4000)
end

PROC_BASE = 0x15F
PROC_SIZE = 0x030
PROC_COUNT = 0x1B -- 00~1A

HUD_SCALE = 2

local ADDRS	= {}

-- this is not the best way to do it i do not care. bite me
ADDRS.BALL_X		= 0x015F + 3	-- word
ADDRS.BALL_Y		= 0x015F + 1	-- word
ADDRS.ALT_BALL_X	= 0x0062	-- word
ADDRS.ALT_BALL_Y	= 0x0060	-- word
ADDRS.CAM_X			= 0x008D	-- byte
ADDRS.CAM_Y			= 0x008E	-- byte

-- sub_BANK7_FD27
local jukeboxChoice = false
function forceSound()
	emu.log(string.format("sound = %02X", mem.byte[0x0CF]))
	if jukeboxChoice then
		mem.byte[0x0CF] = jukeboxChoice
		emu.log("overwrote with ".. jukeboxChoice)
		jukeboxChoice = false
	end
end
emu.addMemoryCallback(forceSound, emu.callbackType.exec, 0xFD27)

function jukebox(x, y)
	local px, py = 0, 0
	local bw, bh = 13, 9
	local bcolor = 0x000000
	local track = 0
	for i = 0, 0xFF do
		px = (i % 0x10) * (bw) + math.floor((i % 16) / 4) * 3
		py = math.floor(i / 0x10) * (bh)
		track = prg.byte[prgofs(1, 0x9270 + i)]

		bcolor = (jukeboxChoice == i) and (tools.frame % 2 == 0 and 0xFFFFFF or 0xFF0000) or (track >= 0x80 and 0xFF0000 or 0x404040)
		btext = (track >= 0x80 and 0xFF4040 or 0xFFFFFF)
		-- emu.drawRectangle(x + px, y + py, bs, bs, prg.byte[prgofs(1, 0x9720 + i)] >= 0x80 and 0xFF0000 or 0xFFFFFF)
		if true == button(x + px, y + py, bw, bh, bcolor) then
			jukeboxChoice = i
		end
		emu.drawString(x + px + 1, y + py + 1, hexs(track), btext, 0xFF000000)
	end
end





function realToRelative(x, y)
	local relX	= (x - 0x1000) - mem.byte[ADDRS.CAM_X]
	local relY	= (y - 0x1000) - mem.byte[ADDRS.CAM_Y]
	return relX * HUD_SCALE, relY * HUD_SCALE
end

function relativeToReal(x, y)
	local realX	= x + 0x1000 + mem.byte[ADDRS.CAM_X]
	local realY = y + 0x1000 + mem.byte[ADDRS.CAM_Y]
	return realX, realY
end



function drawInGamePosition(x, y, color, text)
	local relX, relY = realToRelative(x, y)
	local color	= color and color or 0xFF0000

	emu.drawLine(relX - 2, relY    , relX + 2, relY    , color)
	emu.drawLine(relX    , relY - 2, relX    , relY + 2, color)
	if text then
		textoutline2(relX + 2, relY - 8, text, color)
	end

end

function drawProcPositions()

	for i = 0, PROC_COUNT - 1 do
		local BA	= PROC_BASE + i * PROC_SIZE
		if mem.byte[BA] ~= 0 or 1 then
			
			local color = mem.byte[BA + 0] ~= 0 and 0xFFFFFF or 0xA07F7F7F
			local relX, relY = realToRelative(mem.word[BA + 3], mem.word[BA + 1])
			local hW, hH = mem.byte[BA + 0x0C], mem.byte[BA + 0x0B]
			emu.drawRectangle(relX, relY, hW * HUD_SCALE, hH * HUD_SCALE, color)

			drawInGamePosition(
				mem.word[BA + 3],
				mem.word[BA + 1],
				color,
				-- string.format("%X\n%04X\n%04X", i, mem.word[BA + 0x0D], mem.word[BA + 0x17])
				string.format("%X", i, mem.word[BA + 0x0D], mem.word[BA + 0x17])
			)
		end

	end
end




function trackPPUReadB()
	emu.log(string.format("PPU read: $%04X = #$%02X", mem.word[0x098], cpuregisters.a))
end

-- 0xCA60 start of routine
-- 0xCA73 end

-- word 98 = addr to read from
-- a = read value
-- emu.addMemoryCallback(trackPPUReadA, emu.callbackType.exec, 0xCA60)
-- emu.addMemoryCallback(trackPPUReadB, emu.callbackType.exec, 0xCA73)



emu.addMemoryCallback(function () 
	local retaddr, retreal = getReturnAddress()
	emu.log(string.format("Initialized @ %04X [%06X].", retaddr, retreal))
	-- emu.breakExecution() -- HIT THE BREAKS!!!!
end, emu.callbackType.exec, 0xC086)


known_bytes = { 0x01, 0x02, 0x03, 0x04, 0x09, 0x0a, 0x0b, 0x0c, 0x29, 0x2a }
known_bytest = {}
for k,v in pairs(known_bytes) do
	known_bytest[v] = true
end



function drawProcTable(x, y)
	local x = x or 50
	local y = y or 50

	-- if 1 then return end

	for i = 0, PROC_COUNT - 1 do
		local px	= x
		local py	= y + i * 18
		local st	= getProcData(i)
		local t		= mem.byte[0xA7 + i]
		emu.drawString(px, py, string.format("%02X %02X\n%04X ", i, mem.byte[0xA7 + i], PROC_BASE + PROC_SIZE * i))

		if t >= 0 then
			for b = 0, PROC_SIZE - 1 do
				local px2	= 30 + (b % 24) * 17
				local py2	= math.floor(b / 24) * 9
				if not known_bytest[b] then
					emu.drawString(px + px2, py + py2, hexs(st[b]) .." ", (b % 2) == 0 and 0xFFFFFF or 0xA0A0FF, (b >= 24) and 0x10000000 or 0x10333333)
				else
					emu.drawString(px + px2, py + py2, " - ", (b % 2) == 0 and 0xFFFFFF or 0xA0A0FF, (b >= 24) and 0x10000000 or 0x10333333)
				end
			end
			emu.drawString(px + 438, py, string.format("%04X  \n  %04X", st.pc, st.sprite))
		end
	end


end


function getProcData(idx)
	local p = {}
	local o = PROC_BASE + PROC_SIZE * idx
	for i = 0, PROC_SIZE - 1 do
		p[i]	= mem.byte[o + i]
	end

	--[[
		00:
		01w: y position
		03w: x position
		05:
		06:
		07:
		08:
		09o: sprite data pointer
		0B: height (px?)
		0C: width (px?)
		0D:
		0E:
		0F:
		10:
		11:
		12:
		13:
		14:
		15:
		16:
		17:
		18:
		19:
		1A:
		1B:
		1C:
		1D:
		1E:
		1F:
		20:
		21:
		22:
		23:
		24:
		25:
		26:
		27:
		28:
		29o: VMPtr (current vm bytecode PC)
		2B:
		2C: rate?
		2D:
		2E:
		2F:
--]]
	
	p.pc		= mem.word[o + 0x29]	-- VMPtr
	p.sprite	= mem.word[o + 0x09]	-- sprite data ofs
	-- p.mp		= mem.word[o + 0x09]
	p.rate		= mem.byte[o + 0x2C]

	p.x			= mem.word[o + 0x03]
	p.y			= mem.word[o + 0x01]
	p.w			= mem.byte[o + 0x0C]
	p.h			= mem.byte[o + 0x0B]




	return p
end




proctrace_table = {}
proctrace_entry = 0
proctrace_current_proc = false
proctrace_step_count = 0
function proctrace_StartRunProcess()
	-- StartRunProcess
	-- DEC2
	proctrace_entry = 0
	proctrace_step_count = 1
	proctrace_table = {}
	proctrace_current_proc = false
end
function proctrace_RunProcess()
	-- RunProcess
	-- DEC4
	proctrace_entry = proctrace_entry + 1
	proctrace_current_proc = mem.word[0x092]
	proctrace_table[proctrace_entry] = { base = proctrace_current_proc, steps = {} }
	proctrace_step_count = 1
end
function proctrace_step()
	-- 0000 in RAM (yep!)
	-- current $003
	proctrace_table[proctrace_entry].steps[proctrace_step_count] = { addr = mem.word[0x003], opcode = mem.byte[mem.word[0x003]] }
	proctrace_step_count	= proctrace_step_count + 1
end
function proctrace_FinishProcess()
	-- FinishProcess
	-- DFD7
	proctrace_table[proctrace_entry].steps[proctrace_step_count] = { addr = mem.word[0x003], opcode = 0xFF }
	proctrace_step_count = 0
	proctrace_current_proc = false
end

local function ins_jmp(what, where)
	proctrace_table[proctrace_entry].steps[proctrace_step_count] = { addr = mem.word[0x003], bra = what, dest = where }
	proctrace_step_count	= proctrace_step_count + 1
	
end


function proctrace_JMP() ins_jmp("JM", mem.word[mem.word[0x003]]) end -- D3B7
function proctrace_JNE() ins_jmp("NE", mem.word[mem.word[0x003]]) end -- D3A3
function proctrace_JEQ() ins_jmp("EQ", mem.word[mem.word[0x003]]) end -- D3A8
function proctrace_JCS() ins_jmp("CS", mem.word[mem.word[0x003]]) end -- D3AD
function proctrace_JCC() ins_jmp("CC", mem.word[mem.word[0x003]]) end -- D3B2
	

emu.addMemoryCallback(proctrace_StartRunProcess, emu.callbackType.exec, 0xDEC2)
emu.addMemoryCallback(proctrace_RunProcess,      emu.callbackType.exec, 0xDEC4)
emu.addMemoryCallback(proctrace_step,            emu.callbackType.exec, 0x0000)
emu.addMemoryCallback(proctrace_FinishProcess,   emu.callbackType.exec, 0xDFD7)


emu.addMemoryCallback(proctrace_JMP, emu.callbackType.exec, 0xD3B7)
emu.addMemoryCallback(proctrace_JNE, emu.callbackType.exec, 0xD3A3)
emu.addMemoryCallback(proctrace_JEQ, emu.callbackType.exec, 0xD3A8)
emu.addMemoryCallback(proctrace_JCS, emu.callbackType.exec, 0xD3AD)
emu.addMemoryCallback(proctrace_JCC, emu.callbackType.exec, 0xD3B2)


function drawptrace(x, y)
	local x = x or 50
	local y = y or 50
	local i = 0
	for k,v in pairs(proctrace_table) do
		emu.drawString(x, y + i * 9, string.format("%02X [$%04X] ", (v.base - PROC_BASE) / PROC_SIZE, v.base))
		local ii = 0
		for kk, vv in ipairs(v.steps) do
			if ii > 6 then
				ii = 0
				i = i + 1
			end
			if vv.opcode then
				emu.drawString(x + 80 + ii * 44, y + i * 9, string.format("%04X:%02X ", vv.addr, vv.opcode), vv.opcode ~= 0xFF and 0xFFFFFF or 0x7F7F7F)
			else
				emu.drawString(x + 80 + ii * 44, y + i * 9, string.format("%s:%02X ", vv.bra, vv.dest), 0xFF8080)
			end
			ii = ii + 1
		end
		i = i + 1
	end
end



opin = 0
emu.addMemoryCallback(function() opin = mem.word[0x070] end, emu.callbackType.exec, 0xCD32)
emu.addMemoryCallback(function() emu.log(string.format("[CD32] in %04X out %04X %04X (%5d -> %5d  %5d)", opin, mem.word[0x070], mem.word[0x073], opin, mem.word[0x070], mem.word[0x073])) end, emu.callbackType.exec, 0xCD5F)









function mainfunc()
	emu.selectDrawSurface(emu.drawSurface.scriptHud, HUD_SCALE)

	drawProcPositions()

	-- drawProcTable(0, 20)
	drawptrace()

	local screenX	= -0x1000 + mem.word[ADDRS.BALL_X]
	local screenY	= -0x1000 + mem.word[ADDRS.BALL_Y] - mem.byte[ADDRS.CAM_Y]

	-- textoutline2(10, 10, string.format("%03X %03X", screenX, screenY))
	-- textoutline2(10, 18, string.format(" %02X  %02X", mem.byte[ADDRS.CAM_X], mem.byte[ADDRS.CAM_Y]))

	textoutline2(1, 1, string.format("PC=%04X S=%02X\nA=%02X X=%02X Y=%02X",
		cpuregisters.pc, cpuregisters.sp,
		cpuregisters.a, cpuregisters.x, cpuregisters.y
		)
	)
	-- hey watch let's see if everything breaks :^)
	-- if (math.random(0, 100) < 2) then
	-- 	cpuregisters.pc	= 0
	-- end


	-- emu.drawString(10, 100, string.format("%02X %s", mem.byte[0x3F], thinbinary(mem.byte[0x3F])))


	-- emu.drawRectangle(screenX - 3, screenY - 3, 7, 7, 0x40FF0000, true)

	if true and tools.keyPressed("rightclick") then
		local gameX	= 0x1000 + tools.mouse.x
		local gameY	= 0x1000 + tools.mouse.y + mem.byte[ADDRS.CAM_Y]
		mem.word[ADDRS.BALL_Y]	= gameY
		mem.word[ADDRS.BALL_X]	= gameX
		emu.drawRectangle(screenX - 3, screenY - 3, 7, 7, 0xFFFFFF, true)
	end


	--jukebox(10, 10)

end
emu.addEventCallback(mainfunc, emu.eventType.endFrame)
