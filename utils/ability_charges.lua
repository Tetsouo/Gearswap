---============================================================================
--- FFXI GearSwap Utility Module - Ability Charges Management
---============================================================================
--- Professional ability charges management system for GearSwap automation.
--- Provides comprehensive support for abilities with multiple charges including
--- Scholar Stratagems, BST Ready moves, COR Quick Draw, and other charge-based
--- abilities. Core features include:
---
--- • **Universal Charge Calculation** - Works with any multi-charge ability
--- • **Accurate Availability Checking** - Proper charge counting logic
--- • **Recast Time Management** - Per-charge recast calculation
--- • **Job-Specific Support** - SCH, BST, COR, BLU abilities
--- • **Error Recovery** - Robust handling of edge cases
---
--- This module ensures proper management of abilities that have multiple
--- charges, avoiding the common mistake of checking only if recast > 0
--- which would limit abilities to a single charge.
---
--- @file utils/ability_charges.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-08
--- @requires utils/logger
---
--- @usage
---   local ChargesUtils = require('utils/ability_charges')
---   local charges = ChargesUtils.get_available_charges('Stratagems')
---   if ChargesUtils.has_charges('Ready') then ... end
---============================================================================

local ChargesUtils = {}

-- Load dependencies
local log = require('utils/logger')

-- ===========================================================================================================
--                                     Ability Charge Definitions
-- ===========================================================================================================

-- Define abilities with multiple charges and their properties
-- ability_id: The windower ability ID
-- max_charges: Function to calculate max charges based on job/level
-- charge_time: Function to calculate recharge time per charge
local CHARGED_ABILITIES = {
    -- Scholar Stratagems
    stratagems = {
        ability_id = 231,
        job_required = 'SCH',
        max_charges = function(player)
            local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
            if lvl >= 90 then return 5
            elseif lvl >= 70 then return 4
            elseif lvl >= 50 then return 3
            elseif lvl >= 30 then return 2
            elseif lvl >= 10 then return 1
            else return 0 end
        end,
        charge_time = function(player)
            local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
            if lvl >= 99 then return 33
            elseif lvl >= 90 then return 48
            elseif lvl >= 70 then return 60
            elseif lvl >= 50 then return 80
            elseif lvl >= 30 then return 120
            else return 240 end
        end
    },
    
    -- Beastmaster Ready
    ready = {
        ability_id = 102,  -- Ready ability ID
        job_required = 'BST',
        max_charges = function(player)
            -- BST gets 3 charges for Ready at 75+
            local lvl = player.main_job_level
            if lvl >= 75 then
                return 3  -- 3 charges at 75+
            elseif lvl >= 45 then
                return 2
            elseif lvl >= 15 then
                return 1
            else
                return 0
            end
        end,
        charge_time = function(player)
            -- Base recharge time, can be modified by gear
            return 90  -- 90 seconds base per charge
        end
    },
    
    -- Beastmaster Sic (same as Ready)
    sic = {
        ability_id = 102,  -- Sic uses same ID as Ready
        job_required = 'BST',
        max_charges = function(player)
            -- BST gets 3 charges for Sic at 75+
            local lvl = player.main_job_level
            if lvl >= 75 then
                return 3  -- 3 charges at 75+
            elseif lvl >= 45 then
                return 2
            elseif lvl >= 15 then
                return 1
            else
                return 0
            end
        end,
        charge_time = function(player)
            -- Base recharge time, can be modified by gear
            return 90  -- 90 seconds base per charge
        end
    },
    
    -- Corsair Quick Draw
    quick_draw = {
        ability_id = 195,  -- Quick Draw ability ID
        job_required = 'COR',
        max_charges = function(player)
            -- COR gets 4 charges with Quick Draw at 99
            if player.main_job == 'COR' then
                local lvl = player.main_job_level
                if lvl >= 99 then
                    return 4  -- 4 charges at 99
                elseif lvl >= 84 then
                    return 3  -- 3 charges at 84+
                elseif lvl >= 50 then
                    return 2  -- 2 charges at 50+
                elseif lvl >= 40 then
                    return 1  -- 1 charge at 40+
                end
            end
            return 0
        end,
        charge_time = function(player)
            return 60  -- 60 seconds per charge
        end
    },
    
    -- Blue Mage Unbridled Learning/Wisdom
    unbridled = {
        ability_id = 485,  -- Unbridled Learning
        job_required = 'BLU',
        max_charges = function(player)
            if player.main_job == 'BLU' and player.main_job_level >= 95 then
                return 2  -- 2 charges at 95+
            elseif player.main_job == 'BLU' and player.main_job_level >= 81 then
                return 1
            end
            return 0
        end,
        charge_time = function(player)
            return 300  -- 5 minutes per charge
        end
    }
}

-- ===========================================================================================================
--                                     Core Charge Calculation Functions
-- ===========================================================================================================

--- Get the available charges for a specific ability
-- @param ability_name string The name of the ability (e.g., 'stratagems', 'ready', 'quick_draw')
-- @return number The number of available charges
function ChargesUtils.get_available_charges(ability_name)
    ability_name = ability_name:lower()
    
    local ability_data = CHARGED_ABILITIES[ability_name]
    if not ability_data then
        log.debug("Ability '%s' not found in charged abilities list", ability_name)
        return 0
    end
    
    -- Check job requirement
    if ability_data.job_required then
        if player.main_job ~= ability_data.job_required and 
           player.sub_job ~= ability_data.job_required then
            return 0
        end
    end
    
    -- Get max charges for this ability
    local max_charges = ability_data.max_charges(player)
    if max_charges == 0 then
        return 0
    end
    
    -- Get current recast time
    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts then
        log.error("Could not get ability recasts")
        return 0
    end
    
    local recast_time = ability_recasts[ability_data.ability_id] or 0
    
    -- If recast is 0, all charges are available
    if recast_time == 0 then
        return max_charges
    end
    
    -- Calculate charge time
    local charge_time = ability_data.charge_time(player)
    if charge_time == 0 then
        log.error("Invalid charge time for ability '%s'", ability_name)
        return 0
    end
    
    -- Calculate how many charges are on cooldown
    -- The recast time shows time until ALL charges are back
    local charges_on_cooldown = math.ceil(recast_time / charge_time)
    
    -- Available charges = max - those on cooldown
    local available = math.max(0, max_charges - charges_on_cooldown)
    
    log.debug("Charges for %s: max=%d, recast=%d, charge_time=%d, on_cd=%d, available=%d",
              ability_name, max_charges, recast_time, charge_time, charges_on_cooldown, available)
    
    return available
end

--- Check if an ability has any charges available
-- @param ability_name string The name of the ability
-- @return boolean True if at least one charge is available
function ChargesUtils.has_charges(ability_name)
    return ChargesUtils.get_available_charges(ability_name) > 0
end

--- Get the maximum number of charges for an ability
-- @param ability_name string The name of the ability
-- @return number The maximum number of charges
function ChargesUtils.get_max_charges(ability_name)
    ability_name = ability_name:lower()
    
    local ability_data = CHARGED_ABILITIES[ability_name]
    if not ability_data then
        return 0
    end
    
    -- Check job requirement
    if ability_data.job_required then
        if player.main_job ~= ability_data.job_required and 
           player.sub_job ~= ability_data.job_required then
            return 0
        end
    end
    
    return ability_data.max_charges(player)
end

--- Get the recharge time per charge for an ability
-- @param ability_name string The name of the ability
-- @return number The recharge time in seconds
function ChargesUtils.get_charge_time(ability_name)
    ability_name = ability_name:lower()
    
    local ability_data = CHARGED_ABILITIES[ability_name]
    if not ability_data then
        return 0
    end
    
    return ability_data.charge_time(player)
end

--- Get detailed charge information for an ability
-- @param ability_name string The name of the ability
-- @return table Table containing charge details
function ChargesUtils.get_charge_info(ability_name)
    ability_name = ability_name:lower()
    
    local ability_data = CHARGED_ABILITIES[ability_name]
    if not ability_data then
        return {
            available = 0,
            max = 0,
            charge_time = 0,
            next_charge_in = 0,
            full_recharge_in = 0
        }
    end
    
    local max_charges = ChargesUtils.get_max_charges(ability_name)
    local available = ChargesUtils.get_available_charges(ability_name)
    local charge_time = ChargesUtils.get_charge_time(ability_name)
    
    -- Get current recast
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local recast_time = ability_recasts and ability_recasts[ability_data.ability_id] or 0
    
    -- Calculate time until next charge
    local next_charge_in = 0
    if available < max_charges and recast_time > 0 then
        next_charge_in = recast_time % charge_time
        if next_charge_in == 0 then
            next_charge_in = charge_time
        end
    end
    
    return {
        available = available,
        max = max_charges,
        charge_time = charge_time,
        next_charge_in = next_charge_in,
        full_recharge_in = recast_time
    }
end

-- ===========================================================================================================
--                                     Helper Functions for Common Abilities
-- ===========================================================================================================

--- Check if Scholar has stratagems available
-- @return boolean True if stratagems are available
function ChargesUtils.has_stratagems()
    return ChargesUtils.has_charges('stratagems')
end

--- Get available stratagem count
-- @return number Number of available stratagems
function ChargesUtils.get_stratagem_count()
    return ChargesUtils.get_available_charges('stratagems')
end

--- Check if BST has Ready charges available
-- @return boolean True if Ready charges are available
function ChargesUtils.has_ready_charges()
    return ChargesUtils.has_charges('ready')
end

--- Get available Ready charge count
-- @return number Number of available Ready charges
function ChargesUtils.get_ready_count()
    return ChargesUtils.get_available_charges('ready')
end

--- Check if BST has Sic charges available (same as Ready)
-- @return boolean True if Sic charges are available
function ChargesUtils.has_sic_charges()
    return ChargesUtils.has_charges('sic')
end

--- Get available Sic charge count (same as Ready)
-- @return number Number of available Sic charges
function ChargesUtils.get_sic_count()
    return ChargesUtils.get_available_charges('sic')
end

--- Check if COR has Quick Draw charges available
-- @return boolean True if Quick Draw charges are available
function ChargesUtils.has_quick_draw_charges()
    return ChargesUtils.has_charges('quick_draw')
end

return ChargesUtils