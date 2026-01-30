package.path = "../?.lua"

local DepotStation = require("classes.DepotStation")

write("Enter station's name: ")
local stationName = read()

write("Enter depot's computer ID: ")
local depotId = tonumber(read())
local depotStation = DepotStation.new({name = stationName, depotId = depotId})

depotStation:init()