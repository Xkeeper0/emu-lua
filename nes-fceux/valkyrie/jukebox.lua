
local jukeboxTable	= {
	pause              = { 0x0310, 3 },
	death              = { 0x0313, 3 },
	fanfare            = { 0x0316, 2 },
	playerDamage       = { 0x0318, 1 },
	lowHP              = { 0x0319, 1 },
	warp               = { 0x031A, 2 },
	pickupItem         = { 0x031C, 2 },
	pickupMoney        = { 0x031E, 2 },
	playerAttack       = { 0x0320, 1 },
	useAxe             = { 0x0321, 1 },
	spellFireball      = { 0x0322, 2 },
	useLightning       = { 0x0324, 2 },
	enemyDamaged       = { 0x0326, 1 },
	spellHeal          = { 0x0327, 2 },
	spellTimeStop      = { 0x0329, 3 },
	enemyProjectile    = { 0x032C, 1 },
	spellInvisible     = { 0x032D, 3 },
	pitfall            = { 0x0330, 1 },
	enemySpawns        = { 0x0331, 2 },
	itemStolen         = { 0x0333, 1 },
	thief              = { 0x0334, 1 },
	enemyChomp         = { 0x0335, 1 },
	shopBuzz           = { 0x0336, 1 },
	select1            = { 0x0337, 1 },
	select2            = { 0x0338, 1 },
	indoorFootsteps    = { 0x0339, 2 },
	poisoned           = { 0x033B, 3 },
	underworldMusic    = { 0x033E, 3 },
	overworldMusic     = { 0x0341, 3 },
	ending             = { 0x0344, 3 },
	}	

local jukeboxSorted		= { 
	"pause",
	"death",
	"fanfare",
	"playerDamage",
	"lowHP",
	"warp",
	"pickupItem",
	"pickupMoney",
	"playerAttack",
	"useAxe",
	"spellFireball",
	"useLightning",
	"enemyDamaged",
	"spellHeal",
	"spellTimeStop",
	"enemyProjectile",
	"spellInvisible",
	"pitfall",
	"enemySpawns",
	"itemStolen",
	"thief",
	"enemyChomp",
	"shopBuzz",
	"select1",
	"select2",
	"indoorFootsteps",
	"poisoned",
	"underworldMusic",
	"overworldMusic",
	"ending",
}

local bsize		= 7
local lheight	= 12
local lwidth	= 99


function playtrack(name)
	local details	= jukeboxTable[name] or error("idiot. ".. name .." isnt real.")
	for i = 1, details[2] do
		mem.byte[details[1] + i - 1] = 1
	end
end

local function jukeboxTrackButtons(x, y, offset, bytes)

	local anyplaying	= 0

	-- buttons for channel status
	for bnum = 1, bytes do
		local chanstatus	= mem.byte[offset + bnum - 1]
		local chancolor		= chanstatus == 2 and "white" or (chanstatus == 1 and "red" or "gray")
		anyplaying			= math.max(anyplaying, chanstatus)

		if button(x + ((2 - bytes) + bnum) * bsize, y + bsize - 1, bsize - 1, bsize - 3, chancolor) then
			mem.byte[offset + bnum - 1]	= chanstatus ~= 0 and 0 or 1
		end
	end
	
	-- button to play entire track
	local buttoncolor		= anyplaying == 2 and "white" or (anyplaying == 1 and "red" or "gray")
	if button(x + ((3 - bytes) * bsize), y - 1, (bsize * bytes) - 1, bsize - 1, buttoncolor) then
		for bnum = 1, bytes do
			mem.byte[offset + bnum - 1]	= anyplaying ~= 0 and 0 or 1
		end
	end

	return anyplaying

end


function jukeboxControls(x, y)

	-- it does help to sort of write out what you're doing, though.
	-- case in point:
	-- [for every entry in the jukebox table...]
	--    allocate (# bytes * button width + padding) space
	--    draw that many buttons, and a larger functional button
	--    for toggling the entire set
	--  if the width is over some limit, go to the next line of buttons

	local xpos		= 0
	local ypos		= 0
	local num		= 0
	local rows		= 15
	local name		= ""
	local data		= 0
	for k, v in ipairs(jukeboxSorted) do
		name		= v
		data		= jukeboxTable[v]
	-- for name, data in pairs(jukeboxTable) do
		local bytes	= data[2]

		local xpos	= math.floor(num / rows) * lwidth
		local ypos	= (num % rows) * lheight

		gui.box(x + xpos - 2, y + ypos - 2, x + xpos + lwidth - 1 , y + ypos + lheight - 1, "#00000080", "clear")
		local anyplaying	= jukeboxTrackButtons(x + xpos - 1, y + ypos, data[1], data[2])
		textoutline(x + xpos + bsize * 3 + 1, y + ypos + 1, name, anyplaying ~= 0 and "yellow" or "P10", "black")

		num			= num + 1
	end

end


