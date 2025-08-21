---============================================================================
--- FFXI GearSwap Compatibility Layer - Shared Functions Module
---============================================================================
--- **CRITICAL COMPATIBILITY LAYER** - This module serves as the intelligent
--- bridge between legacy GearSwap code and the new modular architecture.
--- Provides 100% backward compatibility while enabling gradual migration to
--- the new module system. Features include:
---
--- • **21 Backward Compatibility Wrappers** - Zero breaking changes
--- • **Intelligent Module Loading** - Lazy loading for optimal performance
--- • **Legacy Function Preservation** - All existing code continues to work
--- • **Progressive Migration Path** - Gradual transition to new modules
--- • **Configuration Integration** - Centralized settings with fallbacks
--- • **Professional Error Handling** - Robust failure recovery mechanisms
---
--- This file is the **HEART** of the transition system - it maintains full
--- compatibility with existing job configurations while providing access to
--- all new modular functionality. All jobs depend on this compatibility layer.
---
--- @file modules/shared.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires config/config, utils/logger, utils/messages, core/equipment, core/spells
---
--- @usage
---   include('modules/shared.lua') -- Included by all job files
---   formatRecastDuration(recast) -- Legacy functions work unchanged
---   createFormattedMessage(...) -- Backward compatibility maintained
---
--- @warning **DO NOT MODIFY** this file without extensive testing across all jobs
--- @see Docs/ARCHITECTURE_OVERVIEW.md for compatibility layer documentation
---============================================================================

---============================================================================
--- MODULE INITIALIZATION AND DEPENDENCIES
---============================================================================

local SharedFunctions = {}

-- Load critical modular dependencies for compatibility layer operation with error handling
local config_success, config = pcall(require, 'config/config')
if not config_success then
    windower.add_to_chat(167, "Shared Module: Config module not found")
    return
end

local log_success, log = pcall(require, 'utils/LOGGER')
if not log_success then
    windower.add_to_chat(167, "Shared Module: Logger module not found")
    return
end

local msg_success, MessageUtils = pcall(require, 'utils/MESSAGES')
if not msg_success then
    windower.add_to_chat(167, "Shared Module: Messages module not found")
    return
end

local eq_success, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
if not eq_success then
    windower.add_to_chat(167, "Shared Module: Equipment module not found")
    return
end

local spell_success, SpellUtils = pcall(require, 'core/SPELLS')
if not spell_success then
    windower.add_to_chat(167, "Shared Module: Spells module not found")
    return
end

-- Load equipment factory (optional)
local factory_success = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not factory_success then
    log.warn("Equipment factory module not found, continuing without it")
end

---============================================================================
--- CENTRALIZED MODULE REGISTRY
---============================================================================
--- This section loads all commonly used modules with pcall protection
--- and exposes them globally so jobs don't need individual require calls.
--- This eliminates 283+ unprotected require calls across the project.
---============================================================================

-- Global module registry - All modules loaded with pcall protection
SharedFunctions.modules = {}

-- Helper function to safely load and register modules
local function safe_require(module_path, module_name, is_critical)
    local success, result = pcall(require, module_path)
    if success then
        SharedFunctions.modules[module_name] = result
        log.debug("Module loaded: %s", module_name)
        return result
    else
        local level = is_critical and "error" or "warn"
        log[level]("Failed to load module %s: %s", module_name, tostring(result))
        if is_critical then
            windower.add_to_chat(167, string.format("CRITICAL: %s module failed to load", module_name))
        end
        return nil
    end
end

-- Load all critical modules (already loaded above, but adding to registry)
SharedFunctions.modules.config = config
SharedFunctions.modules.log = log
SharedFunctions.modules.MessageUtils = MessageUtils
SharedFunctions.modules.EquipmentUtils = EquipmentUtils
SharedFunctions.modules.SpellUtils = SpellUtils

-- Load frequently used modules with protection
SharedFunctions.modules.MacroCommands = safe_require('macros/MACRO_COMMANDS', 'MacroCommands', true)
SharedFunctions.modules.MacroManager = safe_require('macros/MACRO_MANAGER', 'MacroManager', true)
SharedFunctions.modules.WeaponUtils = safe_require('equipment/WEAPONS', 'WeaponUtils', true)
SharedFunctions.modules.StateUtils = safe_require('core/STATE', 'StateUtils', true)
SharedFunctions.modules.DualBoxUtils = safe_require('features/DUALBOX', 'DualBoxUtils', true)
SharedFunctions.modules.UniversalCommands = safe_require('core/UNIVERSAL_COMMANDS', 'UniversalCommands', true)

-- Load utility modules
SharedFunctions.modules.ValidationUtils = safe_require('utils/VALIDATION', 'ValidationUtils', true)
SharedFunctions.modules.Colors = safe_require('utils/COLORS', 'Colors', false)
SharedFunctions.modules.Helpers = safe_require('utils/HELPERS', 'Helpers', false)
SharedFunctions.modules.ScholarUtils = safe_require('utils/SCHOLAR', 'ScholarUtils', false)
SharedFunctions.modules.AbilityHelper = safe_require('utils/ABILITY_HELPER', 'AbilityHelper', true)
SharedFunctions.modules.JobLoader = safe_require('utils/JOB_LOADER', 'JobLoader', false)
SharedFunctions.modules.EquipmentCache = safe_require('equipment/EQUIPMENT_CACHE', 'EquipmentCache', false)
SharedFunctions.modules.ModuleLoader = safe_require('utils/MODULE_LOADER', 'ModuleLoader', false)
SharedFunctions.modules.Notifications = safe_require('utils/NOTIFICATIONS', 'Notifications', false)

-- Load optional testing/performance modules
SharedFunctions.modules.Benchmark = safe_require('tests/performance/benchmark', 'Benchmark', false)

-- Load resources with protection
SharedFunctions.modules.resources = safe_require('resources', 'resources', true)

-- Create global aliases for backward compatibility and easy access
-- These replace all the individual require() calls in job files
_G.MessageUtils = SharedFunctions.modules.MessageUtils
_G.MacroCommands = SharedFunctions.modules.MacroCommands
_G.MacroManager = SharedFunctions.modules.MacroManager
_G.WeaponUtils = SharedFunctions.modules.WeaponUtils
_G.StateUtils = SharedFunctions.modules.StateUtils
_G.DualBoxUtils = SharedFunctions.modules.DualBoxUtils
_G.EquipmentUtils = SharedFunctions.modules.EquipmentUtils
_G.SpellUtils = SharedFunctions.modules.SpellUtils
_G.UniversalCommands = SharedFunctions.modules.UniversalCommands
_G.ValidationUtils = SharedFunctions.modules.ValidationUtils
_G.Colors = SharedFunctions.modules.Colors
_G.Helpers = SharedFunctions.modules.Helpers
_G.ScholarUtils = SharedFunctions.modules.ScholarUtils
_G.AbilityHelper = SharedFunctions.modules.AbilityHelper
_G.JobLoader = SharedFunctions.modules.JobLoader
_G.EquipmentCache = SharedFunctions.modules.EquipmentCache
_G.ModuleLoader = SharedFunctions.modules.ModuleLoader
_G.Notify = SharedFunctions.modules.Notifications
_G.Benchmark = SharedFunctions.modules.Benchmark
_G.config = SharedFunctions.modules.config
_G.log = SharedFunctions.modules.log
_G.res = SharedFunctions.modules.resources

-- Function to get a module safely (alternative to global access)
function SharedFunctions.get_module(module_name)
    local module = SharedFunctions.modules[module_name]
    if not module then
        log.warn("Requested module not available: %s", module_name)
        return nil
    end
    return module
end

-- Function to check if a module is available
function SharedFunctions.has_module(module_name)
    return SharedFunctions.modules[module_name] ~= nil
end

-- Constants used throughout the script (from config)
SharedFunctions.GRAY = config.get_color('debug') or 160     -- Color code for gray
SharedFunctions.ORANGE = config.get_color('warning') or 057 -- Color code for orange
SharedFunctions.YELLOW = config.get_color('info') or 050    -- Color code for yellow
SharedFunctions.RED = config.get_color('error') or 028      -- Color code for red
SharedFunctions.WAIT_TIME = 1.2                             -- Time to wait between actions, in seconds

-- Array of stratagem charge times
SharedFunctions.strat_charge_time = { 240, 120, 80, 60, 48 }

-- Array of spell names to be ignored
SharedFunctions.ignoredSpells = SpellUtils.ignoredSpells

-- The name of the main player (from config)
SharedFunctions.mainPlayerName = config.get_main_player()

-- The name of the alternate player (from config)
SharedFunctions.altPlayerName = config.get_alt_player()

-- Define an object to store the current state values
SharedFunctions.altState = {}

-- Set of incapacitating buffs
SharedFunctions.incapacitating_buffs_set = {
    silence = true,
    stun = true,
    petrification = true,
    terror = true,
    sleep = true,
    mute = true,
}

-- ===========================================================================================================
--                                         1. Legacy Message Function Wrappers
-- ===========================================================================================================
-- DEPRECATED: These functions have been moved to MessageUtils.lua
-- Keeping minimal wrappers for backward compatibility

function formatRecastDuration(recast)
    return MessageUtils.format_recast_duration(recast)
end

function createFormattedMessage(startMessage, spellName, recastTime, endMessage, isLastMessage, isColored)
    return MessageUtils.create_formatted_message(startMessage, spellName, recastTime, endMessage, isLastMessage,
        isColored)
end

-- ===========================================================================================================
--                                    2. Alternate Player Functions
-- ===========================================================================================================

-- Declare local variables to avoid global namespace pollution
local send_command = send_command
local windower = windower
local player = player
local assert = assert
local pcall = pcall
local type = type
local tonumber = tonumber
local tostring = tostring
local string = string
local math = math
local os = os
local table = table
local pairs = pairs
local ipairs = ipairs

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

--- Backward compatibility wrapper for alt state update
function update_altState()
    local success_StateUtils, StateUtils = pcall(require, 'core/state')
    if not success_StateUtils then
        error("Failed to load core/state: " .. tostring(StateUtils))
    end
    StateUtils.update_alt_state()
    -- Keep SharedFunctions.altState synchronized for backward compatibility
    SharedFunctions.altState = StateUtils.get_alt_state()
end

--- Backward compatibility wrapper for geo buffing
function bubbleBuffForAltGeo(altSpell, isEntrust, isGeo)
    local success_DualBoxUtils, DualBoxUtils = pcall(require, 'features/dualbox')
    if not success_DualBoxUtils then
        error("Failed to load features/dualbox: " .. tostring(DualBoxUtils))
    end
    return DualBoxUtils.bubble_buff_for_alt_geo(altSpell, isEntrust, isGeo)
end

--- Handles the casting of an alternate spell.
-- @param altSpell (string): The name of the alternate spell to cast.
-- @param altTier (string or nil): The tier of the alternate spell to cast.
-- @param isRaSpell (boolean): Indicates whether the spell is a Ra spell.
function handle_altNuke(altSpell, altTier, isRaSpell)
    assert(altSpell ~= '' and (altTier ~= '' or altTier == nil),
        "Invalid arguments: altSpell and altTier must not be empty strings")
    assert(type(altSpell) == 'string' and (altTier == nil or type(altTier) == 'string') and type(isRaSpell) == 'boolean',
        'Invalid input parameters')

    local spellToCast = altSpell .. (isRaSpell and ' III' or altTier)

    local targetid, targetname = get_current_target_id_and_name()

    if player.status == 'Engaged' then
        if targetid then
            local success, err = pcall(send_command,
                'send ' ..
                SharedFunctions.altPlayerName ..
                ' /assist <' ..
                SharedFunctions.mainPlayerName ..
                '>; wait 1; send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' <t>'
            )
            if not success then
                assert(false, 'Failed to send command: ' .. (err or 'Unknown error'))
            end
        end
    else
        local mob = windower.ffxi.get_mob_by_target('lastst')
        if mob and mob.id then
            targetid = mob.id
            local success, err = pcall(send_command,
                'send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid)
            if not success then
                assert(false, 'Failed to send command: ' .. (err or 'Unknown error'))
            end
        end
    end
end

--- Casts a sequence of spells on a target.
-- @param spells (table): A table of spells to cast.
-- @return (boolean): True if successful, false otherwise.
function applySpellSequenceToTarget(spells)
    if type(spells) ~= 'table' or #spells == 0 then
        return false
    end

    local success, targetid, targetname = pcall(get_current_target_id_and_name)
    if not success then
        return false
    end

    -- Optimized spell sequence processing with cached values
    local spellCount = #spells
    local altPlayerName = SharedFunctions.altPlayerName
    local targetIdStr = tostring(targetid)

    for i = 1, spellCount do
        local spell = spells[i]
        local spellName = spell.name
        local spellDelay = spell.delay

        -- Optimized command building
        local command = (spellDelay == 0) and
            ('send ' .. altPlayerName .. ' ' .. spellName .. ' ' .. targetIdStr) or
            ('wait ' .. spellDelay .. '; send ' .. altPlayerName .. ' ' .. spellName .. ' ' .. targetIdStr)
        -- Optimized Phalanx command building with cached values
        if spellName == 'Phalanx2' and targetname == SharedFunctions.mainPlayerName and player.main_job == 'PLD' then
            local mainPlayerName = SharedFunctions.mainPlayerName

            -- Build Phalanx command efficiently
            local bothPhalanx = (spellDelay == 0) and
                ('send ' .. mainPlayerName .. ' Phalanx ' .. targetIdStr .. '; send ' .. altPlayerName .. ' Phalanx2 ' .. targetIdStr) or
                ('wait ' .. spellDelay .. '; send ' .. mainPlayerName .. ' Phalanx ' .. targetIdStr .. '; send ' .. altPlayerName .. ' Phalanx2 ' .. targetIdStr)

            local success, message = pcall(send_command, bothPhalanx)
            if not success then
                return false
            end
        else
            local success, message = pcall(send_command, command)
            if not success then
                return false
            end
        end
    end

    return true
end

--- Handles the command sequence for a character.
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'bdd', 'buffrng', 'curaga', 'debuff').
-- @return (boolean): True if successful, false otherwise.
function bufferRoleForAltRdm(commandType)
    if type(commandType) ~= 'string' then
        return false
    end

    local success, targetid, targetname = pcall(get_current_target_id_and_name)
    if not success then
        return false
    end

    local spells = {}

    if commandType == 'bufftank' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Refresh3', delay = 4 },
            { name = 'Phalanx2', delay = 9 },
            { name = 'Regen2',   delay = 13 },
        }
    elseif commandType == 'buffmelee' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'buffrng' then
        spells = {
            { name = 'flurry2',  delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'curaga' then
        spells = {
            { name = 'curaga3', delay = 0 }
        }
    elseif commandType == 'debuff' then
        spells = {
            { name = 'distract3', delay = 0 },
            { name = 'dia3',      delay = 4 },
            { name = 'slow2',     delay = 8 },
            { name = 'Blind2',    delay = 12 },
            { name = 'paralyze2', delay = 17 }
        }
    end

    local success, message = pcall(applySpellSequenceToTarget, spells)
    if not success then
        return false
    end

    return true
end

---============================================================================
--- KAORIES COMMAND HANDLERS
---============================================================================

--- Handle Kaories dual-box commands
--- @param command string The command to execute (bufftank, buffmelee, buffrng, curaga, debuff)
--- @return boolean True if command was handled
function handle_kaories_command(command)
    if type(command) ~= 'string' then
        return false
    end

    local valid_commands = {
        bufftank = true,
        buffmelee = true,
        buffrng = true,
        curaga = true,
        debuff = true
    }

    if not valid_commands[command] then
        return false
    end

    return bufferRoleForAltRdm(command)
end

-- Export globally for job access
_G.handle_kaories_command = handle_kaories_command

-- ===========================================================================================================
--                            3. Equipment and Gear Set Management Functions
-- ===========================================================================================================

-- Legacy wrapper for equipment creation (now uses centralized equipment factory)
-- Note: The global createEquipment function is now provided by utils/equipment_factory

-- DEPRECATED: Equipment functions moved to EquipmentUtils.lua
function adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
    return EquipmentUtils.adjust_gear_based_on_tp_for_weaponskill(spell)
end

-- ===========================================================================================================
--                         4. State Management and Basic Data Handling Functions
-- ===========================================================================================================

--- Retrieves the ID and name of the current target.
-- @return (number, string) The ID and name of the current target, or nil if no target is selected.
--- Backward compatibility wrapper for target ID and name
function get_current_target_id_and_name()
    local success_UtilityUtils, UtilityUtils = pcall(require, 'utils/HELPERS')
    if not success_UtilityUtils then
        error("Failed to load utils/HELPERS: " .. tostring(UtilityUtils))
    end
    return UtilityUtils.get_current_target_id_and_name()
end

-- Legacy wrapper for incapacitation check (now uses SpellUtils)
function incapacitated(spell, eventArgs)
    return SpellUtils.check_incapacitated(spell, eventArgs)
end

--- Backward compatibility wrapper for party member pet check
function find_member_and_pet_in_party(name)
    local success_UtilityUtils, UtilityUtils = pcall(require, 'utils/HELPERS')
    if not success_UtilityUtils then
        error("Failed to load utils/HELPERS: " .. tostring(UtilityUtils))
    end
    return UtilityUtils.find_member_and_pet_in_party(name)
end

--- Backward compatibility wrapper for table contains (handled by UtilityUtils)
-- Note: table.contains is automatically extended by UtilityUtils
local success_UtilityUtils, UtilityUtils = pcall(require, 'utils/HELPERS')
if not success_UtilityUtils then
    error("Failed to load utils/HELPERS: " .. tostring(UtilityUtils))
end

--- Backward compatibility wrapper for TH action check
function th_action_check(category, param)
    return UtilityUtils.th_action_check(category, param)
end

-- ===========================================================================================================
--                                     5. Spell Casting Functions
-- ===========================================================================================================

-- Legacy wrappers for spell functions (now use SpellUtils)
function can_cast_spell(spell, eventArgs)
    return SpellUtils.can_cast_spell(spell, eventArgs)
end

function try_cast_spell(spell, eventArgs)
    return SpellUtils.try_cast_spell(spell, eventArgs)
end

function handle_unable_to_cast(spell, eventArgs)
    return SpellUtils.handle_unable_to_cast(spell, eventArgs)
end

-- More legacy wrappers for spell functions (now use SpellUtils)
function checkDisplayCooldown(spell, eventArgs)
    return SpellUtils.check_display_cooldown(spell, eventArgs)
end

function handle_spell(spell, eventArgs, auto_abilities)
    return SpellUtils.handle_spell(spell, eventArgs, auto_abilities)
end

function auto_ability(spell, eventArgs, abilityId, waitTime, abilityName)
    return SpellUtils.auto_ability(spell, eventArgs, abilityId, waitTime, abilityName)
end

function handleInterruptedSpell(spell, eventArgs)
    return SpellUtils.handle_interrupted_spell(spell, eventArgs)
end

--- Global spell_interrupted function for GearSwap event handling
-- This function is called automatically by GearSwap when a spell is interrupted
function spell_interrupted(spell, eventArgs)
    -- Suppress default GearSwap message by setting handled = true
    if eventArgs then
        eventArgs.handled = true
    end

    -- Don't show interruption message if this was a cooldown cancel
    if _G.cooldown_cancel_in_progress then
        return true
    end

    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    MessageUtils.spell_interrupted_message(spell)
    return true
end

function handleCompletedSpell(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if state and state.Moving and state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end

    return true
end

function handleSpellAftercast(spell, eventArgs)
    return SpellUtils.handle_spell_aftercast(spell, eventArgs)
end

-- Legacy wrappers for spell casting functions (now use SpellUtils)
function castElementalSpells(mainSpell, tier)
    return SpellUtils.cast_elemental_spell(mainSpell, tier)
end

function castArtsOrAddendum(arts, addendum)
    local command
    if not buffactive[arts] then
        command = 'input /ja "' .. arts .. '" <me>'
    else
        command = 'input /ja "' .. addendum .. '" <me>'
    end
    send_command(command)
end

function castSchSpell(spell, arts, addendum)
    return SpellUtils.cast_sch_spell(spell, arts, addendum)
end

function refine_Utsusemi(spell, eventArgs)
    return SpellUtils.refine_utsusemi(spell, eventArgs)
end

-- ===========================================================================================================
--                               6. Job-Specific Command Handling Functions
-- ===========================================================================================================

--- Backward compatibility wrapper for BLM commands
function handle_blm_commands(cmdParams)
    local success_CommandUtils, CommandUtils = pcall(require, 'core/COMMANDS')
    if not success_CommandUtils then
        error("Failed to load core/COMMANDS: " .. tostring(CommandUtils))
    end
    return CommandUtils.handle_blm_commands(cmdParams)
end

--- Backward compatibility wrapper for SCH subjob commands
function handle_sch_subjob_commands(cmdParams)
    local success_CommandUtils, CommandUtils = pcall(require, 'core/COMMANDS')
    if not success_CommandUtils then
        error("Failed to load core/COMMANDS: " .. tostring(CommandUtils))
    end
    return CommandUtils.handle_sch_subjob_commands(cmdParams)
end

--- Backward compatibility wrapper for WAR commands
function handle_war_commands(cmdParams)
    local success_CommandUtils, CommandUtils = pcall(require, 'core/COMMANDS')
    if not success_CommandUtils then
        error("Failed to load core/COMMANDS: " .. tostring(CommandUtils))
    end
    return CommandUtils.handle_war_commands(cmdParams)
end

--- Backward compatibility wrapper for THF commands
function handle_thf_commands(cmdParams)
    local success_CommandUtils, CommandUtils = pcall(require, 'core/COMMANDS')
    if not success_CommandUtils then
        error("Failed to load core/COMMANDS: " .. tostring(CommandUtils))
    end
    return CommandUtils.handle_thf_commands(cmdParams)
end

-- ===========================================================================================================
--                              7. Weapon Skill Adjustment Functions - DEPRECATED
-- ===========================================================================================================
-- These functions have been moved to libs/WeaponUtils.lua
-- Keeping wrapper functions for backward compatibility

local success_WeaponUtils, WeaponUtils = pcall(require, 'equipment/weapons')
if not success_WeaponUtils then
    error("Failed to load equipment/weapons: " .. tostring(WeaponUtils))
end

--- Backward compatibility wrapper for weapon skill range check
function Ws_range(spell)
    return WeaponUtils.check_weaponskill_range(spell)
end

-- Legacy wrapper for ear equipment adjustment (now uses EquipmentUtils)
function adjust_Left_Ear_Equipment(spell, player_info)
    return EquipmentUtils.adjust_ear_equipment(spell, player_info)
end

-----------------------------------------------------------------------------------------------
-- check_weaponset(weaponType)
--
-- Checks and equips the correct weapon set based on the player's main job and the weapon type.
-- WAR: Only equips main weapon set which includes both main and sub weapons (no separate sub set).
-- THF/BST: Uses main and sub sets separately depending on the job logic.
-- Others: Default handling for main and sub sets, except BLM which is excluded.
--
-- @param weaponType (string): Must be either 'main' or 'sub'.
-----------------------------------------------------------------------------------------------
--- Backward compatibility wrapper for weapon set checking
function check_weaponset(weaponType)
    return WeaponUtils.check_weaponset(weaponType)
end

--- Backward compatibility wrapper for range lock checking
function check_range_lock()
    return WeaponUtils.check_range_lock()
end

--- Backward compatibility wrapper for equipment reset
function reset_to_default_equipment()
    local success_StateUtils, StateUtils = pcall(require, 'core/state')
    if not success_StateUtils then
        error("Failed to load core/state: " .. tostring(StateUtils))
    end
    return StateUtils.reset_to_default_equipment()
end

--- Backward compatibility wrapper for job equipment handling
function job_handle_equipping_gear(playerStatus, eventArgs)
    local success_StateUtils, StateUtils = pcall(require, 'core/state')
    if not success_StateUtils then
        error("Failed to load core/state: " .. tostring(StateUtils))
    end
    return StateUtils.job_handle_equipping_gear(playerStatus, eventArgs)
end

--- Backward compatibility wrapper for job state change
function job_state_change(field, new_value, old_value)
    local success_StateUtils, StateUtils = pcall(require, 'core/state')
    if not success_StateUtils then
        error("Failed to load core/state: " .. tostring(StateUtils))
    end

    -- Handle legacy BST-specific functions that may not be in StateUtils
    if field and field:lower() == 'ammo' and display_broth_count then
        display_broth_count()
    end

    -- BST logic is now centralized in BST_FUNCTION.lua
    -- Only handle ammoSet changes for F5 cycling
    if field and field:lower() == 'ammoset' then
        -- When ammoSet changes (via F5 or cycle command), equip the broth
        if equip_pet_broth then
            coroutine.schedule(function() equip_pet_broth() end, 0.1)
        end
    end

    return StateUtils.job_state_change(field, new_value, old_value)
end

--- Backward compatibility wrapper for buff change handling
-- @param buff (string): The name of the buff
-- @param gain (boolean): Whether the buff was gained or lost
function buff_change(buff, gain)
    local success_BuffManagerUtils, BuffManagerUtils = pcall(require, 'core/buff_manager')
    if not success_BuffManagerUtils then
        error("Failed to load core/buff_manager: " .. tostring(BuffManagerUtils))
    end
    BuffManagerUtils.handle_buff_change(buff, gain)
end

-- ===========================================================================================================
--                             9. Stratagem Management Functions (SCH Job) - DEPRECATED
-- ===========================================================================================================
-- These functions have been moved to libs/ScholarUtils.lua
-- Keeping wrapper functions for backward compatibility

local success_ScholarUtils, ScholarUtils = pcall(require, 'utils/scholar')
if not success_ScholarUtils then
    error("Failed to load utils/scholar: " .. tostring(ScholarUtils))
end

--- Backward compatibility wrapper for get_max_stratagem_count
function get_max_stratagem_count()
    return ScholarUtils.get_max_stratagem_count()
end

--- Backward compatibility wrapper for get_stratagem_recast_time
function get_stratagem_recast_time()
    return ScholarUtils.get_stratagem_recast_time()
end

--- Backward compatibility wrapper for get_available_stratagem_count
function get_available_stratagem_count()
    return ScholarUtils.get_available_stratagem_count()
end

--- Backward compatibility wrapper for stratagems_available
function stratagems_available()
    return ScholarUtils.stratagems_available()
end

-- ===========================================================================================================
--                                     10. Command Functions Mapping - DEPRECATED
-- ===========================================================================================================
-- These functions have been moved to libs/CommandUtils.lua
-- Keeping reference for backward compatibility

-- Load CommandUtils with protection (moved from unprotected require)
SharedFunctions.modules.CommandUtils = safe_require('core/COMMANDS', 'CommandUtils', true)
local CommandUtils = SharedFunctions.modules.CommandUtils

-- Backward compatibility: expose commandFunctions from CommandUtils
commandFunctions = CommandUtils.commandFunctions

-- ===========================================================================================================
--                                     11. Auto Job Change Detection - DISABLED
-- ===========================================================================================================
-- DISABLED: This automatic job change detection system was causing conflicts
-- with the new unified macro/lockstyle management system. Job changes are now
-- handled properly by the centralized macro_manager.lua system called from
-- each job's select_default_macro_book() function.
--
-- The unified system provides:
-- - Better timing control
-- - Spam prevention
-- - Proper dressup coordination
-- - No conflicts between manual and automatic changes
-- ===========================================================================================================

-- Previous automatic job change detection system has been disabled
-- Job changes are now handled by the unified macro/lockstyle management system

return SharedFunctions
