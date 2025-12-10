-- inventory editor

local editslot	= false


local function createitemmenu(x, y)
	local xpos	= 0
	local ypos	= 0
	local bwidth	= 62
	local bheight	= 10
	local cols		= 3
	local m			= input.mouse()
	local hit		= false
	gui.box(x, y, x + 182, y + 94, "white", "black")
	for i = 0, 0x1A do
		xpos	= x + 4 + (i % cols) * bwidth
		ypos	= y + 4 + math.floor(i / cols) * bheight

		hit = hitbox(m.x, m.y, xpos - 2, ypos - 1, xpos + (xpos >= 100 and bwidth - 6 or bwidth) - 4, ypos + bheight - 3)
		gui.box(xpos - 2, ypos - 1, xpos + (xpos >= 100 and bwidth - 6 or bwidth) - 4, ypos + bheight - 3, hit and "orange" or "white")

		if hit and input.pressed("leftclick") then
			mem.byte[0x160 + editslot * 2]	= i + 1
			mem.byte[0x161 + editslot * 2]	= mem.byte[0x9B70 + ((i + 1) * 2)]
			playtrack("pickupItem")
			editslot	= false
		end


		-- button(xpos - 2, ypos - 1, (xpos >= 100 and bwidth - 6 or bwidth) - 2, bheight - 2, "white", "clear")
		gui.text(xpos, ypos, hexs(i + 1) ..":".. (itemlist[i + 1] and itemlist[i + 1] or "??"), "black", "clear" )
	end

	if input.pressed("leftclick") and editslot then
		playtrack("select2")
		editslot	= false
	end


end






function inventory()
	if editslot then
		createitemmenu(5, 100)
	end

	local offset	= 0
	local item		= 0
	local uses		= 0
	local x			= 12
	local y			= 194
	local xpos		= 0
	local ypos		= 0
	local bresult	= 0
	local bordercolor	= "clear"

	for i = 0, 7 do
		offset		= 0x160 + i * 2
		item, uses	= mem.byte[offset], mem.byte[offset+1]
		xpos		= x + (i % 4) * 12
		ypos		= y + math.floor(i / 4) * 16
		if editslot == i then
			bordercolor	= (timer % 12) >= 6 and "red" or "yellow"
		else
			bordercolor	= "clear"
		end

		bresult		= multibutton(xpos, ypos, 7, 15, "clear", bordercolor, "yellow")
		if bresult == 1 then
			-- left click
			if item == 0 then
				-- no item here; create one...
				editslot	= i
				playtrack("select1")

			elseif uses ~= 0 and uses ~= 0xFF then
				mem.byte[offset+1]	= math.min(99, uses + 1)		-- uses
				playtrack("select1")
			else
				-- item has infinite uses you doofus
				playtrack("shopBuzz")
			end
		
		elseif item ~= 0 and bresult == 2 then
			-- right click
			mem.byte[offset]	= 0		-- item
			mem.byte[offset+1]	= 0		-- uses
			playtrack("itemStolen")

		end

		if (item > 0 and (uses > 0 and uses < 255)) then
			textshadow(xpos + (uses <= 9 and 3 or 0) - 1, ypos + 13, uses, (uses == 1 and "orange" or "white"), "black")
		end

	end

end
