---============================================================================
--- FFXI GearSwap Configuration - Black Mage (BLM)
---============================================================================
--- Professional GearSwap configuration for Black Mage job in FFXI.
--- Provides advanced automation for gear swapping, spell management, and
--- dual-boxing functionality with intelligent magic burst support.
---
--- @file Tetsouo_BLM.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- Dependencies:
---   - modules/automove.lua    : Automatic movement detection and gear swapping
---   - modules/shared.lua      : Shared utility functions across jobs
---   - jobs/blm/BLM_SET.lua   : BLM-specific equipment sets
---   - jobs/blm/BLM_FUNCTION.lua : BLM-specific advanced functions
---
--- Features:
---   - Intelligent magic burst detection and optimization
---   - Automatic spell tier selection based on target and situation
---   - Dual-boxing support for synchronized spellcasting
---   - Storm spell management and rotation
---   - Experience point optimization mode
---   - Mana Wall buff tracking and gear adjustment
---   - Macro book and lockstyle automation
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_BLM
---   Unload with: //gs unload
---
--- Key Bindings:
---   F9 : Cycle Casting Mode (MagicBurst/Normal)
---
--- Console Commands:
---   //gs c cycle CastingMode     : Toggle casting mode
---   //gs c cycle mainLightSpell  : Cycle light element spells
---   //gs c cycle mainDarkSpell   : Cycle dark element spells
---   //gs c cycle tierSpell       : Cycle spell tiers (VI-II)
---   //gs c cycle Aja             : Cycle -ja spells
---   //gs c cycle Storm           : Cycle storm spells
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include framework and loads all necessary modules.
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')          -- Utility functions and structures for GearSwap
    include('core/globals.lua')
    include('modules/automove.lua')      -- Automatic movement speed gear swapping
    include('modules/shared.lua')        -- Functions shared across multiple jobs
    include('jobs/blm/BLM_SET.lua')      -- Gear sets specific to Black Mage
    include('jobs/blm/BLM_FUNCTION.lua') -- Advanced functions specific to Black Mage
    
    -- Initialize universal metrics system
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.initialize()
end

-------------------------------------------------------------------------------------------------------------

---============================================================================
--- JOB SETUP AND CONFIGURATION
---============================================================================

--- Configure job-specific states and user preferences.
--- Initializes all customizable options, state management, and keybindings.
--- Called automatically after Mote-Include initialization.
---
--- States configured:
---   - CastingMode: Magic burst vs normal casting optimization
---   - Xp: Experience point gain optimization toggle
---   - Element selection: Light/Dark element preferences for main/alt player
---   - Spell tiers: Automatic tier selection (VI down to base spells)
---   - Aja spells: Ancient magic rotation management
---   - Storm spells: Enhancing magic storm rotation
---
--- @usage Automatically called by Mote framework
--- @see job_self_command For command handling
function job_setup()
    -- Command to change Casting mode: /console gs c cycle CastingMode
    state.CastingMode:options('MagicBurst', 'Normal')
    state.Xp = M { ['description'] = 'XP', 'False', 'True' }
    -- Command to change MainLight mode: /console gs c cycle mainLightSpell
    state.MainLightSpell = M('Fire', 'Thunder', 'Aero')
    -- Command to change SubLight mode: /console gs c cycle subLightSpell
    state.SubLightSpell = M('Thunder', 'Fire', 'Aero')
    -- Command to change MainDark mode: /console gs c cycle mainDarkSpell
    state.MainDarkSpell = M('Stone', 'Blizzard', 'Water')
    -- Command to change SubDark mode: /console gs c cycle subDarkSpell
    state.SubDarkSpell = M('Blizzard', 'Stone', 'Water')
    -- Command to change TierSpell mode: /console gs c cycle tierSpell
    state.TierSpell = M('VI', 'V', 'IV', 'III', 'II', '')
    -- Command to change Aja mode: /console gs c cycle Aja
    state.Aja = M('Firaja', 'Stoneja', 'Blizzaja', 'Aeroja', 'Thundaja', 'Waterja')
    -- Command to change Storm mode: /console gs c cycle Storm
    state.Storm = M('FireStorm', 'Sandstorm', 'Thunderstorm', 'HailStorm', 'Rainstorm', 'Windstorm', 'Voidstorm',
        'Aurorastorm')
    Manawall = buffactive['Mana Wall'] or false

    --------------------------------------------------------------------------------------------
    -- DUAL-BOXING CONFIGURATION
    -- State management for secondary character coordination and automation
    --------------------------------------------------------------------------------------------
    -- Command to change MainLight mode: /console gs c cycle AltPlayerLight
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    -- Command to change MainDark mode: /console gs c cycle altPlayerDark
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    -- Command to change TierSpell mode: /console gs c cycle altPlayerTier
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    -- Command to change Aja mode: /console gs c cycle altPlayera
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    -- Command to change Aja mode: /console gs c cycle altPlayerGeo
    state.altPlayerGeo = M('Geo-Malaise', 'Geo-Focus', 'Geo-Precision', 'Geo-Refresh', 'Geo-Languor')
    -- Command to change Aja mode: /console gs c cycle altPlayerGeo
    state.altPlayerIndi = M('Indi-Acumen', 'Indi-Refresh',
        'Indi-Haste')
    -- Command to change Entrust Indi mode: /console gs c cycle altPlayerEntrust
    state.altPlayerEntrust = M('Indi-INT', 'Indi-Refresh')
    --------------------------------------------------------------------------------------------
    -- Binds F9 to cycle through Casting Mode
    send_command('bind F9 gs c cycle CastingMode')
end

--- Configure user-specific settings and preferences.
--- Called after job_setup to handle user customizations.
--- Primarily handles macro book selection based on subjob.
---
--- @usage Automatically called by Mote framework
--- @see select_default_macro_book For macro configuration
function user_setup()
    -- Calls a function to select the default macro book based on the sub-job
    select_default_macro_book()
end

--- Clean up resources when unloading the GearSwap file.
--- Unbinds all custom keybindings to prevent conflicts.
--- Called automatically when changing jobs or reloading.
---
--- @usage Automatically called by GearSwap
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('unbind F9')
end

--- Initialize gear sets for Black Mage.
--- This function is intentionally empty as gear sets are loaded
--- from the external BLM_SET.lua file via include statement.
---
--- @usage Automatically called by Mote framework
--- @see jobs/blm/BLM_SET.lua For actual gear set definitions
function init_gear_sets()

end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle pre-casting logic and validations.
--- Performs comprehensive checks before spell execution including:
--- - Action lock validation to prevent casting during other actions
--- - Spell refinement and optimization based on current state
--- - Cooldown checking and display
--- - Arts buff validation for enhancing magic
---
--- @param spell table The spell object being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell casting
--- @see handle_spell For spell processing logic
--- @see checkDisplayCooldown For recast timer display
--- @see refine_various_spells For spell optimization
--- @see checkArts For arts buff validation
function job_precast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for precast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_precast(spell, action, spellMap, eventArgs)
    
    -- If the player is currently performing an action, immediately return and do nothing else.
    if midaction() then
        return
    end

    handle_spell(spell, eventArgs, auto_abilities) -- Handle the spell casting
    checkDisplayCooldown(spell, eventArgs)         -- Check and display the recast cooldown
    refine_various_spells(spell, eventArgs, spellCorrespondence)
    checkArts(spell, eventArgs)
end

--- Handle mid-casting logic and gear optimization.
--- Executes during the casting animation phase to optimize mana usage
--- and prepare for potential interruptions.
---
--- @param spell table The spell object being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
--- @see SaveMP For mana conservation logic
function job_midcast(spell, action, spellMap, eventArgs)
    -- Universal metrics tracking for midcast
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.universal_job_midcast(spell, action, spellMap, eventArgs)
    
    SaveMP()
end

--- Handle post-casting cleanup and state management.
--- Executes after spell completion to handle buff management,
--- MP recovery, and state transitions. Includes duplicate call
--- protection to prevent event handling issues.
---
--- Technical Implementation:
---   Uses timestamp-based deduplication with 100ms window to prevent
---   double-processing of aftercast events, which can occur due to
---   GearSwap's event handling architecture.
---
--- @param spell table The spell object that was cast
--- @param action table The action object that was performed
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell completion
--- @see handleSpellAftercast For actual aftercast processing

--- @type table Tracking structure for duplicate call prevention
--- @field spell_id number Last processed spell ID
--- @field timestamp number Timestamp of last processed spell (milliseconds)
local last_aftercast = { spell_id = nil, timestamp = 0 }

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Get current time in milliseconds
    local current_time = os.clock() * 1000

    -- Check if this is a duplicate call (same spell within 100ms)
    if last_aftercast.spell_id == spell.id and
        (current_time - last_aftercast.timestamp) < 100 then
        -- Ignore duplicate call
        return
    end

    -- Update tracking
    last_aftercast.spell_id = spell.id
    last_aftercast.timestamp = current_time

    -- Process aftercast normally
    handleSpellAftercast(spell, eventArgs)
    
    -- Universal metrics tracking
    local MetricsIntegration = require('core/metrics_integration')
    MetricsIntegration.track_action(spell, eventArgs)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book and visual appearance for Black Mage.
--- Automatically selects appropriate macro page based on subjob and
--- applies the configured lockstyle set. Includes safe loading/unloading
--- of the dressup addon to prevent macro conflicts.
---
--- Macro Page Selection:
---   - Page 1, Book 14 for all subjobs (SCH/RDM/WHM optimized)
---   - Lockstyle set 6 applied with delay
---   - Dressup addon safely reloaded to maintain custom appearance
---
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
function select_default_macro_book()
    send_command('lua unload dressup')

    -- BLM macro pages based on subjob
    local macro_page = ({ SCH = 14, RDM = 14, WHM = 14 })[player.sub_job] or 14
    set_macro_page(1, macro_page)

    -- BLM lockstyle
    send_command('wait 3; input /lockstyleset 6')

    -- Reload dressup with delay to avoid macro loss
    send_command('wait 20; lua load dressup')
end

---============================================================================
--- CUSTOM COMMAND HANDLER
---============================================================================

--- Handle custom GearSwap commands including test execution.
--- Processes user commands sent via //gs c <command>
---
--- Available commands:
---   - test: Run unit tests for all modules
---   - buffself: Execute BuffSelf function
---   - mainlight: Cast main light element spell
---   - maindark: Cast main dark element spell
---   - mainaja: Cast main -ja spell
---   - storm: Cast storm spell
---
--- @param cmdParams table Command parameters split by spaces
--- @param eventArgs table Event arguments for command handling
--- @usage //gs c test (runs unit tests)
--- @usage //gs c buffself (casts self buffs)
function job_self_command(cmdParams, eventArgs)
    -- Run unit tests
    if cmdParams[1] == 'test' then
        windower.add_to_chat(050, "Executing GearSwap module tests...")
        include('test_runner.lua')
        eventArgs.handled = true
        return
    end

    -- Existing BLM commands (if any exist in BLM_FUNCTION.lua)
    if cmdParams[1] == 'buffself' then
        BuffSelf()
        eventArgs.handled = true
        return
    end

    -- Add other BLM-specific commands here as needed
end
