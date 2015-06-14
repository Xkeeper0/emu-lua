

	local fart	= {}


	function fart.progressBar(x, y, w, h, value, maximum, minimum)

		local minimum	= minimum and minimum or 0
		local maximum	= maximum and maximum or 1


		-- w - 2 for border or something
		local rw	= w - 2
		local bwp	= (value - minimum) / (maximum - minimum)
		local bw	= math.floor(math.min(1, math.max(0, bwp)) * rw)

		gui.box(x, y, x + w, y + h, "black", "white")
		if bw > 0 then
			gui.box(x + 1, y + 1, x + 1 + bw, y + 1 + h - 2, "green", "green")
		end


	end



	return fart