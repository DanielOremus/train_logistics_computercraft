local stations = require("config.station").stations


local trackSchedule = {
        cyclic = false, -- Does the schedule repeat itself after the end has been reached?
        entries = { -- List of entries, each entry contains a single instruction and multiple conditions.
            {
            instruction = {
                id = "create:destination", -- The different instructions are described below.
                data = { -- Data that is stored about the instruction. Different for each instruction type.
                text = stations.trackFactory.name,
                },
            },
            conditions = {    -- List of lists of conditions. The outer list is the "OR" list
                {               -- and the inner lists are "AND" lists.
                {
                    id = "create:delay", -- The different conditions are described below.
                    data = { -- Data that is stored about the condition. Different for each condition type.
                    value = 30,
                    time_unit = 1,
                    },
                },
                }
            },
            },
            {
            instruction = {
                id = "create:destination", -- The different instructions are described below.
                data = { -- Data that is stored about the instruction. Different for each instruction type.
                text = stations.mainStation.name,
                },
            },
            conditions = {    -- List of lists of conditions. The outer list is the "OR" list
                {               -- and the inner lists are "AND" lists.
                {
                    id = "create:delay", -- The different conditions are described below.
                    data = { -- Data that is stored about the condition. Different for each condition type.
                    value = 5,
                    time_unit = 1,
                    },
                },
                }
            },
            },
        },
    }


return {trackSchedule = trackSchedule}