
memoryDomain	= require("shims/memoryDomain")
domains			= memory.getmemorydomainlist()
m	= {
	main	= memoryDomain.new("68K RAM"),
	z80		= memoryDomain.new("Z80 RAM"),
	cart	= memoryDomain.new("MD CART"),
	boot	= memoryDomain.new("BOOT ROM"),
	cram	= memoryDomain.new("CRAM"),
	vsram	= memoryDomain.new("VSRAM"),
	vram	= memoryDomain.new("VRAM"),
	}


function showObj()
	for i = 0, 20 do
		for vv = 0, 0xF do
			local ix	= (vv % 0x8) * (7 * 6)
			local iy	= i * 20 + math.floor(vv / 0x8) * 10
			gui.drawText(ix, iy, string.format("%5d", m.main.read_s16_be(0x950 + (i * 0x20) + vv * 2)))
		end
	end
end


event.onframeend(showObj)

