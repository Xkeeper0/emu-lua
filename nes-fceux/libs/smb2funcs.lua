

function getWorldLevelArea(level, area, page)
	local world	= math.floor(level / 3) + 1
	local worldlev	= (level % 3) + 1
	return string.format("%d-%d-%d", world, worldlev, area) .. (page and string.format(":%d", smb2.currentPage) or "")
end


local TileQuadPointers	= memory.readword(tileQuadPointer)	-- special pointer in ASM :^)
TileQuads			= {}
do
	local function readTileQuads()
		local qp = {}
		for i = 0, 3 do
			qp[i]	= memory.readbyte(TileQuadPointers + i + 4) * 0x100 + memory.readbyte(TileQuadPointers + i)
			for t = 0, 0x3F do
				local tnum = t + (i * 0x40);
				TileQuads[tnum]	= {}
				for qt = 0, 3 do
					TileQuads[tnum][qt]	= memory.readbyte(qp[i] + t * 4 + qt)
				end
			end
		end
	end
	readTileQuads()
end



function tileXYAddr(x, y)
	local cXPage	= math.floor(x / 16)
	local cXTile	= x % 16
	local cYPage	= math.floor(y / 15)
	local cYTile	= y % 15
	local cMem		= 0x6000 + (cXPage * 0xF0) + (cYPage * 0xF0) + (cYTile * 0x10) + (cXTile)
	return cMem
end

function getAttribute(x, y)
	-- get the upper left corner
	local tempX	= AND(x, 0xFE)
	local tempY	= AND(y, 0xFE)
	local t1	= math.floor(memory.readbyte(tileXYAddr(tempX    , tempY)) / 0x40)
	local t2	= math.floor(memory.readbyte(tileXYAddr(tempX + 1, tempY)) / 0x40)
	local t3	= math.floor(memory.readbyte(tileXYAddr(tempX    , tempY + 1)) / 0x40)
	local t4	= math.floor(memory.readbyte(tileXYAddr(tempX + 1, tempY + 1)) / 0x40)
	return t1 + (t2 * 0x04) + (t3 * 0x10) + (t4 * 0x40)
	
end

function writeLevelTile(x, y, tile)
	local cMem		= tileXYAddr(x, y)
	local cVal		= memory.readbyte(cMem)

	if cVal == tile then
		return false
	end

	local cXPage	= math.floor(x / 16)
	local cXTile	= x % 16
	local cYPage	= math.floor(y / 15)
	local cYTile	= y % 15
	local pBase		= 0x2000 + ((1 - cXPage % 2) * 0x400) + ((1 - cYPage % 2) * 0x800)
	local pMem		= pBase + (cXTile * 0x02) + (cYTile * 0x40)
	
	local pAttX		= math.floor(cXTile / 2)	-- 0~7
	local pAttY		= math.floor(cYTile / 2)	-- 0~7
	local pAttr		= pBase + 0x3C0 + pAttY * 0x08 + pAttX

	memory.writebyte(cMem, tile)
	local attrib	= getAttribute(x, y)
	-- print(string.format("%04X => %02X (%02X), %04X // %04X %02X", cMem, tile, cVal, pMem, pAttr, attrib))
	writePPUTile(pMem, TileQuads[tile], pAttr, attrib)
	return true
end

function writePPUTile(addr, tile, attrAddr, attrib)
	memory.writebyte(0x2006, math.floor(addr / 0x100))
	memory.writebyte(0x2006, addr % 0x100)
	memory.writebyte(0x2007, tile[0])
	memory.writebyte(0x2007, tile[1])
	memory.writebyte(0x2006, math.floor((addr + 0x20) / 0x100))
	memory.writebyte(0x2006, (addr + 0x20) % 0x100)
	memory.writebyte(0x2007, tile[2])
	memory.writebyte(0x2007, tile[3])

	memory.writebyte(0x2006, math.floor((attrAddr) / 0x100))
	memory.writebyte(0x2006, (attrAddr) % 0x100)
	memory.writebyte(0x2007, attrib)
end
