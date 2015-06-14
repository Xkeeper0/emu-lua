
-- Use memory.register? false = uses memory.readbyte instead.
blowthegameup	= true;

-- How to destroy a game in Lua without writing anything to RAM, ever
-- I think something in FCEU is a tiny bit busted


function kaboom() 
	testcount	= testcount + 1;
end;

function kaboom2() 
	testcount2	= testcount2 + 1;
end;

function kaboom3() 
	testcount3	= testcount3 + 1;
end;

if blowthegameup then
	memory.register(0x2007, kaboom);	-- DESTROYED
	memory.register(0x4000, kaboom2);	-- DESTROYED
	memory.register(0x2002, kaboom3);	-- DESTROYED
end;

testcount	= 0;
testcount2	= 0;
testcount3	= 0;

while true do

	if blowthegameup then
		gui.text(8, 9, string.format("Calls: %4d, %4d, %4d", testcount, testcount2, testcount3));
		if testcount == 0 and testcount2 == 0 and testcount3 == 0 then
			gui.text(5, 211, "Looks like it crashed.");
			gui.text(5, 220, "memory.register() claims another unfortunate victim.");
		end;

		testcount	= 0;
		testcount2	= 0;
		testcount3	= 0;
	
	else
		void		= memory.readbyte(0x2007);
		void		= memory.readbyte(0x4000);
		void		= memory.readbyte(0x2002);

	end;
	FCEU.frameadvance();

end;