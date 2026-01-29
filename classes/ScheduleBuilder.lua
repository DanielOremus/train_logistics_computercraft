local ScheduleBuilder = {}
ScheduleBuilder.__index = ScheduleBuilder

local example = {
    cyclic = false,
    stations = {
        {
            name = "station_name",
            conditions = {
                {

                }
            }
        }
    }
}

function ScheduleBuilder:build(task)
    
end

return ScheduleBuilder