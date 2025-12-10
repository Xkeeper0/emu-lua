
-- round number to given decimal place
function math.round(num, dec)
	local mult	= 10 ^ (dec or 0)
	return math.floor( num * mult + 0.5 ) / mult
end

function clamp(v, min, max)
	return math.min(math.max(v, min), max)
end
math.clamp = clamp


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
	print(string.format("new --> sp %02X  pc %04X", sp - 2, where))
	print(string.format("to stack --> [$%04X] %04X", (0x100 + sp - 1), pc - 1))
end


function hitbox(x, y, x1, y1, x2, y2)
	return (x >= x1 and x <= x2) and (y >= y1 and y <= y2)
end
function button(x, y, w, h, color, hover)
	local m = input.mouse()
	local hit = hitbox(m.x, m.y, x, y, x + w, y + h)
	local hitcol = hit and "gray" or "black"
	local color = color and color or "gray"
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

function multibutton(x, y, w, h, color, bordercolor, hovercolor)
	local m = input.mouse()
	local hit = hitbox(m.x, m.y, x, y, x + w, y + h)
	local bordercolor = hit and (hovercolor and hovercolor or "P10") or (bordercolor and bordercolor or "P00")
	local ret = 0
	if hit and input.pressed("leftclick") then
		bordercolor = "white"
		ret = 1
	elseif hit and input.pressed("rightclick") then
		bordercolor = "red"
		ret = 2
	end
	gui.box(x, y, x + w, y + h, color, bordercolor)
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


function hexs(v, l)
	return string.format("%0".. (l or 2) .."X", v)
end
function hexdump(t)
	local o				= {}
	for k,v in pairs(t) do
		o[k]			= hexs(v)
	end
	return table.concat(o, " ")
end


function thinbinary(v, l, rev)
	local out	= ""
	local siz	= l or math.max(8, v ~= 0 and math.ceil(math.log(v) / math.log(2)) or 1)
	for i = 0, siz - 1 do
		if rev then
			out		= out .. (AND(v, 2 ^ i) ~= 0 and "|" or ".")
		else
			out		= (AND(v, 2 ^ i) ~= 0 and "|" or ".") .. out
		end
	end
	return out
end


function showmouse(crosshair)
	local textx = (input.xmouse > 210) and (input.xmouse - 40) or (input.xmouse + 5)
	local texty = (input.ymouse > 223) and (input.ymouse - 12) or (input.ymouse + 10)
	if crosshair then
		local csz	= (type(crosshair) == "number") and crosshair or 2
		gui.line(input.xmouse - csz, input.ymouse, input.xmouse + csz, input.ymouse, "white")
		gui.line(input.xmouse, input.ymouse - csz, input.xmouse, input.ymouse + csz, "white")
	end
	gui.text(textx, texty, string.format("%d,%d", input.xmouse, input.ymouse))
end


bf		= {}
-- input: value, [carry]
-- output: value, carry
function bf.ROR(v, c)
	local c2	= AND(0x01, v)
	v		= AND(0xFF, math.floor(v / 2) + ((c and 0x80 * c or 0)))
	return v, c2
end
function bf.ROL(v, c)
	local c2	= (AND(v, 0x80) == 0x80 and 1 or 0)
	v		= AND(0xFF, v * 2 + (c and c or 0))
	return v, c2
end
function bf.LSR(v)
	return AND(0xFF, math.floor(v / 2)), AND(0x01, v)
end
function bf.ASL(v)
	local c2	= (AND(v, 0x80) == 0x80 and 1 or 0)
	return AND(0xFF, v * 2), c2
end
-- shortcuts
function bf.rshift(v, n)
	return math.floor(v / math.pow(2, n))
end
function bf.lshift(v, n)
	return v * math.pow(2, n)
end


-- access CPU registers with "cpuregisters.pc" instead of `memory.getregister("pc")`
-- and clobber them with "cpuregisters.pc = 0xBEEF" instead of `memory.setregister("pc", 0xBEEF)`
cpuregisters	= {}
function cpuregisters:__index(key)
	return memory.getregister(key)
end
function cpuregisters:__newindex(key, value)
	return memory.setregister(key, value)
end
setmetatable(cpuregisters, cpuregisters)

-- convenience table
mem				= { byte = {}, sbyte = {}, word = {}, sword = {}}
function mem.byte:__index(key)             return memory.readbyte(key)                  end
function mem.byte:__newindex(key, value)   return memory.writebyte(key, value)          end
function mem.sbyte:__index(key)            return memory.readbytesigned(key)            end
function mem.sbyte:__newindex(key, value)  return memory.writebytesigned(key, value)    end
function mem.word:__index(key)             return memory.readword(key)                  end
function mem.word:__newindex(key, value)   return memory.writeword(key, value)          end
function mem.sword:__index(key)            return memory.readwordsigned(key)            end
function mem.sword:__newindex(key, value)  return memory.writewordsigned(key, value)    end
setmetatable(mem.byte, mem.byte)
setmetatable(mem.sbyte, mem.sbyte)
setmetatable(mem.word, mem.word)
setmetatable(mem.sword, mem.sword)



-- right-down-rightdown shadow
function textshadow(x, y, text, color, shadow)
	local color = color and color or "white"
	local shadow = shadow and shadow or "black"
	gui.text(x + 1, y    , text, shadow, "clear")
	gui.text(x + 1, y + 1, text, shadow, "clear")
	gui.text(x    , y + 1, text, shadow, "clear")
	gui.text(x    , y    , text, color , "clear")
end
-- outline of the four cardinal directions
function textoutline(x, y, text, color, shadow)
	local color = color and color or "white"
	local shadow = shadow and shadow or "black"
	gui.text(x + 1, y    , text, shadow, "clear")
	gui.text(x    , y - 1, text, shadow, "clear")
	gui.text(x - 1, y    , text, shadow, "clear")
	gui.text(x    , y + 1, text, shadow, "clear")
	gui.text(x    , y    , text, color , "clear")
end
-- full outline with corners
function textoutline2(x, y, text, color, shadow)
	local color = color and color or "white"
	local shadow = shadow and shadow or "black"
	gui.text(x + 1, y + 1, text, shadow, "clear")
	gui.text(x    , y + 1, text, shadow, "clear")
	gui.text(x - 1, y + 1, text, shadow, "clear")
	gui.text(x + 1, y    , text, shadow, "clear")
	gui.text(x - 1, y    , text, shadow, "clear")
	gui.text(x    , y - 1, text, shadow, "clear")
	gui.text(x + 1, y - 1, text, shadow, "clear")
	gui.text(x - 1, y - 1, text, shadow, "clear")

	gui.text(x    , y    , text, color , "clear")
end
