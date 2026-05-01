local user = "andreasthuis"
local repo = "farm-discord-bot-cc"
local branch = "main"

local api_url = ("https://api.github.com/repos/%s/%s/contents?ref=%s"):format(user, repo, branch)
local raw_url = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(user, repo, branch)

print("Fetching file list from GitHub...")

local response = http.get(api_url)
if not response then
    error("Could not connect to GitHub API. Check your username/repo.")
end

local files = textutils.unserializeJSON(response.readAll())
response.close()

for _, file in ipairs(files) do
    if file.type == "file" and file.name:match("%.lua$") and file.name ~= "config.lua" then
        print("Downloading: " .. file.name)
        
        local fResp = http.get(raw_url .. file.name)
        if fResp then
            local f = fs.open(file.name, "w")
            f.write(fResp.readAll())
            f.close()
            fResp.close()
        else
            print("Failed to download " .. file.name)
        end
    end
end

if not fs.exists("config.lua") then
    print("\nCreating config.lua template...")
    local f = fs.open("config.lua", "w")
    f.write('return { token = "Bot TOKEN", channel_id = "ID" }')
    f.close()
    print("Please edit config.lua with your credentials!")
end

print("\nUpdate Complete!")