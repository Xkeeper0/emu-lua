function getMode()
	local ghostMode		= memory.readbyte(0xD0)
	local ghostModeTimer	= memory.readbyte(0x00CF) * 0x3C + (0x3C - memory.readbyte(0x00d1))
	local text = "Chase"
	if math.fmod(ghostMode, 2) == 0 then
		text = "Scatter"
	end

	return { modeName = text, modeCount = ghostMode, modeTimer = ghostModeTimer, modeRaw1 = memory.readbyte(0x00CF), modeRaw2 = memory.readbyte(0x00D1)}

end



function framesToSeconds(frames)
	return frames / 60;
end



Object	= {
	values		= {
		addresses	= {
			x			= nil,
			xs			= nil,
			y			= nil,
			ys			= nil,
			color		= nil,
			dir			= nil,
		},
	},
	x			= nil,
	xs			= nil,
	y			= nil,
	ys			= nil,
	color		= nil,
	dir			= nil,

};


Object_mt		= { __index = Object };
--Objectv_mt		= { __index = Object.getValue };
Objectv_mt		= { __index = 
						function (s,k)
							return memory.readbyte(s.addresses[k])
						end
				}
setmetatable( Object , Object_mt );
setmetatable( Object.values , Objectv_mt );

function Object:new()
	local ret	= {};
	ret.values	= { addresses	= {} };
	setmetatable( ret, Object_mt );
	setmetatable( ret.values , Objectv_mt );	
	return ret

end

function Object:getPosition()
	return {
		x	= self.values.x, -- + self.values.xs / 0x100 - 8,
		y	= self.values.y, -- + self.values.ys / 0x100 + 8,
		dir	= self.values.dir
	}

end;


function Object:drawPosition()
	local pos	= self:getPosition()
	gui.line(pos.x - 1, pos.y    , pos.x + 1, pos.y    , "white");
	gui.line(pos.x    , pos.y - 1, pos.x    , pos.y + 1, "white");

	local directions	= {
		[0]	= function (x, y) gui.line(x, y, x    , y - 5, "white"); end,
		[1]	= function (x, y) gui.line(x, y, x - 5, y    , "white"); end,
		[2]	= function (x, y) gui.line(x, y, x    , y + 5, "white"); end,
		[3]	= function (x, y) gui.line(x, y, x + 5, y    , "white"); end,
		[4]	= function (x, y) gui.line(x - 5, y, x + 5, y    , "red"); end,
		}

	--gui.text(pos.x + 2, pos.y + 2, string.format("%d %d", pos.dir, self.values.dx), "gray", "clear");

	if directions[pos.dir] then
		directions[pos.dir](pos.x, pos.y)
	end

end;




Pacman = Object:new()
Pacman.values.addresses		= {
	x	= 0x001A,
	xs	= 0x001B,
	y	= 0x001C,
	ys	= 0x001D,
	dir	= 0x0050,
	dx	= 0x0050,
}

Blinky = Object:new()
Blinky.values.addresses		= {
	x	= 0x001E,
	xs	= 0x001F,
	y	= 0x0020,
	ys	= 0x0021,
	dir	= 0x00B9,
	dx	= 0x00BA,
}

Pinky = Object:new()
Pinky.values.addresses		= {
	x	= 0x0022,
	xs	= 0x0023,
	y	= 0x0024,
	ys	= 0x0025,
	dir	= 0x00BB,
	dx	= 0x00BC,
}

Inky = Object:new()
Inky.values.addresses		= {
	x	= 0x0026,
	xs	= 0x0027,
	y	= 0x0028,
	ys	= 0x0029,
	dir	= 0x00BD,
	dx	= 0x00BE,
}

Clyde = Object:new()
Clyde.values.addresses		= {
	x	= 0x002A,
	xs	= 0x002B,
	y	= 0x002C,
	ys	= 0x002D,
	dir	= 0x00BF,
	dx	= 0x00C0,
}

print(Pacman);
print(Blinky);
print(Pinky);
print(Inky);
print(Clyde);


LockPacman	= false

while true do

	inpt	= input.get()
	if inpt['Q'] then
		LockPacman	= true
	end

	if LockPacman then
		memory.writebyte(0x001a, 170)
		memory.writebyte(0x001c, 92)
	end

--	local line	= 0
--	thisObject	= Blinky:getPosition()
	
	Pacman:drawPosition()
	Blinky:drawPosition()
	Pinky:drawPosition()
	Inky:drawPosition()
	Clyde:drawPosition()


	-- Blue timer
	bluetimer	= memory.readbyte(0x0089) * 0x3C + (0x3C - memory.readbyte(0x008A))

	gui.text(200, 0, bluetimer)

	mode		= getMode();
	gui.text(180, 90, string.format("%d: %s\n%5.1f\n%02X %02X", mode.modeCount, mode.modeName, framesToSeconds(mode.modeTimer), mode.modeRaw1, mode.modeRaw2))


	DotsRemaining		= memory.readbyte(0x006A)
	BlinkySpeedup1Dots	= memory.readbyte(0x008D)
	BlinkySpeedup2Dots	= memory.readbyte(0x008E)

	gui.text(180, 120, string.format("Dots left: %3d\nBlinky1:%3d\nBlinky2:%3d", DotsRemaining, BlinkySpeedup1Dots, BlinkySpeedup2Dots))




	emu.frameadvance();
end;