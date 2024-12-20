spriteBase	= 0x200



require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")



local oldSprites	= {}
inRegister	= false

for s = 0, 63 do
	local a	= spriteBase + s * 4
	oldSprites[a]			= {}
	oldSprites[a]['value']	= memory.readbyte(a)
	oldSprites[a]['used']	= (memory.readbyte(a) > 0 and memory.readbyte(a) < 0xf8)

end


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


function m.trackSpriteMemory(address, size)
	if inRegister then 
		return
	end

	local newVal	= m.rb(address)
	if newVal > 0x00 and newVal < 0xef then
		oldSprites[address]['value']	= newVal
		oldSprites[address]['used']		= true
	else
		oldSprites[address]['used']		= false
	end

end


for s = 0, 63 do
	local a	= spriteBase + s * 4
	memory.register(a, m.trackSpriteMemory)
end


function m.showUnusedSprites(spriteNum)
	for s = 0, 63 do
		local a	= spriteBase + s * 4
		local f	= m.rb(a)
		if f >= 0xf8 then
			memory.writebyte(a+0, math.floor(s / 8) * 8 + 164)
			memory.writebyte(a+1, spriteNum)
			memory.writebyte(a+2, 0x0)
			memory.writebyte(a+3, math.fmod(s, 8) * 8 + 184)
		end
	end
end


function m.restoreUnusedSprites()
	for s = 0, 63 do
		local a	= spriteBase + s * 4
		inRegister	= true
		if not oldSprites[a]['used'] then
			memory.writebyte(a, oldSprites[a].value)
		end
	end
	inRegister	= false

end


--local pos	= { x = 228, y = 212 }
local pos	= { x = 220, y = 204 }
local mul	= { x = 4, y = 4 }

timer = 0

while true do
	gui.text(232, 0, string.format("%04X", spriteBase))
	m.restoreUnusedSprites()

	--gui.box(pos.x - 1, pos.y - 1, pos.x + 8 * mul.x - 1, pos.y + 8 * mul.y - 1, "black", "black")

	for s = 0, 63 do
		local a	= spriteBase + s * 4
		local c	= (oldSprites[a]['used']) and "white" or "red"
		local x	= (s % 8) * mul.x + pos.x
		local y	= (math.floor(s / 8)) * mul.y + pos.y

		--gui.text((s % 8) * 10, math.floor(s / 8) * 10, tostring(oldSprites[a]['used']))
		--gui.box(x, y, x + mul.x - 2, y + mul.y - 2, c)
		local b = button(x, y, mul.x, mul.y, c, true)
		if b == -1 then
			local sx = memory.readbyte(spriteBase + s * 4 + 3)
			local sy = memory.readbyte(spriteBase + s * 4 + 0)
			gui.line(sx, sy, sx    , sy + 7, (timer % 6 < 3) and "white" or "red")
			gui.line(sx, sy, sx + 7, sy    , (timer % 6 < 3) and "white" or "red")
		end


	end

	timer = timer + 1
	input.update()
	emu.frameadvance()
end
