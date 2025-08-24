---============================================================================
--- FFXI GearSwap Configuration - Thief (THF)
---============================================================================
--- Professional GearSwap configuration for Thief job in FFXI.
--- Provides advanced automation for gear swapping, Treasure Hunter optimization,
--- stealth ability management, and dual-boxing functionality.
---
--- @file Tetsouo_THF.lua
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
---   - jobs/thf/THF_SET.lua       : THF-specific equipment sets
---   - jobs/thf/THF_FUNCTION.lua  : THF-specific advanced functions
---   - Mote-TreasureHunter.lua    : Treasure Hunter automation framework
---
--- Features:
---   - Intelligent Treasure Hunter gear management with multiple modes
---   - Sneak Attack and Trick Attack buff tracking and optimization
---   - Abyssea proc mode for weakening procedures
---   - Dynamic weapon set switching for different combat scenarios
---   - Ranged attack treasure hunter support (RATH)
---   - Aeolian Edge treasure hunter optimization
---   - Sub-job specific macro book and lockstyle management
---   - Dual-boxing support for mage coordination
---   - TP-based weapon skill gear selection
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_THF
---   Unload with: //gs unload
---
--- Treasure Hunter Modes:
---   - None: No TH gear swapping
---   - Tag: TH gear on mob tagging only
---   - SATA: TH gear on Sneak/Trick Attack usage
---   - Fulltime: TH gear maintained constantly
---
--- Console Commands:
---   //gs c cycle TreasureMode : Toggle treasure hunter mode
---   //gs c cycle HybridMode  : Toggle defense mode (PDT/Normal/MDT)
---   //gs c cycle OffenseMode : Toggle accuracy mode (Normal/Acc)
---   //gs c cycle AbysseaProc : Toggle Abyssea proc mode
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary THF-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. THF equipment sets
---   5. THF advanced functions
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('features/DUALBOX.lua')          -- Dual-boxing utilities for alt job detection
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')      -- Module for movement speed gear management
    include('modules/SHARED.lua')        -- Shared functions across jobs
    include('jobs/thf/THF_SET.lua')      -- Thief specific gear sets
    include('jobs/thf/THF_FUNCTION.lua') -- Advanced functions specific to Thief

    -- Initialize universal metrics system
    -- Metrics system removed during cleanup
end

--- Initialize gear sets for Thief.
--- This function is intentionally minimal as gear sets are externally defined
--- in the THF_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/thf/THF_SET.lua For complete equipment set definitions
function init_gear_sets()
end

--- Configure user-specific settings and preferences.
--- Called after job_setup to handle user customizations and macro setup.
--- Primarily handles macro book selection based on subjob.
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance configuration
function user_setup()
    -- THF Keybindings F1-F6 for state cycling
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F1 gs c cycle WeaponSet1')    -- Cycle main weapon (Vajra/Malevolence/Dagger)
        send_command('bind F2 gs c cycle SubSet')        -- Cycle sub weapon (Centovente/Tanmogayi/Dagger2)
        send_command('bind F3 gs c cycle AbysseaProc')   -- Toggle Abyssea proc mode
        send_command('bind F4 gs c cycle WeaponSet2')    -- Cycle Abyssea proc weapon (Dagger/Sword/Great Sword/etc.)
        send_command('bind F5 gs c cycle HybridMode')    -- Cycle defense mode (PDT/Normal/MDT)
        send_command('bind F6 gs c cycle TreasureMode')  -- Cycle TH mode (None/Tag/SATA/Fulltime)
    end, 0.5)
    
    -- Initialize Keybind UI
    local success, KeybindUI = pcall(require, 'ui/KEYBIND_UI')
    if success then
        KeybindUI.init()
    end
    
    select_default_macro_book() -- Selects the default macro book based on sub-job
    
    -- Initialize dual-box alt job detection with delay
    send_command('wait 5; gs c altjob')
    
    -- Check and update macros after job detection
    send_command('wait 8; gs c macros')
end


---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and Treasure Hunter integration.
--- Initializes all THF-specific mechanics including buff tracking,
--- treasure hunter modes, weapon configurations, and dual-boxing states.
---
--- Key Features Configured:
---   - Treasure Hunter automation via Mote-TreasureHunter.lua
---   - Sneak Attack, Trick Attack, and Feint buff state tracking
---   - Hybrid and offense mode options for different combat scenarios
---   - Abyssea proc mode for endgame content
---   - Dynamic weapon set configurations
---   - Job ability ID mappings for TH automation
---   - Dual-boxing mage coordination states
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see Mote-TreasureHunter.lua For TH automation framework
function job_setup()
    include('Mote-TreasureHunter.lua') -- Includes the file for handling Treasure Hunter.
    -- Initializes the treasureHunter state variable from TreasureMode and sets default treasure mode
    treasureHunter = state.TreasureMode.value
    state.TreasureMode:set('tag')
    -- Sets up state variables for buffs
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    -- Configures hybrid and offense mode options
    state.HybridMode:options('PDT', 'Normal', 'MDT')
    state.OffenseMode:options('Normal', 'Acc')
    -- Define options for AbysseaProc mode
    state.AbysseaProc = M(false, 'Abyssea Proc')
    -- Configures gear sets for main and sub weapons
    state.WeaponSet1 = M { ['description'] = 'Main Weapon', 'Vajra', 'Malevolence', 'Dagger' }
    state.WeaponSet2 = M { ['description'] = 'Main Weapon', 'Dagger', 'Sword', 'Great Sword', 'Polearm', 'Club', 'Staff', 'Scythe' }
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Centovente', 'Tanmogayi', "Dagger2" }
    -- Sets up default job ability IDs for actions that always have Treasure Hunter
    info.default_ja_ids = S { 35, 204 }
    info.default_u_ja_ids = S { 201, 202, 203, 205, 207 }
    -- Defines options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi =
        M('Indi-Frailty', 'Indi-Refresh', 'Indi-Barrier', 'Indi-Fend', 'Indi-Fury', 'Indi-Acumen', 'Indi-Precision',
            'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Haste', 'Indi-Refresh', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle post-precast gear adjustments for Treasure Hunter optimization.
--- Applies specialized gear sets based on ability usage and TH mode settings.
--- Critical for maximizing treasure hunter effectiveness on key abilities.
---
--- Special Handling:
---   - Aeolian Edge: Equips TH-optimized nuke gear when TH is active
---   - Sneak/Trick Attack: Equips TH gear based on TreasureMode settings
---   - Range lock validation for distance-dependent abilities
---
--- @param spell table The spell or ability being used
--- @param action table The action being performed
--- @param spellMap string The type/classification of the spell or ability
--- @param eventArgs table Additional event arguments
--- @usage Automatically called by GearSwap after precast gear selection
--- @see check_range_lock For distance validation
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Equip AeolianTH gear set if 'Aeolian Edge' is being used and Treasure Hunter is active.
    if spell.english == 'Aeolian Edge' and treasureHunter ~= 'None' then
        -- Preserve the ear2 that was set by adjust_Gear_Based_On_TP_For_WeaponSkill
        local saved_ear2 = sets.precast.WS[spell.english] and sets.precast.WS[spell.english].ear2
        equip(sets.AeolianTH)
        if saved_ear2 then
            equip({ ear2 = saved_ear2 })
        end
    elseif spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
    check_range_lock()
end

--- Handle pre-casting logic with comprehensive ability management.
--- Performs multiple validation and optimization steps before ability execution:
--- - Spell handling and auto-ability coordination
--- - Cooldown checking and display
--- - Utsusemi shadow management
--- - TP-based weapon skill gear optimization
--- - Buff state tracking and updates
--- - Range validation for distance-dependent abilities
---
--- @param spell table The spell or ability being cast
--- @param action table The action object containing execution details
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell/ability execution
--- @see handle_spell For comprehensive spell processing
--- @see adjust_Gear_Based_On_TP_For_WeaponSkill For WS optimization
function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    -- Metrics system removed during cleanup

    handle_spell(spell, eventArgs, auto_abilities) -- Handles the spell based on its type and the current state.
    checkDisplayCooldown(spell, eventArgs)         -- Central system handles ALL spells/abilities including SA/TA AND Utsusemi
    refine_utsusemi(spell, eventArgs)              -- Refines the Utsusemi spell if it's being cast (THF version)
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell) -- Selects the earrings based on the weapon and TP.
    -- Sets the state for the buff corresponding to the spell being cast to true, if it exists.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end


    Ws_range(spell)
end

--- Handle mid-casting gear adjustments for ranged Treasure Hunter.
--- Applies specialized RATH (Ranged Attack Treasure Hunter) gear when
--- performing ranged attacks while Treasure Hunter mode is active.
---
--- Implementation:
---   Only activates when TreasureMode is not 'None' and action type
---   is 'Ranged Attack', ensuring optimal TH proc chances on ranged hits.
---
--- @param spell table The spell or ability being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
--- @see sets.precast.RATH For ranged TH gear configuration
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- If Treasure Mode is active and a ranged attack is being performed, equip the RATH gear set.
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

--- Handle post-casting cleanup and buff state management.
--- Manages buff state transitions after ability execution and handles
--- special cases like weapon skill buff consumption.
---
--- Buff State Management:
---   - Updates buff states based on spell interruption status
---   - Automatically resets Sneak Attack, Trick Attack, and Feint
---     states after successful weapon skill usage
---   - Maintains accurate buff tracking for gear optimization
---
--- @param spell table The spell or ability that was executed
--- @param action table The action object that was performed
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell/ability completion
--- @see handleSpellAftercast For shared aftercast processing
-- Add midcast function for metrics tracking
function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    -- Metrics system removed during cleanup
end

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking
    -- Metrics system removed during cleanup


    -- If a buff corresponding to the spell exists, update its state based on whether the spell was interrupted or the buff is active.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end

    -- If a WeaponSkill was successfully used, reset the state of 'Sneak Attack', 'Trick Attack', and 'Feint' buffs.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end

    -- Perform additional actions after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book using the centralized macro manager
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
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
            windower.add_to_chat(167, '[THF] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('THF', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end

---============================================================================
--- SELF COMMAND HANDLER
---============================================================================

--- Handle custom console commands for Thief.
--- Provides specialized command handling for THF-specific operations and testing.
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
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'THF') then
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

    -- Add other THF-specific commands here as needed
end

---============================================================================
--- CLEANUP AND RESOURCE MANAGEMENT
---============================================================================

--- Clean up resources and unbind keys when unloading THF configuration.
--- Ensures proper cleanup of key bindings and prevents conflicts when
--- switching between different job configurations.
---
--- Cleanup Operations:
---   - Unbinds all THF-specific function key bindings (F1-F6)
---   - Clears any THF-specific state variables
---   - Performs safe resource cleanup
---
--- @usage Automatically called by GearSwap when unloading job configuration
--- @see user_setup For corresponding setup operations
function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    -- Unbind all THF-specific F1-F6 keys
    send_command('unbind F1') -- WeaponSet1 cycling
    send_command('unbind F2') -- SubSet cycling  
    send_command('unbind F3') -- AbysseaProc toggle
    send_command('unbind F4') -- WeaponSet2 cycling
    send_command('unbind F5') -- HybridMode cycling
    send_command('unbind F6') -- TreasureMode cycling
end
