
--
-- Data definitions for various bits of Valkyrie no Bouken
--


worldWidth		= 0x1000		-- 4096
worldHeight		=  0xA00		-- 2560

itemlist	= {}
itemlist[0x01]	= "Lantrn"
itemlist[0x02]	= "Lantrn2"
itemlist[0x03]	= "Potion"
itemlist[0x04]	= "Potion2"
itemlist[0x05]	= "Antidt"
itemlist[0x06]	= "Antidt2"
itemlist[0x07]	= "Key"
itemlist[0x08]	= "GoldKey"
itemlist[0x09]	= "Ax"
itemlist[0x0a]	= "Ax2"
itemlist[0x0b]	= "Sword"
itemlist[0x0c]	= "Sword2"
itemlist[0x0d]	= "PwSword"
itemlist[0x0e]	= "PwSword2"
itemlist[0x0f]	= "MsSword"
itemlist[0x10]	= "SandraSl"
itemlist[0x11]	= "Mantle"
itemlist[0x12]	= "Mantle2"
itemlist[0x13]	= "Helmet"
itemlist[0x14]	= "Helmet2"
itemlist[0x15]	= "Tent"
itemlist[0x16]	= "Tent2"
itemlist[0x17]	= "Tiara"
itemlist[0x18]	= "Whale"
itemlist[0x19]	= "CureAll"
itemlist[0x1a]	= "TimeKey"
itemlist[0x1b]	= "Ship"
itemlist[0x1c]	= "Cash"

--[[
	Presenting: The EXP table, in ASCII format!

    | 1-5 | 5-10 | 10+  (level requirement per lv. up)
A   |  +2 |  +2  | +1
B   |  +1 |  +3  | +1
O   |  +3 |  +1  | +1
AB  | (+1+1+2+3) | +1   (randomly picked)

	Thanks for enjoying this little table.
--]]
exptable	= {
	     0,		-- 0x00
	    20,		-- 0x01
	    50,		-- 0x02
	    90,		-- 0x03
	   150,		-- 0x04
	   230,		-- 0x05
	   350,		-- 0x06
	   510,		-- 0x07
	   750,		-- 0x08
	  1100,		-- 0x09
	  1600,		-- 0x0A
	  2200,		-- 0x0B
	  3200,		-- 0x0C
	  4400,		-- 0x0D
	  6400,		-- 0x0E
	  9000,		-- 0x0F
	 12000,		-- 0x10
	 15000,		-- 0x11
	 20000,		-- 0x12 (10K/ea after this)
	}


-- gets the required exp amount for a given exp level
-- after a point, the table goes up by 10k each
function getexpforexplevel(nextlv)
	if nextlv <= 0x12 then
		return exptable[nextlv + 1]
	else
		return (nextlv - 0x12) * 10000 + 20000
	end
end

-- gets the previous exp level for a given exp
function getexplevelforgrowth(growth, level)
	if growth == 0 then
		if level >= 10 then
			return 0x12 + (level - 10)
		end
		return (level - 1) * 2
	elseif growth == 1 then
		if level >= 10 then
			return 0x13 + (level - 10)
		end
		if level <= 5 then
			return (level - 1)
		end
		return 4 + (level - 5) * 3

	elseif growth == 2 then
		if level >= 10 then
			return 0x11 + (level - 10)
		end
		if level <= 5 then
			return (level - 1) * 3
		end
		return 0x0c + (level - 5)
	end
	return nil
end


function getrandomleveltable()
	local out	= {0}
	local levelexp	= 1
	for i = 2, 12 do
		out[i]	= levelexp
		
		-- this is 0,3 -> clamp 1,3 because the game does
		-- an AND 0x03, and BEQs to just increase by 1 if 0
		levelexp	= levelexp + (i < 10 and clamp(math.random(0, 3), 1, 3) or 1)
	end
	return out
end

leveltable		= {}
-- even: increases by 2 every time
leveltable[0]	= { 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x13, 0x14}
-- fast-slow: +1 for the first 5, then +3 after that
leveltable[1]	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x07, 0x0A, 0x0D, 0x10, 0x13, 0x14, 0x15}
-- slow-fast: +3 for the first 5, then +1 after that
leveltable[2]	= { 0x00, 0x03, 0x06, 0x09, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13}

for i = 0, 2 do
	for l = 1, 12 do
		local xxx			= getexplevelforgrowth(i, l)
		if (leveltable[i][l] ~= xxx) then
			print("level table mismatch", i, l, leveltable[i][l], xxx)
		end
		leveltable[i][l]	= getexplevelforgrowth(i, l)
	end
end

-- random (+1, +1, +2, or +3; this is just a simulation)
leveltable[3]	= getrandomleveltable()



asigns			= {}
asigns[0x00]	= "Aries"
asigns[0x01]	= "Taurus"
asigns[0x02]	= "Gemini"
asigns[0x03]	= "Cancer"
asigns[0x04]	= "Leo"
asigns[0x05]	= "Virgo"
asigns[0x06]	= "Libra"
asigns[0x07]	= "Scorpio"
asigns[0x08]	= "Sagittarius"
asigns[0x09]	= "Capricorn"
asigns[0x0A]	= "Aquarius"
asigns[0x0B]	= "Pisces"

btypes			= {}
btypes[0x00]	= "A"
btypes[0x01]	= "B"
btypes[0x02]	= "O"
btypes[0x03]	= "AB"
growthrates			= {}
growthrates[0x00]	= "Steady"
growthrates[0x01]	= "Fast-slow"
growthrates[0x02]	= "Slow-fast"
growthrates[0x03]	= "Random"
playercolors	= {}
playercolors[0x00]	= 0x20
playercolors[0x01]	= 0x2C
playercolors[0x02]	= 0x1A
playercolors[0x03]	= 0x25



--[[
	Password before scrambling:
	0  DDDD DDDD
	1  PLLD DDDD
	2  EEEE EEEE
	3  EEEE EEEE
	4  LLLL LLLL
	5  CCGG AAAA
	6  NNPT WHMS
	7  PPPP PPPP
	8  XXXX XXXX
	non-scrambled:
	9  NNNN NQQQ

	[N]Level   [X]EXPTarget
	[L]MaxHP   [P]MaxMP
	[D]ollars  [E]EXP     (both /10)
	[C]olor [G]rowth [A]stro
	[T]iara [W]hale [H]elmet2 [M]antle2 [S]wordM
	[Q] rotate count
--]]

valkyriepw_bit2item = {}
valkyriepw_bit2item[0x01]	= "msword"
valkyriepw_bit2item[0x02]	= "mantle2"
valkyriepw_bit2item[0x04]	= "helmet2"
valkyriepw_bit2item[0x08]	= "whale"
valkyriepw_bit2item[0x10]	= "tiara"

valkyriepw_item2bit = {
	tiara	= 0x10,
	whale	= 0x08,
	helmet2	= 0x04,
	mantle2	= 0x02,
	msword	= 0x01
	}

valkyriepw_letters	= {
	"0","1","2","3","4","5","6","7",
	"8","9","A","B","C","D","E","F",
	"G","H","I","J","K","L","M","N",
	"O","P","Q","R","S","T","U","V",
	"W","X","Y","Z"
	}


do
	local HOOK_PREROTATE		= 0xDEAC
	local HOOK_POSTROTATE		= 0xDED9
	local pbytes_prerotate		= nil
	local pbytes_postrotate		= nil
	function valkyriepw_test_prerotate_hook()
		memory.registerexec(HOOK_PREROTATE, nil)
		if not pbytes_prerotate then return end
		local pbytes_mem		= {}
		for i = 0, 9 do
			pbytes_mem[i]		= mem.byte[0x140 + i]
		end
		print("Pre-rotate: top (code) / bottom (game)")
		print(hexdump(pbytes_prerotate))
		print(hexdump(pbytes_mem))
	end
	function valkyriepw_test_prerotate(pbytes)
		pbytes_prerotate	= {}
		for i = 0, 9 do
			pbytes_prerotate[i]	= pbytes[i]
		end
		memory.registerexec(HOOK_PREROTATE, valkyriepw_test_prerotate_hook)
	end

	function valkyriepw_test_postrotate_hook()
		memory.registerexec(HOOK_POSTROTATE, nil)
		if not pbytes_postrotate then return end
		local pbytes_mem		= {}
		for i = 0, 9 do
			pbytes_mem[i]		= mem.byte[0x140 + i]
		end
		print("Post-rotate: top (code) / bottom (game)")
		print(hexdump(pbytes_postrotate))
		print(hexdump(pbytes_mem))
	end
	function valkyriepw_test_postrotate(pbytes)
		pbytes_postrotate	= {}
		for i = 0, 9 do
			pbytes_postrotate[i]	= pbytes[i]
		end

		memory.registerexec(HOOK_POSTROTATE, valkyriepw_test_postrotate_hook)
	end
end

function valkyriepw_getitemflags()
	local item	= nil
	local items	= {}

	local item2flag	= {}
	item2flag[0x0F]		= "msword"
	item2flag[0x12]		= "mantle2"
	item2flag[0x14]		= "helmet2"
	item2flag[0x17]		= "tiara"
	item2flag[0x18]		= "whale"

	for i = 0, 7 do
		-- check inventory items
		item	= mem.byte[0x0160 + i * 2]
		if item2flag[item] then
			items[item2flag[item]]	= true
		end
	end
	return items
end


function valkyriepw_getgamestate()
	return {
		level		= mem.byte[0x00b9],
		expTarget	= mem.byte[0x00bb],
		maxHP		= mem.word[0x00c4],
		maxMP		= mem.word[0x00c6],
		exp			= memory.readvnb(0x00d5, 5),
		gold		= memory.readvnb(0x00d0, 4),
		color		= mem.byte[0x0112],
		growth		= mem.byte[0x0111],
		astro		= mem.byte[0x0110],
		items		= valkyriepw_getitemflags(),
		shift		= mem.byte[0x002F],
		}
end

function valkyriepw_getpassword(game_state)
	
	local passwordbytes	= valkyriepw_generate(game_state)
	local passwordtextbytes, passwordtext = valkyriepw_converttotext(passwordbytes)
	return passwordtext, passwordtextbytes
end

function valkyriepw_generate(game_state)

	-- Prepare local versions of data for stuffing into the password
	-- Clamping to ensure they fit and don't break anything
	local pwlevel	= clamp(math.floor(game_state.level),     0, 0x080 - 1)
	local pwtarget	= clamp(math.floor(game_state.expTarget), 0, 0x100 - 1)

	local pwgold	= clamp(math.floor(game_state.gold / 10), 0, 0x02000 - 1)	-- (8191, in game cap 6000)
	local pwexp		= clamp(math.floor(game_state.exp / 10),  0, 0x10000 - 1)	-- (65535, in game cap 60000)
	local pwmaxHP	= clamp(game_state.maxHP, 1, 999)	-- 0x400 - 1, 1023; 0 isn't valid here
	local pwmaxMP	= clamp(game_state.maxMP, 0, 999)	-- 0x400 - 1, 1023

	local pwastro	= clamp(game_state.astro,  0, 0x10 - 1)	-- 0-11
	local pwgrowth	= clamp(game_state.growth, 0, 0x04 - 1)	-- 0- 3
	local pwcolor	= clamp(game_state.color,  0, 0x04 - 1)	-- 0- 3

	local pwitems	= 0
	for k,v in pairs(game_state.items) do
		if v and valkyriepw_item2bit[k] then
			pwitems	= OR(pwitems, valkyriepw_item2bit[k])
		end
	end

	local pwshift	= game_state.shift and AND(0x07, game_state.shift) or math.random(0, 7)

	-- Our local versions of our sanitized variables are ready, so let's start inserting them
	local pwb		= {}
	for i = 0, 9 do
		pwb[i]		= 0
	end

	-- 0  DDDD DDDD		(money)
	pwb[0]			= AND(0xFF, pwgold)
	-- 1  PLLD DDDD		(max MP, max HP, money)
	local pw1a		= AND(0x1F, bf.rshift(pwgold, 8))	-- top 5 bits
	local pw1b		= AND(0x03, bf.rshift(pwmaxHP, 8))	-- bits 8 and 9
	local pw1c		= AND(0x01, bf.rshift(pwmaxMP, 8))	-- bit 8
	pwb[1]			= OR(pw1a, bf.lshift(pw1b, 5), bf.lshift(pw1c, 7))
	-- 2  EEEE EEEE		(exp)
	pwb[2]			= AND(0xFF, pwexp)
	-- 3  EEEE EEEE		(exp)
	pwb[3]			= AND(0xFF, bf.rshift(pwexp, 8))
	-- 4  LLLL LLLL		(max HP)
	pwb[4]			= AND(0xFF, pwmaxHP)
	-- 5  CCGG AAAA		(color, growth, astro sign)
	-- these are already clamped to the expected ranges
	pwb[5]			= OR(pwastro, bf.lshift(pwgrowth, 4), bf.lshift(pwcolor, 6))
	-- 6  NNPT WHMS
	local pw6b		= AND(0x01, bf.rshift(pwmaxMP, 9))	-- bit 9
	local pw6c		= AND(0x03, pwlevel)				-- bits 0-1
	pwb[6]			= OR(pwitems, bf.lshift(pw6b, 5), bf.lshift(pw6c, 6))
	-- 7  PPPP PPPP		(max MP)
	pwb[7]			= AND(0xFF, pwmaxMP)
	-- 8  XXXX XXXX
	pwb[8]			= AND(0xFF, pwtarget)
	-- 	9  NNNN NQQQ
	pwb[9]			= OR(AND(0xF8, bf.lshift(pwlevel, 1)), pwshift)

	valkyriepw_test_prerotate(pwb)

	local c			= 0
	while (pwshift >= 0) do
		-- this bit is shifted off, so pre-prep it to shift in
		-- to the first byte
		c	= AND(0x01, pwb[8])
		for i = 0, 8 do
			pwb[i], c	= bf.ROR(pwb[i], c)
		end
		pwshift	= pwshift - 1
	end

	valkyriepw_test_postrotate(pwb)

	return pwb

end



-- converts the password bytes into 5-bit characters
-- 
function valkyriepw_converttotext(pbytes)
	local ptext	= {}
	for i = 0, 17 do
		ptext[i]	= 0
	end

	-- do first 5 password bytes
	local c		= 0
	for pb = 0, 4 do
		for pt = 0, 7 do
			c				= 0
			pbytes[0], c	= bf.LSR(pbytes[0])
			pbytes[1], c	= bf.ROR(pbytes[1], c)
			pbytes[2], c	= bf.ROR(pbytes[2], c)
			pbytes[3], c	= bf.ROR(pbytes[3], c)
			pbytes[4], c	= bf.ROR(pbytes[4], c)
			ptext[pt]		= bf.ROL(ptext[pt], c)

			c				= 0
			pbytes[5], c	= bf.LSR(pbytes[5])
			pbytes[6], c	= bf.ROR(pbytes[6], c)
			pbytes[7], c	= bf.ROR(pbytes[7], c)
			pbytes[8], c	= bf.ROR(pbytes[8], c)
			pbytes[9], c	= bf.ROR(pbytes[9], c)
			ptext[pt + 9]	= bf.ROL(ptext[pt + 9], c)
		end
	end

	-- calculate the checksum and stuff it in the relevant spaces
	local checksum	= 0
	for i = 0, 17 do
		-- bytes 8 and 17 technically aren't counted for this,
		-- but in this case they're still zero so it's fine
		checksum	= checksum + ptext[i]
	end
	ptext[8]		= AND(0x1F, checksum)
	ptext[17]		= AND(0x1F, bf.rshift(checksum, 5))

	local otext		= ""
	for i = 0, 17 do
		otext	= otext .. (valkyriepw_letters[ptext[i] + 1] and valkyriepw_letters[ptext[i] + 1] or ("[".. hexs(ptext[i]) .."]"))
	end
	return ptext, otext

end


spawnTable	= {}
local spawnOfs	= 0x9BE8
local otmp		= 0
local spawncnt	= (0x9CB7 - 0x9BE8) / 3
local uw		= false
-- for i = 0, 207 do	-- ???
for i = 0, (spawncnt - 1) do	-- ???
	-- table start: 9BE8
	-- underworld:  9C4B
	-- table end: 9CB7
	-- 9BE8 ~ 9CB7
	-- 9C4B
	-- 207 spawns(?)
	-- format: XX YY TT
	otmp		= spawnOfs + i * 3
	uw			= otmp >= 0x9C4B
	
	spawnTable[i]	= {
		x		= mem.byte[otmp    ],
		y		= mem.byte[otmp + 1], -- - (uw and worldHeight or 0),
		type	= mem.byte[otmp + 2],
		uw		= uw
	}
end

