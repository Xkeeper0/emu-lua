
ladxr_items = require "ladxr/item-names"



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
		local itembar_bg	= 0x00000000
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
			emu.drawRectangle(0, yc - ys, 160, ys * 2, itembar_bg, true)

		else
			-- already open
			emu.drawRectangle(0, yc - itembar_size, 160, itembar_size * 2, itembar_bg, true)

			
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

		return
	end
end



function track_itemmessage()
	-- ItemMessage override
	local item_id = cpuregisters.a
	-- emu.displayMessage("Item", string.format("Got item: %02X", item_id))
	cpuregisters.pc = cpuregisters.pc + (0xB - 0x05) -- skip out of routine, go to nearest ret
	emu.log("test1 ".. hexs(item_id))
	local to_add = ladxr_items:get_itembar_messages(item_id)
	for i, m in ipairs(to_add) do
		emu.log("test3 ".. m.msg)
		add_itemline(m.msg, m.major)
	end
	
end

-- see https://github.com/daid/LADXR/blob/master/patches/bank3e.asm/main.asm
local ladxrmain = bank(0x3E, 0x4000)	-- ROM offset of the LADXR jump table
local jumptable = bank(0x3E, 0x4008)	-- jump table start
-- ItemMessage is #3 in the jump table; skip over a few opcodes to get a reliable hook point
local ladxr_itemmessage = bank(0x3E, prg.word[jumptable + 0x02 * 0x03] + 5)

emu.addMemoryCallback(track_itemmessage, emu.callbackType.exec, ladxr_itemmessage, ladxr_itemmessage, emu.cpuType.gameboy, emu.memType.gbPrgRom)
