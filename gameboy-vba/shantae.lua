
	-- Shantae debug code
	-- Left x 2, Right x 8, Left x 6, 
	-- Right x 2, Left x 7, Right x 6
	-- Left x 8 



	-- Current task: find camera boundaries

	offsets		= {
		player	= {
			position	= {
				x			= 0xd034,
				y			= 0xd037,
			},
		},
		camera	= {
			position	= {
				x			= 0xc9fb,
				y			= 0xc9fd,
				},
			boundaries	= {
				topLeft		= {
					x			= 0xc9e9,
					y			= 0xc9ec,
				},
				bottomRight	= {
					x			= 0xc9dd,
					y			= 0xc9e1,
				},
			},
		},
	}


	function getPlayerPos()
		local x	= memory.readword(offsets.player.position.x)
		local y	= memory.readword(offsets.player.position.y)
		return {x = x, y = y}
	end

	function getCameraPos()
		local x	= memory.readword(offsets.camera.position.x)
		local y	= memory.readword(offsets.camera.position.y)
		return {x = x, y = y}
	end


	function getCameraBoundaries()
		local x1	= memory.readword(offsets.camera.boundaries.topLeft.x)
		local y1	= memory.readword(offsets.camera.boundaries.topLeft.y)
		local x2	= memory.readword(offsets.camera.boundaries.bottomRight.x)
		local y2	= memory.readword(offsets.camera.boundaries.bottomRight.y)

		return {
			topLeft		= {x = x1, y = y1},
			bottomRight	= {x = x2, y = y2},
			}

	end



	function unlockCamera()
		memory.writeword(offsets.camera.boundaries.topLeft.x, 0x0000)
		memory.writeword(offsets.camera.boundaries.topLeft.y, 0x0000)
		memory.writeword(offsets.camera.boundaries.bottomRight.x, 0x2000)
		memory.writeword(offsets.camera.boundaries.bottomRight.y, 0x2000)
	end



	local keys	= {}
	local keyso	= {}

	while true do
		keyso	= keys
		keys	= input.get()

		if keys['Z'] then
			unlockCamera()
		end


		local playerPos		= getPlayerPos()
		local cameraPos		= getCameraPos()
		local cameraBounds	= getCameraBoundaries()

		gui.box(0, 128, 160, 144, "#000000c0")

		gui.text(1, 129, string.format("Player %04X %04X", playerPos.x, playerPos.y))
		gui.text(1, 136, string.format("Camera %04X %04X", cameraPos.x, cameraPos.y))

		gui.text( 90, 129, string.format("Cam T/L %04X %04X", cameraBounds.topLeft.x, cameraBounds.topLeft.y))
		gui.text( 90, 136, string.format("Cam B/R %04X %04X", cameraBounds.bottomRight.x, cameraBounds.bottomRight.y))


		emu.frameadvance()

	end


