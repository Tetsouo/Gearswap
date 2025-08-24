---============================================================================
--- FFXI GearSwap Configuration - Warrior (WAR)
---============================================================================
--- Professional GearSwap configuration for Warrior job in FFXI.
--- Provides advanced automation for gear swapping, weapon skill optimization,
--- hybrid mode management, and dual-boxing functionality.
---
--- @file Tetsouo_WAR.lua
--- @author Tetsouo
--- @version 2.1 (Mote v2 Compatible)
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
---   F1   : Cycle WeaponSet - Rotate through weapon configurations
---   F2   : Cycle ammoSet - Change ammunition type
---   F5   : Cycle HybridMode (PDT ⇆ Normal) - Toggle defensive gear
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
    include('core/GLOBALS.lua')
    include('features/DUALBOX.lua')          -- Dual-boxing utilities for alt job detection
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('monitoring/SIMPLE_JOB_MONITOR.lua')     -- Kaories job monitoring
    include('utils/EQUIPMENT_FACTORY.lua')
    include('modules/AUTOMOVE.lua')
    include('modules/SHARED.lua')
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

    -- Clean any previous job binds first
    for i = 1, 7 do
        send_command('unbind F' .. i)
    end
    
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        -- HybridMode keybind (F5) - standardized across jobs
        send_command('bind F5 gs c cycle HybridMode')
        
        -- Keybindings F1-F2 for states available in job_setup
        send_command('bind F1 gs c cycle WeaponSet')
        send_command('bind F2 gs c cycle ammoSet')
    end, 0.5)

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

    -- Initialize Keybind UI
    local success, KeybindUI = pcall(require, 'ui/KEYBIND_UI')
    if success then
        KeybindUI.init()
    end

    select_default_macro_book()
end

--- Clean up resources when unloading the GearSwap file.
--- Unbinds all custom keybindings to prevent conflicts with other jobs.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    -- Unbind WAR-specific keys (F1, F2, F5)
    send_command('unbind F1') -- WeaponSet
    send_command('unbind F2') -- ammoSet
    send_command('unbind F5') -- HybridMode
    
    -- Clean unbind all F-keys to prevent conflicts when switching jobs
    for i = 1, 12 do
        send_command('unbind F' .. i)
    end
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
    -- First, try universal commands (equiptest, validate_all, etc.)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if success_UniversalCommands and UniversalCommands then
        if UniversalCommands.handle_command(cmdParams, eventArgs) then
            return
        end
    end
    
    local command = cmdParams[1]:lower()

    -- Handle macro commands using centralized system
    -- MacroCommands now available globally via shared.lua
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'WAR') then
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
    if command == 'test' then
        -- MessageUtils now available globally via shared.lua
        MessageUtils.system_action_message('Executing GearSwap module tests...')
        include('test_runner.lua')
        eventArgs.handled = true
        return
    end

    -- Metrics commands removed during cleanup

    -- Cache management commands
    if command == 'cache' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'

        if subcommand == 'stats' then
            -- EquipmentCache now available globally via shared.lua
            local stats = EquipmentCache.get_statistics()
            -- MessageUtils now available globally via shared.lua
            local cache_stats = {
                ['Entries'] = string.format('%d/%d', stats.entries, stats.max_entries),
                ['Hit Rate'] = string.format('%.1f%% (%d hits, %d misses)', stats.hit_rate, stats.hits, stats.misses),
                ['Avg Access'] = string.format('%.2fms', stats.avg_access_time_ms)
            }
            MessageUtils.system_stats_message('Cache Statistics', cache_stats)
        elseif subcommand == 'cleanup' then
            -- EquipmentCache now available globally via shared.lua
            EquipmentCache.cleanup()
            -- MessageUtils now available globally via shared.lua
            MessageUtils.system_action_message('Cache cleanup completed')
        elseif subcommand == 'clear' then
            -- EquipmentCache now available globally via shared.lua
            EquipmentCache.clear()
            -- MessageUtils now available globally via shared.lua
            MessageUtils.system_action_message('Cache cleared')
        end
        eventArgs.handled = true
        return
    end

    -- Module loader commands
    if command == 'modules' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'

        if subcommand == 'stats' then
            -- ModuleLoader now available globally via shared.lua
            local stats = ModuleLoader.get_statistics()
            -- MessageUtils now available globally via shared.lua
            local module_stats = {
                ['Cached Modules'] = stats.cached_modules,
                ['Memory Usage'] = string.format('%.2fKB', stats.total_memory_kb),
                ['Hit Rate'] = string.format('%.1f%%', stats.hit_rate),
                ['Avg Load Time'] = string.format('%.2fms', stats.avg_load_time_ms)
            }
            MessageUtils.system_stats_message('Module Loader Statistics', module_stats)
        elseif subcommand == 'cleanup' then
            -- ModuleLoader now available globally via shared.lua
            ModuleLoader.cleanup_unused_modules()
            -- MessageUtils now available globally via shared.lua
            MessageUtils.system_action_message('Module cleanup completed')
        end
        eventArgs.handled = true
        return
    end

    -- Notification system commands
    if command == 'notify' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'test'

        if subcommand == 'test' then
            -- Notifications now available globally via shared.lua
            Notify.show("Test notification successful!", "success", 3)
            Notify.show("Warning test message", "warning", 3)
            Notify.show("Error test message", "error", 3)
        end
        eventArgs.handled = true
        return
    end

    -- Performance benchmarks
    if command == 'benchmark' then
        -- Benchmark now available globally via shared.lua
        -- MessageUtils now available globally via shared.lua
        MessageUtils.system_action_message('Starting performance benchmark...')

        coroutine.schedule(function()
            local results = Benchmark.run_all_benchmarks()
            -- MessageUtils now available globally via shared.lua
            local benchmark_stats = {
                ['Tests Passed'] = string.format('%d/%d', results.passed, results.total),
                ['Pass Rate'] = string.format('%.1f%%', results.pass_rate)
            }
            MessageUtils.system_stats_message('Benchmark Results', benchmark_stats)
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
    -- Metrics tracking removed during cleanup

    handle_spell(spell, eventArgs, auto_abilities)
    checkDisplayCooldown(spell, eventArgs)
    Ws_range(spell)

    if spell.type ~= 'WeaponSkill' then return end

    local wsmode = get_custom_wsmode(spell, spellMap)
    local ws_set = sets.precast.WS[spell.english] or sets.precast.WS

    -- Use the safe equipment function from EquipmentUtils
    -- EquipmentUtils now available globally via shared.lua
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
    -- Metrics tracking removed during cleanup

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

    -- Metrics tracking removed during cleanup
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
    -- Load macro manager safely
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success then
            macro_manager = result
        else
            windower.add_to_chat(167, '[WAR] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('WAR', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end

---============================================================================
--- COMMAND HELP DISPLAY
---============================================================================

--- Display brief command reference that fits in console
function display_command_help()
    print("=============== TETSOUO GEARSWAP COMMANDS ===============")
    print(" SHORTCUTS: F1=WeaponSet F2=ammoSet F5=HybridMode //gs r=Reload")
    print("")
    print(" METRICS (disabled by default):")
    print("   //gs c metrics toggle   | Enable/disable")
    print("   //gs c metrics show     | Performance dashboard")
    print("   //gs c metrics export   | Export to JSON")
    print("")
    print(" OTHER:")
    print("   //gs c cache stats      | Cache stats")
    print("   //gs c test             | Unit tests")
    print("   //gs c cmd full         | Complete help")
    print("=======================================================")
end

--- Display full command reference (longer version)
function display_full_help()
    print("================== COMPLETE GEARSWAP HELP ==================")
    print("")
    print("KEYBOARD SHORTCUTS:")
    print("  F1 = Cycle WeaponSet (change weapon)")
    print("  F2 = Cycle ammoSet (change ammo)")
    print("  F5 = Cycle HybridMode (PDT <-> Normal)")
    print("")
    print("METRICS SYSTEM:")
    print("  //gs c metrics status   | View status (active/inactive)")
    print("  //gs c metrics toggle   | Enable/disable")
    print("  //gs c metrics show     | Colored dashboard")
    print("  //gs c metrics export   | Save to JSON")
    print("  //gs c metrics reset    | Reset to zero")
    print("")
    print("CACHE & SYSTEM:")
    print("  //gs c cache stats      | Cache statistics")
    print("  //gs c cache clear      | Clear cache")
    print("  //gs c modules stats    | Module info")
    print("  //gs c test             | Unit tests")
    print("")
    print("GEARSWAP:")
    print("  //gs r                  | Reload config")
    print("  //gs c cycle HybridMode | Toggle defense")
    print("  //gs c cycle WeaponSet  | Change weapon")
    print("")
    print("=========================================================")
end
