local discord
local function getDiscord()
    discord = discord or loadfile("discord.lua")()
    return discord
end

local function concatTable(t, sep)
    local result = ""
    for i, v in ipairs(t) do
        result = result .. v
        if i < #t then result = result .. sep end
    end
    return result
end

local commands = {
    status = {
        description = "Check the status of the farm system.",
        permissions = {"pc", "discord"},
        action = function()
            return "Farm status: All systems operational."
        end
    },
    logs = {
        description = "View recent logs from the Discord bot.",
        permissions = {"pc", "discord"},
        action = function()
            local logs = getDiscord().getLogs()
            if #logs == 0 then
                return "No logs available."
            else
                local logMessages = {"Recent Logs:"}
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
        end
    },
    exit = {
        description = "Exit the program.",
        permissions = {"pc"},
        action = function()
            return "Exiting program."
        end
    },
    ping = {
        description = "Check if the bot is responsive.",
        permissions = {"discord"},
        action = function()
            return "Pong! The bot is responsive."
        end
    },
    list = {
        description = "List all available commands.",
        permissions = {"pc", "discord"},
        action = function()
            local commandList = {"Available Commands:"}
            for cmd, info in pairs(commands) do
                table.insert(commandList, string.format("%s: %s available on %s", cmd, info.description, concatTable(info.permissions, ", ")))
            end
            sleep(0)
            return concatTable(commandList, "\n")
        end
    }
}

return commands