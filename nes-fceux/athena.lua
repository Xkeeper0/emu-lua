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


MAXOBJS		= 0x20



function newObject(index)

	local objectCollection	= MemoryCollection {
		xhi	= MemoryAddress.new(0x0771 + index, "byte", false),
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
	xhi	= MemoryAddress.new(0x0060, "byte", false),
	xlo	= MemoryAddress.new(0x00E7, "byte", false),
	}



function plasterOntoScreen(objectx, objecty, camerax, cameray, caption)
	-- Hey did you know that since the game uses the braindamaged
	-- onscreen coordinates system no further transforms are needed?
	-- w o w

	local x = objectx - camerax
	local y = objecty - cameray
	gui.line(x - 4, y    , x + 4, y    , "red")
	gui.line(x    , y - 4, x    , y + 4, "red")
	if caption then
		gui.text(x + 3, y + 3, caption)
	end
end




while true do

	local camx	= camera.xhi * 0x100 + camera.xlo


	for i = 0, MAXOBJS do
		local xpos	= objects[i].xhi * 0x100 + objects[i].xlo
		local ypos	= objects[i].y
		--gui.text(0, 10 * i, string.format("%X : %04X %02X", i, xpos, ypos))
		plasterOntoScreen(xpos, ypos, camx, 0, string.format("%X", i))
	end

	gui.text(200, 8, string.format("%04X", camx))


	emu.frameadvance()

end




