

local lastupdate	= -1
local objlist		= {}
local objcount		= 0
function runobjecthook(addr)
	if emu.framecount() ~= lastupdate then
		lastupdate	= emu.framecount()
		objlist		= {}
		objcount	= 0
	end

	objcount		= objcount + 1
	if addr == 0x85D8 then
		-- JSR     RunObjectCode
		objlist[objcount]	= {
			otype			= cpuregisters.a,
			oindex			= mem.byte[0x094],
			osprite			= mem.byte[0x095],
			ostun			= false,
		}

	elseif addr == 0x85FA then
		-- SkipStunnedObject
		objlist[objcount]	= {
			otype			= mem.byte[0x000],
			oindex			= mem.byte[0x094],
			osprite			= mem.byte[0x095],
			ostun			= true,
		}
	else
		print("??????????" .. hexs(addr))
	end

end
memory.registerexec(0x85D8, runobjecthook)
memory.registerexec(0x85FA, runobjecthook)


local objtable	= { 
	0x070,
	0x200,
	0x240,
	0x280,
	0x300,
	0x3C0,
	0x3E0,
	0x400,
	0x460,
	0x4C0,
	0x4E0,
	0x500,
	0x540,	-- item drop (1:5ludder 2:1ludder 3:heart)
	0x580,
}
local objtablec	= #objtable

function showobjectlist()
	local xp = 0
	local yp = 60
	local obj		= nil
	local ocolor	= nil
	for i = 0, objcount - 1 do
		obj		= objlist[i + 1]
		local letter	= letterindex(i)

		local odead		= mem.byte[0x3C0 + obj.oindex]
		local ostun		= obj.ostun
		local o380		= mem.byte[0x380 + obj.oindex]		-- inactive?
		if ostun then
			ocolor		= "orange"
		elseif odead == 1 and o380 == 1 then
			ocolor		= "#ff80ff"
		elseif odead == 1 then
			ocolor		= "#00ffff"
		elseif o380 == 1 then
			ocolor		= "yellow"
		else
			ocolor		= "white"
		end
		gui.text(xp     , yp + 8 * i, letter, "white", "black")
		gui.text(xp +  9, yp + 8 * i, "  ", "clear", "#00000080")
		textshadow(xp +  9, yp + 8 * i, string.format("%02X", obj.otype), ocolor)
			--[[
		gui.text(xp +  9, yp + 8 * i, 
			string.format("%02X [x%02X,y%02X] %02X %02X",
			obj.otype,
			obj.oindex,
			obj.osprite,
			odead,
			o380
		), ocolor, "#00000080")
		--]]
		for b = 1, objtablec do
			local addr		= hexs(objtable[b], 3)
			local splits	= "$".. string.sub(addr, 1, 1) .."\n ".. string.sub(addr, 2, 2) .."\n ".. string.sub(addr, 3, 3)
			gui.text(xp + 20 + 13 * b, yp - 24, splits, b % 2 == 0 and "P20" or "P24", "#00000080")
		end
		for b = 1, objtablec do
			gui.text(xp + 20 + 13 * b, yp + 8 * i, hexs(mem.byte[objtable[b] + obj.oindex]), mem.byte[objtable[b] + obj.oindex] == 0x00 and "gray" or (b % 2 == 0 and "white" or "cyan"), "#00000080")
		end
	end
end
