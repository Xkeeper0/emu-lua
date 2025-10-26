-- friday the 13th


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")
timer				= 0


local game		= MemoryCollection {
	u00A4			= MemoryAddress.new(0x00A4, "byte", false),

	jasonTimer1			= MemoryAddress.new(0x0587, "byte", false),
	jasonAttackTimer1	= MemoryAddress.new(0x058D, "byte", false),
	jasonTimer1			= MemoryAddress.new(0x0587, "byte", false),
	jasonHealth			= MemoryAddress.new(0x051C, "byte", false),

	otherCounselorsAlive	= MemoryAddress.new(0x0504, "byte", false),
	kidsAlive				= MemoryAddress.new(0x0503, "byte", false),

	dayNightCycle			= MemoryAddress.new(0x0508, "byte", false),
	cabinEnterCount			= MemoryAddress.new(0x0523, "byte", false),

	}

local player	= MemoryCollection {
	health			= MemoryAddress.new(0x0505, "byte", false),
	weapon			= MemoryAddress.new(0x0506, "byte", false),
	counselor		= MemoryAddress.new(0x0507, "byte", false),
	lighter			= MemoryAddress.new(0x0517, "byte", false),
	flashlight		= MemoryAddress.new(0x0518, "byte", false),
	vitamins		= MemoryAddress.new(0x0519, "byte", false),
	sweater			= MemoryAddress.new(0x051A, "byte", false),
	}



function H_83D6()
	local target	= memory.readword(0x0000)
	local len		= memory.readbyte(0x0002)
	print(string.format("Clearing memory: %04X, %02X (%d) bytes", target, len, len))
end
memory.registerexec(0x83D6, H_83D6)


local H_80B4_calls	= {}
function H_80B4()
	table.insert(H_80B4_calls, memory.readword(0x0020))
end
memory.registerexec(0x80B4, H_80B4)


function ShowCabinStatus(xp, yp)

	for i = 0, 9 do
		local x		= xp + 0
		local y		= yp + 0 + (i * 8)
		local cs	= memory.readbyte(0x074E + i)
		local ts	= ""
		for xx = 1, 5 do
			ts = ts .. (math.random(0, 100) < 50 and "." or "|")
		end
		gui.text(x, y, string.format("%X %02X %s", i, cs, thinbinary(cs)))
		-- dipswitchMenu(x + 25, y, cs)

	end
end


while true do

	ShowCabinStatus(0, 0)

	local yo	= 0
	for k,v in pairs(game._m) do
		gui.text(100, yo, k)
		gui.text(200, yo, tostring(game[k]))
		yo		= yo + 8
	end

	for k,v in ipairs(H_80B4_calls) do
		gui.text(10, k * 8, hexs(v, 4))
	end


	input.update()
	timer	= timer + 1
	emu.frameadvance()
end
