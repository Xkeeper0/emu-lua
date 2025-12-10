
do

	local password_state	= {
		level		= 1,
		expTarget	= 1,
		maxHP		= 64,
		maxMP		= 32,
		exp			= 0,
		gold		= 0,
		color		= 0,
		growth		= 0,
		astro		= 0,
		items		= {},
		shift		= 0,
		}

	local previous_password		= nil
	local password_glow			= {}
	local generating_active		= false
	local generating_timer		= 0
	local generatedpassword		= ""
	local generatedbytes		= nil

	function numberbuttons(x, y, n)
		local change	= 0
		for i = 0, n do
			if button(  x + i * 6 - 1, y - 7, 6, 5, "gray") then
				change = change + math.pow(10, n - i)
			end
			if button(  x + i * 6 - 1, y + 8, 6, 5, "gray") then
				change = change - math.pow(10, n - i)
			end
		end
		if change > 0 then
			mem.byte[0x338]	= 0x01		-- beep
		elseif change < 0 then
			mem.byte[0x339]	= 0x01		-- boop
		end
		return change
	end

	function passwordscreen()
		local x, y = 10, 135
	
		x, y = 10, 135
		gui.text( x,      y, "Max HP:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.maxHP))
		password_state.maxHP = clamp(password_state.maxHP + numberbuttons(x + 40, y, 2), 1, 999)

		x, y = 10, 160
		gui.text( x,      y, "Max MP:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.maxMP))
		password_state.maxMP = clamp(password_state.maxMP + numberbuttons(x + 40, y, 2), 0, 999)

		x, y = 80, 135
		gui.text( x,      y, "Level:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.level))
		password_state.level = clamp(password_state.level + numberbuttons(x + 40, y, 2), 0, 0x7F)

		x, y = 80, 160
		gui.text( x,      y, "Next:", "white", "clear")
		gui.text( x + 40, y, string.format("%3d", password_state.expTarget))
		local expnext	= getexpforexplevel(password_state.expTarget)
		local expnexts	= expnext <= 999999 and string.format("%6d", expnext) or string.format("%.2f M", expnext / 1000000)
		gui.text( x +  0, y + 8, expnexts, "#8888ff", "clear")
		password_state.expTarget = clamp(password_state.expTarget + numberbuttons(x + 40, y, 2), 0, 0xFF)

		x, y = 80, 185
		gui.text( x,      y, "EXP:", "white", "clear")
		gui.text( x + 28, y, string.format("%6d", password_state.exp))
		password_state.exp = clamp(password_state.exp / 10 + numberbuttons(x + 28, y, 4), 0, 60159) * 10	-- based on testing, 60159 is valid but 60160 isn't

		x, y = 10, 185
		gui.text( x,      y, "Gold:", "white", "clear")
		gui.text( x + 34, y, string.format("%5d", password_state.gold))
		password_state.gold = clamp(password_state.gold / 10 + numberbuttons(x + 34, y, 3), 0, 0x1FFF) * 10

		x, y = 150, 135
		gui.text( x,      y, "Sign:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.astro))
		password_state.astro = (password_state.astro + numberbuttons(x + 40, y, 0)) % 0x10
		gui.text( x + 50, y, asigns[password_state.astro] and asigns[password_state.astro] or "(Invalid)",  "#8888ff", "clear")

		x, y = 150, 160
		gui.text( x,      y, "Growth:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.growth))
		password_state.growth = (password_state.growth + numberbuttons(x + 40, y, 0)) % 0x04
		gui.text( x + 50, y, growthrates[password_state.growth] and growthrates[password_state.growth] or "(Invalid)",  "#8888ff", "clear")

		x, y = 150, 185
		gui.text( x,      y, "Color:", "white", "clear")
		gui.text( x + 34, y, string.format("%2d", password_state.color))
		password_state.color = (password_state.color + numberbuttons(x + 40, y, 0)) % 0x04
		gui.box( x + 50, y, x + 64, y + 6, string.format("P%02X", playercolors[password_state.color]))

		x, y = 130, 216
		gui.text( x,      y, "Shift:", "white", "clear")
		gui.text( x + 30, y, string.format("%d", password_state.shift))
		password_state.shift = (0x8 + password_state.shift + numberbuttons(x + 30, y, 0)) % 0x8

		x, y = 10, 210
		gui.text( x,      y, "Items:", "white", "clear")
		x, y = 50, 210
		for k,v in pairs(valkyriepw_bit2item) do
			local t = button( x - 3,  y - 3, 37, 12, password_state.items[v] and "#008800" or "#444444")
			if t then 
				mem.byte[0x338 + (password_state.items[v] and 1 or 0)] = 1	-- beep boop
				password_state.items[v] = not password_state.items[v]
			end

			gui.text( x,      y, v,  password_state.items[v] and "white" or "black", "clear")
			x	= x + 40
			if x > 120 then
				x	= x - 120
				y	= y + 14
			end
		end

		generatedpassword, generatedbytes	= valkyriepw_getpassword(password_state)
		if not previous_password then
			for i = 0, 17 do
				password_glow[i]	= 0
			end
		else
			local plen = string.len(generatedpassword)
			for i = 0, 17 do
				local op = string.sub(previous_password, i + 1, i + 1)
				local np = string.sub(generatedpassword, i + 1, i + 1)
				if op ~= np then
					password_glow[i]	= clamp(password_glow[i] + 60, 0, 120)
				end
			end
		end
		previous_password	= generatedpassword


		local fancy		= 0
		local fancy2	= 0
		local plen = string.len(generatedpassword)
		for i = 1, plen do
			fancy	= math.sin((timer + i * 3) / 25) * 3
			fancy2	= clamp(math.ceil(password_glow[i - 1] / 5), 0, 3) * 0x10
			
			local color = string.format("P%02X", fancy2 + 0x01 + ((timer / 5 + i / 3) % 10))
			gui.text(51 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), color, "clear")
			-- gui.text(51 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), "#00000040", "clear")
			gui.text(50 + i * 8, 87 + fancy, string.sub(generatedpassword, i, i), color, "clear")
		end


		for i = 0, 17 do
			password_glow[i]	= math.max(0, password_glow[i] - 1)
		end


		x, y = 175, 207
		local do_generate	= button(x, y, 70, 23, "#008000")
		gui.text( x + 14, y + 8, "Generate!", "white", "clear")
		if do_generate then
			generating_active	= true
			generating_timer	= 40 + math.random(0, 60)
		end


		if generating_active then
			local ptmp		= 0
			local did_any	= false
			for i = 0, 17 do
				ptmp	= mem.byte[0x120 + i]
				if (generating_timer > 0 or ptmp ~= generatedbytes[i]) then
					if math.random(0, 5) > 2 then
						mem.byte[0x120 + i]	= (ptmp + 1) % 0x20
						ptmp	= ptmp + 1 -- break below condition
					end
					if ptmp == generatedbytes[i] then
						password_glow[i]	= 21
					end
					did_any	= true
				else
					password_glow[i]	= 90
				end
			end
			generating_timer	= math.max(0, generating_timer - 1)
			if not did_any then
				generating_active = false
			end
		end
	end
end
