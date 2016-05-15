
-- Fix FCEUX fuckups
require("libs/toolkit")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")



-- Friendly names of above
local playerCharactersN	= { [0]	= 'human', 'dragon', 'golem', 'mouse' }

-- HP / MaxHP values for above charcters
-- Maybe other relevant values, but for now this is it
local playerCharacters	= {}
for i = 0, 3 do
	playerCharacters[i]	= MemoryCollection {
		hp		= MemoryAddress.new(0x0097 + i, "byte", false),
		maxhp	= MemoryAddress.new(0x0093 + i, "byte", false),
		}
end


-- Value for currently selected player character
local player	= MemoryCollection {
	character	= MemoryAddress.new(0x0050, "byte", false),
	relx		= MemoryAddress.new(0x005a, "word", false),
	rely		= MemoryAddress.new(0x0058, "word", false),
	-- games that store player x/y as a relative camera value
	-- are my F-A-V-O-R-I-T-E!!!
	-- (barfing)
	}

local camera	= MemoryCollection {
	x			= MemoryAddress.new(0x002e, "word", false),
	y			= MemoryAddress.new(0x0032, "word", false),
	}


local objects	= {}

for i = 0, 0xF do
	objects[i]		= MemoryCollection {
		state		= MemoryAddress.new(0x0500 + i, "byte", false),
		u10			= MemoryAddress.new(0x0510 + i, "byte", false),
		type		= MemoryAddress.new(0x0520 + i, "byte", false),
		graphics	= MemoryAddress.new(0x0530 + i, "byte", false),
		damage		= MemoryAddress.new(0x0540 + i, "byte", false),
		hp			= MemoryAddress.new(0x0550 + i, "byte", false),
		u60			= MemoryAddress.new(0x0560 + i, "byte", false),
		timer1		= MemoryAddress.new(0x0570 + i, "byte", false),
		u80			= MemoryAddress.new(0x0580 + i, "byte", false),
		timer2		= MemoryAddress.new(0x0590 + i, "byte", false),
		ua0			= MemoryAddress.new(0x05a0 + i, "byte", false),
		ub0			= MemoryAddress.new(0x05b0 + i, "byte", false),
		uc0			= MemoryAddress.new(0x05c0 + i, "byte", false),
		ud0			= MemoryAddress.new(0x05d0 + i, "byte", false),
		direction	= MemoryAddress.new(0x05e0 + i, "byte", false),
		uf0			= MemoryAddress.new(0x05f0 + i, "byte", false),

		-- Technically subpixel data probably
		rely		= MemoryAddress.new(0x0640 + i, "byte", false),
		relysub		= MemoryAddress.new(0x0650 + i, "byte", false),
		relx		= MemoryAddress.new(0x0660 + i, "byte", false),
		relxsub		= MemoryAddress.new(0x0670 + i, "byte", false),

	}

end







function getRealCoordinates(cam, obj)
	return cam.x + obj.relx / 0x100, cam.y + obj.rely / 0x100
end

function coordinatesToScreen(x, y, cam)
	return x - cam.x, y - cam.y
end

function screenToCoordinates(x, y, cam)
	return x + cam.x, y + cam.y
end

function plasterOntoScreen(x, y, caption)
	-- Hey did you know that since the game uses the braindamaged
	-- onscreen coordinates system no further transforms are needed?
	-- w o w
	gui.line(x - 4, y    , x + 4, y    , "red")
	gui.line(x    , y - 4, x    , y + 4, "red")
	if caption then
		gui.text(x + 3, y + 3, caption)
	end
end



while true do


	inputi, inputc	= input.update()
	
	if inputi.rightclick then
		player.relx	= inputc.xmouse * 0x100
		player.rely	= inputc.ymouse * 0x100
	end


	local pc		= player.character

	gui.text(5, 5, string.format("%2X, %2X", inputc.xmouse, inputc.ymouse))
	--gui.text(2, 75, string.format("%02X", pv))
	gui.text(2, 65, string.format("%2d/%2d", playerCharacters[pc].hp, playerCharacters[pc].maxhp))


	gui.text(5, 190, string.format("%4X  /%4X  ", camera.x, camera.y))
	gui.text(5, 200, string.format("  %4X/  %4X", player.relx, player.rely))

	local px, py	= getRealCoordinates(camera, player)
	local sx, sy	= coordinatesToScreen(px, py, camera)
	gui.text(5, 210, string.format("%04X  /%04X  ", px, py))

	plasterOntoScreen(sx, sy)


	for i = 0, 0xF do
		local state	= objects[i].state
		if state ~= 0x00 then
			local ex	= objects[i].relx
			local ey	= objects[i].rely
			plasterOntoScreen(ex, ey, string.format("%X %02X %02X", i, state, objects[i].type))
		end
	end



	emu.frameadvance()
end




