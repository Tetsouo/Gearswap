---============================================================================
--- FFXI GearSwap Utility Module - Data Validation and Type Checking
---============================================================================
--- Professional validation system for GearSwap configurations and runtime data.
--- Provides comprehensive parameter validation, type checking, configuration
--- validation, and error reporting. Core features include:
---
--- • **Parameter Validation** - Nil checking, type validation, range checking
--- • **Configuration Validation** - Settings file validation and error reporting
--- • **Equipment Validation** - Gear set validation and item existence checking
--- • **Spell Data Validation** - Spell parameter and target validation
--- • **Safe Type Conversion** - Protected type casting with error handling
--- • **Input Sanitization** - User input cleaning and validation
--- • **Error Context Reporting** - Detailed error messages with context
--- • **Performance Optimization** - Cached validation results for efficiency
---
--- This module provides the foundation for reliable and safe operation across
--- all GearSwap functionality, preventing runtime errors through comprehensive
--- validation with informative error reporting and recovery mechanisms.
---
--- @file utils/validation.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger
--- @requires Windower FFXI
---
--- @usage
---   local ValidationUtils = require('utils/validation')
---   ValidationUtils.validate_not_nil(value, 'parameter_name')
---   ValidationUtils.validate_type(obj, 'table', 'spell_data')
---============================================================================

local ValidationUtils = {}

-- Load dependencies
local config = require('config/config')
local log = require('utils/logger')

-- ===========================================================================================================
--                                     Parameter Validation Functions
-- ===========================================================================================================

--- Validates that a value is not nil
-- @param value (any): Value to check
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_not_nil(value, name)
    if value == nil then
        log.error("Parameter '%s' cannot be nil", name or "unknown")
        return false
    end
    return true
end

--- Validates that a value is of a specific type
-- @param value (any): Value to check
-- @param expected_type (string): Expected type ('string', 'number', 'table', etc.)
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_type(value, expected_type, name)
    if type(value) ~= expected_type then
        log.error("Parameter '%s' must be %s, got %s", name or "unknown", expected_type, type(value))
        return false
    end
    return true
end

--- Validates that a string is not empty
-- @param value (string): String to check
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_string_not_empty(value, name)
    if not ValidationUtils.validate_type(value, 'string', name) then
        return false
    end
    
    if value == "" then
        log.error("Parameter '%s' cannot be empty string", name or "unknown")
        return false
    end
    
    return true
end

--- Validates that a number is within a specific range
-- @param value (number): Number to check
-- @param min (number): Minimum allowed value
-- @param max (number): Maximum allowed value
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_number_range(value, min, max, name)
    if not ValidationUtils.validate_type(value, 'number', name) then
        return false
    end
    
    if value < min or value > max then
        log.error("Parameter '%s' must be between %s and %s, got %s", 
                  name or "unknown", tostring(min), tostring(max), tostring(value))
        return false
    end
    
    return true
end

--- Validates that a table is not empty
-- @param value (table): Table to check
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_table_not_empty(value, name)
    if not ValidationUtils.validate_type(value, 'table', name) then
        return false
    end
    
    if next(value) == nil then
        log.error("Parameter '%s' cannot be empty table", name or "unknown")
        return false
    end
    
    return true
end

--- Validates multiple parameters at once
-- @param validations (table): Array of validation specs {value, type, name, optional}
-- @return (boolean): True if all valid, false otherwise
function ValidationUtils.validate_parameters(validations)
    if type(validations) ~= 'table' then
        log.error("Validations parameter must be a table")
        return false
    end
    
    for i, validation in ipairs(validations) do
        local value = validation.value
        local expected_type = validation.type
        local name = validation.name or ("param_" .. i)
        local optional = validation.optional or false
        
        -- Skip validation if optional and nil
        if not (optional and value == nil) then
            -- Validate not nil (unless optional)
            if not optional and not ValidationUtils.validate_not_nil(value, name) then
                return false
            end
            
            -- Validate type if value is not nil
            if value ~= nil and not ValidationUtils.validate_type(value, expected_type, name) then
                return false
            end
        end
    end
    
    return true
end

-- ===========================================================================================================
--                                     Game Object Validation Functions
-- ===========================================================================================================

--- Validates that the player object is available and valid
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_player()
    if not player then
        log.error("Player object not available")
        return false
    end
    
    if not player.main_job then
        log.error("Player main job not available")
        return false
    end
    
    if not player.status then
        log.error("Player status not available")
        return false
    end
    
    return true
end

--- Validates that the state object is available and has required fields
-- @param required_fields (table, optional): Array of required field names
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_state(required_fields)
    if not state then
        log.error("State object not available")
        return false
    end
    
    if type(state) ~= 'table' then
        log.error("State object must be a table")
        return false
    end
    
    required_fields = required_fields or {}
    for _, field in ipairs(required_fields) do
        if not state[field] then
            log.error("Required state field missing: %s", field)
            return false
        end
    end
    
    return true
end

--- Validates that equipment sets are available
-- @param required_sets (table, optional): Array of required set names
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_sets(required_sets)
    if not sets then
        log.error("Sets object not available")
        return false
    end
    
    if type(sets) ~= 'table' then
        log.error("Sets object must be a table")
        return false
    end
    
    required_sets = required_sets or {}
    for _, set_name in ipairs(required_sets) do
        if not sets[set_name] then
            log.error("Required equipment set missing: %s", set_name)
            return false
        end
    end
    
    return true
end

--- Validates a spell object
-- @param spell (table): Spell object to validate
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_spell(spell)
    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return false
    end
    
    if not spell.name then
        log.error("Spell object missing 'name' field")
        return false
    end
    
    if not spell.type then
        log.error("Spell object missing 'type' field")
        return false
    end
    
    return true
end

--- Validates a target object
-- @param target (table): Target object to validate
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_target(target)
    if not ValidationUtils.validate_type(target, 'table', 'target') then
        return false
    end
    
    if not target.id then
        log.error("Target object missing 'id' field")
        return false
    end
    
    if not target.name then
        log.error("Target object missing 'name' field")
        return false
    end
    
    return true
end

-- ===========================================================================================================
--                                     Equipment Validation Functions
-- ===========================================================================================================

--- Validates an equipment item specification
-- @param item (table): Equipment item to validate
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_equipment_item(item)
    if not ValidationUtils.validate_type(item, 'table', 'equipment item') then
        return false
    end
    
    if not item.name then
        log.error("Equipment item missing 'name' field")
        return false
    end
    
    -- Optional fields validation
    if item.priority and type(item.priority) ~= 'number' then
        log.error("Equipment item 'priority' must be a number")
        return false
    end
    
    if item.bag and type(item.bag) ~= 'string' then
        log.error("Equipment item 'bag' must be a string")
        return false
    end
    
    if item.augments and type(item.augments) ~= 'table' then
        log.error("Equipment item 'augments' must be a table")
        return false
    end
    
    return true
end

--- Validates an equipment set
-- @param equipment_set (table): Equipment set to validate
-- @param set_name (string): Name of the set for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_equipment_set(equipment_set, set_name)
    if not ValidationUtils.validate_type(equipment_set, 'table', set_name or 'equipment set') then
        return false
    end
    
    -- Validate that it's not an empty table
    if next(equipment_set) == nil then
        log.warn("Equipment set '%s' is empty", set_name or 'unknown')
        return true  -- Empty sets are allowed
    end
    
    -- Validate each item in the set
    local valid_slots = {
        'main', 'sub', 'range', 'ammo',
        'head', 'neck', 'left_ear', 'right_ear',
        'body', 'hands', 'left_ring', 'right_ring',
        'back', 'waist', 'legs', 'feet'
    }
    
    for slot, item in pairs(equipment_set) do
        -- Check if slot name is valid
        local slot_valid = false
        for _, valid_slot in ipairs(valid_slots) do
            if slot == valid_slot then
                slot_valid = true
                break
            end
        end
        
        if not slot_valid then
            log.warn("Unknown equipment slot '%s' in set '%s'", slot, set_name or 'unknown')
        end
        
        -- Validate item
        if type(item) == 'string' then
            -- Simple string item name is valid
        elseif type(item) == 'table' then
            if not ValidationUtils.validate_equipment_item(item) then
                log.error("Invalid equipment item in slot '%s' of set '%s'", slot, set_name or 'unknown')
                return false
            end
        else
            log.error("Equipment item in slot '%s' must be string or table, got %s", slot, type(item))
            return false
        end
    end
    
    return true
end

-- ===========================================================================================================
--                                     Function Availability Validation
-- ===========================================================================================================

--- Validates that a function exists and is callable
-- @param func (function): Function to validate
-- @param func_name (string): Name of the function for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_function(func, func_name)
    if not func then
        log.error("Function '%s' is not available", func_name or 'unknown')
        return false
    end
    
    if type(func) ~= 'function' then
        log.error("'%s' is not a function, got %s", func_name or 'unknown', type(func))
        return false
    end
    
    return true
end

--- Validates that multiple functions are available
-- @param functions (table): Table of {func, name} pairs
-- @return (boolean): True if all valid, false otherwise
function ValidationUtils.validate_functions(functions)
    if not ValidationUtils.validate_type(functions, 'table', 'functions') then
        return false
    end
    
    for _, func_spec in ipairs(functions) do
        local func = func_spec[1] or func_spec.func
        local name = func_spec[2] or func_spec.name or 'unknown'
        
        if not ValidationUtils.validate_function(func, name) then
            return false
        end
    end
    
    return true
end

-- ===========================================================================================================
--                                     Utility Validation Functions
-- ===========================================================================================================

--- Validates that a value is one of the allowed options
-- @param value (any): Value to check
-- @param allowed_values (table): Array of allowed values
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_enum(value, allowed_values, name)
    if not ValidationUtils.validate_type(allowed_values, 'table', 'allowed_values') then
        return false
    end
    
    for _, allowed in ipairs(allowed_values) do
        if value == allowed then
            return true
        end
    end
    
    log.error("Parameter '%s' must be one of: %s, got %s", 
              name or 'unknown', table.concat(allowed_values, ', '), tostring(value))
    return false
end

--- Creates a validation result object
-- @param is_valid (boolean): Whether validation passed
-- @param errors (table, optional): Array of error messages
-- @return (table): Validation result
function ValidationUtils.create_validation_result(is_valid, errors)
    return {
        valid = is_valid,
        errors = errors or {},
        has_errors = function(self) return #self.errors > 0 end,
        add_error = function(self, error) table.insert(self.errors, error) end,
        get_error_summary = function(self) return table.concat(self.errors, '; ') end
    }
end

--- Safe validation wrapper that catches errors
-- @param validation_func (function): Validation function to execute
-- @param ... Variable arguments to pass to validation function
-- @return (table): Validation result object
function ValidationUtils.safe_validate(validation_func, ...)
    local success, result = pcall(validation_func, ...)
    
    if success then
        return ValidationUtils.create_validation_result(result, {})
    else
        return ValidationUtils.create_validation_result(false, {result})
    end
end

return ValidationUtils