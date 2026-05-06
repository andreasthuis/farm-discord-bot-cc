local main = loadfile("main.lua")()
local conf = loadfile("config.lua")()

local function mainFunc()
    local success, err = pcall(main)
    if not success then
        print("Error in main.lua: " .. err)
    end
end

if conf.auto_start then
    mainFunc()
else
    print("Auto-start is disabled. Please run main.lua manually.")
end