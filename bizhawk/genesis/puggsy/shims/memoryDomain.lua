
local MemoryDomain	= {}
local mt			= {}
local currentDomain	= nil

function MemoryDomain.new(domain)
	local ret	= {
			domain	= domain
		}
	return setmetatable(ret, mt)

end


mt.__index	= function(t, k)
	if t.domain ~= currentDomain then
		memory.usememorydomain(t.domain)
		currentDomain	= t.domain
	end
	return memory[k]

end




return MemoryDomain