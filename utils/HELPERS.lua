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
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

--- @type table Validation utilities for parameter checking
local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end

--- @type table Equipment validator for set validation
local success_EquipmentValidator, EquipmentValidator = pcall(require, 'utils/EQUIPMENT_VALIDATOR')
if not success_EquipmentValidator then
    error("Failed to load utils/equipment_validator: " .. tostring(EquipmentValidator))
end

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(name, 'name') then
        return false
    end

    if not ValidationUtils.validate_string_not_empty(name, 'name') then
        return false
    end

    if type(party) ~= 'table' then
        log.error("Party data not available")
        return false
    end

    -- Optimized party iteration with cached length and early exit
    local partySize = #party

    for i = 1, partySize do
        local member = party[i]
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            local mob = member.mob
            if mob.name == name then
                local has_pet = mob.pet_index ~= nil
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(name, 'name') then
        return nil
    end

    if not ValidationUtils.validate_string_not_empty(name, 'name') then
        return nil
    end

    if type(party) ~= 'table' then
        log.debug("Party data not available")
        return nil
    end

    -- Optimized party member lookup with cached length
    local partySize = #party

    for i = 1, partySize do
        local member = party[i]
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            local mob = member.mob
            if mob.name == name then
                -- Return member data with cached mob reference
                return {
                    name = mob.name,
                    id = mob.id,
                    hpp = mob.hpp,
                    mp = mob.mp,
                    mpp = mob.mpp,
                    tp = mob.tp,
                    main_job = mob.main_job,
                    main_job_level = mob.main_job_level,
                    sub_job = mob.sub_job,
                    sub_job_level = mob.sub_job_level,
                    has_pet = mob.pet_index ~= nil,
                    pet_index = mob.pet_index,
                    zone = mob.zone,
                    distance = mob.distance
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

    -- Optimized party member collection with pre-allocated array
    local partySize = #party
    local memberCount = 0

    for i = 1, partySize do
        local member = party[i]
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            local mob = member.mob
            memberCount = memberCount + 1
            members[memberCount] = {
                name = mob.name,
                id = mob.id,
                hpp = mob.hpp,
                main_job = mob.main_job,
                main_job_level = mob.main_job_level,
                has_pet = mob.pet_index ~= nil,
                distance = mob.distance
            }
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(tbl, 'tbl') then
        return false
    end

    if not ValidationUtils.validate_type(tbl, 'table', 'tbl') then
        return false
    end

    if not ValidationUtils.validate_not_nil(element, 'element') then
        return false
    end

    -- Optimized table search with early exit
    for _, value in pairs(tbl) do
        if value == element then
            return true -- Early exit on match
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(tbl, 'tbl') then
        return nil
    end

    if not ValidationUtils.validate_type(tbl, 'table', 'tbl') then
        return nil
    end

    if not ValidationUtils.validate_not_nil(element, 'element') then
        return nil
    end

    -- Optimized array search with cached length and early exit
    local tableLength = #tbl

    for i = 1, tableLength do
        if tbl[i] == element then
            return i -- Early exit on match
        end
    end

    return nil
end

--- Merges two tables (shallow copy)
-- @param target (table): Target table to merge into
-- @param source (table): Source table to merge from
-- @return (table): The merged target table
function UtilityUtils.table_merge(target, source)
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(target, 'target') then
        return {}
    end

    if not ValidationUtils.validate_type(target, 'table', 'target') then
        return {}
    end

    if not ValidationUtils.validate_not_nil(source, 'source') then
        return target
    end

    if not ValidationUtils.validate_type(source, 'table', 'source') then
        return target
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(tbl, 'tbl') then
        return {}
    end

    if not ValidationUtils.validate_type(tbl, 'table', 'tbl') then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(tbl, 'tbl') then
        return 0
    end

    if not ValidationUtils.validate_type(tbl, 'table', 'tbl') then
        return 0
    end

    -- Optimized table size counting
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(category, 'category') then
        return false
    end

    if not ValidationUtils.validate_type(category, 'number', 'category') then
        return false
    end

    if not ValidationUtils.validate_not_nil(param, 'param') then
        return false
    end

    if not ValidationUtils.validate_type(param, 'number', 'param') then
        return false
    end

    local th_actions = {
        [2] = function() return true end,                                                                        -- Any ranged attack
        [4] = function() return true end,                                                                        -- Any magic action
        [3] = function(p) return p and p == 30 end,                                                              -- Aeolian Edge
        [6] = function(p) return p and info and info.default_ja_ids and info.default_ja_ids:contains(p) end,     -- Provoke, Animated Flourish
        [14] = function(p) return p and info and info.default_u_ja_ids and info.default_u_ja_ids:contains(p) end -- Quick/Box/Stutter Step, etc.
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
    -- Basic validation - value can be any type, default should be number if provided
    if default ~= nil and not ValidationUtils.validate_type(default, 'number', 'default') then
        default = 0
    else
        default = default or 0
    end

    if value == nil then
        return default
    end

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
    -- Basic validation - default should be string if provided
    if default ~= nil and not ValidationUtils.validate_type(default, 'string', 'default') then
        default = ""
    else
        default = default or ""
    end

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(value, 'value') then
        return 0
    end

    if not ValidationUtils.validate_type(value, 'number', 'value') then
        return 0
    end

    if not ValidationUtils.validate_not_nil(min, 'min') then
        return value
    end

    if not ValidationUtils.validate_type(min, 'number', 'min') then
        return value
    end

    if not ValidationUtils.validate_not_nil(max, 'max') then
        return value
    end

    if not ValidationUtils.validate_type(max, 'number', 'max') then
        return value
    end

    return math.max(min, math.min(max, value))
end

--- Rounds a number to specified decimal places
-- @param value (number): Number to round
-- @param decimals (number, optional): Number of decimal places (default: 0)
-- @return (number): Rounded number
function UtilityUtils.round(value, decimals)
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(value, 'value') then
        return 0
    end

    if not ValidationUtils.validate_type(value, 'number', 'value') then
        return 0
    end

    if decimals ~= nil and not ValidationUtils.validate_type(decimals, 'number', 'decimals') then
        decimals = 0
    end

    decimals = decimals or 0
    local multiplier = 10 ^ decimals
    return math.floor(value * multiplier + 0.5) / multiplier
end

--- Generates a simple hash from a string (for basic identification)
-- @param str (string): String to hash
-- @return (number): Simple hash value
function UtilityUtils.simple_hash(str)
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(str, 'str') then
        return 0
    end

    if not ValidationUtils.validate_type(str, 'string', 'str') then
        return 0
    end

    -- Optimized hash calculation with cached string length
    local hash = 0
    local strLength = #str

    for i = 1, strLength do
        hash = hash + string.byte(str, i)
    end

    return hash
end

-- ===========================================================================================================
--                                     Equipment Validation Functions
-- ===========================================================================================================

--- Validates an equipment set using the GearSwap-compatible validator
-- @param equipment_set (table): Equipment set to validate
-- @param set_name (string, optional): Name of the set for error reporting
-- @return (table): Validation result with valid, missing_items, errors fields
function UtilityUtils.validate_equipment_set(equipment_set, set_name)
    -- Parameter validation
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        return {
            valid = false,
            missing_items = {},
            errors = { "Invalid equipment set: must be a table" },
            used_items = {}
        }
    end

    -- Use the dedicated equipment validator
    return EquipmentValidator.validate_equipment_set(equipment_set, set_name)
end

--- Quick check if an equipment set is valid (returns boolean only)
-- @param equipment_set (table): Equipment set to validate
-- @param set_name (string, optional): Name of the set
-- @return (boolean): True if set is completely valid, false otherwise
function UtilityUtils.is_equipment_set_valid(equipment_set, set_name)
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        return false
    end

    local result = EquipmentValidator.validate_equipment_set(equipment_set, set_name)
    return result and result.valid == true
end

--- Validates equipment and reports errors to chat
-- @param equipment_set (table): Equipment set to validate
-- @param set_name (string, optional): Name of the set
-- @param show_success (boolean, optional): Show success message if valid
-- @return (boolean): True if valid, false otherwise
function UtilityUtils.validate_and_report_equipment(equipment_set, set_name, show_success)
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        windower.add_to_chat(167, "[Equipment] Invalid equipment set provided")
        return false
    end

    EquipmentValidator.validate_and_report(equipment_set, set_name, show_success)
    return UtilityUtils.is_equipment_set_valid(equipment_set, set_name)
end

--- Gets missing items from an equipment set
-- @param equipment_set (table): Equipment set to check
-- @param set_name (string, optional): Name of the set
-- @return (table): Array of missing items with slot and name fields
function UtilityUtils.get_missing_equipment_items(equipment_set, set_name)
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        return {}
    end

    local result = EquipmentValidator.validate_equipment_set(equipment_set, set_name)
    return result and result.missing_items or {}
end

--- Validates all equipment sets in the sets table
-- @param sets_table (table, optional): Sets table to validate (defaults to global 'sets')
-- @param report_valid (boolean, optional): Whether to report valid sets too
-- @return (table): Summary with total_sets, valid_sets, invalid_sets counts
function UtilityUtils.validate_all_equipment_sets(sets_table, report_valid)
    sets_table = sets_table or sets

    if not sets_table or not ValidationUtils.validate_type(sets_table, 'table', 'sets_table') then
        windower.add_to_chat(167, "[Equipment] No sets table available for validation")
        return { total_sets = 0, valid_sets = 0, invalid_sets = 0 }
    end

    EquipmentValidator.validate_all_sets(sets_table, report_valid or false)

    -- Return summary (simplified - the full function shows detailed results)
    return { total_sets = -1, valid_sets = -1, invalid_sets = -1 } -- Detailed counting would require refactoring
end

--- Clears the equipment validation cache
function UtilityUtils.clear_equipment_validation_cache()
    EquipmentValidator.clear_cache()
end

--- Gets equipment validation cache statistics
-- @return (table): Cache statistics with entries, age, max_age fields
function UtilityUtils.get_equipment_validation_cache_stats()
    return EquipmentValidator.get_cache_stats()
end

-- Initialize backward compatibility
UtilityUtils.extend_table_namespace()

return UtilityUtils
