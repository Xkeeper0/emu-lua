
local ranks	= { 'a','2','3','4','5','6','7','8','9','T','J','Q','K', 'A' }
local suits = { 'h','s','d','c' }
local colors = { 'red','black','blue','#008000' }

function decodecard(val)

	local suit	= math.floor(val / 0x10) + 1
	local rank	= (val % 0x10) + 1
	if suit > 4 or rank <= 1 or rank > 14 then return string.format("%02X", val), "red", "#800000" end

	return ranks[rank] .. suits[suit], colors[suit], "white"
end

function drawcard(x, y, val)
	local card, cardcolor, cardback = decodecard(val)
	gui.text(x, y, card, cardcolor, cardback)
end