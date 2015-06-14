
m	= require("m")

objectTypes	= {}

objectTypes[0x00]	= "fuck"
objectTypes[0x01]	= "Villager"
objectTypes[0x02]	= "God"
objectTypes[0x03]	= "Ambrosia"
objectTypes[0x04]	= "Health refill?"
objectTypes[0x05]	= "Turns into 03 and drops"

objectTypes[0x06]	= "(Kills itself?)"
objectTypes[0x07]	= "(Also kills self?)"
objectTypes[0x08]	= "Drop!"
objectTypes[0x09]	= "Poison buble spawner"
objectTypes[0x0A]	= "(? Always does damage)"
objectTypes[0x0B]	= "Throwing spear projectile"
objectTypes[0x0C]	= ""
objectTypes[0x0D]	= ""
objectTypes[0x0E]	= "Crete Soldier Axe"
objectTypes[0x0F]	= "Amazon projectile"
objectTypes[0x10]	= ""
objectTypes[0x11]	= "Fireball projectile"
objectTypes[0x12]	= "Red bush to burn?"
objectTypes[0x13]	= "Dolphin (summonable)"
objectTypes[0x14]	= "Bull"
objectTypes[0x15]	= "Boss (never un-invulns)"
objectTypes[0x16]	= ""
objectTypes[0x17]	= ""
objectTypes[0x18]	= "Cyclops"
objectTypes[0x19]	= "Lion?"

objectTypes[0x1a]	= "Lamia?"
objectTypes[0x1b]	= ""
objectTypes[0x1c]	= "Dark Unicorn"
objectTypes[0x1d]	= "Statue"
objectTypes[0x1e]	= "? (Flappy wing shit)"
objectTypes[0x1f]	= "Ladon"

objectTypes[0x20]	= "? (Flies sideways lots, weird)"
objectTypes[0x21]	= "Minotaur"
objectTypes[0x22]	= "Spring-loaded Centaur"
objectTypes[0x23]	= "Crete Soldier"
objectTypes[0x24]	= "Giant Snake"
objectTypes[0x25]	= "Amazon Prime"
objectTypes[0x26]	= "Slime"
objectTypes[0x27]	= "Something fishy."
objectTypes[0x28]	= "Bat"
objectTypes[0x29]	= "Snake A"
objectTypes[0x2a]	= "Snake B"
objectTypes[0x2b]	= "Satyr"
objectTypes[0x2c]	= "Jumper"
objectTypes[0x2d]	= "Fish"
objectTypes[0x2e]	= "Monkey"
objectTypes[0x2f]	= "Ghost"
objectTypes[0x30]	= "Spider web"
objectTypes[0x31]	= "Amazon"
objectTypes[0x32]	= "Spear-throwing man"
objectTypes[0x34]	= "Scorpion"
objectTypes[0x35]	= "Gargoyle"

objectTypes[0x39]	= "Bird"
objectTypes[0x3A]	= "Rock (dropped from bird)"

objectTypes[0x3C]	= "Pegasus (summonable)"
objectTypes[0x3d]	= "Shadow"

objectTypes[0x40]	= "Snake C"




--[[

		NOT TALKING TIME !

		01e-01f	Camera X

		053		Player X velocity

		063		Player x Position (lo)

		065		Player y position ???
		067		Player y hitbox
		068		Player h hitbox size
--]]

function getCamera()
	return {
		x	= m.r2(0x001e, 0x001f),
		y	= 0,
		}

end

function positionToScreen(obj, cam)
	return {
		x	= obj.x - cam.x,
		y	= obj.y - cam.y
		}
end


function getPlayer()
	local player	= {}
	player.x	= m.r2(0x063, 0x064)
	player.y	= m.rb(0x065)
	player.hp	= m.rb(0x04a)

	return player
end

function getObjects()
	local objects	= {}
	for i = 0, 8 do
		local b	= 0x400 + (0x10 * i)
		objects[i]	= {
			type		= m.rb(b + 0x0),
			state		= m.rb(b + 0x1),
			x			= m.r2(b + 0x2, b + 0x3),
			y			= m.rb(b + 0x4),
			tile		= m.rb(b + 0x5),
			yfrac		= m.rb(b + 0x6),
			xaccel		= m.rb(b + 0x7),
			xfrac		= m.rb(b + 0x8),
			yaccellfrac	= m.rb(b + 0x9),
			yaccel		= m.rb(b + 0xa),
			animframe	= m.rb(b + 0xb),
			animtimer	= m.rb(b + 0xc),
			unk_d		= m.rb(b + 0xd),
			timer		= m.rb(b + 0xe),
			damage		= m.rb(b + 0xf)


			}


	end
	return objects
end



function drawObjects()

	local player	= getPlayer()

	local camera	= getCamera()

	local playerpos	= positionToScreen(player, camera)
	gui.line(playerpos.x, playerpos.y, playerpos.x + 0, playerpos.y + 5, "white")
	gui.line(playerpos.x, playerpos.y, playerpos.x + 5, playerpos.y + 0, "white")

	gui.text(1, 1, string.format("%04X %02X", player.x, player.y))

	local objects	= getObjects()
	for i, obj in pairs(objects) do
		if obj.type ~= 0x80 and obj.type ~= 0x00 then
			local objectpos	= positionToScreen(obj, camera)
			gui.line(objectpos.x, objectpos.y, objectpos.x + 0, objectpos.y + 5, "white")
			gui.line(objectpos.x, objectpos.y, objectpos.x + 5, objectpos.y + 0, "white")
			gui.text(objectpos.x + 2, objectpos.y + 2, i)
			local types	= (objectTypes[obj.type] and objectTypes[obj.type] ~= "") and objectTypes[obj.type] or "Unknown"
			gui.text(1, 20 + i * 8, string.format("%X - %02X (%s)", i, obj.type, types))

		end

	end


end

function megaFart()
	local s	= 3
	local a	= s * 4 + 0x200

	memory.writebyte(a+3, math.random(5, 30))
	memory.writebyte(a+0, math.random(12, 32))
end




while true do

	megaFart()
	memory.writebyte(0x04a, 0x10)

	drawObjects()
	--m.showUnusedSprites(0xFF)

	emu.frameadvance()
end