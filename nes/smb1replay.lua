require "x_functions";

savetofilename	= "andrewg-speedrun.xrp";


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
	x_requires(5);

end;






function loadreplay(filename, replaynum)

	replays[replaynum]	= {};

	f	= io.open(filename, "r");
	linesin		= 0;
	finished	= false;
	while not finished do

		inline	= f:read("*line");
		if inline == nil then
			finished	= true;
		
		else


			_, _, s0, s1, s2, s3, s4, s5 = string.find(inline, "^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)")

			replays[replaynum]["f".. s0]	= {
				areaout		= s1 + 0,
				playerxout	= s2 + 0,
				playeryout	= s3 + 0,
				worldout	= s4 + 0,
				playerstate	= s5 + 0,
				};

--[[
			if math.fmod(s0, 10) == 0 then 
				text(1,1, "Loading ".. replaynum .." ... ".. s0);
				FCEU.frameadvance();
			end;
--]]
		end;

	end;

	f:close();

end;



function savereplay(filename, replaydata) 

	stringout	= "";

	f	= io.open(filename, "w");
	for k, v in pairs(replaydata) do
		stringout		= string.format("%d:%d:%d:%d:%d:%d\n", k, v['areaout'], v['playerxout'], v['playeryout'], v['worldout'], v['playerstate']);
		f:write(stringout);
	end;

	f:close();

	return true;

end;


function playermarker(screenx, playerarea, playerworld, replayname, replaydata)

--	text(1, 84, string.format("PA: %04X  RA: %04X", playerarea, replaydata['areaout']));
--	text(1, 92, string.format("PW: %04X  RW: %04X", playerworld, replaydata['worldout']));


	if (playerarea == replaydata['areaout']) and (playerworld == replaydata['worldout']) then
--		text(1, 50, "Drawing player marker");
		if screenx > replaydata['playerxout'] then
			if replaydata['playeryout'] < 0x100 then
				line(1, 1, 8, 8, "#ffffff");
				text(8, 8, replayname);
			elseif replaydata['playeryout'] > 0x200 then
				line(1, 236, 8, 8, "#ffffff");
				text(8, 228, replayname);
			else
				box(1, replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), math.max(1, (replaydata['playerxout'] + 15) - screenx), replaydata['playeryout'] - 0x100 + 0x20, "#ffffff");
				text(2, replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), replayname);
			end;

		elseif screenx + 0x110 <= replaydata['playerxout'] then
			if replaydata['playeryout'] < 0x100 then
				line(255, 1, 247, 8, "#ffffff");
				text(243, 8, replayname);
			elseif replaydata['playeryout'] > 0x200 then
				line(255, 236, 247, 8, "#ffffff");
				text(243, 228, replayname);
			else
				box(255, replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), math.min(255, replaydata['playerxout'] - (screenx + 0x10)), replaydata['playeryout'] - 0x100 + 0x20, "#ffffff");
				text(248, replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), replayname);
			end;
		else
			box(math.max(0, replaydata['playerxout'] - screenx), replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), math.min(255, (replaydata['playerxout'] + 15) - screenx), replaydata['playeryout'] - 0x100 + 0x20, "#ffffff");
			text(math.max(0, replaydata['playerxout'] - screenx), replaydata['playeryout'] - 0x100 + 0x10 * (1 - math.min(replaydata['playerstate'], 1)), replayname);

		end;
	else
--		text(1, 50, "Player out of bounds");

	end;	
	
--[[
		areaout		= areaout,
		playerxout	= playerxout,
		playeryout	= playeryout,
		worldout	= worldout,
		playerstate	= playerstate,
]]
end;




counter			= 0;
replays			= {};
data			= {};
replays			= {};
--loadreplay("test.xrp", "Xk");

--loadreplay("xk00.xrp", "X1");
--loadreplay("xk01.xrp", "X2");
--loadreplay("xk02.xrp", "X3");
--loadreplay("acmlm.xrp", "Ac");
--loadreplay("drag.xrp", "Dg");




while true do

	counter		= counter + 1;

	screenpage		= memory.readbyte(0x071a);
	screenxpos		= memory.readbyte(0x071c);

	arealow			= memory.readbyte(0x00e7);
	areahigh		= memory.readbyte(0x00e8);

	worldnumber		= memory.readbyte(0x075f);
	areanumber		= memory.readbyte(0x0760);

	playerpage		= memory.readbyte(0x006d);
	playerxpos		= memory.readbyte(0x0086);

	playeryposl		= memory.readbyte(0x00ce);
	playeryposh		= memory.readbytesigned(0x00b5);

	playerstate		= memory.readbyte(0x0756);
--[[
	text( 10,   8, string.format("Screen position: %02X.%02X", screenpage, screenxpos));
	text(  1,  16, string.format("Player X position: %02X.%02X", playerpage, playerxpos));
	text(  1,  24, string.format("Player Y position: %02d.%02X", playeryposh, playeryposl));

	text(149,   8, string.format("Area bytes: %02X %02X", areahigh, arealow));
	text(154,  16, string.format("Area data: %02X %02X", worldnumber, areanumber));
	text(161,  24, string.format("Player state: %02X", playerstate));

]]
	text(216, 220, string.format("%6d", counter));

	screenxout		= screenpage * 0x100 + screenxpos;	-- not actually used for output, but still very useful
	areaout			= areahigh * 0x100 + arealow;
	playerxout		= playerpage * 0x100 + playerxpos;
	playeryout		= playeryposh * 0x100 + playeryposl;
	worldout		= worldnumber * 0x100 + areanumber;

	data[counter]	= {
		areaout		= areaout,
		playerxout	= playerxout,
		playeryout	= playeryout,
		worldout	= worldout,
		playerstate	= playerstate,
		};


	joyput	= joypad.read(1);
	if joyput['select'] then
		savereplay(savetofilename, data);
		saved	= true;
	end;


	if saved then
		text(86, 32, "Saved replay data");
	end;

	box(playerxout - screenxout, playeryout - 0x100 + 0x10 * (1 - math.min(playerstate, 1)), playerxout - screenxout + 15, playeryout - 0x100 + 0x20, "#ff0000");

--	stringout		= string.format("%d:%d:%d:%d:%d:%d", counter, areaout, playerxout, playeryout, worldout, playerstate);
--	text(20, 36, "Data: ".. stringout .. "   (".. string.len(stringout) .." len)");

	yp	= 8;
	for k, v in pairs(replays) do
		yp	= yp + 8;
		fc	= "f".. counter;
		if v[fc] then 

			-- text(  16, yp, "Playing replay ".. k ..".");

--[[
			text(  1, 216, string.format("Player X position: %02X.%02X", math.floor(v[fc]['playerxout'] / 0x100), math.fmod(v[fc]['playerxout'], 0x100)));
			text(  1, 224, string.format("Player Y position: %02d.%02X", math.floor(v[fc]['playeryout'] / 0x100), math.fmod(v[fc]['playeryout'], 0x100)));
			text(149, 208, string.format("Area bytes: %02X %02X", math.floor(v[fc]['areaout'] / 0x100), math.fmod(v[fc]['areaout'], 0x100)));
			text(154, 216, string.format("Area data: %02X %02X", math.floor(v[fc]['worldout'] / 0x100), math.fmod(v[fc]['worldout'], 0x100)));
			text(161, 224, string.format("Player state: %02X", v[fc]['playerstate']));
]]
			if v[fc]['areaout'] == areaout and v[fc]['worldout'] == worldout then

			end;

			playermarker(screenxout, areaout, worldout, k, v[fc]);

		else
			text(  16, yp, "Replay ".. k .." ended.");
--			text(  1, 224, "The replay probably ended.");

		end;

--]]	
	end;



	FCEU.frameadvance();

end;






