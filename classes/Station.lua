local printError = require("utils.helpers").printError
local printInfo = require("utils.helpers").printInfo

local stationConfig = require("config.station")

local Station = {}
Station.__index = Station

Station.messageHandlers = {
    TASK = function (self,sender,task)
        self:doTask(sender, task)
    end,
    HEARTBEAT = function (self,sender,msg)
        print("GOT hearbeat")
        rednet.send(sender, { type = "HEARTBEAT_RES" })
    end,
    HANDSHAKE_RES = function (self, server, msg)
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
    instance.produces = stationData.produces or {}
    instance.running = false
    instance.listening = false

    return instance
end

function Station:init()
    self:getStationBlock()
    self:setBlockName()
    self:openRednet()

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
                error(string.format("Cannot reach '%s' from '%s'!", stationName, self.name, self.id), 0)
            end
        end
    end
    self.block.setSchedule(schedule)
end

function Station:setBlockName()
    self.block.setStationName(self.name)
end

function Station:doTask(sender, task)
    print("Need to do a task!")
end

return Station