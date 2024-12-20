

local chart = {}
local rng = {}
for i = 0, 255 do
	chart[i] = 0
	rng[i] = 0
end

timer = 0
history = 0
calls = 0
totalcalls = 0

function update_rng_history()
	calls = calls + 1
	totalcalls = totalcalls + 1
	if totalcalls % 8 == 0 then
		rng[history] = memory.readbyte(0x0500)
		history = (history + 1) % 256
	end
end

memory.registerexec(0xd349, update_rng_history)


while true do

	chart[timer] = (memory.readbyte(0x0007) ~= 00 and 1 or 0)
	timer = (timer + 1) % 256
	
	for x = 0, 255 do
		gui.line(x, 100, x, 150, (chart[x] == 0 and "black" or "white"))
	end

	local ehistory = 0 -- effective history
	local hvalue = 0 -- history value
	for x = 0, 255 do
		ehistory = (history + x + 1) % 256
		hvalue = rng[ehistory]
		-- gui.text(x * 20, 10, string.format("%02X\n%02X", ehistory, hvalue))
		for y = 0, 7 do
			gui.line(x, 50 + y * 4, x, 50 + y * 4 + 3, (AND(hvalue, math.pow(2, y)) == 0 and "black" or "white"))
		end
	end
	gui.box(255, 84, 255 - (calls / 8), 90, "green")
	gui.text(200, 40, string.format("%4d", calls))
	calls = 0
	gui.line(timer, 90, timer, 160, "red")
	emu.frameadvance()
		
end
