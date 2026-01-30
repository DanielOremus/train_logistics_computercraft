local function groupByKey(keyName, list)
    local group = {}
    for _, value in ipairs(list) do
        group[value[keyName]] = value
    end
    return group
end

local function printError(text)
    term.setTextColor(colors.red)
    print("[ERROR] " .. text)
    term.setTextColor(colors.white)
end

local function printWarning(text)
    term.setTextColor(colors.orange)
    print("[WARN] " .. text)
    term.setTextColor(colors.white)
end

local function printInfo(text)
    term.setTextColor(colors.lightGray)
    print("[INFO] " .. text)
    term.setTextColor(colors.white)
end

local function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count +1
    end
    return count
end


return {groupByKey = groupByKey, printError = printError, printWarning = printWarning, tableLength = tableLength, printInfo = printInfo}