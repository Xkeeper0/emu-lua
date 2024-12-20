while true do

	inpt	= input.get();
	i		= 0;
	for k, v in pairs(inpt) do
		gui.text(0, i * 8 + 8, string.format("%s => %s", k, tostring(v)));
		i	= i + 1;
	end;


	FCEU.frameadvance();

end;