local discord
local function getDiscord()
	discord = discord or loadfile("utils/discord.lua")()
	return discord
end

local commands
local function getCommands()
	commands = commands or loadfile("data/commands.lua")()
	return commands
end

local farms
local function getFarms()
	farms = farms or loadfile("utils/farms.lua")()
	return farms
end

local function concatTable(t, sep)
	local result = ""
	for i, v in ipairs(t) do
		result = result .. v
		if i < #t then
			result = result .. sep
		end
	end
	return result
end

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local function getCurrentTime()
	return os.time(os.date("*t"))
end

local commands = {
	status = {
		description = "Check the status of the farm system.",
		permissions = { "pc", "discord" },
		action = function(platform)
			local farms = getFarms().getFarms()
			local total = 0
			local active = 0
			local time  = getCurrentTime()
			for _, farm in pairs(farms) do
				if farm.type == "farm" then
					total = total + 1
					if time - farm.lastUpdate < 10 then
						active = active + 1
					end
				end
			end
			local msg = string.format("Total farms: %d, Active farms: %d", total, active)
			if platform == "discord" then
				return { title = "Farm Status", description = msg, color = 65280 }, "embed"
			end
			return "Farm status: " .. msg
		end,
	},
	logs = {
		description = "View recent logs from the Discord bot.",
		permissions = { "pc" },
		action = function()
			local logs = getDiscord().getLogs()
			if #logs == 0 then
				return string.format("No logs available. %s", logs)
			else
				local logMessages = { "Recent Logs:" }
				for i = math.max(1, #logs - 9), #logs do
					local log = logs[i]
					if log.type == "received" then
						table.insert(logMessages, string.format("[RECEIVED] %s: %s", log.user, log.content))
					elseif log.type == "message" then
						table.insert(logMessages, string.format("[SENT] %s", log.content))
					elseif log.type == "embed" then
						table.insert(logMessages, string.format("[EMBED] %s: %s", log.title, log.description))
					end
				end
				sleep(0)
				return table.concat(logMessages, "\n")
			end
		end,
	},
	exit = {
		description = "Exit the program.",
		permissions = { "pc" },
		action = function()
			return "Exiting program."
		end,
	},
	ping = {
		description = "Check if the bot is responsive.",
		permissions = { "discord" },
		action = function()
			return "pong!"
		end,
	},
	list = {
		description = "List all available commands.",
		permissions = { "pc", "discord" },
		action = function(platform)
			local commandList = {}
			for cmd, info in pairs(getCommands()) do
				if has_value(info.permissions, platform) then
					local name = (platform == "discord") and ("!" .. cmd) or cmd
					table.insert(commandList, string.format("`%s` - %s", name, info.description))
				end
			end

			if platform == "discord" then
				return {
					title = "Command List",
					description = table.concat(commandList, "\n"),
					color = 10181046,
				},
					"embed"
			end
			return "Available Commands:\n" .. table.concat(commandList, "\n")
		end,
	},
	farms = {
		description = "List all connected farms and their status.",
		permissions = { "discord" },
		action = function()
			local farms = getFarms().getFarms()
			local farmList = {}
			local time = getCurrentTime()
			for _, farm in pairs(farms) do
				if farm.type == "farm" then
					local status = (time - farm.lastUpdate < 10) and "Active" or "Inactive"
					table.insert(farmList, string.format("**%s** (ID: %d) - %s", farm.name, farm.id, status))
				end
			end

			if #farmList == 0 then
				return "No farms currently connected."
			end

			return {
				title = "Connected Farms",
				description = table.concat(farmList, "\n"),
				color = 65280,
			}, "embed"
		end,
	},
}

return commands
