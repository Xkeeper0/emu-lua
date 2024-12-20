--[[

	sw1: todo
	
	sw2 and sw3 are part of a cheat system, activated by
	toggling the relevant bit on and then OFF.
	sw2's highest bit adds 0C to the next cheat,
	effectively acting like a shift key.

	sw2 -^ 01 02 03 04 05 06 07
	sw3 08 09 0A 0B -- -- -- --
	sw2 0C 0D 0E 0F 10 11 12 13
	sw3 14 15 16 17 -- -- -- --

	sw2's highest bit will also set the hi-lo cheat to 4.

	init state:
	sw1: E9  XXX.X..X
	sw2: FF  XXXXXXXX
	sw3: FF  XXXXXXXX
	sw4: 0F  ....XXXX
	sw5: 00  ........

	cheat effects:

	00	(makes next input 0C-17)
	01	4E9 = 0F	all fruits
	02	594 =  1	?
	03	4E9 = 11	line of 3 triple bars
	04	4E9 = 12	line of 3 sevens
	05	4E9 = 13	all 4 sevens
	06	4E9 = 14	all 5 sevens
	07	4E9 = 1A	all any bar

	08	4E9 = 1B	all orange
	09	4E9 = 1C	all limes
	0a	Hi-lo cheat: add an ensured win (00 -> 02 03 04 05 ..., no cap like in DSML)
	0b	Hi-lo cheat: set to ensured loss

	0c	587 =  4	3 ensured hi lo wins, maybe ensured bonus?
	0d	4E9 = 0E	none fruit
	0e	594 =  0	?
	0f	4E9 = 10	line of 3 double bars
	10	4E9 = 0B	line of 3 bars
	11	4E9 = 0A	line of 3 stars
	12	4E9 = 19	all stars
	13	587 =  5	hi-lo bonus: 2 bars (x50)

	14	587 =  8	hi-lo bonus: 3 bars (x200)
	15	587 =  7	hi-lo bonus: 3 3 3 (x100)
	16	587 =  6	hi-lo bonus: all same number (x50)
	17	584 =  2	force outer reel win


--]]


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


function multi_start()
end
function multi_end()
end

function report_y()
	print(string.format("Y=%02X", memory.getregister("y") / 2))
end


local dip	= MemoryCollection{
	sw1 = MemoryAddress.new(0x06f8, "byte", false),
	sw2 = MemoryAddress.new(0x06fb, "byte", false),
	sw3 = MemoryAddress.new(0x06fc, "byte", false),
	sw4 = MemoryAddress.new(0x06f9, "byte", false),
	sw5 = MemoryAddress.new(0x06fd, "byte", false),
}

local dipm = { "sw1", "sw2", "sw3", "sw4", "sw5" }

memory.registerexec(0xD0FD, multi_start)
memory.registerexec(0xD14F, multi_end)
memory.registerexec(0xEDDE, report_y)
showDips = true
timer = 0
while true do

	if showDips then
		local yt = 10

		for k,v in pairs(dipm) do

			gui.text(164, yt, string.format("%s %02X          ", v, dip[v]))
			local toggle = dipswitchMenu(200, yt, dip[v])
			if (toggle ~= 0) then
				dip[v] = XOR(dip[v], toggle)
			end
			yt = yt + 9
		end
	end

	timer = timer + 1
	input.update()
	emu.frameadvance()
end
