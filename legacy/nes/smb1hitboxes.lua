-- super mario bros 1 hitbox script  
-- by qfox  
  
local function box(x1,y1,x2,y2,color)  
    -- gui.text(50,50,x1..","..y1.." "..x2..","..y2);  
    if (x1 > 0 and x1 < 255 and x2 > 0 and x2 < 255 and y1 > 0 and y1 < 224 and y2 > 0 and y2 < 224) then  
        gui.drawbox(x1,y1,x2,y2,color);  
    end;  
end;  
  
  
while true do  
    -- draw the guides  
	-- horizontal  
	--[[
	local guideheight = 30;  
	gui.drawline(0,guideheight,250,guideheight,"red");  
	local start = memory.readbyte(0x071C); -- this is the forward position at the edge. the screen is 255 positions wide  
	-- draw two pixels every 10 positions, start at a 10  
	-- you know your position (x), subtract 125, start there  
	for i=1,250 do  
		if (math.mod(start+i, 5) == 0) then  
--			gui.drawpixel(i, guideheight-1, "red");  
--			gui.drawpixel(i, guideheight-2, "red");  
			if (math.mod(start+i, 10) == 0) then  
--				gui.drawpixel(i, guideheight-3, "red");  
--				gui.drawpixel(i, guideheight-4, "red");  
			end;  
		end;  
	end;  
	gui.text(113, guideheight-15, string.format("%02X", memory.readbyte(0x0086)));
	gui.text(0,guideheight-15, string.format("%02X", start));  
	gui.text(230,guideheight-15, string.format("%02X", start));  
]]--

  
    -- an accurate enemy hitbox can be found starting at 0x04A0, 4 bytes for each object, x1,y1 x2,y2, and these positions are far more accurate compared to above, so..  
    local foreal = 0x04AC;  
    local blitted = 0x000E;  
    for i=0,15 do  
        if (memory.readbyte(blitted+i) ~= 0 and memory.readbyte(foreal+(i*4)) ~= 0xFF) then  
--        if (memory.readbyte(foreal+(i*4)) ~= 0xFF) then  
            local x1 = memory.readbyte(foreal+(i*4));  
            local y1 = memory.readbyte(foreal+(i*4)+1);  
            local x2 = memory.readbyte(foreal+(i*4)+2);  
            local y2 = memory.readbyte(foreal+(i*4)+3);  
            --gui.text(150,32+(i*15), x1..","..y1.." - "..x2..","..y2);  
            box(x1,y1,x2,y2,"green");  
			gui.text(x1, y1, memory.readbyte(blitted+i));
		end;  
    end;  
  
--    gui.text(5,32,"Green rectangles are hitboxes!\nBlue rectangle is solid collision box!");  

	-- draw the collision box for the player and for static objects. this is not the enemy collision hitbox!  
	-- this shows you when mario collides with the floor, a wall, a solid block, or whatever else solid.  
	local mariostate = memory.readbyte(0x0499); -- 00 = large standing, 01 = small, 02 = large ducking  
    -- ok, the height of small mario is three pixels lower then the height of ducking large mario  
    -- the difference between the y position of the large mario and the top bound is equal to it's y when ducking; 13 pixels. small mario has a 10 pixel upper bound.  
    upperbound = 3;  
    if (mariostate == 1) then upperbound = 0; end; -- small mario is really smaller then the ducking large mario  
    lowerbound = 13;  
    if (mariostate == 0) then lowerbound = 25; end; -- large mario has more distance between the lower bound and it's y  

	-- The "solid collision box" makes absolutely no fucking sense. Ignore it.
    box(memory.readbyte(0x04AC), memory.readbyte(0x04AD)-upperbound, memory.readbyte(0x04AE), memory.readbyte(0x04AD)+lowerbound, "blue");  
  
    FCEU.frameadvance()  
end 