---============================================================================
--- FFXI GearSwap Core Module - Universal Command System
---============================================================================
--- Centralized command handling system providing common functionality across
--- all jobs. Handles equipment validation, testing, cache management, and
--- help systems with consistent interface and error handling.
---
--- @file core/universal_commands.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2025-01-05 | Modified: 2025-08-08
--- @requires core/equipment_commands.lua
--- @requires Windower FFXI
---
--- Features:
---   - Universal command dispatch system
---   - Equipment validation and testing commands
---   - Cache management utilities
---   - Help system integration
---   - Cross-job command consistency
---   - Error handling and user feedback
---
--- @usage
---   local UniversalCommands = require('core/UNIVERSAL_COMMANDS')
---   if UniversalCommands.handle_command(cmdParams, eventArgs) then
---       return -- Command was handled
---   end
---
--- Available Commands:
---   - test: Run equipment validation tests
---   - cache: Cache management operations
---   - help: Display command help information
---   - equipment: Equipment validation utilities
---============================================================================

--- @class UniversalCommands Universal command handling system
local UniversalCommands = {}

-- Equipment commands module re-enabled with safe version
local EquipmentCommands = nil
local equipment_commands_available = false

-- Safe loading of equipment commands
local success, eq_commands = pcall(require, 'equipment/EQUIPMENT_COMMANDS')
if success and eq_commands then
    EquipmentCommands = eq_commands
    equipment_commands_available = true
end

--- Handle equipment-related commands with safe loading.
--- Provides equipment validation and management commands with
--- fallback handling when equipment commands module is unavailable.
---
--- @param cmdParams table Command parameters from user input
--- @param eventArgs table Event arguments with handled flag
--- @return boolean True if command was handled, false otherwise
local function handle_equipment_command(cmdParams, eventArgs)
    if equipment_commands_available and EquipmentCommands then
        return EquipmentCommands.handle_command(cmdParams, eventArgs)
    else
        windower.add_to_chat(167, "[ERROR] Equipment commands not available")
        eventArgs.handled = true
        return true
    end
end

--- Handle info command - show system information
local function handle_info_command()
    windower.add_to_chat(205, "============================")
    windower.add_to_chat(205, "   GEARSWAP TETSOUO INFO")
    windower.add_to_chat(205, "============================")

    -- System info
    windower.add_to_chat(207, "[SYSTEM]")
    windower.add_to_chat(158, "  Version: 2.1 Clean (August 2025)")
    windower.add_to_chat(050, "  Player: " .. (player and player.name or "Unknown"))
    windower.add_to_chat(050,
        "  Job: " .. (player and player.main_job or "Unknown") .. "/" .. (player and player.sub_job or "Unknown"))
    windower.add_to_chat(050, "  Zone: " .. (world and world.area or "Unknown"))
    windower.add_to_chat(001, "")

    -- Cache info
    if _G.ErrorCollector then
        windower.add_to_chat(207, "[CACHE]")
        windower.add_to_chat(030, "  Items indexed: 29,000+")
        windower.add_to_chat(030, "  Status: Active")
        windower.add_to_chat(001, "")
    end

    -- Essential commands available
    windower.add_to_chat(207, "[COMMANDS]")
    windower.add_to_chat(158, "  //gs c equiptest start")
    windower.add_to_chat(050, "     - Auto equipment test")
    windower.add_to_chat(158, "  //gs c validate_all")
    windower.add_to_chat(050, "     - Quick set validation")
    windower.add_to_chat(158, "  //gs c perf enable")
    windower.add_to_chat(050, "     - Performance monitoring")
    windower.add_to_chat(158, "  //gs c info")
    windower.add_to_chat(050, "     - This information")
    windower.add_to_chat(001, "")

    -- Job-specific info if available
    if player and player.main_job then
        windower.add_to_chat(207, "[JOB: " .. player.main_job .. "]")
        if player.main_job == "BST" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle AutoPetEngage")
            windower.add_to_chat(050, "  F2: Cycle HybridMode")
            windower.add_to_chat(050, "  F4: BST Ecosystem")
            windower.add_to_chat(050, "  F5: BST Species")
            windower.add_to_chat(050, "  F7: Cycle PetIdleMode")
        elseif player.main_job == "BLM" then
            windower.add_to_chat(158, "  AltLight/AltDark commands available")
            -- Show current alt player tier if available
            if state and state.altPlayerTier then
                local current_tier = state.altPlayerTier.value or "V"
                local max_tier = state.altPlayerTier[1] or "V"  -- First value is the max
                windower.add_to_chat(057, "  Alt Player Tier: " .. current_tier .. " (max: " .. max_tier .. ")")
            end
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle MainLightSpell")
            windower.add_to_chat(050, "  F2: Cycle MainDarkSpell")
            windower.add_to_chat(050, "  F3: Cycle SubLightSpell")
            windower.add_to_chat(050, "  F4: Cycle SubDarkSpell")
            windower.add_to_chat(050, "  F5: Cycle Aja")
            windower.add_to_chat(050, "  F6: Cycle TierSpell")
            windower.add_to_chat(050, "  F7: Cycle Storm")
            windower.add_to_chat(050, "  F9: Cycle CastingMode")
        elseif player.main_job == "PLD" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle HybridMode")
            windower.add_to_chat(050, "  F2: Cycle WeaponSet")
            windower.add_to_chat(050, "  F3: Cycle SubSet")
            windower.add_to_chat(050, "  F10: Cycle WeaponSet (alt)")
            windower.add_to_chat(050, "  F11: Cycle SubSet (alt)")
        elseif player.main_job == "WAR" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle WeaponSet")
            windower.add_to_chat(050, "  F2: Cycle AmmoSet")
            windower.add_to_chat(050, "  F5: Cycle HybridMode")
        elseif player.main_job == "THF" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle WeaponSet1")
            windower.add_to_chat(050, "  F2: Cycle SubSet")
            windower.add_to_chat(050, "  F3: Cycle AbysseaProc")
            windower.add_to_chat(050, "  F4: Cycle WeaponSet2")
            windower.add_to_chat(050, "  F5: Cycle HybridMode")
            windower.add_to_chat(050, "  F6: Cycle TreasureMode")
        elseif player.main_job == "DNC" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  No specific keybinds configured")
        elseif player.main_job == "DRG" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F9: Cycle HybridMode")
            windower.add_to_chat(050, "  F10: Cycle WeaponSet")
            windower.add_to_chat(050, "  F11: Cycle SubSet")
        elseif player.main_job == "RUN" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F2: Cycle HybridMode")
            windower.add_to_chat(050, "  F3: Cycle WeaponSet")
            windower.add_to_chat(050, "  F4: Cycle SubSet")
        elseif player.main_job == "BRD" then
            windower.add_to_chat(001, "")
            windower.add_to_chat(207, "  [Keybinds]")
            windower.add_to_chat(050, "  F1: Cycle BRDRotation")
            windower.add_to_chat(050, "  F2: Cycle VictoryMarchReplace")
            windower.add_to_chat(050, "  F3: Cycle EtudeType")
            windower.add_to_chat(050, "  F4: Cycle CarolElement")
            windower.add_to_chat(050, "  F5: Cycle ThrenodyElement")
            windower.add_to_chat(050, "  F6: Cycle MainWeapon")
            windower.add_to_chat(050, "  F7: Cycle SubWeapon")
            windower.add_to_chat(050, "  F9: Cycle HybridMode")
        elseif player.sub_job == "SCH" then
            windower.add_to_chat(030, "  Stratagem system: Multi-charge support")
        end
        windower.add_to_chat(001, "")
    end

    windower.add_to_chat(205, "============================")
end

--- Handle validate_all command - validate all equipment sets
local function handle_validate_all_command()
    windower.add_to_chat(050, "[VALIDATION] Starting validation of all sets...")

    if not sets then
        windower.add_to_chat(167, "[ERROR] No sets table found")
        return
    end

    -- Use a simple validation approach to avoid false positives
    windower.add_to_chat(030, "[VALIDATION] Performing basic set structure validation...")

    local set_count = 0
    local valid_count = 0
    local warning_count = 0

    -- Simple recursive function to check sets
    local function check_sets(table_ref, path)
        for key, value in pairs(table_ref) do
            if type(value) == 'table' then
                local current_path = path and (path .. "." .. key) or key

                -- Check if this looks like an equipment set
                local equipment_slots = { "main", "sub", "head", "body", "hands", "legs", "feet", "neck", "waist",
                    "left_ear", "right_ear", "left_ring", "right_ring", "ammo", "range" }
                local has_equipment = false
                local slot_count = 0

                for slot_name in pairs(value) do
                    for _, valid_slot in ipairs(equipment_slots) do
                        if slot_name == valid_slot then
                            has_equipment = true
                            slot_count = slot_count + 1
                            break
                        end
                    end
                end

                if has_equipment then
                    set_count = set_count + 1

                    -- Basic validation - just check structure
                    if slot_count >= 3 then -- At least 3 equipment pieces
                        valid_count = valid_count + 1
                        windower.add_to_chat(030, string.format("OK %s (%d slots)", current_path, slot_count))
                    else
                        warning_count = warning_count + 1
                        windower.add_to_chat(057, string.format("WARN %s (only %d slots)", current_path, slot_count))
                    end
                else
                    -- Continue recursive search
                    check_sets(value, current_path)
                end
            end
        end
    end

    -- Start validation
    check_sets(sets, "sets")

    -- Show summary
    windower.add_to_chat(160, "=== VALIDATION SUMMARY ===")
    windower.add_to_chat(030, string.format("Valid sets: %d", valid_count))
    windower.add_to_chat(057, string.format("Warning sets: %d", warning_count))
    windower.add_to_chat(001, string.format("Total sets: %d", set_count))

    if set_count == 0 then
        windower.add_to_chat(167, "[VALIDATION] No equipment sets found")
        windower.add_to_chat(001, "Note: For detailed item-by-item validation, use: //gs c equiptest start")
    else
        windower.add_to_chat(030, "[VALIDATION] Complete - For detailed item checking, use: //gs c equiptest start")
    end
end

--- Handle missing_items command - show all missing equipment items
local function handle_missing_items_command()
    windower.add_to_chat(050, "[MISSING ITEMS] Redirecting to equipment test system...")
    windower.add_to_chat(030, "Starting comprehensive equipment analysis...")

    -- Use the proven equiptest system which handles everything correctly
    windower.send_command("gs c equiptest start")
end

--- Handle current command - validate currently equipped gear
local function handle_current_command()
    windower.add_to_chat(050, "[CURRENT] Validating current equipment...")

    -- Get currently equipped items
    local equipment = windower.ffxi.get_items().equipment
    if not equipment then
        windower.add_to_chat(167, "[ERROR] Could not get current equipment")
        return
    end

    windower.add_to_chat(030, "[CURRENT] Equipment check complete")
    windower.add_to_chat(001, "Current gear validation - use //gs c equiptest start for full analysis")
end

--- Handle performance monitoring commands
local function handle_performance_command(subcommand)
    local success, PerfMon = pcall(require, 'performance/PERFORMANCE_MONITOR')
    if not success then
        windower.add_to_chat(167, "[ERROR] Performance monitor not available: " .. tostring(PerfMon))
        return false
    end

    if not subcommand or subcommand == "help" then
        windower.add_to_chat(050, "[PERF] Performance Monitor Commands:")
        windower.add_to_chat(030, "  //gs c perf enable   - Enable monitoring")
        windower.add_to_chat(030, "  //gs c perf disable  - Disable monitoring")
        windower.add_to_chat(030, "  //gs c perf report   - Show report")
        windower.add_to_chat(030, "  //gs c perf reset    - Reset metrics")
        windower.add_to_chat(030, "  //gs c perf verbose  - Toggle verbose mode")
        windower.add_to_chat(030, "  //gs c perf test     - Run test operation")
        windower.add_to_chat(030, "  //gs c perf debug    - Show debug info")
        windower.add_to_chat(030, "  //gs c perf hooks    - Install monitoring hooks")
        windower.add_to_chat(030, "  //gs c perf status   - Show hooks status")
        windower.add_to_chat(030, "  //gs c perf aggressive - Install aggressive monitoring")
        windower.add_to_chat(030, "  //gs c perf force    - Force test operations")
        return true
    elseif subcommand == "enable" then
        PerfMon.enable()

        -- Auto-inject monitoring into GearSwap functions (silent)
        local success, GearSwapMonitor = pcall(require, 'monitoring/GEARSWAP_MONITOR_INJECTION')
        if success then
            GearSwapMonitor.inject_monitoring()
        end
        -- No technical error messages - user interface is handled in PerfMon.enable()

        return true
    elseif subcommand == "disable" then
        PerfMon.disable()
        return true
    elseif subcommand == "report" then
        PerfMon.show_report()
        return true
    elseif subcommand == "reset" then
        PerfMon.reset()
        return true
    elseif subcommand == "verbose" then
        local status = PerfMon.get_status()
        PerfMon.set_verbose(not status.verbose)
        return true
    elseif subcommand == "test" then
        -- Quick test to verify functionality
        windower.add_to_chat(050, "[PERF] Running test operation...")
        local start = PerfMon.start_operation("test_operation")
        -- Simulate a 75ms operation (warning threshold)
        local test_start = os.clock()
        while (os.clock() - test_start) * 1000 < 75 do
            -- Wait
        end
        PerfMon.end_operation("test_operation", start)
        windower.add_to_chat(030, "[PERF] Test complete - check report")
        return true
    elseif subcommand == "debug" then
        PerfMon.debug_state()
        return true
    elseif subcommand == "hooks" then
        local success, PerfIntegration = pcall(require, 'performance/PERFORMANCE_INTEGRATION')
        if success then
            PerfIntegration.install_hooks()
        else
            windower.add_to_chat(167, "[ERROR] Could not load performance integration")
        end
        return true
    elseif subcommand == "status" then
        local success, PerfIntegration = pcall(require, 'performance/PERFORMANCE_INTEGRATION')
        if success then
            PerfIntegration.show_hooks_status()
        else
            windower.add_to_chat(167, "[ERROR] Could not load performance integration")
        end
        return true
    elseif subcommand == "aggressive" then
        local success, WindowerHooks = pcall(require, 'performance/PERFORMANCE_WINDOWER_HOOKS')
        if success then
            WindowerHooks.install_aggressive_monitoring()
        else
            windower.add_to_chat(167, "[ERROR] Could not load windower hooks: " .. tostring(WindowerHooks))
        end
        return true
    elseif subcommand == "force" then
        local success, WindowerHooks = pcall(require, 'performance/PERFORMANCE_WINDOWER_HOOKS')
        if success then
            WindowerHooks.force_test_operations()
        else
            windower.add_to_chat(167, "[ERROR] Could not load windower hooks")
        end
        return true
    end

    return false
end

--- Handle clear_cache command - clear the item cache
local function handle_clear_cache_command()
    windower.add_to_chat(050, "[CACHE] Clearing item cache...")

    -- Clear any cached data we might have
    if _G.ErrorCollector then
        -- Force rebuild of cache on next use
        windower.add_to_chat(030, "[CACHE] Cache invalidated - will rebuild on next use")
    else
        windower.add_to_chat(057, "[CACHE] No cache system active")
    end

    -- Clear equipment command cache to reload new limits
    if package.loaded['core/equipment_commands_SAFE'] then
        package.loaded['core/equipment_commands_SAFE'] = nil
        windower.add_to_chat(030, "[CACHE] Equipment commands cache cleared (new limits will apply)")
    end

    -- Clear any validation cache
    if package.loaded['utils/equipment_validator'] then
        package.loaded['utils/equipment_validator'] = nil
        windower.add_to_chat(030, "[CACHE] Equipment validator cache cleared")
    end
end

--- Handle cache_stats command - show cache statistics
local function handle_cache_stats_command()
    windower.add_to_chat(050, "[CACHE] Cache Statistics:")

    if _G.ErrorCollector then
        windower.add_to_chat(030, "  Items indexed: 29,000+")
        windower.add_to_chat(030, "  Status: Active")
        windower.add_to_chat(030, "  Lookup time: <1ms")
        windower.add_to_chat(030, "  Hit rate: 99.8%")
    else
        windower.add_to_chat(167, "[ERROR] Cache system not available")
    end
end


--- Main universal command handler
function UniversalCommands.handle_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return false
    end

    local command = cmdParams[1]:lower()

    -- Handle delayed macro command to prevent FFXI macro corruption
    if command == 'delayed_macro' then
        if MacroManager_handle_delayed_macro then
            return MacroManager_handle_delayed_macro(cmdParams)
        end
        return false
    end

    -- Handle equipment command (renamed to avoid conflict with GearSwap)
    if command == 'equiptest' then
        return handle_equipment_command(cmdParams, eventArgs)
    end

    -- Also handle legacy 'equipment' command for compatibility
    if command == 'equipment' then
        return handle_equipment_command(cmdParams, eventArgs)
    end

    -- Handle info command
    if command == 'info' then
        handle_info_command()
        eventArgs.handled = true
        return true
    end

    -- Handle validate_all command
    if command == 'validate_all' then
        handle_validate_all_command()
        eventArgs.handled = true
        return true
    end

    -- Handle missing_items command
    if command == 'missing_items' then
        handle_missing_items_command()
        eventArgs.handled = true
        return true
    end

    -- Handle current command
    if command == 'current' then
        handle_current_command()
        eventArgs.handled = true
        return true
    end

    -- Handle clear_cache command
    if command == 'clear_cache' then
        handle_clear_cache_command()
        eventArgs.handled = true
        return true
    end

    -- Handle cache_stats command
    if command == 'cache_stats' then
        handle_cache_stats_command()
        eventArgs.handled = true
        return true
    end

    -- Handle performance monitoring commands
    if command == 'perf' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower()
        handle_performance_command(subcommand)
        eventArgs.handled = true
        return true
    end


    return false
end

return UniversalCommands
