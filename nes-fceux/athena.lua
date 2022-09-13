--[[
      Athena by Micronics

    (   )         _     _ _   
  (   ) (        | |   (_) |  
   ) _   )    ___| |__  _| |_ 
    ( \_     / __| '_ \| | __|
  _(_\ \)__  \__ \ | | | | |_ 
 (____\___)) |___/_| |_|_|\__|


	00B6	Incremented every time a block is damaged
			Doesn't seem to be read???








--]]

-- Fix FCEUX fuckups
require("libs/toolkit")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")


MAXOBJS				= 0x20


screenDataOffsets	= {}
screenDataOffsets[0]	= { 0x584, 0x51C }
screenDataOffsets[1]	= { 0x5F9, 0x591 }




function newObject(index)

	local objectCollection	= MemoryCollection {
		xHi	= MemoryAddress.new(0x0771 + index, "byte", false),
		xlo	= MemoryAddress.new(0x0788 + index, "byte", false),
		y	= MemoryAddress.new(0x075a + index, "byte", false),
		}

	return objectCollection

end


objects		= {}

for i = 0, MAXOBJS do
	objects[i]	= newObject(i)
end



local camera	= MemoryCollection {
	xLo			= MemoryAddress.new(0x00e7, "byte", false),
	xHi			= MemoryAddress.new(0x0060, "byte", false),
	onBottom	= MemoryAddress.new(0x00e8, "byte", false),
	}



function plasterOntoScreen(objectx, objecty, camerax, cameray, caption)
	-- coordinates are already based on screen position, not world position
	
	local x = objectx - camerax
	local y = objecty - cameray
	gui.line(x - 4, y    , x + 4, y    , "red")
	gui.line(x    , y - 4, x    , y + 4, "red")
	if caption then
		gui.text(x + 3, y + 3, caption, "red", "black")
	end
end




function drawTileGrid()
	local camX		= camera.xHi * 0x100 + camera.xLo
	local bottom	= camera.onBottom
	if bottom > 1 then
		error(string.format("unexpected bottom value %02X", bottom))
	end

	local offsets	= screenDataOffsets[bottom]

	local memOfs	= 0
	local value		= 0
	for y = 0, 12 do
		for x = 0, 7 do
			memOfs	= y * 8 + x
			value	= memory.readbyte(offsets[2] + memOfs)
			drawTileSquare(x * 2 + 0, y, math.floor(value / 0x10))
			drawTileSquare(x * 2 + 1, y, value % 0x10)
		end
	end
end

function drawTileSquare(x, y, type)
	if type ~= 0 then
		x = ((x * 16 - camera.xLo) % 0x100)
		y	= (y + 2) * 16
		gui.box(x, y, x + 15, y + 15, "clear", "white")
		gui.text(x + 2, y + 2, string.format("%X", type))
	end
end



trackCount = 0
function trackStatus()
	local regX = memory.getregister("x")
	local num  = regX / 2
	local mem1 = memory.readbyte(0x0002 + regX)
	local mem2 = memory.readbyte(0x0003 + regX)

	local procStr	= ""
	if mem1 == 0x80 then
		-- data is pulled in order
		--+1 2 3 4 5/6
		-- Y X A P (rts)
		local stackOfs	= 0x100 + mem2
		local saveY		= memory.readbyte(stackOfs + 1)
		local saveX		= memory.readbyte(stackOfs + 2)
		local saveA		= memory.readbyte(stackOfs + 3)
		local saveP		= memory.readbyte(stackOfs + 4)
		local savePC	= memory.readword(stackOfs + 5) + 1	-- RTS = +1
		procStr	= string.format("  A=%02X X=%02X Y=%02X P=%02X PC=%04X", saveA, saveX, saveY, saveP, savePC)
	end
	gui.text(0, 8 * num + 4, string.format("%X: X=%X %02X %02X%s", trackCount, regX, mem1, mem2, procStr), "white", mem1 == 0x80 and "#000080" or "black")
	trackCount = trackCount + 1
end

memory.registerexecute(0xC37D, trackStatus)






while true do

	local camX	= camera.xHi * 0x100 + camera.xLo


	for i = 0, MAXOBJS do
		local xpos	= objects[i].xHi * 0x100 + objects[i].xlo
		local ypos	= objects[i].y
		--gui.text(0, 10 * i, string.format("%X : %04X %02X", i, xpos, ypos))
		--plasterOntoScreen(xpos, ypos, camX, 0, string.format("%X", i))
	end

	gui.text(200, 0, string.format("%04X B=%d", camX, camera.onBottom))

	drawTileGrid()

	trackCount	= 0
	emu.frameadvance()

end




