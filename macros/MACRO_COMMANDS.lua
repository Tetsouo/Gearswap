---============================================================================
--- FFXI GearSwap Macro Command System
---============================================================================
--- Centralized macro command system for all jobs.
--- Handles dynamic macro book changes in response to alt character (Kaories)
--- job changes.
---
--- @file core/macro_commands.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-16
--- @requires config/config.lua
---
--- Usage:
---   In job_self_command of each job:
---   local MacroCommands = require('core/MACRO_COMMANDS')
---   if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'JOB_NAME') then
---       return
---   end
---
--- Features:
---   - //gs c macros command for dynamic updates
---   - Automatic reading of Kaories job
---   - Intelligent dual-box vs solo selection
---   - Unified informational messages
---   - Protection against multiple executions
---============================================================================

local MacroCommands = {}

---============================================================================
--- HANDLE MACRO COMMAND
---============================================================================

--- Handles the 'macros' command for a specific job
--- @param cmdParams table Command parameters
--- @param eventArgs table Event arguments
--- @param job_name string Job name (THF, DNC, WAR, etc.)
--- @param silent boolean If true, suppress status messages
--- @return boolean True if command was handled
function MacroCommands.handle_macro_command(cmdParams, eventArgs, job_name, silent)
    if not cmdParams or not cmdParams[1] then
        return false
    end

    local command = cmdParams[1]:lower()

    -- Check if this is the macros command
    if command ~= 'macros' then
        return false
    end

    -- Only respond if this is the current job
    if not player or player.main_job ~= job_name then
        return false
    end

    -- Protection against multiple executions
    if _G._macro_command_running then
        return true
    end
    _G._macro_command_running = true

    -- Execute macro update
    MacroCommands.update_macro_book(job_name, silent)

    -- Reset flag after execution
    _G._macro_command_running = false

    -- Mark command as handled
    if eventArgs then
        eventArgs.handled = true
    end

    return true
end

---============================================================================
--- UPDATE MACRO BOOK
---============================================================================

--- Updates macro book based on centralized configuration
--- @param job_name string Job name
--- @param silent boolean If true, suppress status messages
function MacroCommands.update_macro_book(job_name, silent)
    -- Load centralized configuration
    local success_config, config = pcall(require, 'config/config')
    if not success_config then
        error("Failed to load config/config: " .. tostring(config))
    end
    if not config then
        add_to_chat(167, '[Macro Commands] Configuration not found')
        return
    end

    -- Read alt job dynamically
    local alt_job = MacroCommands.read_alt_job()

    -- Get current subjob
    local sub_job = player.sub_job or 'WAR'

    -- Try dual-box configuration first
    local dual_config = config.get_dual_box_macro(job_name, sub_job, alt_job)
    if dual_config then
        set_macro_page(dual_config.page, dual_config.book)

        -- Display update message (only if not silent)
        if not silent then
            local main_job = player.main_job or job_name
            local selection_reason = main_job .. "/" .. sub_job .. " + " .. alt_job
            add_to_chat(050, '[Dual-Box] ' .. selection_reason .. ' -> Macro Book ' .. dual_config.book)
        end

        return
    end

    -- Fallback to solo configuration
    local solo_config = config.get_solo_macro(job_name, player.sub_job)
    if solo_config then
        set_macro_page(solo_config.page, solo_config.book)

        -- Display update message (only if not silent)
        if not silent then
            local main_job = player.main_job or job_name
            local sub_job = player.sub_job or 'WAR'
            local selection_reason = main_job ..
            "/" .. sub_job .. (alt_job and (" (Alt: " .. alt_job .. " not configured)") or " (Solo)")
            add_to_chat(050, '[Dual-Box] ' .. selection_reason .. ' -> Macro Book ' .. solo_config.book)
        end

        return
    end

    -- No configuration found
    add_to_chat(167, '[Macro Commands] No configuration found for ' .. job_name)
end

---============================================================================
--- READ ALT JOB
---============================================================================

--- Reads alt job from kaories_job.txt file
--- @return string|nil Alt job or nil if not found
function MacroCommands.read_alt_job()
    local file = io.open('kaories_job.txt', 'r')
    if not file then
        return nil
    end

    local alt_job = file:read('*all')
    file:close()

    if alt_job then
        alt_job = alt_job:gsub('%s+', '') -- Remove whitespace
        if alt_job ~= '' then
            return alt_job
        end
    end

    return nil
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MacroCommands
