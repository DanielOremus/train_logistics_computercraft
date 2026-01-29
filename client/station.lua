package.path = "../?.lua"

local Station = require("classes.Station")

write("Enter station's name: ")
local stationName = read()

local station = Station.new({name = stationName, produces = {}})

station:init()