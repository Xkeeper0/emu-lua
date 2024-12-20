
-- round number to given decimal place
function math.round(num, dec)
	local mult	= 10 ^ (dec or 0)
	return math.floor( num * mult + 0.5 ) / mult
end

-- draw fancy bar visualization
-- x, y, w, h: position, size
-- min, max, val: given range for values, actual value
-- fill: "full" color
-- marker: a solid line at the end of the filled area
-- background: unfilled area in bar
-- border: color of outside border of bar
-- outline (optional): outline color outside of the bar
function drawBar(x, y, w, h, min, max, val, fill, marker, background, border, outline)

	local percent	= math.min(1, math.max(0, (val - min) / (max - min)))
	local fillWidth	= math.round(percent * w)

	local x2			= x + w
	local y2			= y + h

	local fill			= fill or "gray"
	local marker		= marker or "white"
	local background	= background or "black"
	local border		= border or nil
	local outline		= outline or nil

	if outline and border then
		-- draw outline and border together, then draw background
		gui.box(x - 2, y - 2, x2 + 2, y2 + 2, border, outline)
		gui.box(x, y, x2, y2, background, background)

	elseif border then
		-- draw the border and background together
		gui.box(x - 1, y - 1, x2 + 1, y2 + 1, background, border)

	else
		-- just draw the border
		gui.box(x, y, x2, y2, background, background)
	end

	if fillWidth > 0 then
		gui.box(x, y, x + fillWidth, y2, fill, fill)
	end
	if marker then
		gui.line(x + fillWidth, y, x + fillWidth, y2, marker)
	end
end



function getDecimalValue(ofs, len)
	local r = 0
	for i = 0, len - 1 do
		r = r + (memory.readbyte(ofs + i) * (10 ^ i))
	end
	return r
end

function setDecimalValue(ofs, len, value)
	for i = 0, len - 1 do
		memory.writebyte(ofs + i, (value % 10))
		value = math.floor(value / 10)
	end
end


function getReturnAddress()
	local sp = memory.getregister("s")
	return memory.readword(0x100 + sp + 1)
end


function forceJSR(where)
	-- stack needs to be ret addr - 1
	local sp = memory.getregister("s")
	local pc = memory.getregister("pc")
	memory.writeword(0x100 + sp - 1, pc - 1)
	memory.setregister("s", sp - 2)
	memory.setregister("pc", where)
	print(string.format("interrupted @ sp %02X  pc %04X", sp, pc))
end


function hitbox(x, y, x1, y1, x2, y2)
	return (x >= x1 and x <= x2) and (y >= y1 and y <= y2)
end
function button(x, y, w, h, color, hover)
	local m = input.mouse()
	local hit = hitbox(m.x, m.y, x, y, x + w, y + h)
	local hitcol = hit and "gray" or "black"
	local ret = false
	if hit and input.pressed("leftclick") then
		hitcol = "white"
		ret = true
	elseif hit and hover then
		ret = -1   -- this will never bite me in the ass. never
	end
	gui.box(x, y, x + w, y + h, color, hitcol)
	return ret
end


function dipswitchMenu(x, y, dips)
	local toggleMask = 0
	local xp = 0
	local buttonSize = 6
	local bitMask = 0
	for i = 0, 7 do
		bitMask = 2 ^ i
		xp = x + (7 - i) * (buttonSize + 1)
		if button(xp, y, buttonSize, buttonSize, (AND(dips, bitMask) ~= 0) and "white" or "gray") then
			-- because this is just bits in order,
			-- this is basically just an OR
			toggleMask = toggleMask + bitMask
		end
	end
	return toggleMask
end
