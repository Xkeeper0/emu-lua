
-- Zelda 2 Random Script That Displays Miscellaneous Useless Crap (tm) by 4matsy
-- 2008, September 11th.

require("shapedefs");

local function box(x1,y1,x2,y2,color)
	if (x1 > 0 and x1 < 255 and x2 > 0 and x2 < 255 and y1 > 0 and y1 < 241 and y2 > 0 and y2 < 241) then
		gui.drawbox(x1,y1,x2,y2,color);
	end;
end;
local function text(x,y,str)
	if (x > 0 and x < 255 and y > 0 and y < 240) then
		gui.text(x,y,str);
	end;
end;
local function pixel(x,y,color)
	if (x > 0 and x < 255 and y > 0 and y < 240) then
		gui.drawpixel(x,y,color);
	end;
end;

while (true) do
	
	-- print player's attack, magic, and life
	local lvlatk    = memory.readbyte(0x0777); -- attack stat
	local lvlmag    = memory.readbyte(0x0778); -- magic stat
	local lvllif    = memory.readbyte(0x0779); -- life stat
	local atkdmg    =                 0xe66d ; -- left end of table of damage done by sword
	local magiccons = memory.readbyte(0x0783); -- # of magic containers
	local heartcons = memory.readbyte(0x0784); -- # of heart containers
	local magic     = memory.readbyte(0x0773); -- remaining magic
	local life      = memory.readbyte(0x0774); -- remaining life
	text(1,31,"Sword:\n"..(memory.readbyte((lvlatk-1)+atkdmg)).." dmg");
	if magic == (magiccons*32) then
		text(37,31,(magic+1).."/"..(magiccons*32).." mp\n(full)")
	else
		text(37,31,(magic+1).."/"..(magiccons*32).." mp")
	end;
	if life == (heartcons*32) then
		text(109,31,(life+1).."/"..(heartcons*32).." hp\n(full)");
	else
		text(109,31,(life+1).."/"..(heartcons*32).." hp");
	end;

	-- print points needed for next level-up
	local ptatkbig = 0x9659;                                                -- left end of table of 256's of points needed to level-up attack
	local ptatklil = 0x9671;                                                -- left end of table of   1's of points needed to level-up attack
	local ptmagbig = 0x9661;                                                -- left end of table of 256's of points needed to level-up magic
	local ptmaglil = 0x9679;                                                -- left end of table of   1's of points needed to level-up magic
	local ptlifbig = 0x9669;                                                -- left end of table of 256's of points needed to level-up life
	local ptliflil = 0x9681;                                                -- left end of table of   1's of points needed to level-up life
	local curpts   = (256*memory.readbyte(0x0775))+memory.readbyte(0x0776); -- current points
	if ((memory.readbyte(ptatklil+(lvlatk-1))+(256*memory.readbyte(ptatkbig+(lvlatk-1)))-curpts) >= 0) then
		text(1,1,"Attack L"..(lvlatk+1).."\nin "..(memory.readbyte(ptatklil+(lvlatk-1))+(256*memory.readbyte(ptatkbig+(lvlatk-1)))-curpts))
	else
		text(1,1,"Attack L"..(lvlatk+1).."\n"..math.abs((memory.readbyte(ptatklil+(lvlatk-1))+(256*memory.readbyte(ptatkbig+(lvlatk-1)))-curpts)).." past")
	end;
	if ((memory.readbyte(ptmaglil+(lvlmag-1))+(256*memory.readbyte(ptmagbig+(lvlmag-1)))-curpts) >= 0) then
		text(52,1,"Magic L"..(lvlmag+1).."\nin "..(memory.readbyte(ptmaglil+(lvlmag-1))+(256*memory.readbyte(ptmagbig+(lvlmag-1)))-curpts))
	else
		text(52,1,"Magic L"..(lvlmag+1).."\n"..math.abs((memory.readbyte(ptmaglil+(lvlmag-1))+(256*memory.readbyte(ptmagbig+(lvlmag-1)))-curpts)).." past")
	end;
	if ((memory.readbyte(ptliflil+(lvllif-1))+(256*memory.readbyte(ptlifbig+(lvllif-1)))-curpts) >= 0) then
		text(99,1,"Life L"..(lvllif+1).."\nin "..(memory.readbyte(ptliflil+(lvllif-1))+(256*memory.readbyte(ptlifbig+(lvllif-1)))-curpts))
	else
		text(99,1,"Life L"..(lvllif+1).."\n"..math.abs((memory.readbyte(ptliflil+(lvllif-1))+(256*memory.readbyte(ptlifbig+(lvllif-1)))-curpts)).." past")
	end;

	-- print enemies needed for next item drop
	local lildrop = memory.readbyte(0x05df); -- # of small enemies killed, every 6 drops a blue jar or 50-point bag
	local bigdrop = memory.readbyte(0x05e0); -- # of large enemies killed, every 6 drops a red jar or 200-point bag
	local dropreq = memory.readbyte(0xe8a0); -- # of enemies needed for item drop
	for i=0,(dropreq-2) do
		local meterx    = 223; -- x-origin of the meter
		local metery    =   2; -- y-origin of the meter
		local spacingx  =   6; -- how much x-space between each shape?
		local spacingy  =   0; -- how much y-space between each shape?
		local spacingmx =   0; -- how much x-space between each meter?
		local spacingmy =   9; -- how much y-space between each meter?
		text((meterx-48),(metery-1),"Blue/50:");
		text((meterx-48),(metery+8),"Red/200:");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)-1),(metery+(spacingy*i)+(spacingmy*0)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)-1),(metery+(spacingy*i)+(spacingmy*0)+0),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)-1),(metery+(spacingy*i)+(spacingmy*0)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+0),(metery+(spacingy*i)+(spacingmy*0)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+0),(metery+(spacingy*i)+(spacingmy*0)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+1),(metery+(spacingy*i)+(spacingmy*0)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+1),(metery+(spacingy*i)+(spacingmy*0)+0),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+1),(metery+(spacingy*i)+(spacingmy*0)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*0)+0),(metery+(spacingy*i)+(spacingmy*0)+0),"z2magicjar","#000080");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)-1),(metery+(spacingy*i)+(spacingmy*1)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)-1),(metery+(spacingy*i)+(spacingmy*1)+0),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)-1),(metery+(spacingy*i)+(spacingmy*1)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+0),(metery+(spacingy*i)+(spacingmy*1)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+0),(metery+(spacingy*i)+(spacingmy*1)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+1),(metery+(spacingy*i)+(spacingmy*1)-1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+1),(metery+(spacingy*i)+(spacingmy*1)+0),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+1),(metery+(spacingy*i)+(spacingmy*1)+1),"z2magicjar","#606060");
		drawshape((meterx+(spacingx*i)+(spacingmx*1)+0),(metery+(spacingy*i)+(spacingmy*1)+0),"z2magicjar","#600000");
		for i=0,lildrop-1 do
			drawshape((meterx+(spacingx*i)+(spacingmx*0)+0),(metery+(spacingy*i)+(spacingmy*0)+0),"z2magicjar","#60a0ff");
		end;
		for i=0,bigdrop-1 do
			drawshape((meterx+(spacingx*i)+(spacingmx*1)+0),(metery+(spacingy*i)+(spacingmy*1)+0),"z2magicjar","#ff8080");
		end;
	end;

	-- print enemy life
	local etxbig    = 0x0041; -- right end of table of 256's of active enemies' x-position values
	local etxlil    = 0x0053; -- right end of table of   1's of active enemies' x-position values
	local ety       = 0x002f; -- right end of table of          active enemies' y-position values
	local etmaxhp   = 0x6d21; --  left end of table of                 enemies' max hp values
	local etcurhp   = 0x00c7; -- right end of table of          active enemies' current hp values
	local etid      = 0x00a6; -- right end of table of          active enemies' id's
	local etkickin  = 0x00bb; -- right end of table of          active enemies' alive/dead/floatypoints states
	local scrbig    = 0x072a; -- 256's of screen scroll position
	local scrlil    = 0x00fd; --   1's of screen scroll position
	local barlength =     48; -- how long is the lifebar?
	local barwidth  =      8; -- how wide is the lifebar?
	for i=0,5 do
		ex = ((memory.readbyte(etxlil-i)+(256*memory.readbyte(etxbig-i)))-(memory.readbyte(scrlil)+(256*(memory.readbyte(scrbig)))));
		ey = memory.readbyte(ety-i)-16
		echp = memory.readbyte(etcurhp-i);
		emid = memory.readbyte(etid-i)
		emhp = memory.readbyte(etmaxhp+emid);
		ehits = (math.ceil(echp/memory.readbyte((lvlatk-1)+atkdmg)));
		ealive = memory.readbyte(etkickin-i);
		ox = ex-(math.floor(barlength/2))+8
		oy = ey-7
		if ealive == 1 then
			text(ox-2,oy+barwidth,echp.." hp\n("..ehits.." hits)")
			box(ox,oy+1,ox,oy+barwidth-1,"#ffffff");
			box(ox+barlength+1,oy+1,ox+barlength+1,oy+barwidth-1,"#ffffff");
			for i=1,barlength do
				box(ox+i,oy+0,ox+i,oy+barwidth-0,"#ffffff");
				box(ox+i,oy+1,ox+i,oy+barwidth-1,"#000000");
			end;
			if emhp ~= 0 then
				for i=1,(math.ceil((echp/emhp)*barlength)) do
					box(ox+i,oy+1,ox+i,oy+barwidth-1,"#ff0000");
					box(ox+i,oy+2,ox+i,oy+barwidth-2,"#ff80c0");
				end;
			end;
		end;
		if ealive == 2 then
			text(ex-16,ey+1,"*BROIP!*")
		end;
		if ealive == 3 then
			text(ex-28,ey+1,"YAY POINTS :D")
		end;
	end;

	FCEU.frameadvance();
end;
