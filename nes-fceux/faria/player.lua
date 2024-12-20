
	local expTable	= require("exptable")

	local Player	= {
		values		= {
			addresses	= {
				hp			= 0x6914,
				maxhp		= 0x6915,
				goldA		= 0x691B,
				goldB		= 0x691C,

				str			= 0x6912,
				dp			= 0x6913,
				level		= 0x691A,
				expA		= 0x6917,
				expB		= 0x6918,
				expNextA	= 0x6962,
				expNextB	= 0x6963,

				arrows		= 0x6925,
				battery		= nil,

				bomb		= 0x6928,
				sede		= 0x6927,
				saba		= 0x6929,

				overX		= 0x00C1,
				overY		= 0x00C2,
				townXI		= 0x00C1,
				townYI		= 0x00C2,
				townX		= 0x00B4,
				townY		= 0x00B5,

				mystery		= 0x00b6,
				towerFloor	= 0x00b7,
				towerRoom	= 0x00b8,

			},
		},



	};


	Player_mt		= { __index = Player };
	Playerv_mt		= { __index = 
							function (s,k)
								if s.addresses[k] == nil then
									print("ERR: Tried to get key ".. k .." but it's nil!");
									return 0;
								end
								return memory.readbyte(s.addresses[k])
							end
					}
	setmetatable( Player , Player_mt );
	setmetatable( Player.values , Playerv_mt );

	function Player:new()
		local ret	= {};
		ret.values	= { addresses	= Player.values.addresses };
		setmetatable( ret, Player_mt );
		setmetatable( ret.values , Playerv_mt );	
		return ret

	end



	function Player:getStatus()
	
		local level		= self.values.level + 1
		local exp		= self.values.expA + self.values.expB * 0x100
		local expNext	= self.values.expNextA + self.values.expNextB * 0x100

		local levelExp	= 0
		local levelLen	= 0

		if expTable[level] and expTable[level + 1] then
			levelExp	= exp - expTable[level]
			levelLen	= expTable[level + 1] - expTable[level]
	
		end



		return {
			hp			= self.values.hp,
			maxHp		= self.values.maxhp,
			gold		= self.values.goldA + self.values.goldB * 0x100,

			str			= self.values.str,
			dp			= self.values.dp,
			level		= level,

			exp			= exp,
			expNext		= expNext,

			levelLen	= levelLen,
			levelExp	= levelExp,

			location	= self:getPosition()

		}

	end

	function Player:getPosition()
		-- Towers are 8x8 in this game
		local towerRoomRaw	= self.values.towerRoom
		local towerRoom		= {
				x	= towerRoomRaw % 8,
				y	= math.floor(towerRoomRaw / 8),
			}
		return {
			overX	= self.values.overX,
			overY	= self.values.overY,
			townX	= self.values.townX,
			townY	= self.values.townY,

			towerFloor		= self.values.towerFloor,
			towerRoom		= towerRoom,
			towerRoomRaw	= towerRoomRaw,
		}

	end


	return Player:new()