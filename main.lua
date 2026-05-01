print("Andreas' Farm System initializing...")

local discord = loadfile("discord.lua")()

parallel.waitForAny(discord.init)

print("Initialization complete. Starting main loop...")

function listenForCommand()
    local input = read()
    if input == "status" then
        print("Farm status: All systems operational.")
    elseif input == "exit" then
        print("Exiting program.")
        os.exit()
    else
        print("Unknown command: " .. input)
    end
end

while true do
    listenForCommand()
end