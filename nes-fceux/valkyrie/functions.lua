
function lifebar(x, y, sx, sy, a1, a2, oncolor, offcolor, outerborder, innerborder)
	-- function drawBar(x, y, w, h, min, max, val, fill, marker, background, border, outline)
	drawBar(x, y, sx, sy, 0, a2, a1, oncolor, "white", offcolor, outerborder and outerborder or "clear")
end


function hpwidth(hp, wmin, wmax)
	local val	= ((math.max(32, hp) - 32) / 967) ^ 0.7 --((hp - 32) / 967)
	return math.ceil((val * (wmax - wmin)) + wmin)
end
function enemyhpwidth(hp, wmin, wmax)
	local val	= clamp((math.max(1, hp - 8) / 246) ^ 0.7, 0, 1)
	return math.ceil((val * (wmax - wmin)) + wmin)
end


-- stored as single digits per byte, 00-09, e.g. 04 03 02 01 = 1234
function memory.readvnb(offset, length)
	local val		= 0

	for i = 0, length do
		local inp	= memory.readbyte(offset + (i))
		if (inp ~= 0x26) then val = val + inp * (10 ^ i); end
	end
	return val
end
function memory.writevnb(offset, length, val)
	local val = clamp(val, 0, (10 ^ (length + 1)) - 1)
	for i = 0, length do
		local tmp = (val / (10 ^ i)) % 10
		-- write spaces instead of 0s
		if (val < (10 ^ (i - 1))) then tmp = 0x26; end
		memory.writebyte(offset + (i), tmp)
	end
	return val
end

function getspawnflag(num, uw)
	return mem.byte[0x600 + num + (uw and 0x40 or 0)]
end


function getEnemySpawns(x, y, inUW)
	local bOfs	= 0x9CB7 + (inUW and 0x90 or 0)
	local xh	= AND(0x0F, math.floor(x / 0x100))
	local yh	= AND(0x07, math.floor(y / 0x100)) * 0x10
	local sOfs	= bOfs + (yh + xh)
	return mem.byte[sOfs]
end

