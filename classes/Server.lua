local operationsList = require("constants.operations")
local printHelpers = require("utils.printHelpers")
local tableHelpers = require("utils.tableHelpers")
local protocols = require("constants.protocols")
local schedules = require("constants.schedules")
local msgTypeEnum = require("constants.msgTypeEnum")
local groupByKey, printError, printInfo = tableHelpers.groupByKey, printHelpers.printError, printHelpers.printInfo

local Server = {}
Server.__index = Server

Server.messageHandlers = {
    [msgTypeEnum.ERROR] = function (self, sender, msg)
        printError(msg.err)
    end,
    [msgTypeEnum.HANDSHAKE_CLIENT_STATION] = function (self,station,msg)
        rednet.send(station, {
            type = msgTypeEnum.HANDSHAKE_RES,
            sender = string.format("Server (#%d)", self.id)
        })
    end
}

function Server.new(operations)
    local instance = setmetatable({}, Server)
    instance.id = os.getComputerID()
    instance.operations = operations
    instance.operationsGroup = groupByKey("key", operations)
    return instance
end

function Server:start()
    self:openRednet()
    local depots = { rednet.lookup(protocols.DEPOT_LOOKUP) }
    for _, id in pairs(depots) do
        rednet.send(id, {type="DISPATCH_TRAIN", schedule = schedules.trackSchedule})
    end

    parallel.waitForAny(
        function ()
            while true do
                local sender, msg = rednet.receive()
                if Server.messageHandlers[msg.type] then
                    Server.messageHandlers[msg.type](self, sender, msg)
                end
            end
        end
    )
    -- local operationId = self:askOperation()
    -- if operationId == self.operationsGroup.exit.id then
    --     return
    -- end

    -- print(string.format("Selected operation id is: %d", operationId))
end

function Server:openRednet()
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

function Server:askOperation()
    local opIndex = nil
    local isValid = false
    local result = nil
    while not isValid do
        print("-- Select number of operation --\n")
        for index, value in ipairs(self.operations) do
            print(string.format("%d. %s",index-1,value.name))
        end

        write("\nOperation: ")
        opIndex = tonumber(read())

        isValid, result = pcall(Server.validateOperationIndex, self, opIndex)
        if not isValid then
            printError(result)
        end
    end

    return self.operations[opIndex+1].id
end

function Server:validateOperationIndex(index)
    if type(index) ~= "number" then
        error("[ERROR] Argument must be a number!", 0)
    end
    if not self.operations[index+1] then
        error("[ERROR] Argument is out of range!", 0)
    end
end

return Server.new(operationsList)