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
local number_of_parallels = 16

-- Tier 1
tiers[1] = {
    { name = "Water", amount = 1000, type = "fluid", parallel = true },
    { name = "Activated Carbon Filter Mesh", amount = 1, type = "item" },
}

-- Tier 2
tiers[2] = {
    { name = "Filtered Water (Grade 1)", amount = 1000, type = "fluid", parallel = true },
    { name = "Ozone", amount = 1024000, type = "fluid" },
}

-- Tier 3
tiers[3] = {
    { name = "Ozonated Water (Grade 2)", amount = 1000, type = "fluid", parallel = true },
    { name = "Polyaluminium Chloride", amount = 1000000, type = "fluid" },
}

-- Tier 4
tiers[4] = {
    { name = "Flocculated Water (Grade 3)", amount = 1000, type = "fluid", parallel = true },
    { name = "BLOCKER", amount = 1, type = "item" },
}

-- Tier 5
tiers[5] = {
    { name = "pH Neutralized Water (Grade 4)", amount = 1000, type = "fluid", parallel = true },
}

-- Tier 6
tiers[6] = {
    { name = "Extreme-Temperature Treated Water (Grade 5)", amount = 1000, type = "fluid", parallel = true },
}

-- Tier 7
tiers[7] = {
    { name = "Ultraviolet Treated Electrically Neutral Water (Grade 6)", amount = 1000, type = "fluid", parallel = true },
}

-- Tier 8
tiers[8] = {
    { name = "Degassed Decontaminant-Free Water (Grade 7)", amount = 1000, type = "fluid", parallel = true },
}


-- Adjust amounts for parallel processing
for tier, requirements in pairs(tiers) do
    for _, req in ipairs(requirements) do
        if req.parallel then
            req.amount = req.amount * number_of_parallels
        end
    end
end

return tiers
