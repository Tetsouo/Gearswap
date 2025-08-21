---============================================================================
--- FFXI GearSwap Equipment Factory - Standardized Equipment Creation
---============================================================================
--- Centralized equipment creation utility providing consistent equipment
--- object creation across all job configurations. Ensures standard
--- format, validation, and compatibility with all GearSwap operations.
---
--- @file utils/equipment_factory.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
--- @requires utils/validation
---
--- Features:
---   - Consistent equipment object structure across all jobs
---   - Parameter validation with detailed error reporting
---   - Support for augments, bags, and priority settings
---   - Backward compatibility with existing createEquipment calls
---   - Memory-efficient object creation
---
--- Usage:
---   local factory = require('utils/equipment_factory')
---   local weapon = factory.create('Excalibur', 10, 'inventory', {'DMG+50'})
---   local armor = factory.create('Valor Surcoat')
---============================================================================

local EquipmentFactory = {}

-- Load validation utilities
local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end

---============================================================================
--- EQUIPMENT CREATION FUNCTIONS
---============================================================================

--- Create a standardized equipment object with comprehensive validation.
--- This is the centralized function that all jobs should use for equipment creation.
--- Provides consistent structure and validation across the entire system.
---
--- @param name string The item name as it appears in-game (required)
--- @param priority number|nil Optional priority for set combination (higher = more important)
--- @param bag string|nil Optional bag location ('inventory', 'wardrobe', etc.)
--- @param augments table|nil Optional table of augment strings
--- @return table|nil Equipment object with validated parameters, or nil on error
---
--- @usage
---   local weapon = EquipmentFactory.create('Excalibur', 10, 'inventory', {'DMG+50', 'Acc+30'})
---   local armor = EquipmentFactory.create('Valor Surcoat')
---   local accessory = EquipmentFactory.create('Stikini Ring +1', nil, 'wardrobe')
function EquipmentFactory.create(name, priority, bag, augments)
    -- Validate required parameters
    if not ValidationUtils.validate_not_nil(name, 'equipment name') then
        return nil
    end

    if not ValidationUtils.validate_type(name, 'string', 'equipment name') then
        return nil
    end

    if not ValidationUtils.validate_string_not_empty(name, 'equipment name') then
        return nil
    end

    -- Validate optional parameters
    if priority ~= nil then
        -- Auto-convert string numbers to numbers
        if type(priority) == 'string' then
            local num_priority = tonumber(priority)
            if num_priority then
                priority = num_priority
            else
                priority = nil -- Invalid string, treat as no priority
            end
        end

        if priority ~= nil then
            if not ValidationUtils.validate_type(priority, 'number', 'equipment priority') then
                return nil
            end

            if priority ~= 0 and not ValidationUtils.validate_number_range(priority, 1, 100, 'equipment priority') then
                return nil
            end
        end
    end

    if bag ~= nil then
        if not ValidationUtils.validate_type(bag, 'string', 'equipment bag') then
            return nil
        end

        -- Validate bag names
        local valid_bags = {
            'inventory', 'safe', 'storage', 'temporary', 'locker',
            'satchel', 'sack', 'case', 'wardrobe', 'wardrobe 2',
            'wardrobe 3', 'wardrobe 4', 'wardrobe 5', 'wardrobe 6',
            'wardrobe 7', 'wardrobe 8'
        }

        local bag_valid = false
        for _, valid_bag in ipairs(valid_bags) do
            if bag:lower() == valid_bag then
                bag_valid = true
                break
            end
        end

        if not bag_valid then
            local success_log, log = pcall(require, 'utils/LOGGER')
            if not success_log then
                error("Failed to load utils/logger: " .. tostring(log))
            end
            log.warn("Unknown bag type: %s. Using anyway but may cause issues.", bag)
        end
    end

    if augments ~= nil then
        if not ValidationUtils.validate_type(augments, 'table', 'equipment augments') then
            return nil
        end

        -- Validate augments are strings
        for i, augment in ipairs(augments) do
            if not ValidationUtils.validate_type(augment, 'string', 'augment ' .. i) then
                return nil
            end
        end
    end

    -- Create equipment object
    local equipment = {
        name = name,
        priority = priority,
        bag = bag,
        augments = augments
    }

    return equipment
end

--- Batch create multiple equipment items from a table definition.
--- Useful for creating entire equipment sets at once with validation.
---
--- @param equipment_table table Table with slot names as keys and equipment data as values
--- @return table Table with validated equipment objects
---
--- @usage
---   local set_data = {
---       main = {'Excalibur', 10, 'inventory', {'DMG+50'}},
---       sub = {'Aegis', 5, 'wardrobe'},
---       head = {'Valor Coronet'}
---   }
---   local equipment_set = EquipmentFactory.create_batch(set_data)
function EquipmentFactory.create_batch(equipment_table)
    if not ValidationUtils.validate_type(equipment_table, 'table', 'equipment table') then
        return {}
    end

    local result = {}

    for slot, equipment_data in pairs(equipment_table) do
        if type(equipment_data) == 'table' then
            -- Extract parameters from array
            local name = equipment_data[1]
            local priority = equipment_data[2]
            local bag = equipment_data[3]
            local augments = equipment_data[4]

            result[slot] = EquipmentFactory.create(name, priority, bag, augments)
        elseif type(equipment_data) == 'string' then
            -- Simple string name
            result[slot] = EquipmentFactory.create(equipment_data)
        end
    end

    return result
end

--- Create equipment with automatic wardrobe assignment.
--- Assigns items to wardrobes automatically based on availability.
---
--- @param name string The item name
--- @param priority number|nil Optional priority
--- @param augments table|nil Optional augments
--- @param preferred_wardrobe string|nil Preferred wardrobe ('wardrobe', 'wardrobe 2', etc.)
--- @return table Equipment object with automatic bag assignment
function EquipmentFactory.create_auto_wardrobe(name, priority, augments, preferred_wardrobe)
    local bag = preferred_wardrobe or 'wardrobe'
    return EquipmentFactory.create(name, priority, bag, augments)
end

---============================================================================
--- BACKWARD COMPATIBILITY FUNCTIONS
---============================================================================

--- Backward compatibility wrapper for existing createEquipment calls.
--- This ensures all existing code continues to work without modification.
---
--- @param name string Equipment name
--- @param priority number|nil Priority
--- @param bag string|nil Bag location
--- @param augments table|nil Augments
--- @return table Equipment object
function EquipmentFactory.create_legacy(name, priority, bag, augments)
    return EquipmentFactory.create(name, priority, bag, augments)
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Validate an equipment object structure.
--- Useful for checking equipment objects received from external sources.
---
--- @param equipment table Equipment object to validate
--- @return boolean True if valid equipment object
--- @return table List of validation errors (empty if valid)
function EquipmentFactory.validate_equipment(equipment)
    local errors = {}

    if not equipment then
        table.insert(errors, "Equipment object is nil")
        return false, errors
    end

    if type(equipment) ~= 'table' then
        table.insert(errors, "Equipment must be a table")
        return false, errors
    end

    if not equipment.name then
        table.insert(errors, "Equipment must have a name")
    elseif type(equipment.name) ~= 'string' then
        table.insert(errors, "Equipment name must be a string")
    elseif equipment.name == '' then
        table.insert(errors, "Equipment name cannot be empty")
    end

    if equipment.priority and type(equipment.priority) ~= 'number' then
        table.insert(errors, "Equipment priority must be a number")
    end

    if equipment.bag and type(equipment.bag) ~= 'string' then
        table.insert(errors, "Equipment bag must be a string")
    end

    if equipment.augments and type(equipment.augments) ~= 'table' then
        table.insert(errors, "Equipment augments must be a table")
    end

    return #errors == 0, errors
end

--- Clone an equipment object with optional parameter overrides.
--- Useful for creating variations of existing equipment.
---
--- @param base_equipment table Base equipment to clone
--- @param overrides table|nil Table of parameters to override
--- @return table New equipment object
function EquipmentFactory.clone_equipment(base_equipment, overrides)
    if not base_equipment then
        return nil
    end

    local new_equipment = {
        name = base_equipment.name,
        priority = base_equipment.priority,
        bag = base_equipment.bag,
        augments = base_equipment.augments and table.copy(base_equipment.augments) or nil
    }

    if overrides then
        for key, value in pairs(overrides) do
            new_equipment[key] = value
        end
    end

    return new_equipment
end

---============================================================================
--- GLOBAL BACKWARD COMPATIBILITY
---============================================================================

--- Make createEquipment available globally for backward compatibility.
--- This ensures existing job files continue to work without modification.
_G.createEquipment = EquipmentFactory.create

return EquipmentFactory
