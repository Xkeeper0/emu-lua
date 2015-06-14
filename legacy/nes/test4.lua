function testfunc(x)


	gui.text(8, 16, x);

end;



test	= {testfunc};

while true do

	gui.text(8, 8, "Testing");

	test[1]("OK");

	FCEU.frameadvance();

end;