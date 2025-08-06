---============================================================================
--- FFXI GearSwap Core Module - Weapon Management Utilities
---============================================================================
--- Professional weapon management system for GearSwap job configurations.
--- Provides weapon skill range checking, equipment validation, weapon set
--- management, and job-specific weapon optimization. Core features include:
---
--- • **Weapon Skill Range Validation** - Automatic distance checking and cancellation
--- • **Multi-Weapon Set Management** - Dynamic weapon switching based on situation
--- • **TP-Based Gear Selection** - Intelligent WS gear based on TP levels
--- • **Weapon Compatibility Checking** - Job and subjob weapon validation
--- • **Ammo Management Integration** - BST pet broth and combat ammo coordination
--- • **Range Attack Support** - Bow, gun, and throwing weapon optimization
--- • **Weapon Skill Timing** - Optimal timing and gear swapping for WS
--- • **Error Recovery** - Robust handling of weapon swap failures
---
--- This module centralizes all weapon-related logic across job configurations,
--- ensuring consistent and reliable weapon management with comprehensive
--- error handling and performance optimization.
---
--- @file core/weapons.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, utils/messages
---
--- @usage
---   local WeaponUtils = require('core/weapons')
---   WeaponUtils.check_weaponskill_range(spell)
---   WeaponUtils.equip_weapon_set(weapon_name, sub_name)
---
--- @see jobs/*/FUNCTION.lua for job-specific weapon optimization
---============================================================================

local WeaponUtils = {}

-- Load critical dependencies for weapon management operations
local config = require('config/config')              -- Centralized configuration system
local log = require('utils/logger')                  -- Professional logging framework  
local MessageUtils = require('utils/messages')       -- Message formatting utilities

-- ===========================================================================================================
--                                     Weapon Skill Range Check
-- ===========================================================================================================

--- Checks if a weapon skill is within range of the target.
-- @param spell (table): A table containing information about the spell.
-- @return (boolean): True if in range, false if cancelled
function WeaponUtils.check_weaponskill_range(spell)
    if spell.type ~= "WeaponSkill" then
        return true -- Not a weapon skill, no range check needed
    end

    if not spell or type(spell) ~= 'table' then
        log.error("Invalid spell parameter for range check")
        return false
    end

    if not spell.target or type(spell.target) ~= 'table' then
        log.error("Spell target information missing")
        return false
    end

    if type(spell.range) ~= 'number' or type(spell.target.distance) ~= 'number' or type(spell.target.model_size) ~= 'number' then
        log.error("Missing numeric values for range calculation")
        return false
    end

    local range_multiplier = config.get('combat.weaponskill.range_multiplier') or 1.55
    local effective_range = spell.target.model_size + spell.range * range_multiplier

    if effective_range < spell.target.distance then
        cancel_spell()

        MessageUtils.incapacitated_message(spell.name, "Too Far!")
        log.warn("Cancelled weapon skill %s - target too far (distance: %.1f, effective range: %.1f)",
            spell.name, spell.target.distance, effective_range)

        return false
    end

    return true
end

-- ===========================================================================================================
--                                     Weapon Set Management
-- ===========================================================================================================

--- Checks and equips appropriate weapon set based on job and weapon type
-- @param weaponType (string): Must be either 'main' or 'sub'
-- @return (boolean): True if successful, false otherwise
function WeaponUtils.check_weaponset(weaponType)
    if not player then
        log.error("Player object not available")
        return false
    end

    if not player.main_job then
        log.error("Player main job not available")
        return false
    end

    if weaponType ~= 'main' and weaponType ~= 'sub' then
        log.error("Invalid weaponType: %s (must be 'main' or 'sub')", tostring(weaponType))
        return false
    end

    -- THF-specific weapon handling
    if player.main_job == 'THF' then
        return WeaponUtils.handle_thf_weapons(weaponType)

        -- BST-specific weapon handling
    elseif player.main_job == 'BST' then
        return WeaponUtils.handle_bst_weapons(weaponType)

        -- General weapon handling (excludes BLM)
    elseif player.main_job ~= 'BLM' then
        return WeaponUtils.handle_general_weapons(weaponType)
    end

    return true
end

--- Handles THF-specific weapon set logic
-- @param weaponType (string): 'main' or 'sub'
-- @return (boolean): Success status
function WeaponUtils.handle_thf_weapons(weaponType)
    if not (state and state.AbysseaProc and state.WeaponSet2 and state.WeaponSet1 and state.SubSet) then
        log.error("THF weapon state variables not properly initialized")
        return false
    end

    if not (sets and sets[state.WeaponSet1.current] and sets[state.WeaponSet2.current] and sets[state.SubSet.current]) then
        log.error("THF weapon sets not properly defined")
        return false
    end

    local success = false

    if weaponType == 'main' then
        local weapon_set = state.AbysseaProc.value and sets[state.WeaponSet2.current] or sets[state.WeaponSet1.current]
        success, error_msg = pcall(equip, weapon_set)

        if success then
            log.debug("THF main weapon equipped: %s", state.AbysseaProc.value and "Proc set" or "Normal set")
        else
            log.error("Failed to equip THF main weapon: %s", error_msg or "unknown error")
        end
    elseif weaponType == 'sub' then
        success, error_msg = pcall(equip, sets[state.SubSet.current])

        if success then
            log.debug("THF sub weapon equipped: %s", state.SubSet.current)
        else
            log.error("Failed to equip THF sub weapon: %s", error_msg or "unknown error")
        end
    end

    return success
end

--- Handles BST-specific weapon and ammo logic
-- @param weaponType (string): 'main' or 'sub'
-- @return (boolean): Success status
function WeaponUtils.handle_bst_weapons(weaponType)
    if not (state and state.WeaponSet and state.SubSet and state.ammoSet) then
        log.error("BST weapon state variables not properly initialized")
        return false
    end

    -- Handle ammo first for BST
    WeaponUtils.handle_bst_ammo()

    local success = false

    if weaponType == 'main' then
        if not sets[state.WeaponSet.current] then
            log.error("BST main weapon set does not exist: %s", state.WeaponSet.current)
            return false
        end

        success, error_msg = pcall(equip, sets[state.WeaponSet.current])

        if success then
            log.debug("BST main weapon equipped: %s", state.WeaponSet.current)
        else
            log.error("Failed to equip BST main weapon: %s", error_msg or "unknown error")
        end
    elseif weaponType == 'sub' then
        if not sets[state.SubSet.current] then
            log.error("BST sub weapon set does not exist: %s", state.SubSet.current)
            return false
        end

        success, error_msg = pcall(equip, sets[state.SubSet.current])

        if success then
            log.debug("BST sub weapon equipped: %s", state.SubSet.current)
        else
            log.error("Failed to equip BST sub weapon: %s", error_msg or "unknown error")
        end
    end

    return success
end

--- Handles BST ammo management
function WeaponUtils.handle_bst_ammo()
    if player.status == 'Engaged' then
        -- Use combat ammo when engaged
        local combat_ammo = config.get('jobs.bst.combat_ammo') or "Aurgelmir Orb +1"
        local success, error_msg = pcall(equip, { ammo = combat_ammo })

        if success then
            log.debug("BST combat ammo equipped: %s", combat_ammo)
        else
            log.error("Failed to equip BST combat ammo: %s", error_msg or "unknown error")
        end
    elseif state.ammoSet and sets[state.ammoSet.value] then
        -- Use pet-focused ammo when not engaged
        local success, error_msg = pcall(equip, sets[state.ammoSet.value])

        if success then
            log.debug("BST pet ammo equipped: %s", state.ammoSet.value)
        else
            log.error("Failed to equip BST pet ammo: %s", error_msg or "unknown error")
        end
    end
end

--- Handles general weapon set logic for most jobs
-- @param weaponType (string): 'main' or 'sub'
-- @return (boolean): Success status
function WeaponUtils.handle_general_weapons(weaponType)
    if not (state and state.WeaponSet) then
        log.error("General weapon state variables not properly initialized")
        return false
    end

    local success = false

    if weaponType == 'main' then
        if not sets[state.WeaponSet.current] then
            log.error("Main weapon set does not exist: %s", state.WeaponSet.current)
            return false
        end

        success, error_msg = pcall(equip, sets[state.WeaponSet.current])

        if success then
            log.debug("Main weapon equipped: %s", state.WeaponSet.current)
        else
            log.error("Failed to equip main weapon: %s", error_msg or "unknown error")
        end
    elseif weaponType == 'sub' and player.main_job ~= 'WAR' then
        -- WAR doesn't use separate sub sets (included in main WeaponSet)
        if not (state.SubSet and sets[state.SubSet.current]) then
            log.error("SubSet or corresponding set is missing")
            return false
        end

        success, error_msg = pcall(equip, sets[state.SubSet.current])

        if success then
            log.debug("Sub weapon equipped: %s", state.SubSet.current)
        else
            log.error("Failed to equip sub weapon: %s", error_msg or "unknown error")
        end
    end

    return success
end

-- ===========================================================================================================
--                                     Range Lock Management
-- ===========================================================================================================

--- Checks if a ranged weapon is equipped and locks or unlocks the range and ammo slots accordingly
-- @return (boolean): True if successful, false otherwise
function WeaponUtils.check_range_lock()
    if not (player and player.equipment and player.equipment.range) then
        log.error("Player equipment information not available")
        return false
    end

    local success = false
    local error_msg = nil

    if player.equipment.range ~= 'empty' then
        -- Lock range and ammo slots when ranged weapon is equipped
        success, error_msg = pcall(disable, 'range', 'ammo')

        if success then
            log.debug("Range and ammo slots locked (ranged weapon equipped)")
        else
            log.error("Failed to disable range and ammo slots: %s", error_msg or "unknown error")
        end
    else
        -- Unlock range and ammo slots when no ranged weapon
        success, error_msg = pcall(enable, 'range', 'ammo')

        if success then
            log.debug("Range and ammo slots unlocked (no ranged weapon)")
        else
            log.error("Failed to enable range and ammo slots: %s", error_msg or "unknown error")
        end
    end

    return success
end

-- ===========================================================================================================
--                                     Weapon Information and Utilities
-- ===========================================================================================================

--- Gets information about currently equipped weapons
-- @return (table): Table with main and sub weapon information
function WeaponUtils.get_weapon_info()
    if not (player and player.equipment) then
        return { main = nil, sub = nil, range = nil, ammo = nil }
    end

    return {
        main = player.equipment.main or "empty",
        sub = player.equipment.sub or "empty",
        range = player.equipment.range or "empty",
        ammo = player.equipment.ammo or "empty"
    }
end

--- Checks if player has a specific weapon equipped
-- @param weapon_name (string): Name of the weapon to check
-- @param slot (string, optional): Specific slot to check ('main', 'sub', 'range'). If nil, checks all weapon slots
-- @return (boolean): True if weapon is equipped in specified slot(s)
function WeaponUtils.has_weapon_equipped(weapon_name, slot)
    if type(weapon_name) ~= 'string' then
        log.error("Weapon name must be a string")
        return false
    end

    local weapon_info = WeaponUtils.get_weapon_info()

    if slot then
        if slot == 'main' or slot == 'sub' or slot == 'range' then
            return weapon_info[slot] == weapon_name
        else
            log.error("Invalid weapon slot: %s", slot)
            return false
        end
    else
        -- Check all weapon slots
        return weapon_info.main == weapon_name or
            weapon_info.sub == weapon_name or
            weapon_info.range == weapon_name
    end
end

--- Validates weapon set configuration
-- @param set_name (string): Name of the weapon set to validate
-- @return (boolean, table): Success status and list of issues
function WeaponUtils.validate_weapon_set(set_name)
    if type(set_name) ~= 'string' then
        log.error("Set name must be a string")
        return false, { "Invalid set name type" }
    end

    if not sets or not sets[set_name] then
        return false, { "Set does not exist: " .. set_name }
    end

    local issues = {}
    local weapon_set = sets[set_name]

    -- Check for required weapon slots
    if not weapon_set.main then
        table.insert(issues, "Missing main weapon in set: " .. set_name)
    end

    -- Additional validation could be added here
    -- e.g., checking if weapons exist in inventory

    return #issues == 0, issues
end

-- ===========================================================================================================
--                                     Weapon Skill TP Management
-- ===========================================================================================================

--- Common TP threshold logic used by multiple jobs (WAR, DRG, THF, DNC)
-- @param tp (number): Total TP value including gear and buff bonuses
-- @return (number): The closest valid TP tier (1000, 2000, or 3000)
function WeaponUtils.get_tp_threshold(tp)
    if tp >= 3000 then
        return 3000
    elseif tp >= 2000 then
        return 2000
    else
        return 1000
    end
end

--- Common logic for determining if TP bonus gear should be used
-- @param spell (table): The Weapon Skill spell data
-- @param ws_info (table): Weapon skill info with tp_bonus_gear_always
-- @param weapon_tp_bonus (number): TP bonus from current weapon (optional)
-- @return (string|nil): 'TPBonus' if gear improves scaling, otherwise nil
function WeaponUtils.get_tp_bonus_mode(spell, ws_info, weapon_tp_bonus)
    if spell.type ~= 'WeaponSkill' then 
        return nil 
    end

    local current_tp = player.tp
    local tp_bonus_buffs = 0
    local tp_bonus_gear_always = 0
    weapon_tp_bonus = weapon_tp_bonus or 0

    -- Always-on TP bonus gear (e.g. Boii Cuisses +3)
    if ws_info and ws_info.tp_bonus_gear_always then
        tp_bonus_gear_always = ws_info.tp_bonus_gear_always
    end

    -- Common buff: Warcry grants +700 TP
    if buffactive['Warcry'] then
        tp_bonus_buffs = tp_bonus_buffs + 700
    end

    -- Total TP before optional gear (Moonshade)
    local total_tp = current_tp + tp_bonus_buffs + tp_bonus_gear_always + weapon_tp_bonus
    if total_tp < 1000 then 
        return nil 
    end

    -- Compare scaling tiers
    local threshold_without = WeaponUtils.get_tp_threshold(total_tp)
    local threshold_with = WeaponUtils.get_tp_threshold(total_tp + 250) -- Moonshade bonus

    if threshold_with > threshold_without and threshold_with >= 2000 then
        return 'TPBonus'
    end

    return nil
end

--- Common weapon-specific TP bonus mapping used by multiple jobs
-- @param weapon_name (string): Name of the main weapon
-- @return (number): TP bonus for this weapon
function WeaponUtils.get_weapon_tp_bonus(weapon_name)
    local weapon_tp_bonuses = {
        ['Chango'] = 500,  -- Used by WAR
        -- Add other weapons as needed
    }
    
    return weapon_tp_bonuses[weapon_name] or 0
end

--- Job-specific weapon mappings (main weapon -> sub weapon)
-- @param job (string): Job abbreviation (e.g., 'WAR', 'PLD')
-- @return (table): Weapon mapping table for the job
function WeaponUtils.get_weapon_mapping(job)
    local job_mappings = {
        WAR = {
            ['Naegling']   = 'Blurred Shield +1',
            ['Ukonvasara'] = 'Utu Grip',
            ['Loxotic']    = 'Blurred Shield +1',
            ['Chango']     = 'Utu Grip',
            ['Lycurgos']   = 'Utu Grip',
            ['Shining']    = 'Utu Grip',
        },
        -- Add other jobs as needed
        PLD = {
            ['Burtgang']   = 'Aegis',
            ['Naegling']   = 'Duban',
            -- Add more as needed
        }
    }
    
    return job_mappings[job] or {}
end

return WeaponUtils
