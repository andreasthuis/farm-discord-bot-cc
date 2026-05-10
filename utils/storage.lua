local vault = peripheral.find("inventory")

if not vault then
    print("Error: No Vault (or inventory) connected!")
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
print("Vault Contents:")
print("----------------")
for name, count in pairs(myItems) do
    local shortName = name:match(":(.+)") or name
    print(string.format("%-15s : %d", shortName, count))
end

return myItems