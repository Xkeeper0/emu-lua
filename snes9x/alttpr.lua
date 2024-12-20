--[[

	script that dispalys a number every time you bonk
	in alttp randomized

	version 0
	xkeeper


https://dashboard.twitch.tv/u/xkeeper_/stream-manager
https://twitch.tv/xkeeper_

	https://mikesrpgcenter.com/zelda3/maps.html


	enter room
	hold right (into wall)
	press left 1 frame
	buffer down+right (hold) and use somaria
	press left 1 frame again
	hold down


	down+right (full diagonal at once) then use somaria while holding down+right, but don't hold it longer


--]]

old_gui_text = gui.text
gui.text	= function (...)
	arg[2]	= arg[2] + 1
	old_gui_text(unpack(arg))
end


function clamp(v, l, h)
	return math.max(math.min(v, h), l)
end

--[[

for k,v in pairs(_G) do
	if v ~= _G then
		print(string.format("%s: %s\n", k, tostring(v)))
	end
end
--]]



local bonks	= 0
local playerx, playery = 0
local camerax, cameray = 0
local relativex, relativey = 0
local bonks = 0
local direction = 0
-- 0 - up, 2 - down, 4 - left, 6 - right

local magic		= 0


do
	local bonksHigh = 0

	function trackBonks()
		local b = memory.readbyte(0x7EF420)
		if b > bonksHigh then
			bonksHigh = b
			addBonk()
		end
	end

end


memory.registerwrite(0x7EF420, trackBonks)



do
	local bonkNotices	= {}

	local dirTable		= {}
	dirTable[0]			= { x =  0, y = -2 }
	dirTable[2]			= { x =  0, y =  2 }
	dirTable[4]			= { x = -2, y =  0 }
	dirTable[6]			= { x =  2, y =  0 }

	function drawBonks()
		local rem = nil

		for i, b in pairs(bonkNotices) do
			if (b.l < 0) then
				rem = i
			else
				b.l		= b.l - 1

				b.x		= clamp(b.x + b.xs, 6, 240)
				b.y		= clamp(b.y + b.ys, 6, 214)
				b.z		= b.z + b.zs

				b.xs	= b.xs * 0.97
				b.ys	= b.ys * 0.97

				if (b.zs ~= 0) then
					b.zs	= (b.zs - 0.20)
				end
				if (b.z < 0) then
					b.zs	= -(b.zs * 0.6)
					if (b.zs < 1) then
						b.zs = 0
					end
					b.z		= 0
				end

				local bsiz = (string.len(b.t) * 4) + 1
				gui.box(b.x - 3, b.y - b.z - 0, b.x + bsiz, b.y - b.z + 6, "black")
				gui.text(b.x, b.y - b.z, b.t)
			end
		end

		if rem then
			table.remove(bonkNotices, rem)
		end
	end


	function addBonk()
		local sx, sy = getScreenCoords()
		local linkDir = memory.readbyte(0x7E002F)
		local bonks		= memory.readbyte(0x7EF420)


		local newBonk = {
			x	= sx + 8,
			y	= sy,
			z	= 0,
			xs	= dirTable[linkDir].x,
			ys	= dirTable[linkDir].y,
			zs	= -5,
			t	= string.format("%s", bonks),
			l	= 90,
			}
		table.insert(bonkNotices, newBonk)

		--[[
		-- if you uncomment this you will eat one heart every time you bonk
		local dam = memory.readbyte(0x7E0373)
		dam = clamp(dam + 8, 0, 0xFF)
		memory.writebyte(0x7E0373, dam)
		--]]

	end
end



do
	local chestNotices	= {}

	local dirTable		= {}
	dirTable[0]			= { x =  0, y = -2 }
	dirTable[2]			= { x =  0, y =  2 }
	dirTable[4]			= { x = -2, y =  0 }
	dirTable[6]			= { x =  2, y =  0 }

	function drawChests()
		local rem = nil

		for i, b in pairs(chestNotices) do
			if (b.l < 0) then
				rem = i
			else
				b.l		= b.l - 1

				if (b.zs ~= 0) then
					b.zs	= math.min(b.zs * 0.95 + 0.015, 0)
					b.z		= b.z + b.zs
				end

				local bsiz = (string.len(b.t) * 4) + 1
				local efy	= clamp(b.y + b.z, 8, 224)	-- effective y
				--gui.box(b.x - 3, efy - 0, b.x + bsiz, efy + 6, "white")
				gui.text(b.x, efy, b.t, "black", "white")
			end
		end

		if rem then
			table.remove(chestNotices, rem)
		end
	end


	function addChest(num)
		local sx, sy = getScreenCoords()


		local newChest = {
			x	= sx + 6,
			y	= sy,
			z	= -14,
			zs	= -2.4,
			t	= string.format("%s", num),
			l	= 90,
			}
		table.insert(chestNotices, newChest)

	end
end



function getScreenCoords()
	-- realtalk i have no idea how any of this works
	-- link's coordinates are absolute in the world,
	-- the camera coordinates are very much not
	-- maybe using the wrong values or missing other stuff
	local playerx	= memory.readword(0x7E0022)
	local playery	= memory.readword(0x7E0020)

	local camerax	= memory.readword(0x7E061C)
	local cameray	= memory.readword(0x7E0618)

	local relativex	= ((0x200 + (playerx % 0x200) - (camerax % 0x200)) + 0x80) % 0x100
	local relativey	= ((0x200 + (playery % 0x200) - (cameray % 0x200)) + 0x80) % 0x100

	return relativex, relativey
end


function memory.read4word(addr)
	return memory.readword(addr + 2) * 0x10000 + memory.readword(addr)
end

function formatTime1(t)
	t = t / 60
	if t < 60 then
		-- 0:00:00.00
		--      00.00
		--   00:00.00
		-- 0:00:00.00
		return string.format("     %5.2f", t)
	elseif t < 3600 then
		return string.format("  %2d:%05.2f", math.floor(t / 60), t % 60)
	else
		return string.format("%d:%02d:%05.2f", math.floor(t / 3600), math.floor((t / 60) % 60), t % 60)
	end
end

lastLagTime		= 0
showLagTimer	= 0
lastMenuTime	= 0
showMenuTimer	= 0
lastItemTotal	= 0
showItemTimer	= 0
timerAdj		= 0

--while true do
function x()


	playerx		= memory.readword(0x7E0022)
	playery		= memory.readword(0x7E0020)
	camerax		= memory.readword(0x7E061C)
	cameray		= memory.readword(0x7E0618)
	camerax2	= memory.readword(0x7E061E)
	cameray2	= memory.readword(0x7E061A)

	statsLocked	= memory.readbyte(0x7EF443)

	heartpieces	= memory.readbyte(0x7EF36B)		-- 00 01 02 03
	HPmax		= memory.readbyte(0x7EF36C)		-- 1 heart = 08, max = A0
	HP			= memory.readbyte(0x7EF36D)
	magic		= memory.readbyte(0x7EF36E)		-- max = 80?
	bonks		= memory.readbyte(0x7EF420)		-- max = 255

	itemTotal	= memory.readbyte(0x7EF423)

	timeNoLag	= memory.read4word(0x7EF42E)	-- loopframes
	timeReal	= memory.read4word(0x7EF43E)	-- NMIFrames
	timeLag		= timeReal - timeNoLag
	timeMenu	= memory.read4word(0x7EF444)	-- MenuFrames

	if itemTotal ~= 0 or lastItemTotal == 0 then
		if itemTotal ~= lastItemTotal then
			lastItemTotal	= itemTotal
			showItemTimer	= 60
			addChest(lastItemTotal)
		end
	end


	local col1, col2	= "white", "black"
	if showItemTimer > 0 then
		showItemTimer	= showItemTimer - 1
		if showItemTimer >= 30 then
			local tmp = showItemTimer - 30
			if (tmp % 10 >= 5) then
				col1, col2	= "white", "#7f7f7f"
			else
				col1, col2	= "#7f7f7f", "white"
			end
		else
			col1, col2	= "white", "#7f7f7f"
		end
	end

	gui.text(127, 0, string.format("/216", lastItemTotal), "#aaaaaa", "black")
	gui.text(114, 0, string.format("%3d", lastItemTotal), col1, col2)





	gui.text(216, 0, formatTime1(timeReal))
	timerAdj	= 0
	if timeLag ~= lastLagTime then
		showLagTimer	= 60
		gui.text(216, 7, formatTime1(timeLag), "white", "red")
		timerAdj	= 7
	elseif showLagTimer > 0 then
		showLagTimer	= showLagTimer - 1
		gui.text(216, 7, formatTime1(timeLag), "#ff4444", "black")
		timerAdj	= 7

	end

	if timeMenu ~= lastMenuTime then
		showMenuTimer	= 120
		gui.text(216, 7 + timerAdj, formatTime1(timeMenu), "white", "#00aa00")
	elseif showMenuTimer > 0 then
		showMenuTimer	= showMenuTimer - 1
		gui.text(216, 7 + timerAdj, formatTime1(timeMenu), "green", "#000000")
	end

	lastLagTime		= timeLag
	lastMenuTime	= timeMenu

--		gui.text(216, 8, formatTime1(timeLag))
--	gui.text(216, 15, formatTime1(timeMenu))



	-- relativex	= (playerx % 0x1000) - camerax + 0x80
	-- relativey	= (playery % 0x1000) - cameray + 0x80
	relativex	= ((0x200 + (playerx % 0x200) - (camerax % 0x200)) + 0x80) % 0x100
	relativey	= ((0x200 + (playery % 0x200) - (cameray % 0x200)) + 0x80) % 0x100

	--gui.text(1, 1, string.format("Link %04X %04X\nCam  %04X %04X\nRel  %04X %04X", playerx, playery, camerax, cameray, relativex, relativey))

	--gui.text(relativex, relativey, "x")

	--gui.text(1, 220, string.format("Bonks: %d", bonks))

	-- gui.text(8, 20, string.format("%3d", magic), "white", "#00a000")


	--[[
	local hpMW	= math.floor(HPmax)
	local hpW	= math.floor(HP)
	local hpN	= math.floor((HP / 8) * 10)
	local hpMN	= math.floor((HPmax / 8) * 10)

	local mpW	= magic
	local mpMW	= 128

	gui.box(0, 0, 11, 12, "black")

	gui.box(12, 0, 12 + hpMW + 3, 4, "#aa0000", "black")
	if (hpW > 0) then
		gui.box(13, 1, 13 + hpW  + 1, 3, "#ff6666")
		gui.line(13 + hpW  + 1, 1, 13 + hpW  + 1, 3, "white")
	end
	
	gui.box(12, 4, 12 + mpMW + 3, 8, "#006600", "black")
	if (mpW > 0) then
		gui.box(13, 5, 13 + mpW  + 1, 7, "#22ff22")
		gui.line(13 + mpW  + 1, 5, 13 + mpW  + 1, 7, "white")
	end
	gui.text(0, 6, string.format("%3d", magic), "#22ff22", "#004400")
	gui.text(0, 0, string.format("%3d", hpN), "white", "#aa0000")
	--]]


	drawBonks()
	drawChests()
--	emu.frameadvance()
end

gui.register(x)

-- ...sers\Revya\Documents\Repos\emu-lua\snes9x\alttpr.lua:16:
--		attempt to call field 'frameadvance' (a nil value)
