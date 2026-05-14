local farms = {}
local filePath = "data/farms.lua"

local list = {}
if fs.exists(filePath) then
    list = loadfile(filePath)() or {}
    local currentTime = os.time(os.date("*t"))
    for id, farm in pairs(list) do
        if not farm.lastUpdate then
            farm.lastUpdate = currentTime - 86400
        end
    end
end

local lastSave = 0

function farms.save()
    local f = fs.open(filePath, "w")
    f.write("return " .. textutils.serialize(list))
    f.close()
end

function farms.updateFarm(id, data)
    local was_new = list[id] == nil
    list[id] = data
    if was_new or os.time(os.date("*t")) - lastSave > 60 then
        farms.save()
        lastSave = os.time(os.date("*t"))
    end
end

function farms.getFarms()
    return list
end

return farms