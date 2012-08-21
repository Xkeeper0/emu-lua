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


function inptframe(key) 
	if nohotkeys then
		return false;
	end;
	return (inpt[key] and not inptlast[key]);
end;


function drawkeycounter()
	for i = 0, 0x1F do
		memory.writebyte(0x8C80 + i, keycounterart[i + 1]);
	end;
end;


function sortstatmessages(a, b)
	if a.timer ~= b.timer then
		return a.timer < b.timer;
	else
		return a.message > b.message;
	end;
end;

function addstatusmessage(msg)
	table.insert(statusmessages, { timer =  -6, message = msg});
end;

function showstatusmessages(msg)
	table.sort(statusmessages, sortstatmessages);

	local msgdisptime	= 120;
	local msgfadetime	= 30;
	local yp			= - 7;

	for t, m in pairs(statusmessages) do 
		c	= 0;
		ypt	= 0;

		if m['timer'] < 0 then
			yp	= yp - m['timer'];
			c	= 0xFF - math.floor((6 + m['timer']) / 6 * 0xFF);

		elseif m['timer'] > msgdisptime then
			c	= math.min(0xFF, math.floor((m['timer'] - msgdisptime) / msgfadetime * 0xFF));
			ypt	= math.pow((m['timer'] - msgdisptime) / msgfadetime * 5, 2);

		end;


		text(   1, 128 + yp - ypt, m['message'], 0xFFFFFFFF - c, 0x000000FF - c);
		yp	= yp - 7;
		statusmessages[t]['timer']	= statusmessages[t]['timer'] + 1;
	end;
end;






player	= {};
npc		= {};
for i = 0, 0xF do
	npc[i]	= { 
		lockdisp		= 0,
		};
end;

timer					= 0;
inpt					= {};
inptlast				= {};
statmsg					= {};
mode					= 0;
playerl					= {};
timers					= {};
timers['pop-msg']		= 0;
timers['ga-msg']		= 0;
nohotkeys				= false;

keycounterart		= {
	0x0E, 0x0E, 0x1B, 0x1B, 0x11, 0x11, 0x1B, 0x1B, 
	0x3E, 0x3E, 0x60, 0x60, 0xF0, 0xF0, 0xA0, 0xA0, 
	0x00, 0x00, 0x00, 0x00, 0x22, 0x22, 0x14, 0x14, 
	0x08, 0x08, 0x14, 0x14, 0x22, 0x22, 0x00, 0x00,
	}

statusmessages			= {};

shownpcstate		= 1;

addstatusmessage("Q/W: Enable/Disable freemove");
addstatusmessage("Z/X/C: Toggle timer/HP display");
addstatusmessage("A: Show/hide NPC display");
addstatusmessage("P: Disable ALL hotkeys");


while true do

	showstatusmessages();

	timer					= timer + 1;
	inptlast				= table.clone(inpt);
	inpt					= input.get();
	timers['pop-msg']		= timers['pop-msg'] + 1;
	timers['ga-msg']		= timers['ga-msg'] + 1;


--	if inptframe('P') then
--		addstatusmessage("Button goes squish!");
--	end;

	playerl					= table.clone(player);

	player['hpcur']			= memory.readbyte(0xDB5A)
	player['hpmax']			= memory.readbyte(0xDB5B) * 8;
	player['swordcharge']	= memory.readbyte(0xC122);
	player['poweruplife']	= memory.readbyte(0xD47A);
	player['poweruptype']	= memory.readbyte(0xD47C);
	player['counter-ga']	= memory.readbyte(0xD471);
	player['counter-pop']	= memory.readbyte(0xD415);
	player['submap']		= memory.readbyte(0xFFF7);
	player['mapmode']		= memory.readbyte(0xDB5F);

	if player['counter-pop'] ~= playerl['counter-pop'] then
		if timers['pop-msg'] <= 20 then
		
		elseif timers['pop-msg'] < 240 then
			timers['pop-msg']	= 20;
		elseif timers['pop-msg'] < 300 then
			timers['pop-msg']	= math.ceil(((300 - timers['pop-msg']) / 60) * 20);
		elseif timers['pop-msg'] >= 300 then
			timers['pop-msg']	= 0;
		end;
	end;

	if player['counter-ga'] ~= playerl['counter-ga'] then
		if timers['ga-msg'] <= 20 then
		
		elseif timers['ga-msg'] < 240 then
			timers['ga-msg']	= 20;
		elseif timers['ga-msg'] < 300 then
			timers['ga-msg']	= math.ceil(((300 - timers['ga-msg']) / 60) * 20);
		elseif timers['ga-msg'] >= 300 then
			timers['ga-msg']	= 0;
		end;
	end;

	if inptframe('P') then
		nohotkeys	= true;
		addstatusmessage("All keyboard hotkeys disabled!");
		addstatusmessage("This cannot be toggled without");
		addstatusmessage("restarting the script, though.");
	elseif inptframe('Z') then
		mode		= 0;
		addstatusmessage("Displaying sprite health");
	elseif inptframe('X') then
		mode		= 1;
		addstatusmessage("Displaying sprite timers");
	elseif inptframe('C') then
		mode		= 2;
		addstatusmessage("Displaying secondary timer (?)");
	end;
	if inptframe('W') then
		memory.writebyte(0xC17B, 0x00);
		addstatusmessage("Free-move disabled");
	elseif inptframe('Q') then
		memory.writebyte(0xC17B, 0x01);
		addstatusmessage("Free-move enabled");
	end;
	if inptframe('A') then
		shownpcstate	= 1 - shownpcstate;
		addstatusmessage("NPC state display toggled");
	end;


	if timers['pop-msg'] < 300 then
		local a		= 0xFF;
		if timers['pop-msg'] < 20 then
			a		= math.floor(0xFF * timers['pop-msg'] / 20);
		end;
		if timers['pop-msg'] > 240 then
			a		= math.floor(0xFF * (300 - timers['pop-msg']) / 60);
		end;

		text(   1,   3, "Piece of Power", 0xFFDDDD00 + a, 0x00000000 + a);
		text(  71,   3, string.format("%2d/30", player['counter-pop']), 0xFFDDDD00 + a, 0x00000000 + a);
		for i = 0, 29 do
			if i < player['counter-pop'] then
				c		= math.floor(0xFF - math.abs(math.sin((timers['pop-msg'] - i) / 40)) * 0xFF);
				c		= 0x00010100 * c + 0xFF000000 + a;
			else
				c	= 0x80000000 + a;
			end;
			filledbox(1 + i * 3,  1, 2 + i * 3,  2, c);
			box      (0 + i * 3,  0, 3 + i * 3,  3, 0x00000000 + a);
		end;		
	end;


	if timers['ga-msg'] < 300 then
		local a		= 0xFF;
		if timers['ga-msg'] < 20 then
			a		= math.floor(0xFF * timers['ga-msg'] / 20);
		end;
		if timers['ga-msg'] > 240 then
			a		= math.floor(0xFF * (300 - timers['ga-msg']) / 60);
		end;

		text( 112,   3, "Acorn", 0xDDDDFF00 + a, 0x00000000 + a);
		text( 140,   3, string.format("%2d/12", player['counter-ga']), 0xDDDDFF00 + a, 0x00000000 + a);

		for i = 0, 11 do
			if i < player['counter-ga'] then
				c		= math.floor(0x99 - math.abs(math.sin((timers['ga-msg'] - i) / 40)) * 0x99);
				c		= 0x01010000 * c + 0x6666FF00 + a;
			else
				c	= 0x00008000 + a;
			end;
			filledbox(156 - i * 4,  1,  158 - i * 4,  2, c);
			box      (155 - i * 4,  0,  159 - i * 4,  3, 0x00000000 + a);
		end;		
	end;

	if player['swordcharge'] > 0 then
		
		c			= 0x8888FFFF;
		if player['swordcharge'] >= 40 then
			c		= math.ceil(math.abs(math.sin(timer / 10) * 0xFF)) * 0x010100;
			c		= 0xFF0000FF + c;
		end;

		filledbox(   0, 124,  50, 127, 0x000000FF);
		filledbox(   9, 125,  9 + 40, 126, 0x000088FF);
		filledbox(   9, 125,  9 + player['swordcharge'], 126, c);
		text(   1, 121, string.format("%2d", player['swordcharge']));

	end;


	if player['poweruptype'] ~= 0 then

		if player['poweruptype'] == 1 then
			text( 104, 118, "Piece of Power");
			coff		= 0x880000FF;
			con1		= 0xFF0000FF;
			con2		= 0x00010100;
		elseif player['poweruptype'] == 2 then
			text( 104, 118, "Guardian Acorn");
			coff		= 0x000088FF;
			con1		= 0x0000FFFF;
			con2		= 0x01010000;
		else
		end;

		for i = 0, 2 do

			if i >= 3 - player['poweruplife'] then
				c		= coff;
			else
				c		= math.ceil((math.sin((timer - 10 * i) / 15) + 1) / 2 * 0xFF);
				c		= con1 + c * con2;
			end;
--		filledbox(103, 125, 159, 127, 0xFF0000FF);
			filledbox(140 - i * 19, 124, 159 - i * 19, 127, c);
--			box      (103 + i * 19, 124, 103 + i * 19 + 18, 127, 0xFF0000FF);
			box      (140 - i * 19, 124, 159 - i * 19, 127, 0x000000FF);
		end;
	end;


	freeslots	= 0;

	for i = 0, 0xF do
		local npcbase	= 0xE200 + i;

		

	
		npc[i]['x']			= memory.readbyte(0xE200 + i);
		npc[i]['y']			= memory.readbyte(0xE210 + i);
		npc[i]['type']		= memory.readbyte(0xE3A0 + i);
		npc[i]['state']		= memory.readbyte(0xE280 + i);
		npc[i]['health']	= memory.readbyte(0xE360 + i);
		npc[i]['timer']		= memory.readbyte(0xE2E0 + i);

		--[[ States:

			00	Inactive
			01	Dying
			02	Falling into pit
			03	Burning
			04	Initializing
			05	Normal
			06	Stunned
			07	Carried
			08	Thrown
		--]]

		--[[ RAM addresses (E__0)
			20	X position
			21	Y position
			22	?
			23	?
			24	X velocity
			25	Y velocity
			26	?
			27	?
			28	State
			29	?
			2A	?
			2B	??? Cucco hits
			2C	?
			2D	?
			2E	Timer
			2F	?
			30	?
			31	Z position
			32	Z velocity
			33	?
			34	?
			35	?
			36	Health
			37	?
			38	?
			39	?
			3A	Type
			3B	?
		-- Ends here? --
			3C	?
			3D	?
			3E	?
			3F	?
		--]]


		if (npc[i]['state'] ~= 0) then
			boxcolor	= 0xFFFFFFFF;
			if shownpcstate == 1 then
				box(npc[i]['x'] - 8, npc[i]['y'] - 16, npc[i]['x'] + 7, npc[i]['y'] - 1, boxcolor);
				text(npc[i]['x'] + 0, npc[i]['y'] - 16, string.format("%02X", npc[i]['type']), 0x0000FFFF, 0xFFFFFFFF);
				text(npc[i]['x'] - 7, npc[i]['y'] - 16, string.format("%X", i), 0x000000FF, 0xFFFFFFFF);
				text(npc[i]['x'] - 0, npc[i]['y'] -  7, string.format("%2X", npc[i]['state']), 0x008800FF, 0xFFFFFFFF);

				if mode == 0 then
					text(npc[i]['x'] - 7, npc[i]['y'] -  7, string.format("%d", npc[i]['health']), 0xFF0000FF, 0xFFFFFFFF);
				elseif mode == 1 then
					text(npc[i]['x'] - 7, npc[i]['y'] -  7, string.format("%02X", npc[i]['timer']), 0xFF0000FF, 0xFFFFFFFF);
				elseif mode == 2 then
					text(npc[i]['x'] - 7, npc[i]['y'] -  7, string.format("%02X", memory.readbyte(0xE2B0 + i)), 0xFF0000FF, 0xFFFFFFFF);
				end;
			end;
			if (inpt['leftclick'] or inpt['rightclick']) and npc[i]['state'] ~= 0 and hitbox(inpt['xmouse'], inpt['ymouse'], inpt['xmouse'], inpt['ymouse'], npc[i]['x'] - 8, npc[i]['y'] - 16, npc[i]['x'] + 7, npc[i]['y'] - 1) then

				if inpt['leftclick'] then
					memory.writebyte(0xE280 + i, 0x03);
					memory.writebyte(0xE2E0 + i, 0x30);
				elseif inpt['rightclick'] then
					memory.writebyte(0xE280 + i, 0x07);
--					memory.writebyte(0xE320 + i, 0x20);
				end;

			elseif false and (npc[i]['state'] ~= 0 and hitbox(inpt['xmouse'], inpt['ymouse'], inpt['xmouse'], inpt['ymouse'], npc[i]['x'] - 8, npc[i]['y'] - 16, npc[i]['x'] + 7, npc[i]['y'] - 1)) or npc[i]['lockdisp'] > 0 then
				local dispboxx	= inpt['xmouse'] + 5;
				local dispboxy	= inpt['ymouse'] + 5;
				if inpt['xmouse'] > 100 then
					dispboxx	= dispboxx - 60;
				end;
				if inpt['ymouse'] > 100 then
					dispboxy	= dispboxy - 60;
				end;

				if npc[i]['lockdisp'] > 0 then
					dispboxx	= 10;
					dispboxy	= 20;
				end;

				filledbox(dispboxx, dispboxy, dispboxx + 20, dispboxy + 20, 0x00008888);
				local str		= "";
				for addr = 0, 0x1F do
					str			= string.format("%s%02X", str, memory.readbyte(npcbase + addr * 0x10));
					if math.fmod(addr + 1, 8) == 0 then
						text(0, 1, "AA");
						str		= str .. "\n";
					end;
				end;
				
				if inptframe('A') then
					npc[i]['lockdisp']	= 1 - npc[i]['lockdisp'];
				end;
				text(dispboxx, dispboxy, str);
			end;

		else
			freeslots	= freeslots + 1;
		end;
	end;


--	text(0, 0, string.format("FREE %2d %s", freeslots, string.rep("#", freeslots) .. string.rep("-", 16 - freeslots)));








	for i = 0, 2 do
		local d	= math.pow(10, i);
		local h	= math.floor(player['hpcur'] / d);
		if (h == 0) and (player['hpcur'] < d) then
			t	= 0x7F;
		else
			t	= 0xB0 + math.fmod(h, 10);
		end;
		memory.writebyte(0x9C10 - i, t);

	end;
	
	memory.writebyte(0x9C0D, 0x7F);
	memory.writebyte(0x9C11, 0x7F);
	memory.writebyte(0x9C12, 0x7F);
	memory.writebyte(0x9C13, 0xA9);

	for i = 0x9C2D, 0x9C2D + 6 do
		memory.writebyte(i, 0x7F);
	end;

	text     ( 136, 129, string.format("/%3d", player['hpmax']), 0x000000FF, 0x00000000);
	p	= math.floor(player['hpcur'] / player['hpmax'] * 50);
	filledbox( 107, 138, 157, 141, 0xFFC888FF);
	filledbox( 157 - p, 138, 157, 141, 0xAA0000FF);
	box      ( 106, 137, 158, 142, 0x000000FF);






	-- Key counter code
	-- FFF7 = Submap (better)
	-- DB60 = Submap too (?)
	-- DB5F = Mode (?)

	player['submap']		= memory.readbyte(0xFFF7);
	player['mapmode']		= memory.readbyte(0xDB5F);

	if player['mapmode'] == 1 and (player['submap'] <= 0x07 or player['submap'] == 0xFF) then
		if memory.readbyte(0x8C80) == 0xFF then
			drawkeycounter();
		end;

		memory.writebyte(0x9C0A, 0xC8);
		memory.writebyte(0x9C0B, 0xC9);
		memory.writebyte(0x9C0C, 0xB0 + memory.readbyte(0xDBD0));
	end;




	vba.frameadvance();
end;






	bang1	= math.random(0x8000, 0xFFFF)
	bang2	= math.random(0, 0xFF);
	memory.writebyte(bang1, bang2);

	print(string.format("%04X => %02X", bang1, bang2));

