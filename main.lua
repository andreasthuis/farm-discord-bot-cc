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
        elseif input == "logs" then
            local logs = discord.getLogs()
            if #logs == 0 then
                print("No logs available.")
            else
                print("Recent Logs:")
                for i = math.max(1, #logs - 9), #logs do
                    local log = logs[i]
                    if log.type == "received" then
                        print(string.format("[RECEIVED] %s: %s", log.user, log.content))
                    elseif log.type == "message" then
                        print(string.format("[SENT] %s", log.content))
                    elseif log.type == "embed" then
                        print(string.format("[EMBED] %s: %s", log.title, log.description))
                    end
                end
            end
        elseif input ~= "" then
            print("Unknown command: " .. input)
        end
        
        term.setTextColor(colors.white)
    end
end
print("Initialization complete.")
parallel.waitForAny(discord.runBot, terminalListener)