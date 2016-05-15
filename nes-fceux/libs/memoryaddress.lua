
	local MemoryAddress	= {}

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
			}
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