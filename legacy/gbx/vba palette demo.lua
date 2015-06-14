require "x_functions";
require "x_interface";


timer	= 0;
trans	= 0;
while true do
	timer	= timer + 1;
	input.update();


--	box(inpt['xmouse'] - 2, inpt['ymouse'] - 2, inpt['xmouse'] + 2, inpt['ymouse'] + 2, "#ffffff");
--	box(inpt['xmouse'] - 3, inpt['ymouse'] - 3, inpt['xmouse'] + 3, inpt['ymouse'] + 3, "#ffffff");

	gui.transparency(trans);
	for x = 0x00, 0xFF do
		line( x, 16 * 1, x, 16 * 2, string.format("#%02X%02X%02X", x, 0, 0));
		line( x, 16 * 2, x, 16 * 3, string.format("#%02X%02X%02X", x, x, 0));
		line( x, 16 * 3, x, 16 * 4, string.format("#%02X%02X%02X", 0, x, 0));
		line( x, 16 * 4, x, 16 * 5, string.format("#%02X%02X%02X", 0, x, x));
		line( x, 16 * 5, x, 16 * 6, string.format("#%02X%02X%02X", 0, 0, x));
		line( x, 16 * 6, x, 16 * 7, string.format("#%02X%02X%02X", x, 0, x));
		line( x, 16 * 7, x, 16 * 8, string.format("#%02X%02X%02X", x, x, x));
	end;
	bottom	= 16 * 8;
	for y = 8, 16 do
		line( 0, y, 255, y, "#000000");
	end;
	for y = bottom, bottom + 29 do
		line( 0, y, 255, y, "#000000");
	end;


	line( 0, 15, 255, 15, "white");
	line( 0, bottom + 1, 255, bottom + 1, "white");

	
	if math.fmod(timer, 2) < 1 or true then
		c	= "black";
	else
		c	= "white";
	end;

	line(inpt['xmouse'] - 1, 15, inpt['xmouse'] - 1, bottom + 2, c);
	line(inpt['xmouse'] + 1, 15, inpt['xmouse'] + 1, bottom + 2, c);
--	pixel(inpt['xmouse'], 15, c);
--	pixel(inpt['xmouse'], 82, c);
	
	line(inpt['xmouse'], 12, inpt['xmouse'], 15, "white");
	line(inpt['xmouse'], bottom + 2, inpt['xmouse'], bottom + 5, "white");
	tpos	= math.max(0, math.min(242, inpt['xmouse'] - 7));
	text(tpos, bottom + 5, string.format("%02X", inpt['xmouse']));
	
	text(5, bottom + 18, "Transparency:");
	for i = 0, 3 do
		if trans == i then
			c	= "white";
		else
			c	= nil;
		end;
		if (control.button(80 + 15 * i, bottom + 19, 7, 1, i, c)) then
			trans	= i;
		end;
	end;


	FCEU.frameadvance();

end;