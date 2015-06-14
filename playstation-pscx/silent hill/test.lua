while true do

	for i = 240, 320 do
		gui.text(i, (i - 240) * 2, i);

	end;


	pcsx.frameadvance();

end;