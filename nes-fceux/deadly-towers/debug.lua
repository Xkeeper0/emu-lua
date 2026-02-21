
-- debug feature selector
do

	debugkeys		= { 0x0E, 0x15, 0x1B, 0x2A, 0x2E, 0x35, 0x3E }
	debugfuncs		= {}
	debugfuncs[0x0E]	= "0E @ CHRRAM"
	debugfuncs[0x15]	= "15 L CRC"
	debugfuncs[0x1B]	= "1B M MONITOR"
	debugfuncs[0x2A]	= "2A C COLOR"
	debugfuncs[0x2E]	= "2E T TIMER"
	debugfuncs[0x35]	= "35 S SOUND"
	debugfuncs[0x3E]	= "3E ESC (RST)"
	-- 7 1 4 2 5 3 6
	debugrequest	= false
	function debugoptions()
		local xp	= 110
		local yp	= 10
		local ys	= 8
		for i = 0, 6 do
			gui.text(xp, yp + ys * i, string.format("  %s", debugfuncs[debugkeys[i + 1]]))
			if button(xp, yp + ys * i + 1, 10, 4, (debugrequest and debugrequest == debugkeys[i + 1]) and "white" or "gray") then
				debugrequest	= debugkeys[i + 1]
			end
		end
		if debugrequest then
			gui.text(xp, yp + ys * 7, "Reset required", "yellow", "black")
		end
	end
	function debughook(addr)
		if not debugrequest then return end
		if getcurrentbank() ~= 2 then return end

		if addr == 0x8159 then
			-- after UpdateJoypads_2
			game.joypad1	= 0x03			-- A + B
			cpuregisters.a	= 0x03			-- A + B
			print "debug: joypad written"

		elseif addr == 0x817F then
			-- start of ReadFamilyKeyboard
			mem.byte[0x001B]	= debugrequest
			cpuregisters.a		= debugrequest
			cpuregisters.pc		= 0x81DD		-- RTS
			
			print("debug: keyboard written. ".. hexs(debugrequest))
			debugrequest		= false
		end
	end
	memory.registerexec(0x8159, debughook)
	memory.registerexec(0x817F, debughook)
end
