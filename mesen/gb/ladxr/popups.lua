-- handlers for various kinds of popups / "flying text"


--[[

	eventual plans:
	i'd like to refactor this to be more of a self-contained table
	and maybe do some other things, idk. i forgor

--]]



local pops = {}
function basic_pop(pop)
	textoutline2(
		clamp(pop.x - pop.size.width / 2, 1, 160 - pop.size.width),
		clamp(pop.y - pop.size.height / 2, 1, 138 - pop.size.height),
		pop.msg)
	return pop.x, pop.y
end



jump_ttl = 40
function jump_pop(pop)
	local alpha	= 0
	if pop.ttl < 20 then
		alpha	= (0x80 - math.floor(pop.ttl / 20 * 0x80)) * 0x01000000
	end
	textshadow(
		clamp(pop.x - pop.size.width / 2, 1, 160 - pop.size.width),
		clamp(pop.y - pop.size.height / 2, 1, 138 - pop.size.height),
		pop.msg, 0x70FFFFFF + alpha, 0x70000000 + alpha)
	return pop.x, pop.y
end


kill_ttl = 45
function kill_pop(pop)
	if pop.ttl > (kill_ttl - 5) then
		pop.y = pop.y - 2
	elseif pop.ttl > (kill_ttl - 10) then
		pop.y = pop.y - 1
	elseif pop.ttl > (kill_ttl - 15) then
		pop.y = pop.y - 0.5
	end
	textoutline(
		clamp(pop.x - pop.size.width / 2, 1, 160 - pop.size.width),
		clamp(pop.y - pop.size.height / 2, 1, 138 - pop.size.height),
		pop.msg, 0xFF6666, 0x30000000)
	return pop.x, pop.y
end


item_ttl = 120
function item_pop(pop)
	if pop.ttl > (item_ttl - 10) then
		pop.y = pop.y - 1
	elseif pop.ttl > (item_ttl - 35) then
		pop.y = pop.y - 0.4
	elseif pop.ttl > (item_ttl - 60) then
		pop.y = pop.y - 0.1
	end
	
	local fcolor = 0xCCCCCC
	local bcolor = 0x000000
	if pop.ttl > 60 and (pop.ttl % 4) < 2 then
		fcolor = 0xFFFFFF
		bcolor = 0x777777
	end

	textoutline2(
		clamp(pop.x - pop.size.width / 2, 1, 160 - pop.size.width),
		clamp(pop.y - pop.size.height / 2, 1, 138 - pop.size.height),
		pop.msg, fcolor, bcolor)
	return pop.x, pop.y	
end




bonk_ttl = 120
function bonk_pop(pop)
	pop.extra.z = pop.extra.z + pop.extra.z_accel
	if pop.extra.z > 0 and pop.extra.z_accel > 0 then
		pop.extra.z_accel = pop.extra.z_accel * -0.60
		pop.extra.y_accel = pop.extra.y_accel * 0.40
		pop.extra.x_accel = pop.extra.x_accel * 0.40
	else
		pop.extra.z_accel = pop.extra.z_accel + 0.1
	end

	pop.x = pop.x + pop.extra.x_accel
	pop.y = pop.y + pop.extra.y_accel

	local dx = pop.x
	local dy = pop.y

	emu.drawString(
		clamp(dx - pop.size.width / 2, 1, 160 - pop.size.width) + 1,
		clamp(dy - pop.size.height / 2, 1, 138 - pop.size.height) + 1,
		pop.msg, 0x00000000, 0xFF000000)
	emu.drawString(
		clamp(dx - pop.size.width / 2, 1, 160 - pop.size.width) + 1,
		clamp(dy - pop.size.height / 2, 1, 138 - pop.size.height) + pop.extra.z + 1,
		pop.msg, 0x80000000, 0xFF000000)
	emu.drawString(
		clamp(dx - pop.size.width / 2, 1, 160 - pop.size.width),
		clamp(dy - pop.size.height / 2, 1, 138 - pop.size.height) + pop.extra.z,
		pop.msg, 0xFFFFFF, 0xFF000000)

	-- textshadow(
	-- 	clamp(dx - pop.size.width / 2, 1, 160 - pop.size.width),
	-- 	clamp(dy - pop.size.height / 2, 1, 138 - pop.size.height),
	-- 	pop.msg)
	return pop.x, pop.y	
end





function add_pop(x, y, msg, ttl, func, extra)
	local textsize = emu.measureString(msg)
	table.insert(pops, { x = x, y = y, msg = msg, size = textsize, ttl = ttl or 90, func = func or basic_pop, extra = extra or {}})
end

function draw_pops()
	local any = false	-- if any were found. if not, clear table
	for i, pop in ipairs(pops) do
		if pop.ttl > 0 then
			any = true
			-- local nx, ny = pop.func(pop.x, pop.y, pop.msg, pop.size, pop.ttl)
			local nx, ny = pop.func(pop)
			pops[i].ttl = pops[i].ttl - 1
			pops[i].x = nx
			pops[i].y = ny
		end
	end
	if not any then pops = {} end
end





function track_kill()
	local ei = cpuregisters.c
	killcount = killcount + 1
	local ex = mem.byte[0xE200 + ei]
	local ey = mem.byte[0xE210 + ei]
	add_pop(ex, ey - 7, killcount, kill_ttl, kill_pop)

end
-- 03:55CF [D5CF] SpawnEnemyDrop::
emu.addMemoryCallback(track_kill, emu.callbackType.exec, 0xD5CF, 0xD5CF, emu.cpuType.gameboy, emu.memType.gbPrgRom)


function track_jump()
	jumpcount = jumpcount + 1
	local linkx	= mem.byte[0xFF98]
	local linky	= mem.byte[0xFF99]
	add_pop(linkx, linky, jumpcount, jump_ttl, jump_pop)

end
-- 00:14CB [14CB] UseRocsFeather::
-- 14e2 is after some checks + it plays the sound
emu.addMemoryCallback(track_jump, emu.callbackType.exec, 0x14E2, 0x14E2, emu.cpuType.gameboy, emu.memType.gbPrgRom)


function track_bonk()
	bonkcount = bonkcount + 1
	local linkx	= mem.byte[0xFF98]
	local linky	= mem.byte[0xFF99]
	local dir = mem.byte[0xFF9E] -- <1  ^2  >0  v3

	local xa = 0
	local ya = 0
	local xs = 0.9
	if dir == 0 then		-- right
		xa = xs
		linkx = linkx + 3
	elseif dir == 1 then	-- left
		xa	= -xs
		linkx = linkx - 3
	elseif dir == 2 then	-- up
		ya = -xs
		linky = linky - 5
	elseif dir == 3 then	-- down
		ya	= xs
		linky = linky + 2
	end

	add_pop(linkx, linky, bonkcount, bonk_ttl, bonk_pop, { z = 0, z_accel = -2, x_accel = xa, y_accel = ya })
	-- add_pop(linkx, linky + 10, dir)--, bonk_ttl, bonk_pop)

end
-- 02:74F9: bonk sound
emu.addMemoryCallback(track_bonk, emu.callbackType.exec, 0xB4F9, 0xB4F9, emu.cpuType.gameboy, emu.memType.gbPrgRom)
