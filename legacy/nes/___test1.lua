


-- Basic init
socket		= require("socket.core");	-- Load LuaSocket core
sockets		= {};						-- container table for sockets
										-- It would probably make more sense to put some of these
										-- into the netplay namespace, but derp



-- Takes a number and turns it into a 4-byte binary value
-- Note that any values over this number are truncated
function string.toraw(num)
	return string.char(	AND(math.floor(num / 0x1000000), 0xFF), 
						AND(math.floor(num / 0x0010000), 0xFF), 
						AND(math.floor(num / 0x0000100), 0xFF), 
						AND(num                        , 0xFF));
end;

-- Takes a binary string (MSB first) and returns it to an int
-- Lua doesn't seem to have something to do this automatically
-- It takes any length, though it's not necessarily gaurenteed to work
function string.fromraw(num)
	out		= 0
	for i = 1, string.len(num) do
		out	= (out * 0x100) + string.byte(num, i);
	end;
	
	return out;
end;



function start(ip, port)

	-- todo: make the configuration configurable
	-- one way or another
	sockets['game']		= socket.udp();
	bindname			= "*"
	bindport			= port

	peername			= ip;
	peerport			= port

	sockets['game']:setsockname(bindname, bindport)
	sockets['game']:setpeername(peername, peerport);
	sockets['game']:settimeout(0);

	-- Should probably be moved to a dedicated wait loop somewhere
	-- SO that we can keep sending it every second or so until we get a reply

	return true; -- why not
end;


function dread()

	repeat
		-- read value / error
		rd, er	= sockets['game']:receive();
		if rd then
			drecv(rd);

		else
			--print(er);
		end;
--	until not rd 
	until true 
	
end;



function drecv(data)
	paddr	= string.fromraw(string.sub(data, 1, 4));
	pval	= string.fromraw(string.sub(data, 5, 8));
	gui.text(8, 8, string.format("%04X => %02X\n", paddr, pval));

	memory.writebyte(paddr, pval);
end;



function dsend(data)

	dataout	= data -- string.toraw(0x0123) .. string.toraw(0x45);


	if dataout then
		sockets['game']:send(dataout);
		return true;
	else
		return false;
	end;
end;




    -- Compatibility: Lua-5.1
    function split(str, pat)
       local t = {}  -- NOTE: use {n = 0} in Lua-5.0
       local fpat = "(.-)" .. pat
       local last_end = 1
       local s, e, cap = str:find(fpat, 1)
       while s do
          if s ~= 1 or cap ~= "" then
    	 table.insert(t,cap)
          end
          last_end = e+1
          s, e, cap = str:find(fpat, last_end)
       end
       if last_end <= #str then
          cap = str:sub(last_end)
          table.insert(t, cap)
       end
       return t
    end
