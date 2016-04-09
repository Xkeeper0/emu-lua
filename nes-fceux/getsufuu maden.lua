
direction	= {}
direction[0]	= "N"
direction[1]	= "E"
direction[2]	= "S"
direction[3]	= "W"


map	= {}


-- Add a tile to the "known" map
function mapTileAdd(x, y)
	if not map[x] then
		map[x]	= {}
	end

	map[x][y]	= true
end

function mapTileCheck(x, y)
	if not map[x] then
		return false
	
	elseif not map[x][y] then
		return false

	else
		return map[x][y]
	end
end



function drawMap(px, py)
	local mTile	= 4
	local mTop	= 40
	local mLeft	= 210
	local mSize	= 5
	local mFill	= mSize - 1

	function doSquare(x, y)
		local mtx	= mLeft + (mSize * (x + mTile))
		local mty	= mTop + (mSize * (y + mTile))
		local c	= "#000000"
		local d	= "gray"
		if mapTileCheck(px + x, py + y) then
			c	= "white"
		end
		if x == 0 and y == 0 and memory.readbyte(0x00e1) % 0x10 >= 0x08 then
			c	= "red"
			d	= "white"
		end

		gui.box(mtx, mty, mtx + mSize, mty + mSize, d)
		gui.box(mtx + 1, mty + 1, mtx + mFill, mty + mFill, c)
	end

	for x = -mTile, mTile do
		for y = -mTile, mTile do
			doSquare(x, y)
		end
	end

	doSquare(0, 0)

end




while true do

	mazeX	= memory.readbyte(0x0020)
	mazeY	= memory.readbyte(0x0021)

	mapTileAdd(mazeX, mazeY)
	drawMap(mazeX, mazeY)

	exp		= memory.readbyte(0x07F1)
	hp		= memory.readbyte(0x07D3)
	level	= memory.readbyte(0x07D2)

	mazedir	= memory.readbyte(0x07D8)

	gui.box(  1,  15,  96,  24, "black")
	gui.box(  1,  31,  96,  39, "black")

	exppct	= (exp / 256) * (95 - 32)
	gui.box(32, 16, 95, 22, "#2222aa")
	if exppct > 0 then
		gui.box(32, 16, 32 + exppct, 22, "#8080ff")
	end

	hppct	= (hp / 64) * (95 - 32)
	gui.box(32, 32, 95, 38, "#440000")
	if hppct > 0 then
		gui.box(32, 32, 32 + hppct, 38, "red")
	end

	gui.text(  2,  16, string.format("Lv %2d", level), "white", "clear")
	gui.text( 20,  32, "HP", "white", "clear")

	gui.text( 78,  16, string.format("%3d", exp), "black", "clear")
	gui.text( 77,  16, string.format("%3d", exp), "white", "clear")

	gui.text( 78,  32, string.format("%3d", hp), "black", "clear")
	gui.text( 77,  32, string.format("%3d", hp), "white", "clear")


	gui.text(240,  27, direction[mazedir])


	--[[
	-- cheat HP
	memory.writebyte(0x07D3, 32)

	-- show mouse coordinates
	i	= input.get()
	gui.text(2, 200, string.format("%3d %3d", i.xmouse, i.ymouse))
	gui.line(i.xmouse + 0, i.ymouse + 0, i.xmouse + 3, i.ymouse    , "white")
	gui.line(i.xmouse + 0, i.ymouse + 0, i.xmouse    , i.ymouse + 3, "white")
	gui.line(i.xmouse + 1, i.ymouse + 1, i.xmouse + 4, i.ymouse + 1, "black")
	gui.line(i.xmouse + 1, i.ymouse + 1, i.xmouse + 1, i.ymouse + 4, "black")
	--]]


	emu.frameadvance()

end