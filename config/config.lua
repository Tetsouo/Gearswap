---============================================================================
--- FFXI GearSwap Configuration Manager
---============================================================================
--- Centralized configuration loading and management system for GearSwap.
--- Provides safe settings loading, validation, and convenient access methods
--- for all configuration data across the entire GearSwap ecosystem.
---
--- @file config.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05
--- @date Modified: 2025-08-05
--- @requires config/settings.lua
--- @requires Windower FFXI
---
--- Features:
---   - Safe configuration loading with error handling and fallbacks
---   - Automatic settings validation with detailed error reporting
---   - Dot-notation path access for nested configuration values
---   - Convenient helper functions for common configuration queries
---   - Player name management for dual-boxing scenarios
---   - Debug and logging configuration management
---   - Movement detection parameter configuration
---   - UI color scheme management
---   - Job-specific configuration support
---
--- Usage:
---   local config = require('config/config')
---   local main_player = config.get_main_player()
---   local debug_enabled = config.is_debug_enabled()
---   local custom_value = config.get('jobs.war.weapon_priority')
---
--- Error Handling:
---   - Graceful fallback to default settings if settings.lua fails to load
---   - Comprehensive validation with detailed error messages
---   - Non-breaking operation when accessing undefined configuration paths
---
--- Thread Safety:
---   This module is designed to be loaded once and accessed read-only
---   during normal operation. Configuration changes should be rare and
---   typically require a GearSwap reload.
---============================================================================

---============================================================================
--- MODULE INITIALIZATION
---============================================================================

--- @type table Main configuration module table
local config = {}

---============================================================================
--- CORE CONFIGURATION LOADING
---============================================================================

--- Load and validate configuration settings from external file.
--- Implements comprehensive error handling and fallback mechanisms
--- to ensure the GearSwap system remains functional even with
--- configuration issues.
---
--- @return table The loaded and validated settings table
--- @see config/settings.lua For the actual configuration definitions
local function load_settings()
    local success, settings = pcall(function()
        return require('config/settings')
    end)
    
    if not success then
        windower.add_to_chat(167, "ERROR: Failed to load settings.lua")
        -- Return default settings
        return {
            players = { main = 'Player', alt = 'AltPlayer' },
            debug = { enabled = false, level = 'INFO' },
            movement = { threshold = 1.0, check_interval = 15 },
            ui = { colors = { error = 167, warning = 057, info = 050 } },
        }
    end
    
    -- Validate settings
    local valid, errors = settings:validate()
    if not valid then
        windower.add_to_chat(167, "ERROR: Invalid settings:")
        for _, error in ipairs(errors) do
            windower.add_to_chat(167, "  - " .. error)
        end
    end
    
    return settings
end

--- Initialize configuration system
config.settings = load_settings()

---============================================================================
--- CONFIGURATION ACCESS METHODS
---============================================================================

--- Get a configuration value using dot-notation path.
--- Safely navigates nested configuration structures without throwing
--- errors if intermediate keys don't exist.
---
--- @param path string Dot-separated path to the configuration value
--- @return any|nil The configuration value, or nil if path doesn't exist
--- @usage
---   local weapon = config.get('jobs.war.default_weapon')
---   local color = config.get('ui.colors.error')
function config.get(path)
    local value = config.settings
    for part in path:gmatch("[^.]+") do
        value = value[part]
        if value == nil then
            return nil
        end
    end
    return value
end

--- Set a configuration value using dot-notation path.
--- Dynamically updates configuration values at runtime.
--- Note: Changes are not persisted to disk and will be lost on reload.
---
--- @param path string Dot-separated path to the configuration value
--- @param new_value any The new value to set
--- @return boolean True if successful, false if path is invalid
--- @usage
---   config.set('debug.enabled', true)
---   config.set('movement.threshold', 0.5)
function config.set(path, new_value)
    local parts = {}
    for part in path:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    local current = config.settings
    for i = 1, #parts - 1 do
        current = current[parts[i]]
        if current == nil then
            return false
        end
    end
    
    current[parts[#parts]] = new_value
    return true
end

---============================================================================
--- PLAYER MANAGEMENT HELPERS
---============================================================================

--- Get the main player character name.
--- Used throughout the system to identify the primary character
--- in dual-boxing and multi-character scenarios.
---
--- @return string The main player character name
function config.get_main_player()
    return config.settings.players.main
end

--- Get the alternative player character name.
--- Used for dual-boxing coordination and multi-character automation.
---
--- @return string The alternative player character name
function config.get_alt_player()
    return config.settings.players.alt
end

---============================================================================
--- DEBUG AND LOGGING HELPERS
---============================================================================

--- Check if debug mode is enabled.
--- Used throughout the system to conditionally enable verbose logging
--- and debug output.
---
--- @return boolean True if debug mode is enabled
function config.is_debug_enabled()
    return config.settings.debug.enabled
end

--- Get the current debug logging level as a numeric value.
--- Returns a numeric representation of the logging level for
--- efficient level comparison in logging systems.
---
--- @return number Debug level (1=ERROR, 2=WARN, 3=INFO, 4=DEBUG)
function config.get_debug_level()
    local levels = {ERROR=1, WARN=2, INFO=3, DEBUG=4}
    return levels[config.settings.debug.level] or 2
end

---============================================================================
--- MOVEMENT DETECTION HELPERS
---============================================================================

--- Get the movement detection threshold.
--- Used by the automatic movement detection system to determine
--- when movement-based gear swapping should occur.
---
--- @return number Movement threshold in in-game distance units
function config.get_movement_threshold()
    return config.settings.movement.threshold
end

--- Get the movement check interval.
--- Determines how frequently the movement detection system
--- should check for player position changes.
---
--- @return number Check interval in seconds
function config.get_movement_check_interval()
    return config.settings.movement.check_interval
end

---============================================================================
--- USER INTERFACE HELPERS
---============================================================================

--- Get a UI color code for chat messages.
--- Provides consistent color schemes across all system messages
--- with fallback to default if color type is not defined.
---
--- @param color_type string The type of color (error, warning, info, etc.)
--- @return number Windower chat color code
function config.get_color(color_type)
    return config.settings.ui.colors[color_type] or 050
end

---============================================================================
--- JOB-SPECIFIC CONFIGURATION HELPERS
---============================================================================

--- Get a specific setting for a particular job.
--- Allows job-specific customization of behavior while maintaining
--- a consistent configuration interface.
---
--- @param job string The job abbreviation (e.g., 'war', 'pld', 'blm')
--- @param setting string The specific setting name
--- @return any|nil The job setting value, or nil if not defined
function config.get_job_setting(job, setting)
    if config.settings.jobs[job] then
        return config.settings.jobs[job][setting]
    end
    return nil
end

--- Get the complete configuration for a specific job.
--- Returns the entire configuration table for a job, allowing
--- bulk access to all job-specific settings.
---
--- @param job string The job abbreviation (e.g., 'war', 'pld', 'blm')
--- @return table The complete job configuration table
function config.get_job_config(job)
    return config.settings.jobs[job] or {}
end

return config