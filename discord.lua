-- discord.lua
local config = loadfile("config.lua")()
local bot_token = "Bot " .. config.token
local channel_id = config.channel_id
local last_message_id = ""

local logs = {}

local function sendEmbed(title, description, reply_to_id)
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
    local payload = {
        embeds = {{ title = title, description = description, color = 65280 }}
    }
    if reply_to_id then payload.message_reference = { message_id = reply_to_id } end

    local response = http.post(url, textutils.serializeJSON(payload), {
        ["Authorization"] = bot_token,
        ["Content-Type"] = "application/json",
    })
    if response then response.close() end
    logs[#logs + 1] = { type = "embed", title = title, description = description }
end

local function sendMessage(content, reply_to_id)
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
    local payload = { content = content }
    if reply_to_id then payload.message_reference = { message_id = reply_to_id } end

    local response = http.post(url, textutils.serializeJSON(payload), {
        ["Authorization"] = bot_token,
        ["Content-Type"] = "application/json",
    })
    if response then response.close() end
    logs[#logs + 1] = { type = "message", content = content }
end

local function getLatestMessage()
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages?limit=1"
    local response = http.get(url, { ["Authorization"] = bot_token })

    if response then
        local data = textutils.unserializeJSON(response.readAll())
        response.close()
        if data and data[1] then
            local msg = data[1]
            if msg.id ~= last_message_id and not (msg.author and msg.author.bot) then
                last_message_id = msg.id
                logs[#logs + 1] = { type = "received", user = msg.author.username, content = msg.content }
                return msg.author.username, msg.content, msg.id
            end
        end
    end
    return nil
end

local function runBot()
    while true do
        local user, text, id = getLatestMessage()
        if user then
            if text == "!ping" then
                sendMessage("pong!", id)
            elseif text == "!status" then
                sendEmbed("Farm Status", "All systems operational. (Checked via Discord)", id)
            end
        end
        sleep(2)
    end
end

local function getLogs()
    return logs
end

return {
    runBot = runBot,
    sendEmbed = sendEmbed,
    sendMessage = sendMessage,
    getLogs = getLogs,
}