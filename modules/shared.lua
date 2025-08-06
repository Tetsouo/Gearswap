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
--- @version 2.0
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

-- Load critical modular dependencies for compatibility layer operation
local config = require('config/config')              -- Centralized configuration system
local log = require('utils/logger')                  -- Professional logging framework
local MessageUtils = require('utils/messages')       -- Message formatting utilities  
local EquipmentUtils = require('core/equipment')     -- Equipment management core
local SpellUtils = require('core/spells')           -- Spell validation and handling

-- Constants used throughout the script (from config)
SharedFunctions.GRAY = config.get_color('debug') or 160      -- Color code for gray
SharedFunctions.ORANGE = config.get_color('warning') or 057  -- Color code for orange
SharedFunctions.YELLOW = config.get_color('info') or 050     -- Color code for yellow
SharedFunctions.RED = config.get_color('error') or 028       -- Color code for red
SharedFunctions.WAIT_TIME = 1.2 -- Time to wait between actions, in seconds

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
    return MessageUtils.create_formatted_message(startMessage, spellName, recastTime, endMessage, isLastMessage, isColored)
end

-- ===========================================================================================================
--                                    2. Alternate Player Functions
-- ===========================================================================================================

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

--- Backward compatibility wrapper for alt state update
function update_altState()
    local StateUtils = require('core/state')
    StateUtils.update_alt_state()
    -- Keep SharedFunctions.altState synchronized for backward compatibility
    SharedFunctions.altState = StateUtils.get_alt_state()
end

--- Backward compatibility wrapper for geo buffing
function bubbleBuffForAltGeo(altSpell, isEntrust, isGeo)
    local DualBoxUtils = require('core/dualbox')
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

    for _, spell in ipairs(spells) do
        local command
        if spell.delay == 0 then
            command = string.format('send %s %s %s', SharedFunctions.altPlayerName, spell.name, tostring(targetid))
        else
            command =
                string.format('wait %d; send %s %s %s', spell.delay, SharedFunctions.altPlayerName, spell.name,
                    tostring(targetid))
        end
        if spell.name == 'Phalanx2' and targetname == SharedFunctions.mainPlayerName and player.main_job == 'PLD' then
            local bothPhalanx
            if spell.delay == 0 then
                bothPhalanx =
                    string.format(
                        'send %s Phalanx %s; send %s Phalanx2 %s',
                        SharedFunctions.mainPlayerName,
                        tostring(targetid),
                        SharedFunctions.altPlayerName,
                        tostring(targetid)
                    )
            else
                bothPhalanx =
                    string.format(
                        'wait %d; send %s Phalanx %s; send %s Phalanx2 %s',
                        spell.delay,
                        SharedFunctions.mainPlayerName,
                        tostring(targetid),
                        SharedFunctions.altPlayerName,
                        tostring(targetid)
                    )
            end
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

-- ===========================================================================================================
--                            3. Equipment and Gear Set Management Functions
-- ===========================================================================================================

-- Legacy wrapper for equipment creation (now uses EquipmentUtils)
function createEquipment(name, priority, bag, augments)
    return EquipmentUtils.create_equipment(name, priority, bag, augments)
end

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
    local UtilityUtils = require('utils/helpers')
    return UtilityUtils.get_current_target_id_and_name()
end

-- Legacy wrapper for incapacitation check (now uses SpellUtils)
function incapacitated(spell, eventArgs)
    return SpellUtils.check_incapacitated(spell, eventArgs)
end

--- Backward compatibility wrapper for party member pet check
function find_member_and_pet_in_party(name)
    local UtilityUtils = require('utils/helpers')
    return UtilityUtils.find_member_and_pet_in_party(name)
end

--- Backward compatibility wrapper for table contains (handled by UtilityUtils)
-- Note: table.contains is automatically extended by UtilityUtils
local UtilityUtils = require('utils/helpers')

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
    
    local MessageUtils = require('utils/messages')
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
    local CommandUtils = require('core/commands')
    return CommandUtils.handle_blm_commands(cmdParams)
end

--- Backward compatibility wrapper for SCH subjob commands
function handle_sch_subjob_commands(cmdParams)
    local CommandUtils = require('core/commands')
    return CommandUtils.handle_sch_subjob_commands(cmdParams)
end

--- Backward compatibility wrapper for WAR commands
function handle_war_commands(cmdParams)
    local CommandUtils = require('core/commands')
    return CommandUtils.handle_war_commands(cmdParams)
end

--- Backward compatibility wrapper for THF commands
function handle_thf_commands(cmdParams)
    local CommandUtils = require('core/commands')
    return CommandUtils.handle_thf_commands(cmdParams)
end

-- ===========================================================================================================
--                              7. Weapon Skill Adjustment Functions - DEPRECATED
-- ===========================================================================================================
-- These functions have been moved to libs/WeaponUtils.lua
-- Keeping wrapper functions for backward compatibility

local WeaponUtils = require('core/weapons')

--- Backward compatibility wrapper for weapon skill range check
function Ws_range(spell)
    return WeaponUtils.check_weaponskill_range(spell)
end

-- Legacy wrapper for ear equipment adjustment (now uses EquipmentUtils)
function adjust_Left_Ear_Equipment(spell, player_info)
    return EquipmentUtils.adjust_left_ear_equipment(spell, player_info)
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
    local StateUtils = require('core/state')
    return StateUtils.reset_to_default_equipment()
end

--- Backward compatibility wrapper for job equipment handling
function job_handle_equipping_gear(playerStatus, eventArgs)
    local StateUtils = require('core/state')
    return StateUtils.job_handle_equipping_gear(playerStatus, eventArgs)
end

--- Backward compatibility wrapper for job state change
function job_state_change(field, new_value, old_value)
    local StateUtils = require('core/state')
    
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
    local BuffManagerUtils = require('core/buff_manager')
    BuffManagerUtils.handle_buff_change(buff, gain)
end

-- ===========================================================================================================
--                             9. Stratagem Management Functions (SCH Job) - DEPRECATED
-- ===========================================================================================================
-- These functions have been moved to libs/ScholarUtils.lua
-- Keeping wrapper functions for backward compatibility

local ScholarUtils = require('utils/scholar')

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

local CommandUtils = require('core/commands')

-- Backward compatibility: expose commandFunctions from CommandUtils
commandFunctions = CommandUtils.commandFunctions

return SharedFunctions