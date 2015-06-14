

	local field	= {}


	-- Probably random so oops
	function field.getStepsToNextEncounter()
		return 0
	end

	-- Can't have a random encounter while > 0
	function field.getNoBattleStepsRemaining()
		return m.rb(0xd13c)
	end


	function field.inBattle()
		local b	= m.rb(0xd057)
		return (b > 0 and true or false),
				{ 
					wild	= b == 1 and true or false,
					trainer	= b == 2 and true or false
				}
	end


	function field.getRandomEncounters()
		local ret		= {}

		ret.rate		= m.rb(0xd887)	-- not sure how this works
		ret.encounters	= {}

		--[[
			Encounter rates by slot:
			20% 20% 15% 10% 10%
			10%  5%  5%  4%  1%
		]]--

		for i = 0, 9 do
			table.insert(ret.encounters, {
				level	= m.rb(0xd888 + i * 2),
				pokemon	= pokemon.getPokemonByIndex(m.rb(0xd889 + i * 2))
				})

		end
		return ret

	end






	return field