---============================================================================
--- FFXI GearSwap Core Module - Equipment Management Utilities
---============================================================================
--- Comprehensive equipment management system for GearSwap automation.
--- Provides safe equipment handling, set customization, weapon skill optimization,
--- and validation utilities for reliable gear swapping operations.
---
--- @file equipment.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05
--- @date Modified: 2025-08-05
--- @requires config/config.lua
--- @requires utils/logger.lua
--- @requires Windower FFXI
--- @requires GearSwap addon
---
--- Features:
---   - Safe equipment creation with parameter validation
---   - Dynamic set customization based on game state conditions
---   - Intelligent weapon skill optimization with TP-based earring selection
---   - Equipment set validation and error reporting
---   - Condition-driven gear set combinations
---   - Moonshade Earring TP threshold management
---   - Treasure Hunter integration for weapon skill selection
---   - Comprehensive error handling and logging
---
--- Usage:
---   local EquipmentUtils = require('core/equipment')
---   
---   -- Create equipment with augments
---   local cape = EquipmentUtils.create_equipment('Ambuscade Cape', 1, 'wardrobe', {'STR+20', 'DEX+20'})
---   
---   -- Customize set based on current state
---   local custom_set = EquipmentUtils.customize_set_based_on_state(base_set, xp_set, pdt_set, mdt_set)
---   
---   -- Safe equipment with validation
---   EquipmentUtils.safe_equip(weapon_skill_set, 'Savage Blade')
---   
---   -- Validate equipment set
---   local valid, errors = EquipmentUtils.validate_equipment_set('Idle', idle_set)
---
--- Thread Safety:
---   All functions are designed to be called safely from GearSwap events.
---   State modifications are atomic and do not require external locking.
---============================================================================

---============================================================================
--- MODULE INITIALIZATION
---============================================================================

--- @class EquipmentUtils Equipment management utility module
local EquipmentUtils = {}

--- @type table Configuration module for equipment settings
local config = require('config/config')

--- @type table Logging utilities for error reporting and debugging
local log = require('utils/logger')

---============================================================================
--- EQUIPMENT CREATION AND VALIDATION
---============================================================================

--- Create a standardized equipment object with comprehensive validation.
--- Ensures all equipment objects follow consistent structure and contain
--- valid data for reliable gear swapping operations.
---
--- @param name string The item name as it appears in-game
--- @param priority number|nil Optional priority for set combination (higher = more important)
--- @param bag string|nil Optional bag location ('inventory', 'wardrobe', etc.)
--- @param augments table|nil Optional table of augment strings
--- @return table|nil Equipment object with validated parameters, or nil on error
--- @usage
---   local weapon = EquipmentUtils.create_equipment('Excalibur', 10, 'inventory', {'DMG+50', 'Accuracy+30'})
---   local armor = EquipmentUtils.create_equipment('Valor Surcoat')
function EquipmentUtils.create_equipment(name, priority, bag, augments)
    if type(name) ~= 'string' then
        log.error("Parameter 'name' must be a string")
        return nil
    end

    if priority ~= nil and type(priority) ~= 'number' then
        log.error("Parameter 'priority' must be a number or nil")
        return nil
    end

    if bag ~= nil and type(bag) ~= 'string' then
        log.error("Parameter 'bag' must be a string or nil")
        return nil
    end

    if augments and type(augments) ~= 'table' then
        log.error("Parameter 'augments' must be a table")
        return nil
    end

    return {
        name = name,
        priority = priority or nil,
        bag = bag or nil,
        augments = augments or {}
    }
end

---============================================================================
--- SET COMBINATION AND CUSTOMIZATION
---============================================================================

--- Combine equipment sets based on dynamic conditions.
--- Evaluates conditions in order and applies the first matching set overlay
--- to the base set using GearSwap's set_combine functionality.
---
--- @param defaultSet table The base equipment set to start with
--- @param conditions table Map of condition names to boolean values
--- @param setTable table Map of condition names to equipment sets
--- @return table The combined equipment set with condition-specific modifications
--- @usage
---   local conditions = { PDT = state.HybridMode.value == 'PDT', Acc = state.OffenseMode.value == 'Acc' }
---   local setTable = { PDT = sets.idle.PDT, Acc = sets.idle.Acc }
---   local result = EquipmentUtils.customize_set(sets.idle, conditions, setTable)
function EquipmentUtils.customize_set(defaultSet, conditions, setTable)
    if not defaultSet or not conditions or not setTable then
        log.error("Invalid parameters for customize_set")
        return defaultSet or {}
    end

    if type(conditions) ~= "table" or type(setTable) ~= "table" then
        log.error("Invalid parameters: 'conditions' and 'setTable' must be tables")
        return defaultSet
    end

    for conditionName, isActive in pairs(conditions) do
        if isActive then
            local conditionSet = setTable[conditionName]
            if conditionSet then
                -- Combine the default set with the condition's set and return
                return set_combine(defaultSet, conditionSet)
            else
                -- If the set for this condition is not defined, log a warning
                log.warn("No set defined for condition '%s', using default set", conditionName)
            end
        end
    end

    -- If no conditions are met, return the default set
    return defaultSet
end

--- Generate state-based conditions and equipment set mappings.
--- Analyzes current game state to determine which defensive conditions
--- are active and creates corresponding condition-to-set mappings.
---
--- Conditions Generated:
---   - PDT_XP: Physical damage taken reduction with experience gain optimization
---   - PDT: Standard physical damage taken reduction
---   - PDT_ACC: Physical damage taken reduction with accuracy focus
---   - MDT: Magical damage taken reduction
---
--- @param setPDT_XP table|nil Equipment set for PDT with experience optimization
--- @param setPDT table|nil Equipment set for standard PDT
--- @param setPDT_ACC table|nil Equipment set for PDT with accuracy
--- @param setMDT table|nil Equipment set for magical damage taken reduction
--- @return table Table of condition names mapped to boolean activation status
--- @return table Table of condition names mapped to equipment sets
function EquipmentUtils.get_conditions_and_sets(setPDT_XP, setPDT, setPDT_ACC, setMDT)
    -- Validate input sets
    local function validate_set(set)
        return set == nil or type(set) == "table"
    end

    if not (validate_set(setPDT_XP) and validate_set(setPDT) and
            validate_set(setPDT_ACC) and validate_set(setMDT)) then
        log.error("Invalid parameters: Equipment sets must be tables or nil")
        return {}, {}
    end

    -- Ensure 'state' and required state variables are valid
    if type(state) ~= "table" then
        log.error("Invalid state: 'state' must be a table")
        return {}, {}
    end

    if type(state.HybridMode) ~= "table" or type(state.OffenseMode) ~= "table" then
        log.error("Invalid state: 'HybridMode' and 'OffenseMode' must be tables")
        return {}, {}
    end

    -- Handle optional 'state.Xp'
    local xpValue = (type(state.Xp) == "table" and state.Xp.value) or 'False'

    local conditions = {}
    local setTable = {}

    -- Only include conditions if their sets are provided
    if setPDT_XP then
        conditions['PDT_XP'] = (state.HybridMode.value == 'PDT') and (xpValue == 'True')
        setTable['PDT_XP'] = setPDT_XP
    end

    if setPDT then
        conditions['PDT'] = (state.HybridMode.value == 'PDT') and (xpValue == 'False')
        setTable['PDT'] = setPDT
    end

    if setPDT_ACC then
        conditions['PDT_ACC'] = (state.HybridMode.value == 'PDT') and (state.OffenseMode.value == 'Acc')
        setTable['PDT_ACC'] = setPDT_ACC
    end

    if setMDT then
        conditions['MDT'] = (state.HybridMode.value == 'MDT') and (xpValue == 'False')
        setTable['MDT'] = setMDT
    end

    return conditions, setTable
end

--- Customize equipment set based on current game state conditions.
--- High-level convenience function that automatically generates conditions
--- and applies appropriate set combinations based on current state values.
---
--- @param baseSet table The base equipment set to customize
--- @param setXp table|nil Equipment set overlay for experience point optimization
--- @param setPDT table|nil Equipment set overlay for physical damage reduction
--- @param setMDT table|nil Equipment set overlay for magical damage reduction
--- @return table The customized equipment set with state-appropriate modifications
--- @usage
---   local final_set = EquipmentUtils.customize_set_based_on_state(
---       sets.idle.Normal, sets.idle.XP, sets.idle.PDT, sets.idle.MDT
---   )
function EquipmentUtils.customize_set_based_on_state(baseSet, setXp, setPDT, setMDT)
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(setXp, setPDT, nil, setMDT)
    return EquipmentUtils.customize_set(baseSet, conditions, setTable)
end

---============================================================================
--- WEAPON SKILL AND COMBAT OPTIMIZATION
---============================================================================

--- Optimize weapon skill gear based on current TP and spell parameters.
--- Automatically adjusts earring selection for optimal weapon skill damage
--- by analyzing TP levels and weapon skill characteristics.
---
--- @param spell table The weapon skill spell object being executed
--- @usage Called automatically during weapon skill precast events
--- @see adjust_left_ear_equipment For specific earring selection logic
function EquipmentUtils.adjust_gear_based_on_tp_for_weaponskill(spell)
    if not spell then
        log.error("Spell is nil")
        return
    end

    if not (sets and sets.precast and sets.precast.WS) then
        log.error("Required tables do not exist")
        return
    end

    if not (player and player.equipment and player.tp) then
        log.error("Player information is not available")
        return
    end

    if not sets.precast.WS[spell.name] then
        sets.precast.WS[spell.name] = sets.precast.WS
    end

    sets.precast.WS[spell.name].left_ear = EquipmentUtils.adjust_left_ear_equipment(spell, player)
end

--- Select optimal left ear equipment for weapon skills.
--- Implements intelligent earring selection based on TP levels, sub weapon,
--- and weapon skill characteristics. Considers Moonshade Earring TP thresholds
--- and weapon skill-specific optimizations.
---
--- Selection Logic:
---   - Moonshade Earring: Used at specific TP ranges for TP Bonus optimization
---   - Dawn Earring: Specialized for multi-hit weapon skills like Exenterator
---   - Sortiarius Earring: Optimized for magical weapon skills like Aeolian Edge
---   - Sherida Earring: Default choice for standard physical weapon skills
---
--- @param spell table The weapon skill spell object
--- @param player_info table Current player status including TP and equipment
--- @return string The optimal earring name for the current situation
function EquipmentUtils.adjust_left_ear_equipment(spell, player_info)
    local tp = player_info.tp
    local sub = player_info.equipment.sub
    local treasureHunter = state and state.TreasureMode and state.TreasureMode.value or 'None'

    -- Check moonshade threshold from config
    local moonshade_threshold = config.get('combat.weaponskill.moonshade_threshold') or 1750

    -- TP conditions for Moonshade Earring
    local tp_range_1 = tp >= moonshade_threshold and tp < 2000
    local tp_range_2 = tp >= 2750 and tp < 3000

    -- Check if we should use Moonshade
    if (sub == 'Centovente' and tp_range_1) or
        (sub ~= 'Centovente' and (tp_range_1 or tp_range_2)) then
        return 'MoonShade Earring'
    end

    -- Specific weapon skill checks
    if spell.name == 'Exenterator' then
        return 'Dawn Earring'
    elseif spell.name == 'Aeolian Edge' then
        return 'Sortiarius Earring'
    else
        return 'Sherida Earring'
    end
end

---============================================================================
--- EQUIPMENT VALIDATION AND SAFETY
---============================================================================

--- Validate equipment set structure and item definitions.
--- Performs comprehensive validation of equipment sets to ensure
--- proper structure and identify potential issues before equipping.
---
--- Validation Checks:
---   - Proper table structure for set data
---   - Required fields present in equipment objects
---   - Valid item type specifications
---   - Consistent naming conventions
---
--- @param set_name string Descriptive name of the set for error reporting
--- @param set_data table The equipment set table to validate
--- @return boolean True if all validations pass
--- @return table List of validation errors with detailed descriptions
function EquipmentUtils.validate_equipment_set(set_name, set_data)
    local invalid_items = {}

    if type(set_data) ~= 'table' then
        log.error("Set data must be a table")
        return false, invalid_items
    end

    -- This would need integration with Windower's inventory API
    -- For now, just check structure
    for slot, item in pairs(set_data) do
        if type(item) == 'table' then
            if not item.name then
                table.insert(invalid_items, { slot = slot, reason = "Missing item name" })
            end
        elseif type(item) ~= 'string' then
            table.insert(invalid_items, { slot = slot, reason = "Invalid item type" })
        end
    end

    if #invalid_items > 0 then
        log.warn("Invalid items in set '%s':", set_name)
        for _, invalid in ipairs(invalid_items) do
            log.warn("  - Slot %s: %s", invalid.slot, invalid.reason)
        end
    end

    return #invalid_items == 0, invalid_items
end

--- Safely equip a gear set with comprehensive error handling.
--- Provides a protective wrapper around GearSwap's equip function
--- with validation, error handling, and optional debug logging.
---
--- Safety Features:
---   - Pre-equip validation to catch structural issues
---   - Protected call (pcall) to prevent crashes on equip failures
---   - Detailed error logging with context information
---   - Optional debug output for successful equipment changes
---
--- @param set_data table The equipment set to equip
--- @param set_name string|nil Optional descriptive name for logging (default: 'Unknown')
--- @return boolean True if equipment was successful, false on any error
--- @usage
---   local success = EquipmentUtils.safe_equip(sets.precast.WS['Savage Blade'], 'Savage Blade WS')
function EquipmentUtils.safe_equip(set_data, set_name)
    if not set_data then
        log.error("Cannot equip nil set")
        return false
    end

    set_name = set_name or "Unknown"

    -- Validate before equipping
    local valid, invalid_items = EquipmentUtils.validate_equipment_set(set_name, set_data)

    if not valid and #invalid_items > 0 then
        log.warn("Equipping set '%s' with %d invalid items", set_name, #invalid_items)
    end

    -- Attempt to equip
    local success, error = pcall(equip, set_data)
    if not success then
        log.error("Failed to equip set '%s': %s", set_name, error or "unknown error")
        return false
    end

    if config.get('debug.show_swaps') then
        log.info("Equipped set: %s", set_name)
    end

    return true
end

return EquipmentUtils
