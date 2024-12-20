
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
