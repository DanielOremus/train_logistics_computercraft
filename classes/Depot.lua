local stationConfig = require("config.station")
local printHelpers = require("utils.printHelpers")
local printError, printWarning, printInfo = printHelpers.printError, printHelpers.printWarning, printHelpers.printInfo
local msgTypeEnum = require("constants.msgTypeEnum")

local protocols = require("constants.protocols")


--TODO: add main menu for operating with depot
--TODO: make stations update feature, for adding or removing stations
--TODO: refactor copy/paste class methods (make them reusable)
--TODO: add main menu for stations

local Depot = {}
Depot.__index = Depot
Depot.heartbeatInterval = 5
Depot.stationOfflineTimeout = Depot.heartbeatInterval * 2 + 2

Depot.messageHandlers = {
    [msgTypeEnum.PING] = function (self, sender, msg)
        rednet.send(sender, {type = msgTypeEnum.PONG})
    end,
    [msgTypeEnum.HEARTBEAT_RES] = function (self, stationId, msg)
        self.stations[stationId].status = stationConfig.statuses.ONLINE
        self.stations[stationId].train = msg.station.train
        self.stations[stationId].name = msg.station.name
        self.stations[stationId].lastSeen = os.clock()

    end,
    [msgTypeEnum.DISPATCH_TRAIN] = function (self, server, msg)
        print("Got train request")
        local stationId
        for id, station in pairs(self.stations) do
            if station.train then
                stationId = id
                break
            end
        end
        if not stationId then
            rednet.send(server, {type = msgTypeEnum.ERROR, err = "No trains are available!"})
        else
            rednet.send(stationId, {type = msgTypeEnum.DISPATCH_TRAIN, schedule = msg.schedule})
        end
    end,
    [msgTypeEnum.ERROR] = function (self, station, msg)
        local targets = {
            DEPOT = function ()
                printError(msg.err)
            end,
            SERVER = function ()
                rednet.send(self.serverId, {type = msgTypeEnum.ERROR, err = msg.err})
            end
        }
        targets[msg.target]()
    end,
    [msgTypeEnum.HANDSHAKE_DEPOT_STATION] = function (self, stationId, msg)
        local station = self:prepareStation(msg.payload)
        self:addStation(station)
        rednet.send(stationId, {type = msgTypeEnum.HANDSHAKE_RES, sender = string.format("Depot '%s' (#%d)", self.name, self.id) })
        printInfo(string.format("Station '%s' (#%d) registered.", station.name, station.id))
    end
}

function Depot.new(name, serverId)
    local instance = setmetatable({}, Depot)
    instance.id = os.getComputerID()
    instance.serverId = serverId
    instance.name = name
    instance.stations = {}
    instance.listening = false
    return instance
end

function Depot:init()
    self:openRednet()
    rednet.host(protocols.DEPOT_LOOKUP, string.format("depot_%d", os.clock()))
    self:displayMainMenu()
end

function Depot:displayMainMenu()
    term.clear()
    term.setCursorPos(1,1)
    print("-- Choose operation --\n")
    local options = {
        {
            title = "Start Listen", func = function () self:listenEvents() end
        }, 
        {
            title = "Shut Down", func = function () print("See you soon :)") end
        }
    }
    for i, value in ipairs(options) do
        print(string.format("%d. %s", i, value.title))
    end
    --TODO: add validation
    write("> ")
    local operation = tonumber(read())
    options[operation].func()
end

function Depot:addStation(stationObj)
    self.stations[stationObj.id] = stationObj
end

function Depot:prepareStation(stationObj)
    --Add extra fields to station object
    local save = {}
        for key, value in pairs(stationObj) do
            save[key] = value
        end
        save.status = stationConfig.statuses.ONLINE
        save.lastSeen = os.clock()
    return save
end

function Depot:openRednet()
    local modems = {}
    while #modems == 0 do
        modems = { peripheral.find("modem", function (name, modem)
            if modem.isWireless() then
                rednet.open(name)
                return true
            end
        end) }
        if #modems == 0 then
            printError("No wireless modem connected! Waiting...")
            os.sleep(3)
        end
    end
    printInfo("Rednet opened on " .. #modems .. " modem(s).")
end

function Depot:handleMessage(sender, msg)
    local handler = Depot.messageHandlers[msg.type]
    if handler then
        handler(self, sender, msg)
    end
end

function Depot:sendHeartbeat()
    --Sending heartbeat to all connected stations
    for _, station in pairs(self.stations) do
        rednet.send(station.id, { type = msgTypeEnum.HEARTBEAT })
    end
end

function Depot:checkStations()
    --Change station status if it's not responding
    local now = os.clock()
    for _, station in pairs(self.stations) do
        if station.status == stationConfig.statuses.ONLINE and now - station.lastSeen > Depot.stationOfflineTimeout then
            printWarning(string.format("Station '%s' (#%d) not responding, changing status to %s", station.name, station.id, stationConfig.statuses.OFFLINE))
            station.status = stationConfig.statuses.OFFLINE
        end
    end
end

function Depot:listenEvents()
    self.listening = true
    self.heartbeatTimer = os.startTimer(Depot.heartbeatInterval)

    while self.listening do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "rednet_message" then
            self:handleMessage(p1,p2)
        elseif event == "timer" and self.heartbeatTimer == p1 then
                self:sendHeartbeat()
                self:checkStations()
                self.heartbeatTimer = os.startTimer(Depot.heartbeatInterval)
        elseif event == "key" and p1 == keys.q then
            self.listening = false
            self:displayMainMenu()
        end
    end
end

return Depot