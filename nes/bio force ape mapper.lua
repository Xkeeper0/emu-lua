require "x_functions";

if not x_requires then
	-- Sanity check. If they require a newer version, let them know.
	timer	= 1;
	while (true) do
		timer = timer + 1;
		for i = 0, 32 do
			gui.drawbox( 6, 28 + i, 250, 92 - i, "#000000");
		end;
		gui.text( 10, 32, string.format("This Lua script requires the x_functions library."));
		gui.text( 53, 42, string.format("It appears you do not have it."));
		gui.text( 39, 58, "Please get the x_functions library at");
		gui.text( 14, 69, "http://xkeeper.shacknet.nu/");
		gui.text(114, 78, "emu/nes/lua/x_functions.lua");

		warningboxcolor	= string.format("%02X", math.floor(math.abs(30 - math.fmod(timer, 60)) / 30 * 0xFF));
		gui.drawbox(7, 29, 249, 91, "#ff" .. warningboxcolor .. warningboxcolor);

		FCEU.frameadvance();
	end;

else
	x_requires(4);
end;


-- Things to be done every frame, so that the main emulation loop can be passed off to other parts
function frame()	
	-- Infinite health.
	memory.writebyte(0x04a2, 0x0F);
	forcepos();

	FCEU.frameadvance();

	if showhud then
		hud();
	end;

	movetimeout	= movetimeout - 1;

	playerx		= memory.readword(0x0485);
	playery		= memory.readword(0x0488);
	camerax		= memory.readword(0x0457);
	cameray		= memory.readword(0x045a);
	stage		= memory.readbyte(0x062b);



	inkeyp		= table.clone(inkey);
	inkey		= input.get();

	if inkey['delete'] and not inkeyp['delete'] then
		playercontrol	= not playercontrol;
	end;

	if inkey['insert'] and not inkeyp['insert'] then
		screenshotmode	= not screenshotmode;
		lolx	= math.random(0, 0x0F00);
		loly	= math.random(0, 0x0F00);
	end;

	if inkey['left'] then
		playerfx	= math.max(playerfx - 16, 0);
	end;	
	if inkey['right'] then
		playerfx	= math.min(playerfx + 16, 0x0FFF);
	end;
	if inkey['up'] then
		playerfy	= math.max(playerfy - 16, 0);
	end;
	if inkey['down'] then
		playerfy	= math.min(playerfy + 16, 0x0FFF);
	end;



end;



function hud()

	text( 188, 218, "Force:");
	if playercontrol == true then
		text( 223, 218, "ON ");
	else
		text( 223, 218, "OFF");
	end;

	text( 188, 226, string.format("%04X %04X", playerfx, playerfy));
	text(   8, 218, string.format("%04X %04X", playerx, playery));
	text(   8, 226, string.format("%04X %04X", camerax, cameray));


	if screenshotmode == true then
		text(  93, 218, "Automove ON ");
	else
		text(  93, 218, "Automove OFF");
	end;
	text(  98, 226, string.format("%04X %04X", desiredx, desiredy));

--	text(8, 100, stage);

end;


-- Moves the player by the max amount possible.
-- Returns false if there is still more movement to be done.
-- returns true if movement is done (camera may not be centered yet)
-- dx, dy are camera.
function moveplayer(dx, dy)
	desiredx	= dx;
	desiredy	= dy;
	dx		= dx + 0x80;
	dy		= dy + 0x70;

	if dx - playerfx ~= 0 then
		if lastdir ~= 0 and movetimeout > 0 then
			text(  80,   8, string.format("H-Wait: %2d", movetimeout));
			return false;
		end;
		lastdir			= 0;
		movetimeout		= 50;
		if dx < playerfx then
			text(  80,   8, string.format("Move left:\n%4Xpx", math.abs(dx - playerfx)));
			playerfx	= playerfx - math.min(8, math.abs(dx - playerfx));
		else
			text(  80,   8, string.format("Move right:\n%4Xpx", math.abs(dx - playerfx)));
			playerfx	= playerfx + math.min(8, math.abs(dx - playerfx));
		end;
	elseif dy - playerfy ~= 0 then
		if lastdir ~= 1 and movetimeout > 0 then
			text(  80,   8, string.format("V-Wait: %2d", movetimeout));
			return false;
		end;
		lastdir			= 1;
		movetimeout		= 50;
		if dy < playerfy then
			text(  80,   8, string.format("Move up:\n%4Xpx", math.abs(dy - playerfy)));
			playerfy	= playerfy - math.min(8, math.abs(dy - playerfy));
		else
			text(  80,   8, string.format("Move down:\n%4Xpx", math.abs(dy - playerfy)));
			playerfy	= playerfy + math.min(8, math.abs(dy - playerfy));
		end;
		
	else
		return true;
	end;

	return false;
end;

function forcepos()
	if playercontrol == true then
		memory.writeword(0x0485, playerfx);
		memory.writeword(0x0488, playerfy);
	end;
end;
memory.register(0x0485, forcepos);


function cartded()
	memory.writebyte(0x07FE, 0);
end;
memory.register(0x07FE, cartded);

desiredx		= 0x0000;
desiredy		= 0x0000;

playercontrol	= true;
screenshotmode	= true;
inkey			= {};
inkeyp			= {};

playerx			= memory.readword(0x0485);
playery			= memory.readword(0x0488);
camerax			= memory.readword(0x0457);
cameray			= memory.readword(0x045a);
stage			= memory.readbyte(0x062b);

playerfx		= math.floor(playerx / 8) * 8;
playerfy		= math.floor(playery / 8) * 8;

movetimeout		= 30;

lolx			= 0;
loly			= 0;
showhud			= true;



function makemap()

	for sy = 0x0000, 0x1000, 0xC0 do
		for sx = 0x0000, 0x1000, 0xE0 do
			while not moveplayer(sx, sy) do
				frame();
			end;

			for delay = 1, 90 do
				frame();
			end;

			FCEU.setrenderplanes(false, true);
			frame();
			frame();

			screenshot	= gui.gdscreenshot()
			f	= io.open(string.format("stage%d/bfamap-%04x-%04x.gd", stage, sx, sy), "wb");
			f:write(screenshot);
			f:close();
		
			frame();
			frame();
			FCEU.setrenderplanes(true, true);

			if sx > 0x0900 then
				sx	= 0xFFFF;
			end;
		end;
		if sy > 0x0900 then
			sy	= 0xFFFF;
		end;
	end;
end;


makemap();

while true do

	text(8, 8, "DONE");
--	if screenshotmode then
--		done	=;
--		if done then
--			text(8, 8, "OK");
--		end;
--	end;
	
	
	frame();
end;