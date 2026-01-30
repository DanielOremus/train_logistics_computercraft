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

rednet.open("top")
rednet.host("REPO", "repo_network")
print("[INFO] Resource computer started!")

while true do
    local _, sender, msg = os.pullEvent("rednet_message")
    if msg.type == "GET_FILE" then
        sendFile(sender, msg)
    end
end

