local scheduleStation = require("config.schedule_station")

local function getSchedule(number)
    return scheduleStation[number]
end

return getSchedule