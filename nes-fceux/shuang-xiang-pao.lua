--[[



--]]


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


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


local monitored = MemoryCollection{
	u_37c = MemoryAddress.new(0x037c, "decimal6", false),
	u_3c2 = MemoryAddress.new(0x03c2, "decimal6", false),
	u_UCC = MemoryAddress.new(0x03c9, "decimal6", false),
	u_3CF = MemoryAddress.new(0x03CF, "decimal6", false),
	u_7d3DE = MemoryAddress.new(0x03DE, "decimal6", false),
	u_7d3E5 = MemoryAddress.new(0x03E5, "decimal6", false),
	u_5d3EC = MemoryAddress.new(0x03EC, "decimal6", false),
	u_5d3F3 = MemoryAddress.new(0x03F3, "decimal6", false),
	}


local dip	= MemoryCollection{
	sw1 = MemoryAddress.new(0x06f8, "byte", false),
	sw2 = MemoryAddress.new(0x06fb, "byte", false),
	sw3 = MemoryAddress.new(0x06fc, "byte", false),
	sw4 = MemoryAddress.new(0x06f9, "byte", false),
	sw5 = MemoryAddress.new(0x06fd, "byte", false),
}
	
local dipm = { "sw1", "sw2", "sw3", "sw4", "sw5" }


showDips = true
timer = 0
while true do


	if input.pressed("A") then
		-- memory.writebyte(0x058, 3)
		forceJSR(0xCAD8)
	end


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



	local tmp = 0
	for k,v in pairs(rawget(monitored, "_m")) do
		gui.text(180, 220 + tmp * 8, k .. "     ", "white", "black")
		gui.text(220, 220 + tmp * 8, string.format("%6d", monitored[k]))
		tmp = tmp - 1
	end


	timer = timer + 1
	input.update()
	emu.frameadvance()
end
