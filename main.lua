local discord = loadfile("discord.lua")()
local commands = loadfile("commands.lua")()

print("Andreas' Farm System initializing...")

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then return true end
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
            local result = command.action()
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

print("Initialization complete.")
parallel.waitForAll(discord.runBot, terminalListener)