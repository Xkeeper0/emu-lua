
local input	= input

local cur	= {}	-- Currently held buttons
local prev	= {}	-- Previous frame's buttons
local imm	= {}	-- "Immediate" presses (just this frame)

function input.update()

	prev	= cur
	cur		= input.get()
	imm		= {}
	for k,v in pairs(cur) do
		if cur[k] and not prev[k] then
			imm[k]	= true
		end
	end

	return imm, cur
end

return input
