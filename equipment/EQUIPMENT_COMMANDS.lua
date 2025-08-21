---============================================================================
--- FFXI GearSwap Equipment Commands - SAFE VERSION (Post-Performance Fix)
---============================================================================
--- Refactored equipment command handlers with performance-safe operations.
--- This version avoids heavy initialization and blocking operations.
---
--- @file core/equipment_commands.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-09 (Safe Recovery Version)
--- @requires utils/error_collector.lua (production version)
---============================================================================

local EquipmentCommands = {}

-- Safe logger - no external dependencies
local function safe_log(color, message)
    if windower and windower.add_to_chat then
        windower.add_to_chat(color, message)
    else
        print(message)
    end
end

---============================================================================
--- SAFE HELPER FUNCTIONS
---============================================================================

--- Collect equipment sets by finding actual set definitions (not runtime exploration)
--- @return table, number Array of set paths and max limit
local function collect_equipment_sets_safe()
    -- Start performance monitoring
    local success, PerfMon = pcall(require, 'performance/PERFORMANCE_MONITOR')
    local start_time = success and PerfMon.start_operation("equipment_scan") or os.clock()

    local main_sets = {}
    local max_sets = 200

    -- Get job-specific SET file path
    local job = player and player.main_job and player.main_job:upper() or "UNKNOWN"
    local set_file_path = string.format("jobs/%s/%s_SET.lua", job:lower(), job)


    -- Read and parse the set file to find actual set definitions
    local success_read, file_content = pcall(function()
        -- Try multiple possible paths
        local possible_paths = {
            windower.addon_path .. set_file_path,
            windower.addon_path .. "../data/Tetsouo/" .. set_file_path,
            "D:\\Windower Tetsouo\\addons\\GearSwap\\data\\Tetsouo\\" .. set_file_path,
            set_file_path
        }

        for _, path in ipairs(possible_paths) do
            local file = io.open(path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                return content
            end
        end

        return nil
    end)

    if success_read and file_content then
        -- Parse file for actual set definitions
        -- Match patterns like: sets.idle = { or sets['Ochain'] = { or sets.precast.JA['Provoke'] = set_combine(
        for line in file_content:gmatch("[^\r\n]+") do
            local set_name = nil

            -- Pattern 1: sets.something = { (including complex paths with brackets)
            set_name = line:match("^(sets[%.%w%[%]'\"_%-%s]+)%s*=%s*{")

            -- Pattern 2: sets['something'] = {
            if not set_name then
                local bracket_name = line:match("^sets%[(['\"]?[^'\"]+['\"]?)%]%s*=%s*{")
                if bracket_name then
                    -- Keep bracket notation for sets defined with brackets
                    local clean_name = bracket_name:gsub("'", ""):gsub('"', '')
                    set_name = "sets['" .. clean_name .. "']"
                end
            end

            -- Pattern 3: sets.something = set_combine(
            if not set_name then
                set_name = line:match("^(sets[%.%w%[%]'\"_%-%s]+)%s*=%s*set_combine%(")
            end

            -- Pattern 4: sets['something'] = set_combine(
            if not set_name then
                local bracket_name = line:match("^sets%[(['\"]?[^'\"]+['\"]?)%]%s*=%s*set_combine%(")
                if bracket_name then
                    local clean_name = bracket_name:gsub("'", ""):gsub('"', '')
                    set_name = "sets['" .. clean_name .. "']"
                end
            end

            -- Pattern 5: sets.something = sets.other
            if not set_name then
                set_name = line:match("^(sets[%.%w%[%]'\"_%-%s]+)%s*=%s*sets[%.%[]")
            end

            -- Pattern 6: sets['something'] = sets.other or sets['other']
            if not set_name then
                local bracket_name = line:match("^sets%[(['\"]?[^'\"]+['\"]?)%]%s*=%s*sets")
                if bracket_name then
                    local clean_name = bracket_name:gsub("'", ""):gsub('"', '')
                    set_name = "sets['" .. clean_name .. "']"
                end
            end

            if set_name then
                -- Clean up the set name (remove quotes only for dot notation)
                if not set_name:match("%[.*%]") then
                    set_name = set_name:gsub("'", ""):gsub('"', '')
                end

                -- Check for duplicates
                local already_exists = false
                for _, existing_set in ipairs(main_sets) do
                    if existing_set == set_name then
                        already_exists = true
                        break
                    end
                end

                if not already_exists then
                    table.insert(main_sets, set_name)
                    -- Set found and added
                end
            end
        end
    else
        safe_log(167, string.format("[ERROR] Could not read SET file: %s", set_file_path))
        safe_log(057, "[FALLBACK] Using runtime exploration...")

        -- Fallback: simple runtime exploration as backup
        if sets and type(sets) == 'table' then
            local function simple_scan(table_ref, prefix)
                for key, value in pairs(table_ref) do
                    if type(value) == 'table' and type(key) == 'string' then
                        local new_path = prefix .. "." .. key
                        -- Check if it looks like a set (has equipment slots or is a known set pattern)
                        local has_equipment = false
                        local equipment_slots = { 'main', 'sub', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist',
                            'left_ear', 'right_ear', 'ear1', 'ear2', 'left_ring', 'right_ring', 'ring1', 'ring2', 'ammo',
                            'range' }

                        for _, slot in ipairs(equipment_slots) do
                            if value[slot] ~= nil then
                                has_equipment = true
                                break
                            end
                        end

                        if has_equipment then
                            table.insert(main_sets, new_path)
                        else
                            -- Continue scanning deeper
                            simple_scan(value, new_path)
                        end
                    end
                end
            end

            simple_scan(sets, "sets")
        end
    end

    -- End performance monitoring
    if success and PerfMon then
        PerfMon.end_operation("equipment_scan", start_time)
    end

    return main_sets, max_sets
end

--- Safe error collector initialization - Production
--- @return boolean Success status
local function initialize_error_collector_safe()
    -- Force reload ErrorCollector
    _G.ErrorCollector = nil -- Clear existing

    -- Method 1: Try direct require (more reliable)
    local success, ErrorCollectorModule = pcall(require, 'utils/ERROR_COLLECTOR')
    if success and ErrorCollectorModule then
        _G.ErrorCollector = ErrorCollectorModule
        safe_log(030, "[LOAD] ErrorCollector loaded via require")
    else
        -- Method 2: Try include as fallback
        local include_success = pcall(include, 'utils/error_collector.lua')
        if include_success and _G.ErrorCollector then
            safe_log(030, "[LOAD] ErrorCollector loaded via include")
        else
            safe_log(167, "[ERROR] Failed to load ErrorCollector")
            return false
        end
    end

    -- Verify ErrorCollector is loaded
    if not _G.ErrorCollector then
        safe_log(167, "[ERROR] ErrorCollector not available after loading")
        return false
    end

    -- Try to start it safely
    local start_success = pcall(_G.ErrorCollector.start_collecting)
    if not start_success then
        safe_log(167, "[ERROR] Failed to start ErrorCollector")
        return false
    end

    safe_log(030, "[SUCCESS] ErrorCollector initialized and started")
    return true
end

---============================================================================
--- SAFE COMMAND HANDLERS
---============================================================================

--- Handle equipment test start command - SAFE VERSION
--- @param eventArgs table Event arguments
function EquipmentCommands.handle_start(eventArgs)
    local job = player and player.main_job and player.main_job:upper() or "UNKNOWN"

    -- Header will be handled by ErrorCollector V5

    -- Initialize error collector safely
    if not initialize_error_collector_safe() then
        safe_log(167, "[ERROR] Error collector unavailable - basic validation only")
        eventArgs.handled = true
        return false
    end

    if _G.ErrorCollector then
        local success = pcall(_G.ErrorCollector.start_collecting)

        if success then
            -- Display report after analysis
            pcall(_G.ErrorCollector.show_report)
        else
            safe_log(167, "[ERROR] Equipment analysis failed")
        end
    else
        safe_log(167, "[ERROR] ErrorCollector not available")
    end

    eventArgs.handled = true
    return true
end

--- Handle equipment test report command - SAFE VERSION
--- @param eventArgs table Event arguments
function EquipmentCommands.handle_report(eventArgs)
    if _G.ErrorCollector then
        local success = pcall(_G.ErrorCollector.show_report)
        if not success then
            safe_log(167, "[ERROR] Report generation failed (SAFE MODE)")
        end
    else
        safe_log(167, "[ERROR] ErrorCollector not available")
    end

    eventArgs.handled = true
    return true
end

--- Handle equipment test status command - SAFE VERSION
--- @param eventArgs table Event arguments
function EquipmentCommands.handle_status(eventArgs)
    safe_log(050, "=== EQUIPMENT STATUS v2.0 (SAFE) ===")

    if _G.ErrorCollector then
        local success, status = pcall(_G.ErrorCollector.get_capture_status)
        if success and status then
            safe_log(status.collecting and 030 or 167,
                string.format("[COLLECT] %s", status.collecting and "ACTIVE" or "INACTIVE"))
            safe_log(001, string.format("[STATS] Errors captured: %d", status.total_errors or 0))
        else
            safe_log(057, "[STATUS] Error collector status unavailable")
        end
    else
        safe_log(167, "[ERROR] ErrorCollector not available")
    end

    eventArgs.handled = true
    return true
end

--- Handle help command - SAFE VERSION
--- @param eventArgs table Event arguments
function EquipmentCommands.handle_help(eventArgs)
    safe_log(050, "===== EQUIPMENT COMMANDS v2.0 (SAFE) =====")
    safe_log(030, "  gs c equiptest start     - Safe equipment analysis")
    safe_log(030, "  gs c equiptest report    - Show error report")
    safe_log(001, "  gs c equiptest status    - System status")
    safe_log(001, "")
    safe_log(160, "SAFE MODE: Performance optimized, no blocking operations")

    eventArgs.handled = true
    return true
end

---============================================================================
--- MAIN COMMAND DISPATCHER - SAFE VERSION
---============================================================================

--- Main equipment command handler - SAFE VERSION
--- @param cmdParams table Command parameters
--- @param eventArgs table Event arguments
--- @return boolean Success status
function EquipmentCommands.handle_command(cmdParams, eventArgs)
    local subcommand = cmdParams[2] and cmdParams[2]:lower()

    if subcommand == 'start' then
        return EquipmentCommands.handle_start(eventArgs)
    elseif subcommand == 'report' then
        return EquipmentCommands.handle_report(eventArgs)
    elseif subcommand == 'status' then
        return EquipmentCommands.handle_status(eventArgs)
    else
        return EquipmentCommands.handle_help(eventArgs)
    end
end

return EquipmentCommands
