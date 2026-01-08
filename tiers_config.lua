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

-- Minimum water amounts for each tier's output fluid
-- If a tier's output is below its minimum, the controller will prioritize running that tier
-- (starting from lowest tiers first) instead of running the highest available tier.
-- Set to 0 or nil to disable minimum checking for that tier.
local minimums = {
    -- [tier_number] = { name = "Output Fluid Name", amount = minimum_amount }
    [1] = { name = "Filtered Water (Grade 1)", amount = 1000000 },
    [2] = { name = "Ozonated Water (Grade 2)", amount = 1000000 },
    [3] = { name = "Flocculated Water (Grade 3)", amount = 100000 },
    [4] = { name = "pH Neutralized Water (Grade 4)", amount = 100000 },
    [5] = { name = "Extreme-Temperature Treated Water (Grade 5)", amount = 0 },
    [6] = { name = "Ultraviolet Treated Electrically Neutral Water (Grade 6)", amount = 0 },
    [7] = { name = "Degassed Decontaminant-Free Water (Grade 7)", amount = 0 },
    [8] = { name = "Subatomically Perfect Water (Grade 8)", amount = 0 },
}

-- Tier 1
tiers[1] = {
    { name = "Water", amount = 16000, type = "fluid" },
    { name = "Activated Carbon Filter Mesh", amount = 1, type = "item" },
}

-- Tier 2
tiers[2] = {
    { name = "Filtered Water (Grade 1)", amount = 16000, type = "fluid" },
    { name = "Ozone", amount = 1024000, type = "fluid" },
}

-- Tier 3
tiers[3] = {
    { name = "Ozonated Water (Grade 2)", amount = 4000, type = "fluid" },
    { name = "Polyaluminium Chloride", amount = 900000, type = "fluid" },
}

-- Tier 4
tiers[4] = {
    { name = "Flocculated Water (Grade 3)", amount = 4000, type = "fluid" },
    { name = "Hydrochloric Acid", amount = 2500, type = "fluid" },
    { name = "Sodium Hydroxide Dust", amount = 250, type = "item" },
}

-- Tier 5
tiers[5] = {
    { name = "pH Neutralized Water (Grade 4)", amount = 1000, type = "fluid" },
    { name = "BLOCKER", amount = 1, type = "item" },
}

-- Tier 6
tiers[6] = {
    { name = "Extreme-Temperature Treated Water (Grade 5)", amount = 1000, type = "fluid" },
}

-- Tier 7
tiers[7] = {
    { name = "Ultraviolet Treated Electrically Neutral Water (Grade 6)", amount = 1000, type = "fluid" },
}

-- Tier 8
tiers[8] = {
    { name = "Degassed Decontaminant-Free Water (Grade 7)", amount = 1000, type = "fluid" },
}


return {
    requirements = tiers,
    minimums = minimums,
}
