--require "x_functions";
--[[


	C600		Objects ($20 bytes ea)

	DE06		VRAM update area
]]


CAMERA_SCREEN_OFFSET_X	= 160 / 2
CAMERA_SCREEN_OFFSET_Y	= 144 / 2


function cameraToVRAM(x, y)

	 -- 9800 ~ 9BFF
	 -- $20 tiles/line

	 local subx	= math.floor((x % 256) / 8)
	 local suby	= math.floor((y % 256) / 8)

	 return 0x9800 + (suby * 0x20 + subx)

end


function screenToCamera(x, y)


	local camerax		= memory.readword(0xFFCA);
	local cameray		= memory.readword(0xFFC8);

	return camerax + (x - CAMERA_SCREEN_OFFSET_X), cameray + (y - CAMERA_SCREEN_OFFSET_Y)


end

function cameraToScreen(x, y)


	local camerax		= memory.readword(0xFFCA);
	local cameray		= memory.readword(0xFFC8);

	return (x + CAMERA_SCREEN_OFFSET_X) - camerax, (y + CAMERA_SCREEN_OFFSET_Y) - cameray


end


function drawMouse(m)
	gui.line(m.xmouse, m.ymouse, m.xmouse + 5, m.ymouse, 0xFFFFFFFF)
	gui.line(m.xmouse, m.ymouse, m.xmouse, m.ymouse + 5, 0xFFFFFFFF)
	gui.line(m.xmouse + 1, m.ymouse + 1, m.xmouse + 4, m.ymouse + 1, 0x000000FF)
	gui.line(m.xmouse + 1, m.ymouse + 2, m.xmouse + 3, m.ymouse + 2, 0x000000FF)
	gui.line(m.xmouse + 1, m.ymouse + 3, m.xmouse + 2, m.ymouse + 3, 0x000000FF)
	gui.line(m.xmouse + 1, m.ymouse + 4, m.xmouse + 1, m.ymouse + 4, 0x000000FF)
end




mapsquares	= {};
for i = 0, 0xFF do
	mapsquares[i]	= {};
end;

brushsize	= 1;
graphsize	= 3;
timer		= 0;
inpt		= input.get()

while true do

	last		= inpt
	inpt		= input.get()


	timer		= timer + 1;
	playerx		= memory.readword(0xFFC2);
	playery		= memory.readword(0xFFC0);
	camerax		= memory.readword(0xFFCA);
	cameray		= memory.readword(0xFFC8);

	cameraofsx	= (playerx - camerax)
	cameraofsy	= (playery - cameray)
	cameraadjx	= cameraofsx + (160 / 2)
	cameraadjy	= cameraofsy + ((144 - 8) / 2)

	--gui.box(cameraadjx - 2, cameraadjy - 2, cameraadjx + 2, cameraadjy + 2, 0xFF0000)

	memory.writebyte(memory.readword(0xFFAA), math.random(0, 255))



	mapx		= math.floor(playerx / 0x100);
	mapy		= math.floor(playery / 0x100);
	mapsquares[mapx][mapy]	= 1;

	local mousex, mousey	= screenToCamera(inpt.xmouse, inpt.ymouse)
	local mouseVRAM			= cameraToVRAM(mousex, mousey)
	local smousex, smousey	= cameraToScreen(math.floor(mousex / 8) * 8, math.floor(mousey / 8) * 8)

	--[[
	gui.text(  0,  0, string.format("P %04X %04X", playerx, playery), 0xFFFFFFFF);
	gui.text( 57,  0, string.format("C %04X %04X", camerax, cameray), 0xFFBBBBFF);
	gui.text(114,  0, string.format("O %4d %4d", cameraofsx, cameraofsy), 0xFF7777FF);


	gui.text(  0,  8, string.format("M %04X %04X", math.min(0xFFFF, mousex), math.min(0xFFFF, mousey)), 0xBBFFBBFF);
	gui.text( 57,  8, string.format("M VRAM %04X = %02X", mouseVRAM, memory.readbyte(mouseVRAM)), 0x77FF77FF);
	gui.text(  0, 16, string.format("S %4d %4d", math.min(0xFFFF, smousex), math.min(0xFFFF, smousey)), 0xBBBBFFFF);

	--]]

	--gui.box(smousex, smousey, smousex + 10, smousey + 10, 0xFF00FFFF)
	
	mousecolorm	= math.floor((math.sin(timer / 6) * 40 + 40))
	mousecolor	= 0x0000FF00 + (0x01010000 * mousecolorm * 2) + 0x7F - math.floor(mousecolorm / 2)
	gui.box(smousex - 1, smousey - 1, smousex + 8 * brushsize, smousey + 8 * brushsize, mousecolor, 0x222255FF)


	if inpt.leftclick or inpt.rightclick then
		local val	= inpt.leftclick and 0xFF or 0x06
		for ix = 1, brushsize do
			for iy = 1, brushsize do
				local lmouseVRAM			= cameraToVRAM(mousex + (ix - 1) * 8, mousey + (iy - 1) * 8)
				memory.writebyte(lmouseVRAM, val)
			end
		end
	end

	if inpt['leftbracket'] and not last['leftbracket'] then
		brushsize	= math.max(1, brushsize - 1)
	end

	if inpt['rightbracket'] and not last['rightbracket'] then
		brushsize	= math.min(4, brushsize + 1)
	end


	for tx, tz in pairs(mapsquares) do
		for ty, tz in pairs(tz) do
			gui.box(-1 + tx * graphsize, -1 + ty * graphsize, 3 + tx * graphsize, 3 + ty * graphsize, 0x88888880, 0x88888800);
--			t	= t + 8;
		end;
	end;


	if math.fmod(timer, 20) < 10 then
		gui.box(0 + mapx * graphsize, 0 + mapy * graphsize, 2 + mapx * graphsize, 2 + mapy * graphsize, nil, 0xFFFF00FF);
	else
		gui.box(0 + mapx * graphsize, 0 + mapy * graphsize, 2 + mapx * graphsize, 2 + mapy * graphsize, nil, 0xFF0000FF);
	end;


	-- drawMouse(inpt);





	emu.frameadvance();

end;
