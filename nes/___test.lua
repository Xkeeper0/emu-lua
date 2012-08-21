require "___test1";

start("67.5.122.29", 7845);


--[[
arg	= split(arg, " ");

if arg[1] and arg[2] then
	
	v1	= tonumber(arg[1])
	v2	= tonumber(arg[2])

	print(string.format("%04X => %02X", v1, v2));
	dsend(
		string.toraw(v1) .. 
		string.toraw(v2)
			
		);
		
		
end

--]]

while true do
	
	inpt	= input.get();
	if inpt['A'] then
		v1	= math.random(0x0000, 0x07FF);
		v2	= math.random(0x00, 0xFF);
		
		print(string.format("%04X => %02X", v1, v2));
		dsend(
			string.toraw(v1) .. 
			string.toraw(v2)
			
			);
	end;

	dread();
	emu.frameadvance();
end