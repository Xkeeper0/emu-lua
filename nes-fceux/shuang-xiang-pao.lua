--[[



--]]


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")
timer = 0

require("bit-gamblers")

--[[
local dip	= MemoryCollection{
	sw1 = MemoryAddress.new(0x06f8, "byte", false),
	sw2 = MemoryAddress.new(0x06fb, "byte", false),
	sw3 = MemoryAddress.new(0x06fc, "byte", false),
	sw4 = MemoryAddress.new(0x06f9, "byte", false),
	sw5 = MemoryAddress.new(0x06fd, "byte", false),
}

local dipm = { "sw1", "sw2", "sw3", "sw4", "sw5" }
--]]

local gamedata = MemoryCollection{
	credits = MemoryAddress.new(0x0372, "decimal6", false),
	betlastround = MemoryAddress.new(0x0378, "decimal2", false),
	betthisround = MemoryAddress.new(0x037A, "decimal2", false),
	slotbonusbet = MemoryAddress.new(0x037c, "decimal6", false),
	totalinsertedcredits = MemoryAddress.new(0x03c9, "decimal6", false),
	couponvalue = MemoryAddress.new(0x03CF, "decimal6", false),
	couponvalue2 = MemoryAddress.new(0x03D5, "decimal6", false),
}

local monitored = MemoryCollection{
	gm = MemoryAddress.new(0x041d),
	u_45A = MemoryAddress.new(0x045A, "byte", false),
	u_3c2 = MemoryAddress.new(0x03c2, "decimal6", false),
	u_455 = MemoryAddress.new(0x0455, "byte", false),
	u_01A = MemoryAddress.new(0x001A, "byte", false),
	u_01B = MemoryAddress.new(0x001B, "byte", false),
	-- u_5d3EC = MemoryAddress.new(0x03EC, "decimal6", false),
	-- u_5d3F3 = MemoryAddress.new(0x03F3, "decimal6", false),
	}


local dip	= MemoryCollection{
	sw1 = MemoryAddress.new(0x06f8, "byte", false),
	-- sw2 = MemoryAddress.new(0x06fb, "byte", false),
	-- sw3 = MemoryAddress.new(0x06fc, "byte", false),
	s1a = MemoryAddress.new(0x040C, "byte", false),
	s1b = MemoryAddress.new(0x0428, "byte", false),
	sw4 = MemoryAddress.new(0x06f9, "byte", false),
	sw5 = MemoryAddress.new(0x06fd, "byte", false),
}
-- local dipm = { "sw1", "sw2", "sw3", "sw4", "sw5" }
local dipm = { "sw1", "s1a", "s1b", "sw4", "sw5" }
	
local jbOrder = {
	0,  1,  2,  3, 14, 15, 16, 17, 18, -1,
	4,  5,  6,  7,  8, 19, 20, -1,
	9, 10, 11, 12, 13 
	}
local lastplayed	= {}
function hookPlaySound()
	lastplayed[cpuregisters.a]	= timer
end
memory.registerexec(0xF262, hookPlaySound)

function jukebox()
	local xpos = 96
	local ypos = 215
	local bw = 8
	local bh = 8
	local xp = 0
	local yp = 0
	local brow	 = 0
	local bcol	 = 0

	local bpx	= 0
	local bpy	= 0
	for i, n in pairs(jbOrder) do
		bpx	= xpos + bcol * (bw + xp)
		bpy	= ypos + brow * (bh + yp)
		if n == -1 then
			brow	= brow + 1
			bcol	= 0
		else
			local bcolor	= (lastplayed[n] and (timer - lastplayed[n]) < 6) and "green" or "#303030"
			if button(bpx, bpy, bw, bh, bcolor) then
				cpuregisters.a	= n
				print(n)
				wrappedJSR(0xF262)
			end
			gui.text(bpx + 2, bpy + 1, n < 10 and string.char(n + 0x30) or string.char((n - 10) + 0x41), "white", "clear")
			bcol	= bcol + 1
		end

	end
end


function notefreq(n)
	return mem.byte[0xF5AA + n], mem.byte[0xF5CE + n]
end

function fart()
	-- 36 tones
	mem.byte[0x42a]	= 1		-- SoundChannel1Active
	mem.byte[0x42b]	= 2		-- SoundChannel2Active

	local nlo, nhi

	nlo, nhi		= notefreq(math.random(0, 35))
	mem.byte[0x435]	= nlo
	mem.byte[0x436]	= OR(nhi, 0xD0)
	nlo, nhi		= notefreq(math.random(0, 35))
	mem.byte[0x439]	= nlo
	mem.byte[0x43A]	= OR(nhi, 0xD0)

	mem.byte[0x433]	= 0x85
	mem.byte[0x437]	= 0x85

	mem.byte[0x434]	= 0
	mem.byte[0x438]	= 0

	forceJSR(0xF53A)	-- WriteSoundRegisters

end
function clearsound()
	mem.byte[0x42a]	= 0
	mem.byte[0x42b]	= 0
	mem.byte[0x435]	= 0
	mem.byte[0x436]	= 0
	mem.byte[0x439]	= 0
	mem.byte[0x43A]	= 0

	mem.byte[0x433]	= 0
	mem.byte[0x437]	= 0

	mem.byte[0x434]	= 0
	mem.byte[0x438]	= 0
end

function paino()
	local xp, yp	= 20, 100

	local m = input.mouse()
	local bx, by	= 0, 0
	local any		= false
	if input.held("leftclick") or input.held("rightclick") then clearsound() end
	for i = 0, 11 do
		bx	= xp + i * 5
		for r = 0, 2 do
			by	= yp + r * 10
			local hit = hitbox(m.x, m.y, bx, by, bx + 3, by + 7)
			gui.box(bx, by, bx + 3, by + 7, hit and "white" or "gray")
			if hit and input.held("leftclick") then
				-- channel 1
				local nlo, nhi		= notefreq(r * 12 + i)
				mem.byte[0x42a]	= 1		-- SoundChannel1Active
				mem.byte[0x435]	= nlo
				mem.byte[0x436]	= OR(nhi, 0xD0)
				mem.byte[0x433]	= 0x85
				mem.byte[0x434]	= 0
				any = true
			end
			if hit and input.held("rightclick") then
				-- channel 2
				local nlo, nhi		= notefreq(r * 12 + i)
				mem.byte[0x42b]	= 2		-- SoundChannel2Active
				mem.byte[0x439]	= nlo
				mem.byte[0x43A]	= OR(nhi, 0xD0)
				mem.byte[0x437]	= 0x85
				mem.byte[0x438]	= 0
				any = true
			end
		end
	end

	if any then
		-- forceJSR(0xF53A)	-- WriteSoundRegisters
		wrappedJSR(0xF53A)	-- WriteSoundRegisters
	end
end


showpalettes	= false
function palettes()
	local xpos = 0
	local ypos = 190
	if (button(xpos, ypos - 7, 6)) then
		showpalettes	= not showpalettes
	end
	if not showpalettes then return end

	local bw = 6
	local bh = 8
	local xp = 1
	local yp = 0
	local brow	 = 0
	local bcol	 = 0
	local bpx	= 0
	local bpy	= 0
	for n = 0, 0xE do
		bpx	= xpos + bcol * (bw + xp)
		bpy	= ypos + brow * (bh + yp)
		local bcolor	= mem.byte[0x0454] == n and "green" or "#404040"
		if button(bpx, bpy, bw, bh, bcolor) then
			wrappedJSR(0xF09D)
			cpuregisters.a	= n
		end
		gui.text(bpx + 1, bpy + 1, string.format("%X", n), "white", "clear")
		bcol	= bcol + 1

	end

	ypos = ypos + 9
	bcol = 0
	for n = 0, 0x4 do
		bpx	= xpos + bcol * (bw + xp)
		bpy	= ypos + brow * (bh + yp)
		local bcolor	= "#404040"
		if button(bpx, bpy, bw, bh, bcolor) then
			wrappedJSR(0xF0E6)
			cpuregisters.a	= n
		end
		gui.text(bpx + 1, bpy + 1, string.format("%X", n), "white", "clear")
		bcol	= bcol + 1

	end

end




function drawtexts()
	local xpos = 0
	local ypos = 140
	local bw = 6
	local bh = 8
	local xp = 1
	local yp = 0
	local brow	 = 0
	local bcol	 = 0
	local bpx	= 0
	local bpy	= 0
	for n = 0, 0x11 do
		if n < 0xD or n == 0x11 then
			bpx	= xpos + bcol * (bw + xp)
			bpy	= ypos + brow * (bh + yp)
			local bcolor	= "#404040"
			if button(bpx, bpy, bw, bh, bcolor) then
				wrappedJSR(0xE1D0)
				cpuregisters.a	= n
			end
			gui.text(bpx + 1, bpy + 1, string.format("%X", n), "white", "clear")
			bcol	= bcol + 1
			if n == 6 then
				bcol = 0
				brow = brow + 1
			end
		end
	end

end





-- BG palette
-- memory.registerexec(0xF09D, function () cpuregisters.a = math.min(0xE, math.floor(input.xmouse / 0x10)); end)
-- SP palette
-- memory.registerexec(0xF0E6, function () cpuregisters.a = math.min(0x4, math.floor(input.xmouse / 0x10)); end)
-- wrapexec(0xF09D, function () forceJSR(0xF0E6);  end)


-- memory.registerexec(0xE1D0, function () 
-- 	cpuregisters.a = 3
-- end)

function misc()
	if button(0, 130, 6) then
		wrappedJSR(0xF281)
		cpuregisters.a = 0
	end
	if button(10, 130, 6) then
		wrappedJSR(0xB6BC)
	end
	if button(10, 140, 12, 6) then
		cpuregisters.pc = 0xA17E
		cpuregisters.s = 0xFF
	end
	if button(20, 130, 6) then
		monitored.gm = clamp(monitored.gm - 1, 0, 0x10)
	end
	if button(27, 130, 6) then
		monitored.gm = clamp(monitored.gm + 1, 0, 0x10)
	end
end




-- memory.registerexec(0xDC0C, function ()
-- 	cpuregisters.a = 8
-- end)

-- getrandomcard
-- memory.registerexec(0xD407, function ()
-- 	wrappedJSR(0xED0C)	-- WaitAFrames
-- 	cpuregisters.a = 2

-- end)



showDips = true


--[[
while true do
	timer = timer + 1
	input.update()
	palettes()
	drawtexts()
	misc()
	emu.frameadvance()
end
--]]

while true do

	-- palettes()
	-- drawtexts()
	-- misc()


	if showDips then
		local yt = 1
		local xt = 188

		for k,v in pairs(dipm) do

			gui.text(xt, yt, string.format("%s %02X      ", v, dip[v]), "white", "#0000F040")
			local toggle = dipswitchMenu(xt + 36, yt, dip[v], 3, 6)
			if (toggle ~= 0) then
				dip[v] = XOR(dip[v], toggle)
			end
			yt = yt + 9
		end
	end



	local tmp = 0
	for k,v in pairs(rawget(monitored, "_m")) do
		gui.text(180, 232 + tmp * 8, k .. "     ", "white", "#00000080")
		gui.text(220, 232 + tmp * 8, string.format("%6d", monitored[k]), "white", "#0000FF80")
		tmp = tmp - 1
	end

	-- for i = 0, 8 do
	-- 	local o = 0x0382 + 6 * i
	-- 	local v	= getDecimalValue(o, 6)
	-- 	gui.text(160, 9 + 8 * (8 - i), string.format("%d:%6d", i, v))
	-- end


	for i = 0, 6 do
		local xt	= 0 + 14 * i
		local yt	= 223 -- 109 + i * 9
		local o1	= 0x03DE + i
		local o2	= 0x03E5 + i
		local card, cardcolor = decodecard(mem.byte[o1])
		if button(xt - 2, yt+2, 13, 5, mem.byte[o2] == 0 and "#404040" or "white") then
			-- mem.byte[o1]	= 0
			mem.byte[o2]	= 1 - mem.byte[o2]
		end
		textoutline(xt+3, yt-2, i)
		drawcard(xt, yt +  9, mem.byte[o1])
	end
	if button(97, 232, 14, 6) then
		wrappedJSR(0xD417)
		--[[
		for i = 0, 6 do
			local o1	= 0x03DE + i
			local o2	= 0x03E5 + i
			if mem.byte[o2] == 0 then
				mem.byte[o1]	= 0
			end
		end
		--]]
	end
	textoutline2(113, 232, "Discard")

	local sp	= cpuregisters.s
	gui.text(0, 0, string.format("%02X PC:%04X S:%02X", mem.byte[0x041d], cpuregisters.pc, sp))
	local sofs	= 0
	local srow	= 1
	while (sp + sofs) < 0xFF do
		gui.text(0, 8 * srow, string.format("%02X:%04X", sp + sofs, getReturnAddress(sofs)))
		srow = srow + 1
		sofs = sofs + 2
	end

	-- palettes()
	-- paino()
	-- jukebox()

	timer = timer + 1
	input.update()
	emu.frameadvance()
end
