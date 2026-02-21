

dungeon		= MemoryCollection.new{
	seed	= MemoryAddress.new(0x016),
	xy		= MemoryAddress.new(0x018),

	c		= MemoryAddress.new(0x011),
	u		= MemoryAddress.new(0x012),
	r		= MemoryAddress.new(0x013),
	d		= MemoryAddress.new(0x014),
	l		= MemoryAddress.new(0x015),
	}

local function xysplit(xy)
	return { x = xy % 0x10, y = math.floor(xy / 0x10) }
end
local function xycombine(x, y)
	return (x + 0x10) % 0x10 + ((y + 0x10) % 0x10) * 0x10
end

local function fungeroomtype(seed, x, y)
	local tmp	= seed
	local pos	= xycombine(x, y)
	for i = 1, pos do
		tmp			= ((tmp * 5) + 1) % 0x100
	end
	return tmp
end
local function funge2(seed, num)
	local a		= (num + seed) % 0x100
	local tmp = a
	a			= AND(a, 0xF0)
	if a < 0x23 or a == 0x40 or a == 0x80 then
		return OR(tmp, 0xF0)
	end
	return tmp
end


local function makedungeonmap(seed)
	local dmap		= {}
	for y = 0, 0xF do
		dmap[y]		= {}
		for x = 0, 0xF do
			local rtype	= funge2(seed, fungeroomtype(seed, x, y))
			dmap[y][x]	= rtype
		end
	end
	return dmap
end


local mapscale	= 8
local mapx		= 100
local mapy		= 100
local df		= { WEST = 0x80, NORTH = 0x10, EAST = 0x20, SOUTH = 0x40 }
local roomborder	= "white"
local roomfill		= "blue"
local doorline		= "blue"
local dp			= 3
local thisdmap		= nil
function drawmaproom(x, y, t, flash)
	local y		= 0xF - y			-- game is backwards
	local xpl	= mapx + x * mapscale
	local ypt	= mapy + y * mapscale
	local xpr	= xpl + mapscale - 1
	local ypb	= ypt + mapscale - 1
	local fill	= flash and "red" or roomfill
	gui.box(xpl, ypt, xpr, ypb, fill, roomborder)

	if AND(t, df.NORTH) ~= 0 then	gui.line(xpl +dp, ypt    , xpr -dp, ypt    , doorline);		end
	if AND(t, df.SOUTH) ~= 0 then	gui.line(xpl +dp, ypb    , xpr -dp, ypb    , doorline);		end
	if AND(t, df.WEST ) ~= 0 then	gui.line(xpl    , ypt +dp, xpl    , ypb -dp, doorline);		end
	if AND(t, df.EAST ) ~= 0 then	gui.line(xpr    , ypt +dp, xpr    , ypb -dp, doorline);		end

end

function showdungeonrooms()
	local xp	= 200
	local yp	= 50

	gui.text(xp +   0, yp +   0, hexs(dungeon.c))
	gui.text(xp +   0, yp +   8, hexs(dungeon.d))
	gui.text(xp +   0, yp -   8, hexs(dungeon.u))
	gui.text(xp -  16, yp +   0, hexs(dungeon.l))
	gui.text(xp +  16, yp +   0, hexs(dungeon.r))

	-- drawmaproom(  0,   0,   dungeon.c)
	-- drawmaproom(  0,   1,   dungeon.d)
	-- drawmaproom(  0,  -1,   dungeon.u)
	-- drawmaproom( -1,   0,   dungeon.l)
	-- drawmaproom(  1,   0,   dungeon.r)

end


function dungeonhandler()
	showdungeonrooms()

	if input.pressed("N") then
		dungeon.seed	= dungeon.seed + 1
		thisdmap	= makedungeonmap(dungeon.seed)
	end
	if thisdmap then
		local ourloc	= false
		for y = 0, 0xF do
			for x = 0, 0xF do
				ourloc	= xycombine(x, y) == dungeon.xy
				drawmaproom(x, y, thisdmap[y][x], ourloc)
			end
		end
	end

end