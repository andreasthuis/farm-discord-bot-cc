local args = { ... }
local user = "andreasthuis"
local repo = "farm-discord-bot-cc"
local branch = "main"

local passed_mode = args[1] 

local function downloadPath(path)
    local api_url = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s"):format(user, repo, path, branch)
    local raw_url = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(user, repo, branch)

    local response = http.get(api_url)
    if not response then
        print("Failed to access: " .. path)
        return
    end

    local items = textutils.unserializeJSON(response.readAll())
    response.close()

    for _, item in ipairs(items) do
        if item.type == "dir" then
            print("Creating directory: " .. item.path)
            fs.makeDir(item.path)
            downloadPath(item.path) 
        elseif item.type == "file" then
            if item.name ~= "config.lua" then
                print("Downloading: " .. item.path)
                local fResp = http.get(raw_url .. item.path)
                if fResp then
                    local f = fs.open(item.path, "w")
                    f.write(fResp.readAll())
                    f.close()
                    fResp.close()
                end
            end
        end
    end
end

print("Fetching files and folders...")
downloadPath("")

if not fs.exists("config.lua") then
    local final_mode = passed_mode or "farm"
    
    print("\nCreating config.lua with mode: " .. final_mode)
    local f = fs.open("config.lua", "w")
    f.write(('return { token = "Bot TOKEN", channel_id = "ID", auto_start = true, mode = "%s" }'):format(final_mode))
    f.close()
    print("Please edit config.lua with your credentials!")
elseif passed_mode then
    print("\nNote: config.lua already exists. The mode '" .. passed_mode .. "' was NOT applied to prevent overwriting.")
end

print("\nUpdate Complete!")