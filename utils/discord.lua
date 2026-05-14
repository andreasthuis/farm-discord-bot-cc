local config = loadfile("config.lua")()
local bot_token = "Bot " .. config.token
local channel_id = config.channel_id
local last_message_id = ""
local communication = loadfile("utils/communication.lua")()

_G.bot_logs = _G.bot_logs or {}

local commands
local function getCommands()
	commands = commands or loadfile("data/commands.lua")()
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

local function parseCommand(text, prefix)
	local raw = text:sub(#prefix + 1)
	local parts = {}
	for part in raw:gmatch("%S+") do
		table.insert(parts, part)
	end
	local commandName = table.remove(parts, 1)
	return commandName, parts
end

local function sendEmbed(title, description, reply_to_id)
	local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
	local payload = {
		embeds = { { title = title, description = description, color = 65280 } },
	}
	if reply_to_id then
		payload.message_reference = { message_id = reply_to_id }
	end

	local success, response = pcall(http.post, url, textutils.serializeJSON(payload), {
		["Authorization"] = bot_token,
		["Content-Type"] = "application/json",
	})

	if success and response then
		response.close()
	elseif not success then
		print("[DISCORD] Error sending embed: " .. response)
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

	local success, response = pcall(http.post, url, textutils.serializeJSON(payload), {
		["Authorization"] = bot_token,
		["Content-Type"] = "application/json",
	})

	if success and response then
		response.close()
	elseif not success then
		print("[DISCORD] Error sending message: " .. response)
	end

	_G.bot_logs[#_G.bot_logs + 1] = { type = "message", content = content }
	if #_G.bot_logs > 100 then
		table.remove(_G.bot_logs, 1)
	end
	sleep(0)
end

local function getLatestMessage()
	local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages?limit=1"
	local success, response = pcall(http.get, url, { ["Authorization"] = bot_token })

	if not success then
		print("[DISCORD] Error fetching messages: " .. response)
		sleep(0)
		return nil
	end

	if response then
		local parseSuccess, data = pcall(function()
			return textutils.unserializeJSON(response.readAll())
		end)
		response.close()

		if not parseSuccess then
			print("[DISCORD] Error parsing JSON response")
			sleep(0)
			return nil
		end

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

local function beOnline()
	local gateway_url = "wss://gateway.discord.gg/?v=10&encoding=json"

	local function runBot()
		print("Connecting to Discord Gateway...")

		local ws, err = http.websocket(gateway_url)

		if not ws then
			print("Failed to connect: " .. tostring(err))
			return
		end

		print("Connected! Handshaking...")

		while true do
			local event, url, msg = os.pullEvent()

			if event == "websocket_message" then
				local data = textutils.unserializeJSON(msg)

				if data.op == 10 then
					local heartbeat_interval = data.d.heartbeat_interval / 1000

					ws.send(textutils.serializeJSON({
						op = 2,
						d = {
							token = bot_token,
							intents = 513,
							properties = {
								os = "linux",
								browser = "computercraft",
								device = "computercraft",
							},
						},
					}))

					os.startTimer(heartbeat_interval)
					print("Bot is now ONLINE (Green Dot active).")

				elseif data.op == 1 or event == "timer" then
					ws.send(textutils.serializeJSON({
						op = 1,
						d = JSONObject,
					}))
					os.startTimer(heartbeat_interval or 30)
				end
			elseif event == "websocket_closed" then
				print("Connection lost. Retrying...")
				return runBot()
			end
		end
	end

	runBot()
end

local function runBot()
	local prefix = "!"

	parallel.waitForAny(beOnline)

	while true do
		local user, text, id = getLatestMessage()

		if user and text:sub(1, #prefix) == prefix then
			local commandName, args = parseCommand(text, prefix)

			local commands = getCommands()
			local command = commands[commandName]

			if command and has_value(command.permissions, "discord") then
				local commandData = {command = commandName, args = args, id = id}
				communication.send(textutils.serialize(commandData), "discord_command")
				
				local responseReceived = false
				local result
				while not responseReceived do
					local event, senderId, message, protocol = os.pullEvent("rednet_message")
					if protocol == "discord_response" then
						local responseData = textutils.unserialize(message)
						if responseData.id == id then
							result = responseData.response
							if type(result) == "table" and result.title then
								sendEmbed(result.title, result.description, id)
							else
								sendMessage(tostring(result), id)
							end
							responseReceived = true
						end
					end
				end
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
