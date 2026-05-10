local farms = {}
local filePath = "data/farms.lua"

local list = {}
if fs.exists(filePath) then
    list = loadfile(filePath)() or {}
end

function farms.save()
    local f = fs.open(filePath, "w")
    f.write("return " .. textutils.serialize(list))
    f.close()
end

function farms.updateFarm(id, data)
    list[id] = data
    farms.save()
end

function farms.getFarms()
    return list
end

function farms.networkListener()
    while true do
        local event, senderId, message, protocol, time = os.pullEvent("rednet_message")
        if protocol == "farm_update" then
            local farmData = textutils.unserialize(message)
            farmData.lastUpdate = time
            if farmData and farmData.id then
                farms.updateFarm(farmData.id, farmData)
            end
        end
    end
end

return farms