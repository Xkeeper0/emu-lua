
	local MemoryAddress	= {}



-- for games that store one byte per digit
-- 123,456 -> 06 05 04 03 02 01
-- at some point i could probably refactor all of this but, fuck it
function readdecimal(ofs, len)
	local r = 0
	for i = 0, len - 1 do
		r = r + (memory.readbyte(ofs + i) * (10 ^ i))
	end
	return r
end

function writedecimal(ofs, len, value)
	for i = 0, len - 1 do
		memory.writebyte(ofs + i, (value % 10))
		value = math.floor(value / 10)
	end
end

function readdecimal2(ofs) return readdecimal(ofs, 2) end
function readdecimal4(ofs) return readdecimal(ofs, 4) end
function readdecimal6(ofs) return readdecimal(ofs, 6) end
function writedecimal2(ofs, val) return writedecimal(ofs, 2, val) end
function writedecimal4(ofs, val) return writedecimal(ofs, 4, val) end
function writedecimal6(ofs, val) return writedecimal(ofs, 6, val) end


	local memoryFunctions	= {
		byte	= {
			unsigned	= {
				read		= memory.readbyte,
				write		= memory.writebyte,
				},
			signed		= {
				read		= memory.readbytesigned,
				write		= memory.writebytesigned,
				},
			},

		word	= {
			unsigned	= {
				read		= memory.readword,
				write		= memory.writeword,
				},
			signed		= {
				read		= memory.readwordsigned,
				write		= memory.writewordsigned,
				},
			},

		dword	= {
			unsigned	= {
				read		= memory.readdword,
				write		= memory.writedword,
				},
			signed		= {
				read		= memory.readdwordsigned,
				write		= memory.writedwordsigned,
				},
			},

		decimal2	= {
			unsigned = { read = readdecimal2,  write = writedecimal2 },
			signed   = { read = readdecimal2,  write = writedecimal2 },
			},
		decimal4	= {
			unsigned = { read = readdecimal4,  write = writedecimal4 },
			signed   = { read = readdecimal4,  write = writedecimal4 },
			},
		decimal6	= {
			unsigned = { read = readdecimal6,  write = writedecimal6 },
			signed   = { read = readdecimal6,  write = writedecimal6 },
			},
		}






	function MemoryAddress.new(address, _type, _signed)
		local type		= _type and _type or 'byte'
		local signed	= _signed and "signed" or "unsigned"

		local ret	= {
			readfunc	= memoryFunctions[type][signed].read,
			writefunc	= memoryFunctions[type][signed].write,
			address		= address,
			}

		return setmetatable(ret, MemoryAddress)

	end


	function MemoryAddress:read()
		return self.readfunc(self.address)
	end

	function MemoryAddress:write(value)
		--print(string.format("Write %08x = %x", self.address, value))
		return self.writefunc(self.address, value)
	end


	MemoryAddress.__index	= MemoryAddress
	
	MemoryAddress	= setmetatable(MemoryAddress, {
						__call	= function(_, ...) return MemoryAddress.new(...) end,
						__index	= MemoryAddress
					}
				)


	return MemoryAddress