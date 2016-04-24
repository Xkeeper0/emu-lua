
-- Minish Cap script
-- Shift + Arrow keys to force-move
-- Objects are displayed with numbers + possile HP value
-- 





m	= {}
p	= {}

function math.constrain(v, min, max)
	return math.min(math.max(v, min), max)
end


-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")



-- Simple 2-byte X/Y position
-- Unlike other earlier games, some of the coordinates are actually based in the "world"
-- so 0,0 isn't "top left" of a room.
camera	= MemoryCollection {
	x	= MemoryAddress.new(0x03000BFA, "word", false),
	y	= MemoryAddress.new(0x03000BFC, "word", false),
	}


-- Technically should just be object[0], though HP/mHP is stored separately
-- todo: add a way to set/unset indexes in a memorycollection (heh)
player	= MemoryCollection {
	x			= MemoryAddress.new(0x0300118C, "dword", false),
	y			= MemoryAddress.new(0x03001190, "dword", false),
	invuln		= MemoryAddress.new(0x0300119d, "byte", false),

	hp			= MemoryAddress.new(0x02002AEA, "byte", false),
	mhp			= MemoryAddress.new(0x02002AEB, "byte", false),

	charm		= MemoryAddress.new(0x02002AF2, "byte", false),
	charmOn		= MemoryAddress.new(0x02002B05, "byte", false),
	picolyte	= MemoryAddress.new(0x02002AF3, "byte", false),
	picolyteOn	= MemoryAddress.new(0x02002B07, "byte", false),

	}


objects	= {}

print(string.format("%08X", 0x03001160 + 0x14 * 0x88))


-- 38: Flags? b00000001 = "talkable"?



-- Actual max limit of objects is unknown, likely 0x50
for i = 0, 0x50 do
	local ofs	= 0x03001160 + i * 0x88
	objects[i]	= MemoryCollection {
		

		objGroup	= MemoryAddress.new(ofs + 0x08, "byte", false),
		objValue	= MemoryAddress.new(ofs + 0x09, "byte", false),
		objParam	= MemoryAddress.new(ofs + 0x0A, "byte", false),

		-- Likely not Z, but "state" or "animation"
		-- 4 happens to be the one for Link jumping
		z		= MemoryAddress.new(ofs + 0x0C, "byte", false),

		-- rotation ( 0^  2>  4v  6< ... in-betweens are probably mid-angles)
		dir		= MemoryAddress.new(ofs + 0x14, "byte", false),

		-- X and Y position in the world; 4 bytes, two for full, two for subpixel
		-- Divide by 0x10000 to get location basically.
		x		= MemoryAddress.new(ofs + 0x2C, "dword", false),
		y		= MemoryAddress.new(ofs + 0x30, "dword", false),

		-- HP value, sometimes used for something else (NPC dialog?)
		hp		= MemoryAddress.new(ofs + 0x45, "byte", false),

		-- Stun and Invuln determine how damage works?
		-- Setting both to 0 makes enemies able to take damage immediately
		-- Setting stun to 0 makes them almost "ignore" getting hit (so they keep moving)
		-- Invuln doesn't seem to do anything by itself
		stun	= MemoryAddress.new(ofs + 0x42, "byte", false),
		invuln	= MemoryAddress.new(ofs + 0x3d, "byte", false),

		-- random values for testing
		unk1	= MemoryAddress.new(ofs + 0x4A, "byte", false),
		unk2	= MemoryAddress.new(ofs + 0x4B, "byte", false),

		v05		= MemoryAddress.new(ofs + 0x05, "byte", false),
		v26		= MemoryAddress.new(ofs + 0x26, "byte", false),

		v48		= MemoryAddress.new(ofs + 0x48, "byte", false),

		}

end


-- Print a simple header for dumping a sprite's data
do
	local prt	= ""
	for i = 0, 0x87 do
		prt	= prt .. string.format(" %02X", i)
	end

	print(string.format("XX: %s", prt))
end


-- Output every byte of a given object to the "console"
function dumpObject(id, obj)
	local ofs	= 0x03001160 + id * 0x88
	local prt	= ""
	for i = 0, 0x87 do
		prt	= prt .. string.format(" %02X", memory.readbyte(ofs + i))
	end

	print(string.format("%02X: %s", id, prt))
end


-- Draw an object to the screen lazily
function drawObject(id, obj)
	local relx	= (obj.x / 0x10000) - camera.x
	local rely	= (obj.y / 0x10000) - camera.y

	local scrx	= math.constrain(relx, 4, 235)
	local scry	= math.constrain(rely + 5, 0, 153)

	gui.line(relx - 3, rely    , relx + 3, rely    , "white")
	gui.line(relx    , rely - 3, relx    , rely + 3, "white")

	--local xmid	= obj.unk2 / 2

	--gui.line(relx, rely - obj.unk1, relx, rely, "red")
	--gui.line(relx, rely, relx + obj.v26, rely, "red")

	local hbx	= obj.v48 / 0x10
	gui.box(relx - hbx, rely - hbx, relx + hbx, rely + hbx, "clear", "red")

	--obj.v26		= math.random(0x00, 0xFF)

	--obj.unk1	= 0x11
	--obj.unk2	= 0xFF

	gui.text(scrx - 3, scry, string.format("%02X", id))
	--gui.text(scrx - 3, scry, string.format("%02X (%02X:%02X %02X)", id, obj.objGroup, obj.objValue, obj.objParam))
	if obj.hp > 0 and obj.hp ~= 255 then
		gui.text(scrx - 3, scry + 8, string.format("%dhp", obj.hp))
	end


	----[[
	-- Set enemies to have 0 invuln frames
	-- This is really fun with turbo-sword and can break bosses
	if id == 0 then
		obj.v48	= 0x10
		--obj.invuln	= 0x00
		--obj.stun	= 0x00
	end
	--]]

	-- --[[
	if id == 0x00 or id == 0x09 or id == 0x0b or id == 0x0c then
		--dumpObject(id, obj)
	end
	--]]
end


local maxObjectIndexRecord	= 0

while true do

	inpt			= input.get()				-- get current keyboard buttons

	mov				= 0x80000;					-- speed of forced movement

	player.hp		= player.mhp
	player.invuln	= 0x00

	-- Move player in various directions depending on buttons held
	if inpt.shift then
		gui.text(50, 20, "MOVE OK")

		--player.picolyte		= 0x2E
		player.picolyteOn		= 0xFF

		if inpt.Z then
			-- Sets player object "state"?? to "jumping"
			objects[0].z	= 4
		end
		if inpt.up then
			player.y	= (player.y - mov)
		end
		if inpt.down then
			player.y	= (player.y + mov)
		end
		if inpt.left then
			player.x	= (player.x - mov)
		end
		if inpt.right then
			player.x	= (player.x + mov)
		end
	end

	-- Get mouse position in world
	mousepos	= {
		x		= camera.x + inpt.xmouse,
		y		= camera.y + inpt.ymouse,
		}




	-- Print current coordinates to screen
	gui.text(  0, 152, string.format("%4X,%4X", math.floor(player.x / 0x10000), math.floor(player.y / 0x10000)))

	-- Print player health to the screen near the hearts
	gui.text(  8,   0, string.format("%3d/%3d", player.hp, player.mhp))

	-- Show mouse cursor coordinates on screen...
	-- ...as well as their coordinates in-world
	gui.text(204,   0, string.format("%4d,%4d", inpt.xmouse, inpt.ymouse))
	gui.text(204,   7, string.format("%4X,%4X", mousepos.x, mousepos.y))

	local maxObjectIndex	= 0
	local objectCount		= 0
	for objectIndex = 0, 0x50 do
		if objects[objectIndex].x ~= 0 or objects[objectIndex].y ~= 0 then
			drawObject(objectIndex, objects[objectIndex])
			objectCount	= objectCount + 1
			maxObjectIndex	= objectIndex
			maxObjectIndexRecord	= math.max(maxObjectIndexRecord, maxObjectIndex)
		end
	end

	gui.text(160 - 8, 152 - 8, string.format("%2d objs, max %2x (%2x)", objectCount, maxObjectIndex, maxObjectIndexRecord))

	-- Continue emulating game
	emu.frameadvance()

end
