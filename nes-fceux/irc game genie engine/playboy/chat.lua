-- "Chat" API: aka how PlayBoy connects to the IRC server and interacts with it.
local ROOT_PATH = (...):match('(.+)%.%w+$')
local Class  = require(ROOT_PATH ..".class")
local Socket = require("socket") -- We'll need some good old socket action
local Chat = Class("PlayBoy Chat") -- Oh, and some good ol' PlayBoy Chat action.


function Chat:connect(server, port)
	self.tcp = Socket.tcp()
	local ok = self.tcp:connect(server, port)
	
	if ok == 1 then
		print(">Connected to " .. server .. "!")
	else
		print(">Cannot connect to " .. server .. ".")
	end
end

function Chat:getStats()
	-- Returns bytes received, sent, and the socket object's age (in seconds).
	if not self.tcp then return end
	return self.tcp:getstats()
end

function Chat:sendCommand(command, message)
	-- Sends a command to the server, with a message.
	if not self.tcp then return end
	self.tcp:send(command .. " " .. (message or "") .. "\r\n")
end

function Chat:sendChatMessage(channel, message)
	self.tcp:send("PRIVMSG " .. channel .. " :" .. (message or "") .. "\r\n")
end

function Chat:joinChannel(channel)
	-- If it's able to, sends the JOIN command. It's pretty much a shortcut.
	self:sendCommand("JOIN", channel or "#love") -- Now I'm really making things blatant!
end

function Chat:receiveMessage(flag)
	if not self.tcp then return end
	return self.tcp:receive(flag or "*l")
end

function Chat:setTimeout(timeout)
	-- Sets up the timeout.
	if not self.tcp then return end
	self.tcp:settimeout(timeout or 0)
end

function Chat:operate()
	-- RECEIVES MESSAGES
	local message, err = self:receiveMessage()
	if message then
		-- Right now it only gets the raw message. That's probably a good idea to update.
		return message
	end
end

function Chat:close()
	-- Called to close up the chat, if you catch my drift.
	if self.tcp then self.tcp:close() end
end

return Chat