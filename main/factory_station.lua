package.path = "../?.lua"

local FactoryStation = require("classes.FactoryStation")

write("Enter factory's name: ")
local stationName = read()

write("Enter server's id: ")
local serverId = tonumber(read())

--TODO: add feature to add products

local produces = {}

local factory = FactoryStation.new({name = stationName, serverId = serverId, produces = produces})

factory:init()