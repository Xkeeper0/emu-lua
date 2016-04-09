
	local PartyPokemon	= {}



	function PartyPokemon.new(index)

		local start			= offsets['party'] + 8 + (index * 0x2C)
		print(string.format("%04x %02x %04x", start, index, offsets['party']))
		local ret	= {

					values	= {
						-- Relevant values as mObjects here
						level		= mObject.new(start + 0x21),
						statusRaw	= mObject.new(start + 0x04),
						hp			= {
							current		= mObject.new(start + 0x01, 'word'),
							max			= mObject.new(start + 0x22, 'word'),
							},
						},
					
					}



		local mt	= {
			__index	= function (table, key)
				if table.values[key] then
					if not table.values[key]['read'] then
						return table.values[key]
					else
						return table.values[key]:read()
					end
				else
					return PartyPokemon[key]
				end
			end
		}

		return setmetatable(ret, mt)

	end



	-- Get a deeper table with the same metatable bullshit as before

	local magicize(real)
		local t		= {}
		local mt	= {
			__index	= function (table, key)
				if table[key] then
					if not table[key]['read'] then
							return magicize(table[key])
						else
							return table[key]:read()
						end
					end
				else
					return nil
				end
			end
		}

		return setmetatable(real, mt)

	end



	return PartyPokemon