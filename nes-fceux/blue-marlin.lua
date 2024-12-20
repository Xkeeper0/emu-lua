--[[
	
	RAM address notes:

	00a2	Fishing area
			0-2: Florida
			3-5: Hawaii 1
			6-8: Hawaii 2
			9-B: Hawaii 3

	01a9	line test value

	0497	weather
	0498	temperature
	0499	tournament day (0~3)
	
	05b0	last fish type
	05b4	fish stamina ( <=56 1 sweat   <=2B 2 sweat )
	
	05d6	last hooked fish weight

	in-game timer
	0753	tick rate???
	0754	frames
	0755	seconds
	0756	minutes
	0757	"hours" (day ends at 10)

	"since last..." timer???
	0758	past me wtf did this mean
	0759
	075a
	075b

	075c	line length setting ( (n+1) * 100) )

	075d	line remaining delta maybe
	075e	line remaining (word)

	0760	player level skill  (0-4: D C B A AA)
	0761	player level muscle
	0762	player level body

	0763	player exp skill
	0764	player exp muscle
	0765	player exp body

	0766	lure
	0767	lure depth
	0768	line test option

	076a	largest marlin caught
	076e	average marlin caught

	0772	hook strength
			>= F0: invuln.
			<= A0: crisis
			<= 50: crisis 2
	
	0777	todays largest marlin (word) x 12

	0792	todays fish type x 12


	07b8	player stamina delta maybe
	07b9	player stamina
	07ba	player max stamina maybe

	07c1	line tension (higher = better)
			3B: warning beep
			1F: super warning beep

	07c2	"some line test value 1"
	07c4	reverse active




--]]


require("libs/toolkit")
require("libs/functions")

-- Require some modules/classes
MemoryAddress		= require("libs/memoryaddress")
MemoryCollection	= require("libs/memorycollection")

input				= require("libs/input")






local gameClock	= MemoryCollection{
	rate		= MemoryAddress.new(0x0753, "byte", false),
	frames		= MemoryAddress.new(0x0754, "byte", false),
	seconds		= MemoryAddress.new(0x0755, "byte", false),
	minutes		= MemoryAddress.new(0x0756, "byte", false),
	hours		= MemoryAddress.new(0x0757, "byte", false),

	-- wtf does this MEAN
	framesLast	= MemoryAddress.new(0x0754, "byte", false),
	secondsLast	= MemoryAddress.new(0x0755, "byte", false),
	minutesLast	= MemoryAddress.new(0x0756, "byte", false),
	hoursLast	= MemoryAddress.new(0x0757, "byte", false),
	}


local todaysFish	= {}
for i = 0, 11 do
	todaysFish[i]	= MemoryCollection{
		-- this is clearly wrong somehow but i'm not sure how
		weight		= MemoryAddress.new(0x077a + i * 2, "word", false),
		type		= MemoryAddress.new(0x0792 + i, "byte", false)
	}
end


local player	= MemoryCollection{
	stamina			= MemoryAddress.new(0x07b9, "byte", false),
	staminaDelta	= MemoryAddress.new(0x07b8, "byte", true),
	staminaMax		= MemoryAddress.new(0x07ba, "byte", false),

	skillLv			= MemoryAddress.new(0x0760, "byte", false),
	muscleLv		= MemoryAddress.new(0x0761, "byte", false),
	bodyLv			= MemoryAddress.new(0x0762, "byte", false),
	skillEXP		= MemoryAddress.new(0x0763, "byte", false),
	muscleEXP		= MemoryAddress.new(0x0764, "byte", false),
	bodyEXP			= MemoryAddress.new(0x0765, "byte", false),
	}

local fishing	= MemoryCollection{
	hookStrength	= MemoryAddress.new(0x0772, "byte", false),
	tension			= MemoryAddress.new(0x07c1, "byte", false),
	
	lineRemaining	= MemoryAddress.new(0x075e, "word", false),
	lineFractional	= MemoryAddress.new(0x075d, "byte", false),
	
	fishType		= MemoryAddress.new(0x05b0, "byte", false),
	fishStamina		= MemoryAddress.new(0x05b4, "byte", false),
	fishWeight		= MemoryAddress.new(0x05d6, "word", false),

	}

-- 7a2

local fart			= {}

for i = 0, 7 do
	fart[i]	= MemoryCollection{
		x	= MemoryAddress.new(0x0396 + 4 * i, "byte", false),
		y	= MemoryAddress.new(0x0398 + 4 * i, "byte", false),
		}
end

local showFishing	= 1
local showPlayer	= 1

local levels		= { "D", "C", "B", "A", "AA" }

fishTypes		= { "BlueMarlin", "BlackMarlin", "StripedMarlin", "SwordFish", "SailFish", "Tuna", "WhiteShark", "Barracuda", "Dorado" }

function fishType(n)
	return fishTypes[n + 1] and fishTypes[n + 1] or string.format("? (%02X)", n)


end

while true do

	for i = 0, 7 do
		gui.text(80, 20 + i * 8, string.format("%04X %04X", fart[i].x, fart[i].y))
	end

	if input.pressed("Z") then
		showFishing	= not showFishing
	end
	if input.pressed("X") then
		showPlayer	= not showPlayer
	end

	if showFishing then

		gui.text(177, 174, string.format("Hook\n%3d", fishing.hookStrength))
		gui.text( 91, 149, string.format("Tension: %3d", fishing.tension))

		gui.text( 49, 159, string.format("%3d.%02X", fishing.lineRemaining, fishing.lineFractional))

		gui.text(195, 211, string.format(" %3dlb. \n(%s)", fishing.fishWeight, fishType(fishing.fishType)))
		gui.text(195, 154, string.format("Stm %3d", fishing.fishStamina))
		gui.text( 62, 133, string.format(" %3d/%3d", player.stamina, player.staminaMax))
	end

	if showPlayer then
		gui.text(181,  11, "Player Status")
		gui.text(180,  20, "Skill   \nMuscle \nBody  ")
		gui.text(210,  20, string.format("%-2s+%3d\n%-2s+%3d\n%-2s+%3d", levels[player.skillLv + 1], player.skillEXP, levels[player.muscleLv + 1], player.muscleEXP, levels[player.bodyLv + 1], player.bodyEXP))

		gui.text( 0, 30, "Held fish:")
		for i = 0, 11 do
			if todaysFish[i].type ~= 0xFF then
				gui.text( 0,  39 + i * 8, string.format("%3dlb. (%s)", todaysFish[i].weight, fishType(todaysFish[i].type)))
			end
		end
	end

	gui.text(0, 0, string.format("%02d:%02d:%02d (%02X/%X)", gameClock.hours, gameClock.minutes, gameClock.seconds, gameClock.frames, gameClock.rate))
	-- gui.text(0, 8, string.format("%02d:%02d:%02d.%02d", gameClock.hoursLast, gameClock.minutesLast, gameClock.secondsLast, gameClock.framesLast))


	emu.frameadvance()
	input.update()

end







--[[


	misc notes:

	00:A73A seems to be related to moving objects on the map(?)
	called with X=0, 1, 2



--]]