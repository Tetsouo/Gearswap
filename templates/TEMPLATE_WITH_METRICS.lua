---============================================================================
--- FFXI GearSwap Configuration Template - With Integrated Metrics
---============================================================================
--- Template job file with built-in metrics tracking system.
--- Copy this file and rename it to Tetsouo_[JOB].lua
---
--- @file TEMPLATE_WITH_METRICS.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('core/globals.lua')
    include('modules/automove.lua')
    include('modules/shared.lua')
    include('jobs/[job]/[JOB]_SET.lua')      -- Replace [job] and [JOB] with actual job
    include('jobs/[job]/[JOB]_FUNCTION.lua') -- Replace [job] and [JOB] with actual job
    
    -- Initialize universal metrics system
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.initialize()
end

function init_gear_sets()
    -- All gear sets are defined in jobs/[job]/[JOB]_SET.lua
end

---============================================================================
--- JOB SETUP AND CONFIGURATION
---============================================================================

function job_setup()
    -- Job-specific setup here
end

function user_setup()
    -- User preferences and keybindings
    select_default_macro_book()
end

function file_unload()
    -- Clean up keybindings
end

---============================================================================
--- CUSTOM COMMAND HANDLER
---============================================================================

function job_self_command(cmdParams, eventArgs)
    -- Universal metrics system commands
    local MetricsIntegration = require('core/metrics_integration')
    if MetricsIntegration.handle_command(cmdParams, eventArgs) then
        return
    end
    
    -- Add other job-specific commands here
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast - ALWAYS INCLUDE THIS
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_precast(spell, action, spellMap, eventArgs)
    
    -- Precast logic here
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast - ALWAYS INCLUDE THIS
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_midcast(spell, action, spellMap, eventArgs)
    
    -- Midcast logic here
end

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Handle shared aftercast processing
    handleSpellAftercast(spell, eventArgs)
    
    -- Universal metrics tracking for aftercast - ALWAYS INCLUDE THIS
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.track_action(spell, eventArgs)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

function select_default_macro_book()
    set_macro_page(1, 1) -- Adjust for job
end