
local input	= input

local cur	= {}	-- Currently held buttons
local prev	= {}	-- Previous frame's buttons
local imm	= {}	-- "Immediate" presses (just this frame)

--[[

	from the documentation:
	
	leftclick, rightclick, middleclick,
	capslock, numlock, scrolllock,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
	A, B, C, D, E, F, G, H, I, J, K, L, M,
	N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
	F1, F2, F3, F4, F5, F6,  F7, F8, F9, F10, F11, F12,
	F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24,
	backspace, tab, enter, shift, control, alt, pause, escape, space,
	pageup, pagedown, end, home, left, up, right, down,
	numpad0, numpad1, numpad2, numpad3, numpad4, numpad5,
	numpad6, numpad7, numpad8, numpad9, numpad*,
	insert, delete, numpad+, numpad-, numpad., numpad/,
	semicolon, plus, minus, comma, period, slash, backslash,
	tilde, quote, leftbracket, rightbracket.

--]]

function input.update()

	prev	= cur
	cur		= input.get()
	imm		= {}

	-- patch for Linux versions of FCEUX
	if cur['click'] then
		-- Linux FCEUX doesn't give the ____click keys,
		-- instead giving a "click" key, with
		-- bit 0 (1) = let, bit 1 (2) = right
		cur.leftclick	= AND(cur.click, 1) == 1
		cur.rightclick	= AND(cur.click, 2) == 2
		-- no middle click
	end		

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


input.mt = { __index = function (t, k) return cur[k] end }
setmetatable(input, input.mt)

-- Get the current state so things like mouse coords are available
input.update()

return input
