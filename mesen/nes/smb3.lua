



-- stuff from before
-- require("libs/toolkit")
require("libs/functions")

-- -- Require some modules/classes
-- MemoryAddress		= require("libs/memoryaddress")
-- MemoryCollection	= require("libs/memorycollection")

-- input				= require("libs/input")

socket				= require("socket.core")
udp = socket.udp()
udp:settimeout(0)
udp:setpeername("127.0.0.1", 37801)


-- memory.registerexec(0x0578, function () 
-- 	tmp = mem.byte[0x0578] - 1
-- 	print(string.format("powerup state: %02X", tmp))
-- 	udp:send(string.format("m=%.1f", tmp == 0 and 0.5 or 1.0))

-- end)

powerup_state	= 0
tmp				= 0
timer = 0
flytimer = 0
ptimer = 0
function mainfunc()

	-- tmp = memory.readbyte(0x006D) * 0x100 + memory.readbyte(0x0086)
	if mem.byte[0x070a] == 0x00 then
		tmp = mem.byte[0x0746]
		-- map
	else
		-- otherwise
		tmp = mem.byte[0x0ED]
	end
	-- emu.drawString(40, 40, string.format("%02X %02X", tmp, powerup_state))
	if tmp ~= powerup_state then
		powerup_state = tmp
		emu.log(string.format("powerup state: %02X", powerup_state))
		-- udp:send(string.format("b=%.1f", math.min(1, powerup_state / 2)))
		udp:send(string.format("m=%.1f", powerup_state == 0 and 0.5 or 1.0))
	end

	-- emu.drawString(0,  0, string.format("%02X", mem.byte[0x3DD]))
	-- emu.drawString(0,  8, string.format("%02X", mem.byte[0x515]))
	-- emu.drawString(0, 16, string.format("%02X", mem.byte[0x56E]))
	-- emu.drawString(0, 60, string.format("%02X", mem.byte[0x567]))

	flytime = mem.byte[0x56E]
	if flytime > 0 or flytimer > 0 then
		if flytime > 0 then flytimer = 60 end
		local color = math.min(255, math.max(0, math.floor((math.sin(timer / 3) + 1) * 127))) * 0x010100 + 0x0000FF
		drawBar(64, 197, 93, 3, 0, 0x7F, flytime, color, 0xFFFFFF, 0x000000, 0xFFFFFF, 0x000000)
		textoutline2(45, 195, string.format("%3d", flytime))
		flytimer = flytimer - 1
	end
		
	ptime = mem.byte[0x567]
	if ptime > 0 or ptimer > 0 then
		if ptime > 0 then ptimer = 60 end
		local color = math.min(127, math.max(0, math.floor((math.cos(1.3 + timer / 12) + 1) * 63))) * 0x010200 + 0x2000FF
		drawBar(25, 27, 200, 3, 0, 0x7F, ptime, color, 0xFFFFFF, 0x000000, 0xFFFFFF, 0x00000000)
		textoutline2(116, 25, string.format("%3d", ptime))
		ptimer = ptimer - 1

	end


	-- velocity x
	-- emu.drawString(0, 32, string.format("%3d", mem.sbyte[0x0BD]))
	velx		= math.abs(mem.sbyte[0x0BD])
	bcolor      = 0x7F7F7F
	if velx >= 56 then
		bcolor = (timer % 2) < 1 and 0xFFFFFF or 0xFF0000
	elseif velx >= 40 then
		bcolor = 0xFFFF00
	elseif velx >= 24 then
		bcolor = 0x00FF00
	end

	-- 24 40  56
	-- drawBar(x, y, w, h, min, max, val, fill, marker, background, border, outline)
	drawBar(64, 221, 93, 3, 0, 56, velx, bcolor, 0xFFFFFF, 0x000000, 0xFFFFFF, 0x000000)
	textoutline2(51, 219, string.format("%2d", velx))

	-- velocity y
	-- emu.drawString(0, 40, string.format("%3d", mem.sbyte[0x0CF]))
	

	
	timer = timer + 1
end



emu.addEventCallback(mainfunc, emu.eventType.endFrame)
