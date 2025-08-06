---============================================================================
--- FFXI GearSwap Utility Module - General Helper Functions
---============================================================================
--- Comprehensive collection of utility functions for GearSwap automation.
--- Provides common functionality shared across all job configurations,
--- including target management, party utilities, and general game helpers.
--- Core features include:
---
--- • **Target Management** - Current target detection and validation
--- • **Party Member Utilities** - Party/alliance member and pet detection
--- • **Treasure Hunter Integration** - TH action checking and validation
--- • **Game State Helpers** - Player status and condition checking
--- • **Safe API Wrappers** - Protected Windower API calls with error handling
--- • **Data Validation** - Input sanitization and type checking
--- • **Performance Utilities** - Cached lookups and optimized operations
--- • **Debug Helpers** - Development and troubleshooting utilities
---
--- This module contains the fundamental building blocks used throughout
--- the GearSwap system, providing reliable and consistent access to
--- common game information and operations.
---
--- @file utils/helpers.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger
--- @requires Windower FFXI
---
--- @usage
---   local UtilityUtils = require('utils/helpers')
---   local target_id, target_name = UtilityUtils.get_current_target_id_and_name()
---   local party_member = UtilityUtils.find_member_and_pet_in_party(player_name)
---
--- @see core/ modules for specialized utilities
---============================================================================

local UtilityUtils = {}

-- Load critical dependencies for utility operations
local config = require('config/config')              -- Centralized configuration system
local log = require('utils/logger')                  -- Professional logging framework

-- ===========================================================================================================
--                                     Target Management Functions
-- ===========================================================================================================

--- Retrieves the ID and name of the current target.
-- @return (number, string): The ID and name of the current target, or nil if no target is selected.
function UtilityUtils.get_current_target_id_and_name()
    local success, target = pcall(windower.ffxi.get_mob_by_target, 'lastst')
    if not success or not target then
        log.debug("No target found or error getting target")
        return nil, nil
    end
    
    return target.id, target.name
end

--- Gets detailed target information
-- @return (table): Table with target details or nil if no target
function UtilityUtils.get_target_info()
    local success, target = pcall(windower.ffxi.get_mob_by_target, 'lastst')
    if not success or not target then
        return nil
    end
    
    return {
        id = target.id,
        name = target.name,
        distance = target.distance,
        model_size = target.model_size,
        hpp = target.hpp,
        status = target.status,
        in_party = target.in_party,
        in_alliance = target.in_alliance
    }
end

--- Checks if current target is valid for actions
-- @return (boolean): True if target is valid, false otherwise
function UtilityUtils.has_valid_target()
    local target_info = UtilityUtils.get_target_info()
    return target_info ~= nil and target_info.id ~= nil
end

-- ===========================================================================================================
--                                     Party and Group Functions
-- ===========================================================================================================

--- Checks if a specific party member has a pet.
-- @param name (string): The name of the party member to check.
-- @return (boolean): True if the party member is found and they have a pet, false otherwise.
function UtilityUtils.find_member_and_pet_in_party(name)
    if type(name) ~= 'string' then
        log.error("Party member name must be a string")
        return false
    end
    
    if type(party) ~= 'table' then
        log.error("Party data not available")
        return false
    end
    
    for _, member in ipairs(party) do
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            if member.mob.name == name then
                local has_pet = member.mob.pet_index ~= nil
                log.debug("Party member %s %s pet", name, has_pet and "has" or "has no")
                return has_pet
            end
        end
    end
    
    log.debug("Party member %s not found", name)
    return false
end

--- Gets party member information by name
-- @param name (string): Name of the party member
-- @return (table): Party member data or nil if not found
function UtilityUtils.get_party_member(name)
    if type(name) ~= 'string' then
        log.error("Party member name must be a string")
        return nil
    end
    
    if type(party) ~= 'table' then
        log.debug("Party data not available")
        return nil
    end
    
    for _, member in ipairs(party) do
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            if member.mob.name == name then
                return {
                    name = member.mob.name,
                    id = member.mob.id,
                    hpp = member.mob.hpp,
                    mp = member.mob.mp,
                    mpp = member.mob.mpp,
                    tp = member.mob.tp,
                    main_job = member.mob.main_job,
                    main_job_level = member.mob.main_job_level,
                    sub_job = member.mob.sub_job,
                    sub_job_level = member.mob.sub_job_level,
                    has_pet = member.mob.pet_index ~= nil,
                    pet_index = member.mob.pet_index,
                    zone = member.mob.zone,
                    distance = member.mob.distance
                }
            end
        end
    end
    
    return nil
end

--- Gets all party members with their basic info
-- @return (table): Array of party member data
function UtilityUtils.get_all_party_members()
    local members = {}
    
    if type(party) ~= 'table' then
        log.debug("Party data not available")
        return members
    end
    
    for _, member in ipairs(party) do
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            table.insert(members, {
                name = member.mob.name,
                id = member.mob.id,
                hpp = member.mob.hpp,
                main_job = member.mob.main_job,
                main_job_level = member.mob.main_job_level,
                has_pet = member.mob.pet_index ~= nil,
                distance = member.mob.distance
            })
        end
    end
    
    return members
end

-- ===========================================================================================================
--                                     Table and Collection Utilities
-- ===========================================================================================================

--- Checks if a table contains a specific element.
-- @param tbl (table): The table to search in.
-- @param element (any): The element to search for in the table.
-- @return (boolean): True if the element is found in the table, false otherwise.
function UtilityUtils.table_contains(tbl, element)
    if type(tbl) ~= 'table' then
        log.error("First parameter must be a table")
        return false
    end
    
    if element == nil then
        log.error("Element cannot be nil")
        return false
    end
    
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    
    return false
end

--- Adds table.contains method to the global table namespace for backward compatibility
function UtilityUtils.extend_table_namespace()
    if not table.contains then
        table.contains = UtilityUtils.table_contains
    end
end

--- Finds the index of an element in an array
-- @param tbl (table): The array to search in
-- @param element (any): The element to find
-- @return (number): Index of the element, or nil if not found
function UtilityUtils.table_find(tbl, element)
    if type(tbl) ~= 'table' then
        log.error("First parameter must be a table")
        return nil
    end
    
    for i, value in ipairs(tbl) do
        if value == element then
            return i
        end
    end
    
    return nil
end

--- Merges two tables (shallow copy)
-- @param target (table): Target table to merge into
-- @param source (table): Source table to merge from
-- @return (table): The merged target table
function UtilityUtils.table_merge(target, source)
    if type(target) ~= 'table' or type(source) ~= 'table' then
        log.error("Both parameters must be tables")
        return target or {}
    end
    
    for key, value in pairs(source) do
        target[key] = value
    end
    
    return target
end

--- Creates a shallow copy of a table
-- @param tbl (table): Table to copy
-- @return (table): Shallow copy of the table
function UtilityUtils.table_copy(tbl)
    if type(tbl) ~= 'table' then
        log.error("Parameter must be a table")
        return {}
    end
    
    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = value
    end
    
    return copy
end

--- Gets the number of elements in a table (including non-array elements)
-- @param tbl (table): Table to count
-- @return (number): Number of elements in the table
function UtilityUtils.table_size(tbl)
    if type(tbl) ~= 'table' then
        log.error("Parameter must be a table")
        return 0
    end
    
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    
    return count
end

-- ===========================================================================================================
--                                     Treasure Hunter Functions
-- ===========================================================================================================

--- Determines if a given action inherently triggers the Treasure Hunter effect.
-- @param category (number): The category of the action.
-- @param param (number): The specific action within the category.
-- @return (boolean): True if the action inherently triggers Treasure Hunter, false otherwise.
function UtilityUtils.th_action_check(category, param)
    if type(category) ~= 'number' then
        log.error("TH action check: category must be a number")
        return false
    end
    
    if type(param) ~= 'number' then
        log.error("TH action check: param must be a number")
        return false
    end
    
    local th_actions = {
        [2] = function() return true end,                                                                  -- Any ranged attack
        [4] = function() return true end,                                                                  -- Any magic action
        [3] = function(p) return p == 30 end,                                                              -- Aeolian Edge
        [6] = function(p) return info and info.default_ja_ids and info.default_ja_ids:contains(p) end,     -- Provoke, Animated Flourish
        [14] = function(p) return info and info.default_u_ja_ids and info.default_u_ja_ids:contains(p) end -- Quick/Box/Stutter Step, etc.
    }
    
    if th_actions[category] then
        local success, result = pcall(th_actions[category], param)
        if success then
            return result
        else
            log.warn("Error checking TH action for category %d, param %d: %s", category, param, result)
        end
    end
    
    return false
end

--- Gets Treasure Hunter level from equipment
-- @return (number): Current TH level from gear
function UtilityUtils.get_current_th_level()
    -- This would need integration with equipment checking
    -- For now, return 0 as placeholder
    return 0
end

-- ===========================================================================================================
--                                     Utility and Helper Functions
-- ===========================================================================================================

--- Safely converts a value to a number
-- @param value (any): Value to convert
-- @param default (number, optional): Default value if conversion fails
-- @return (number): Converted number or default
function UtilityUtils.to_number(value, default)
    default = default or 0
    
    if type(value) == 'number' then
        return value
    elseif type(value) == 'string' then
        local num = tonumber(value)
        return num or default
    else
        return default
    end
end

--- Safely converts a value to a string
-- @param value (any): Value to convert
-- @param default (string, optional): Default value if conversion fails
-- @return (string): Converted string or default
function UtilityUtils.to_string(value, default)
    default = default or ""
    
    if value == nil then
        return default
    else
        return tostring(value)
    end
end

--- Checks if a value is empty (nil, empty string, empty table)
-- @param value (any): Value to check
-- @return (boolean): True if value is considered empty
function UtilityUtils.is_empty(value)
    if value == nil then
        return true
    elseif type(value) == 'string' then
        return value == ""
    elseif type(value) == 'table' then
        return next(value) == nil
    else
        return false
    end
end

--- Clamps a number between min and max values
-- @param value (number): Value to clamp
-- @param min (number): Minimum value
-- @param max (number): Maximum value
-- @return (number): Clamped value
function UtilityUtils.clamp(value, min, max)
    if type(value) ~= 'number' or type(min) ~= 'number' or type(max) ~= 'number' then
        log.error("All parameters must be numbers for clamp")
        return value or 0
    end
    
    return math.max(min, math.min(max, value))
end

--- Rounds a number to specified decimal places
-- @param value (number): Number to round
-- @param decimals (number, optional): Number of decimal places (default: 0)
-- @return (number): Rounded number
function UtilityUtils.round(value, decimals)
    if type(value) ~= 'number' then
        log.error("Value must be a number for rounding")
        return 0
    end
    
    decimals = decimals or 0
    local multiplier = 10 ^ decimals
    return math.floor(value * multiplier + 0.5) / multiplier
end

--- Generates a simple hash from a string (for basic identification)
-- @param str (string): String to hash
-- @return (number): Simple hash value
function UtilityUtils.simple_hash(str)
    if type(str) ~= 'string' then
        return 0
    end
    
    local hash = 0
    for i = 1, #str do
        hash = hash + string.byte(str, i)
    end
    
    return hash
end

-- Initialize backward compatibility
UtilityUtils.extend_table_namespace()

return UtilityUtils