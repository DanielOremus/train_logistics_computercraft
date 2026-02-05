local printHelpers = require("utils.printHelpers")
local printError, printWarning, printInfo = printHelpers.printError, printHelpers.printWarning, printHelpers.printInfo
local msgTypeEnum = require("constants.msgTypeEnum")

local stationConfig = require("config.station")

local Station = {}
Station.__index = Station

Station.messageHandlers = {
    [msgTypeEnum.HEARTBEAT] = function (self,sender,msg)
        print("GOT hearbeat")
        rednet.send(sender, { type = "HEARTBEAT_RES" })
    end,
    [msgTypeEnum.HEARTBEAT_RES] = function (self, server, msg)
        printInfo(string.format("Connected to Server (#%d).", server))
        self.hasHandshake = true
    end
}

function Station.new(stationData)
    local instance = setmetatable({}, Station)
    instance.block = nil
    instance.id = os.getComputerID()
    instance.name = stationData.name
    instance.hasHandshake = false
    instance.listening = false

    return instance
end

function Station:openRednet()
    local modems = {}
    while #modems == 0 do
        modems = { peripheral.find("modem", function (name, modem)
            if modem.isWireless() then
                rednet.open(name)
                return true
            end
        end) }
        if #modems == 0 then
            printError("No modem connected! Waiting...")
            os.sleep(3)
        end
    end
    printInfo("Rednet opened on " .. #modems .. " modem(s).")
end

function Station:getStationBlock()
    local blocks = {}
    while #blocks == 0 do
        blocks = { peripheral.find("Create_Station") }
        if #blocks == 0 then
            printError("No station block found! Waiting...")
            os.sleep(3)
        end
        if #blocks > 1 then
            printError("Too many station blocks! Waiting...")
            os.sleep(3)
        end
    end
    printInfo("Station block found.")
    self.block = blocks[1]
    return blocks[1]
end

function Station:getTrainName()
    local present, result = pcall(self.block.getTrainName, self)
    if present then
        self.train = result
        return result
    end
    self.train = nil
    return nil
end


function Station:handleMessage(sender, msg)
    local handler = self.messageHandlers[msg.type]
    if handler then
        handler(self, sender, msg)
    end
end

function Station:setSchedule(schedule)
    for _, entry in pairs(schedule.entries) do
        if entry.instruction.id == "create:destination" then
            local stationName = entry.instruction.data.text
            local canReach = self.block.canTrainReach(stationName)
            if not canReach then
                error(string.format("Cannot reach '%s' from '%s'!", stationName, self.name), 0)
            end
        end
    end
    self.block.setSchedule(schedule)
end

function Station:setBlockName()
    self.block.setStationName(self.name)
end

function Station:init()
    self:getStationBlock()
    self:setBlockName()
    self:openRednet()
end

function Station:sendHandshake()
    local targetId = self:getHandshakeTargetId()
    local msgType = self:getHandshakeMsgType()
    local payload = self:buildHandshakePayload()

    self.listening = true

    local sender = nil
    local msg = {}
    while not (sender == targetId and msg.type == msgTypeEnum.HANDSHAKE_RES) do
        rednet.send(targetId, {
            type = msgType,
            payload = payload
        })

        sender, msg = rednet.receive(3)
        if not (sender == targetId and msg.type == msgTypeEnum.HANDSHAKE_RES) then
            printError("Handshake failed, retrying...")
        end
    end

    

    -- while self.listening do
    --     rednet.send(targetId, {
    --         type = msgType,
    --         payload = payload
    --     })

    --     local event, p1, p2 = os.pullEvent()
    --     if event == "rednet_message" then
    --         self:handleMessage(p1,p2)
    --     elseif event == "timer" and self.heartbeatTimer == p1 then
    --             self:sendHeartbeat()
    --             self:checkStations()
    --             self.heartbeatTimer = os.startTimer(Depot.heartbeatInterval)
    --     elseif event == "key" and p1 == keys.q then
    --         self.listening = false
    --         self:displayMainMenu()
    --     end
    -- end

    printInfo(string.format("'%s' connected to %s.", self.name, msg.sender))
end

function Station:getHandshakeTargetId()
    error("getHandshakeTargetId not implemented", 2)
end

function Station:getHandshakeMsgType()
    error("getHandshakeMsgType not implemented", 2)
end

function Station:buildHandshakePayload()
    error("buildHandshakePayload not implemented", 2)
end

function Station:displayMainMenu()
    print("Hello from station")
end

return Station