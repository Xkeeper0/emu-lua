--
-- Arkista's Ring
-- 

require("libs/toolkit")
require("libs/functions")
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")
input				= require("libs/input")


rnghistory			= 0
rnghistorytable		= {}
function rngoutput()
	rnghistorytable[rnghistory]	= { cpuregisters.a, getReturnAddress() }
	rnghistory		= (rnghistory + 1) % 1000
end
-- memory.registerexec(0xB57E, rngoutput)


function drawrng()
	local ox	= 0
	local oy	= 0

	for i = 0, 999 do
		if rnghistorytable[i] then
			gui.pixel(ox + rnghistorytable[i][1] % 0x10, oy + math.floor(rnghistorytable[i][1] / 0x10), "white")
		end
	end
	gui.text(ox, oy + 20, string.format("%4d", rnghistory))


	local rnum	= 0
	for i = 0, 16 do
		rnum	= (rnghistory - i + 1000) % 1000
		if rnghistorytable[rnum] then
			gui.text(ox + 0, oy + 40 + i * 8, string.format("%2X %s $%04X", rnghistorytable[rnum][1], thinbinary(rnghistorytable[rnum][1], 8), rnghistorytable[rnum][2]))
		end

	end
end


function hookentryexit(inaddr, outaddr, func)
	local a = cpuregisters.a
	local x = cpuregisters.x
	local y = cpuregisters.y
	print(string.format("IN: PC=$%04X->$%04X A=%02X X=%02X Y=%02X", cpuregisters.pc, inaddr, a, x, y))
	forceJSR(inaddr)
	if func then func() end
	memory.registerexec(outaddr, function ()
		cpuregisters.a = a
		cpuregisters.x = x
		cpuregisters.y = y
		print(string.format("OUT $%04X->$%04X A=%02X X=%02X Y=%02X", inaddr, outaddr, a, x, y))
		memory.registerexec(outaddr, nil)
	end)
end




function playmusic(n)
	local n = n
	print("Playing music ".. hexs(n))
	hookentryexit(0xCEA9, 0xCEAD, function() print(hexs(cpuregisters.pc) .." new = ".. hexs(n)); cpuregisters.a = n; end)
end

function playsound(n)
	local n = n
	print("Playing sound ".. hexs(n))
	hookentryexit(0xC88E, 0xCEBF, function() print(hexs(cpuregisters.pc) .." new = ".. hexs(n)); cpuregisters.a = n; end)
end





timer = 0
while true do
	
	-- drawrng()

	local x, y		= 20, 5
	local bx, by	= 20, 20
	local bh, bw	= 12, 18
	local bc		= "gray"
	local bf		= playmusic

	bx	= x + -1 * bw
	by	= y + 2 * bh
	if button(bx, by, bw - 2, bh * 4 - 2, "#0000C0") then
		playsound(0)
	end
	gui.text(bx + 3, by + 4, "S\nT\nOS\nPF\n X", "white", "clear")
	bx	= x + -1 * bw
	by	= y + 0 * bh
	if button(bx, by, bw * 2 - 2, bh - 2, "#008000") then
		playmusic(0)
	end
	gui.text(bx + 6, by + 2, "STOP", "white", "clear")


	for i = 1, 0x2F do
		bx	= x + (i % 8) * bw
		by	= y + math.floor(i / 8) * bh
		if i <= 08 then
			bc	= "#008000"
		elseif i < 0x10 then
			bc	= "#800000"
		else
			bc	= "#0000C0"
		end
		bf	= i <= 0x8 and playmusic or playsound

		if button(bx, by, bw - 2, bh - 2, bc) then
			bf(i)
			if i == 0 then
				playsound(0)
			end
		end
		gui.text(bx + 3, by + 2, hexs(i), "white", "clear")
	end



	timer = timer + 1
	input.update()
	emu.frameadvance()
end