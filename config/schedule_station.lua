local stationsConfig = require("config.stations")
local schedulesConfig = require("constants.schedules")


local config = {
    [stationsConfig.ironStation.id] = schedulesConfig.ironSchedule,
    [stationsConfig.woodStation.id] = schedulesConfig.woodSchedule
}

return config