

	local memoryR		= {}

	-- Read byte
	function memoryR.rb(a)
		return memory.readbyte(a)
	end

	-- Read byte (signed)
	function memoryR.rbs(a)
		return memory.readbytesigned(a)
	end

	-- Read word (big-endian, unsigned)
	function memoryR.rwBE(a)
		return memory.readbyte(a) * 0x100 +
				memory.readbyte(a + 1)
	end
	memoryR.rw	= memoryR.rwBE

	-- Read word (little-endian, unsigned)
	function memoryR.rwLE(a)
		return memory.readbyte(a + 1) * 0x100 +
				memory.readbyte(a)
	end

	-- 3-byte word or whatever, who comes up with this shit
	function memoryR.r3wBE(a)
		return memory.readbyte(a) * 0x10000 + 
				memory.readbyte(a + 1) * 0x100 + 
				memory.readbyte(a + 2)
	end
	memoryR.r3w	= memoryR.r3wBE


	return memoryR