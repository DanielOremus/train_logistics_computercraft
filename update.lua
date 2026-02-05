local UpdateManager = {}
UpdateManager.__index = UpdateManager
UpdateManager.repoName = "train_logistics"
UpdateManager.DEV_ID = nil

function UpdateManager.new()
    local instance = setmetatable({}, UpdateManager)
    instance.expected = 0
    instance.received = 0
    return instance
end

function UpdateManager:initUpdate()
    self:openRednet()
    UpdateManager.getDevId()
    self:getRepoFilesPaths()
    if not fs.exists(self.repoName) then
        fs.makeDir(self.repoName)
    end
    self:updateFiles()
    rednet.close()
end

function UpdateManager.getDevId()
    local devId = nil
    while not devId do
        devId = rednet.lookup("REPO", "repo_network")
        if not devId then
            print("[INFO] Resource computer must run!")
            os.sleep(3)
        end
    end
    UpdateManager.DEV_ID = devId
end

function UpdateManager:updateFiles()
    for _, filePath in pairs(self.paths) do
        self:sendFileRequest(filePath)
    end
    while self.received < self.expected do
        local _, sender, msg = os.pullEvent("rednet_message")
        if sender == self.DEV_ID and msg.type == "FILE" then
            self:onFileReceive(msg)
        end
    end
    print("[INFO] Files updated!")
end

function UpdateManager:getRepoFilesPaths()
    rednet.send(self.DEV_ID, {
        type = "GET_PATHS",
        repoName = self.repoName
    })
    local sender = nil
    local msg = {}
    while msg.type ~= "PATHS" or sender ~= self.DEV_ID do
        sender, msg = rednet.receive()
    end
    print("[INFO] Got repo structure!")
    self.paths = msg.paths or {}
    return msg.paths
end

function UpdateManager:onFileReceive(msg)
    fs.makeDir(fs.getDir(msg.path))
    local file = fs.open(msg.path, "w")
    file.write(msg.content)
    file.close()

    self.received = self.received + 1
end

function UpdateManager:sendFileRequest(path)
    self.expected = self.expected + 1
    rednet.send(self.DEV_ID, {
        type = "GET_FILE",
        path = path
    })
end

function UpdateManager:openRednet()
    local modems = {}
    while #modems == 0 do
        modems = { peripheral.find("modem", function (name, modem)
            if modem.isWireless() then
                rednet.open(name)
                return true
            end
        end) }
        if #modems == 0 then
            print("No wireless modem connected! Waiting...")
            os.sleep(3)
        end
    end
end

UpdateManager.new():initUpdate()