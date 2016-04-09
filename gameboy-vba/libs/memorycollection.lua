

	local MemoryCollection	= {}

	function MemoryCollection.new(t)

		local ret	= {
			_m		= t,
			}

		return setmetatable(ret, MemoryCollection)

	end


	function MemoryCollection:read()
		return self.readfunc(self.address)
	end

	function MemoryCollection:write(value)
		return self.writefunc(self.address, value)
	end

	function MemoryCollection:__index(key)

		if self._m[key] then
			return self._m[key]:read()

		elseif MemoryCollection[key] then
			return MemoryCollection[key]

		end

	end


	function MemoryCollection:__newindex(key, value)

		if self._m[key] then
			return self._m[key]:write(value)
		end

	end

	--MemoryCollection.__index	= MemoryCollection

	return setmetatable(MemoryCollection, 
			{
				__index = MemoryCollection,
				__call = function (_, ...) return MemoryCollection.new(...) end
			}
		)