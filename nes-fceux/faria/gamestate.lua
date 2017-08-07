
	local gameState	= {}
	gameState.currentState	= nil

	local knownAddresses	= {}
	knownAddresses[0x815b]	= false		-- Menu trans.
	knownAddresses[0xca60]	= {}
	knownAddresses[0xca60][0x8694]	= "battle"
	knownAddresses[0xca60][0x962e]	= "battle"

	knownAddresses[0xca60][0x891c]	= false	-- Menu

	knownAddresses[0xca60][0xca73]	= "menu"	-- Selected option
	knownAddresses[0xca60][0xa24d]	= "fade"		-- Drawing
	knownAddresses[0xca60][0x809a]	= "fade"		-- Drawing
	knownAddresses[0xca60][0xca7d]	= "menu"		-- Drawing

	knownAddresses[0xca60][0xbe22]	= "battle"	-- Return from menu

	knownAddresses[0xca60][0x86e8]	= "overworld"	-- First loads
	knownAddresses[0xca60][0x820b]	= "overworld"	-- Moved
	knownAddresses[0xca60][0x9f18]	= "town"		-- Moving
	knownAddresses[0xca60][0xa16d]	= "town"		-- Idle




	function gameState.getPointerOffStack()
		local s	= memory.getregister("s")
		local a	= memory.readbyte(0x100 + s + 1) + memory.readbyte(0x100 + s + 2) * 0x100
		return a
	end

	function gameState.trackChanges()
		local v	= memory.readbyte(0x00e9)
		if v == 1 then
			lastfun		= memory.getregister("pc")
			lastfun2	= gameState.getPointerOffStack()
			funcount	= funcount + 1
			if knownAddresses[lastfun] and type(knownAddresses[lastfun]) == "table" then
				if knownAddresses[lastfun][lastfun2] then
					gameState.currentState	= knownAddresses[lastfun][lastfun2]
				end
			elseif knownAddresses[lastfun] then
				gameState.currentState	= knownAddresses[lastfun]
			end

		end

		if gameState.currentState == "battle" and memory.readbyte(0x71a9) == 0xFF then
			gameState.currentState = "dungeon"
		end
	end

	memory.registerwrite(0x00e9, gameState.trackChanges)



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

		if gameState.currentState then
			return gameState.currentState
		else
			return "unknown"
		end

		local musicPointer	= gameState.getMusicPointer()

		if musicPointers[musicPointer] then
			return musicPointers[musicPointer]
		else
			return "unknown"
		end

	end



	return gameState
