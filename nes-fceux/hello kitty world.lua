-- hello kitty world (jp)

require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")

do
	local profiledata = {}
	function getCycleCount(key)
		local cur = debugger.getcyclescount()
		local ret = profiledata[key] and (cur - profiledata[key].last) or 0
		profiledata[key] = { last = cur, time = ret }
		return ret
	end
end

nmiTime = 0
frameTime = 0
objHandleTime = 0
copyTimeTotal = 0
copyTimeFrame = 0
framewaitTime = 0

nmiInHandler = 0
nmiInCopy = 0
function objHandleStart()
	getCycleCount("objhandler")
	copyTimeTotal = 0
	nmiInHandler = 0
end
function objHandleEnd()
	objHandleTime = getCycleCount("objhandler") - nmiInHandler
	copyTimeFrame = copyTimeTotal
	copyTimeTotal = 0
end
function copyStart()
	getCycleCount("copy")
	nmiInCopy = 0
end
function copyEnd()
	copyTimeTotal = copyTimeTotal + getCycleCount("copy") - nmiInCopy
end


function nmi()
	getCycleCount("nmi_inside")
	frameTime = getCycleCount("nmi")
end
function nmiEnd()
	nmiTime = getCycleCount("nmi_inside")
	framewaitTime = 0
	nmiInHandler = nmiInHandler + nmiTime
	nmiInCopy = nmiInCopy + nmiTime
end
function framewaitStart()
	getCycleCount("framewait")
end
function framewaitEnd()
	framewaitTime = getCycleCount("framewait") - nmiTime

end


memory.registerexec(0xCCFB, objHandleStart)
memory.registerexec(0xCDF1, objHandleEnd)
memory.registerexec(0xD37E, copyStart) -- obj -> 20
memory.registerexec(0xD38B, copyEnd)
memory.registerexec(0xD38C, copyStart) -- 20 <- obj
memory.registerexec(0xD397, copyEnd)
memory.registerexec(0xC600, nmi)
memory.registerexec(0xC6A4, nmiEnd)
memory.registerexec(0xC25D, framewaitStart)
memory.registerexec(0xC267, framewaitEnd)

local colors = { active = "white", inactive = "gray", textbg = "#000000B0" }

while true do


	for i = 0, 0x1B do
		local ofs = 0x3D0 + i * 0x15
		local str = string.format("%03X\n", ofs)
		-- for ii = 0, 0x14, 2 do
		for ii = 0, 0x0, 2 do
			str = str .. string.format("%02X.%02X\n", memory.readbyte(ofs + ii), memory.readbyte(ofs + ii + 1))
		end
		local tx = (i % 8) * 30
		-- local ty = math.floor(i / 8) * 50
		local ty = math.floor(i / 8) * 16
		local col = (memory.readbyte(ofs) ~= 0) and colors.active or colors.inactive
		gui.text(tx, ty, str, col, colors.textbg)
	end

	-- gui.text(214, 216 + 8 * -3, string.format("%7d", framewaitTime), "gray", "black")
	gui.text(214, 216 + 8 * -2, string.format("%7d", nmiTime), "yellow", "black")
	gui.text(214, 216 + 8 * -1, string.format("%7d", frameTime), "red", "black")
	gui.text(214, 216 + 8 *  0, string.format("%7d", objHandleTime), "green", "black")
	gui.text(214, 216 + 8 *  1, string.format("%7d", copyTimeFrame), "cyan", "black")
	gui.text(174, 216 + 8 *  1, string.format("(%5.2f%%)", (objHandleTime ~= 0 and (copyTimeFrame / objHandleTime) * 100 or 0)), "#0080ff", "black")
	barlen = 40

	gui.box(254 - (barlen * 3), 231, 255, 239, "black")
	if (frameTime > 0) then
		barsize = (objHandleTime / (frameTime)) * barlen
		gui.box(255 - barsize, 236, 255, 239, "red")

		barsize = (copyTimeFrame / (frameTime)) * barlen
		gui.box(255 - barsize, 236, 255, 239, "cyan")

		barsize = (nmiTime / (frameTime)) * barlen
		gui.box(255 - barsize, 233, 255, 234, "yellow")
	end
	for i = 0, 3 do
		gui.box(255 - (barlen * i), 234, 255 - (barlen * i), 237, "white")

	end


	input.update()
	emu.frameadvance()
end