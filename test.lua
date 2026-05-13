local config = loadfile("config.lua")()
local bot_token = config.token
local gateway_url = "wss://gateway.discord.gg/?v=10&encoding=json"

local function runBot()
    print("Connecting to Discord Gateway...")
    
    local ws, err = http.websocket(gateway_url)
    
    if not ws then
        print("Failed to connect: " .. tostring(err))
        return
    end

    print("Connected! Handshaking...")

    while true do
        local event, url, msg = os.pullEvent()
        
        if event == "websocket_message" then
            local data = textutils.unserializeJSON(msg)
            
            if data.op == 10 then
                local heartbeat_interval = data.d.heartbeat_interval / 1000
                
                ws.send(textutils.serializeJSON({
                    op = 2,
                    d = {
                        token = bot_token,
                        intents = 513,
                        properties = {
                            os = "linux",
                            browser = "computercraft",
                            device = "computercraft"
                        }
                    }
                }))

                os.startTimer(heartbeat_interval)
                print("Bot is now ONLINE (Green Dot active).")

            elseif data.op == 1 or event == "timer" then
                ws.send(textutils.serializeJSON({
                    op = 1,
                    d = JSONObject
                }))
                os.startTimer(heartbeat_interval or 30)
            end
        
        elseif event == "websocket_closed" then
            print("Connection lost. Retrying...")
            return runBot()
        end
    end
end

runBot()