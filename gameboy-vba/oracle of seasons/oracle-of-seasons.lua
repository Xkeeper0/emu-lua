
    local Sprite	= require("oracle-of-seasons-sprite")
    spriteList		= require("oracle-of-seasons-enemy-list")



	function getCurrentGameShit()

		return {
			gameTime		= memory.readdword(0xc622),

			levelBank		= memory.readbyte(0xc63a),
			overworldScreen	= memory.readbyte(0xc63b),

			enemiesSinceMaple	= memory.readbyte(0xc6e3),
			-- The RAM map helpfully says that addresses
			-- C64C~C65B are "kills since ???"
			-- probably gasha seeds. probably. maybe

			health			= {
				max			= memory.readbyte(0xc6a3),
				current		= memory.readbyte(0xc6a2),
				},

			-- this is all really exciting, sorry

			enemiesOnScreen	= memory.readbyte(0xcc30),

			-- Fun Addresses:
			-- C700-C7FF: overworld screen flags (or w/e)
			-- CE00-CEAF: "screen collision data". sounds good
			-- CF00-CFAF: "screen tile data". gonna make some art
		}

		-- please don't crash
	end


	function getCameraShit()

		return {
			-- c48d/c48c stop matching "real cam" after a screen transition
			--x	= memory.readbyte(0xc48d),
			--y	= memory.readbyte(0xc48c),
			x	= memory.readbyte(0xffaa),
			y	= memory.readbyte(0xffa8),
			}
	end


	function getPlayerShit()
		-- todo: s/shit/something less dumb/

		-- apparently coordinates are not screen-relative, maybe.
		-- time to go look through a cave, fart
		return {
			x	= memory.readbyte(0xd00d),
			y	= memory.readbyte(0xd00b),
			z	= memory.readbytesigned(0xd00f),
			}

	end


	function setPlayerShit(x, y, z, zs)
		memory.writebyte(0xd00d, x)
		memory.writebyte(0xd00b, y)
		memory.writebyte(0xd00f, z)
		if zs then memory.writebyte(0xd015, zs) end

	end


	function cameraToScreen(camera, Sprite)
		-- assume "camera" and "Sprite" have simple x, y coords
		return {
			x	= (Sprite.x - camera.x + 0x100) % 0x100,
			y	= (Sprite.y - camera.y + 0x110) % 0x100,
			}

	end

	function screenToCamera(camera, Sprite)
		-- this will not work. cameras are hard.
		return {
			x	= (Sprite.x + camera.x + 0x100) % 0x100,
			y	= (Sprite.y + camera.y + 0x0F0) % 0x100,

		}
	end

	function drawSpriteMarker(Sprite, color, precalc, size, text)
		local obj	= Sprite

		local sz	= size and size or 2

		if not precalc then
			obj	= cameraToScreen(getCameraShit(), Sprite)
		end

		gui.line(obj.x - sz, obj.y, obj.x + sz, obj.y, color)
		gui.line(obj.x, obj.y - sz, obj.x, obj.y + sz, color)

		if text then
			--gui.text(obj.x + 3, obj.y + 3, text, 0x000000a0, "clear")
			--gui.text(obj.x + 2, obj.y + 2, text, color, "clear")
			gui.text(obj.x + 2, obj.y + 2, text, color, "black")
		end
	end


	function drawSpriteHitbox(Sprite, border, fill)
		local obj	= Sprite
		obj			= cameraToScreen(getCameraShit(), Sprite)
		border		= border and border or "white"
		fill		= fill and fill or "clear"


		gui.box(obj.x - Sprite.hitboxX,
				obj.y - Sprite.hitboxY,
				obj.x + Sprite.hitboxX,
				obj.y + Sprite.hitboxY,
				fill, border)

	end



	function replaceJoypad()
		local keys	= {
			F	= 'A',
			D	= 'B',
			W	= 'L',
			R	= 'R',
			V	= 'start',
			B	= 'select',
			I	= 'up',
			J	= 'left',
			L	= 'right',
			K	= 'down',
			}

		local jp	= {}
		local ipt	= input.get()
		for k,v in pairs(keys) do
			if ipt[k] then
				jp[v]	= true
			end
		end

		joypad.set(1, jp);
	end


	function mouseToScreen(m, camera)

		if not m then
			m = input.get()
		end
		if not camera then
			camera = getCameraShit()
		end


		local temp	= { x = m.xmouse, y = m.ymouse }


		return screenToCamera(camera, temp)

	end

	function hexPrint(v)
		return v and string.format("%02x", v) or "ERR"
	end



	function printCoordinates(Sprite, line, prefix, suffix)
		gui.text(1, 16 + 7 * line, string.format("%s(%2x,%2x) %s", prefix and prefix or "", Sprite.x, Sprite.y, suffix and suffix or ""))

	end

	function printStuff(Sprite, line, prefix, suffix)
		gui.text(1, 16 + 7 * line, string.format("%s %s", prefix and prefix or "", suffix and suffix or ""))

	end

	last	= input.get()
	inpt	= input.get()

	local enemies	= {}
	encount			= 0x3F

	for ix = 0, encount do
		enemies[ix]		= Sprite.new(ix)
	end


	while true do

		replaceJoypad()

		last	= inpt
		inpt	= input.get()

		gameShit	= getCurrentGameShit()
		--[[
		gui.text(1, 113, string.format("health: %d / %d", gameShit.health.current, gameShit.health.max))
		gui.text(1, 121, string.format("current screen: %x (bank %x)", gameShit.overworldScreen, gameShit.levelBank))
		gui.text(1, 129, string.format("enemies on screen: %d", gameShit.enemiesOnScreen))
		gui.text(1, 137, string.format("game time (min): %3.1f", gameShit.gameTime / 3600))
		--]]

		--memory.writebyte(0xc6a2, 0xc)


		player	= getPlayerShit()
		mouse	= mouseToScreen()

		--printCoordinates(player, 0)
		--printCoordinates(getCameraShit(), 1)
		--printCoordinates(mouse, 3)

		if inpt.rightclick then
			setPlayerShit(mouse.x, mouse.y, -6, -1)

		end

		--drawSpriteMarker(player, 0xFFFF00FF)
		drawSpriteMarker(mouse, 0xFF00FFFF)

		local ln	= 0
		local en	= ""
		for i = 0, encount do
			enemies[i]:update()
			local c		= 0xFF0000FF
			if i % 2 == 0 then
				c		= 0xFFFFFFFF
			end

			if enemies[i].data.x ~= 0 or enemies[i].data.type ~= 0 or enemies[i].data.subtype ~= 0 then
				--[[
				if spriteList[enemies[i].data.type] then
					en	= string.format("%02x %02x [%s]", enemies[i].data.subtype, enemies[i].data.type, spriteList[enemies[i].data.type])
				else
					en	= string.format("%02x %02x", enemies[i].data.subtype, enemies[i].data.type)
				end
				--]]

				if (enemies[i].data.hitboxX ~= 0 or enemies[i].data.hitboxY ~= 0) then
					drawSpriteHitbox(enemies[i].data, c - 0x22, "clear")
				end
				drawSpriteMarker(enemies[i].data, c, false, 2, hexPrint(i))

				printStuff(enemies[i].data, ln,
					hexPrint(i) .." ",
					--"O=".. hexPrint(enemies[i]:getOffset()) ..
					--" T=".. hexPrint(enemies[i].data.type) ..
					--" ST="..hexPrint(enemies[i].data.subtype) ..
					" A=".. hexPrint(enemies[i].data.action) ..
					" T=".. hexPrint(enemies[i].data.timer) ..
					" D="..enemies[i].data.damageOnTouch..
					" H="..enemies[i].data.health
					)
				--printCoordinates(enemies[i].data, ln, string.format("%02x ", i))
				ln	= ln + 1
			end
		end

		emu.frameadvance();

	end