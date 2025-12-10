
-- ************************************************************************************
prevexplevel	= false
function doexp()

	-- the ones digit in-game is painted on
	local totalexp	= memory.readvnb(0x00d5, 5)
	local growth	= memory.readbyte(0x0111)
	local level		= memory.readbyte(0x00b9)
	local nextexplv	= memory.readbyte(0x00bb)
	local prevexp	= 0

	local expval	= {}
	expval.level	= 0
	expval.next	= 0
	expval.nextlvexp	= 0
	expval.prev	= 0
	expval.pct	= 0
	expval.exp	= 0
	expval.over	= false

	-- if level == 0 and nextexplv == 0 and then
	-- 	return expval
	-- end


	if growth ~= 3 then
		-- for the simple growth types, we can just get their values

		nextexp		= getexpforexplevel(nextexplv)
		prevexp		= getexpforexplevel(getexplevelforgrowth(growth, level))
		expval.nextlvexp	= nextexp

		if totalexp >= nextexp then
			-- over exp for that level; show the next level
			expval.over	= true
			nextexp		= getexpforexplevel(getexplevelforgrowth(growth, level + 2))
			prevexp		= getexpforexplevel(getexplevelforgrowth(growth, level + 1))
		end

	else
		nextexp		= getexpforexplevel(nextexplv)
		-- random growth type
		if not prevexplevel then
			local guess = math.max(-1, nextexplv - 5)
			local lvexp	= 0
			repeat
				guess		= guess + 1
				lvexp	= getexpforexplevel(guess + 1)
			until lvexp > totalexp
			prevexplevel	= guess
			print(string.format("Guessed previous EXPLevel as %02X", prevexplevel))
		end
		prevexp	= getexpforexplevel(prevexplevel)
		expval.nextlvexp	= nextexp

		if totalexp >= nextexp then
			-- in this case just assume the worst case. maybe they'll be surprised
			expval.over	= true
			nextexp		= getexpforexplevel(nextexplv + 3)
			prevexp		= getexpforexplevel(nextexplv)
		end


	end

	expval.level	= level
	expval.exp	= totalexp
	expval.next	= nextexp - totalexp
	expval.prev	= prevexp
	expval.pct	= prevexp and (math.floor((totalexp - prevexp) / (nextexp - prevexp) * 100)) or 0

	if prevexp == -1 then
		expval.pct	= -1
	end

	return expval
end
