
	local fieldInfo	= {}

	function fieldInfo.showEncounters(encounters)

		-- god bless fucked up variable names
		for i, v in ipairs(encounters.encounters) do

			gui.text(1, (i - 1) * 8, string.format("%-10s (Lv%3d)", v.pokemon.name, v.level))

		end

	end


	return fieldInfo