local function groupByKey(keyName, list)
    local group = {}
    for _, value in ipairs(list) do
        group[value[keyName]] = value
    end
    return group
end

local function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count +1
    end
    return count
end


return {groupByKey = groupByKey, tableLength = tableLength}