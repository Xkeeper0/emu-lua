

	local memoryR		= {}

	-- Read byte
	function memoryR.rb(a, signed)
		return signed and memoryR.rbs(a) or memory.readbyte(a)
	end

	-- Read byte (signed)
	function memoryR.rbs(a)
		return memory.readbytesigned(a)
	end

	-- Read word (big-endian, unsigned)
	function memoryR.rwBE(a, signed)
		local v = memory.readbyte(a) * 0x100 +
				memory.readbyte(a + 1)
		if signed and v >= 0x7FFF then
			-- this math is probably wrong because im coder
			v	= (0x10000 - v) * -1
		end
		return v
	end
	memoryR.rw	= memoryR.rwBE


	-- Write word (big-endian, unsigned)
	function memoryR.wwBE(a, v, signed)
		-- todo: actually register signed
		memory.writebyte(a    , math.floor(v / 0x100))
		memory.writebyte(a + 1, v % 0x100)
	end
	memoryR.ww	= memoryR.wwBE

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