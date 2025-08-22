---============================================================================
--- FFXI GearSwap Configuration - Black Mage (BLM)
---============================================================================
--- Professional GearSwap configuration for Black Mage job in FFXI.
--- Provides advanced automation for gear swapping, spell management, and
--- dual-boxing functionality with intelligent magic burst support.
---
--- @file Tetsouo_BLM.lua
--- @author Tetsouo
--- @version 2.1
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
    include('core/GLOBALS.lua')
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')      -- Automatic movement speed gear swapping
    include('modules/SHARED.lua')        -- Functions shared across multiple jobs
    include('jobs/blm/BLM_SET.lua')      -- Gear sets specific to Black Mage
    include('jobs/blm/BLM_FUNCTION.lua') -- Advanced functions specific to Black Mage

    -- Metrics system removed during cleanup
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
    -- BLM Keybindings F1-F7 dans l'ordre demandé
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F1 gs c cyclemainlight')
        send_command('bind F2 gs c cyclemaindark')
        send_command('bind F3 gs c cyclesublight')
        send_command('bind F4 gs c cyclesubdark')
        send_command('bind F5 gs c cycle Aja')
        send_command('bind F6 gs c cycle TierSpell')  -- TierSpell sur F6
        send_command('bind F7 gs c cycle Storm')
        
        -- BLM F9 pour CastingMode (F10-F12 libres pour GearSwap)
        send_command('bind F9 gs c cycle CastingMode')
    end, 0.5)
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
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    -- Unbinds the keys associated with the states.
    -- Unbind all F1-F7, F9 keys
    for i = 1, 7 do
        send_command('unbind F' .. i)
    end
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

--- Synchronize main states with alt player states when they change
--- This ensures alt player spells match main spell selections
function job_state_change(stateField, newValue, oldValue)
    -- Debug to see if this is called
    windower.add_to_chat(123, '[DEBUG] job_state_change: ' .. (stateField or 'nil') .. ' -> ' .. (newValue or 'nil'))
    
    -- Synchronize MainLightSpell with altPlayerLight
    if stateField == 'MainLightSpell' then
        state.altPlayerLight:set(newValue)
        -- Use the new BLM element message function (like PLD uses pld_rune_message)
        MessageUtils.blm_element_message('MainLight', newValue)
        -- MessageUtils now available globally via shared.lua
        MessageUtils.blm_sync_message('light', newValue)
    -- Synchronize MainDarkSpell with altPlayerDark  
    elseif stateField == 'MainDarkSpell' then
        state.altPlayerDark:set(newValue)
        -- Use the new BLM element message function
        MessageUtils.blm_element_message('MainDark', newValue)
        -- MessageUtils now available globally via shared.lua
        MessageUtils.blm_sync_message('dark', newValue)
    -- Synchronize SubLightSpell with altPlayerLight
    elseif stateField == 'SubLightSpell' then
        state.altPlayerLight:set(newValue)
        -- Use the new BLM element message function
        MessageUtils.blm_element_message('SubLight', newValue)
        -- MessageUtils now available globally via shared.lua
        MessageUtils.blm_sync_message('light', newValue)
    -- Synchronize SubDarkSpell with altPlayerDark
    elseif stateField == 'SubDarkSpell' then
        state.altPlayerDark:set(newValue)
        -- Use the new BLM element message function
        MessageUtils.blm_element_message('SubDark', newValue)
        -- MessageUtils now available globally via shared.lua
        MessageUtils.blm_sync_message('dark', newValue)
    -- Synchronize TierSpell with altPlayerTier
    elseif stateField == 'TierSpell' then
        state.altPlayerTier:set(newValue)
        -- MessageUtils now available globally via shared.lua
        MessageUtils.blm_sync_message('tier', newValue)
    end
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
    -- Metrics tracking removed during cleanup

    -- If the player is currently performing an action, immediately return and do nothing else.
    if midaction() then
        return
    end

    -- Force Fast Cast for transport spells when called by external addons (MyHome, warp, etc.)
    -- External addons sometimes bypass normal GearSwap precast hooks
    if spell.name then
        local spell_lower = spell.name:lower()
        if spell_lower:find('warp') or spell_lower:find('teleport') or spell_lower:find('recall') or
           spell.name == 'Retrace' or spell.name == 'Escape' then
            equip(sets.precast.FC)
        end
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
    -- Metrics tracking removed during cleanup

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

    -- Metrics tracking removed during cleanup
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
    -- Load macro manager safely
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success then
            macro_manager = result
        else
            windower.add_to_chat(167, '[BLM] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('BLM', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
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
    -- Custom BLM element cycling commands (like PLD's cyclerune)
    local command = cmdParams[1] and cmdParams[1]:lower() or ""
    
    -- Helper function for colored element messages
    local function show_element_message(state_type, element_name)
        local element_colors = {
            Fire = 057,      -- Orange
            Thunder = 012,   -- Yellow  
            Aero = 006,      -- Cyan
            Stone = 010,     -- Brown
            Water = 056,     -- Light Blue
            Blizzard = 005,  -- Blue
        }
        local color_code = element_colors[element_name] or 001
        local gray = string.char(0x1F, 160)
        local job_color = string.char(0x1F, 207)
        local element_color = string.char(0x1F, color_code)
        
        local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                       gray .. 'Current ' .. state_type .. ': ' .. 
                       element_color .. element_name .. gray
        windower.add_to_chat(001, message)
    end
    
    -- Custom cycle commands like PLD's cyclerune
    if command == 'cyclemainlight' then
        state.MainLightSpell:cycle()
        show_element_message('MainLight', state.MainLightSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclemaindark' then
        state.MainDarkSpell:cycle()
        show_element_message('MainDark', state.MainDarkSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclesublight' then
        state.SubLightSpell:cycle()
        show_element_message('SubLight', state.SubLightSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclesubdark' then
        state.SubDarkSpell:cycle()
        show_element_message('SubDark', state.SubDarkSpell.value)
        eventArgs.handled = true
        return
    end
    
    -- First, try universal commands (equiptest, validate_all, etc.)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if success_UniversalCommands and UniversalCommands then
        if UniversalCommands.handle_command(cmdParams, eventArgs) then
            return
        end
    end
    
    -- Handle macro commands using centralized system
    -- MacroCommands now available globally via shared.lua
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'BLM') then
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

    -- Existing BLM commands (if any exist in BLM_FUNCTION.lua)
    if cmdParams[1] == 'buffself' then
        BuffSelf()
        eventArgs.handled = true
        return
    end
    
    -- Alt player spell commands (case insensitive)
    local cmd = cmdParams[1] and cmdParams[1]:lower() or ""
    
    if cmd == 'altlight' then
        -- Cast light spell on alt character using synchronized states
        if state.altPlayerLight and state.altPlayerTier then
            local tierToUse = state.altPlayerTier.value
            -- RDM can only cast up to tier V, so limit if needed
            if tierToUse == 'VI' then
                tierToUse = 'V'
            end
            handle_altNuke(state.altPlayerLight.value, tierToUse, false)
            -- MessageUtils now available globally via shared.lua
            MessageUtils.blm_alt_cast_message('cast_light', state.altPlayerLight.value, tierToUse)
        else
            -- MessageUtils now available globally via shared.lua
            MessageUtils.blm_alt_cast_message('error_light')
        end
        eventArgs.handled = true
        return
    end
    
    if cmd == 'altdark' then
        -- Cast dark spell on alt character using synchronized states
        if state.altPlayerDark and state.altPlayerTier then
            local tierToUse = state.altPlayerTier.value
            -- RDM can only cast up to tier V, so limit if needed
            if tierToUse == 'VI' then
                tierToUse = 'V'
            end
            handle_altNuke(state.altPlayerDark.value, tierToUse, false)
            -- MessageUtils now available globally via shared.lua
            MessageUtils.blm_alt_cast_message('cast_dark', state.altPlayerDark.value, tierToUse)
        else
            -- MessageUtils now available globally via shared.lua
            MessageUtils.blm_alt_cast_message('error_dark')
        end
        eventArgs.handled = true
        return
    end

    -- Add other BLM-specific commands here as needed
end
