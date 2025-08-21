---============================================================================
--- FFXI GearSwap Configuration - Dancer (DNC)
---============================================================================
--- Professional GearSwap configuration for Dancer job in FFXI.
--- Provides advanced automation for step management, flourish tracking,
--- treasure hunter optimization, and dual-boxing functionality.
---
--- @file Tetsouo_DNC.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires Mote-TreasureHunter.lua
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- Dependencies:
---   - modules/automove.lua        : Automatic movement detection and gear swapping
---   - modules/shared.lua          : Shared utility functions across jobs
---   - jobs/dnc/DNC_SET.lua       : DNC-specific equipment sets
---   - jobs/dnc/DNC_FUNCTION.lua  : DNC-specific advanced functions
---   - Mote-TreasureHunter.lua    : Treasure Hunter automation framework
---
--- Features:
---   - Intelligent step management with main/alt step rotation
---   - Flourish buff tracking (Climactic, Building, Ternary)
---   - Treasure Hunter integration with step/flourish coordination
---   - Dynamic weapon set switching for different combat scenarios
---   - Step target selection automation
---   - Skillchain coordination and timing
---   - Hybrid defense mode management (PDT/Normal)
---   - Accuracy mode switching for different content
---   - Dual-boxing support for mage coordination
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_DNC
---   Unload with: //gs unload
---
--- Step Management:
---   - Main Step: Primary step for debuffing (Box Step, Quickstep, etc.)
---   - Alt Step: Secondary step for additional effects
---   - Auto target selection for optimal step application
---
--- Console Commands:
---   //gs c cycle TreasureMode : Toggle treasure hunter mode
---   //gs c cycle HybridMode  : Toggle defense mode (PDT/Normal)
---   //gs c cycle OffenseMode : Toggle accuracy mode (Normal/Acc)
---   //gs c cycle WeaponSet   : Change main weapon configuration
---   //gs c cycle SubSet      : Change sub weapon configuration
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary DNC-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. DNC equipment sets
---   5. DNC advanced functions
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('core/GLOBALS.lua')
    include('features/DUALBOX.lua')          -- Dual-boxing utilities for alt job detection
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('modules/AUTOMOVE.lua')      -- Module for movement speed gear management
    include('modules/SHARED.lua')        -- Shared functions across jobs
    include('jobs/dnc/DNC_SET.lua')      -- Dancer specific gear sets
    include('jobs/dnc/DNC_FUNCTION.lua') -- Advanced functions specific to Dancer

    -- Initialize universal metrics system
    -- Metrics system removed during cleanup
end

--- Initialize gear sets for Dancer.
--- This function is intentionally minimal as gear sets are externally defined
--- in the DNC_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/dnc/DNC_SET.lua For complete equipment set definitions
function init_gear_sets()
end

---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and Dancer mechanics.
--- Initializes all DNC-specific mechanics including step management,
--- flourish tracking, treasure hunter modes, and dual-boxing states.
---
--- Key Features Configured:
---   - Treasure Hunter automation via Mote-TreasureHunter.lua
---   - Flourish buff state tracking (Climactic, Building, Ternary)
---   - Step management system with main/alt step rotation
---   - Dynamic weapon and sub weapon configurations
---   - Hybrid and offense mode options
---   - Step target selection automation
---   - Skillchain coordination timing
---   - Dual-boxing mage coordination states
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see Mote-TreasureHunter.lua For TH automation framework
function job_setup()
    include('Mote-TreasureHunter.lua') -- Includes the file for handling Treasure Hunter.
    -- Initializes the treasureHunter state variable from TreasureMode and sets default treasure mode
    treasureHunter = state.TreasureMode.value
    state.TreasureMode:set('tag')
    -- Configures hybrid and offense mode options
    state.HybridMode:options('PDT', 'Normal')
    state.OffenseMode:options('Normal', 'Acc')
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Twashtar', 'Mpu Gandring', 'Demersal', 'Tauret' } --gs c cycle WeaponSet
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Centovente', 'Blurred', 'Gleti' }                     --gs c cycle SubSet
    state.ammoSet = M { ['description'] = 'Ammo', 'Aurgelmir' }                                               --gs c cycle SubSet
    climactic = buffactive['climactic flourish'] or false
    building = buffactive['building flourish'] or false
    ternary = buffactive['ternary flourish'] or false
    state.MainStep = M { ['description'] = 'Main Step', 'Box Step', 'Quickstep', 'Stutter Step', 'Feather Step' }
    state.AltStep = M { ['description'] = 'Alt Step', 'Feather Step', 'Quickstep', 'Stutter Step', 'Box Step' }
    state.UseAltStep = M(true, 'Use Alt Step')
    state.SelectStepTarget = M(true, 'Select Step Target')
    state.CurrentStep = M { ['description'] = 'Current Step', 'Main', 'Alt' }
    state.SkillchainPending = M(false, 'Skillchain Pending')
    state.Buff['Climactic Flourish'] = buffactive['Climactic Flourish'] or false
    -- Defines options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Barrier', 'Indi-Refresh', 'Indi-Fend', 'Indi-Fury', 'Indi-Acumen', 'Indi-Precision',
        'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Refresh', 'Indi-Haste', 'Indi-AGI', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
    -- Sets up default job ability IDs for actions that always have Treasure Hunter
    info.default_ja_ids = S { 35, 204 }
    info.default_u_ja_ids = S { 201, 202, 203, 205, 207 }
end

function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

---============================================================================
--- FILE UNLOAD AND SELF COMMAND HANDLER
---============================================================================

--- Clean up resources when unloading the GearSwap file.
--- Currently no specific cleanup required for DNC.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    -- Add any DNC-specific cleanup here if needed
end

--- Handle custom console commands for Dancer.
--- Provides specialized command handling for DNC-specific operations and testing.
---
--- Available Commands:
---   test : Execute GearSwap module unit tests
---
--- @param cmdParams table Array of command parameters
--- @param eventArgs table Event arguments for command handling
--- @usage //gs c test (runs unit tests)
function job_self_command(cmdParams, eventArgs)
    -- Handle macro commands using centralized system
    -- MacroCommands now available globally via shared.lua
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'DNC') then
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

    -- Add other DNC-specific commands here as needed
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    -- Metrics system removed during cleanup


    handle_spell(spell, eventArgs, auto_abilities) -- Handles the spell based on its type and the current state.
    checkDisplayCooldown(spell, eventArgs)         -- Checks and displays the cooldown for the spell.
    refine_Utsusemi(spell, eventArgs)
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell) -- Selects the earrings based on the weapon and TP.
    handle_presto_and_step(spell, eventArgs)
    auto_WS_flourish(spell)
    Ws_range(spell)
    -- Sets the state for the buff corresponding to the spell being cast to true, if it exists.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
end

-- Add midcast function for metrics tracking
function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    -- Metrics system removed during cleanup
end

-- Return true if we handled the aftercast work.  Otherwise it will fall back
-- to the general aftercast() code in Mote-Include.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking
    -- Metrics system removed during cleanup


    if not spell.interrupted then
        if state.Buff[spell.english] ~= nil then
            state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
        end
    end
    -- Perform additional actions after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book - with Kaories detection but no loops
function select_default_macro_book()
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success then
            macro_manager = result
        else
            windower.add_to_chat(167, '[DNC] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    if macro_manager.setup_job_macro_lockstyle then
        macro_manager.setup_job_macro_lockstyle('DNC', player.sub_job, true) -- true = show message
    elseif MacroManager_select_macro_book then
        MacroManager_select_macro_book(nil, nil, false) -- false = show message
    else
        windower.add_to_chat(167, '[DNC] No macro management function available')
    end
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end
