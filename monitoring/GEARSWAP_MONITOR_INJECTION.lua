---============================================================================
--- FFXI GearSwap Core Module - Direct Monitoring Injection System
---============================================================================
--- Advanced monitoring system that injects performance tracking directly
--- into GearSwap job functions. Provides accurate scope-aware monitoring
--- with direct access to GearSwap operations and internal state.
---
--- @file core/gearswap_monitor_injection.lua
--- @author Tetsouo
--- @version 2.2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-09
--- @requires core/performance_monitor.lua
--- @requires Windower FFXI, GearSwap addon
---
--- Features:
---   - Direct injection into GearSwap job function contexts
---   - Accurate scope-aware performance monitoring
---   - Real-time GearSwap operation tracking
---   - Internal state access for comprehensive analysis
---   - Minimal overhead injection system
---
--- @usage
---   local monitor = require('core/GEARSWAP_MONITOR_INJECTION')
---   monitor.inject_job_monitoring(job_file)
---============================================================================

--- @class GearSwapMonitor Direct GearSwap monitoring injection system
local GearSwapMonitor = {}

-- Load the monitoring system
local success_PerfMon, PerfMon = pcall(require, 'performance/PERFORMANCE_MONITOR')
if not success_PerfMon then
    error("Failed to load performance/performance_monitor: " .. tostring(PerfMon))
end

---============================================================================
--- MONITORING INJECTION FUNCTIONS
---============================================================================

--- Function to wrap around precast for monitoring
function GearSwapMonitor.monitor_precast(original_precast)
    return function(spell, action)
        local spell_name = (spell and spell.name) or "unknown"
        local start = PerfMon.start_operation("precast_" .. spell_name)

        -- Call original function
        local result
        if original_precast then
            result = original_precast(spell, action)
        end

        PerfMon.end_operation("precast_" .. spell_name, start)
        return result
    end
end

--- Function to wrap around midcast for monitoring
function GearSwapMonitor.monitor_midcast(original_midcast)
    return function(spell, action)
        local spell_name = (spell and spell.name) or "unknown"
        local start = PerfMon.start_operation("midcast_" .. spell_name)

        -- Call original function
        local result
        if original_midcast then
            result = original_midcast(spell, action)
        end

        PerfMon.end_operation("midcast_" .. spell_name, start)
        return result
    end
end

--- Function to wrap around aftercast for monitoring
function GearSwapMonitor.monitor_aftercast(original_aftercast)
    return function(spell, action)
        local spell_name = (spell and spell.name) or "unknown"
        local start = PerfMon.start_operation("aftercast_" .. spell_name)

        -- Call original function
        local result
        if original_aftercast then
            result = original_aftercast(spell, action)
        end

        PerfMon.end_operation("aftercast_" .. spell_name, start)
        return result
    end
end

--- Function to wrap around status_change for monitoring
function GearSwapMonitor.monitor_status_change(original_status_change)
    return function(new_status, old_status)
        local start = PerfMon.start_operation("status_change")

        -- Call original function
        local result
        if original_status_change then
            result = original_status_change(new_status, old_status)
        end

        PerfMon.end_operation("status_change", start)
        return result
    end
end

--- Function to wrap around job_setup for monitoring
function GearSwapMonitor.monitor_job_setup(original_job_setup)
    return function()
        local start = PerfMon.start_operation("job_setup")

        -- Call original function
        local result
        if original_job_setup then
            result = original_job_setup()
        end

        PerfMon.end_operation("job_setup", start)
        return result
    end
end

--- Function to wrap around init_gear_sets for monitoring
function GearSwapMonitor.monitor_init_gear_sets(original_init_gear_sets)
    return function()
        local start = PerfMon.start_operation("init_gear_sets")

        -- Call original function
        local result
        if original_init_gear_sets then
            result = original_init_gear_sets()
        end

        PerfMon.end_operation("init_gear_sets", start)
        return result
    end
end

--- Function to wrap pet functions for BST
function GearSwapMonitor.monitor_pet_change(original_pet_change)
    return function(pet, gain)
        local operation = gain and "pet_summoned" or "pet_dismissed"
        local start = PerfMon.start_operation(operation)

        -- Call original function
        local result
        if original_pet_change then
            result = original_pet_change(pet, gain)
        end

        PerfMon.end_operation(operation, start)
        return result
    end
end

---============================================================================
--- EASY INJECTION HELPER
---============================================================================

--- Simple function to inject monitoring into a job file
--- Call this at the end of your job file's job_setup()
function GearSwapMonitor.inject_monitoring()
    -- Silent injection to avoid technical spam
    local injection_count = 0

    -- Only inject if functions exist in current scope
    if precast and type(precast) == 'function' then
        local original_precast = precast
        precast = GearSwapMonitor.monitor_precast(original_precast)
        injection_count = injection_count + 1
    end

    if midcast and type(midcast) == 'function' then
        local original_midcast = midcast
        midcast = GearSwapMonitor.monitor_midcast(original_midcast)
        injection_count = injection_count + 1
    end

    if aftercast and type(aftercast) == 'function' then
        local original_aftercast = aftercast
        aftercast = GearSwapMonitor.monitor_aftercast(original_aftercast)
        injection_count = injection_count + 1
    end

    if status_change and type(status_change) == 'function' then
        local original_status_change = status_change
        status_change = GearSwapMonitor.monitor_status_change(original_status_change)
        injection_count = injection_count + 1
    end

    if pet_change and type(pet_change) == 'function' then
        local original_pet_change = pet_change
        pet_change = GearSwapMonitor.monitor_pet_change(original_pet_change)
        injection_count = injection_count + 1
    end

    if init_gear_sets and type(init_gear_sets) == 'function' then
        local original_init_gear_sets = init_gear_sets
        init_gear_sets = GearSwapMonitor.monitor_init_gear_sets(original_init_gear_sets)
        injection_count = injection_count + 1
    end

    -- No technical messages - the user interface is managed in performance_monitor.lua

    return injection_count > 0
end

---============================================================================
--- MANUAL MONITORING HELPERS
---============================================================================

--- Simple function to manually track an operation
function GearSwapMonitor.track_operation(operation_name, operation_func, ...)
    local start = PerfMon.start_operation(operation_name)
    local result = { operation_func(...) }
    PerfMon.end_operation(operation_name, start)
    return unpack(result)
end

--- Track equipment change
function GearSwapMonitor.track_equip_change(set_name)
    local start = PerfMon.start_operation("equip_" .. (set_name or "unknown"))
    return start -- Return start time so calling code can end it
end

--- End equipment change tracking
function GearSwapMonitor.end_equip_tracking(start_time, set_name)
    PerfMon.end_operation("equip_" .. (set_name or "unknown"), start_time)
end

return GearSwapMonitor
