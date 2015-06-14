while true do

	romsize = (16384 * rom.readbyte(0x04) + 8192 * rom.readbyte(0x05)) + 0x10;

	gui.text(10, 10, string.format("ROM size: %10d (%8.2f kB)", romsize, romsize / 1024));

	FCEU.frameadvance();

end;