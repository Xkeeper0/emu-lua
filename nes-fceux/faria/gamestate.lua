
	local gameState	= {}

	function gameState.getMusicPointer()
		return memory.readword(0x0004)
	end

	local musicPointers	= {}
	musicPointers[0xe6eb]	= "battle"
	musicPointers[0xe6df]	= "battle"
	musicPointers[0xe6f1]	= "dungeon"

	musicPointers[0xe6e5]	= "title"

	musicPointers[0xe6fd]	= "town"
	musicPointers[0xe703]	= "town"

	musicPointers[0xe6d9]	= "castle"

	musicPointers[0xe6b5]	= "overworld"


	-- Todo: There are a lot more than this
	-- This is also a really awful way to check, surely there's better...
	function gameState.get()

		local musicPointer	= gameState.getMusicPointer()

		if musicPointers[musicPointer] then
			return musicPointers[musicPointer]
		else
			return "unknown"
		end

	end



	return gameState