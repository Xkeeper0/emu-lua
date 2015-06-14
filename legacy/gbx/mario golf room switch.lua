roomno		= 0x00;


inpt		= {};
last		= {};
inpt		= input.get();


while true do

	last	= inpt;
	inpt	= input.get();
	
	if (inpt['U'] and not last['U']) then
		
		roomno	= roomno - 1;
	
	elseif (inpt['O'] and not last['O']) then
		roomno	= roomno + 1;
	
	end;
	
	memory.writebyte(0xC450, roomno);

	gui.text(0, 0, string.format("%02X", roomno));

	emu.frameadvance();
end;

--]]