---============================================================================
--- FFXI GearSwap Configuration - Paladin (PLD)
---============================================================================
--- Professional GearSwap configuration for Paladin job in FFXI.
--- Provides advanced automation for gear swapping, tank optimization,
--- defensive mode management, and dual-boxing functionality.
---
--- @file Tetsouo_PLD.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- Dependencies:
---   - modules/automove.lua        : Automatic movement detection and gear swapping
---   - modules/shared.lua          : Shared utility functions across jobs
---   - jobs/pld/PLD_SET.lua       : PLD-specific equipment sets
---   - jobs/pld/PLD_FUNCTION.lua  : PLD-specific advanced functions
---
--- Features:
---   - Intelligent hybrid defense mode switching (PDT/MDT)
---   - Dynamic weapon and shield set management
---   - Phalanx optimization with experience point mode integration
---   - Spell tracking for buff management and optimization
---   - Rune element selection for support job compatibility
---   - Sub-job specific macro book and lockstyle management
---   - Dual-boxing support for mage coordination
---   - Experience point gain optimization mode
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_PLD
---   Unload with: //gs unload
---
--- Key Bindings:
---   F9  : Cycle Hybrid Mode (PDT ⇆ MDT)
---   F10 : Cycle Weapon Set
---   F11 : Cycle Sub Weapon/Shield Set
---
--- Console Commands:
---   //gs c cycle HybridMode : Toggle defense mode
---   //gs c cycle WeaponSet  : Change main weapon configuration
---   //gs c cycle SubSet     : Change shield/sub weapon configuration
---   //gs c cycle Xp         : Toggle experience point optimization
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary PLD-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. PLD equipment sets
---   5. PLD advanced functions
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    -- Include necessary libraries and modules
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')      -- Module for movement speed gear management
    include('modules/SHARED.lua')        -- Shared functions across jobs
    include('jobs/pld/PLD_SET.lua')      -- Paladin specific gear sets
    include('jobs/pld/PLD_FUNCTION.lua') -- Advanced functions specific to Paladin

    -- Initialize universal metrics system
    -- Metrics system removed during cleanup
end

--- Initialize gear sets for Paladin.
--- This function is intentionally minimal as gear sets are externally defined
--- in the PLD_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/pld/PLD_SET.lua For complete equipment set definitions
function init_gear_sets()
end

--- Configure user-specific settings and preferences.
--- Called after job_setup to handle user customizations and macro setup.
--- Primarily handles macro book selection based on subjob.
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance configuration
function user_setup()
    -- Bind F2 and F3 here (states already created in job_setup)
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F2 gs c cycle WeaponSet')
        send_command('bind F3 gs c cycle SubSet')
    end, 0.5)
    
    -- Initialize Keybind UI
    local success, KeybindUI = pcall(require, 'ui/KEYBIND_UI')
    if success then
        KeybindUI.init()
    end
    
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and keybinding management.
--- Initializes all PLD-specific mechanics including defense modes,
--- weapon configurations, experience optimization, and dual-boxing states.
---
--- Key Features Configured:
---   - Hybrid defense modes (PDT for physical, MDT for magical damage)
---   - Dynamic weapon set switching (Burtgang, Shining One, Naegling, Malevo)
---   - Shield/sub weapon configurations (Duban, Aegis, Alber)
---   - Experience point optimization toggle
---   - Rune element selection for RUN subjob compatibility
---   - Dual-boxing mage coordination states
---   - Function key bindings for quick mode switching
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see file_unload For cleanup of keybindings
function job_setup()
    -- Define options for hybrid mode
    state.HybridMode:options('PDT', 'MDT')
    -- Define options for XP mode
    state.Xp = M { ['description'] = 'XP', 'False', 'True' }
    
    -- Define custom states for weapons and shields (MOVED FROM user_setup)
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Burtgang', 'Shining One', 'Naegling', 'Malevo' }
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Duban', 'Aegis', 'Alber' }
    
    -- Clean any previous job binds first
    for i = 1, 7 do
        send_command('unbind F' .. i)
    end
    
    -- PLD Keybindings F1 only (F2-F3 in user_setup)
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F1 gs c cycle HybridMode')
        
        -- Add F4 for RuneElement cycling if sub RUN (with safety check)
        if player and player.sub_job == 'RUN' then
            send_command('bind F4 gs c cyclerune')
        end
        
        -- Keep F10-F11 binds for compatibility
        send_command('bind F10 gs c cycle WeaponSet')
        send_command('bind F11 gs c cycle SubSet')
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

    state.RuneElement = M {
        ['description'] = 'Rune Element',
        'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae'
    }
end

--- Clean up resources when unloading the GearSwap file.
--- Unbinds all custom keybindings to prevent conflicts with other jobs.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- Keybindings cleaned up:
---   - F9: Hybrid mode cycling
---   - F10: Weapon set cycling
---   - F11: Sub weapon/shield set cycling
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    -- Unbind all F1-F7 keys and F10-F11
    for i = 1, 7 do
        send_command('unbind F' .. i)
    end
    send_command('unbind F10') -- Unbind key for cycling main weapon set
    send_command('unbind F11') -- Unbind key for cycling sub weapon set
end

---============================================================================
--- SELF COMMAND HANDLER
---============================================================================

--- Handle custom console commands for Paladin.
--- Provides specialized command handling for PLD-specific operations and testing.
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
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'PLD') then
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

    -- Add other PLD-specific commands here as needed
end

--- Initialize gear sets for Paladin (duplicate function - legacy support).
--- This duplicate function exists for legacy compatibility but is not used.
--- The primary init_gear_sets() function above handles all initialization.
---
--- @deprecated This duplicate function is maintained for compatibility only
--- @see init_gear_sets Primary initialization function above
function init_gear_sets()
    -- All gear sets are defined in jobs/pld/PLD_SET.lua for better organization
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle pre-casting logic with specialized Paladin optimizations.
--- Performs comprehensive spell preparation including:
--- - Phalanx optimization with experience point mode integration
--- - Spell tracking for buff management and gear optimization
--- - Comprehensive spell handling and auto-ability coordination
--- - Cooldown checking and display for efficient spell usage
---
--- Special Handling:
---   - Phalanx: Automatically adjusts gear based on XP mode settings
---   - Spell tracking: Monitors spell usage for optimization algorithms
---
--- @param spell table The spell or ability being cast
--- @param action table The action object containing execution details
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell/ability execution
--- @see handle_phalanx_while_xp For Phalanx-specific optimization
--- @see track_spell_precast For spell usage tracking
function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    -- Metrics system removed during cleanup


    -- If the spell is Phalanx, call the handle_phalanx_while_xp function
    if spell.name == 'Phalanx' then
        handle_phalanx_while_xp(spell, eventArgs)
    end


    -- Special handling for Flash - check BEFORE any equipment changes
    if spell.name == 'Flash' and auto_abilities[spell.name] then
        auto_abilities[spell.name](spell, eventArgs)
        -- Si eventArgs.handled = true, on sort complètement (pas d'équipement)
        if eventArgs.handled then
            return
        end
    end
    
    -- Handle the spell casting with auto_abilities (pour les autres spells)
    if spell.name ~= 'Flash' then
        handle_spell(spell, eventArgs, auto_abilities)
    end

    -- ADD: Track spell in precast
    track_spell_precast(spell)
    -- Check and display the recast cooldown - SKIP Flash completely
    if spell.name ~= 'Flash' then
        checkDisplayCooldown(spell, eventArgs)
    end
end

--- Handle mid-casting logic and optimizations.
--- Currently minimal implementation with placeholder for incapacitation checks.
--- Reserved for spell-specific gear swapping during casting phase.
---
--- Technical Note:
---   Incapacitation checking is commented out but available for future use
---   to handle spell interruption scenarios.
---
--- @param spell table The spell object being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    -- Metrics system removed during cleanup


    -- Check if the player is incapacitated
    --[[ incapacitated(spell, eventArgs) ]]
end

--- Handle post-casting cleanup and advanced spell tracking.
--- Executes after spell completion to manage state transitions,
--- equipment updates, and spell usage analytics.
---
--- Features:
---   - Shared aftercast processing for common spell handling
---   - Advanced spell tracking for optimization algorithms
---   - State management and buff duration tracking
---
--- @param spell table The spell object that was executed
--- @param action table The action object that was performed
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell/ability completion
--- @see handleSpellAftercast For shared aftercast processing
--- @see track_spell_aftercast For spell usage analytics
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking
    -- Metrics system removed during cleanup


    -- Perform actions specific to the spell that was cast
    handleSpellAftercast(spell, eventArgs)
    -- ADD: Track spell in aftercast
    track_spell_aftercast(spell)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book and visual appearance for Paladin.
--- Automatically selects appropriate macro page based on subjob synergy
--- and applies the configured lockstyle set. Includes safe loading/unloading
--- of the dressup addon to prevent macro conflicts.
---
--- Macro Page Selection:
---   - BLU subjob: Page 1, Book 23 (Magic tanking focus)
---   - WAR subjob: Page 1, Book 21 (Physical tanking focus)
---   - RDM subjob: Page 1, Book 28 (Versatile casting support)
---   - RUN subjob: Page 1, Book 21 (Runic enhancement support)
---   - Default:    Page 1, Book 23 (General purpose tanking)
---   - Lockstyle set 3 applied with timing delay
---
--- Safety Features:
---   - Dressup addon safely unloaded/reloaded to prevent macro loss
---   - Timing delays prevent addon conflicts
---
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
function select_default_macro_book()
    -- Load macro manager safely
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success and result then
            macro_manager = result
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    if macro_manager and macro_manager.setup_job_macro_lockstyle then
        macro_manager.setup_job_macro_lockstyle('PLD', player.sub_job, true) -- true = show message
    elseif setup_job_macro_lockstyle then
        -- Fallback to global function
        setup_job_macro_lockstyle('PLD', player.sub_job, true)
    else
        windower.add_to_chat(158, '[PLD] Macro management not available, using basic setup')
        -- Basic fallback
        send_command('input /macro book 1; input /macro set 1')
    end
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end
