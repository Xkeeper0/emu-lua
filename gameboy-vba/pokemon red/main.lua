

	game	= "red"

	m		= require("data/memory")
	mObject	= require("data/memoryObject")

	offsets	= require("data/memoryAddresses")

	pokemon	= require("data/pokemon")
	field	= require("data/field")


	status		= require("graphics/status")
	fieldInfo	= require("graphics/fieldInfo")

	-- art farts
	fart		= require("graphics/fart")


	test		= require("data/test")


	local tv	= test.new(0)
	print(tv.level)
	print(tv.hp.current)


	-- good function name (tm)
	function crap_debug_everywhere(t)
		local tmp	= 0
		for k,v in pairs(t) do
			gui.text(1, 1 + tmp * 8, k .. ": ".. tostring(v))
			tmp	= tmp + 1
		end
	end


	while true do
		--gui.text(132, 137, "running")

		local party	= pokemon.data.getPartyPokemon()

		status.drawSinglePokemonStats(party.pokemon[0])
		--status.drawPartyPokemon(pokemon.data.getPartyPokemon())
	

		--fieldInfo.showEncounters(field.getRandomEncounters())

		local ipt	= input.get()
		--gui.text(ipt.xmouse, ipt.ymouse, "x")
		--gui.text(1, 137, string.format("%3d %3d", ipt.xmouse, ipt.ymouse))

		emu.frameadvance()
	end