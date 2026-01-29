local Task = {}
Task.__index = Task

function Task.new(requestType, stationName, provide, request)
    local instance = setmetatable({}, Task)
    instance.type = requestType
    instance.station = stationName
    instance.provide = provide
    instance.request = request
    return instance
end

-- function Task.getRequestFromProvide(provide)
--     local request = {}
--     for key, value in pairs(provide) do
--         if value <= 0 then
--             error(string.format("'%d' count must be positive, given '%d'", key,value))
--         end
--         if key=="iron_plate" then
--             request.iron_ingot = value
--         end
--     end

--     return request

-- end

return Task
