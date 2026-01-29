local Station = require("classes.Station")
local printError = require("utils.helpers").printError
local printInfo = require("utils.helpers").printInfo

local DepotStation = {}
DepotStation.__index = DepotStation
setmetatable(DepotStation, Station)

DepotStation.messageHandlers = {
    HEARTBEAT = function (self, depot, msg)
        self:getTrainName()
        rednet.send(depot, { type = "HEARTBEAT_RES", station = {
            train = self.train
        }})
    end,
    HANDSHAKE_RES = function (self, depot, msg)
        printInfo(string.format("Connected to Depot (#%d).", depot))
        self.hasHandshake = true
    end,
    DISPATCH_TRAIN = function (self, depot, msg)
        local schedule = msg.schedule
        local train = self:getTrainName()
        --Making a new presence check (train) for sure
        if not train then
            rednet.send(depot, {type = "DEPOT_ERROR", target = "SERVER", err = string.format("No train at '%s' (#%d)", self.name, self.id)})
            return
        end
        local success, err = pcall(self.setSchedule, self, schedule)
        if not success then
            rednet.send(depot, {type = "DEPOT_ERROR", target = "SERVER", err = err})
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
    self:getStationBlock()
    self:setBlockName()
    self:getTrainName()
    self:openRednet()
    self:sendHandshake()
    self:listenEvents()
    -- self:displayMainMenu()
end

function DepotStation:sendHandshake()
    rednet.send(self.depotId, { 
        type = "REGISTER_STATION",
        station = {
            id = self.id, 
            name = self.name, 
            listening = self.listening,
            train = self.train
        }
    })
end

function DepotStation:listenEvents()
    self.listening = true
    self.handshakeTimer = os.startTimer(5)

    while self.listening do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "rednet_message" then
            local sender, msg, protocol = p1, p2, p3
            self:handleMessage(sender, msg)
        elseif event == "timer" and p1 == self.handshakeTimer then
            if not self.hasHandshake then
                printError("No response from depot!")
                self:sendHandshake()
                self.handshakeTimer = os.startTimer(5)
            end
        elseif event == "key" and p1 == keys.q then
            self.listening = false
            self:displayMainMenu()
        end
    end
end

function DepotStation:displayMainMenu()
    
end

return DepotStation