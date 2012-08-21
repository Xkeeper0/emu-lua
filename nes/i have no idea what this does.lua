
require("x_functions");
x_requires(4);



function gameloop ()
	for i = 0x00, 0x13 do
		text(8, 8 + 8 * i + math.floor(i / 4) * 2, string.format("%04X> %02X", 0x4000 + i, memory.readbyte(0x4000 + i)));
	end;

	text(8, 8 + 8 * 0x15 + 8, string.format("%04X> %02X", 0x4000 + 0x15, memory.readbyte(0x4000 + 0x15)));
	text(192, 8, string.format("Writes: %4d", writes));
end;

function test()
	text(64, 8, string.format("4000> %02X", memory.readbyte(0x4000)));
	writes	= writes + 1;
end;
	










gui.register(gameloop);
memory.register(0x4000, test);
writes	= 0;
while (true) do 
	writes	= 0;
	FCEU.frameadvance();
end;