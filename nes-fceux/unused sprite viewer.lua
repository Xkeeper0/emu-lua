-- copy paste ez functions because coding is hard

local m	= {}

function m.rb(a)
	return memory.readbyte(a)
end

function m.rw(a)
	return memory.readword(a)

end

function m.r2(a2, a1)
	return m.rb(a1) * 0x100 + m.rb(a2)

end


function m.fb(v)
	return string.format("%02X", v)
end

function m.fw(v)
	return string.format("%04X", v)
end

function m.showUnusedSprites(spriteNum)
	for s = 0, 63 do
		local a	= 0x0200 + s * 4
		local f	= m.rb(a)
		if f >= 0xf8 then
			memory.writebyte(a+0, math.floor(s / 8) * 8 + 164)
			memory.writebyte(a+1, spriteNum)
			memory.writebyte(a+2, 0x0)
			memory.writebyte(a+3, math.fmod(s, 8) * 8 + 184)
		end
	end
end

return m