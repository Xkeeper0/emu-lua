-- require('connector_ladx_mesen')

require("libs/functions")

-- autotracker function; does not otherwise interact with
-- this overlay script at all (it's its own thing)
require("ladxr-autotracker")

killcount = 0
jumpcount = 0
bonkcount = 0
icount = 0

c		= require "ladxr/memory-constants"

require "ladxr/popups"
require "ladxr/itembar"
require "ladxr/dungeon-hud"


-- wGameplayType = 
-- 0B= in game, etc
-- 0C = subscreen is open, or opening/closing
-- other useful memory addresses
--[[

	D368:wMusicTrackToPlay
D47C:wActivePowerUp
DB3F:wHasMedicine
DB57:wDeathCount
DB5A:wHealth
DB6D:wCollectedTunics ; Memory location where to store which tunic options are available
DB5D:wRupeeCountHigh
DB5E:wRupeeCountLow

FFF6:hMapRoom (room id on active map)
FFF7:hMapId (00..07), 0C=eagletower alt, FF=color dungeon, 
FFF8:hRoomStatus

--]]

local last_beep = -999
function cool_health_bar(x, y)
	local hp		= mem.byte[c.wHealth]
	local maxhp		= mem.byte[c.wMaxHearts] * 8
	local maxmaxhp	= (maxhp > 56) and 112 or 56  -- 14 * 8, 7 * 8
	local hasmed	= mem.byte[c.wHasMedicine]
	local barsize	= 56
	local barheight	= 4

	local hpsize	= math.ceil(hp / maxmaxhp * barsize)
	local maxhpsize	= math.ceil(maxhp / maxmaxhp * barsize)

	-- if we have the medicine, add our max hp to the maxhp
	-- and "overcharge" the bar
	local bar_bg	= 0x800000
	local bar_fg	= 0xFF7777
	if hasmed ~= 0 then
		bar_bg = bar_fg
		bar_fg = 0xFFEEEE
	end


	local text_fg	= 0xEEEEEE
	local text_bg	= 0x000000
	local border_bg	= 0x000000
	if mem.byte[c.wIsOnLowHeath] ~= 0 then
		local time_to_beep	= mem.byte[c.wTimeToNextLowHealthSFX]
		if time_to_beep == 0 then
			last_beep = tools.frame
		end
		if tools.frame - last_beep < 10 then
			text_fg		= 0xFFFFFF
			text_bg		= 0xFF0000
			border_bg	= 0xFF0000
		else
			text_fg		= 0xFF7700
			text_bg		= 0x440000
		end
	elseif mem.byte[c.wFullHearts] ~= 0 then
		text_fg		= 0xFFFFFF
		text_bg		= 0x2828F0
		border_bg	= 0x000080
	end
	
	-- emu.drawString(0, 0, mem.byte[c.wTimeToNextLowHealthSFX])
	-- c.wTimeToNextLowHealthSFX


	emu.drawRectangle(x    , y    , barsize + 1  , barheight + 2, border_bg, true)
	emu.drawRectangle(x + 1, y + 1, barsize - 2  , barheight    , 0x000000, true)
	emu.drawRectangle(x + 1, y + 1, maxhpsize - 1, barheight    , bar_bg, true)
	emu.drawRectangle(x + 1, y + 1, hpsize - 1   , barheight    , bar_fg, true)

	for i = 1, 14 do
		emu.drawRectangle(x + math.ceil((i * 8) / maxmaxhp * barsize), y + 1, 1, 1, 0xCC000000)
		emu.drawRectangle(x + math.ceil((i * 8) / maxmaxhp * barsize), y + 4, 1, 1, 0x88000000)
	end


	emu.drawRectangle(x + maxhpsize + 1, y + 1, 1, barheight, bar_fg)
	
	textoutline2(x + 4, y + 3, string.format("%d", math.floor(hp / 2)), text_fg, text_bg) --, 0xFF000000)

end

--[[
0-6: 30 kills
7-10: 35 kills
11-14: 40 kills
--]]
function powerup_meters(x, y)
	-- y = y + 4
	x = x
	local pop_kills	= mem.byte[c.wPieceOfPowerKillCount]
	local ga_kills = mem.byte[c.wGuardianAcornCounter]

	local barsize = 28

	local ga_max	= 0x0C -- GUARDIAN_ACORN_COUNTER_MAX
	local maxhp		= mem.byte[c.wMaxHearts]
	local pop_max	= 30
	if maxhp >= 11 then
		pop_max= 40
	elseif maxhp >= 7 then
		pop_max = 35
	end

	local popwidth	= math.ceil((pop_kills / (pop_max - 1)) * barsize)
	local gawidth	= math.ceil((ga_kills / (ga_max - 1)) * barsize)

	local popfg	= 0xFF4444
	local gafg	= 0x6666FF
	if ga_kills >= ga_max - 1 and (tools.frame % 4 < 2) then
		gafg = 0xFFFFFF
	end
	if pop_kills >= pop_max - 1 and (tools.frame % 4 < 2) then
		popfg = 0xFFFFFF
	end

	emu.drawRectangle(x, y + 12, barsize * 2 + 2, 4, 0x000000, true)
	emu.drawRectangle(x          , y + 13, barsize, 2, 0x800000, true)
	emu.drawRectangle(x          , y + 13, popwidth, 2, popfg, true)
	emu.drawRectangle(x + barsize + 2, y + 13, barsize, 2, 0x000080, true)
	emu.drawRectangle(x + barsize * 2 - gawidth, y + 13, gawidth, 2, gafg, true)

	-- powerup state meter. 1=pop 2=ga
	local powerup	= mem.byte[c.wActivePowerUp]
	if powerup ~= 0 then
		local bsize = 19
		emu.drawRectangle(x + 1, y + 10, bsize * 3 - 3    , 4, 0x000000, true)
		local hits	= mem.byte[c.wPowerUpHits]
		for i = 0, 2 do
			local mult	= clamp(math.floor(math.sin((tools.frame - i * 18) / 18) * 127 + 127), 0, 0xFF)
			local fgcolor	= 0x000000
			local bgcolor	= 0x444444
			if powerup == 1 then
				fgcolor	= 0xFF0000 + 0x0101 * mult
				bgcolor	= 0x400808
			else
				fgcolor = 0x0000FF + 0x010100 * mult
				bgcolor	= 0x0a0a40
			end

			emu.drawRectangle(x +  1 + i * (bsize - 2) + 1, y + 11, bsize - 1, 2, ((2 - hits) >= i and fgcolor or bgcolor), true)
		end
	end
end

function no_powerup_popups(n, v)
	local dialog = mem.byte[c.wDialogGotItem]
	-- 1 and 5 are PoP / GA
	-- timer starts high and then counts down, pops dialog at 02
	-- 2 = Toadstool,
	-- 3 = Magic powder,


	if v == 0x02 and (dialog == 1 or dialog == 5 or dialog == 2 or dialog == 3) then
		-- skip it! get outta here
		mem.byte[c.wDialogGotItemCountdown]	= 0

		if dialog == 1 then
			add_itemline("Piece of Power", true)
			add_itemline("Sword damage increased", false)
			add_itemline("Movement speed increased", false)
			if math.random(0, 10) == 0 then
				add_itemline("Music interrupted", false)
			end
		elseif dialog == 5 then
			add_itemline("Guardian Acorn", true)
			if mem.byte[c.wTunicType] == 0x2 then -- blue tunic
				add_itemline("It's useless...", false)
				add_itemline("You have the Blue Tunic on", false)
			else
				add_itemline("Damage taken reduced", false)
			end
			if math.random(0, 10) == 0 then
				add_itemline("Music interrupted", false)
			end
		elseif dialog == 2 then
			add_itemline("Strange Mushroom", true)
			add_itemline("Very aromatic.", false)
			add_itemline("Ahzi would love this...", false)
		elseif dialog == 3 then
			add_itemline("Magic Powder", true)
		end

		return 0
	end
end
emu.addMemoryCallback(no_powerup_popups, emu.callbackType.write, c.wDialogGotItemCountdown, c.wDialogGotItemCountdown, emu.cpuType.gameboy, emu.memType.gameboyMemory)


gameplaytype_handlers	= {}

-- Main game
gameplaytype_handlers[0x0B]		= function ()
	-- not sure why i have to x2 the color value here but vOv probably a bug.
	emu.drawRectangle(104  , 128 , 56,  16, emu.getPixel(104, 128) * 2, true)
	powerup_meters(104, 128)
	cool_health_bar(104, 128)
	draw_dungeon_keys()
end

-- Map screen
gameplaytype_handlers[0x07]		= function ()
end

-- Inventory
gameplaytype_handlers[0x0C]		= function ()
end



function our_overlay()


	local gameplaytype	= mem.byte[c.wGameplayType]
	if gameplaytype_handlers[gameplaytype] then
		gameplaytype_handlers[gameplaytype]()
	end
	
	local linkx	= mem.byte[0xFF98]
	local linky	= mem.byte[0xFF99]

	local nicount = sram.word[0x1010]
	if nicount ~= icount then
		add_pop(linkx + 1, linky - 12, string.format("%x", nicount), item_ttl, item_pop)
	end
	icount = nicount
	draw_pops()
	draw_itemlines()

	if tools.keyReleased("leftclick") then
		local mouse = emu.getMouseState()
		-- add_pop(mouse.x, mouse.y, math.random(0, 150), kill_ttl, kill_pop)
	end


end

emu.addEventCallback(our_overlay, emu.eventType.startFrame)
