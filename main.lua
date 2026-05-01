-- startup.lua
local discord = loadfile("discord.lua")()

print("Andreas' Farm System initializing...")

local function terminalListener()
    while true do
        write("> ")
        local input = read()
        if input == "status" then
            print("Farm status: All systems operational.")
        elseif input == "exit" then
            print("Exiting program.")
            return
        else
            print("Unknown command: " .. input)
        end
    end
end

print("Initialization complete.")
parallel.waitForAny(discord.runBot, terminalListener)