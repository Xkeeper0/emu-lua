inputprev	= {
	A		= false,
	B		= false,
	select	= false,
	start	= false,
	up		= false,
	down	= false,
	left	= false,
	right	= false,
	}


function force(i)
	out	= {};
	for k,v in pairs(i) do
		if v == nil then
			v = false;
		end;
		out[k]	= v;
	end;

	return out;
end;

--[[
function durr()
	temp	= force(joypad.get(1));

	z	= 0;
	for k,v in pairs(temp) do
		gui.text(8, z * 8 + 8, string.format("%s > %s", k, tostring(v)));
		z = z + 1;
	end;


	joypad.set(1, inputprev);
--	inputprev	= temp;
end;



emu.registerafter(durr);
--]]
while true do

	temp	= force(joypad.get(1));

	z	= 0;
	for k,v in pairs(temp) do
		gui.text(8, z * 8 + 8, string.format("%s > %s", k, tostring(v)));
		z = z + 1;
	end;


	joypad.set(1, inputprev);
	inputprev	= temp;
	
	
	
	emu.frameadvance();
end;