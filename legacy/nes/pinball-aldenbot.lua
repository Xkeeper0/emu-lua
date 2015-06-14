-- 0x7 is x of ball, 0x9 is y, 0x125 is amount launcher is pulled back 

while (true) do 


    --check if it needs to be launched 
    if memory.readbyte(0x7)==225 and memory.readbyte(0x9)==154 and memory.readbyte(0x125)~=4 then 
        joypad.set(1,{B=true}) 
    end 
   --check right flipper 
   if memory.readbyte(0x7) > 145 and memory.readbyte(0x7) < 175 and memory.readbyte(0x9) > 189 and memory.readbyte(0x9) < 226 then 
         joypad.set(1,{A=true}) 
    end 
    --check left flipper 
    if memory.readbyte(0x7) > 110 and memory.readbyte(0x7) < 138 and memory.readbyte(0x9) > 189 and memory.readbyte(0x9) < 226 then 
         joypad.set(1,{up=true}) 
    end 

	timer	= memory.readbyte(0x01f7);
	if timer == 0x78 then
		FCEU.pause();
	end;

	FCEU.frameadvance();
end