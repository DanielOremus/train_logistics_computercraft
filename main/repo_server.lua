local function sendFile(client, msg)
    local file = fs.open(msg.path, "r")
    local content = file.readAll()
    file.close()
    rednet.send(client, {
        type = "FILE",
        path = msg.path,
        content = content
    })
end

local function getFilesPaths(currentPath, paths)
    local result = paths or {}
    local list = fs.list(currentPath)
    for _, value in pairs(list) do
        local path = fs.combine(currentPath, value)
        if fs.isDir(path) then
            if fs.getName(path) ~= ".git" then
                getFilesPaths(path, result)
            end
        else
            table.insert(result, path)
        end
    end
    return result
end

rednet.open("top")
rednet.host("REPO", "repo_network")
print("[INFO] Resource computer started!")

while true do
    local _, sender, msg = os.pullEvent("rednet_message")
    if msg.type == "GET_FILE" then
        sendFile(sender, msg)
    end
    if msg.type == "GET_PATHS" then
        local paths = getFilesPaths(msg.repoName)
        rednet.send(sender, {type = "PATHS", paths = paths})
    end
end

