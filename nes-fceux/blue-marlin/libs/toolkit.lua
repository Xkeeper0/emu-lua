-- SCRIPTS TO MAKE FCEUX SUCK A LITTLE LESS BAD


if not memory.writeword then
	-- in the rare possibility fceux ever gets updated
	
	function memory.writeword(a, v)

		memory.writebyte(a, v % 0x100)
		memory.writebyte(a + 1, math.floor(v / 0x100))

	end
end


