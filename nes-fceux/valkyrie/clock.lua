
function drawclock()
	-- gui.text(188,  23, string.format("GameMode: %02x", gamemode))
	
	--      (x, y, sx, sy, a1, a2, oncolor, offcolor, outerborder, innerborder)
	-- lifebar(194,   1,  60,  2, gamehour, 24, "#ffffff", "#777777", "black")
	-- lifebar(194,   5,  60,  0, gameminute, 60, "#cccccc", "#555555", "black")

	local gametimeH		= mem.byte[0x031]	-- $0 ~ $7F
	local gametimeL		= mem.byte[0x030]	-- $0 ~ $3B (0 - 59 decimal)
	-- total game "day": 7680 ticks ($80 × 60)
	-- minutes in a (real) day: 1440
	-- 86400 seconds in a (real) day ~= 11.25 seconds/tick
	-- honestly i'm not sure how past me came up with the /320 number, i'm too out of it for that
	local gametimeT		= gametimeH * 60 + gametimeL				-- 0 ~ 7679
	local worldtimeH	= math.floor(gametimeT / 320)				-- 320 "ticks" per hour (7680/24)
	local worldtimeM	= math.floor((gametimeT % 320) / 320 * 60)	-- 320 ticks -> 60 minutes (~5 1/3 ea)
	local worldtimeS	= math.floor(math.fmod((gametimeT % 320) / 320 * 3600, 60))	-- remainder


	-- textoutline2(229 - 20,   7, string.format("%02d:%02d:%02d", gamehour, gameminute, gametimef))
	-- textoutline2(229 - 20,  15, string.format("%04X", gametime))
	-- textoutline2(229 - 20,  23, string.format("%02X %02X", mem.byte[0x031], mem.byte[0x30]))
	-- textoutline2(229 - 40,  31, string.format("%02d:%02d:%02d", worldtimeH, worldtimeM, worldtimeS))

	-- 24 x 6 = 192 (128 x 1.5)
	local cx	= 32
	local cw	= 192
	local cs	= (cw / 128)
	local ch	= 2

	-- time segments:
	-- $08 $38 $68 $70 $78
	gui.box(cx - 2, 0, cx + cw + 2, ch + 1, "black")
	gui.box(cx, 0, cx + cw, ch, "yellow")
	gui.box(cx + (0x00 * cs), 0, cx + (0x08 * cs) - 1, ch, "orange")
	gui.box(cx + (0x38 * cs), 0, cx + (0x68 * cs) - 1, ch, "white")
	gui.box(cx + (0x68 * cs), 0, cx + (0x70 * cs) - 1, ch, "orange")
	gui.box(cx + (0x70 * cs), 0, cx + (0x78 * cs) - 1, ch, "blue")
	gui.box(cx + (0x78 * cs), 0, cx + (0x80 * cs), ch, "purple")

	gui.box(cx + (gametimeT / 7680 * cw) - 1, -1, cx + (gametimeT / 7680 * cw) + 1, ch + 2, "white", "black")
	textshadow(cx + (gametimeT / 7680 * cw) - 13, ch + 2, string.format("%02d:%02d", worldtimeH, worldtimeM))
end

