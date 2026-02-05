local Station = require("classes.Station")
local printHelpers = require("utils.printHelpers")
local printError, printWarning, printInfo = printHelpers.printError, printHelpers.printWarning, printHelpers.printInfo
local msgTypeEnum = require("constants.msgTypeEnum")

local DepotStation = {}
DepotStation.__index = DepotStation
setmetatable(DepotStation, Station)

DepotStation.messageHandlers = {
    [msgTypeEnum.HEARTBEAT] = function (self, depot, msg)
        self:getTrainName()
        rednet.send(depot, { type = msgTypeEnum.HEARTBEAT_RES, station = {
            name = self.name,
            train = self.train
        }})
    end,
    [msgTypeEnum.HEARTBEAT_RES] = function (self, depot, msg)
        printInfo(string.format("Connected to Depot (#%d).", depot))
        self.hasHandshake = true
    end,
    [msgTypeEnum.DISPATCH_TRAIN] = function (self, depot, msg)
        local schedule = msg.schedule
        local train = self:getTrainName()
        --Making a new presence check (train) for sure
        if not train then
            rednet.send(depot, {type = msgTypeEnum.ERROR, target = "SERVER", err = string.format("No train at '%s' (#%d)", self.name, self.id)})
            return
        end
        local success, err = pcall(self.setSchedule, self, schedule)
        if not success then
            rednet.send(depot, {type = msgTypeEnum.ERROR, target = "SERVER", err = err})
        else
            printInfo("Train '" .. train .. "' dispatched!")
        end
    end
}

function DepotStation.new(stationData)
    local instance = Station.new(stationData)
    setmetatable(instance, DepotStation)
    instance.depotId = stationData.depotId
    return instance
end

function DepotStation:init()
    printInfo(self.name)
    Station.init(self)
    self:getTrainName()
    self:sendHandshake()
    -- self:displayMainMenu()
    -- self:listenDepot()
end

function DepotStation:listenDepot()
    self.listening = true

    while self.listening do
        local event, p1, p2 = os.pullEvent()
        if event == "rednet_message" then
            local sender, msg = p1, p2
            self:handleMessage(sender, msg)
        elseif event == "key" and p1 == keys.q then
            self.listening = false
            self:displayMainMenu()
        end
    end
end

function DepotStation:getHandshakeTargetId()
    return self.depotId
end

function DepotStation:getHandshakeMsgType()
    return msgTypeEnum.HANDSHAKE_DEPOT_STATION
end

function DepotStation:buildHandshakePayload()
    return {
        id = self.id,
        name = self.name,
        train = self.train
    }
end

function DepotStation:displayMainMenu()
    
end

return DepotStation