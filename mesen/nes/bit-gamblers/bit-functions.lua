local function readdecimal(from, where, declen)
	-- emu.log(string.format("%s %s %s", tostring(from), tostring(where), tostring(declen)))
	local result = 0
	 	for i = declen, 1, -1 do
		result = (result * 10) + from.byte[where - 1 + i]
	end
	return result
end

local function writedecimal(to, where, declen, value)
	for i = 1, declen do
		to.byte[where - 1 + i] = (value % 10)
		value = math.floor(value / 10)
	end
end



local function createDecimal(memTable)
	local memory = { dec6 = {}, dec5 = {}, dec4 = {}, dec3 = {}, dec2 = {} }
	local memTable = memTable

	function memory.dec6:__index(key)             return readdecimal(memTable, key,  6) end
	function memory.dec6:__newindex(key, value)   return writedecimal(memTable, key, 6, value) end
	function memory.dec5:__index(key)             return readdecimal(memTable, key,  5) end
	function memory.dec5:__newindex(key, value)   return writedecimal(memTable, key, 5, value) end
	function memory.dec4:__index(key)             return readdecimal(memTable, key,  4) end
	function memory.dec4:__newindex(key, value)   return writedecimal(memTable, key, 4, value) end
	function memory.dec3:__index(key)             return readdecimal(memTable, key,  3) end
	function memory.dec3:__newindex(key, value)   return writedecimal(memTable, key, 3, value) end
	function memory.dec2:__index(key)             return readdecimal(memTable, key,  2) end
	function memory.dec2:__newindex(key, value)   return writedecimal(memTable, key, 2, value) end

	setmetatable(memory.dec6, memory.dec6)
	setmetatable(memory.dec5, memory.dec5)
	setmetatable(memory.dec4, memory.dec4)
	setmetatable(memory.dec3, memory.dec3)
	setmetatable(memory.dec2, memory.dec2)

	return memory
end

decmem = createDecimal(mem)
decprg = createDecimal(prg)






local ranks	= { 'a','2','3','4','5','6','7','8','9','T','J','Q','K', 'A' }
local suits = { 'h','s','d','c' }
local colors = { 0xFF0000, 0x000000, 0x0000FF, 0x008800 }

function decodecard(val)
	local suit	= math.floor(val / 0x10) + 1
	local rank	= (val % 0x10) + 1
	if suit > 4 or rank <= 1 or rank > 14 then return string.format("%02X", val), 0xFF0000, 0x660000 end

	return ranks[rank] .. suits[suit], colors[suit], 0xFFFFFF
end

function drawcard(x, y, val)
	local card, cardcolor, cardback = decodecard(val)
	emu.drawString(x, y, card, cardcolor, cardback)
end







sxp	= {}
function sxp.readScrNum2Table(ofs, num)
	-- ScrNum2 table from SXP
	local num = num or 0x19
	local ofs = ofs or 0xF3B4

	--  ofs  sx sy ch len 
	-- 00 01 02 03 04 05

	local co = 0
	local out = {}
	for i = 0, num - 1 do
		co = ofs + 6 * i
		out[i]	= {
			addr	= mem.word[co + 0],
			scrX	= mem.byte[co + 2],
			scrY	= mem.byte[co + 3],
			chrAdd	= mem.byte[co + 4],
			length	= mem.byte[co + 5],
		}
	end

	return out

end