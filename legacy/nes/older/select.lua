function stuff()
	gui.text(8, 8, string.format("%02X", memory.readbyte(0x0026)));
	memory.writebyte(0x0026, AND(memory.readbyte(0x0026), 0xFB));
end;

memory.register(0x0026, stuff);


while (true) do

	joypad.set(1, joypad.read(1)); 
	FCEU.frameadvance();

end;