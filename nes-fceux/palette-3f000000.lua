
stage = 0
stages	= {nil, nil, nil, nil}

function dumpRegs()
	return string.format("PC=%04x A=%02x X=%02x Y=%02x ic=%10d", memory.getregister("pc"), memory.getregister("a"), memory.getregister("x"), memory.getregister("y"), debugger.getinstructionscount())
end

function resetPPU()
	stage = 0
end

function trackChanges(addr, size, value)

	if stage == 0 and value == 0x3F then
		stage = 1
		stages[1]	= dumpRegs()
	elseif stage > 0 and value == 0x00 then
		if (stage == 1 or stage == 2) then
			stage = stage + 1
			stages[stage]	= dumpRegs()
		elseif (stage == 3) then
			stages[4]	= dumpRegs()
			print(string.format("-----------\r\n%s\r\n%s\r\n%s\r\n%s\r\n", stages[1], stages[2], stages[3], stages[4]))

			debugger.hitbreakpoint()
			stage = 0
		end
	else
		stage = 0
	end

end

memory.registerwrite(0x2002, resetPPU)
memory.registerwrite(0x2007, resetPPU)
memory.registerwrite(0x2006, trackChanges)