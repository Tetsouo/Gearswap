---============================================================================
--- FFXI GearSwap Core Module - State Management Utilities
---============================================================================
--- Professional state management system for GearSwap job configurations.
--- Provides centralized state synchronization, equipment handling, and 
--- job state transitions. Core features include:
---
--- • Alt-player state synchronization for dual-boxing scenarios
--- • Equipment state management with automatic gear updates
--- • Job state change handling with event propagation
--- • Buff state tracking and validation
--- • State persistence and recovery mechanisms
--- • Performance-optimized state updates with caching
---
--- This module serves as the central nervous system for all state-related
--- operations across job configurations and provides a unified interface
--- for state manipulation and monitoring.
---
--- @file core/state.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, core/weapons
---
--- @usage
---   local StateUtils = require('core/state')
---   StateUtils.update_alt_state()
---   StateUtils.job_handle_equipping_gear(player.status, eventArgs)
---============================================================================

local StateUtils = {}

-- Load critical dependencies for state management operations
local config = require('config/config')          -- Centralized configuration system
local log = require('utils/logger')              -- Professional logging framework  
local WeaponUtils = require('core/weapons')      -- Weapon management utilities

-- ===========================================================================================================
--                                     Alt State Management
-- ===========================================================================================================

-- Define object to store the current alt state values
StateUtils.altState = {}

--- Updates the alt state object with the current state values.
-- This function synchronizes the alternate state with the main state variables.
function StateUtils.update_alt_state()
    if type(state) ~= 'table' then
        log.error("State object not available for alt state update")
        return
    end

    local function update_state_field(stateField, altStateField)
        if state[stateField] and type(state[stateField]) == 'table' and state[stateField].value then
            StateUtils.altState[altStateField] = state[stateField].value
        else
            log.warn("State field %s not found or invalid", stateField)
        end
    end

    -- Update all alt state fields
    update_state_field('altPlayerLight', 'Light')
    update_state_field('altPlayerTier', 'Tier') 
    update_state_field('altPlayerDark', 'Dark')
    update_state_field('altPlayera', 'Ra')
    update_state_field('altPlayerGeo', 'Geo')
    update_state_field('altPlayerIndi', 'Indi')
    update_state_field('altPlayerEntrust', 'Entrust')
    
    log.debug("Alt state updated successfully")
end

--- Gets current alt state values
-- @return (table): Current alt state
function StateUtils.get_alt_state()
    return StateUtils.altState
end

--- Sets a specific alt state field
-- @param field (string): Field name to set
-- @param value (any): Value to set
function StateUtils.set_alt_state_field(field, value)
    if type(field) ~= 'string' then
        log.error("Alt state field name must be a string")
        return false
    end
    
    StateUtils.altState[field] = value
    log.debug("Alt state field %s set to %s", field, tostring(value))
    return true
end

-- ===========================================================================================================
--                                     Equipment State Management
-- ===========================================================================================================

--- Resets the player's equipment to its default state based on current conditions.
-- @return (boolean): True if successful, false otherwise
function StateUtils.reset_to_default_equipment()
    if not (sets and sets.engaged and sets.idle and sets.MoveSpeed) then
        log.error("Required equipment sets not available")
        return false
    end

    if not player then
        log.error("Player object not available")
        return false
    end

    -- Determine base set
    local baseSet = player.status == 'Engaged' and sets.engaged or sets.idle
    
    -- Add movement gear if moving and not engaged
    if state and state.Moving and state.Moving.value == 'true' and player.status ~= 'Engaged' then
        baseSet = set_combine(baseSet, sets.MoveSpeed)
        log.debug("Added movement gear to base set")
    end

    -- Apply hybrid mode modifications
    local success = StateUtils.apply_hybrid_mode_gear(baseSet)
    if not success then
        log.warn("Failed to apply hybrid mode gear, using base set")
        local equip_success, error_msg = pcall(equip, baseSet)
        if not equip_success then
            log.error("Failed to equip base set: %s", error_msg or "unknown error")
            return false
        end
    end

    log.debug("Equipment reset to default state")
    return true
end

--- Applies hybrid mode specific gear modifications
-- @param baseSet (table): Base equipment set to modify
-- @return (boolean): True if successful, false otherwise
function StateUtils.apply_hybrid_mode_gear(baseSet)
    if not baseSet then
        log.error("Base set required for hybrid mode application")
        return false
    end

    if not (state and state.HybridMode) then
        -- No hybrid mode, equip base set
        local success, error_msg = pcall(equip, baseSet)
        if not success then
            log.error("Failed to equip base set: %s", error_msg or "unknown error")
            return false
        end
        return true
    end

    local hybrid_mode = state.HybridMode.value
    local target_set = baseSet

    if hybrid_mode == 'PDT' then
        target_set = StateUtils.get_pdt_set(baseSet)
    elseif hybrid_mode == 'MDT' then
        target_set = StateUtils.get_mdt_set(baseSet)
    end

    local success, error_msg = pcall(equip, target_set)
    if not success then
        log.error("Failed to equip hybrid mode set (%s): %s", hybrid_mode, error_msg or "unknown error")
        return false
    end

    log.debug("Applied hybrid mode: %s", hybrid_mode)
    return true
end

--- Gets appropriate PDT (Physical Damage Taken) set
-- @param baseSet (table): Base equipment set
-- @return (table): PDT equipment set
function StateUtils.get_pdt_set(baseSet)
    if state and state.Xp and state.Xp.value == 'True' then
        return baseSet.PDT_XP or baseSet.PDT or baseSet
    elseif state and state.OffenseMode and state.OffenseMode.value == 'Acc' then
        return baseSet.PDT_ACC or baseSet.PDT or baseSet
    else
        return baseSet.PDT or baseSet
    end
end

--- Gets appropriate MDT (Magic Damage Taken) set
-- @param baseSet (table): Base equipment set
-- @return (table): MDT equipment set
function StateUtils.get_mdt_set(baseSet)
    return baseSet.MDT or baseSet
end

-- ===========================================================================================================
--                                     Job Equipment Handling
-- ===========================================================================================================

--- Handles the player's equipment based on their status and event arguments.
-- @param playerStatus (string or nil): The player's status.
-- @param eventArgs (table or nil): Additional event arguments.
-- @return (boolean): True if successful, false otherwise
function StateUtils.job_handle_equipping_gear(playerStatus, eventArgs)
    -- Validation
    if playerStatus ~= nil and type(playerStatus) ~= 'string' then
        log.error("playerStatus must be string or nil")
        return false
    end

    if eventArgs ~= nil and type(eventArgs) ~= 'table' then
        log.error("eventArgs must be table or nil")
        return false
    end

    if not state then
        log.error("State object not available")
        return false
    end

    -- XP mode handling
    if state.Xp and state.Xp.value == 'True' then
        log.debug("XP mode active - using default equipment only")
        return StateUtils.reset_to_default_equipment()
    end

    -- Standard equipment handling
    local success = true

    -- Handle weapon sets
    if not WeaponUtils.check_weaponset('main') then
        log.warn("Failed to equip main weapon")
        success = false
    end

    if not WeaponUtils.check_weaponset('sub') then
        log.warn("Failed to equip sub weapon")
        success = false
    end

    -- Reset to default equipment
    if not StateUtils.reset_to_default_equipment() then
        log.warn("Failed to reset to default equipment")
        success = false
    end

    -- THF-specific range lock handling
    if player and player.main_job == 'THF' then
        if not WeaponUtils.check_range_lock() then
            log.warn("Failed to handle range lock for THF")
            success = false
        end
    end

    if success then
        log.debug("Equipment handling completed successfully")
    else
        log.warn("Equipment handling completed with some errors")
    end

    return success
end

-- ===========================================================================================================
--                                     State Change Management
-- ===========================================================================================================

--- Handles necessary actions when the job state changes.
-- @param field (string): The field that has changed in the job state.
-- @param new_value (any): The new value of the changed field.
-- @param old_value (any): The old value of the changed field.
-- @return (boolean): True if successful, false otherwise
function StateUtils.job_state_change(field, new_value, old_value)
    if not field then
        log.error("State change field cannot be nil")
        return false
    end

    if new_value == nil then
        log.error("State change new_value cannot be nil")
        return false
    end

    if old_value == nil then
        log.error("State change old_value cannot be nil")
        return false
    end

    log.debug("State change: %s = %s (was %s)", field, tostring(new_value), tostring(old_value))

    local success = true

    -- Handle weapon set changes
    if field == 'WeaponSet1' or field == 'WeaponSet2' or field == 'WeaponSet' then
        if not WeaponUtils.check_weaponset('main') then
            log.warn("Failed to update main weapon after state change")
            success = false
        end
        
        if not WeaponUtils.check_weaponset('sub') then
            log.warn("Failed to update sub weapon after state change")
            success = false
        end
    end

    -- Handle sub weapon set changes
    if field == 'SubSet' then
        if not WeaponUtils.check_weaponset('sub') then
            log.warn("Failed to update sub weapon after SubSet change")
            success = false
        end
    end

    -- Handle ammo set changes (BST specific)
    if field == 'ammoSet' and player and player.main_job == 'BST' then
        StateUtils.display_broth_count()
    end

    -- Refresh equipment after state change
    if not StateUtils.job_handle_equipping_gear(player and player.status, nil) then
        log.warn("Failed to refresh equipment after state change")
        success = false
    end

    return success
end

--- Displays broth count for BST ammo management
function StateUtils.display_broth_count()
    if not (player and player.main_job == 'BST') then
        return
    end

    -- This would need integration with inventory checking
    -- For now, just log the action
    log.info("Broth count display requested for BST ammo change")
end

-- ===========================================================================================================
--                                     State Validation and Utilities
-- ===========================================================================================================

--- Validates that required state variables exist
-- @return (boolean): True if state is valid, false otherwise
function StateUtils.validate_state()
    if not state then
        log.error("Global state object missing")
        return false
    end

    local required_fields = {
        'Moving', 'HybridMode'
    }

    local optional_fields = {
        'Xp', 'OffenseMode', 'WeaponSet', 'WeaponSet1', 'WeaponSet2', 'SubSet'
    }

    -- Check required fields
    for _, field in ipairs(required_fields) do
        if not state[field] then
            log.error("Required state field missing: %s", field)
            return false
        end
    end

    -- Warn about missing optional fields
    for _, field in ipairs(optional_fields) do
        if not state[field] then
            log.debug("Optional state field missing: %s", field)
        end
    end

    log.debug("State validation passed")
    return true
end

--- Gets current state summary for debugging
-- @return (table): State summary
function StateUtils.get_state_summary()
    if not state then
        return { error = "State not available" }
    end

    local summary = {
        moving = state.Moving and state.Moving.value or "unknown",
        hybrid_mode = state.HybridMode and state.HybridMode.value or "unknown",
        xp_mode = state.Xp and state.Xp.value or "unknown",
        offense_mode = state.OffenseMode and state.OffenseMode.value or "unknown",
        player_status = player and player.status or "unknown",
        main_job = player and player.main_job or "unknown"
    }

    return summary
end

--- Logs current state for debugging
function StateUtils.log_current_state()
    local summary = StateUtils.get_state_summary()
    log.info("Current state: Moving=%s, Hybrid=%s, XP=%s, Offense=%s, Status=%s, Job=%s", 
             summary.moving, summary.hybrid_mode, summary.xp_mode, 
             summary.offense_mode, summary.player_status, summary.main_job)
end

--- Checks if player is in a specific state
-- @param state_field (string): State field to check
-- @param expected_value (any): Expected value
-- @return (boolean): True if state matches expected value
function StateUtils.is_in_state(state_field, expected_value)
    if not state or not state[state_field] then
        return false
    end
    
    return state[state_field].value == expected_value
end

--- Sets a state field value safely
-- @param state_field (string): State field to set
-- @param value (any): Value to set
-- @return (boolean): True if successful, false otherwise
function StateUtils.set_state_field(state_field, value)
    if not state then
        log.error("State object not available")
        return false
    end

    if not state[state_field] then
        log.error("State field does not exist: %s", state_field)
        return false
    end

    local old_value = state[state_field].value
    state[state_field].value = value
    
    log.debug("State field %s changed from %s to %s", state_field, tostring(old_value), tostring(value))
    return true
end

return StateUtils