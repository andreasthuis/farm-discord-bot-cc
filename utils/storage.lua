local vault = peripheral.find("inventory")

if not vault then
    term.setTextColor(colors.red)
    print("Error: No Vault (or inventory) connected!")
    term.setTextColor(colors.white)
    return
end

local function getVaultContents()
    local contents = {}
    local rawItems = vault.list()

    for slot, item in pairs(rawItems) do
        if contents[item.name] then
            contents[item.name] = contents[item.name] + item.count
        else
            contents[item.name] = item.count
        end
    end
    
    return contents
end

local myItems = getVaultContents()

term.clear()
term.setCursorPos(1,1)

term.setTextColor(colors.yellow)
print("Vault Contents:")
term.setTextColor(colors.gray)
print("--------------------------------")

for name, count in pairs(myItems) do
    local shortName = name:match(":(.+)") or name
    
    term.setTextColor(colors.lightBlue)
    write(string.format("%-18s ", shortName))
    
    term.setTextColor(colors.gray)
    write(": ")
    
    if count < 64 then
        term.setTextColor(colors.orange)
    else
        term.setTextColor(colors.green)
    end
    print(count)
end

term.setTextColor(colors.white)

return myItems