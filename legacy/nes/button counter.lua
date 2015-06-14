
require("x_functions");
x_requires(4);

count	= {0, 0, 0, 0};
buttons	= { {}, {}, {}, {} };
reset	= {false, false, false, false};

while (true) do


	
	for i = 1, 4 do 
		temp		= joypad.read(i);
		for k,v in pairs(temp) do
			if (v ~= buttons[i][k]) and not buttons[i][k] then
				count[i]	= count[i] + 1;
				if k == "select" then
					reset[i]	= true;
				end;
			end;
		end;

		buttons[i]	= joypad.read(i);

		if reset[i] then
			count[i]	= 0;
			reset[i]	= false;
			text(10 + 56 * (i-1), 212, string.format("P%d  Reset!", i));
		end;

		if count[i] > 0 then
			text(10 + 56 * (i-1), 212, string.format("P%d:%6d", i, count[i]));
			lifebar(10 + 56 * (i-1), 220, 50, 1, math.fmod(count[i], 50), 50, "#ffffff", "#000044", false);
			if count[i] >= 50 then 
				lifebar(10 + 56 * (i-1), 223, 50, 0, math.floor(count[i] / 50), 50, "#ffffff", "#000044", false);
			end;
		end;
	end;

	

	FCEU.frameadvance();
end;



