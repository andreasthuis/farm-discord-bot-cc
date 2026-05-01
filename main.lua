-- startup.lua
local discord = loadfile("discord.lua")()

print("Andreas' Farm System initializing...")

local function terminalListener()
    while true do
        term.setTextColor(colors.blue)
        write("> ")
        
        term.setTextColor(colors.white)
        local input = read()
        
        term.setTextColor(colors.lime)
        
        if input == "status" then
            print("Farm status: All systems operational.")
        elseif input == "exit" then
            term.setTextColor(colors.red)
            print("Exiting program.")
            term.setTextColor(colors.white)
            return 
        elseif input ~= "" then
            print("Unknown command: " .. input)
        end
        
        term.setTextColor(colors.white)
    end
end
print("Initialization complete.")
parallel.waitForAny(discord.runBot, terminalListener)