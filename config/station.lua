local stations = {
        depotStation1 = {
            id = 0,
            name = "Depot Station 1",
            produces = {}
        },
        depotStation2 = {
            id = 0,
            name = "Depot Station 2",
            produces = {}
        },
        ironFactory = {
            id = 1,
            name = "Iron Factory",
            produces = {"minecraft:iron_ingot", "create:iron_sheet"}
        },
        trackFactory = {
            id = 2,
            name = "Track Factory",
            produces = {"create:track"}
        },    
        mainStation = {
            id = 2,
            name = "main",
            produces = {"create:track"}
        },   
}

local statuses = {
    OFFLINE = 0,
    ONLINE = 1,
}

return {stations = stations, statuses = statuses}