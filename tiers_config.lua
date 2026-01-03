-- Waterline Tier Requirements Configuration
-- Define the items/fluids required for each tier to activate
--
-- Format for each tier:
-- [tier_number] = {
--     { name = "Item or Fluid Name", amount = required_quantity, type = "item" or "fluid" },
--     ...
-- }
--
-- The tier will activate (redstone output 15) when ALL items/fluids meet their required amounts.
-- Use the exact label name as shown in AE2.

local tiers = {}

-- Tier 1: Basic Water Processing
tiers[1] = {
    { name = "Water", amount = 10000, type = "fluid" },
}

-- Tier 2: Grade 1 Processing
tiers[2] = {
    { name = "Filtered Water (Grade 1)", amount = 5000, type = "fluid" },
    { name = "Ozone", amount = 1000, type = "fluid" },
}

-- Tier 3: Grade 2 Processing
tiers[3] = {
    { name = "Filtered Water (Grade 2)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

-- Tier 4: Grade 3 Processing
tiers[4] = {
    { name = "Filtered Water (Grade 3)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

-- Tier 5: Grade 4 Processing
tiers[5] = {
    { name = "Filtered Water (Grade 4)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

-- Tier 6: Grade 5 Processing
tiers[6] = {
    { name = "Filtered Water (Grade 5)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

-- Tier 7: Grade 6 Processing
tiers[7] = {
    { name = "Filtered Water (Grade 6)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

-- Tier 8: Final Processing
tiers[8] = {
    { name = "Filtered Water (Grade 7)", amount = 5000, type = "fluid" },
    -- Add more requirements here
}

return tiers
