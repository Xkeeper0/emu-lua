
function centertext(len, text)

	return (len - (string.len(text))) * 2;

end;




function magicz() 

	local a	= 0;
	local b	= 0;
	local c	= 0;
	local x = memory.readword(0xCD0F);
	local y	= memory.readword(0xCD44);
	local z	= memory.readword(0xCD42);
	local t	= 0;
	
	if (x ~= 0) then
		t	= x - y;
		if (t < 0) then
			c	= c + 1;
		end;
		
		t	= t + y - z;
		if (t < 0) then
			b	= b + 1;
		end;

		a	= (4 * c) + b;
		
		if (a <= 0) then
			--a	= 1;
		end;
		
	end;
	
	return a;

end;



function memwa(name, addr)

	gui.text(0, 16 + 8 * memrow, string.format("%5d %s", memory.readword(addr), name));

	memrow	= memrow + 1;
	
end;



function drawgobar(ypos, num)
	for i = 0, 6 do
		gui.line(96 + i,ypos + i,114,ypos + i,"red");
	end;
	gui.line(96, ypos-1, 115, ypos-1, "black");
	gui.line(95, ypos, 102, ypos+7, "black");
	gui.line(102, ypos+7, 115, ypos+7, "black");
	gui.line(115, ypos, 115, ypos+7, "black");
	
	gui.text(103 + centertext(3, num),ypos, num, "white", "red");
end;

function gameoverbra()

	local ymax	= 160;
	
	--gui.text(95, 0, string.format("%3d/%3d", dtime, mtime));
	
	if dtime == 0 then
		if lastgobary < 160 then
			lastgobartimer	= lastgobartimer + .1;
			lastgobary		= lastgobary + lastgobartimer;
			drawgobar(lastgobary, "");
		end;
		return;
	end;
	
	lastgobartimer	= -1;
	ypos	= ymax - (dtime / mtime) * ymax;
	lastgobary	= ypos;
	drawgobar(ypos, mtime - dtime);
	
end;


function stoptimer()
	local stoptime	= memory.readword(0xC87C);
	
	if stoptime == 0 and dtime == 0 then
		return;
	end;
	

	local sy	= 7;
	local sx	= 99;
	
	if lastgobary < 42 then
		sx	= sx + math.min(18, (42 - lastgobary));
	end;
	
	
	local cycle1	= "#808080e0";
	local cycle2	= "#404040d0";
	if dtime > 0 then
		cycle1	= "#ff0000e0";
		cycle2	= "#880000c0";
	end;


	local cycletime	= 64;
	
	if stoptime < 20 then
		cycletime	= 4;
	elseif stoptime < 60 then
		cycletime	= 8;
	elseif stoptime < 120 then
		cycletime	= 16;
	elseif stoptime < 240 then
		cycletime	= 32;
	end;
	
	local bgcolor	= cycle2;
	if math.fmod(timer, cycletime) < (cycletime / 2) then
		bgcolor	= cycle1;
	end;
	
	gui.box(sx, sy, sx + 20, sy + 15, bgcolor, "black");
	gui.text(sx + 3, sy + 1, "STOP", "white", "clear");
	gui.text(sx + 3 + centertext(4, stoptime), sy + 8, stoptime, "white", "clear");
	
end;




function adddamage() 
	
	local d	=  memory.readword(0xCD21);
	if d ~= 0 then
		totaldamage	= totaldamage + d;
		local tx	= centertext(4, d);
		print(tx);
		local yp	= math.fmod(damagetog, 2) * 8 + 90;
		damagetog	= damagetog + 1;
		
		table.insert(damages, { value=d, dtimer=0, xpos = tx, ypos=yp, yspd = -3 });
	end;


end;


function showdamage()
	removeid	= nil;
	for k,v in ipairs(damages) do

		if v['dtimer'] > 90 then
			removeid	= k;
		else

			v['ypos']	= math.max(0, v['ypos'] + v['yspd']);
			v['yspd']	= v['yspd'] * 0.95 + 0.01;
		
			local tcolor	= "black";
			if v['dtimer'] > 30 or math.fmod(v['dtimer'], 6) < 2 then
				tcolor		= "white";
			end;
		
			gui.box(118, v['ypos'] - 1, 136, v['ypos'] + 7, "#f00000c0", "black");
			gui.text(120 + v['xpos'], v['ypos'], v['value'], tcolor, "clear");
		
			v['dtimer']	= v['dtimer'] + 1;
			
		end;
	end;
	
	if removeid	then
		table.remove(damages, removeid);
	end;
end;
	



function showhp()
	local hp	= memory.readword(0xCD0B);
	local maxhp	= memory.readword(0xCD0D);
	

	gui.box(112, 64, 144, 79, "#000000E0", "#000000");
	gui.text(113, 65, string.format("%5d", hp), "white", "clear");
	gui.text(120, 72, string.format("/%5d", maxhp), "#8888bb", "clear");
end;








memory.register(0xCD22, adddamage);

timer			= 0;

lastgobary		= 999;
lastgobartimer	= -2;

lastdamage	= 0;
totaldamage	= 0;

damagetog	= 0;

damages		= {};

--		table.insert(damages, { value="####", dtimer=0, ypos=101, yspd = -3 });


local hp	= 0;
local maxhp	= 0;

local inpt	= {};

memrow	= 0;

local guitimeout = 0;

while true do
	timer	= timer + 1;
	ingame	= memory.readbyte(0xFFA3) == 0x01;
	
	dtime	= memory.readbyte(0xC8A6);
	mtime	= memory.readbyte(0xCA24);
	
	
	if ingame then
		guitimeout	= 0;
		gui.opacity(1);
	else
		gui.opacity(math.max(0, 1 - ((guitimeout - 120) / 30)));
		guitimeout	= guitimeout + 1;
		--print (1 - ((guitimeout - 120) / 60));
	end;

	--[[
	memory.writebyte(0xC8A6, 0);
	memory.writeword(0xCD0D, 9999);
	if math.fmod(timer, 1) == 0 then
		memory.writeword(0xCD0B, math.min(9999, memory.readword(0xCD0B) + 5));
	end;
	--]]
	--	local hp	= memory.readword(0xCD0B);
	--local maxhp	= memory.readword(0xCD0D);

	
	if memory.readbyte(0xCEA1) == 0x5 then
		showhp();
		showdamage();
	end;
	gameoverbra();
	stoptimer();
	

	gui.text(108, 137, string.format("Total: %6d", totaldamage), "#ffaaaa");
	
	--[[
	
	--hp		= memory.readword(0xCD46);
	--maxhp	= memory.readword(0xC7B6);
	
	hp		= memory.readword(0xCD0B);
	maxhp	= memory.readword(0xCD0D);
	damage	= memory.readword(0xCD21);
	
	--maxhp			= memory.readword(0xCD44);
	--m1		= memory.readword(0xCD44);
	--m2		= memory.readword(0xCD42);
	--m2		= memory.readword(0xCD48);
	
	--memwa("C8A6 D", 0xC8A6);
	--memwa("CA24 M", 0xCA24);
	--memwa("a", 0xC96D);
	--memwa("a", 0xCD0B);
	--memwa("a", 0xCD0F);
	--memwa("HP5", 0xCD0E);
	--memwa("CD0C", 0xCD0B);
	
	inpt	= input.get();
	
	if inpt['A'] then
		memory.writeword(0xCD44, m1 + 1);
	end;
	if inpt['S'] then
		memory.writeword(0xCD42, memory.readword(0xCD42) - 1);
	end;
	if inpt['W'] then
		memory.writeword(0xCD42, memory.readword(0xCD42) + 1);
	end;
	
	
	gui.text(0, 0, string.format("%4d/%4d", hp, maxhp));
	gui.text(0, 8, string.format("%4d", lastdamage));
	--gui.text(0, 8, string.format("%4d %4d", m1, m2));

	--gui.text(80, 0, string.format("%8d", memory.readdwordsigned(0xCD0E)));
	
	
	gui.text(0,100, magicz());
	
	memrow	= 0;
	
	--]]
	emu.frameadvance();
	
end;
	
	