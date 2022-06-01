-- copy paste ez functions because coding is hard

function rb(a)
	return memory.readbyte(a)
end

function rw(a)
	return memory.readword(a)

end

function r2(a2, a1)
	return rb(a1) * 0x100 + rb(a2)

end


function fb(v)
	return string.format("%02X", v)
end

function fw(v)
	return string.format("%04X", v)
end




function getCamera()
	return {
		x	= r2(0x00fc, 0x00fd),
		y	= r2(0x00fa, 0x00fb),
		}
end



function getObjectFlags(flags)

	local flagDef	= {}
	flagDef[0x0001]	= "0001"
	flagDef[0x0002]	= "0002"
	flagDef[0x0004]	= "0004"
	flagDef[0x0008]	= "0008"
	flagDef[0x0010]	= "0010"
	flagDef[0x0020]	= "0020"
	flagDef[0x0040]	= "0040 damagable"
	flagDef[0x0080]	= "0080 solid"
	flagDef[0x0100]	= "0100 action A"
	flagDef[0x0200]	= "0200 action B"
	flagDef[0x0400]	= "0400"
	flagDef[0x0800]	= "0800"
	flagDef[0x1000]	= "1000"
	flagDef[0x2000]	= "2000"
	flagDef[0x4000]	= "4000 damages"
	flagDef[0x8000]	= "8000 active"

	local objFlags	= {}
	for k, v in pairs(flagDef) do
		if AND(flags, k) ~= 0 then
			table.insert(objFlags, v)
		end
	end

	return objFlags


end



function getObjects()

	local objects	= {}

	for objId = 0, 0xF do
		local baseOfs	= objId

		objects[objId]	= {
			--[[
			un400	= rb(0x0400 + baseOfs),
			un410	= rb(0x0410 + baseOfs),
			--]]
			animSet	= rb(0x0420 + baseOfs),
			--[[
			un430	= rb(0x0430 + baseOfs),
			un440	= rb(0x0440 + baseOfs),
			un450	= rb(0x0450 + baseOfs),
			un460	= rb(0x0460 + baseOfs),
			un470	= rb(0x0470 + baseOfs),
			un480	= rb(0x0480 + baseOfs),
			un490	= rb(0x0490 + baseOfs),
			un4a0	= rb(0x04a0 + baseOfs),
			un4b0	= rb(0x04b0 + baseOfs),
			un4c0	= rb(0x04c0 + baseOfs),
			--]]
			type	= rb(0x04e0 + baseOfs),
			flagsR	= r2(0x0570 + baseOfs, 0x04d0 + baseOfs),
			flags	= getObjectFlags(
						r2(0x0570 + baseOfs, 0x04d0 + baseOfs)
						),
			x		= r2(0x04f0 + baseOfs, 0x0500 + baseOfs),
			y		= r2(0x0510 + baseOfs, 0x0520 + baseOfs),
			--[[
			un530	= rb(0x0530 + baseOfs),
			un540	= rb(0x0540 + baseOfs),
			un550	= rb(0x0550 + baseOfs),
			un560	= rb(0x0560 + baseOfs),
			un570	= rb(0x0570 + baseOfs),
			un580	= rb(0x0580 + baseOfs),
			un590	= rb(0x0590 + baseOfs),
			un5a0	= rb(0x05a0 + baseOfs),
			un5b0	= rb(0x05b0 + baseOfs),
			un5c0	= rb(0x05c0 + baseOfs),
			un5d0	= rb(0x05d0 + baseOfs),
			un5e0	= rb(0x05e0 + baseOfs),
			un5f0	= rb(0x05f0 + baseOfs),
			--]]
		}

		--[[
			0410	P1 animation frame or some other bullshit
			0420	P1 probably more animation bullshit.
			0430	P1 animation timer or some crap
			0440	P1 fake sprite Y? what even.
					Locking it keeps the sprite in a certain space,
					yet collision and shit is unaffected.
			0450	P1 fake sprite X. maybe on-screen position

			04F0	P1 X position (lo)
			0510	P1 Y position (lo)
			0520	P1 Y position (hi)
			0560	P1 Y accelleration
		-- ]]

	end

	return objects
end

function getScreenPos(camera, object)

	return {
		x	= object.x - camera.x,
		y	= object.y - camera.y
		}
end



function fart()

	local cam	= getCamera()
	gui.text(1, 1, string.format("%s %s", fw(cam.x), fw(cam.y)))

	local objects	= getObjects()

	for id, obj in pairs(objects) do

		local screenPos	= getScreenPos(cam, obj)

		-- Show "alive" objects in white, otherwise red
		local color	= {"red", "black"}
		if AND(obj.flagsR, 0x8000) ~= 0 then
			color	= {"white", "#00000080"}
		end
		-- Put object index and object ID on screen
		-- gui.box(screenPos.x - 2, screenPos.y - 2,
		-- 		screenPos.x + 21, screenPos.y + 8, color[2], "clear")
		gui.line(screenPos.x, screenPos.y,
			screenPos.x + 16, screenPos.y     , color[1])
		gui.line(screenPos.x, screenPos.y,
			screenPos.x     , screenPos.y + 16, color[1])
		gui.text(screenPos.x + 2, screenPos.y + 2, string.format("%X\n%02X", id, obj.type), color[1], color[2])

		if id == showSpriteId then
			if showSpriteData then
				local grossHack	= {}
				for k,_ in pairs(obj) do
					if k ~= "flags" then
						table.insert(grossHack, k)
					end
				end
				table.sort(grossHack)

				gui.text(1, 10, string.format("sprite %X", showSpriteId))
				local y	= 20
				for _, k in pairs(grossHack) do
					gui.text(  0, y, k)
					gui.text( 50, y, fb(obj[k]))
					y	= y + 8

				end

				for y, v in pairs(obj.flags) do
					gui.text(170, y * 8 + 1, v)
				end
			end
		end


	end


end


local last	= input.get()
local inpt	= input.get()

showSpriteData	= true
showSpriteId	= 0

while true do
	-- lua in emulators is great.
	-- if you don't run the code in an endless loop,
	-- say, by, registering it
	-- errors are just silently dropped into the void
	--
	-- thanks devs. youre a real help.

	-- (that doesn't include most of the time when the errors
	-- just fucking vanish /anyway/)

	last	= inpt
	inpt	= input.get()
	
	if not last.T and inpt.T then
		showSpriteData	= not showSpriteData
	end
	
	if not last.Z and inpt.Z then
		showSpriteId	= showSpriteId - 1
	end
	
	if not last.X and inpt.X then
		showSpriteId	= showSpriteId + 1
	end

	if 0 or i['A'] then
		for s = 0, 63 do
			local a	= 0x0200 + s * 4
			local f	= rb(a)
			if f == 0xf8 then
				memory.writebyte(a+0, math.floor(s / 8) * 8 + 164)
				memory.writebyte(a+1, math.random(0x28,0x2A))
				memory.writebyte(a+2, 0x0)
				memory.writebyte(a+3, math.fmod(s, 8) * 8 + 184)

			end
		end
	end



	fart()
	emu.frameadvance()

end
