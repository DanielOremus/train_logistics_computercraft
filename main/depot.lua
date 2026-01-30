package.path = "../?.lua"

local Depot = require("classes.Depot")

write("Enter depot's name: ")
local depotName = read()
write("Enter sever computer's id: ")
local serverId = tonumber(read())

local depot = Depot.new(depotName, serverId)

depot:init()

