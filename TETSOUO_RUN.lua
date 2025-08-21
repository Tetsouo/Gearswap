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
--- @version 2.1
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
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')      -- Automatic movement speed gear management
    include('modules/SHARED.lua')        -- Shared utility functions across all jobs
    include('jobs/run/RUN_SET.lua')      -- RUN-specific equipment sets and resistances
    include('jobs/run/RUN_FUNCTION.lua') -- Advanced RUN job mechanics and rune logic

    -- Initialize universal metrics system
    -- Metrics system removed during cleanup
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
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F2 gs c cycle HybridMode')
        send_command('bind F3 gs c cycle WeaponSet')
        send_command('bind F4 gs c cycle SubSet')
    end, 0.5)

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
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
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
    -- First, try universal commands (equiptest, validate_all, etc.)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if success_UniversalCommands and UniversalCommands then
        if UniversalCommands.handle_command(cmdParams, eventArgs) then
            return
        end
    end
    
    -- Handle macro commands using centralized system
    -- MacroCommands now available globally via shared.lua
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'RUN') then
        return
    end

    -- Handle Kaories dual-box commands (debuff, bufftank, etc.)
    if handle_kaories_command and cmdParams[1] then
        local command = cmdParams[1]:lower()
        if handle_kaories_command(command) then
            eventArgs.handled = true
            return
        end
    end

    -- Run unit tests
    if cmdParams[1] == 'test' then
        -- MessageUtils now available globally via shared.lua
        MessageUtils.system_action_message('Executing GearSwap module tests...')
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
    -- Metrics system removed during cleanup


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
    -- Metrics system removed during cleanup


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
    -- Metrics system removed during cleanup


    -- Perform actions specific to the spell that was cast
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book and lockstyle for RUN
function select_default_macro_book()
    -- Load macro manager safely
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success then
            macro_manager = result
        else
            windower.add_to_chat(167, '[RUN] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('RUN', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end
