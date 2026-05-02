local config = loadfile("config.lua")()
local bot_token = "Bot " .. config.token
local channel_id = config.channel_id
local last_message_id = ""

_G.bot_logs = _G.bot_logs or {}

local commands
local function getCommands()
	commands = commands or loadfile("commands.lua")()
	return commands
end

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local function sendEmbed(title, description, reply_to_id)
	local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
	local payload = {
		embeds = { { title = title, description = description, color = 65280 } },
	}
	if reply_to_id then
		payload.message_reference = { message_id = reply_to_id }
	end

	local response = http.post(url, textutils.serializeJSON(payload), {
		["Authorization"] = bot_token,
		["Content-Type"] = "application/json",
	}, 1)
	if response then
		response.close()
	end
	_G.bot_logs[#_G.bot_logs + 1] = { type = "embed", title = title, description = description }
	if #_G.bot_logs > 100 then
		table.remove(_G.bot_logs, 1)
	end
	sleep(0)
end

local function sendMessage(content, reply_to_id)
	local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
	local payload = { content = content }
	if reply_to_id then
		payload.message_reference = { message_id = reply_to_id }
	end

	local response = http.post(url, textutils.serializeJSON(payload), {
		["Authorization"] = bot_token,
		["Content-Type"] = "application/json",
	})
	if response then
		response.close()
	end
	_G.bot_logs[#_G.bot_logs + 1] = { type = "message", content = content }
	if #_G.bot_logs > 100 then
		table.remove(_G.bot_logs, 1)
	end
	sleep(0)
end

local function getLatestMessage()
	local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages?limit=1"
	local response = http.get(url, { ["Authorization"] = bot_token })

	if response then
		local data = textutils.unserializeJSON(response.readAll())
		response.close()
		if data and data[1] then
			local msg = data[1]
			if msg.id ~= last_message_id and not (msg.author and msg.author.bot) then
				last_message_id = msg.id
				_G.bot_logs[#_G.bot_logs + 1] = { type = "received", user = msg.author.username, content = msg.content }
				if #_G.bot_logs > 100 then
					table.remove(_G.bot_logs, 1)
				end
				sleep(0)
				return msg.author.username, msg.content, msg.id
			end
		end
	end
	sleep(0)
	return nil
end

local function runBot()
	local prefix = "!"

	while true do
		local user, text, id = getLatestMessage()

		if user and text:sub(1, #prefix) == prefix then
			local commandName = text:sub(#prefix + 1)

			local commands = getCommands()
			local command = commands[commandName]

			if command and has_value(command.permissions, "discord") then
				local result = command.action("discord")
				sendMessage(result, id)
			else
				sendMessage("Unknown command. Type '!list' to see available commands.", id)
			end
		end

		sleep(2)
	end
end

local function getLogs()
	return _G.bot_logs
end

return {
	runBot = runBot,
	sendEmbed = sendEmbed,
	sendMessage = sendMessage,
	getLogs = getLogs,
}
