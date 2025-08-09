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
---   //gs c metrics [command] : Metrics system management
---   //gs c test              : Run module unit tests
---   //gs c cache [command]   : Cache management
---   //gs r                   : Reload GearSwap configuration
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
---   //gs c metrics show     : Display performance metrics dashboard
---   //gs c metrics export   : Export metrics to JSON file
---   //gs c metrics toggle   : Enable/disable metrics collection
---   //gs c metrics reset    : Reset all collected metrics
---   //gs c test             : Execute module unit tests
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
    include('core/globals.lua')
    include('utils/equipment_factory.lua')
    include('modules/automove.lua')
    include('modules/shared.lua')
    include('jobs/war/WAR_SET.lua')
    include('jobs/war/WAR_FUNCTION.lua')
    removeRetaliationOnLongMovement()
    
    -- Initialize universal metrics system
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.initialize()
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
--- @usage Automatically called by Mote framework after dependency loading
function job_setup()
    -- WAR-specific job logic initialization
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
    -- Mote v2 standard states
    state.HybridMode:options('PDT', 'Normal')

    -- Custom states for weapon and ammunition management
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Ukonvasara', 'Chango', 'Shining', "Loxotic", "Ikenga", "Naegling" }
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
--- CUSTOM COMMAND HANDLER
---============================================================================

--- Handle custom GearSwap commands including metrics and testing.
--- Processes user commands sent via //gs c <command>
---
--- Available commands:
---   - metrics show/export/toggle/reset: Metrics system management
---   - test: Run unit tests for all modules
---   - cache stats/cleanup/clear: Cache management
---   - notify test: Test notification system
---
--- @param cmdParams table Command parameters split by spaces
--- @param eventArgs table Event arguments for command handling
--- @usage //gs c test (runs unit tests)
function job_self_command(cmdParams, eventArgs)
    local command = cmdParams[1]:lower()
    

    -- Run unit tests
    if command == 'test' then
        windower.add_to_chat(050, "Executing GearSwap module tests...")
        include('test_runner.lua')
        eventArgs.handled = true
        return
    end
    
    -- Metrics and performance commands - delegate to universal system
    if command == 'metrics' then
        local MetricsIntegration = require('core/metrics_integration')
        if MetricsIntegration.handle_command(cmdParams, eventArgs) then
            return
        end
    end
    
    -- Cache management commands
    if command == 'cache' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'
        
        if subcommand == 'stats' then
            local EquipmentCache = require('core/equipment_cache')
            local stats = EquipmentCache.get_statistics()
            windower.add_to_chat(050, string.format('═══ Cache Statistics ═══'))
            windower.add_to_chat(050, string.format('Entries: %d/%d', stats.entries, stats.max_entries))
            windower.add_to_chat(050, string.format('Hit Rate: %.1f%% (%d hits, %d misses)', stats.hit_rate, stats.hits, stats.misses))
            windower.add_to_chat(050, string.format('Avg Access: %.2fms', stats.avg_access_time_ms))
        elseif subcommand == 'cleanup' then
            local EquipmentCache = require('core/equipment_cache')
            EquipmentCache.cleanup()
            windower.add_to_chat(050, 'Cache cleanup completed')
        elseif subcommand == 'clear' then
            local EquipmentCache = require('core/equipment_cache')
            EquipmentCache.clear()
            windower.add_to_chat(050, 'Cache cleared')
        end
        eventArgs.handled = true
        return
    end
    
    -- Module loader commands
    if command == 'modules' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'
        
        if subcommand == 'stats' then
            local ModuleLoader = require('utils/module_loader')
            local stats = ModuleLoader.get_statistics()
            windower.add_to_chat(050, string.format('═══ Module Loader Statistics ═══'))
            windower.add_to_chat(050, string.format('Cached Modules: %d', stats.cached_modules))
            windower.add_to_chat(050, string.format('Memory Usage: %.2fKB', stats.total_memory_kb))
            windower.add_to_chat(050, string.format('Hit Rate: %.1f%%', stats.hit_rate))
            windower.add_to_chat(050, string.format('Avg Load Time: %.2fms', stats.avg_load_time_ms))
        elseif subcommand == 'cleanup' then
            local ModuleLoader = require('utils/module_loader')
            ModuleLoader.cleanup_unused_modules()
            windower.add_to_chat(050, 'Module cleanup completed')
        end
        eventArgs.handled = true
        return
    end
    
    -- Notification system commands  
    if command == 'notify' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'test'
        
        if subcommand == 'test' then
            local Notify = require('utils/notifications')
            Notify.show("Test notification successful!", "success", 3)
            Notify.show("Warning test message", "warning", 3) 
            Notify.show("Error test message", "error", 3)
        end
        eventArgs.handled = true
        return
    end
    
    -- Performance benchmarks
    if command == 'benchmark' then
        local Benchmark = require('tests/performance/benchmark')
        windower.add_to_chat(050, 'Starting performance benchmark...')
        
        coroutine.schedule(function()
            local results = Benchmark.run_all_benchmarks()
            windower.add_to_chat(050, string.format('Benchmark completed: %d/%d passed (%.1f%%)', 
                results.passed_benchmarks, results.total_benchmarks, results.success_rate))
        end, 1)
        
        eventArgs.handled = true
        return
    end

    -- Add other WAR-specific commands here as needed
    
    -- Important: Let other commands pass through to the default GearSwap system
    -- This allows commands like "gs equip sets.precast.JA['Provoke']" to work
    -- Do NOT set eventArgs.handled = true here so GearSwap processes the command
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
    -- Universal metrics tracking for precast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_precast(spell, action, spellMap, eventArgs)
    
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
    -- Universal metrics tracking for midcast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_midcast(spell, action, spellMap, eventArgs)
    
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
    
    -- Universal metrics tracking
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.track_action(spell, eventArgs)
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

---============================================================================
--- ENGAGED SET CUSTOMIZATION
---============================================================================
--- The customize_melee_set function is defined in jobs/war/WAR_FUNCTION.lua
--- to avoid conflicts and maintain modular organization.

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

---============================================================================
--- COMMAND HELP DISPLAY
---============================================================================

--- Display brief command reference that fits in console
function display_command_help()
    print("=============== COMMANDES GEARSWAP TETSOUO ===============")
    print(" RACCOURCIS: F5=HybridMode F6=WeaponSet //gs r=Reload")
    print("")
    print(" METRIQUES (desactivees par defaut):")
    print("   //gs c metrics toggle   | Activer/desactiver")  
    print("   //gs c metrics show     | Dashboard performance")
    print("   //gs c metrics export   | Exporter vers JSON")
    print("")
    print(" AUTRES:")
    print("   //gs c cache stats      | Stats cache")
    print("   //gs c test             | Tests unitaires")
    print("   //gs c cmd full         | Aide complete")
    print("=======================================================")
end

--- Display full command reference (longer version)
function display_full_help()
    print("================== AIDE COMPLETE GEARSWAP ==================")
    print("")
    print("RACCOURCIS CLAVIER:")
    print("  F5 = Cycle HybridMode (PDT <-> Normal)")
    print("  F6 = Cycle WeaponSet (changer arme)")
    print("")
    print("SYSTEME METRIQUES:")
    print("  //gs c metrics status   | Voir etat (actif/inactif)")
    print("  //gs c metrics toggle   | Activer/desactiver")
    print("  //gs c metrics show     | Dashboard coloré")
    print("  //gs c metrics export   | Sauver en JSON")
    print("  //gs c metrics reset    | Remettre a zero")
    print("")
    print("CACHE & SYSTEME:")
    print("  //gs c cache stats      | Statistiques cache")
    print("  //gs c cache clear      | Vider cache")
    print("  //gs c modules stats    | Info modules")
    print("  //gs c test             | Tests unitaires")
    print("")
    print("GEARSWAP:")
    print("  //gs r                  | Recharger config")
    print("  //gs c cycle HybridMode | Toggle defense")
    print("  //gs c cycle WeaponSet  | Changer arme")
    print("")
    print("=========================================================")
end
