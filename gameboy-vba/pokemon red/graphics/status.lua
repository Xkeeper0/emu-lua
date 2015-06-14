
	-- to do: rename to something less bad
	status	= {}


	function status.drawPartyPokemon(party)

		gui.box(-1, -1, 160, 53, "#000000e0", "#000000d0")

		for index, poke in pairs(party.pokemon) do

			-- print everything here

			local y		= index * 9 + 1

			gui.text(  1,   y, string.format("%-10s Lv%3d HP %3d/%3d", poke.name, poke.level, poke.hp.current, poke.hp.max), "white", "clear")
			fart.progressBar(112, y + 2, 45, 3, poke.hp.current, poke.hp.max)

		end


	end



	function status.drawSinglePokemonStats(poke)


		--[[
		--]]--

		gui.box(-1, -1, 160, 80, "#000000e0", "#000000d0")

		gui.text(  1,   1, string.format("%-10s    HP %3d/%3d", poke.name, poke.hp.current, poke.hp.max), "white", "clear")
		fart.progressBar( 98, 2, 60, 3, poke.hp.current, poke.hp.max)

		gui.text(  1,   9, string.format("  Level %3d   Status %3d   Type %d/%d", poke.level, poke.statusRaw, poke.type.first, poke.type.second), "white", "clear")
		gui.text(  1,  17, string.format("  EXP  %7d", poke.exp), "white", "clear")

		gui.text(  1,  30, "Stats", "white", "clear")
		gui.text(  1,  38, string.format("HP   %3d  (IV %2d, EV %5d  +%3d)", poke.hp.max       , poke.ivs.hp     , poke.statExp.raw.hp     , poke.statExp.bonus.hp      ), "white", "clear")
		gui.text(  1,  46, string.format("Atk  %3d  (IV %2d, EV %5d  +%3d)", poke.stats.attack , poke.ivs.attack , poke.statExp.raw.attack , poke.statExp.bonus.attack  ), "white", "clear")
		gui.text(  1,  54, string.format("Def  %3d  (IV %2d, EV %5d  +%3d)", poke.stats.defense, poke.ivs.defense, poke.statExp.raw.defense, poke.statExp.bonus.defense ), "white", "clear")
		gui.text(  1,  62, string.format("Spd  %3d  (IV %2d, EV %5d  +%3d)", poke.stats.speed  , poke.ivs.speed  , poke.statExp.raw.speed  , poke.statExp.bonus.speed   ), "white", "clear")
		gui.text(  1,  70, string.format("Spc  %3d  (IV %2d, EV %5d  +%3d)", poke.stats.special, poke.ivs.special, poke.statExp.raw.special, poke.statExp.bonus.special ), "white", "clear")


	end

	--[[

		local pokedata	= {
			species		= m.rb(start + 0x00),
			speciesQ	= m.rb(quickSpecies),
			hp			= {
				current		= m.rw(start + 0x01),
				max			= m.rw(start + 0x22), -- non-box only
				},
			level		= m.rb(start + 0x03),
			status		= m.rb(start + 0x04),
			type		= {
				first		= m.rb(start + 0x05),
				second		= m.rb(start + 0x06),
				},

			catchRate	= m.rb(start + 0x07),	-- used for GSC held items
			moves		= {},		-- will be set latem.r (PP/etc); 08~0B
			otNumber	= m.rw(start + 0x0c),
			exp			= m.r3w(start + 0x0E),
			statExp		= {
				hp			= m.rw(start + 0x11),
				attack		= m.rw(start + 0x13),
				defense		= m.rw(start + 0x15),
				speed		= m.rw(start + 0x17),
				special		= m.rw(start + 0x19)
				},
			iValues		= m.rw(start + 0x1b), -- todo: split these

			-- PP is 1D to 20
			-- Everything beyond here is dropped for
			-- pokes stored in the boxes

			level		= m.rb(start + 0x21),
			stats		= {
				attack		= m.rw(start + 0x24),
				defense		= m.rw(start + 0x26),
				speed		= m.rw(start + 0x28),
				special		= m.rw(start + 0x2A)
				}





			}

	--]]

	return status