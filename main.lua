local discord = loadfile("utils/discord.lua")()
local commands = loadfile("data/commands.lua")()
local config = loadfile("config.lua")()
local communication = loadfile("utils/communication.lua")()
local farms = loadfile("utils/farms.lua")()
local storage = loadfile("utils/storage.lua")
local red = loadfile("utils/redstone.lua")()

local sides = { "top", "bottom", "left", "right", "front", "back" }

print("Andreas' Farm System initializing...")

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local function splitWords(input)
	local words = {}
	for word in (input or ""):gmatch("%S+") do
		table.insert(words, word)
	end
	return words
end

local function parseCommand(input)
	local words = splitWords(input)
	local commandName = table.remove(words, 1)
	return commandName, words
end

local function terminalListener()
	while true do
		term.setTextColor(colors.blue)
		write("> ")

		term.setTextColor(colors.white)
		local input = read()

		term.setTextColor(colors.yellow)

		local commandName, args = parseCommand(input)
		local command = commands[commandName]
		if command and has_value(command.permissions, "pc") then
			local success, result = pcall(command.action, "pc", args)
			if success then
				print(result)
				if command == commands.exit then
					break
				end
			else
				print("Error in command " .. (commandName or input) .. ": " .. result)
			end
		else
			print("Unknown command. Type 'list' to see available commands.")
		end

		term.setTextColor(colors.white)
		sleep(0)
	end
end

local function init()
	communication.init()
	print("Initialization complete.")
	if config.mode == "host" then
		parallel.waitForAny(terminalListener, communication.listen)
		while true do
			local event, senderId, message, protocol, time = os.pullEvent("rednet_message")
			if protocol == "farm_update" then
				local farmData = textutils.unserialize(message)
				farmData.lastUpdate = os.time(os.date("*t"))
				if farmData and farmData.id then
					farms.updateFarm(farmData.id, farmData)
				end
			elseif protocol == "discord_command" then
				local commandData = textutils.unserialize(message)
				if commandData and commandData.command then
					local success, result = pcall(commands[commandData.command].action, "discord", commandData.args)
					if success then
						communication.send(
							textutils.serialize({ type = "discord_response", id = commandData.id, response = result }),
							"discord_response"
						)
					else
						communication.send(
							textutils.serialize({
								type = "discord_response",
								id = commandData.id,
								response = "Error executing command: " .. result,
							}),
							"discord_response"
						)
					end
				end
			end
		end
	elseif config.mode == "farm" then
		for _, side in ipairs(sides) do
			redstone.setOutput(side, true)
		end
		while true do
			local table = {
				type = "farm",
				id = os.getComputerID(),
				name = os.getComputerLabel() or "Unnamed Farm",
				inventory = storage(),
			}
			communication.send(textutils.serialize(table), "farm_update")
			os.sleep(5)
		end
	elseif config.mode == "discord" then
		print("Starting in Discord mode")
		parallel.waitForAny(discord.runBot, communication.listen)
	else
		print("Invalid mode in config. Please set mode to 'host' or 'farm'.")
		return
	end
end

if shell then
	init()
else
	return init
end
