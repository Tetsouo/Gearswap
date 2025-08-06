---============================================================================
--- FFXI GearSwap Configuration - Beastmaster (BST)
---============================================================================
--- Professional GearSwap configuration for Beastmaster job in FFXI.
--- Provides advanced automation for pet management, ecosystem optimization,
--- automatic pet engagement, and HUD-driven pet information display.
---
--- @file Tetsouo_BST.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires GearSwap addon
--- @requires Windower FFXI
--- @requires BST-HUD.lua
--- @requires resources.lua
---
--- Dependencies:
---   - modules/automove.lua      : Automatic movement detection and gear swapping
---   - modules/shared.lua        : Shared utility functions across jobs
---   - jobs/bst/BST_SET.lua     : BST-specific equipment sets
---   - jobs/bst/BST_FUNCTION.lua : BST-specific advanced functions
---   - BST-HUD.lua              : Graphical HUD overlay for pet management
---   - resources.lua            : Windower resource tables
---
--- Features:
---   - Intelligent pet management with automatic engagement control
---   - Ecosystem-based optimization for different monster types
---   - Species-specific broth and jug pet management
---   - Ready move automation and tracking
---   - Pet idle mode switching (Master PDT vs Pet PDT)
---   - Comprehensive pet information HUD overlay
---   - Dynamic weapon and sub weapon set management
---   - Extensive ammo/jug pet library with 20+ pets
---   - Dual-boxing support for mage coordination
---   - F-key binding system for quick state changes
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_BST
---   Unload with: //gs unload
---
--- Key Bindings:
---   F2 : Cycle Hybrid Mode (PDT ⇆ Normal)
---   F3 : Cycle Weapon Set
---   F4 : Cycle Sub Weapon Set
---   F5 : Change Ecosystem (updates all related settings)
---   F6 : Change Species (auto-equips appropriate broth)
---   F7 : Cycle Pet Idle Mode (Master PDT ⇆ Pet PDT)
---   F9 : Toggle Auto Pet Engage (Off ⇆ On)
---
--- Console Commands:
---   //gs c cycle [StateName] : Cycle through any state options
---   //gs c bst_ecosystem     : Interactive ecosystem selection
---   //gs c bst_species       : Interactive species selection
---
--- Supported Ecosystems:
---   All, Aquan, Amorph, Beast, Bird, Lizard, Plantoid, Vermin
---
--- Available Jug Pets:
---   20+ pets including Chapuli, Tulfaire, Acuex, Hippogryph, and more
---============================================================================

---@diagnostic disable: lowercase-global

---============================================================================
--- LOCAL UTILITIES AND TYPE DEFINITIONS
---============================================================================

--- @type function Windower command execution helper
local sc = send_command

--- @type table Windower resource tables for spells, items, etc.
local res = require('resources')

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- Entry point executed once when GearSwap loads the file.
--- Sets up Mote-Include v2 framework, loads all BST-specific modules,
--- and initializes the BST-HUD overlay for pet management.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. BST equipment sets
---   5. BST advanced functions
---   6. BST-HUD overlay for pet information
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
--- @see BST-HUD.lua For pet information overlay
function get_sets()
    mote_include_version = 2 -- target Motenten include version

    -- external include files (order matters)
    include('Mote-Include.lua')
    include('modules/automove.lua')
    include('modules/shared.lua')
    include('jobs/bst/BST_SET.lua')
    include('jobs/bst/BST_FUNCTION.lua')

    -- HUD overlay
    sc('lua load BST-HUD')
end

--- Initialize gear sets for Beastmaster.
--- Hook called by Mote framework to populate gear tables.
--- This function is intentionally minimal as gear sets are externally defined
--- in the BST_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/bst/BST_SET.lua For complete equipment set definitions
function init_gear_sets() end

---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and comprehensive pet management.
--- Initializes all BST-specific mechanics including pet engagement automation,
--- ecosystem-based optimization, species management, and extensive keybinding system.
---
--- Key Features Configured:
---   - Auto Pet Engage: Automatic pet attack coordination
---   - Pet Idle Modes: Master PDT vs Pet PDT defensive strategies
---   - Ecosystem Support: 8 different monster ecosystems for optimization
---   - Species Management: Dynamic species selection with broth auto-equipping
---   - Weapon/Sub Weapon Sets: Dynamic equipment configurations
---   - Extensive Jug Pet Library: 20+ different pets with unique abilities
---   - Dual-boxing Coordination: Mage spell automation states
---   - F-key Binding System: F2-F10 keys for quick state management
---
--- Technical Implementation:
---   Uses data-driven state definition for maintainability and extensibility.
---   Implements unified command system for both keybindings and macro usage.
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see file_unload For keybinding cleanup
--- @see bst_change_ecosystem For ecosystem switching logic
function job_setup()
    -- State definitions: name, description, possible values
    local state_defs = {
        { n = "AutoPetEngage",   d = "AutoPetEngage", v = { "Off", "On" } },
        { n = "petIdleMode",     d = "PetIdleMode",   v = { "MasterPDT", "PetPDT" } },
        { n = "HybridMode",      d = "HybridMode",    v = { "PDT", "Normal" } },
        { n = "WeaponSet",       d = "WeaponSet",     v = { "Aymur" } },
        { n = "SubSet",          d = "SubSet",        v = { "Agwu's axe", "Adapa", "Diamond Aspis" } },
        { n = "ecosystem",       d = "Ecosystem",     v = { "All", "Aquan", "Amorph", "Beast", "Bird", "Lizard", "Plantoid", "Vermin" } },
        { n = "species",         d = "Species",       v = { "All" } },
        {
            n = "ammoSet",
            d = "ammo",
            v = {
                "Bouncing Bertha (Chapuli)", "Swooping Zhivago (Tulfaire)", "Fluffy Bredo (Acuex)", "Slugger (Slug)",
                "Daring Roland (Hippogryph)", "Sultry Patrice (Slime)", "Fatso Fargann (Leech)", "Jovial Edwin (Crab)",
                "Herald Henry (Crab)", "Aged Angus (Crab)", "Blackbeard Randy (Tiger)", "Rhyming Shizuna (Sheep)",
                "Warlike Patrick (Lizard)", "Suspicious Alice (Eft)", "Headbreaker Ken (Fly)", "Threestar Lynn (Ladybug)",
                "Sweet Caroline (Mandragora)", "Cursed Annabelle (Antlion)", "Anklebiter Jedd (Diremite)",
                "Left-Handed Yoko (Mosquito)",
                "Amiable Roche (Fish)", "Brainy Waluis (Funguar)", "Energized Sefina (Beetle)",
                "Weevil Familiar (Weevil)",
                "Choral Leera (Colibri)", "Pondering Peter (Rabbit)", "Vivacious Vickie (Raaz)"
            }
        },
        { n = "petEngaged", d = "petEngaged", v = { "false", "true" } },
    }
    for _, s in ipairs(state_defs) do
        state[s.n] = M { description = s.d, unpack(s.v) }
    end

    -- Alternative spell lists (for external helpers)
    state.altPlayerLight   = M("Fire", "Thunder", "Aero"); state.altPlayerDark = M("Stone", "Blizzard", "Water")
    state.altPlayerTier    = M("V", "IV", "III", "II", ""); state.altPlayera = M("Fira", "Stonera", "Blizzara", "Aera",
        "Thundara", "Watera")
    state.altPlayerGeo     = M("Geo-Frailty", "Geo-Malaise", "Geo-Languor", "Geo-Slow", "Geo-Torpor")
    state.altPlayerIndi    = M("Indi-Fury", "Indi-Refresh", "Indi-Barrier", "Indi-Fend", "Indi-Acumen", "Indi-Precision",
        "Indi-Haste")
    state.altPlayerEntrust = M("Indi-Refresh", "Indi-Haste", "Indi-INT", "Indi-STR", "Indi-VIT")

    -- Keybindings: F2–F10 cycle through states
    for _, b in ipairs {
        { "F2", "HybridMode" }, { "F3", "WeaponSet" }, { "F4", "SubSet" }, 
        { "F7", "petIdleMode" }, { "F9", "AutoPetEngage" }
    } do
        sc(("bind %s gs c cycle %s"):format(b[1], b[2]))
    end
    
    -- BST unified commands (same logic for binds and macros)
    sc("bind F5 gs c bst_ecosystem")   -- Change ecosystem + update everything
    sc("bind F6 gs c bst_species")     -- Change species + equip broth
end

--- Configure user-specific settings and preferences.
--- Runs after job_setup to handle user customizations and macro setup.
--- Primarily handles macro book selection based on subjob synergy.
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance configuration
function user_setup()
    select_default_macro_book()
end

--- Clean up resources when unloading the GearSwap file.
--- Comprehensive cleanup of all keybindings and HUD overlay.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- Cleanup Operations:
---   - Unbinds all F2-F10 function keys
---   - Unloads BST-HUD overlay to free memory
---   - Prevents keybinding conflicts with other jobs
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    for _, key in ipairs({ 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10' }) do
        sc('unbind ' .. key)
    end
    sc('lua unload BST-HUD')
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle pre-casting logic with specialized pet management.
--- Coordinates pet-specific precast actions and maintains ready move database.
--- Critical for pet ability optimization and timing coordination.
---
--- Operations Performed:
---   - Pet precast processing for optimal gear selection
---   - Ready move database updates for current pet
---   - Pet ability coordination and timing optimization
---
--- @param spell table The spell/ability about to be used
--- @param action table Raw action data from game engine
--- @param spellMap table Spell mapping provided by Mote framework
--- @param eventArgs table Event control flags (cancel, handled, etc.)
--- @usage Automatically called by GearSwap before spell/ability execution
--- @see job_pet_precast For pet-specific precast handling
--- @see update_ready_moves For ready move database management
function job_precast(spell, action, spellMap, eventArgs)
    job_pet_precast(spell, action, spellMap, eventArgs)
    update_ready_moves()
end

--- Handle mid-casting logic and optimizations.
--- Currently minimal implementation with placeholder for future enhancements.
--- Reserved for spell-specific gear swapping during casting phase.
---
--- @param spell table The spell object being cast
--- @param action table The action object containing cast information
--- @param spellMap table Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
function job_midcast(spell, action, spellMap, eventArgs)
    -- Add mid-cast logic here if required.
end

--- Handle post-casting cleanup and BST initialization.
--- Executes after spell completion with special handling for first-run initialization.
--- Manages ecosystem setup and pet coordination systems.
---
--- Special Features:
---   - Deferred BST initialization on first aftercast event
---   - Automatic ecosystem configuration with coroutine scheduling
---   - Safe initialization preventing race conditions
---
--- Technical Implementation:
---   Uses coroutine scheduling to prevent initialization conflicts
---   with GearSwap's loading sequence.
---
--- @param spell table The spell object that was executed
--- @param action table The action object that was performed
--- @param spellMap table Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell/ability completion
--- @see bst_change_ecosystem For ecosystem initialization
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Initialize BST on first aftercast if not already done
    if not _bst_initialized then
        _bst_initialized = true
        coroutine.schedule(function()
            if bst_change_ecosystem then
                -- Initialize with current ecosystem
                local eco = state.ecosystem.value
                bst_change_ecosystem()
            end
        end, 1)
    end
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book and visual appearance for Beastmaster.
--- Automatically selects appropriate macro page based on subjob synergy
--- and applies the configured lockstyle set. Includes safe loading/unloading
--- of the dressup addon to prevent macro conflicts.
---
--- Macro Page Selection:
---   - DNC subjob: Page 1, Book 15 (TP and evasion management)
---   - SCH subjob: Page 1, Book 16 (Magic and pet coordination)
---   - WHM subjob: Page 1, Book 15 (Healing and pet support)
---   - Default:    Page 1, Book 15 (General pet management)
---   - Lockstyle set 11 applied with timing delay
---
--- Safety Features:
---   - Dressup addon safely unloaded/reloaded to prevent macro loss
---   - Timing delays prevent addon conflicts
---
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
function select_default_macro_book()
    send_command('lua unload dressup')
    
    -- BST macro pages based on subjob
    local macro_page = ({ DNC = 15, SCH = 16, WHM = 15 })[player.sub_job] or 15
    set_macro_page(1, macro_page)
    
    -- BST lockstyle
    send_command('wait 3; input /lockstyleset 11')
    
    -- Reload dressup with delay to avoid macro loss
    send_command('wait 20; lua load dressup')
end
