package.path = "../?.lua"

local ClientStation = require("classes.ClientStation")

write("Enter station's name: ")
local stationName = read()

write("Enter server's id: ")
local serverId = tonumber(read())

local control = ClientStation.new({name = stationName, serverId = serverId})
control:init()