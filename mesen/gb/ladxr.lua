-- require('connector_ladx_mesen')

require("libs/functions")
require("ladxr-autotracker")

killcount = 0
jumpcount = 0
bonkcount = 0
icount = 0

require "ladxr/popups"
require "ladxr/itembar"


function our_overlay()

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
