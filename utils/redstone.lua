local link = {}

local function isValidSide(side)
    for _, s in ipairs(redstone.getSides()) do
        if s == side then return true end
    end
    return false
end

function link.getSide()
    local sides = redstone.getSides()
    local side = sides[1]
    return side
end

function link.setSignal(side, value)
    if not isValidSide(side) then
        error("Invalid side: " .. tostring(side))
    end
    redstone.setOutput(side, value)
end

return link