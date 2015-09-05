
local MemoryObject	= {}


MemoryObject.__index				= MemoryObject

-- This setup seems stupid.
-- I feel like I should instead delegate the signed/unsigned-ness
-- to other functions, probably in memoryR.
-- blah

MemoryObject.functions				= {
					byte		= {
						read	= m.rbs,
						write	= memory.writebyte
						},
					word		= {
						read	= m.rw,
						write	= m.ww,
						},
					}

function MemoryObject.new(address, _type, _signed)
	local type		= _type and _type or 'byte'
	local signed	= _signed and _signed or false



	local ret	= {
		type	= type,
		signed	= signed,
		address	= address,
		}

	return setmetatable(ret, MemoryObject)

end


function MemoryObject:read()
	return MemoryObject.functions[self.type].read(self.address, self.signed)
end

function MemoryObject:write(v)
	return MemoryObject.functions[self.type].write(self.address, v, self.signed)
end





return MemoryObject