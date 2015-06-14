
	local pokemon	= {}

	local byIndex	= require("data/pokemonByIndex")
	local byPokedex	= require("data/pokemonByPokedex")

	
	pokemon.data	= require("data/pokemonData")


	function pokemon.getPokemonByIndex(id)

		if pokemonByIndex[id] then

			return {
				id		= id,
				pokedex	= byIndex[id],
				name	= byPokedex[byIndex[id]]
				}
		else
			return {
				id		= id,
				pokedex	= 0,
				name	= "(Glitch)"
				}

		end
	end


	return pokemon