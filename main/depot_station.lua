package.path = "../?.lua"

local DepotStation = require("classes.DepotStation")

write("Enter depot's track name: ")
local stationName = read()

write("Enter depot's id: ")
local depotId = tonumber(read())

local depotStation = DepotStation.new({name = stationName, depotId = depotId})
depotStation:init()