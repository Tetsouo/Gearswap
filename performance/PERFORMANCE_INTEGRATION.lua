---============================================================================
--- FFXI GearSwap Core Module - Performance Integration System
---============================================================================
--- Automated performance monitoring integration that hooks into critical
--- GearSwap functions to track performance without modifying existing code.
--- Provides transparent monitoring with minimal overhead and comprehensive
--- function coverage for performance analysis.
---
--- @file core/performance_integration.lua
--- @author Tetsouo
--- @version 2.1.3
--- @date Created: 2025-01-05 | Modified: 2025-08-09
--- @requires core/performance_monitor.lua
--- @requires Windower FFXI
---
--- Features:
---   - Automatic function hooking for transparent monitoring
---   - Critical GearSwap function performance tracking
---   - Non-intrusive integration with existing codebase
---   - Comprehensive coverage of performance-critical operations
---   - Dynamic enable/disable with zero overhead when disabled
---
--- @usage
---   local integration = require('core/PERFORMANCE_INTEGRATION')
---   integration.enable_all_hooks()
---============================================================================

--- @class PerformanceIntegration Automated performance monitoring hooks
local PerformanceIntegration = {}

-- Load the monitoring
local success_PerfMon, PerfMon = pcall(require, 'performance/PERFORMANCE_MONITOR')
if not success_PerfMon then
    error("Failed to load performance/performance_monitor: " .. tostring(PerfMon))
end

-- Hook state
local hooks_installed = false
local original_functions = {}

---============================================================================
--- HOOK INSTALLATION
---============================================================================

--- Hook for equipment changes
local function hook_equipment_functions()
    -- Hook send_command function to capture GS commands
    if windower and windower.send_command and not original_functions.send_command then
        original_functions.send_command = windower.send_command
        windower.send_command = function(command)
            if command and command:find("gs ") then
                local start = PerfMon.start_operation("gs_command")
                local result = original_functions.send_command(command)
                PerfMon.end_operation("gs_command", start)
                return result
            else
                return original_functions.send_command(command)
            end
        end
    end
end

--- Hook for global GearSwap events
local function hook_gearswap_events()
    -- Hook job_setup if it exists
    if _G.job_setup and type(_G.job_setup) == 'function' and not original_functions.job_setup then
        original_functions.job_setup = _G.job_setup
        _G.job_setup = function(...)
            local start = PerfMon.start_operation("job_setup")
            local result = { original_functions.job_setup(...) }
            PerfMon.end_operation("job_setup", start)
            return unpack(result)
        end
    end

    -- Hook init_gear_sets if it exists
    if _G.init_gear_sets and type(_G.init_gear_sets) == 'function' and not original_functions.init_gear_sets then
        original_functions.init_gear_sets = _G.init_gear_sets
        _G.init_gear_sets = function(...)
            local start = PerfMon.start_operation("init_gear_sets")
            local result = { original_functions.init_gear_sets(...) }
            PerfMon.end_operation("init_gear_sets", start)
            return unpack(result)
        end
    end

    -- Hook precast if it exists
    if _G.precast and type(_G.precast) == 'function' and not original_functions.precast then
        original_functions.precast = _G.precast
        _G.precast = function(spell, ...)
            local spell_name = (spell and spell.name) or "unknown"
            local start = PerfMon.start_operation("precast_" .. spell_name)
            local result = { original_functions.precast(spell, ...) }
            PerfMon.end_operation("precast_" .. spell_name, start)
            return unpack(result)
        end
    end

    -- Hook midcast if it exists
    if _G.midcast and type(_G.midcast) == 'function' and not original_functions.midcast then
        original_functions.midcast = _G.midcast
        _G.midcast = function(spell, ...)
            local spell_name = (spell and spell.name) or "unknown"
            local start = PerfMon.start_operation("midcast_" .. spell_name)
            local result = { original_functions.midcast(spell, ...) }
            PerfMon.end_operation("midcast_" .. spell_name, start)
            return unpack(result)
        end
    end

    -- Hook aftercast if it exists
    if _G.aftercast and type(_G.aftercast) == 'function' and not original_functions.aftercast then
        original_functions.aftercast = _G.aftercast
        _G.aftercast = function(spell, ...)
            local spell_name = (spell and spell.name) or "unknown"
            local start = PerfMon.start_operation("aftercast_" .. spell_name)
            local result = { original_functions.aftercast(spell, ...) }
            PerfMon.end_operation("aftercast_" .. spell_name, start)
            return unpack(result)
        end
    end

    -- Hook status_change if it exists
    if _G.status_change and type(_G.status_change) == 'function' and not original_functions.status_change then
        original_functions.status_change = _G.status_change
        _G.status_change = function(new_status, old_status)
            local start = PerfMon.start_operation("status_change")
            local result = { original_functions.status_change(new_status, old_status) }
            PerfMon.end_operation("status_change", start)
            return unpack(result)
        end
    end
end

--- Hook for BST-specific functions
local function hook_pet_functions()
    -- Hook pet_change if it exists
    if _G.pet_change and type(_G.pet_change) == 'function' and not original_functions.pet_change then
        original_functions.pet_change = _G.pet_change
        _G.pet_change = function(pet, gain)
            local operation = gain and "pet_summoned" or "pet_dismissed"
            local start = PerfMon.start_operation(operation)
            local result = { original_functions.pet_change(pet, gain) }
            PerfMon.end_operation(operation, start)
            return unpack(result)
        end
    end

    -- Hook pet_midcast if it exists
    if _G.pet_midcast and type(_G.pet_midcast) == 'function' and not original_functions.pet_midcast then
        original_functions.pet_midcast = _G.pet_midcast
        _G.pet_midcast = function(spell, ...)
            local spell_name = (spell and spell.name) or "unknown"
            local start = PerfMon.start_operation("pet_" .. spell_name)
            local result = { original_functions.pet_midcast(spell, ...) }
            PerfMon.end_operation("pet_" .. spell_name, start)
            return unpack(result)
        end
    end
end

--- Hook basic commands
local function hook_basic_commands()
    -- Hook basic equipment functions if they exist
    if _G.equip and type(_G.equip) == 'function' and not original_functions.equip then
        original_functions.equip = _G.equip
        _G.equip = function(...)
            local start = PerfMon.start_operation("equip_change")
            local result = { original_functions.equip(...) }
            PerfMon.end_operation("equip_change", start)
            return unpack(result)
        end
    end

    -- Hook enable/disable if they exist
    if _G.enable and type(_G.enable) == 'function' and not original_functions.enable then
        original_functions.enable = _G.enable
        _G.enable = function(...)
            local start = PerfMon.start_operation("enable_slots")
            local result = { original_functions.enable(...) }
            PerfMon.end_operation("enable_slots", start)
            return unpack(result)
        end
    end

    if _G.disable and type(_G.disable) == 'function' and not original_functions.disable then
        original_functions.disable = _G.disable
        _G.disable = function(...)
            local start = PerfMon.start_operation("disable_slots")
            local result = { original_functions.disable(...) }
            PerfMon.end_operation("disable_slots", start)
            return unpack(result)
        end
    end
end

---============================================================================
--- PUBLIC FUNCTIONS
---============================================================================

--- Install all hooks automatically
function PerformanceIntegration.install_hooks()
    if hooks_installed then
        windower.add_to_chat(057, "[PERF] Hooks already installed")
        return true
    end

    windower.add_to_chat(050, "[PERF] Installing performance hooks...")

    -- Install different types of hooks
    hook_equipment_functions()
    hook_gearswap_events()
    hook_pet_functions()
    hook_basic_commands()

    hooks_installed = true

    local hooked_count = 0
    for _ in pairs(original_functions) do
        hooked_count = hooked_count + 1
    end

    windower.add_to_chat(030, string.format("[PERF] %d functions hooked for monitoring", hooked_count))

    if hooked_count == 0 then
        windower.add_to_chat(057, "[PERF] WARNING: No functions were hooked - monitoring may not capture operations")
        windower.add_to_chat(001, "[PERF] This is normal if GearSwap functions aren't loaded yet")
    end

    return true
end

--- Show hook status
function PerformanceIntegration.show_hooks_status()
    windower.add_to_chat(050, "=== PERFORMANCE HOOKS STATUS ===")
    windower.add_to_chat(001, string.format("Hooks installed: %s", hooks_installed and "YES" or "NO"))
    windower.add_to_chat(001, string.format("Functions hooked: %d", #original_functions))

    if next(original_functions) then
        windower.add_to_chat(160, "Hooked functions:")
        for func_name, _ in pairs(original_functions) do
            windower.add_to_chat(030, "  OK " .. func_name)
        end
    else
        windower.add_to_chat(057, "No functions currently hooked")
        windower.add_to_chat(001, "Try: //gs c perf install_hooks after loading your job file")
    end

    windower.add_to_chat(050, "================================")
end

--- Attempt to reinstall hooks (useful after job reload)
function PerformanceIntegration.reinstall_hooks()
    hooks_installed = false
    original_functions = {}
    return PerformanceIntegration.install_hooks()
end

--- Uninstall hooks (restore original functions)
function PerformanceIntegration.uninstall_hooks()
    if not hooks_installed then
        windower.add_to_chat(057, "[PERF] No hooks to uninstall")
        return false
    end

    windower.add_to_chat(050, "[PERF] Uninstalling hooks...")

    -- Restore original functions
    for func_name, original_func in pairs(original_functions) do
        _G[func_name] = original_func
        windower.add_to_chat(160, "  OK Restored " .. func_name)
    end

    -- Restore windower.send_command if necessary
    if original_functions.send_command then
        windower.send_command = original_functions.send_command
    end

    hooks_installed = false
    original_functions = {}

    windower.add_to_chat(030, "[PERF] All hooks uninstalled")
    return true
end

--- Manual operation capture test
function PerformanceIntegration.test_capture()
    windower.add_to_chat(050, "[PERF] Testing operation capture...")

    -- Simulate different types of operations
    local start1 = PerfMon.start_operation("manual_test_1")
    -- Simulate 30ms of work
    local test_start = os.clock()
    while (os.clock() - test_start) * 1000 < 30 do end
    PerfMon.end_operation("manual_test_1", start1)

    local start2 = PerfMon.start_operation("manual_test_2")
    -- Simulate 80ms of work (warning)
    test_start = os.clock()
    while (os.clock() - test_start) * 1000 < 80 do end
    PerfMon.end_operation("manual_test_2", start2)

    windower.add_to_chat(030, "[PERF] Test capture complete - check report")
    return true
end

return PerformanceIntegration
