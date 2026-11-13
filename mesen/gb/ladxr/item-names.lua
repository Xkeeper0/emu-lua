
local ladxr_items	= {}
function ladxr_items:add(num, major, name, memaddr, func) 
	self[num]	= { name = name, major = major, memaddr = memaddr, func = func }
end


-- returns array of itembar status messages to display
function ladxr_items:get_itembar_messages(item_id)
	emu.log("test ".. hexs(item_id))
	local item = self[item_id]

	if item.func then
		local lines	= item.func(self, item_id)
		return lines
	end
	if item.memaddr then
		return {{ msg = string.format(item.name, mem.byte[item.memaddr]), major = item.major }}
	end
	return {{ msg = item.name, major = item.major}}

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

local inst = {}
inst[1]	= "Full Moon Cello"
inst[2]	= "Conch Horn"
inst[3]	= "Sea Lily's Bell"
inst[4]	= "Surf Harp"
inst[5]	= "Wind Marimba"
inst[6]	= "Coral Triangle"
inst[7]	= "Organ of Evening Calm"
inst[8]	= "Thunder Drum"

local function key_text(level)
	if not level then
		local submap		= mem.byte[c.hMapId]
		level = (submap == 0xFF) and 0 or (submap + 1)
	end
	local maddr	= 0xDB1A + 5 * (level - 1)
	if level == 0x0 then
		maddr	= 0xDDDE
	end
	-- emu.displayMessage("fart", string.format("%02x %04x", level, maddr))
	
	return {
		{ msg = lv[level] .. "Small Key" },
		{ msg = string.format("You currently have %d", mem.byte[maddr]) },
	}
end

local function multimessage(msgs)
	return msgs
end
local function instrument(level)
	return {
		{ msg = lv[level] .. "Instrument", major = true},
		{ msg = inst[level], major = true },
	}
end

local function seashell()
	local num = mem.byte[c.wSeashellsCount]
	if num == 5 or num == 0x10 or num == 0x20 then
		return {
			{ msg = string.format("Secret Seashell (%x/20)", num), major = true},
			{ msg = "New prize available!", major = true },
		}
	elseif num > 0x20 then
		return {
			{ msg = string.format("Secret Seashell (%x/20)", num), major = true},
			{ msg = "That's useless...", major = false },
		}
	end
	return {{ msg = string.format("Secret Seashell (%x/20)", num), major = false}}
end

local function golden_leaves()
	local num = mem.byte[c.wGoldenLeaves]
	if num == 5 then
		return {
			{ msg = "Fifth Golden Leaf", major = true},
			{ msg = "Leaf seed! Leaf seed!", major = false },
		}
	end
	return {{ msg = string.format("Golden Leaf (%x/5)", num), major = true}}

end


ladxr_items:add( 0x00, true, "Power Bracelet L-%d", c.wPowerBraceletLevel, function () 
	local lvl = mem.byte[c.wPowerBraceletLevel]
	return {
		{msg = string.format("Power Bracelet L-%d", lvl), major = true},
		{msg = (lvl == 1 and "You can lift things!" or "So about Face Shrine..."), major = false},
	} end )
ladxr_items:add( 0x01, true, "Shield L-%d", c.wShieldLevel, function () 
	local lvl = mem.byte[c.wShieldLevel]
	return {
		{msg = (lvl == 1 and "Shield" or "Mirror Shield"), major = true},
		{msg = (lvl == 1 and "Blocks attacks and more" or "Slightly more useful"), major = false},
	} end )
ladxr_items:add( 0x02, true, "Bow and Arrows", 0, function () return {
	{ msg = "Bow and Arrows", major = true },
	{ msg = "Free quiver included", major = false },
	} end  )
ladxr_items:add( 0x03, true, "Hookshot", 0, function () return {
	{ msg = "The Hookshot", major = true },
	{ msg = "BOING!", major = false },
	} end  )
ladxr_items:add( 0x04, true, "Magic Rod", 0, function () return {
	{ msg = "Magic Rod", major = true },
	{ msg = "Burn, baby burn!", major = false },
	} end  )
ladxr_items:add( 0x05, true, "Pegasus Boots", 0, function () return {
		{msg = "Pegasus Boots", major = true},
		{msg = "Dash like the wind", major = false},
	} end )
ladxr_items:add( 0x06, true, "Ocarina", 0, function () return {
		{msg = "The Ocarina", major = true},
		{msg = "Learn to play many songs!", major = false},
	} end )
ladxr_items:add( 0x07, true, "Roc's Feather", 0, function () return {
		{msg = "Roc's Feather", major = true},
		{msg = "Time to jump around!", major = false},
	} end )
ladxr_items:add( 0x08, true, "Shovel", 0, function () return {
		{msg = "The Shovel", major = true},
		{msg = "Dig a hole, dig a hole...", major = false},
	} end )
ladxr_items:add( 0x09, true, "Magic Powder", 0, function () return {
		{msg = "Bag of Magic Powder", major = true},
		{msg = "Sprinkle it on stuff!", major = false},
	} end )
ladxr_items:add( 0x0A, true, "Bombs", 0, function () return {
		{msg = "Bombs", major = true},
		{msg = "Very explosive.", major = false},
	} end )
ladxr_items:add( 0x0B, true, "Sword L-%d", c.wSwordLevel, function ()
	local lvl = mem.byte[c.wShieldLevel]
	return {
		{msg = (lvl == 1 and "Sword" or "Koholint Sword"), major = true},
		{msg = (lvl == 1 and "This bad boy is yours!" or "Shoots beams at full HP"), major = false},
	} end )
ladxr_items:add( 0x0C, true, "Flippers", 0, function () return {
		{msg = "The Flippers", major = true},
		{msg = "Time to go swimming!", major = false},
	} end )

ladxr_items:add( 0x0D, true, "Magnifying Lens" )
ladxr_items:add( 0x0E, true, "Boommerang", 0, function () return {
		{msg = "The Boomerang", major = true},
		{msg = "Always comes back!", major = false},
	} end )

ladxr_items:add( 0x0F, true, "Slime Key" )

ladxr_items:add( 0x10, true, "Medicine", 0, function () return {
		{msg = "Secret Medicine", major = true},
		{msg = "Saves you from death once.", major = false},
	} end )
ladxr_items:add( 0x11, true, "Tail Key" )
ladxr_items:add( 0x12, true, "Angler Key" )
ladxr_items:add( 0x13, true, "Face Key" )
ladxr_items:add( 0x14, true, "Bird Key" )
ladxr_items:add( 0x15, true, "Golden Leaf (%d / 5)", 0xDB42, golden_leaves )
ladxr_items:add( 0x16, false, "Dungeon Map" )
ladxr_items:add( 0x17, false, "Dungeon Compass" )
ladxr_items:add( 0x18, false, "Dungeon Stone Beak" )
ladxr_items:add( 0x19, true, "Boss Key" )
ladxr_items:add( 0x1A, false, "Small Key", 0, function () return key_text() end )
ladxr_items:add( 0x1B, false, "50 Rupees. Nice.", 0, function () return {
	{ msg = "50 Rupees", major = false },
	{ msg = "Very nice!", major = false },
	} end  )
ladxr_items:add( 0x1C, false, "20 Rupees! Joy.", 0, function () return {
	{ msg = "20 Rupees", major = false },
	{ msg = "JOY!", major = false },
	} end  )
ladxr_items:add( 0x1D, false, "100 Rupees! Wow!", 0, function () return {
	{ msg = "100 Rupees", major = false },
	{ msg = "You're harpy!", major = false },
	} end  )
ladxr_items:add( 0x1E, false, "200 Rupees! Amazing!", 0, function () return {
	{ msg = "200 Rupees", major = false },
	{ msg = "You're ecstatic!", major = false },
	} end  )
ladxr_items:add( 0x1F, false, "500 Rupees!? What the", 0, function () return {
	{ msg = "500 Rupees", major = false },
	{ msg = "You're rich!", major = false },
	} end  )

ladxr_items:add( 0x20, true, "Secret Seashell (%x/20)", c.wSeashellsCount, seashell ) -- bcd
ladxr_items:add( 0x21, false, "Master Stalfos's letter" )
ladxr_items:add( 0x22, false, "One Gel" )
ladxr_items:add( 0x23, false, lv[1] .. "Small Key (%d)", 0xDB1A + 5 * 0, function () return key_text(1) end)
ladxr_items:add( 0x24, false, lv[2] .. "Small Key (%d)", 0xDB1A + 5 * 1, function () return key_text(2) end)
ladxr_items:add( 0x25, false, lv[3] .. "Small Key (%d)", 0xDB1A + 5 * 2, function () return key_text(3) end)
ladxr_items:add( 0x26, false, lv[4] .. "Small Key (%d)", 0xDB1A + 5 * 3, function () return key_text(4) end)
ladxr_items:add( 0x27, false, lv[5] .. "Small Key (%d)", 0xDB1A + 5 * 4, function () return key_text(5) end)
ladxr_items:add( 0x28, false, lv[6] .. "Small Key (%d)", 0xDB1A + 5 * 5, function () return key_text(6) end)
ladxr_items:add( 0x29, false, lv[7] .. "Small Key (%d)", 0xDB1A + 5 * 6, function () return key_text(7) end)
ladxr_items:add( 0x2A, false, lv[8] .. "Small Key (%d)", 0xDB1A + 5 * 7, function () return key_text(8) end)
ladxr_items:add( 0x2B, false, lv[0] .. "Small Key (%d)", 0xDDDE, function () return key_text(0) end )
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

ladxr_items:add( 0x50, true, "Mushroom" )
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
ladxr_items:add( 0x80, false, "Piece of Heart (%d/4)", c.wHeartPiecesCount, function ()
	local hpc	= c.wHeartPiecesCount
	local mhp	= mem.byte[c.wMaxHearts]
	if hpc ~= 0 then
		return { msg = string.format("Piece of Heart (%d/4)", hpc), major = false }
	else
		return {
			{ msg = "Piece of Heart (4/4)", major = true },
			{ msg = "That completes a heart!", major = false },
			{ msg = string.format("%dth Heart Container", mhp), major = true },
			{ msg = string.format("Max HP is now %d", mhp * 4), major = false },
		}
	end
end)
ladxr_items:add( 0x81, true, "Bow-wow! Good dog.", function () return {
	{ msg = "Bow-Wow", major = true },
	{ msg = "Who put him in here!?", major = false },
	{ msg = "Who put him in here!?", major = false },
	{ msg = "He'll be at the swamp", major = false },
	} end  ) 
ladxr_items:add( 0x82, false, "10 arrows" )
ladxr_items:add( 0x83, false, "1 arrow..." )
ladxr_items:add( 0x84, true, "Magic Powder capacity up!" )
ladxr_items:add( 0x85, true, "Bomb capacity up!" )
ladxr_items:add( 0x86, true, "Arrow capacity up!" )
ladxr_items:add( 0x87, true, "Red Tunic", 0, function () return {
	{ msg = "Red Tunic", major = true },
	{ msg = "Sword damage increased", major = false },
	{ msg = "Change at phone booths", major = false },
	} end  )
ladxr_items:add( 0x88, true, "Blue Tunic", 0, function () return {
	{ msg = "Blue Tunic", major = true },
	{ msg = "Damage taken reduced", major = false },
	{ msg = "Change at phone booths", major = false },
	} end  )
ladxr_items:add( 0x89, true, "Heart Container", 0, function () return {
	-- { msg = "Heart Container", major = true },
	{ msg = string.format("%dth Heart Container", mem.byte[c.wMaxHearts]), major = true },
	{ msg = string.format("Max HP is now %d", mem.byte[c.wMaxHearts] * 4), major = false },
} end )
ladxr_items:add( 0x8A, true, "Lose a Heart Container" )
ladxr_items:add( 0x8B, true, "Ballad of the Wind Fish" ) 
ladxr_items:add( 0x8C, true, "Manbo's Mambo" )
ladxr_items:add( 0x8D, true, "Song of Soul" )
ladxr_items:add( 0x8E, true, "Instrument 1", 0, function () return instrument(1) end )
ladxr_items:add( 0x8F, true, "Instrument 2", 0, function () return instrument(2) end )
ladxr_items:add( 0x90, true, "Instrument 3", 0, function () return instrument(3) end )
ladxr_items:add( 0x91, true, "Instrument 4", 0, function () return instrument(4) end )
ladxr_items:add( 0x92, true, "Instrument 5", 0, function () return instrument(5) end )
ladxr_items:add( 0x93, true, "Instrument 6", 0, function () return instrument(6) end )
ladxr_items:add( 0x94, true, "Instrument 7", 0, function () return instrument(7) end )
ladxr_items:add( 0x95, true, "Instrument 8", 0, function () return instrument(8) end )
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


return ladxr_items