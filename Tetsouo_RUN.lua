---============================================================================
--- FFXI GearSwap Configuration - Rune Fencer (RUN)
---============================================================================
--- Professional Rune Fencer job configuration with elemental resistance
--- management, rune enhancement optimization, and hybrid tanking capabilities.
--- Features include:
---
--- • **Elemental Resistance Management** - Dynamic rune selection and stacking
--- • **Ward/Barrier Optimization** - Spell timing and potency enhancement
--- • **Hybrid Tank/DD Modes** - PDT/MDT switching with offensive capabilities
--- • **Elemental Weapon Skills** - Damage type optimization for encounters
--- • **Rune Duration Tracking** - Visual and logical rune state management
--- • **Spell Interruption Recovery** - Intelligent recasting and error handling
--- • **Multi-Element Strategy** - Complex rune combinations for specific fights
---
--- @file Tetsouo_RUN.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Mote-Include.lua, RUN_SET.lua, RUN_FUNCTION.lua
--- @requires modules/automove.lua, modules/shared.lua
---
--- @usage
---   F2:  Cycle HybridMode (PDT ⇆ MDT)
---   F3:  Cycle WeaponSet (Aettir variants)
---   F4:  Cycle SubSet (Refined Grip +1 ⇆ Utu Grip)
---   //gs c cycle [mode] - Manual mode cycling via chat commands
---
--- @see jobs/run/RUN_FUNCTION.lua for rune management algorithms
--- @see jobs/run/RUN_SET.lua for elemental resistance equipment sets
---============================================================================

--- Initialize GearSwap libraries and job-specific modules for Rune Fencer
--- Sets up all necessary dependencies including elemental resistance management,
--- rune tracking systems, and hybrid tanking/damage dealer capabilities
---
--- @usage Called automatically on script load - no manual invocation needed
function get_sets()
    mote_include_version = 2             -- Target Motenten Include v2 for compatibility
    include('Mote-Include.lua')          -- Core GearSwap framework with RUN support
    include('core/globals.lua')
    include('modules/automove.lua')      -- Automatic movement speed gear management
    include('modules/shared.lua')        -- Shared utility functions across all jobs
    include('jobs/run/RUN_SET.lua')      -- RUN-specific equipment sets and resistances
    include('jobs/run/RUN_FUNCTION.lua') -- Advanced RUN job mechanics and rune logic
    
    -- Initialize universal metrics system
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.initialize()
end

--- Initialize equipment sets for Rune Fencer
--- Equipment sets are defined externally in RUN_SET.lua for modularity
--- This placeholder ensures compatibility with Mote-Include framework
---
--- @see jobs/run/RUN_SET.lua for actual equipment definitions
function init_gear_sets()
    -- Equipment sets are loaded from external module
    -- This function exists for Mote-Include compatibility
end

---============================================================================
--- USER CONFIGURATION SECTION
---============================================================================

--- Configure user-specific preferences and macro book selection
--- Called after job setup to apply user customizations and initialize
--- macro books and lockstyles based on subjob configuration
---
--- @usage Called automatically by Mote-Include framework
function user_setup()
    select_default_macro_book() -- Initialize macro book and lockstyle for current subjob
end

--- Configure job-specific states, rune management, and keybindings
--- Sets up all user-configurable options and state variables for RUN
--- Called once during initialization to establish job behavior patterns
---
--- @usage Called automatically by Mote-Include framework
function job_setup()
    -- Define options for hybrid mode
    state.HybridMode:options('PDT', 'MDT')
    -- Define options for main weapon set
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Aettir', }
    -- Define options for sub weapon set
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Refined Grip +1', 'Utu Grip' }
    -- Define options for XP mode
    state.Xp = M { ['description'] = 'XP', 'False', 'True' }
    -- Bind keys to cycle through modes and sets
    send_command('bind F2 gs c cycle HybridMode')
    send_command('bind F3 gs c cycle WeaponSet')
    send_command('bind F4 gs c cycle SubSet')

    -- Define options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Haste', 'Geo-Malaise', 'Geo-Frailty',
        'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Refresh', 'Indi-Acumen', 'Indi-Fury')
    state.altPlayerEntrust = M('Indi-Fury', 'Indi-Refresh', 'Indi-Haste', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end

-- Handles the unload event when changing job or reloading the script.
-- This function is called once when the script is unloaded.
function file_unload()
    -- Unbind the keys associated with the hybrid mode, weapon set, and sub weapon set.
    send_command('unbind F2') -- Unbind key for cycling hybrid mode
    send_command('unbind F3') -- Unbind key for cycling main weapon set
    send_command('unbind F4') -- Unbind key for cycling sub weapon set
end

---============================================================================
--- SELF COMMAND HANDLER
---============================================================================

--- Handle custom console commands for Rune Fencer.
--- Provides specialized command handling for RUN-specific operations and testing.
---
--- Available Commands:
---   test : Execute GearSwap module unit tests
---
--- @param cmdParams table Array of command parameters
--- @param eventArgs table Event arguments for command handling
--- @usage //gs c test (runs unit tests)
function job_self_command(cmdParams, eventArgs)
    -- Universal metrics system commands
    local MetricsIntegration = require('core/metrics_integration')
    if MetricsIntegration.handle_command(cmdParams, eventArgs) then
        return
    end
    
    -- Run unit tests
    if cmdParams[1] == 'test' then
        windower.add_to_chat(050, "Executing GearSwap module tests...")
        include('test_runner.lua')
        eventArgs.handled = true
        return
    end

    -- Add other RUN-specific commands here as needed
end

-- Initializes the gear sets for the Paladin job.
-- This function is called once when the script is loaded.
function init_gear_sets()
    -- The actual gear sets are defined in the PLD_SET.lua file.
end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_precast(spell, action, spellMap, eventArgs)
    
    -- If the spell is Phalanx, call the handle_phalanx_while_xp function
    if spell.name == 'Phalanx' then
        handle_phalanx_while_xp(spell, eventArgs)
    end
    -- Handle the spell casting
    handle_spell(spell, eventArgs, auto_abilities)
    -- Check and display the recast cooldown
    checkDisplayCooldown(spell, eventArgs)
end

-- Handles actions to perform during the casting of a spell or ability.
-- This function is called after the precast phase and before the aftercast phase.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_midcast(spell, action, spellMap, eventArgs)
    
    -- Check if the player is incapacitated
    --[[ incapacitated(spell, eventArgs) ]]
end

-- Handles actions to perform after the casting of a spell or ability.
-- This function is called after the spell or ability has been cast.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.track_action(spell, eventArgs)
    
    -- Perform actions specific to the spell that was cast
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book and lockstyle for RUN
function select_default_macro_book()
    send_command('lua unload dressup')

    -- RUN macro pages based on subjob
    local macro_page = ({ BLU = 23, WAR = 21, RDM = 28 })[player.sub_job] or 23
    set_macro_page(1, macro_page)

    -- RUN lockstyle
    send_command('wait 3; input /lockstyleset 3')

    -- Reload dressup with delay to avoid macro loss
    send_command('wait 20; lua load dressup')
end
