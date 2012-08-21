mx	= 0;
my	= 0;
while true do
	inpt	= input.get();
	if inpt['leftclick'] then
		mx	= inpt['xmouse'];
		my	= inpt['ymouse'];
	end;
	
	hp  = memory.readbyte(0x0048);
	maxhp = memory.readbyte(0x0078)
	chips = memory.readbyte(0x003E)
	ammo = memory.readbyte(0x004C)
	gui.text(  5, 198, string.format("%2d/%2d", hp, maxhp));


	gui.text( 200, 8, string.format("%3d/%3d", mx, my));

	emu.frameadvance()
end