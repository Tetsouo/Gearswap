---============================================================================
--- FFXI GearSwap Configuration - Dragoon (DRG)
---============================================================================
--- Professional Dragoon job configuration with wyvern support, jump abilities,
--- and advanced weapon skill optimization. Features include:
---
--- • Intelligent equipment swapping based on combat state
--- • Wyvern-aware pet management and gear optimization
--- • Jump ability timing and recast management
--- • Advanced weapon skill customization with TP scaling
--- • Hybrid defense modes (PDT/Normal) for survivability
--- • Multiple weapon and grip configurations
--- • Automatic movement-based retaliation cancellation
---
--- @file Tetsouo_DRG.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2025-04-21 | Modified: 2025-08-05
--- @requires Mote-Include.lua, DRG_SET.lua, DRG_FUNCTION.lua
--- @requires modules/automove.lua, modules/shared.lua
---
--- @usage
---   F9:  Cycle HybridMode (PDT ⇆ Normal)
---   F10: Cycle WeaponSet (Trishula → Shining One → Ryunohige → Gungnir)
---   F11: Cycle SubSet (Utu Grip variants)
---   //gs c cycle [mode] - Manual mode cycling via chat commands
---============================================================================

--- Initialize GearSwap libraries and job-specific modules
--- This function is called once when the script loads and sets up all
--- necessary dependencies for the Dragoon job configuration
---
--- @usage Called automatically on script load - no manual invocation needed
function get_sets()
    mote_include_version = 2             -- Target Motenten Include v2 for compatibility
    include('Mote-Include.lua')          -- Core GearSwap framework
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')      -- Automatic movement speed gear management
    include('modules/SHARED.lua')        -- Shared utility functions across all jobs
    include('jobs/drg/DRG_SET.lua')      -- Dragoon-specific equipment sets
    include('jobs/drg/DRG_FUNCTION.lua') -- Advanced Dragoon job mechanics
    removeRetaliationOnLongMovement()    -- Auto-cancel retaliation on extended movement

    -- Initialize universal metrics system
    -- Metrics system removed during cleanup
end

--- Initialize equipment sets for Dragoon
--- Equipment sets are defined externally in DRG_SET.lua for modularity
--- This placeholder ensures compatibility with Mote-Include framework
---
--- @see jobs/drg/DRG_SET.lua for actual equipment definitions
function init_gear_sets()
    -- Equipment sets are loaded from external module
    -- This function exists for Mote-Include compatibility
end

---============================================================================
--- JOB CONFIGURATION SECTION
---============================================================================

--- Configure job-specific states, weapon sets, and keybindings
--- Sets up all user-configurable options and state variables for DRG
--- Called once during initialization to establish job behavior
---
--- @usage Called automatically by Mote-Include framework
function job_setup()
    -- Define hybrid defense mode options for survivability management
    state.HybridMode:options('PDT', 'Normal')

    -- Configure available weapon options with legendary weapons prioritized
    state.WeaponSet = M {
        ['description'] = 'Main Weapon',
        'Trishula',    -- Premier mythic polearm with exceptional damage
        'Shining One', -- Excalibur substitute for versatile content
        'Ryunohige',   -- Legendary polearm with high attack rating
        'Gungnir'      -- Classic dragoon spear with balanced stats
    }

    -- Sub-weapon and grip configurations for optimal stat distribution
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Utu Grip' }
    state.ammoSet = M { ['description'] = 'Ammo', 'Hagneia Stone' }

    -- Keybinding configuration for quick mode switching during combat
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F9 gs c cycle HybridMode') -- Toggle defense priority
        send_command('bind F10 gs c cycle WeaponSet') -- Cycle through weapons
        send_command('bind F11 gs c cycle SubSet')    -- Cycle sub-weapon options
    end, 0.5)
end

function user_setup()
    select_default_macro_book()
end

function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    send_command('unbind F9')
    send_command('unbind F10')
    send_command('unbind F11')
end

---============================================================================
--- SELF COMMAND HANDLER
---============================================================================

--- Handle custom console commands for Dragoon.
--- Provides specialized command handling for DRG-specific operations and testing.
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
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'DRG') then
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

    -- Add other DRG-specific commands here as needed
end

function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    -- Metrics system removed during cleanup


    handle_spell(spell, eventArgs, auto_abilities)
    checkDisplayCooldown(spell, eventArgs)
    Ws_range(spell)

    if spell.type == 'WeaponSkill' then
        local wsmode = get_custom_wsmode(spell, spellMap)
        local ws_set = sets.precast.WS[spell.english] or sets.precast.WS
        if wsmode and ws_set[wsmode] then
            equip(ws_set[wsmode])
        else
            equip(ws_set)
        end
        eventArgs.handled = true
    end
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    -- Metrics system removed during cleanup
end

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking
    -- Metrics system removed during cleanup


    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book and lockstyle for DRG
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
            windower.add_to_chat(167, '[DRG] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('DRG', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end
