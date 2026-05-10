local discord = loadfile("utils/discord.lua")()
local commands = loadfile("data/commands.lua")()
local config = loadfile("config.lua")()
local communication = loadfile("utils/communication.lua")()
local farms = loadfile("data/farms.lua")()
local storage = loadfile("utils/storage.lua")

print("Andreas' Farm System initializing...")

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local function terminalListener()
	while true do
		term.setTextColor(colors.blue)
		write("> ")

		term.setTextColor(colors.white)
		local input = read()

		term.setTextColor(colors.yellow)

		local command = commands[input]
		if command and has_value(command.permissions, "pc") then
			local result = command.action("pc")
			print(result)
			if command == commands.exit then
				break
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
		print("listening for farm connections...")
		parallel.waitForAny(discord.runBot, terminalListener, communication.listen)
	elseif config.mode == "farm" then
		while true do
			local inventory = storage()
			communication.send(inventory)
			os.sleep(1)
		end
	else
		print("Invalid mode in config. Please set mode to 'host' or 'farm'.")
		return
	end
end

init()
return init