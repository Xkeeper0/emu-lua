

	local memoryAddresses	= {}


	if game == "red" or game == "blue" then

		-- Bulbapedia's take on the subject of
		-- memory offsets is, uh
		-- laugably inept. Thanks guys!
		--
		-- (for example, they say that the party is
		-- stored at 2F2C in Yellow. As in, in ROM.)

		memoryAddresses['party']		= 0xd163

	end


	return memoryAddresses