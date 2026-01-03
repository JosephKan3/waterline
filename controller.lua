-- Waterline Tier Controller
-- Monitors AE2 network and activates tier-based redstone controls
-- Control 0 activates with the highest active tier (1-8)
-- Usage: controller [debug]

local component = require("component")
local computer = require("computer")
local event = require("event")
local term = require("term")
local shell = require("shell")
local gpu = component.gpu
local filesystem = require("filesystem")

-- Parse arguments
local args = {...}
local DEBUG_MODE = args[1] == "debug"

-- Load configurations
local tiersConfig = require("tiers_config")
local redstoneConfig = require("redstone_config")
local ae2 = require("src.AE2")

-- Constants
local REDSTONE_ON = 15
local REDSTONE_OFF = 0
local CHECK_INTERVAL = DEBUG_MODE and 5 or (redstoneConfig.check_interval or 120)
local PULSE_DURATION = 1 -- seconds

-- State tracking
local tierStates = {} -- Current on/off state for each tier
local redstoneProxies = {} -- Cached redstone component proxies

-- Colors for display
local COLOR_GREEN = 0x00FF00
local COLOR_RED = 0xFF0000
local COLOR_YELLOW = 0xFFFF00
local COLOR_GRAY = 0x808080
local COLOR_WHITE = 0xFFFFFF
local COLOR_MAGENTA = 0xFF00FF

-- Initialize AE2 module
local function initAE2()
    local success, err = pcall(function()
        ae2.init(redstoneConfig.me_interface)
    end)
    if not success then
        print("ERROR: " .. tostring(err))
        return false
    end
    return true
end

-- Get or create redstone component proxy
local function getRedstoneProxy(address)
    if not address then return nil end

    if redstoneProxies[address] then
        return redstoneProxies[address]
    end

    local success, proxy = pcall(component.proxy, address)
    if success and proxy then
        redstoneProxies[address] = proxy
        return proxy
    end

    return nil
end

-- Set redstone output for a tier
local function setRedstoneOutput(tierNum, value)
    local tierConfig = redstoneConfig.tiers[tierNum]
    if not tierConfig then return false end

    local proxy = getRedstoneProxy(tierConfig.address)
    if not proxy then
        print(string.format("Warning: Could not access redstone for tier %d", tierNum))
        return false
    end

    local success, err = pcall(function()
        proxy.setOutput(tierConfig.side, value)
    end)

    if not success then
        print(string.format("Error setting redstone for tier %d: %s", tierNum, tostring(err)))
        return false
    end

    return true
end

-- Get real time from filesystem
local function getRealTime()
    local tempfile = "/tmp/waterline_timefile"
    local file = filesystem.open(tempfile, "a")
    if file then
        file:close()
        local timestamp = filesystem.lastModified(tempfile) / 1000
        filesystem.remove(tempfile)
        return timestamp
    else
        return os.time()
    end
end

-- Format time for display
local function getFormattedTime()
    local timestamp = getRealTime()
    local timetable = os.date("*t", timestamp)

    local hour = timetable.hour
    local min = timetable.min
    local sec = timetable.sec

    if min < 10 then min = "0" .. min end
    if sec < 10 then sec = "0" .. sec end

    return hour .. ":" .. min .. ":" .. sec
end

-- Print with color
local function printColored(text, color)
    local old = gpu.getForeground()
    if color then gpu.setForeground(color) end
    print(text)
    gpu.setForeground(old)
end

-- Print timestamped log
local function log(text, color)
    local old = gpu.getForeground()
    io.write("[" .. getFormattedTime() .. "] ")
    if color then gpu.setForeground(color) end
    print(text)
    gpu.setForeground(old)
end

-- Check a single tier's requirements
local function checkTier(tierNum)
    local requirements = tiersConfig[tierNum]
    if not requirements or #requirements == 0 then
        return false, nil
    end

    local allMet, results = ae2.checkTierRequirements(requirements)
    return allMet, results
end

-- Main check and update cycle
local function updateTiers()
    local highestActiveTier = 0
    local tierResults = {}

    -- Check each tier (1-8) to find the highest ready tier
    for tierNum = 1, 8 do
        local met, results = checkTier(tierNum)
        tierResults[tierNum] = {
            met = met,
            results = results
        }

        if met then
            highestActiveTier = tierNum
            tierStates[tierNum] = true
        else
            tierStates[tierNum] = false
        end
    end

    -- Update control 0 state
    tierStates[0] = highestActiveTier > 0

    -- Pulse redstone: only activate highest tier + tier 0
    if highestActiveTier > 0 then
        local tierConfig = redstoneConfig.tiers[highestActiveTier]
        local control0Config = redstoneConfig.tiers[0]

        -- Beep to indicate cycle trigger
        computer.beep(1000, 0.2)

        -- Turn ON highest tier and tier 0
        if tierConfig then
            setRedstoneOutput(highestActiveTier, REDSTONE_ON)
        end
        if control0Config then
            setRedstoneOutput(0, REDSTONE_ON)
        end

        -- Wait for pulse duration
        os.sleep(PULSE_DURATION)

        -- Turn OFF
        if tierConfig then
            setRedstoneOutput(highestActiveTier, REDSTONE_OFF)
        end
        if control0Config then
            setRedstoneOutput(0, REDSTONE_OFF)
        end
    end

    return highestActiveTier, tierResults
end

-- Display status
local function displayStatus(highestTier, tierResults)
    term.clear()
    term.setCursor(1, 1)

    local title = "=== Waterline Tier Controller ==="
    if DEBUG_MODE then
        title = "=== Waterline Tier Controller [DEBUG] ==="
    end
    printColored(title, COLOR_WHITE)
    print(string.format("Check Interval: %d seconds | Press Q to exit", CHECK_INTERVAL))
    print("")

    -- Control 0 status
    local ctrl0Status = tierStates[0] and "RUNNING" or "OFF"
    local ctrl0Color = tierStates[0] and COLOR_MAGENTA or COLOR_GRAY
    log(string.format("MAIN CONTROLLER: %s", ctrl0Status), ctrl0Color)
    print("")

    -- Display each tier
    for tierNum = 1, 8 do
        local tierConfig = redstoneConfig.tiers[tierNum]
        local result = tierResults[tierNum]

        if not tierConfig then
            log(string.format("Tier %d: Not configured", tierNum), COLOR_GRAY)
        elseif not result or not result.results then
            log(string.format("Tier %d: No requirements defined", tierNum), COLOR_GRAY)
        else
            local statusText
            local statusColor

            if tierNum == highestTier then
                -- This is the running tier
                statusText = "RUNNING"
                statusColor = COLOR_MAGENTA
            elseif result.met then
                -- Has inputs but not the highest tier
                statusText = "WAITING"
                statusColor = COLOR_GREEN
            else
                -- Missing inputs
                statusText = "UNAVAILABLE"
                statusColor = COLOR_GRAY
            end

            log(string.format("Tier %d: %s", tierNum, statusText), statusColor)

            -- Show individual requirements
            for _, req in ipairs(result.results) do
                local reqColor = req.met and COLOR_GREEN or COLOR_RED
                local currentStr = ae2.formatNumber(req.current)
                local requiredStr = ae2.formatNumber(req.required)
                local icon = req.met and "[OK]" or "[!!]"

                local old = gpu.getForeground()
                io.write("         ")
                gpu.setForeground(reqColor)
                io.write(icon .. " ")
                gpu.setForeground(COLOR_WHITE)
                print(string.format("%s: %s / %s (%s)",
                    req.name, currentStr, requiredStr, req.type))
                gpu.setForeground(old)
            end
        end
    end

    print("")
end

-- Display countdown on a single line (updates in place)
local function displayCountdown(seconds)
    local _, height = gpu.getResolution()
    term.setCursor(1, height)
    gpu.setForeground(COLOR_GRAY)
    term.clearLine()
    io.write(string.format("[%s] Next check in %d seconds... (Press Q to exit)", getFormattedTime(), seconds))
    gpu.setForeground(COLOR_WHITE)
end

-- Shutdown - turn off all redstone outputs
local function shutdown()
    print("\nShutting down...")
    for tierNum = 0, 8 do
        local tierConfig = redstoneConfig.tiers[tierNum]
        if tierConfig then
            setRedstoneOutput(tierNum, REDSTONE_OFF)
        end
    end
    print("All redstone outputs disabled.")
end

-- Main loop
local function main()
    term.clear()
    term.setCursor(1, 1)

    print("=== Waterline Tier Controller ===")
    print("Initializing...")

    -- Initialize AE2
    if not initAE2() then
        print("Failed to initialize AE2 module. Exiting.")
        return
    end
    print("AE2 connection established.")

    -- Validate redstone config
    local configuredTiers = 0
    for tierNum = 0, 8 do
        if redstoneConfig.tiers[tierNum] then
            configuredTiers = configuredTiers + 1
        end
    end
    print(string.format("Configured tiers: %d", configuredTiers))

    if configuredTiers == 0 then
        print("WARNING: No tiers configured! Run setup.lua first.")
    end

    os.sleep(2)

    -- Main loop
    while true do
        local highestTier, results
        local success, err = pcall(function()
            highestTier, results = updateTiers()
            displayStatus(highestTier, results)
        end)

        if not success then
            log("Error during update: " .. tostring(err), COLOR_RED)
        end

        -- Countdown loop
        for remaining = CHECK_INTERVAL, 1, -1 do
            displayCountdown(remaining)

            -- Wait 1 second or check for Q key
            local eventType, _, _, code = event.pull(1, "key_down")
            if eventType == "key_down" and code == 0x10 then -- Q key
                shutdown()
                term.clear()
                term.setCursor(1, 1)
                print("Waterline Tier Controller stopped.")
                return
            end
        end
    end
end

-- Run with error handling
local success, err = pcall(main)
if not success then
    print("Fatal error: " .. tostring(err))
    shutdown()
end
