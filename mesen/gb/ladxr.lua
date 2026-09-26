-- require('connector_ladx_mesen')

require("libs/functions")
require("ladxr-autotracker")

killcount = 0
jumpcount = 0
bonkcount = 0
icount = 0




local ladxr_items	= {}
function ladxr_items:add(num, major, name, memaddr) 
	self[num]	= { name = name, major = major, memaddr = memaddr }
end

local lv = {}
lv[0]	= "Color Dungeon "
lv[1]	= "Tail Cave "
lv[2]	= "Bottle Grotto "
lv[3]	= "Key Cavern "
lv[4]	= "Angler's Tunnel "
lv[5]	= "Catfish's Maw "
lv[6]	= "Face Shrine "
lv[7]	= "Eagle's Tower "
lv[8]	= "Turtle Rock "
lv[9]	= "Wind Fish's Egg "


ladxr_items:add( 0x00, true, "Power Bracelet L-%d", 0xDB43 )
ladxr_items:add( 0x01, true, "Shield L-%d", 0xDB44 )
ladxr_items:add( 0x02, true, "Bow" )
ladxr_items:add( 0x03, true, "Hookshot" )
ladxr_items:add( 0x04, true, "Magic Rod" )
ladxr_items:add( 0x05, true, "Pegasus Boots" )
ladxr_items:add( 0x06, true, "Ocarina" )
ladxr_items:add( 0x07, true, "Feather" )
ladxr_items:add( 0x08, true, "Shovel" )
ladxr_items:add( 0x09, true, "Magic Powder" )
ladxr_items:add( 0x0A, true, "Bombs" )
ladxr_items:add( 0x0B, true, "Sword L-%d", 0xDB4E )
ladxr_items:add( 0x0C, true, "Flippers" )
ladxr_items:add( 0x0D, true, "Magnifying Lens" )
ladxr_items:add( 0x0E, true, "Boommerang" )
ladxr_items:add( 0x0F, true, "Slime Key" )

ladxr_items:add( 0x10, true, "Medicine" )
ladxr_items:add( 0x11, true, "Tail Key" )
ladxr_items:add( 0x12, true, "Angler Key" )
ladxr_items:add( 0x13, true, "Face Key" )
ladxr_items:add( 0x14, true, "Harpy Key" )
ladxr_items:add( 0x15, true, "Golden Leaf (%d / 5)", 0xDB15 )
ladxr_items:add( 0x16, false, "Map" )
ladxr_items:add( 0x17, false, "Compass" )
ladxr_items:add( 0x18, false, "Stone Beak" )
ladxr_items:add( 0x19, true, "Nightmare Key" )
ladxr_items:add( 0x1A, false, "Small Key" )
ladxr_items:add( 0x1B, false, "50 Rupees. Nice." )
ladxr_items:add( 0x1C, false, "20 Rupees! Joy." )
ladxr_items:add( 0x1D, false, "100 Rupees! Wow!" )
ladxr_items:add( 0x1E, false, "200 Rupees! Amazing!" )
ladxr_items:add( 0x1F, false, "500 Rupees!? What the" )

ladxr_items:add( 0x20, true, "Secret Seashell (%d/20)", 0xDB0F )
ladxr_items:add( 0x21, false, "Master Stalfos's letter" )
ladxr_items:add( 0x22, false, "One Gel" )
ladxr_items:add( 0x23, false, lv[1] .. "Small Key (%d)", 0xDB1B + 5 * 0 )
ladxr_items:add( 0x24, false, lv[2] .. "Small Key (%d)", 0xDB1B + 5 * 1 )
ladxr_items:add( 0x25, false, lv[3] .. "Small Key (%d)", 0xDB1B + 5 * 2 )
ladxr_items:add( 0x26, false, lv[4] .. "Small Key (%d)", 0xDB1B + 5 * 3 )
ladxr_items:add( 0x27, false, lv[5] .. "Small Key (%d)", 0xDB1B + 5 * 4 )
ladxr_items:add( 0x28, false, lv[6] .. "Small Key (%d)", 0xDB1B + 5 * 5 )
ladxr_items:add( 0x29, false, lv[7] .. "Small Key (%d)", 0xDB1B + 5 * 6 )
ladxr_items:add( 0x2A, false, lv[8] .. "Small Key (%d)", 0xDB1B + 5 * 7 )
ladxr_items:add( 0x2B, false, lv[0] .. "Small Key (%d)", 0xDDDE )
ladxr_items:add( 0x2C, false, lv[1] .. "Map" )
ladxr_items:add( 0x2D, false, lv[2] .. "Map" )
ladxr_items:add( 0x2E, false, lv[3] .. "Map" )
ladxr_items:add( 0x2F, false, lv[4] .. "Map" )

ladxr_items:add( 0x30, false, lv[5] .. "Map" )
ladxr_items:add( 0x31, false, lv[6] .. "Map" )
ladxr_items:add( 0x32, false, lv[7] .. "Map" )
ladxr_items:add( 0x33, false, lv[8] .. "Map" )
ladxr_items:add( 0x34, false, lv[0] .. "Map" )
ladxr_items:add( 0x35, false, lv[1] .. "Compass" )
ladxr_items:add( 0x36, false, lv[2] .. "Compass" )
ladxr_items:add( 0x37, false, lv[3] .. "Compass" )
ladxr_items:add( 0x38, false, lv[4] .. "Compass" )
ladxr_items:add( 0x39, false, lv[5] .. "Compass" )
ladxr_items:add( 0x3A, false, lv[6] .. "Compass" )
ladxr_items:add( 0x3B, false, lv[7] .. "Compass" )
ladxr_items:add( 0x3C, false, lv[8] .. "Compass" )
ladxr_items:add( 0x3D, false, lv[0] .. "Compass" )
ladxr_items:add( 0x3E, false, lv[1] .. "Stone Beak" )
ladxr_items:add( 0x3F, false, lv[2] .. "Stone Beak" )

ladxr_items:add( 0x40, false, lv[3] .. "Stone Beak" )
ladxr_items:add( 0x41, false, lv[4] .. "Stone Beak" )
ladxr_items:add( 0x42, false, lv[5] .. "Stone Beak" )
ladxr_items:add( 0x43, false, lv[6] .. "Stone Beak" )
ladxr_items:add( 0x44, false, lv[7] .. "Stone Beak" )
ladxr_items:add( 0x45, false, lv[8] .. "Stone Beak" )
ladxr_items:add( 0x46, false, lv[0] .. "Stone Beak" )
ladxr_items:add( 0x47, true, lv[1] .. "Boss Key" )
ladxr_items:add( 0x48, true, lv[2] .. "Boss Key" )
ladxr_items:add( 0x49, true, lv[3] .. "Boss Key" )
ladxr_items:add( 0x4A, true, lv[4] .. "Boss Key" )
ladxr_items:add( 0x4B, true, lv[5] .. "Boss Key" )
ladxr_items:add( 0x4C, true, lv[6] .. "Boss Key" )
ladxr_items:add( 0x4D, true, lv[7] .. "Boss Key" )
ladxr_items:add( 0x4E, true, lv[8] .. "Boss Key" )
ladxr_items:add( 0x4F, true, lv[0] .. "Boss Key" )

ladxr_items:add( 0x50, true, lv[0] .. "Mushroom" )
ladxr_items:add( 0x51, false, "50 Rupees? Uh..." ) -- 51
ladxr_items:add( 0x52, false, "20 Rupees? Ugh." )
ladxr_items:add( 0x53, false, "100 Rupees? Nope." )
ladxr_items:add( 0x54, false, "Secret Seashell? (%d/20)", 0xDB0F )
ladxr_items:add( 0x55, false, "Medicine?" )
ladxr_items:add( 0x56, true, "Bombs?" )
ladxr_items:add( 0x57, true, "Hammer" ) -- 57
ladxr_items:add( 0x58, true, "Tail Cave opened" )
ladxr_items:add( 0x59, true, "Key Cavern opened" )
ladxr_items:add( 0x5A, true, "Angler's Tunnel opened" )
ladxr_items:add( 0x5B, true, "Face Shrine opened" )
ladxr_items:add( 0x5C, true, "Kanlet Castle Gate opened" )
ladxr_items:add( 0x5D, true, "Eagle's Tower opened" )
-- 5E (none...)F5

-- 0x80
ladxr_items:add( 0x80, false, "Piece of Heart (%d/4)", 0xDB5C )
ladxr_items:add( 0x81, true, "Bow-wow! Good dog." )
ladxr_items:add( 0x82, false, "10 arrows" )
ladxr_items:add( 0x83, false, "1 arrow..." )
ladxr_items:add( 0x84, true, "Magic Powder capacity up!" )
ladxr_items:add( 0x85, true, "Bomb capacity up!" )
ladxr_items:add( 0x86, true, "Arrow capacity up!" )
ladxr_items:add( 0x87, true, "Red Tunic" )
ladxr_items:add( 0x88, true, "Blue Tunic" )
ladxr_items:add( 0x89, true, "Heart Container" )
ladxr_items:add( 0x8A, true, "Lose a Heart Container" )
ladxr_items:add( 0x8B, true, "Ballad o.t. Wind Fish" )
ladxr_items:add( 0x8C, true, "Mambo's Mambo" )
ladxr_items:add( 0x8D, true, "Song of Soul" )
ladxr_items:add( 0x8E, true, lv[1] .. "Instrument" )
ladxr_items:add( 0x8F, true, lv[2] .. "Instrument" )
ladxr_items:add( 0x90, true, lv[3] .. "Instrument" )
ladxr_items:add( 0x91, true, lv[4] .. "Instrument" )
ladxr_items:add( 0x92, true, lv[5] .. "Instrument" )
ladxr_items:add( 0x93, true, lv[6] .. "Instrument" )
ladxr_items:add( 0x94, true, lv[7] .. "Instrument" )
ladxr_items:add( 0x95, true, lv[8] .. "Instrument" )
ladxr_items:add( 0x96, true, "Flying Rooster" )
ladxr_items:add( 0x97, true, "Yoshi Doll" )
ladxr_items:add( 0x98, true, "Ribbon" )
ladxr_items:add( 0x99, true, "Dog Food" )
ladxr_items:add( 0x9A, true, "Bananas" )
ladxr_items:add( 0x9B, true, "Stick" )
ladxr_items:add( 0x9C, true, "Honeycomb" )
ladxr_items:add( 0x9D, true, "Pineapple" )
ladxr_items:add( 0x9E, true, "Hibiscus" )
ladxr_items:add( 0x9F, true, "Letter" )
ladxr_items:add( 0xA0, true, "Broom" )
ladxr_items:add( 0xA1, true, "Fishing Hook" )
ladxr_items:add( 0xA2, true, "Necklace" )
ladxr_items:add( 0xA3, true, "Scale" )
ladxr_items:add( 0xA4, true, "Magnifying Lens" )







function get_item_msg(item_id)
	local item = ladxr_items[item_id]
	emu.log(string.format("item request: %x %d", item_id, item_id))
	emu.log(string.format("mem request: %4x", item.memaddr or 0))
	emu.log(string.format("mem result: %4x", mem.byte[item.memaddr or 0]))
	if item.memaddr then
		return string.format(item.name, mem.byte[item.memaddr]), item.major
	end
	return item.name, item.major
end


do
	local itembar_state = 0		-- closed / opening / open / closing
	local itembar_trans_time = 10
	local itembar_timer = 0		-- time transitioning between them
	local itembar_time_major = 90
	local itembar_time_minor = 45
	local itembar_size = 6

	local itembar_queue = {}
	function add_itemline(msg, major)
		local textsize = emu.measureString(msg)
		table.insert(itembar_queue, { msg = msg, major = major, size = textsize})
		if itembar_state == 0 then
			itembar_state = 1
		end
	end

	function draw_itemlines()
		-- emu.drawString(0, 116, string.format("s=%d t=%d l=%d", itembar_state, itembar_timer, #itembar_queue))
		-- y=124~139
		local yc	= 136
		local trans_timer = itembar_trans_time
		if itembar_state == 0 then
			return
		end
		if itembar_state == 1 or itembar_state == 5 then
			-- opening or closing
			local ys = math.floor((itembar_timer / itembar_trans_time) * itembar_size)
			if itembar_state == 5 then
				ys = math.floor(((itembar_trans_time - itembar_timer) / itembar_trans_time) * itembar_size)

			end
			emu.drawRectangle(0, yc - ys, 160, ys * 2, 0x00000000, true)

		else
			-- already open
			emu.drawRectangle(0, yc - itembar_size, 160, itembar_size * 2, 0x00000000, true)

			
			local xw = itembar_queue[1].size.width
			local xc = (xw / 2) * -1
			local xs = 80 + xc
			if itembar_state == 2 then
				-- slide item in
				xs = 160 - math.floor((itembar_timer / itembar_trans_time) * (160 - xs))
			elseif itembar_state == 4 then
				-- slide item out
				xs = xs - math.floor((itembar_timer / itembar_trans_time) * (160 - xs))

			elseif itembar_state == 3 then
				-- open
				trans_timer = itembar_queue[1].major and itembar_time_major or itembar_time_minor
			end

			local icolor = 0xDDDDDD
			local ocolor = 0x222222

			if itembar_queue[1].major then
				icolor = 0xFFFFFF
				ocolor = 0x333333
				if (trans_timer - itembar_timer) > 60 then
					icolor = 0xFFFFFF
					ocolor = 0x444444
					if (itembar_timer % 4) < 2 then
						icolor = 0xFFFFFF
						ocolor = 0x777777

					end
				end
			end
			textoutline2(xs, yc - 4, itembar_queue[1].msg, icolor, ocolor)
			-- emu.drawString(xs, yc - 4, itembar_queue[1].msg, 0x00FFFFFF)

		end

		itembar_timer = itembar_timer + 1
		if itembar_timer > trans_timer then
			itembar_timer = 0
			itembar_state = (itembar_state + 1) % 6

			if itembar_state == 5 then
				-- delete item pop from queue
				table.remove(itembar_queue, 1)
				if #itembar_queue > 0 then
					-- already open, so just slide in a new item
					itembar_state = 2
				else
					-- clear queue
					itembar_queue = {}
				end
			end
		end


		
		--[[

		local any = false	-- if any were found. if not, clear table
		for i, pop in ipairs(itembar_queue) do
			if pop.ttl > 0 then
				any = true
				-- local nx, ny = pop.func(pop.x, pop.y, pop.msg, pop.size, pop.ttl)
				local nx, ny = pop.func(pop)
				itembar_queue[i].ttl = itembar_queue[i].ttl - 1
				itembar_queue[i].x = nx
				itembar_queue[i].y = ny
			end
		end
		if not any then itembar_queue = {} end
		--]]
		return
	end
end






require "ladxr/popups"







function track_itemmessage()
	-- ItemMessage override
	local item_id = cpuregisters.a
	-- emu.displayMessage("Item", string.format("Got item: %02X", item_id))
	cpuregisters.pc = cpuregisters.pc + (0xB - 0x05) -- skip out of routine, go to nearest ret
	local msg, major = get_item_msg(item_id)
	add_itemline(msg, major)
	
end

-- see https://github.com/daid/LADXR/blob/master/patches/bank3e.asm/main.asm
local ladxrmain = bank(0x3E, 0x4000)	-- ROM offset of the LADXR jump table
local jumptable = bank(0x3E, 0x4008)	-- jump table start

local ladxr_im_raw = jumptable + 0x02 * 0x03
local ladxr_im_rawr = prg.word[ladxr_im_raw]
local ladxr_itemmessage = bank(0x3E, prg.word[jumptable + 0x02 * 0x03] + 5)		-- ItemMessage is #3
emu.log(string.format("o1: $%06X", ladxrmain))
emu.log(string.format("jt: $%06X", jumptable))
emu.log(string.format("im: $%06X", ladxr_im_raw))
emu.log(string.format("im: $%06X", ladxr_im_rawr))
emu.log(string.format("im: $%06X", ladxr_itemmessage))

emu.log(string.format("ass: $%02X $%02X", prg.byte[ladxr_im_raw], prg.byte[ladxr_im_raw + 1]))


emu.addMemoryCallback(track_itemmessage, emu.callbackType.exec, ladxr_itemmessage, ladxr_itemmessage, emu.cpuType.gameboy, emu.memType.gbPrgRom)







function our_overlay()

	local linkx	= mem.byte[0xFF98]
	local linky	= mem.byte[0xFF99]
	-- emu.drawString(5, 5, "hello world")
	-- emu.drawString(5, 15, string.format("%02X", sram.byte[0x1010]))

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

	-- emu.drawRectangle(linkx - 3, linky - 3, 7, 7)
	-- emu.drawString(linkx - 3, linky - 11, "*")

end

emu.addEventCallback(our_overlay, emu.eventType.startFrame)
