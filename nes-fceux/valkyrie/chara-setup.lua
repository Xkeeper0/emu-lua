
-- ************************************************************************************
-- Start / Character Creation menu
-- Hides the original text and writes new Lua-based descriptions
-- as well as showing the effects of various options
function charaselect()
	local asign			= memory.readbyte(0x0110)
	local btype			= memory.readbyte(0x0111)
	local currentoption	= memory.readbyte(0x002B)

	-- gui.line( 92,  30, 92, 130, "#ffffff")


	gui.box( 13,  48,  96,  64, black);		-- cover JP text
	gui.box( 13,  80,  96,  96, black);		-- cover JP text
	gui.box( 13, 112,  96, 128, black);		-- cover JP text
	gui.box(160,  48, 231,  64, black);		-- cover JP text

	gui.text( 74,  24, " Create your Valkyrie! ", "white", "clear")

	gui.text( 15,  53, "Astrological sign:", (currentoption == 0 and "white" or "gray"), "clear")
	gui.text(158,  53, asigns[asign], "white", "clear")
	if currentoption == 0 then
		gui.text(15, 62, "Determines your\nstarting HP/MP.", "gray", "clear")
	end

	gui.text( 41,  85, "Blood type:", (currentoption == 1 and "white" or "gray"), "clear")
	if currentoption == 1 then
		gui.text(15, 94, " Determines your\nEXP growth curve.", "gray", "clear")
	end

	--	gui.text(164,  83, string.format("%s (%X)", btypes[btype], btype))

	gui.text( 26, 117, "Clothing color:", (currentoption == 2 and "white" or "gray"), "clear")

	
	asign2	= math.fmod(asign, 4)
	if asign2 == 0 then
		shp	= 64
		smp	= 32
	elseif asign2 == 1 then
		shp	= 48
		smp	= 48
	elseif asign2 == 2 then
		shp	= 32
		smp	= 64
	elseif asign2 == 3 then
		shp	= 33
		smp	= 63
	end

	strength	= 10 + math.floor(shp / 32)

	gui.text(  8, 135, "Max HP:", "white", "clear")
	gui.text(  8, 143, "Max MP:", "white", "clear")
	gui.text( 47, 135, " ".. shp, "white", "clear")
	gui.text( 47, 143, " ".. smp, "white", "clear")

	local shpsize	= hpwidth(shp, 16, 100)
	local smpsize	= hpwidth(smp, 16, 100)

	lifebar( 68, 136, shpsize,  4, 64, 64, "#ffcc00", "#880000")
	lifebar( 68, 144, smpsize,  4, 64, 64, "#9999ff", "#0000dd")

	gui.text(214, 136, "STR: ".. strength, "white", "clear")
	gui.text(214, 146, "Starting\n Magic:", "white", "clear")
	if smp >= 40 then
		gui.text(223, 162, "Heal", "yellow", "clear")
	end
	if smp >= 60 then
		gui.text(217, 170, "Fireball", "yellow", "clear")
	end
	
	

	graphx	= 20
	graphy	= 160

	gui.text(graphx - 10, graphy + 65, "Lv.", "white", "clear")

	for i = 1, 12 do
		thispointx	= i * 15 + graphx
		gui.line(thispointx, graphy, thispointx, graphy + 63, "#000088")
		gui.text(thispointx - 4 - (string.len(string.format("%d", i)) - 1) * 3, graphy + 65, string.format("%d", i), "white", "clear")
	end


	for i = 0, 7 do
		lg			= i * 3
		thispointy	= graphy + 63 - (lg) * 3
		gui.line(graphx + 15, thispointy, graphx + 180, thispointy, "#000088")
	
		local exphdg	= getexpforexplevel(lg)
		gui.text(graphx - 16, thispointy - 2, string.format("%5d", exphdg), "#9999ff", "clear")

	end

	gui.line(graphx + 15, graphy     , graphx +  15, graphy + 63, "#9999ff")
	gui.line(graphx + 15, graphy + 63, graphx + 180, graphy + 63, "#9999ff")

	-- gui.box(graphx + 19, graphy + 1, graphx + 73, graphy + 8, "#666666")
	gui.text(graphx + 18, graphy + 2, "EXP Curve", "gray", "clear")


	local btypes	= { 0, 1, 2 }
	btypes[4]		= btype

	lastpointx	= graphx
	lastpointy	= graphy + 180
	for btypetoshow	= 1, 4 do
		lastpointx	= graphx
		lastpointy	= graphy + 180
		for i = 1, 12 do
			thispointx	= i * 15 + graphx
			thispointy	= graphy + 63 - (leveltable[btypes[btypetoshow]][i] * 3)
			if i > 1 then
				gui.line(lastpointx, lastpointy, thispointx, thispointy, btype == btypes[btypetoshow] and "white" or "#444444")
			end
			lastpointx	= thispointx
			lastpointy	= thispointy
		end
	end

	if btype == 3 then
		if (timer % 10) == 0 then
			leveltable[3]	= getrandomleveltable()
		end
		gui.text(graphx + 74, graphy + 28 + math.sin(timer / 12) * 2, " Random ", "yellow", "clear")
	end

end

