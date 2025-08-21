---============================================================================
--- FFXI GearSwap Core Module - Macro Book Manager
---============================================================================
--- Centralized macro book management system for dual-boxing coordination.
--- No external dependencies, works with all jobs.
---
--- @file core/macro_manager.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-16
---============================================================================

-- Cache for preventing duplicate messages
local last_macro_message = ""
local last_macro_time = 0

---============================================================================
--- CONFIGURATION LOADING
---============================================================================

-- Load centralized configuration
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

-- Load new robust manager
local success_robust_manager, robust_manager = pcall(require, 'macros/MACRO_LOCKSTYLE_MANAGER')
if not success_robust_manager then
    error("Failed to load macros/macro_lockstyle_manager: " .. tostring(robust_manager))
end

-- Get macro configurations from centralized settings
local function get_macro_configs()
    local macro_config = config.get_macro_config()
    return {
        dual_box = macro_config.dual_box or {},
        solo = macro_config.solo or {},
        lockstyles = macro_config.lockstyles or {}
    }
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Read Kaories job from file
--- @return string|nil The job name or nil if not found
local function read_kaories_job()
    local file = io.open('kaories_job.txt', 'r')
    if file then
        local job = file:read('*all')
        file:close()
        if job and job ~= '' then
            return job:gsub('%s+', '') -- Remove whitespace
        end
    end
    return nil
end

--- Get alt job from various sources
--- @return string|nil The detected alt job or nil
local function get_alt_job()
    -- First try to read from file using configured alt name
    local alt_name = config.get_alt_player():lower()
    local job_from_file = read_kaories_job() -- This still uses hardcoded filename for now
    if job_from_file then
        return job_from_file
    end

    -- Fallback to global variable
    if _G.kaories_current_job then
        return _G.kaories_current_job
    end

    -- Check DualBoxUtils if available
    if DualBoxUtils and DualBoxUtils.alt_player_job then
        return DualBoxUtils.alt_player_job
    end

    return nil
end

---============================================================================
--- MAIN FUNCTIONS
---============================================================================

--- Select and apply macro book based on job combinations
--- @param main_job string|nil Override main job (optional, defaults to player.main_job)
--- @param sub_job string|nil Override sub job (optional, defaults to player.sub_job)
--- @param silent boolean If true, suppress the status message
--- @return number, number macro_book, macro_page
local function select_macro_book(main_job, sub_job, silent)
    -- Always use new robust manager
    return robust_manager.update_job_settings(main_job, sub_job, silent)
end

--- Initialize macro manager for a job file
--- Should be called in select_default_macro_book() of each job file
local function initialize()
    -- Use new robust manager
    robust_manager.initialize()
end

---============================================================================
--- GLOBAL FUNCTIONS FOR JOB FILES
---============================================================================

-- Make functions globally available immediately
function MacroManager_select_macro_book(main_job, sub_job, silent)
    -- Simply delegate to the internal function to avoid code duplication
    return select_macro_book(main_job, sub_job, silent)
end

function MacroManager_initialize()
    -- Use new robust manager
    robust_manager.initialize()
end

--- Handle delayed macro page changes to prevent FFXI macro corruption
--- @param cmdParams table Command parameters [delayed_macro, page, book]
--- @return boolean True if command was handled
function MacroManager_handle_delayed_macro(cmdParams)
    -- Use new robust manager
    return robust_manager.handle_delayed_macro(cmdParams)
end

--- Unified function for all jobs to setup macro book and lockstyle
--- Call this in select_default_macro_book() of each job
--- @param job_name string The job name (e.g., 'PLD', 'WAR')
--- @param sub_job string The subjob name (e.g., 'WAR', 'NIN')
--- @param show_message boolean Whether to show job change message
function setup_job_macro_lockstyle(job_name, sub_job, show_message)
    -- Safety check - make sure robust_manager is loaded
    if not robust_manager then
        local success_robust_manager, robust_manager = pcall(require, 'macros/MACRO_LOCKSTYLE_MANAGER')
        if not success_robust_manager then
            error("Failed to load macros/macro_lockstyle_manager: " .. tostring(robust_manager))
        end
    end

    -- Use new robust manager - it will detect job automatically
    -- Note: robust_manager uses 'silent' parameter, so we need to invert show_message
    local silent = not (show_message or false)

    if robust_manager.update_job_settings then
        robust_manager.update_job_settings(job_name, sub_job, silent)
    else
        robust_manager.initialize()
    end
end

--- Stop all macro/lockstyle operations immediately
--- Call this in file_unload() of each job
function stop_all_macro_lockstyle_operations()
    -- Safety check - make sure robust_manager is loaded
    if not robust_manager then
        local success_robust_manager, robust_manager = pcall(require, 'macros/MACRO_LOCKSTYLE_MANAGER')
        if not success_robust_manager then
            error("Failed to load macros/macro_lockstyle_manager: " .. tostring(robust_manager))
        end
    end

    -- Stop all operations
    robust_manager.stop_all()
end

-- Also set them in global table for backup
_G.MacroManager_select_macro_book = MacroManager_select_macro_book
_G.MacroManager_initialize = MacroManager_initialize
_G.MacroManager_handle_delayed_macro = MacroManager_handle_delayed_macro
_G.setup_job_macro_lockstyle = setup_job_macro_lockstyle
_G.stop_all_macro_lockstyle_operations = stop_all_macro_lockstyle_operations

-- Create module table to return
local MacroManager = {
    setup_job_macro_lockstyle = setup_job_macro_lockstyle,
    stop_all_macro_lockstyle_operations = stop_all_macro_lockstyle_operations,
    select_macro_book = MacroManager_select_macro_book,
    initialize = MacroManager_initialize,
    handle_delayed_macro = MacroManager_handle_delayed_macro
}

return MacroManager
