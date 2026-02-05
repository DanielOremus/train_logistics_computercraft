local Station = require("classes.Station")
local msgTypeEnum = require("constants.msgTypeEnum")

local ClientStation = {}
ClientStation.__index = ClientStation
setmetatable(ClientStation,Station)

function ClientStation.new(stationData)
    local instance = Station.new(stationData)
    setmetatable(instance, ClientStation)
    instance.serverId = stationData.serverId
    return instance
end

function ClientStation:init()
    Station.init(self)
    self:sendHandshake()
    self:displayMainMenu()
end

function ClientStation:displayMainMenu()
    local menuOptions = {
        {
            name = "Ride",
            func = function ()
                self:initRide()
            end
        }
    }
    local userAns = -1
    while not (type(userAns) == "number" and menuOptions[userAns]) do
        print(string.format("--- Main Menu (%s) ---\n", self.name))
        for i, option in ipairs(menuOptions) do
            print(string.format("%d. %s.", i, option.name))
        end
        write("\nChoose operation: ")
        userAns = tonumber(read())
    end
    menuOptions[userAns].func()
end

function ClientStation:initRide()
    
end

function ClientStation:getHandshakeTargetId()
    return self.serverId
end

function ClientStation:getHandshakeMsgType()
    return msgTypeEnum.HANDSHAKE_CLIENT_STATION
end

function ClientStation:buildHandshakePayload()
    return {
        id = self.id,
        name = self.name
    }
end

return ClientStation
