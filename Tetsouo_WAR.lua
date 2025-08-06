---============================================================================
--- FFXI GearSwap Configuration - Warrior (WAR)
---============================================================================
--- Professional GearSwap configuration for Warrior job in FFXI.
--- Provides advanced automation for gear swapping, weapon skill optimization,
--- hybrid mode management, and dual-boxing functionality.
---
--- @file Tetsouo_WAR.lua
--- @author Tetsouo
--- @version 2.0 (Mote v2 Compatible)
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- Dependencies:
---   - modules/automove.lua      : Automatic movement detection and gear swapping
---   - modules/shared.lua        : Shared utility functions across jobs
---   - jobs/war/WAR_SET.lua     : WAR-specific equipment sets
---   - jobs/war/WAR_FUNCTION.lua : WAR-specific advanced functions
---   - core/equipment.lua       : Safe equipment handling utilities
---
--- Features:
---   - Intelligent weapon skill gear selection based on TP thresholds
---   - Hybrid defense mode (PDT/Normal) for survivability
---   - Dynamic weapon set switching for different combat scenarios
---   - Automatic Retaliation cancellation on movement
---   - Dual-boxing support for mage coordination
---   - Sub-job specific macro book and lockstyle management
---   - Safe equipment handling with error prevention
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_WAR
---   Unload with: //gs unload
---
--- Key Bindings:
---   F5 : Cycle Hybrid Mode (PDT ⇆ Normal)
---   F6 : Cycle Weapon Set
---
--- Console Commands:
---   //gs c cycle HybridMode : Toggle defense mode
---   //gs c cycle WeaponSet  : Change main weapon configuration
---   //gs r                  : Reload GearSwap configuration
---============================================================================

---============================================================================
--- QUICK REFERENCE GUIDE
---============================================================================
--- Key Bindings:
---   F5   : Cycle HybridMode (PDT ⇆ Normal) - Toggle defensive gear
---   F6   : Cycle WeaponSet - Rotate through weapon configurations
---
--- Console Commands:
---   //gs r : Reload GearSwap configuration and reset all bindings
---   //gs c cycle HybridMode : Manual hybrid mode toggle
---   //gs c cycle WeaponSet  : Manual weapon set cycling
---
--- Automatic Features:
---   - Retaliation auto-cancellation on extended movement
---   - TP-based weapon skill gear optimization
---   - Sub-job specific macro book selection
---   - Dual-boxing mage coordination (altPlayer* states)
---
--- For detailed function documentation, see:
---   - jobs/war/WAR_FUNCTION.lua : Advanced WAR-specific logic
---   - jobs/war/WAR_SET.lua      : Complete equipment set definitions
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary WAR-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions  
---   4. WAR equipment sets
---   5. WAR advanced functions
---   6. Retaliation movement handler
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('modules/automove.lua')
    include('modules/shared.lua')
    include('jobs/war/WAR_SET.lua')
    include('jobs/war/WAR_FUNCTION.lua')
    removeRetaliationOnLongMovement()
end

--- Initialize gear sets for Warrior.
--- This function is intentionally minimal as gear sets are externally defined
--- in the WAR_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/war/WAR_SET.lua For complete equipment set definitions
function init_gear_sets()
    -- All gear sets are defined in jobs/war/WAR_SET.lua for better organization
end

---============================================================================
--- JOB SETUP AND CONFIGURATION
---============================================================================

--- Configure job-specific logic and variables.
--- Handles core Warrior mechanics and internal state management.
--- User preferences and keybindings are handled separately in user_setup().
---
--- This separation follows Mote v2 best practices:
---   - job_setup(): Core job mechanics and calculations
---   - user_setup(): User preferences, states, and keybindings
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see user_setup For user preference configuration
function job_setup()
    -- Job-specific variables and logic here
    -- User states and keybinds are now in user_setup()
end

--- Configure user-specific preferences and state management.
--- Sets up all customizable options, keybindings, and dual-boxing states.
--- Called after job_setup to overlay user preferences on job mechanics.
---
--- State Management:
---   - HybridMode: Defense optimization (PDT/Normal)
---   - WeaponSet: Main weapon configuration cycling
---   - ammoSet: Ammunition selection
---   - altPlayer*: Dual-boxing mage coordination states
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance setup
function user_setup()
    -- Mote v2 standard states (use :options() syntax)
    state.HybridMode:options('PDT', 'Normal')

    -- Custom states (keep original syntax)
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Ukonvasara','Chango', 'Shining'; "Loxotic", "Ikenga", "Naegling" }
    state.ammoSet = M { ['description'] = 'Ammo', 'Aurgelmir Orb +1' }

    -- Keybindings
    send_command('bind F5 gs c cycle HybridMode')
    send_command('bind F6 gs c cycle WeaponSet')

    ---------------------------------------------------------------------------
    -- DUAL-BOXING MAGE COORDINATION
    -- State management for secondary character spellcasting automation.
    -- These states control mage spells cast by dual-boxed characters and are
    -- ignored during solo play. Enables synchronized combat strategies.
    ---------------------------------------------------------------------------
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Fury', 'Indi-Agi', 'Indi-Refresh', 'Indi-Barrier', 'Indi-Fend', 'Indi-Acumen',
        'Indi-Precision', 'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Refresh', 'Indi-Barrier', 'Indi-Haste', 'Indi-INT', 'Indi-STR', 'Indi-VIT')

    select_default_macro_book()
end

--- Clean up resources when unloading the GearSwap file.
--- Unbinds all custom keybindings to prevent conflicts with other jobs.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    send_command('unbind F5')
    send_command('unbind F6')
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle pre-casting logic with advanced weapon skill optimization.
--- Performs comprehensive weapon skill preparation including:
--- - TP threshold-based gear selection for optimal damage
--- - Range validation for weapon skills
--- - Spell cooldown tracking and display
--- - Auto-ability coordination
---
--- Technical Implementation:
---   Uses safe equipment handling from core/equipment.lua to prevent
---   gear swap failures and maintain combat effectiveness.
---
--- @param spell table The spell/ability object being used
--- @param action table The action object containing execution details
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell/ability execution
--- @see get_custom_wsmode For TP-based weapon skill mode calculation
--- @see core/equipment.safe_equip For safe gear swapping
function job_precast(spell, action, spellMap, eventArgs)
    handle_spell(spell, eventArgs, auto_abilities)
    checkDisplayCooldown(spell, eventArgs)
    Ws_range(spell)

    if spell.type ~= 'WeaponSkill' then return end

    local wsmode = get_custom_wsmode(spell, spellMap)
    local ws_set = sets.precast.WS[spell.english] or sets.precast.WS

    -- Use the safe equipment function from EquipmentUtils
    local EquipmentUtils = require('core/equipment')
    if wsmode and ws_set[wsmode] then
        EquipmentUtils.safe_equip(ws_set[wsmode], spell.english .. "." .. wsmode)
    else
        EquipmentUtils.safe_equip(ws_set, spell.english)
    end

    eventArgs.handled = true
end

--- Handle mid-casting logic and optimizations.
--- Currently minimal implementation with placeholder for future enhancements.
--- Reserved for spell-specific gear swapping during casting phase.
---
--- @param spell table The spell object being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
function job_midcast(spell, action, spellMap, eventArgs)
    -- Midcast logic here if needed
end

--- Handle post-casting cleanup and state management.
--- Executes after spell/ability completion to manage state transitions
--- and equipment updates.
---
--- @param spell table The spell object that was executed
--- @param action table The action object that was performed
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell/ability completion
--- @see handleSpellAftercast For shared aftercast processing
function job_aftercast(spell, action, spellMap, eventArgs)
    handleSpellAftercast(spell, eventArgs)
end

---============================================================================
--- MOTE V2 COMPATIBILITY AND EQUIPMENT HANDLING
---============================================================================

--- Handle equipment updates for Mote-Include v2 compatibility.
--- Coordinates weapon equipping with shared equipment logic while maintaining
--- compatibility with both legacy and modern Mote versions.
---
--- Implementation Details:
---   - Prioritizes WAR-specific weapon handling via equip_weapons()
---   - Delegates to SharedFunctions for comprehensive gear management
---   - Prevents infinite recursion through careful function resolution
---
--- @param playerStatus string Current player status (Idle/Engaged/etc.)
--- @param eventArgs table Event arguments with equipment context
--- @usage Called automatically by Mote-Include v2 framework
--- @see equip_weapons For WAR-specific weapon logic
--- @see SharedFunctions.job_handle_equipping_gear For shared equipment handling
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Call the weapon equipping function from WAR_FUNCTION.lua
    if equip_weapons then
        equip_weapons()
    end
    
    -- Let SharedFunctions handle the rest of the equipment logic
    if job_handle_equipping_gear then
        -- Use the SharedFunctions version for complete gear handling
        local shared_gear_handler = _G['job_handle_equipping_gear']
        if shared_gear_handler and shared_gear_handler ~= job_handle_equipping_gear then
            shared_gear_handler(playerStatus, eventArgs)
        end
    end
end

--- Legacy compatibility for state change handling.
--- Provides backward compatibility with older Mote versions that use
--- job_state_change instead of job_handle_equipping_gear.
---
--- @param stateField string The state field that changed
--- @param newValue any The new value of the state field
--- @param oldValue any The previous value of the state field
--- @usage Called automatically by legacy Mote versions
--- @deprecated Use job_handle_equipping_gear for Mote v2+
function job_state_change(stateField, newValue, oldValue)
    -- Trigger equipment update when state changes
    handle_equipping_gear(player.status)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book and visual appearance for Warrior.
--- Automatically selects appropriate macro page based on subjob synergy
--- and applies the configured lockstyle set. Includes safe loading/unloading
--- of the dressup addon to prevent macro conflicts.
---
--- Macro Page Selection:
---   - DRG subjob: Page 1, Book 32 (Physical damage focus)
---   - SAM subjob: Page 1, Book 30 (Weapon skill optimization)
---   - DNC subjob: Page 1, Book 37 (Hybrid combat style)
---   - Default:    Page 1, Book 30 (General purpose)
---   - Lockstyle set 5 applied with timing delay
---
--- Safety Features:
---   - Dressup addon safely unloaded/reloaded to prevent macro loss
---   - Timing delays prevent addon conflicts
---
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
function select_default_macro_book()
    send_command('lua unload dressup')
    
    -- WAR macro pages based on subjob
    local macro_page = ({ DRG = 32, SAM = 30, DNC = 37 })[player.sub_job] or 30
    set_macro_page(1, macro_page)
    
    -- WAR lockstyle
    send_command('wait 3; input /lockstyleset 5')
    
    -- Reload dressup with delay to avoid macro loss
    send_command('wait 20; lua load dressup')
end
