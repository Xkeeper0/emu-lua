-- password

local idef1	= 1
local idef2	= 5
local idef3	= 9
local iatk1	= 0x0D
local iatk3	= 0x15
local currentstate	= {}
local pwletters = ".ABCDEFGHIJKLMNOPQRSTUVWXYZ12345"
local pwletter	= {}
for i = 0, 0x1F do
	pwletter[i]	= string.sub(pwletters, i + 1, i + 1)
end

function readpwmem()
	local ret	= {}
	for i = 0, 0x09 do
		ret[i]	= mem.byte[0x100 + i]
	end
	return ret
end
local lastpw = nil
function writepwmem(pw, cpos)
	lastpw	= {}
	for i = 0, 9 do
		mem.byte[0x100 + i]	= pw[i]
		lastpw[i]	= pw[i]
	end

	if not cpos then
		for i = 9, 0, -1 do
			ppu.readbyte(0x210B)
		end
	end
	if cpos then mem.byte[0x00F] = cpos end
	local cursorpos	= mem.byte[0x00F]
	mem.byte[0x00D]	= math.floor(pw[cursorpos] / 8)
	mem.byte[0x00C]	= pw[cursorpos] % 8
end

function writepwtext(addr)
	if getcurrentbank() ~= 0 then return end
	if not lastpw then return end
	-- debugger.hitbreakpoint()
	mem.byte[0x2006]	= 0x21	-- high byte of PPU addr
	mem.byte[0x2006]	= 0x0B	-- low byte of PPU addr
	for i = 0, 9 do
		local w = lastpw[i]
		mem.byte[0x2007]	= mem.byte[0xA091 + lastpw[i]]
	end
	-- cpuregisters.a		= mem.byte[0x06]
	-- cpuregisters.pc		= 0xA038 -- 0xA03B
	-- debugger.hitbreakpoint()
end
memory.registerexec(0xA017, writepwtext)



memory.registerexec(0xA6E0, function ()
	if getcurrentbank() ~= 0 then return end
	print(string.format("Password rejected. Computed: %02X, compare: %02X", mem.byte[0x10D], mem.byte[0x10E]))
end)
memory.registerexec(0xA6E6, function ()
	if getcurrentbank() ~= 0 then return end
	print(string.format("Password accepted. Computed: %02X, compare: %02X", mem.byte[0x10D], mem.byte[0x10E]))
end)







function decodepassword(pw)
	local state		= {}
	local check		= OR(pw[8], (math.floor(pw[9] * 0x20)%0x100))
	local pwbytes	= {}
	local pwc		= {}
	for i = 0, 9 do
		pwc[i]		= pw[i]
		pwbytes[i]	= 0
	end
	
	-- decode text characters (5 bits) to bytes
	for bit = 0, 4 do
		for char = 0, 7 do
			local thisbit	= pwc[char] % 2
			pwc[char]		= math.floor(pwc[char] / 2)
			pwbytes[bit]	= math.floor(pwbytes[bit] / 2) + thisbit * 0x80
		end
	end

	-- take last byte and add 0xAA
	local sub	= (pwbytes[4] + 0xAA) % 0x100
	local out	= {}
	for i = 0, 3 do
		out[i]	= (0x100 + pwbytes[i] + 1 - sub) % 0x100
		-- out[i]	= pwbytes[i]
	end
	out[4]		= sub
	-- out[4]		= pwbytes[4]	-- sub
	local sum	= 0
	for i = 0, 4 do
		sum		= (sum + out[i]) -- % 0x100
	end

	out['pwsum']	= sum
	out['check']	= check
	out['valid']	= (sum % 0x100) == check
	out['pass']		= (out[2] <= (300 - 256)) or AND(out[1], 0x60) == 0

	-- for i = 0, 4 do
	-- 	gui.text(214, 20 + i * 8, hexs(out[i]))
	-- end

	return out

end

function decodestate(decodedpw)
	-- first byte: bells bitflag
	local bellsbitflag	= decodedpw[0]
	local playerHP		= decodedpw[2]
	local bellsburnt	= AND(decodedpw[1], 0x07)
	local magickey		= AND(decodedpw[1], 0x08) == 0x08
	local hyperboots	= AND(decodedpw[1], 0x10) == 0x10
	playerHP	= playerHP + (math.floor(AND(decodedpw[1], 0x60) / 0x20) * 0x100)

	local def1			= idef1 + AND(math.floor(decodedpw[3] / (2^0)), 0x03)
	local def2			= idef2 + AND(math.floor(decodedpw[3] / (2^2)), 0x03)
	local def3			= idef3 + AND(math.floor(decodedpw[3] / (2^4)), 0x03)
	local atk1			= iatk1 + AND(math.floor(decodedpw[3] / (2^6)), 0x03)

	local double		= AND((decodedpw[4]), 1) == 1
	local parallel		= AND((decodedpw[4]), 2) == 2
	
	local glove			= AND(math.floor(decodedpw[4] / 4), 0x03)
	local atk2			= AND(decodedpw[4], 0x03)
	local rng			= math.floor(decodedpw[4] / 0x10)
	if atk2 ~= 0 then atk2 = atk2 + 0x18 end	-- doubleshot-1
	if glove ~= 0 then glove = glove + 0x15 end	-- glove-1

	return {
		hp				= playerHP,
		bellsbitflag	= bellsbitflag,
		bellsburnt		= bellsburnt,
		magickey		= magickey,
		hyperboots		= hyperboots,

		def1			= def1,
		def2			= def2,
		def3			= def3,
		atk1			= atk1,
		atk2			= atk2,
		atk3			= glove,
		double			= double,
		parallel		= parallel,
		random			= rng,
	}

end


function encodestate(state)
	local pwbytes	= {}
	for i = 0, 4 do
		pwbytes[i]	= 0
	end

	-- simple enough: bell bitflag go into byte.
	pwbytes[0]		= state.bellsbitflag

	-- second byte: .MMH KBBB
	-- MM: max HP (yep, two bits!)
	-- H: hyper boots
	-- K: magic key
	-- BBB: burnt bell count
	pwbytes[1]		= OR(pwbytes[1], AND(state.bellsburnt, 0x07))
	pwbytes[1]		= OR(pwbytes[1], state.magickey and 0x08 or 0)
	pwbytes[1]		= OR(pwbytes[1], state.hyperboots and 0x10 or 0)
	pwbytes[1]		= OR(pwbytes[1], AND(math.floor(state.hp / 0x100), 0x03) * 0x20)
	-- pwbytes[1]		= OR(pwbytes[1], AND(math.random(2, 2), 0x03) * 0x20)
	
	-- third byte: low byte of hp
	pwbytes[2]		= state.hp % 0x100

	-- fourth byte: equipment. WWAASSHH
	-- WW: weapon  AA: armor  SS: shield  HH: helmet
	pwbytes[3]		= OR(pwbytes[3], (state.def1 - idef1) * 0x01)
	pwbytes[3]		= OR(pwbytes[3], (state.def2 - idef2) * 0x04)
	pwbytes[3]		= OR(pwbytes[3], (state.def3 - idef3) * 0x10)
	pwbytes[3]		= OR(pwbytes[3], (state.atk1 - iatk1) * 0x40)

	-- fifth byte: items, randomness
	-- RRRR GGPP
	-- PP:  0 no powerup,  1 double,  2 parallel
	-- GG:  0 no glove, 1-3 glove power
	-- RRRR: RNG (frame timer & 0xF0)
	pwbytes[4]		= OR(pwbytes[4], OR(state.double and 1 or 0, state.parallel and 2 or 0))
	pwbytes[4]		= OR(pwbytes[4], AND((state.atk3 ~= 0 and (state.atk3 - iatk3) or 0), 3) * 0x04)
	pwbytes[4]		= OR(pwbytes[4], state.random * 0x10)

	return pwbytes
end

function encodepassword(pwbytes)
	local checksum	= 0
	
	local pwcopy	= {}
	local pwtemp	= {}
	local pwout		= {}

	-- simple checksum of first five bytes
	for i = 0, 4 do
		checksum	= (checksum + pwbytes[i]) % 0x100
		pwcopy[i]	= pwbytes[i]
		pwtemp[i]	= 0
	end

	-- scomble numbers
	for i = 0, 3 do
		pwtemp[i]	= (0x100 + (pwcopy[i] + pwcopy[4] - 1)) % 0x100
	end
	pwtemp[4]	= (0x100 + pwcopy[4] - 0xAA) % 0x100

	-- encode to password bits
	for i = 0, 9 do
		pwout[i]	= 0
	end
	for char = 0, 7 do
		for bit = 0, 4 do
			local thisbit	= pwtemp[bit] % 2
			pwtemp[bit]		= math.floor(pwtemp[bit] / 2)
			pwout[char]		= OR(pwout[char], thisbit * 2^bit)
		end
	end

	pwout[8]	= AND(checksum, 0x1F)
	pwout[9]	= math.floor(AND(checksum, 0xE0) / 0x20)
	-- pwout[9]	= OR(pwout[9], math.random(0, 3) * 0x08)
	pwout[9]	= OR(pwout[9], (math.floor(timer / 1) % 4) * 0x08)
	return pwout

end








local pslots = {
	{	slot	= "def1",	options = { idef1, idef1 + 1, idef1 + 2, idef1 + 3 } },
	{	slot	= "def2",	options = { idef2, idef2 + 1, idef2 + 2, idef2 + 3 } },
	{	slot	= "def3",	options = { idef3, idef3 + 1, idef3 + 2, idef3 + 3 } },

	{	slot	= "atk1",	options = { iatk1, iatk1 + 1, iatk1 + 2, iatk1 + 3 } },
	{	slot	= "atk2",	options = { 0, 0x19, 0x1A } },
	{	slot	= "atk3",	options = { 0,     iatk3 + 1, iatk3 + 2, iatk3 + 3 } },
	}
local pslotedit	= false
local pslottime = false
local pslotanim = 7
function pwitemmenu()
	if not pslotedit then return end
	if pslotedit < 0 then
		-- -1: hyper boots
		-- -2: magic key
		if pslotedit == -1 then
			currentstate.hyperboots	= not currentstate.hyperboots
			mem.byte[0x7F3]			= currentstate.hyperboots and 0x0C or 0x07
		elseif pslotedit == -2 then
			currentstate.magickey	= not currentstate.magickey
			mem.byte[0x7F3]			= currentstate.magickey and 0x0C or 0x07
		end
		pslotedit = false
		return
	end
	local column	= math.floor((pslotedit - 1) / 3)
	local columnt	= (column == 0 and " DEFENSE" or " ATTACK") .. (((pslotedit - 1) % 3) + 1) .." "
	local xp		= column == 0 and 20 or 98
	local yp		= 201 -- 192
	local ocount	= #pslots[pslotedit].options
	local ymod		= math.floor(clamp((timer - pslottime) / pslotanim, 0, 1) * ocount * 11 + 6)
	yp				= yp - ymod
	gui.box(xp, yp, xp + 70, yp + ymod, "black", "white")
	gui.text(xp + 1, yp - 8, columnt, "black", "white")
	local clear		= false
	local m			= input.mouse()
	for i = 1, ocount do
		if ymod >= (i * 11) then
			local bxp	= xp + 4
			local byp	= yp - 5 + i * 11
			local cs	= string.format("%X", pslotedit + (i - 1) * 2)
			local hit	= hitbox(m.x, m.y, bxp - 1, byp - 1, bxp + 63, byp + 7)
			local bcol	= (hit and "P1" or "P0") .. cs
			local tcol	= "white"
			if currentstate[pslots[pslotedit].slot] == pslots[pslotedit].options[i] then
				tcol	= bcol -- "P0" .. cs
				bcol	= "white"
			end
			gui.box(bxp - 1, byp - 1, bxp + 63, byp + 7, bcol, bcol)
			-- gui.line(x - 3, y + 7, x + 66, y + 7, col2)

			gui.text(bxp, byp, itemnames[pslots[pslotedit].options[i]], tcol, "clear")
			-- gui.text(bxp, byp, tostring(currentstate[pslots[pslotedit].slot]), tcol, "clear")

			if hit and input.pressed("leftclick") then
				mem.byte[0x7F3]	= 0x0C	-- cursor sel
				currentstate[pslots[pslotedit].slot] = pslots[pslotedit].options[i]
				if pslots[pslotedit].slot == "atk2" then
					currentstate.parallel = pslots[pslotedit].options[i] == 0x1A
					currentstate.double = pslots[pslotedit].options[i] == 0x19
				end
				clear = true
			end
		end
	end

	if clear then
		pslotedit = false
	end	
end

function pwitembtn(x, y, slot)
	local m	= input.mouse()
	local hit	= hitbox(m.x, m.y, x - 3, y - 1, x + 66, y + 7)
	local col	= hit and "P11" or "P01"
	local col2	= hit and "P21" or "P11"
	if hit and input.pressed("leftclick") then
		pslotedit = (slot ~= pslotedit) and slot or false
		pslottime = timer
		mem.byte[0x7F3]	= 0x07	-- cursor move
	end
	if pslotedit == slot then
		col		= (timer % 20 < 10) and "P15" or "P05"
		col2		= (timer % 20 < 10) and "P35" or "P25"
	end
	gui.box(x - 3, y - 1, x + 66, y + 7, col)
	gui.line(x - 3, y + 7, x + 66, y + 7, col2)
end





local pwcursor = 0
function pwinput()
	local xp	= 62
	local yp	= 128
	local m		= input.mouse()

	gui.box(86 + 8 * pwcursor, 72, 88 + 8 * pwcursor + 8, 74, "white")
	if button(60, 116, 60, 6) then pwcursor = (10 + pwcursor - 1) % 10; mem.byte[0x7F3]	= 0x07; end
	if button(126, 116, 60, 6) then pwcursor = (pwcursor + 1) % 10; mem.byte[0x7F3]	= 0x07; end
	textoutline(87, 116, "<<")
	textoutline(152, 116, ">>")
	for i = 0, 0x1F do
		local col	= i % 8
		local row	= math.floor(i / 8)
		local hit = hitbox(m.x, m.y, xp - 2 + col * 16, yp - 4 + row * 16, xp + col * 16 + 12, yp + row * 16 + 10)
		gui.box(xp - 2 + col * 16, yp - 4 + row * 16, xp + col * 16 + 12, yp + row * 16 + 10, hit and "#80808080" or "clear", hit and "white" or "gray")
		if not pslotedit and hit and input.pressed("leftclick") then
			mem.byte[0x100 + pwcursor]	= i
			mem.byte[0x7F3]	= 0x0C
			pwcursor = (pwcursor + 1) % 10	
		end
	end

end






currentstate	= decodestate(decodepassword(readpwmem()))

function passwordscreen()
	pwinput()

	local currentpw	= readpwmem()
	local decode	= decodepassword(currentpw)
	local decodedstate	= decodestate(decode)

	currentstate		= decodedstate
	-- local decodedstate	= currentstate

	--[[
	for i = 0, 0x09 do
		gui.text(24, 80 + i * 8, hexs(currentpw[i])  .." ".. thinbinary(currentpw[i]))
	end
	for i = 0, 0x04 do
		gui.text(70, 80 + i * 8, hexs(decode[i]) .." ".. thinbinary(decode[i]))
	end
	--]]
	-- gui.text( 9, 86, "PW:" .. hexs(decode.pwsum,3) .." ".. thinbinary(decode.pwsum, 12), "gray", "black")
	-- gui.text( 9, 94, "CS: ".. hexs(decode.check) .." ".. thinbinary(decode.check, 12), "gray", "black")

	gui.text( 180, 60, decode.valid and "Accepted" or "Rejected", decode.valid and "green" or "red", "black")
	if decode.valid then
		gui.text( 180, 60 + 8, decode.pass and "Decoded" or "Aborted", decode.pass and "green" or "red", "black")
	else
		gui.text( 180, 60 + 8, decode.pass and "Decoded" or "Aborted", "#404040", "black")
	end

	--[[
	local i = 0
	for k,v in pairs(decodedstate) do
		gui.text(20, 80 + i * 8, k ..": ".. tostring(v))
		i = i + 1
	end
	--]]
	
	gui.box(  206,  80, 256, 245, "black", "white")
	gui.box(   -1, 190, 256, 245, "black", "white")

	gui.box(  140,  86, 196, 106, "black", "white")
	gui.text( 152,  88, "Max HP", "white", "clear")
	gui.text( 160,  97, string.format("%03d", decodedstate.hp), decodedstate.hp > 300 and "red" or "white", "clear")
	local hpchange = 0
	if button(159 - 17, 88,  8, 7) then   hpchange = -50;	end
	if button(159 - 17, 96, 10, 8) then   hpchange = -10;	end
	if button(159 -  6, 96,  4, 8) then   hpchange =  -1;	end
	if button(203 - 17, 88,  8, 7) then   hpchange =  50;	end
	if button(203 - 19, 96, 10, 8) then   hpchange =  10;	end
	if button(203 - 24, 96,  4, 8) then   hpchange =   1;	end
	decodedstate.hp	= clamp(decodedstate.hp + hpchange, 0, 999)
	if hpchange ~= 0 then
		mem.byte[0x7F3]	= (hpchange > 0) and 0x0C or 0x07 -- cursor sel or move
	end


	local bh	= 10
	local by	= 196

	gui.text(  34, by - 1, "DEFENSE", "white", "clear")
	pwitembtn( 24, by + bh * 1, 1)
	pwitembtn( 24, by + bh * 2, 2)
	pwitembtn( 24, by + bh * 3, 3)
	gui.text(  26, by + bh *  1, itemnames[decodedstate.def1], decodedstate.def1 == idef1 and "gray" or "white", "clear")
	gui.text(  26, by + bh *  2, itemnames[decodedstate.def2], decodedstate.def2 == idef2 and "gray" or "white", "clear")
	gui.text(  26, by + bh *  3, itemnames[decodedstate.def3], decodedstate.def3 == idef3 and "gray" or "white", "clear")

	gui.text( 114, by - 1, "ATTACK", "white", "clear")
	pwitembtn( 102, by + bh * 1, 4)
	pwitembtn( 102, by + bh * 2, 5)
	pwitembtn( 102, by + bh * 3, 6)
	gui.text( 104, by + bh *  1, itemnames[decodedstate.atk1], decodedstate.atk1 == iatk1 and "gray" or "white", "clear")
	gui.text( 104, by + bh *  2, itemnames[decodedstate.atk2], decodedstate.atk2 == 0     and "gray" or  "white", "clear")
	gui.text( 104, by + bh *  3, itemnames[decodedstate.atk3], decodedstate.atk3 == 0     and "gray" or "white", "clear")

	pwitemmenu()

	gui.text( 194, by - 1, "ITEM", "white", "clear")
	pwitembtn( 182, by + bh * 1, -2)
	pwitembtn( 182, by + bh * 2, -1)
	gui.text( 184, by + bh *  1, "MagicKey", decodedstate.magickey and "white" or "#404040", "clear")
	gui.text( 184, by + bh *  2, "HyperBoots", decodedstate.hyperboots and "white" or "#404040", "clear")

	if button(187, by + bh * 3 - 1, 8) then mem.byte[0x7F3] = 0xC; decodedstate.random = (0x10 + decodedstate.random - 1) % 0x10 end
	if button(233, by + bh * 3 - 1, 8) then mem.byte[0x7F3] = 0xC; decodedstate.random = (0x10 + decodedstate.random + 1) % 0x10 end
	gui.text( 197, by + bh *  3, string.format("RND $%X", decodedstate.random), "white", "clear")

	-- --[[
	gui.box(  216,  75, 246, 85, "black", "white")
	gui.text(  220,  77, "BELL", "white", "black")
	local burncount = 0
	for b = 0, 7 do
		local bellowned	= AND(decodedstate.bellsbitflag, 2 ^ b) ~= 0
		if button(213, 89 + 11 * b, 8) then
			decodedstate.bellsbitflag = XOR(decodedstate.bellsbitflag, 2 ^ b)
			mem.byte[0x7F3]	= (not bellowned) and 0x0C or 0x07 -- cursor sel or move
		end
		gui.text(224, 90 + 11 * b, "Bell ".. b, bellowned and (burncount < decodedstate.bellsburnt and "red" or "white") or "#404040", "black")
		if bellowned then burncount = burncount + 1 end
		
	end
	
	if button(213, 179, 8) then
		decodedstate.bellsburnt	= clamp(decodedstate.bellsburnt - 1, 0, 7)
		mem.byte[0x7F3]	= 0x07 -- cursor move
	end
	if button(242, 179, 8) then
		decodedstate.bellsburnt	= clamp(decodedstate.bellsburnt + 1, 0, 7)
		mem.byte[0x7F3]	= 0x0C -- cursor sel
	end

	gui.text(224, 180, decodedstate.bellsburnt .."/7", "red", "black")
	--]]


	local encoded = encodestate(decodedstate)
	-- for i = 0, 4 do
	-- 	gui.text(230, 20 + i * 8, hexs(encoded[i]))
	-- end
	local enpw = encodepassword(encoded)
	gui.box(88, 54, 169, 61, "black")
	for i = 0, 9 do
		-- gui.text(200, 20 + i * 8, hexs(enpw[i]))
		gui.text(89 + 8 * i, 55, pwletter[enpw[i]], "white", "clear")
	end
	writepwmem(enpw, pwcursor)
	-- writepwmem(enpw, (timer / 2) % 10)


	--[[
	local teststate	= {}
	for i = 0, 4 do
		teststate[i]	= math.random(0, 0xff)
	end
	-- teststate[math.random(0,4)]	= math.random(0x0, 0xFF)
	local testdecode	= decodestate(teststate)
	local testencode	= encodestate(testdecode)
	local testencodep	= encodepassword(testencode)
	local testdecodep	= decodepassword(testencodep)
	local ln			= 0
	-- for k,v in pairs(testdecode) do
	-- 	gui.text(115, 110 + 8 * ln, string.format("%s:%s", k, tostring(v)),testdecode[k] == testdecode2[k] and "green" or "red" , "black")
	-- 	-- gui.text(115, 110 + 8 * ln, string.format("%s:%s", k, tostring(v)),"white" , "black")
	-- 	ln = ln + 1
	-- end
	for i = 0, 4 do
		gui.text(112, 90 + i * 8, hexs(testencode[i]) .." " .. hexs(testdecodep[i]), testencode[i] == testdecodep[i] and "white" or "red")
	end
	--]]

	--[[
	local testpass	= {}
	for i = 0, 9 do
		testpass[i]	= 0-- math.random(0, 0x1F)
	end

	local testdecode	= decodepassword(testpass)
	local teststate		= decodestate(testdecode)
	local testencode	= encodestate(teststate)
	local testpass2		= encodepassword(testencode)

	gui.box(65, 128, 200, 184, "black", "red")
	for i = 0, 9 do
		gui.text(68 + 13 * i, 130, string.format("%02X", testpass[i]))
		if i <= 4 then
			gui.text(68 + 13 * i, 138, string.format("%02X", testdecode[i]))
			gui.text(68 + 13 * i, 146, string.format("%02X", testencode[i]), testdecode[i] == testencode[i] and "green" or "red")
		end
		gui.text(68 + 13 * i, 154, string.format("%02X", testpass2[i]), testpass2[i] == testpass[i] and "green" or "red")
	end
	--]]
	-- showmouse(true)

end