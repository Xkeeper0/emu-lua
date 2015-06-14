-- READ SOME PLAYBOY, KID
local ROOT_PATH = (...)
local Class = require(ROOT_PATH .. ".class") -- NOT BY ME
local Chat  = require(ROOT_PATH .. ".chat")
local Playboy = Class("PlayBoy Client")
-- Now that all that's over with, let's make some magic

function Playboy:initialize(server, port, nickname, username, realname, channel, password)
	-- If any of this stuff isn't defined, it won't matter
	self:setServer(server)
	self:setPort(port)
	self:setNickname(nickname)
	self:setUsername(username)
	self:setRealname(realname)
	self:setChannel(channel)
	
	self.password	= password or nil

	-- Oh and we probably need this
	self.chat = Chat:new()
end

function Playboy:setServer(server)
	-- server: the IRC server you'd like to connect to.
	self.server = server or "irc.oftc.net" -- As a default, we'll use our LOVE-ly network.
end

function Playboy:setPort(port)
	self.port = port or 6667 -- In case any magic (or friendship) is needed.
end

function Playboy:setNickname(nickname)
	self.nickname = nickname or "PlayBoy_Client"
end

function Playboy:setUsername(username)
	self.username = username or "PlayBoy" -- There are no masked men
end

function Playboy:setRealname(realname)
	self.realname = realname or "PlayBoy X" -- GTA IV reference, get!
end

function Playboy:setChannel(channel)
	self.channel = channel or "#playboy" -- The mansion
end

function Playboy:returnChat()
	return self.chat
end

function Playboy:sendMessage(message)
	if not self.chat then return end
	self.chat:sendChatMessage(self.channel, message)
end

function Playboy:connect()
	-- Now THIS is what you want to run to begin PlayBoy. We'll need to set up the Chat as well.
	if not self.chat then return end -- I don't know why this wouldn't exist (hackers), but hey
	self.chat:connect(self.server, self.port)
	if self.password then
		self.chat:sendCommand("PASS", self.password)
	end
	self.chat:sendCommand("NICK", self.nickname)
	self.chat:sendCommand("USER", self.username .. " 8 * :" .. self.realname)

	local delay	= os.time() + 0.5
	while os.time() < delay do end

	self.chat:joinChannel(self.channel)
	self.chat:setTimeout()
end

function Playboy:update(dt)
	if self.chat then
		-- OPERATION
		return self.chat:operate()
	end
end

function Playboy:close()
	-- Close up the chat, and GET DOWN WITH YOUR BAD SELF
	if self.chat then self.chat:close() end
end

return Playboy -- because someone stole it