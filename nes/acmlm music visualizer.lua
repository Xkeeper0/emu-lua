
require("x_functions");

function pointer(addr)

	point	= memory.readbyte(addr) + memory.readbyte(addr + 1) * 0x0100;
	return point;

end;

function colorpick(v, ch1, ch2, ch3)

	if not ch1 or not ch2 or not ch3 then
		return "#880000";
	end;

	coloron		= {};
	coloron[ 1]	= "#ff0000";	-- square 1
	coloron[ 2]	= "#00ff00";	-- square 2
	coloron[ 4]	= "#0000ff";	-- tri
	coloron[ 3]	= "#dddd44";	-- 1 + 2
	coloron[ 5]	= "#ff00ff";	-- 1 + t
	coloron[ 6]	= "#00ffff";	-- 2 + t
	coloron[ 7]	= "#ffffff";	-- 1 + 2 + t

--	text(0, 0, cv);

	cv	= 0;

	if ch1 == v then
		cv	= cv + 1;
	end;
	if ch2 == v then
		cv	= cv + 2;
	end;
	if ch3 == v then
		cv	= cv + 4;
	end;

	return coloron[cv];
end;

function dographing()

	for c = 0, 2 do
		for i = 0, 250 do
			if (i > 0) and graph[c][i] then
				graph[c][i - 1]	= graph[c][i]; -- + math.random(-0, 30) / 100 + math.sin(i / 10) / 6;
			end;
			
			if graph[c][i] then
				color	= colorpick(graph[c][i], graph[0][i], graph[1][i], graph[2][i]);
				if graph[c][i] > 0 then
					pixel(i, graph[c][i], color);
				elseif graph[c][i] < 0 then
					pixel(i, graph[c][i] * -1, "#888888");
				end;
			end;
			if i == 250 then
				if graph[c][i] then
					if graph[c][i] > 0 then
						box(250, graph[c][i] - 1, 254, graph[c][i] + 1, "#ffffff");
						line(250, graph[c][i], 254, graph[c][i], color);
					elseif graph[c][i] < 0 then
						box(250, graph[c][i] * -1 - 1, 254, graph[c][i] * -1 + 1, "#ffffff");
						line(250, graph[c][i] * -1, 254, graph[c][i] * -1, "#888888");
					end;
				end;
			end;
		end;
	end;
end;


channels	= {};
channels[0]	= {};
channels[1]	= {};
channels[2]	= {};
channels[3]	= {};
oldval		= {};
oldval[0]	= {};
oldval[1]	= {};
oldval[2]	= {};
oldval[3]	= {};
graph		= {};
graph[0]	= {};
graph[1]	= {};
graph[2]	= {};
graph[3]	= {};


while (true) do

	ohno					= 0;
	maxohno					= 0;
	for i = 0, 3 do
	
		offset					= 0x0600 + 0x0020 * i;
		channels[i]["pitch"]	= 0x7FF - (memory.readbyte(offset + 0x06) * 0xFF + memory.readbyte(offset + 0x05));
--		channels[i]["volume"]	= memory.readbyte(offset + 0x09);
--		channels[i]["volume"]	= memory.readbyte(offset + 0x0b);

--		MAX(AND(pointer(8500 + 060A * 2) + 0609), F) - 060B, 0) then

		point					= pointer(0x84FB + memory.readbyte(offset + 0x0a) * 2);
		yetanotherfuckingtempval	= memory.readbyte(point + memory.readbyte(offset + 0x09));
		ohno					= 0;
		while (yetanotherfuckingtempval < 0x30 and ohno < 0xFF) do
			point						= point - 1;
			yetanotherfuckingtempval	= memory.readbyte(point + memory.readbyte(offset + 0x09));
			ohno						= ohno + 1;
		end;
		channels[i]["volume"]	= math.max(AND(yetanotherfuckingtempval, 0xF) - memory.readbyte(offset + 0x0b), 0);
		maxohno					= maxohno + ohno;
		
		channels[i]["adjust"]	= 132 - (12 * math.log(0x7FF - channels[i]["pitch"]) / math.log(2));
		channels[i]["name"]		= string.sub("C C#D D#E F F#G G#A A#B ", (2 * math.floor(math.fmod(channels[i]["adjust"], 12)) + 1), (2 * math.floor(math.fmod(channels[i]["adjust"], 12)) + 2));
		channels[i]["temp"]		= (2 * math.fmod(channels[i]["adjust"], 12) + 1);
--		W,B,W,B,W, W,B,W,B,W,B,W

	end;

	yspacing	= 16;

	for i = 0, 3 do
	
		if oldval[i]["pitch"] == nil then
			oldval[i]["pitch"]	= 0;
			oldval[i]["adjust"]	= 0;
		end;

		if channels[i]["pitch"] ~= 0x7FF then 
--			text( 76 + math.floor(channels[i]["adjust"] / 132 * 160), 9 + yspacing * i, channels[i]["name"]);
--			lifebar( 80, 18 + yspacing * i, 160, 4, channels[i]["adjust"] ,    132, "#ffffff", "#000044", "#000011", "#ffffff");
--			lifebar( 80, yspacing + yspacing * i, 160, 0, channels[i]["pitch"]  , 0x07FF, "#ffffff", "#000044", "#888888", "#bbbbff");
			oldval[i]["pitch"]	= channels[i]["pitch"];
			oldval[i]["adjust"]	= channels[i]["adjust"];
			graph[i][250]	= 240 - math.floor(channels[i]["adjust"] / 132 * 480);
		else
			graph[i][250]	= 240 - -1 * math.floor(oldval[i]["adjust"] / 132 * 480);
--			lifebar( 80, 18 + yspacing * i, 160, 4, oldval[i]["adjust"]   ,    132, "#888888", "#000044", "#000011", "#ffffff");
--			lifebar( 80, yspacing + yspacing * i, 160, 0, oldval[i]["pitch"]    , 0x07FF, "#888888", "#000044", "#888888", "#bbbbff");
		end;



		if (i < 2 and false) then
			lifebar( 80, 24 + yspacing * i, 160, 0, channels[i]["volume"] , 0x000F, "#ffffff", "#000044", false, "#ffffff");
--			text( 80, 29 + yspacing * i, channels[i]["volume"]);
		end;
	--	lifebar( 95, 108 + 8 * i, 29, 1, channels[i]["volume"] , 0x000F, "#ffffff", "#000044", "#888888", "#000000");



--		val2	= math.log10((0x7FF - channels[i]["pitch"]) / 0x7FF) * -0x1000;
--		text(60, 20 + 32 * i, string.format("%0d", val2));
--		lifebar( 80, 34 + 32 * i, 160, 0, channels[i]["pitch"]  , 0x07FF, "#ffffff", "#000044");



--		text( 80, 110, string.format("Backskips to find data: %d", maxohno));
--		lifebar( 80, 100, 127, 5, maxohno, 0x00FF, "#dd0000", "#000000", "#888888", "#ffffff");
--		lifebar( 80, 100, 160, 2, ohno , 0x00FF, "#ffffff", "#000044");

	end;




--[[
	if memory.readbyte(0x0605) ~= 0x00 then
		lifebar( 80, 20 + 32 * 0, 160, 4, 0xFF - memory.readbyte(0x0605), 0xFF, "#ffffff", "#000044");
		lifebar( 80, 28 + 32 * 0, 160, 2,        memory.readbyte(0x0609), 0x20, "#ffffff", "#000044");
	end;

	if memory.readbyte(0x0625) ~= 0x00 then
		lifebar( 80, 20 + 32 * 1, 160, 4, 0xFF - memory.readbyte(0x0625), 0xFF, "#ffffff", "#000044");
		lifebar( 80, 28 + 32 * 1, 160, 2,        memory.readbyte(0x0629), 0x20, "#ffffff", "#000044");
	end;

	if memory.readbyte(0x0645) ~= 0x00 then
		lifebar( 80, 20 + 32 * 2, 160, 4, 0xFF - memory.readbyte(0x0645), 0xFF, "#ffffff", "#000044");
	end;
]]--


	dographing();






	FCEU.frameadvance();

end;