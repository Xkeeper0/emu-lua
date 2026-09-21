-- require('connector_ladx_mesen')

require("libs/functions")


for i = 1, 1000 do
	prg.byte[math.random(0x004000, 0x100000)] = math.random(0x00, 0xFF)
end
emu.log("ROM exploded :)")
