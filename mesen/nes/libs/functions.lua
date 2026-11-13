
tools = require("libs/toolkit")

local function createMemoryHelper(memType)
	local memory = { byte = {}, sbyte = {}, word = {}, sword = {}, dword = {}, sdword = {}}
	function memory.byte:__index(key)             return emu.read(key,memType, false)      end
	function memory.byte:__newindex(key, value)   return emu.write(key, value,memType)     end
	function memory.sbyte:__index(key)            return emu.read(key,memType, true)       end
	function memory.sbyte:__newindex(key, value)  return emu.write(key, value,memType)     end

	function memory.word:__index(key)             return emu.read16(key,memType, false)    end
	function memory.word:__newindex(key, value)   return emu.write16(key, value,memType)   end
	function memory.sword:__index(key)            return emu.read16(key,memType, true)     end
	function memory.sword:__newindex(key, value)  return emu.write16(key, value,memType)   end

	function memory.dword:__index(key)            return emu.read32(key,memType, false)    end
	function memory.dword:__newindex(key, value)  return emu.write32(key, value,memType)   end
	function memory.sdword:__index(key)           return emu.read32(key,memType, true)     end
	function memory.sdword:__newindex(key, value) return emu.write32(key, value,memType)   end
	setmetatable(memory.byte, memory.byte)
	setmetatable(memory.sbyte, memory.sbyte)
	setmetatable(memory.word, memory.word)
	setmetatable(memory.sword, memory.sword)
	setmetatable(memory.dword, memory.dword)
	setmetatable(memory.sdword, memory.sdword)

	return memory
end

mem = createMemoryHelper(emu.memType.nesDebug)
ppu = createMemoryHelper(emu.memType.nesPpuDebug)
prg = createMemoryHelper(emu.memType.nesPrgRom)
chr = createMemoryHelper(emu.memType.nesChrRom)


cpuregisters	= {}
function cpuregisters:__index(key)
	return emu.getState()["cpu."..key] or nil
end
function cpuregisters:__newindex(key, value)
	local newstate = {}
	newstate["cpu."..key] = value
	return emu.setState( newstate )
end
setmetatable(cpuregisters, cpuregisters)



-- right-down-rightdown shadow
function textshadow(x, y, text, color, shadow)
	local color = color and color or 0xFFFFFF
	local shadow = shadow and shadow or 0x000000
	emu.drawString(x + 1, y    , text, shadow, 0xFF000000)
	emu.drawString(x + 1, y + 1, text, shadow, 0xFF000000)
	emu.drawString(x    , y + 1, text, shadow, 0xFF000000)
	emu.drawString(x    , y    , text, color , 0xFF000000)
end
-- outline of the four cardinal directions
function textoutline(x, y, text, color, shadow)
	local color = color and color or 0xFFFFFF
	local shadow = shadow and shadow or 0x000000
	emu.drawString(x + 1, y    , text, shadow, 0xFF000000)
	emu.drawString(x    , y - 1, text, shadow, 0xFF000000)
	emu.drawString(x - 1, y    , text, shadow, 0xFF000000)
	emu.drawString(x    , y + 1, text, shadow, 0xFF000000)
	emu.drawString(x    , y    , text, color , 0xFF000000)
end
-- full outline with corners
function textoutline2(x, y, text, color, shadow)
	local color = color and color or 0xFFFFFF
	local shadow = shadow and shadow or 0x000000
	emu.drawString(x + 1, y + 1, text, shadow, 0xFF000000)
	emu.drawString(x    , y + 1, text, shadow, 0xFF000000)
	emu.drawString(x - 1, y + 1, text, shadow, 0xFF000000)
	emu.drawString(x + 1, y    , text, shadow, 0xFF000000)
	emu.drawString(x - 1, y    , text, shadow, 0xFF000000)
	emu.drawString(x    , y - 1, text, shadow, 0xFF000000)
	emu.drawString(x + 1, y - 1, text, shadow, 0xFF000000)
	emu.drawString(x - 1, y - 1, text, shadow, 0xFF000000)

	emu.drawString(x    , y    , text, color , 0xFF000000)
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
	local fillWidth	= math.floor((percent * w))

	local x2			= x + w
	local y2			= y + h

	local fill			= fill or 0x7F7F7F
	local marker		= marker or 0xFFFFFF
	local background	= background or 0x000000
	local border		= border or nil
	local outline		= outline or nil

	if outline and border then
		-- draw outline and border together, then draw background
		-- emu.drawRectangle(x - 2, y - 2, w + 4, h + 4, border, outline)
		-- emu.drawRectangle(x, y, w, h, background, background)
		emu.drawRectangle(x - 2, y - 2, w + 4, h + 4, outline, false)
		emu.drawRectangle(x - 1, y - 1, w + 2, h + 2, border, false)
		emu.drawRectangle(x, y, w, h, background, true)

	elseif border then
		-- draw the border and background together
		emu.drawRectangle(x - 1, y - 1, w + 2, h + 2, background, border)

	else
		-- just draw the border
		emu.drawRectangle(x, y, w, h, background, background)
	end

	if fillWidth > 0 then
		emu.drawRectangle(x, y, fillWidth, h, fill, fill)
	end
	if marker then
		emu.drawLine(x + fillWidth, y, x + fillWidth, y + h - 1, marker)
	end
end





function hitbox(x, y, x1, y1, x2, y2)
	if not x or not y or not x1 or not y1 or not x2 or not y2 then return false end
	return (x >= x1 and x <= x2) and (y >= y1 and y <= y2)
end
function button(x, y, w, h, color, hover)
	local m = tools.mouse
	local w = w and w or 8
	local h = h and h or w
	local hit = hitbox(m.x, m.y, x, y, x + w, y + h)
	local hitcol = hit and 0x7F7F7F or 0x000000
	local color = color and color or 0x7F7F7F
	local ret = false
	if hit and tools.keyPressed("leftclick") then
		hitcol = 0xFFFFFF
		ret = true
	elseif hit and hover then
		ret = -1   -- this will never bite me in the ass. never
	end
	emu.drawRectangle(x + 1, y + 1, w- 2, h - 2, color, true)
	emu.drawRectangle(x, y, w, h, hitcol)
	return ret
end

function multibutton(x, y, w, h, color, bordercolor, hovercolor)
	local m = tools.mouse
	local w = w and w or 8
	local h = h and h or w
	local hit = hitbox(m.x, m.y, x, y, x + w, y + h)
	local bordercolor = hit and (hovercolor and hovercolor or 0x7F7F7F) or (bordercolor and bordercolor or 0x3F3F3F)
	local ret = 0
	if hit and tools.keyPressed("leftclick") then
		bordercolor = 0xFFFFFF
		ret = 1
	elseif hit and tools.keyPressed("rightclick") then
		bordercolor = 0xFF0000
		ret = 2
	end
	emu.drawRecatngle(x + 1, y + 1, w - 2, h - 2, color, true)
	emu.drawRecatngle(x, y, w, h, bordercolor)
	return ret
end


function dipswitchMenu(x, y, dips, bw, bh)
	local toggleMask = 0
	local xp = 0
	local buttonWidth = bw and bw or 6
	local buttonHeight = bh and bh or buttonWidth
	local bitMask = 0
	for i = 0, 7 do
		bitMask = 2 ^ i
		xp = x + (7 - i) * (buttonWidth + 1)
		if button(xp, y, buttonWidth, buttonHeight, (AND(dips, bitMask) ~= 0) and 0xFFFFFF or 0x7F7F7F) then
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
			out		= out .. ((v & 2 ^ i) ~= 0 and "|" or ".")
		else
			out		= ((v & 2 ^ i) ~= 0 and "|" or ".") .. out
		end
	end
	return out
end


-- returns [cpu address], [physical PRG address] of the next stack RTS destination
function getReturnAddress(frame)
	local sp = cpuregisters.sp
	local frame = frame or 0
	-- emu.log(string.format("sp %02X f %02X", sp, frame))
	if (sp + frame >= 0x100) then return nil end
	local retaddr = mem.word[0x100 + sp + frame + 1]
	return retaddr, (retaddr >= 0x8000 and emu.convertAddress(retaddr).address or false)
end



function table.flip(t)
	local out = {}
	for k, v in pairs(t) do
		out[v] = k
	end
	return out
end


-- function hook