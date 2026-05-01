local config = loadfile("config.lua")()

local token = config.token

local bot_token = "Bot ".. token
local channel_id = config.channel_id
local last_message_id = ""

local function sendEmbed(title, description, reply_to_id)
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
    
    local payload = {
        embeds = {
            {
                title = title,
                description = description,
                color = 0x00FF00
            }
        }
    }

    if reply_to_id then
        payload.message_reference = {
            message_id = reply_to_id
        }
    end

    local response = http.post(
        url,
        textutils.serializeJSON(payload),
        {
            ["Authorization"] = bot_token,
            ["Content-Type"] = "application/json"
        }
    )

    if response then
        print("Sent embed: " .. title)
        response.close()
    else
        print("Failed to send embed.")
    end
end

local function sendMessage(content, reply_to_id)
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages"
    
    local payload = {
        content = content
    }

    if reply_to_id then
        payload.message_reference = {
            message_id = reply_to_id
        }
    end

    local response = http.post(
        url,
        textutils.serializeJSON(payload),
        {
            ["Authorization"] = bot_token,
            ["Content-Type"] = "application/json"
        }
    )

    if response then
        print("Sent reply: " .. content)
        response.close()
    else
        print("Failed to send reply.")
    end
end

local function getLatestMessage()
    local url = "https://discord.com/api/v10/channels/" .. channel_id .. "/messages?limit=1"
    
    local response = http.get(url, {["Authorization"] = bot_token})
    
    if response then
        local data = textutils.unserializeJSON(response.readAll())
        response.close()
        
        if data and data[1] then
            local msg = data[1]
            -- Only return if its a NEW message and not from a bot
            if msg.id ~= last_message_id and not msg.author.bot then
                last_message_id = msg.id
                return msg.author.username, msg.content, msg.id
            end
        end
    end
    return nil
end

print("Polling Discord for commands...")

while true do
    local user, text, id = getLatestMessage()
    
    if user then
        print("[" .. user .. "]: " .. text)
        
        if text == "!ping" then
            sendMessage("pong!", id)
        end
        if text == "!embed" then
            sendEmbed("Hello!", "This is an embed message.", id)
        end
    end
    sleep(3) 
end