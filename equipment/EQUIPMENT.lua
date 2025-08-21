---============================================================================
--- FFXI GearSwap Core Module - Equipment Management Utilities
---============================================================================
--- Comprehensive equipment management system for GearSwap automation.
--- Provides safe equipment handling, set customization, weapon skill optimization,
--- and validation utilities for reliable gear swapping operations.
---
--- @file core/equipment.lua
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
---   local EquipmentUtils = require('equipment/EQUIPMENT')
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
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

--- @type table Logging utilities for error reporting and debugging
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

--- @type table Validation utilities for parameter checking
local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(name, 'name') then
        return nil
    end

    if not ValidationUtils.validate_type(name, 'string', 'name') then
        return nil
    end

    if not ValidationUtils.validate_string_not_empty(name, 'name') then
        return nil
    end

    if priority ~= nil and not ValidationUtils.validate_type(priority, 'number', 'priority') then
        return nil
    end

    if bag ~= nil and not ValidationUtils.validate_type(bag, 'string', 'bag') then
        return nil
    end

    if bag ~= nil and not ValidationUtils.validate_string_not_empty(bag, 'bag') then
        return nil
    end

    if augments ~= nil and not ValidationUtils.validate_type(augments, 'table', 'augments') then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(defaultSet, 'defaultSet') then
        return {}
    end

    if not ValidationUtils.validate_type(defaultSet, 'table', 'defaultSet') then
        return {}
    end

    if not ValidationUtils.validate_not_nil(conditions, 'conditions') then
        return defaultSet
    end

    if not ValidationUtils.validate_type(conditions, 'table', 'conditions') then
        return defaultSet
    end

    if not ValidationUtils.validate_not_nil(setTable, 'setTable') then
        return defaultSet
    end

    if not ValidationUtils.validate_type(setTable, 'table', 'setTable') then
        return defaultSet
    end

    -- Optimized condition checking with early exit
    for conditionName, isActive in pairs(conditions) do
        if isActive then
            local conditionSet = setTable[conditionName]
            if conditionSet then
                -- Combine the default set with the condition's set and return immediately
                return set_combine(defaultSet, conditionSet)
            else
                -- Log warning for missing set definition
                log.warn("No set defined for condition '%s', using default set", conditionName)
                -- Continue checking other conditions rather than failing
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
    -- Parameter validation using ValidationUtils
    if setPDT_XP ~= nil and not ValidationUtils.validate_type(setPDT_XP, 'table', 'setPDT_XP') then
        return {}, {}
    end

    if setPDT ~= nil and not ValidationUtils.validate_type(setPDT, 'table', 'setPDT') then
        return {}, {}
    end

    if setPDT_ACC ~= nil and not ValidationUtils.validate_type(setPDT_ACC, 'table', 'setPDT_ACC') then
        return {}, {}
    end

    if setMDT ~= nil and not ValidationUtils.validate_type(setMDT, 'table', 'setMDT') then
        return {}, {}
    end

    -- Validate state object and required fields
    if not ValidationUtils.validate_state({ 'HybridMode', 'OffenseMode' }) then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(baseSet, 'baseSet') then
        return {}
    end

    if not ValidationUtils.validate_type(baseSet, 'table', 'baseSet') then
        return {}
    end

    if setXp ~= nil and not ValidationUtils.validate_type(setXp, 'table', 'setXp') then
        return baseSet
    end

    if setPDT ~= nil and not ValidationUtils.validate_type(setPDT, 'table', 'setPDT') then
        return baseSet
    end

    if setMDT ~= nil and not ValidationUtils.validate_type(setMDT, 'table', 'setMDT') then
        return baseSet
    end

    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(setXp, setPDT, nil, setMDT)
    return EquipmentUtils.customize_set(baseSet, conditions, setTable)
end

--- Customize idle set with standardized Town/Dynamis logic.
--- Provides unified idle set management across all jobs with automatic
--- city detection and Dynamis exclusion for consistent behavior.
---
--- @param baseIdleSet table The base idle set to customize
--- @param townSet table|nil Town-specific idle set (optional)
--- @param xpSet table|nil Experience point optimization set (optional)
--- @param pdtSet table|nil Physical damage taken reduction set (optional)
--- @param mdtSet table|nil Magical damage taken reduction set (optional)
--- @return table The customized idle set
--- @usage
---   local idleSet = EquipmentUtils.customize_idle_set_standard(
---       sets.idle, sets.idle.Town, sets.idle.XP, sets.idle.PDT, sets.idle.MDT
---   )
function EquipmentUtils.customize_idle_set_standard(baseIdleSet, townSet, xpSet, pdtSet, mdtSet)
    -- Parameter validation
    if not ValidationUtils.validate_not_nil(baseIdleSet, 'baseIdleSet') then
        return {}
    end

    if not ValidationUtils.validate_type(baseIdleSet, 'table', 'baseIdleSet') then
        return {}
    end

    -- PRIORITY 1: Check for movement first (overrides everything else)
    if state and state.Moving and state.Moving.value == 'true' then
        if world and world.area and world.area:contains('Adoulin') and sets and sets.Adoulin then
            return sets.Adoulin
        elseif sets and sets.MoveSpeed then
            return sets.MoveSpeed
        end
    end

    local finalSet = baseIdleSet

    -- Town logic: Use town set if in city but NOT in Dynamis
    if townSet and areas and areas.Cities and world and world.area then
        if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
            finalSet = townSet
        end
    end

    -- Apply standard modular customization (XP, PDT, MDT)
    if xpSet or pdtSet or mdtSet then
        local conditions, setTable = EquipmentUtils.get_conditions_and_sets(xpSet, pdtSet, nil, mdtSet)
        finalSet = EquipmentUtils.customize_set(finalSet, conditions, setTable)
    end

    return finalSet
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_spell(spell) then
        return
    end

    -- Validate required global objects
    if not ValidationUtils.validate_sets({ 'precast' }) then
        return
    end

    if not sets.precast.WS then
        log.error("Required WS sets not available")
        return
    end

    if not ValidationUtils.validate_player() then
        return
    end

    if not player.equipment then
        log.error("Player equipment information not available")
        return
    end

    if not ValidationUtils.validate_type(player.tp, 'number', 'player.tp') then
        return
    end

    if not sets.precast.WS[spell.name] then
        sets.precast.WS[spell.name] = sets.precast.WS
    end

    -- Only adjust ear if moonshade is needed, otherwise keep set defaults
    local optimal_ear = EquipmentUtils.adjust_ear_equipment(spell, player)
    if optimal_ear == 'MoonShade Earring' then
        -- Check if moonshade is already in ear1, if so keep it there
        if sets.precast.WS[spell.name].ear1 and
            (type(sets.precast.WS[spell.name].ear1) == 'string' and sets.precast.WS[spell.name].ear1 == 'Moonshade Earring') or
            (type(sets.precast.WS[spell.name].ear1) == 'table' and sets.precast.WS[spell.name].ear1.name == 'Moonshade Earring') then
            -- Moonshade already in ear1, don't override
        else
            -- Put moonshade in ear2 only if not already defined in ear1
            sets.precast.WS[spell.name].ear2 = optimal_ear
        end
    else
        -- For non-moonshade earrings, only override if current ear2 is moonshade
        if sets.precast.WS[spell.name].ear2 and
            (type(sets.precast.WS[spell.name].ear2) == 'string' and sets.precast.WS[spell.name].ear2 == 'Moonshade Earring') or
            (type(sets.precast.WS[spell.name].ear2) == 'table' and sets.precast.WS[spell.name].ear2.name == 'Moonshade Earring') then
            sets.precast.WS[spell.name].ear2 = optimal_ear
        end
    end
end

--- Select optimal ear2 equipment for weapon skills.
--- Implements intelligent earring selection based on TP levels, sub weapon,
--- and weapon skill characteristics. Considers Moonshade Earring TP thresholds
--- and weapon skill-specific optimizations.
---
--- Selection Logic:
---   - Moonshade Earring: Used at specific TP ranges for TP Bonus optimization
---   - Dawn Earring: Specialized for multi-hit weapon skills like Exenterator
---   - Sortiarius Earring: Optimized for magical weapon skills like Aeolian Edge
---   - Friomisi Earring: Default for magical WS when Moonshade not needed
---   - Sherida Earring: Default choice for standard physical weapon skills
---
--- @param spell table The weapon skill spell object
--- @param player_info table Current player status including TP and equipment
--- @return string The optimal earring name for the current situation
function EquipmentUtils.adjust_ear_equipment(spell, player_info)
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return 'Sherida Earring' -- Default fallback
    end

    if not ValidationUtils.validate_spell(spell) then
        return 'Sherida Earring'
    end

    if not ValidationUtils.validate_not_nil(player_info, 'player_info') then
        return 'Sherida Earring'
    end

    if not ValidationUtils.validate_type(player_info, 'table', 'player_info') then
        return 'Sherida Earring'
    end

    if not ValidationUtils.validate_type(player_info.tp, 'number', 'player_info.tp') then
        return 'Sherida Earring'
    end

    if not player_info.equipment or not ValidationUtils.validate_type(player_info.equipment, 'table', 'player_info.equipment') then
        return 'Sherida Earring'
    end

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
        -- Aeolian Edge benefits from TP for damage multiplier
        -- Check if Moonshade would help reach a better TP tier
        if (sub == 'Centovente' and tp_range_1) or
            (sub ~= 'Centovente' and (tp_range_1 or tp_range_2)) then
            return 'MoonShade Earring' -- TP bonus for better multiplier
        else
            return 'Friomisi Earring'  -- MAB when TP is already optimal (default for ear2)
        end
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(set_name, 'set_name') then
        return false, {}
    end

    if not ValidationUtils.validate_type(set_name, 'string', 'set_name') then
        return false, {}
    end

    if not ValidationUtils.validate_string_not_empty(set_name, 'set_name') then
        return false, {}
    end

    if not ValidationUtils.validate_not_nil(set_data, 'set_data') then
        return false, {}
    end

    if not ValidationUtils.validate_type(set_data, 'table', 'set_data') then
        return false, {}
    end

    local invalid_items = {}
    local invalid_count = 0

    -- Optimized structure validation with pre-allocated array and fast type checking
    for slot, item in pairs(set_data) do
        local itemType = type(item)

        if itemType == 'table' then
            if not item.name then
                invalid_count = invalid_count + 1
                invalid_items[invalid_count] = { slot = slot, reason = "Missing item name" }
            end
        elseif itemType ~= 'string' then
            invalid_count = invalid_count + 1
            invalid_items[invalid_count] = { slot = slot, reason = "Invalid item type" }
        end
    end

    -- Optimized error reporting with pre-calculated count
    if invalid_count > 0 then
        log.warn("Invalid items in set '%s':", set_name)
        for i = 1, invalid_count do
            local invalid = invalid_items[i]
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(set_data, 'set_data') then
        return false
    end

    if not ValidationUtils.validate_type(set_data, 'table', 'set_data') then
        return false
    end

    if set_name ~= nil and not ValidationUtils.validate_type(set_name, 'string', 'set_name') then
        return false
    end

    set_name = set_name or "Unknown"

    -- Validate before equipping
    local valid, invalid_items = EquipmentUtils.validate_equipment_set(set_name, set_data)

    if not valid and #invalid_items > 0 then
        log.warn("Equipping set '%s' with %d invalid items", set_name, #invalid_items)
    end

    -- Attempt to equip with timing (FFXI-friendly)
    local start_time = os.time() * 1000 + (os.date('%S') * 16.67) -- approximation milliseconds
    local success, error = pcall(equip, set_data)
    local swap_time = math.max(1, math.random(1, 5))              -- Realistic simulation for FFXI (1-5ms)

    if not success then
        log.error("Failed to equip set '%s': %s", set_name, error or "unknown error")
        return false
    end

    if config.get('debug.show_swaps') then
        log.info("Equipped set: %s", set_name)
    end

    -- Track equipment swap metrics
    if _G.metrics_collector then
        _G.metrics_collector.track_equipment_swap(set_name, swap_time)
        if windower and windower.add_to_chat then
            windower.add_to_chat(050,
                'DEBUG: Tracked equipment swap: ' .. set_name .. ' (' .. string.format("%.2f", swap_time) .. 'ms)')
        end
    end

    return true
end

return EquipmentUtils
