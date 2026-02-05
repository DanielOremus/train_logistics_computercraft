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

return {printInfo = printInfo, printWarning = printWarning, printError = printError}