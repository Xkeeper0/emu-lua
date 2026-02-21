itemnames		= {}
itemnames[0x00]	= "Nothing"
itemnames[0x01]	= "NoHelmet"
itemnames[0x02]	= "ChainHelmet"
itemnames[0x03]	= "IronHelmet"
itemnames[0x04]	= "HyperHelmet"
itemnames[0x05]	= "NoShield"
itemnames[0x06]	= "Shield"
itemnames[0x07]	= "LionShield"
itemnames[0x08]	= "ShieldOfKing"
itemnames[0x09]	= "NoArmor"
itemnames[0x0A]	= "LeatherArmor"
itemnames[0x0B]	= "PlateArmor"
itemnames[0x0C]	= "HyperArmor"
itemnames[0x0D]	= "ShortSword"
itemnames[0x0E]	= "NormalSword"
itemnames[0x0F]	= "DragonSlayer"
itemnames[0x10]	= "Splendor!"
itemnames[0x11]	= "MagicKey"
itemnames[0x12]	= "EvilBell"
itemnames[0x13]	= "FireMagic"
itemnames[0x14]	= "HyperBoots"
itemnames[0x15]	= "Figurine"
itemnames[0x16]	= "Glove"
itemnames[0x17]	= "NormalGlove"
itemnames[0x18]	= "Gauntlet"
itemnames[0x19]	= "DoubleShot"
itemnames[0x1A]	= "ParallelShot"
itemnames[0x1B]	= "BlueCrystal"
itemnames[0x1C]	= "GreenCrystal"
itemnames[0x1D]	= "OrangeCrystal"
itemnames[0x1E]	= "RedCrystal"
itemnames[0x1F]	= "BlueScroll"
itemnames[0x20]	= "GreenScroll"
itemnames[0x21]	= "OrangeScroll"
itemnames[0x22]	= "RedScroll"
itemnames[0x23]	= "BlueNecklace"
itemnames[0x24]	= "GreenNecklace"
itemnames[0x25]	= "OrangeNecklace"
itemnames[0x26]	= "RedNecklace"
itemnames[0x27]	= "BluePotion"
itemnames[0x28]	= "GreenPotion"
itemnames[0x29]	= "OrangePotion"
itemnames[0x2A]	= "RedPotion"
itemnames[0x2B]	= "MagicMace"
itemnames[0x2C]	= "Cup"
itemnames[0x2D]	= "FakeShield"
itemnames[0x2E]	= "FakeCup"

local mc = {}
for i = 0, 8 do
	if i <= 2 then
		mc["defense"..i]	= MemoryAddress.new(0x0170 + i)
		mc["attack"..i]		= MemoryAddress.new(0x0173 + i)
	end
	mc["item"..i]	= MemoryAddress.new(0x0176 + i)
end


inventory		= MemoryCollection.new(mc)

local editslot	= false
local function createitemmenu(x, y)
	local xpos	= -3
	local ypos	= 0
	local bwidth	= 64
	local bheight	= 10
	local cols		= 4
	local m			= input.mouse()
	local hit		= false
	local current	= inventory["item"..editslot]
	gui.box(x, y + 1, x + (bwidth * cols), y + 123, "#bbbbbb", "black")
	for i = 1, 0x2E do
		xpos	= x + 4 + ((i - 1) % cols) * bwidth
		ypos	= y + 4 + math.floor((i - 1) / cols) * bheight

		hit = hitbox(m.x, m.y, xpos - 2, ypos - 1, xpos + bwidth - 4, ypos + bheight - 3)
		gui.box(xpos - 2, ypos - 1, xpos + bwidth - 4, ypos + bheight - 3, hit and "orange" or (current == i and "yellow" or "white"))

		if hit and input.pressed("leftclick") then
			inventory["item"..editslot]	= i
			mem.byte[0x7F3]	= 0x09	-- pickup item
			game.gamestate = 0x10
			editslot	= false
		end


		-- button(xpos - 2, ypos - 1, (xpos >= 100 and bwidth - 6 or bwidth) - 2, bheight - 2, "white", "clear")
		gui.text(xpos, ypos, hexs(i), "gray", "clear" )
		gui.text(xpos + 14, ypos, (itemnames[i] and itemnames[i] or "??"), "black", "clear" )
	end

	-- pretend to be an item for the Nothing slot
	local i = 0x30
	xpos	= x + 4 + ((i - 1) % cols) * bwidth
	ypos	= y + 4 + math.floor((i - 1) / cols) * bheight
	i = 0	-- but we're really this
	hit = hitbox(m.x, m.y, xpos - 2, ypos - 1, xpos + bwidth - 4, ypos + bheight - 3)
	gui.box(xpos - 2, ypos - 1, xpos + bwidth - 4, ypos + bheight - 3, hit and "orange" or (current == i and "yellow" or "white"))
	if hit and input.pressed("leftclick") then
		inventory["item"..editslot]	= 0
		editslot	= false
		mem.byte[0x7F3]	= 0x0C	-- cursor sel
		game.gamestate = 0x10
	end
	gui.text(xpos, ypos, hexs(i), "gray", "clear" )
	gui.text(xpos + 14, ypos, (itemnames[i] and itemnames[i] or "??"), "black", "clear" )


	if input.pressed("leftclick") and editslot then
		editslot	= false
	end


end


function inventoryscreen()
	local xp, yp	= 24, 192
	local iwidth		= 24
	local isize			= 16
	local m			= input.mouse()

	if editslot ~= false then
		createitemmenu(0, 64)
	end

	local bordercolor	= "white"
	for i = 0, 8 do
		if editslot == i then
			bordercolor	= (timer % 12) >= 6 and "red" or "yellow"
		else
			bordercolor	= "gray"
		end

		if multibutton(xp + i * iwidth - 1, yp - 1, isize + 1, isize + 1, "clear", bordercolor, (editslot == i and bordercolor or "white")) == 1 then
			editslot	= i
			mem.byte[0x7F3]	= 0x07	-- cursor move
		end

	end


end
