local Station = require("classes.Station")
local msgTypeEnum = require("constants.msgTypeEnum")

local FactoryStation = {}
FactoryStation.__index = FactoryStation
setmetatable(FactoryStation, Station)

FactoryStation.handshakeType = "REGISTER_FACTORY_STATION"

function FactoryStation.new(stationData)
    local instance = Station.new(stationData)
    setmetatable(instance, FactoryStation)
    instance.produces = stationData.produces
    instance.serverId = stationData.serverId
    return instance
end

function FactoryStation:init()
    Station.init(self)
    self:sendHandshake()
    -- self:listenServer()
end

-- function FactoryStation:displayMainMenu()
--     print("Hello from factory")
-- end

function FactoryStation:getHandshakeTargetId()
    return self.serverId
end

function FactoryStation:getHandshakeMsgType()
    return msgTypeEnum.HANDSHAKE_FACTORY_STATION
end

function FactoryStation:buildHandshakePayload()
    return {
        id = self.id,
        name = self.name,
        produces = self.produces
    }
end

return FactoryStation