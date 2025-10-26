
	function drawCross(o, c, s)
		local s = s
		if not s then
			s = 2
		end 
		gui.line(o.x    , o.y - s, o.x    , o.y + s, c)
		gui.line(o.x - s, o.y    , o.x + s, o.y    , c)

	end

	function math.clamp(value, min, max)
		return math.min(max, math.max(min, value))
	end


	function cameraToScreen(o, c, clamp)
		local cl = clamp and true or false
		local x, y = o.x - c.x, o.y - c.y
		if cl then
			x	= math.clamp(x, 0, 149)
			y	= math.clamp(y, 0, 135)
		end
		return { x = x, y = y }
	end


	function mgposition(addr)
		local t		= memory.readword(addr)
		t			= t / 0x20
		return t

	end

	function getPosition(addr1, addr2)
		return { x = mgposition(addr1), y = mgposition(addr2)}
	end


	while true do

		butt	= false
		local ipt		= input.get()
		if ipt.A then
			memory.writebyte(0xc329, 0x00)
			memory.writebyte(0xc32a, 0x00)
			memory.writebyte(0xc32b, 0x40)
			memory.writebyte(0xc32c, 0x40)
			--memory.writebyte(0xc32d, 0x42)
			--memory.writebyte(0xc32e, 0x40)
		end


		if ipt.Z then
			butt	= true
			memory.writebyte(0xd047, 0x20)
		end

		local cameraPos		= getPosition(0xc29a, 0xc29c)
		gui.text(12, 130, string.format("%04x %04x", memory.readword(0xc320), memory.readword(0xc322)))

		--[[
		local playerPos		= getPosition(0xd004, 0xd006)
		local cameraManPos	= getPosition(0xd044, 0xd046)


		drawCross(cameraToScreen(playerPos, cameraPos), "red", 4)
		drawCross(cameraToScreen(cameraManPos, cameraPos), "white")

		--]]

		for i = 0, 0x1F do
			local mX, mY		= 0xd004 + 0x40 * i, 0xd006 + 0x40 * i
			local objectPos		= getPosition(mX, mY)
			local objectPosCam	= cameraToScreen(objectPos, cameraPos)

			if objectPos.x ~= 0 and objectPos.y ~= 0 then
				--gui.text(1, 0 + (i * 6), string.format("%02x", i))

				drawCross(objectPosCam, "white")
				
				local objectPosCam2	= cameraToScreen(objectPos, cameraPos, true)
				local ix	= i
				if butt then
					ix	= 0xd004 + 0x40 * i
				end
				gui.text(objectPosCam2.x + 2, objectPosCam2.y + 1, string.format("%02x", ix))
			end

		end

		emu.frameadvance()

	end