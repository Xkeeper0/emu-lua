
	local pokemonData	= {}




	local statusFlags	= {
		sleep		= 0x04,
		poison		= 0x08,
		burn		= 0x10,
		freeze		= 0x20,
		paralyze	= 0x40
		}

	local ivOrder	= {"special", "speed", "defense", "attack"}




	local function getStatusFromFlags(rawStatus)

		local status	= {}
		for statusFlag, bitMask in pairs(statusFlags) do
			status[statusFlag]	= (AND(rawStatus, bitMask) ~= 0)
		end

		return status

	end



	local function getIVs(rawIVs)

		local ivTable	= {}

		local hpIV		= 0
		for bits, key in ipairs(ivOrder) do

			-- This is convoluted as fuck! yay and will probably not work
			local tmp		= math.floor(rawIVs / math.pow(0x10, bits - 1))
			local iv		= AND(tmp, 0x0F)
			hpIV			= hpIV * 0x02 + AND(iv, 1)
			ivTable[key]	= iv

		end
		ivTable.hp	= hpIV

		return ivTable

	end





	function pokemonData.getPartyPokemon()

		local partySize	= memory.readbyte(offsets['party'])

		local party	= {
			size	= partySize,
			pokemon	= {}
			}

		for index = 0, partySize - 1 do
			party.pokemon[index] = pokemonData.getPartyPokemonByIndex(index)

		end

		return party

	end



	function pokemonData.getPartyPokemonByIndex(id, box)

		local start			= offsets['party'] + 8 + (id * 0x2C)
		local quickSpecies	= offsets['party'] + 1 + (id * 0x00)
		-- if species and quickSpecies are ever different
		-- something has probably gone horribly wrong
		-- given the game we're dealing with this is, uh
		-- considerably more common than one would think

		
		local pokedata	= {
			species		= m.rb(start + 0x00),
			speciesQ	= m.rb(quickSpecies),
			hp			= {
				current		= m.rw(start + 0x01),
				max			= m.rw(start + 0x22), -- non-box only
				},
			level		= m.rb(start + 0x03),
			statusRaw	= m.rb(start + 0x04),
			status		= {},
			type		= {
				first		= m.rb(start + 0x05),
				second		= m.rb(start + 0x06),
				},

			catchRate	= m.rb(start + 0x07),	-- used for GSC held items
			moves		= {},		-- will be set latem.r (PP/etc); 08~0B
			otNumber	= m.rw(start + 0x0c),
			exp			= m.r3w(start + 0x0E),
			statExp		= {
				raw			= {
					hp			= m.rw(start + 0x11),
					attack		= m.rw(start + 0x13),
					defense		= m.rw(start + 0x15),
					speed		= m.rw(start + 0x17),
					special		= m.rw(start + 0x19)
					},
				bonus	= {
					},
				},

			rawIVs		= m.rw(start + 0x1b),
			ivs			= {},
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


		local pokemonPokedexData	= pokemon.getPokemonByIndex(pokedata.species)
		-- Eventually replace name w/ nickname or w/e
		pokedata.name		= pokemonPokedexData.name
		pokedata.pokedex	= pokemonPokedexData.pokedex

		-- IV code
		pokedata.ivs		= getIVs(pokedata.rawIVs)

		pokedata.status		= getStatusFromFlags(pokedata.statusRaw)

		for stat, exp in pairs(pokedata.statExp.raw) do
			pokedata.statExp.bonus[stat]	= math.floor(exp ^ 0.5 / 8 * pokedata.level) / 50
		end


		return pokedata


	end


	return pokemonData