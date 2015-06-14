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
		x	= r2(0x49, 0x4a),
		y	= r2(0x4b, 0x4c),
		}
end

function getTimer()
	return r2(0x0007, 0x0009)

end


function getObjects()
	--[[
		Facing:		0x03F6	(Player)
					0x03FC	(Enemies 1-3)
					0x03FD
					0x03FE


		possible width: 1E? F?

		Position:
			player
				x low		3ba?
				x high		48c? ba?
	--]]

	local objects	= {}

	local base		= 0x03ba

	for i = 0, 0x1E do

		objects[i]	= {
			accel_x_dir	= rb(0x037e + i),		-- 1 = left
			accel_y_dir	= rb(0x039c + i),		-- 1 = down
			x			= r2(0x03ba + i, 0x048c + i),
			y			= r2(0x03d8 + i, 0x04aa + i),
			facing		= rb(0x03f6 + i),		-- 1 = left
			animation	= rb(0x0414 + i),		-- animation frame? door=13(closed) 00(open); player=lots of them
			palette		= rb(0x0432 + i),		
			accel_x_hi	= rb(0x0450 + i),		-- always positive
			accel_y_hi	= rb(0x046e + i),		-- always positive
			type		= rb(0x04c8 + i),		-- 00 = off/dead?
			unk2		= rb(0x04c8 + i + 0x1e *  1),
			unk3		= rb(0x04c8 + i + 0x1e *  2),
			unk4		= rb(0x04c8 + i + 0x1e *  3),
			unk5		= rb(0x04c8 + i + 0x1e *  4),
			unk6		= rb(0x04c8 + i + 0x1e *  5),
			unk7		= rb(0x04c8 + i + 0x1e *  9),
			unk8		= rb(0x04c8 + i + 0x1e * 10),
			unk9		= rb(0x064c + i),

			}

	end

	return objects

end

function fart()

	local camera	= getCamera()
	local objects	= getObjects()

	for i, obj in pairs(objects) do
		if obj.type ~= 0 then

			local y	= i * 8 + 1
			local objcamX	= obj.x - camera.x
			local objcamY	= obj.y - camera.y

			--[[
			gui.text( 16, y, fb(obj.type))
			gui.text( 31, y, fb(obj.unk2))
			gui.text( 46, y, fb(obj.unk3))
			gui.text( 61, y, fb(obj.unk4))
			gui.text( 76, y, fb(obj.unk5))
			gui.text( 91, y, fb(obj.unk6))
			gui.text(106, y, fb(obj.unk7))
			gui.text(121, y, fb(obj.unk8))
			gui.text(136, y, fb(obj.unk9))
			gui.text(  1, y, fb(i), "red", "black")
			--]]

			if obj.type == 0x0B then
				local dv	= obj.unk9
				if dv >= 0x80 then
					dv	= dv - 0x80
				end

				gui.text(objcamX + 2, objcamY + 10, string.format("D:%02d", dv))
			elseif false then
				gui.text(objcamX + 2, objcamY + 10, "T:".. fb(obj.type))
			end

			if false and i == 0x13 then
				gui.line(objcamX, objcamY, objcamX +  8, objcamY +  0, "white")
				gui.line(objcamX, objcamY, objcamX +  0, objcamY +  8, "white")
				gui.text(objcamX + 2, objcamY + 2, fb(i))
				local yp	= 1
				for k,v in pairs(obj) do
					gui.text( 1, yp, k)
					gui.text(60, yp, fw(v))
					yp		= yp + 8
				end
			end
		end
	end

	gui.text(220, 1, string.format("X %s\nY %s", fw(camera.x), fw(camera.y)))

	gui.text(230, 19, "Time \n".. fw(getTimer()))



end

while true do
	fart()
	emu.frameadvance()
end

--gui.register(fart)
