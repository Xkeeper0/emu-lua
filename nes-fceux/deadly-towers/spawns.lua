-- spawns

-- spawn positions table
local spawnpostable	= 0xD15F
local spawnpositions = {}
local function readspawnpositions()
	for i = 0, 0x3D do
		local b		= 0
		local ofs	= romfile.word[romaddr(spawnpostable + i * 2, 1)]
		spawnpositions[i]	= {}
		while b < 0x16 and romfile.byte[ofs + (b * 5)] ~= 0x63 do
			spawnpositions[i][b]	= {
				x = romfile.byte[ofs + (b * 5) + 0] * 0x100 + romfile.byte[ofs + (b * 5) + 1],
				y = romfile.byte[ofs + (b * 5) + 2] * 0x100 + romfile.byte[ofs + (b * 5) + 3],
				timer = romfile.byte[ofs + (b * 5) + 4],
			}
			b = b + 1
		end
	end
end
readspawnpositions()

-- spawn table offsets
local spawntables	= {}
spawntables	= {
	romaddr(0xE0B3, 2),
	romaddr(0xE3DB, 2),
	romaddr(0xE611, 2),
}

local spawnlists	= {}
local function readspawnlist(ofs)
	local b = 0
	local list	= {}
	while b < 0x16 and romfile.byte[ofs + b] ~= 0xFF do
		list[b]	= romfile.byte[ofs + b]
		b = b + 1
	end
	return (b + 1), list
end

local function buildspawnlists()
	spawnlists[0]	= {}
	spawnlists[1]	= {}
	spawnlists[2]	= {}
	for i = 0, 0x3D do
		for belldiff = 1, (i < 0x30 and 3 or 1) do
			local romofs	= spawntables[belldiff] + 2 * i
			local ofs		= romfile.word[romofs]
			local num, list	= readspawnlist(romaddr(ofs, 2))
			spawnlists[belldiff-1][i]	= { ofs = ofs, num = num, list = list }
		end
	end
end
buildspawnlists()

local roomnumber	= 0x00
function spawnlistmenu()
	local xp = 30
	local yp = 59
	local xw = 200
	local yh = 0x16 * 8 + 2

	-- for i = 0, 0xF do
	-- 	gui.text(10, 100 + 8 * i, string.format("$%04X %2d", spawnlists[0][i].ofs, spawnlists[0][i].num))
	-- end

	gui.box(xp - 3, yp - 3, xp + xw, yp + yh, "black", "white")

	gui.text(xp - 2, yp - 11, string.format("    %02X                 ", roomnumber), "P11", "white")
	gui.text(xp + 37, yp - 11, roomnames[roomnumber], "black", "white")
	if button(xp - 1, yp - 11, 7) then
		roomnumber		= (0x3E + (roomnumber - 1)) % 0x3E
		mem.byte[0x7F3]	= 0x07
	end
	if button(xp + 7, yp - 11, 7) then
		roomnumber		= (roomnumber + 1) % 0x3E
		mem.byte[0x7F3]	= 0x0C
	end
	

	for i = 0, 0x14 do
		local ypr	= yp + 8 * i
		gui.text(xp + 2, ypr, letterindex(i), "P21", "black")

		if spawnpositions[roomnumber][i + 1] then
			gui.text(xp + xw - 76, ypr, string.format("%4X,%4X  %2X", spawnpositions[roomnumber][i + 1].x, spawnpositions[roomnumber][i + 1].y, spawnpositions[roomnumber][i + 1].timer), "P10", "clear")
		end

		for belldiff = 0, 2 do
			local tcolor	= "white"
			if belldiff ~= 0 and spawnlists[belldiff][roomnumber] then
				if spawnlists[belldiff][roomnumber].ofs == spawnlists[0][roomnumber].ofs then
				tcolor	= "gray"
				elseif spawnlists[belldiff][roomnumber].list[i] ~= spawnlists[0][roomnumber].list[i] then
					tcolor	= "orange"
				end
			end
			if spawnlists[belldiff][roomnumber] and spawnlists[belldiff][roomnumber].list[i] == 0x19 then
				tcolor	= "P03"
			end

			if spawnlists[belldiff][roomnumber] and spawnlists[belldiff][roomnumber].list[i] then

				gui.text(xp + 16 + belldiff * 38, ypr, hexs(spawnlists[belldiff][roomnumber].list[i]), tcolor, "clear")
			else
				-- gui.text(xp + 16 + belldiff * 38, ypr, "--", "#808080", "clear")
			end
		end
	end
end
