
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

-- return true if a button is being held down
function input.held(k)
	return (cur[k])
end

-- return true if a button was pressed this frame only
function input.pressed(k)
	return (imm[k])
end

-- return true if a button was *released* this frame only
function input.released(k)
	return (prev[k] and not cur[k])
end

-- return current x, y values for mouse
function input.mouse()
	return { x = cur.xmouse, y = cur.ymouse }
end


-- Get the current state so things like mouse coords are available
input.update()

return input
