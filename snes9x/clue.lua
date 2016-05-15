
for i = 0x7f7180, 0x7f71ff do
	memory.writebyte(i, 10)
	print(i)
end

print("welp")
while true do
	emu.frameadvance()
end


local searchStart	= 0x7E0000
local searchEnd		= 0x7FFFFF

--local searchValues	= { 0x05, 0x08, 0x12 }
--local searchValues	= { 0x05, 0x08, 0x12 }
--local searchValues	= { 0x05, 0x08, 0x12 }
local searchValues	= { 6, 5, 2 }
local searchMaxGap	= 0x04
local searchIndex	= 1
local searchMaxIndex	= #searchValues

local searchOffset	= searchStart
local searchCurrent	= searchStart

local searchInterval	= 0x800

local v				= 0
local searchGap		= 0

while searchOffset <= searchEnd do

	v	= memory.readbyte(searchOffset)
	if v == searchValues[1] then

		searchCurrent	= searchOffset
		searchIndex		= 2
		searchGap		= 0

		while searchGap <= searchMaxGap do
			searchCurrent	= searchCurrent + 1
			v	= memory.readbyte(searchCurrent)
			if v == searchValues[searchIndex] then
				searchGap	= 0
				searchIndex	= searchIndex + 1
				if searchIndex > searchMaxIndex then
					print(string.format("Found potential match at %08x (G = %d)", searchOffset, searchCurrent - searchOffset))
					searchGap	= 99999	-- dumb way to abort but it works
				end
			else
				searchGap	= searchGap + 1
			end
		end
	end

	searchOffset	= searchOffset + 1


	if (searchOffset % searchInterval) == 0 then
		gui.text(5, 5, string.format("%08x", searchOffset))
		emu.frameadvance()
	end

end

print("End of search")



--[[

Cards

C.Mustard
	Plum
	Green

	Candle

	Hall
	Kitchen
	Conservatory

Scarlet
	Scarlet

	Knife
	Wrench

	Lounge
	Dining
	Library

White
	Mustard
	Peacock

	Rope
	Pipe

	Ballroom
	Study



0	Mustard
1	Plum
2	Green
3	Peacock
4	Scarlet
5	White

0	Knife			6
1	Candle			7
2	Revolver		8
3	Rope			9
4	Pipe			a
5	Wrench			b

0	Hall			c
1	Lounge			d
2	Dining			e
3	Kitchen			f
4	Ballroom		10
5	Conservatory	11
6	Billiard		12
7	Library			13
8	Study			14


5	White
2	Revolver
6	Billiard




]]