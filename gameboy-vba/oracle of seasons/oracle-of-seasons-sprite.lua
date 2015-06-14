
	local Sprite	= {}
	Sprite.__index	= Sprite

	function Sprite.new(idx)
		local ret	= {
			idx			= nil,
			startAddress	= 0xD000,
			instanceOffset	= 0x40,
			offsets			= {
				type			= 0x01,
				subtype			= 0x02,

				action			= 0x04,

				timer			= 0x06,

				x				= 0x0D,
				y				= 0x0B,
				z				= 0x0F,

				movement		= 0x10,

				graphicsA		= 0x1B,
				graphicsB		= 0x1C,
				graphicsBank	= 0x1D,
				graphicsImgA	= 0x1E,
				graphicsImgB	= 0x1F,

				interaction		= 0x25,

				hitboxX			= 0x27,
				hitboxY			= 0x26,
				damageOnTouch	= { func = memory.readbytesigned, addr = 0x28 },
				health			= 0x29,

				invulnTimer		= 0x2B,
				stunTimer		= 0x2E,
				},
			data			= {
				}
			}

		setmetatable(ret, Sprite)

		ret.idx	= idx
		ret:update()
		return ret

	end

	function Sprite:getOffset()
		return self.startAddress + (self.instanceOffset * self.idx)

	end


	function Sprite:update()
		for key, ofs in pairs(self.offsets) do
			local addr		= self:getOffset()

			if type(ofs) == "table" then
				self.data[key]	= ofs.func(addr + ofs.addr)

			else
				self.data[key]	= memory.readbyte(addr + ofs)

			end
		end

	end


	return Sprite