local discord = loadfile("discord.lua")()
local commands = loadfile("commands.lua")()

print("Andreas' Farm System initializing...")

local function terminalListener()
    while true do
        term.setTextColor(colors.blue)
        write("> ")
        
        term.setTextColor(colors.white)
        local input = read()
        
        term.setTextColor(colors.yellow)
        
        local command = commands[input]
        if command and table.contains(command.permissions, "pc") then
            local result = command.action()
            print(result)
        else
            print("Unknown command. Type 'list' to see available commands.")
        end
        
        term.setTextColor(colors.white)
    end
end
print("Initialization complete.")
parallel.waitForAny(discord.runBot, terminalListener)