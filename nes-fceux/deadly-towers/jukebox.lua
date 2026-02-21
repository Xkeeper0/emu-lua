-- jukebox
-- 07EB = mute flag
-- 07E3 = music queue
-- 07F3 = sound queue
trackcount	= 0x27
tracklist	= {}
for i = 0, trackcount do
	-- placeholder name
	tracklist[i]	= hexs(i)
end

-- jukebox
do
	tracklist[0]	= "(Silence)"
	tracklist[0x01]	= "Title"
	tracklist[0x02]	= "InsideTower"
	tracklist[0x03]	= "Underground"	-- tower caves
	tracklist[0x04]	= "Damage"		-- sfx
	tracklist[0x05]	= "Ludder"		-- sfx
	tracklist[0x06]	= "?"
	tracklist[0x07]	= "CursorMove"	-- sfx
	tracklist[0x08]	= "PickupItem2"	-- sfx
	tracklist[0x09]	= "PickupItem"	-- sfx
	tracklist[0x0A]	= "Attack"		-- SFX
	tracklist[0x0B]	= "Starting"	-- sfx
	tracklist[0x0C]	= "CursorSel"	-- sfx
	tracklist[0x0D]	= "Dying"		-- sfx
	tracklist[0x0E]	= "BurningBell"
	tracklist[0x0F]	= "BossBattle"
	tracklist[0x10]	= "Password"
	tracklist[0x11]	= "Outside"		-- starting point / early areas
	tracklist[0x12]	= "TowerA"
	tracklist[0x13]	= "TowerB"		-- Karma's favorite
	tracklist[0x14]	= "Town"		-- outside / inner areas?
	tracklist[0x15]	= "TowerC"
	tracklist[0x16]	= "TowerD"
	tracklist[0x17]	= "Ending"		-- according to wii8bitstereo
	tracklist[0x18]	= "TowerE"
	tracklist[0x19]	= "TowerF"
	tracklist[0x1A]	= "TowerG"
	tracklist[0x1B]	= "StaffRoll"
	tracklist[0x1C]	= "?"
	tracklist[0x1D]	= "?"
	tracklist[0x1E]	= "BellsFalling"	-- after final boss defeated
	tracklist[0x1F]	= "PickupBell"
	tracklist[0x20]	= "DungeonA"
	tracklist[0x21]	= "DungeonB"
	tracklist[0x22]	= "DungeonC"
	tracklist[0x23]	= "DungeonD"
	tracklist[0x24]	= "DungeonE"
	tracklist[0x25]	= "DungeonF"
	tracklist[0x26]	= "DungeonG"
	tracklist[0x27]	= "DungeonH"


	musictracks	= {}
	showjukebox	= false
	for i = 0, trackcount do
		-- sorted list of track numbers to use, will make less bad later ...
		table.insert(musictracks, i)
	end

	lastmusic	= -1
	lastmusic2	= -1
	lastsound	= -1
	lastsound2	= -1
	function showmusic(xp, yp)
		if lastmusic ~= -1 and lastmusic < 0xF0 then
			gui.text(xp, yp + 0, string.format("M.%02X:%s", lastmusic, tracklist[lastmusic] and tracklist[lastmusic] or "???"), lastmusic2 ~= 0 and "white" or "P19", lastmusic2 ~= 0 and "P09" or "black")
		end
		if lastsound ~= -1 and lastmusic < 0xF0 then
			gui.text(xp, yp + 8, string.format("S.%02X:%s", lastsound, tracklist[lastsound] and tracklist[lastsound] or "???"), lastsound2 ~= 0 and "white" or "P16", lastsound2 ~= 0 and "P06" or "black")
		end
	end

	function jukebox()
		local xp = 50
		local yp = 60

		local bheight = 8
		local bwidth = 90

		local xpos	= 0
		local ypos	= 0
		local textbg	= "black"
		local b1col		= "gray"
		local b2col		= "gray"
		local colcount	= math.ceil(trackcount / 2)

		gui.box(xp - 4, yp - 2, xp + 172, yp + 162, "#000000B0", "white")
		gui.text(xp - 3, yp - 9, " JUKEBOX ", "black", "white")

		for i = 0, trackcount do
			local col	= math.floor((i) / colcount)
			local row	= (i) % colcount
			xpos	= xp + col * bwidth
			ypos	= yp + row * bheight

			local textbg	= "clear"
			local b1col		= "gray"
			local b2col		= "gray"
			if i == lastmusic then
				textbg	= "#008000"
				b1col	= "green"
			elseif i == lastsound then
				textbg	= "#808000"
				b2col	= "yellow"
			end

			gui.text(xpos, ypos + 1, string.format("   %02X ", i), "white", textbg)
			textshadow(xpos, ypos + 1, string.format("   %02X", i), "P22")

			gui.text(xpos + 33, ypos + 1, string.format("%s", tracklist[i]), "white", textbg)
			textshadow(xpos + 33, ypos + 1, string.format("%s", tracklist[i]))
			if button(xpos, ypos + 2, 6, 4, b1col) then
				mem.byte[0x7E3]	= i
				lastmusic		= i
			end
			if button(xpos + 7, ypos + 2, 6, 4, b2col) then
				mem.byte[0x7F3]	= i
				lastsound		= i
			end
		end
	end
	function trackmusic(addr)
		local new	= mem.byte[addr]
		if addr == 0x07E3 then
			if new == 0xFF then return end
			lastmusic	= new == 0 and lastmusic or new
			lastmusic2	= new

		elseif addr == 0x07F3 then
			if new == 0xFF then return end
			lastsound	= new == 0 and lastsound or new
			lastsound2	= new
		end
	end
	memory.registerwrite(0x07E3, trackmusic)
	memory.registerwrite(0x07F3, trackmusic)
end

