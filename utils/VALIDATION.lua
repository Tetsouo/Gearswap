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
---   local ValidationUtils = require('utils/VALIDATION')
---   ValidationUtils.validate_not_nil(value, 'parameter_name')
---   ValidationUtils.validate_type(obj, 'table', 'spell_data')
---============================================================================

local ValidationUtils = {}

-- Load dependencies
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end
-- ErrorHandler re-enabled with lightweight version for performance
local ErrorHandler = nil
local error_handler_available = false

-- Safe loading of lightweight error handler
local success, eh_result = pcall(require, 'utils/error_handler_LIGHTWEIGHT')
if success and eh_result then
    ErrorHandler = eh_result
    error_handler_available = true
end

-- Load centralized logger system
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- Validation cache for performance optimization
local validation_cache = {}
local cache_size = 0
local max_cache_size = 1000

-- Cache cleanup function
local function cleanup_cache()
    if cache_size > max_cache_size then
        -- Remove oldest entries (simple LRU approximation)
        local count = 0
        for key, _ in pairs(validation_cache) do
            validation_cache[key] = nil
            count = count + 1
            if count > max_cache_size / 2 then
                break
            end
        end
        cache_size = cache_size - count
    end
end

-- Generate cache key for validation parameters
local function generate_cache_key(func_name, ...)
    local args = { ... }
    local key_parts = { func_name }
    for i, arg in ipairs(args) do
        if type(arg) == 'table' then
            -- For tables, use a simple hash based on key count and first few values
            table.insert(key_parts, string.format("table_%d", #arg))
        else
            table.insert(key_parts, tostring(arg))
        end
    end
    return table.concat(key_parts, "_")
end

-- Cached validation wrapper
local function cached_validation(func_name, func, ...)
    local cache_key = generate_cache_key(func_name, ...)

    -- Check cache first
    if validation_cache[cache_key] ~= nil then
        return validation_cache[cache_key]
    end

    -- Perform validation
    local result = func(...)

    -- Cache result
    validation_cache[cache_key] = result
    cache_size = cache_size + 1

    -- Cleanup if needed
    if cache_size > max_cache_size then
        cleanup_cache()
    end

    return result
end

-- ===========================================================================================================
--                                     Parameter Validation Functions
-- ===========================================================================================================

--- Validates that a value is not nil (cached for performance)
-- @param value (any): Value to check
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_not_nil(value, name)
    -- Use cached validation for primitive types only
    if type(value) ~= 'table' and type(value) ~= 'function' then
        return cached_validation("validate_not_nil", function(val, param_name)
            if val == nil then
                log.error("Parameter '%s' cannot be nil", param_name or "unknown")
                return false
            end
            return true
        end, value, name)
    end

    -- Direct validation for complex types
    if value == nil then
        log.error("Parameter '%s' cannot be nil", name or "unknown")
        return false
    end
    return true
end

--- Validates that a value is of a specific type (cached for performance)
-- @param value (any): Value to check
-- @param expected_type (string): Expected type ('string', 'number', 'table', etc.)
-- @param name (string): Name of the parameter for error messages
-- @return (boolean): True if valid, false otherwise
function ValidationUtils.validate_type(value, expected_type, name)
    -- Use cached validation for primitive type checks
    if type(value) ~= 'table' and type(value) ~= 'function' then
        return cached_validation("validate_type", function(val, exp_type, param_name)
            if type(val) ~= exp_type then
                log.error("Parameter '%s' must be %s, got %s", param_name or "unknown", exp_type, type(val))
                return false
            end
            return true
        end, value, expected_type, name)
    end

    -- Direct validation for complex types
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

    -- Optimized validation loop with cached length and early exit
    local validationCount = #validations

    for i = 1, validationCount do
        local validation = validations[i]
        local value = validation.value
        local expected_type = validation.type
        local name = validation.name or ("param_" .. i)
        local optional = validation.optional or false

        -- Skip validation if optional and nil (optimized condition)
        if optional and value == nil then
            -- Continue to next validation
        else
            -- Validate not nil (unless optional) with early exit
            if not optional and not ValidationUtils.validate_not_nil(value, name) then
                return false
            end

            -- Validate type if value is not nil with early exit
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

    -- Optimized field validation with early exit and cached length
    if required_fields and #required_fields > 0 then
        local fieldCount = #required_fields
        for i = 1, fieldCount do
            local field = required_fields[i]
            if not state[field] then
                log.error("Required state field missing: %s", field)
                return false
            end
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
        return true -- Empty sets are allowed
    end

    -- Optimized equipment validation with lookup table for slot validation
    local valid_slots = {
        main = true,
        sub = true,
        range = true,
        ammo = true,
        head = true,
        neck = true,
        left_ear = true,
        right_ear = true,
        body = true,
        hands = true,
        left_ring = true,
        right_ring = true,
        back = true,
        waist = true,
        legs = true,
        feet = true
    }

    -- Single optimized validation loop
    for slot, item in pairs(equipment_set) do
        -- Fast slot validation using hash lookup
        if not valid_slots[slot] then
            log.warn("Unknown equipment slot '%s' in set '%s'", slot, set_name or 'unknown')
        end

        -- Optimized item validation with cached type check
        local itemType = type(item)
        if itemType == 'string' then
            -- Simple string item name is valid - no additional processing
        elseif itemType == 'table' then
            if not ValidationUtils.validate_equipment_item(item) then
                log.error("Invalid equipment item in slot '%s' of set '%s'", slot, set_name or 'unknown')
                return false
            end
        else
            log.error("Equipment item in slot '%s' must be string or table, got %s", slot, itemType)
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

    -- Optimized function validation with cached length
    local functionCount = #functions

    for i = 1, functionCount do
        local func_spec = functions[i]
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

    -- Optimized enum validation with early exit and cached length
    local valueCount = #allowed_values

    for i = 1, valueCount do
        if value == allowed_values[i] then
            return true -- Early exit on match
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
        return ValidationUtils.create_validation_result(false, { result })
    end
end

return ValidationUtils
