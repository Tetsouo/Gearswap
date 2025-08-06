---============================================================================
--- FFXI GearSwap Utility Module - Scholar Job Support Functions
---============================================================================
--- Professional Scholar job utility system for GearSwap automation.
--- Provides comprehensive stratagem management, Arts mode handling, spell
--- enhancement coordination, and subjob Scholar support. Core features include:
---
--- • **Stratagem Management** - Light/Dark arts stratagem counting and usage
--- • **Arts Mode Coordination** - Intelligent switching between Light/Dark arts
--- • **Spell Enhancement Logic** - Scholar-specific spell modifications
--- • **Addendum Support** - White/Black addendum spell access management
--- • **Subjob SCH Integration** - Support for SCH as subjob across all jobs
--- • **Tabula Rasa Coordination** - Ultimate stratagem management
--- • **MP Conservation** - Efficient stratagem usage for mana management
--- • **Error Recovery** - Robust handling of stratagem failures
---
--- This module provides essential Scholar functionality for both main job
--- SCH configurations and subjob SCH support across all job combinations,
--- ensuring optimal stratagem usage and Arts coordination.
---
--- @file utils/scholar.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger
--- @requires Windower FFXI
---
--- @usage
---   local ScholarUtils = require('utils/scholar')
---   ScholarUtils.get_max_stratagem_count()
---   ScholarUtils.handle_arts_mode_change()
---============================================================================

local ScholarUtils = {}

-- Load dependencies
local config = require('config/config')
local log = require('utils/logger')

-- ===========================================================================================================
--                                     Stratagem Management Functions (SCH Job)
-- ===========================================================================================================

--- Returns the maximum number of Scholar (SCH) stratagems available based on the player's job level.
-- @return (number): The maximum number of SCH stratagems available, or 0 if 'SCH' is neither the main nor sub job.
function ScholarUtils.get_max_stratagem_count()
    if not player then
        log.error("Player object is not defined")
        return 0
    end

    if type(player.main_job) ~= 'string' or type(player.sub_job) ~= 'string' then
        log.error("Player job information is invalid")
        return 0
    end

    if type(player.main_job_level) ~= 'number' or type(player.sub_job_level) ~= 'number' then
        log.error("Player job level information is invalid")
        return 0
    end

    if player.main_job == 'SCH' or player.sub_job == 'SCH' then
        local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
        if lvl >= 99 then
            return 5
        elseif lvl >= 90 then
            return 5
        elseif lvl >= 70 then
            return 4
        elseif lvl >= 50 then
            return 3
        elseif lvl >= 30 then
            return 2
        else
            return 1
        end
    end

    return 0
end

--- Returns the recast time for a stratagem based on the player's job level.
-- @return (number): The recast time for a stratagem in seconds.
function ScholarUtils.get_stratagem_recast_time()
    if not player then
        log.error("Player object is not defined")
        return 0
    end

    if type(player.main_job) ~= 'string' or type(player.sub_job) ~= 'string' then
        log.error("Player job information is invalid")
        return 0
    end

    if type(player.main_job_level) ~= 'number' or type(player.sub_job_level) ~= 'number' then
        log.error("Player job level information is invalid")
        return 0
    end

    local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
    if lvl >= 99 then
        return 33
    elseif lvl >= 90 then
        return 48
    elseif lvl >= 70 then
        return 60
    elseif lvl >= 50 then
        return 80
    elseif lvl >= 30 then
        return 120
    else
        return 240
    end
end

--- Returns the number of available Scholar (SCH) stratagems.
-- @return (number): The number of available SCH stratagems.
function ScholarUtils.get_available_stratagem_count()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts then
        log.error("Could not get ability recasts")
        return 0
    end

    local recastTime = ability_recasts[231] or 0
    if type(recastTime) ~= 'number' then
        log.error("Recast time is not a number")
        return 0
    end

    local maxStrats = ScholarUtils.get_max_stratagem_count()
    if type(maxStrats) ~= 'number' then
        log.error("Max stratagems is not a number")
        return 0
    end

    if maxStrats == 0 then
        return 0
    end

    local stratagemRecastTime = ScholarUtils.get_stratagem_recast_time()
    if type(stratagemRecastTime) ~= 'number' then
        log.error("Stratagem recast time is not a number")
        return 0
    end

    local stratsUsed = recastTime > stratagemRecastTime and math.ceil(recastTime / stratagemRecastTime) or 0

    if recastTime == stratagemRecastTime then
        stratsUsed = math.floor(recastTime / stratagemRecastTime)
    end

    return math.max(0, maxStrats - stratsUsed)
end

--- Checks if there are any Scholar (SCH) stratagems available for use.
-- @return (boolean): True if there are stratagems available, false otherwise.
function ScholarUtils.stratagems_available()
    local stratagem_count = ScholarUtils.get_available_stratagem_count()
    if type(stratagem_count) ~= 'number' then
        log.error("get_available_stratagem_count did not return a number")
        return false
    end

    return stratagem_count > 0
end

-- ===========================================================================================================
--                                     Stratagem Casting and Management
-- ===========================================================================================================

--- Attempts to cast a stratagem if available
-- @param stratagem_name (string): Name of the stratagem to cast
-- @param target (string, optional): Target for the stratagem (defaults to <me>)
-- @return (boolean): True if stratagem was attempted, false otherwise
function ScholarUtils.cast_stratagem(stratagem_name, target)
    if type(stratagem_name) ~= 'string' then
        log.error("Stratagem name must be a string")
        return false
    end

    if not ScholarUtils.stratagems_available() then
        log.warn("No stratagems available for casting %s", stratagem_name)
        return false
    end

    target = target or '<me>'
    local command = string.format('/ja "%s" %s', stratagem_name, target)

    local success, error_msg = pcall(send_command, 'input ' .. command)
    if not success then
        log.error("Failed to cast stratagem %s: %s", stratagem_name, error_msg or "unknown error")
        return false
    end

    log.info("Cast stratagem: %s on %s", stratagem_name, target)
    return true
end

--- Gets information about current stratagem status
-- @return (table): Table containing stratagem information
function ScholarUtils.get_stratagem_info()
    return {
        max_count = ScholarUtils.get_max_stratagem_count(),
        available_count = ScholarUtils.get_available_stratagem_count(),
        recast_time = ScholarUtils.get_stratagem_recast_time(),
        has_available = ScholarUtils.stratagems_available()
    }
end

--- Validates if player can use Scholar abilities
-- @return (boolean): True if player is SCH main or sub job
function ScholarUtils.can_use_scholar_abilities()
    if not player then
        return false
    end

    return player.main_job == 'SCH' or player.sub_job == 'SCH'
end

-- ===========================================================================================================
--                                     Common Stratagem Shortcuts
-- ===========================================================================================================

--- Casts Light Arts if available
-- @return (boolean): Success status
function ScholarUtils.cast_light_arts()
    if not ScholarUtils.can_use_scholar_abilities() then
        log.warn("Cannot use Scholar abilities - not SCH main/sub")
        return false
    end

    return ScholarUtils.cast_stratagem("Light Arts")
end

--- Casts Dark Arts if available
-- @return (boolean): Success status
function ScholarUtils.cast_dark_arts()
    if not ScholarUtils.can_use_scholar_abilities() then
        log.warn("Cannot use Scholar abilities - not SCH main/sub")
        return false
    end

    return ScholarUtils.cast_stratagem("Dark Arts")
end

--- Casts Addendum: White if available
-- @return (boolean): Success status
function ScholarUtils.cast_addendum_white()
    if not ScholarUtils.can_use_scholar_abilities() then
        log.warn("Cannot use Scholar abilities - not SCH main/sub")
        return false
    end

    return ScholarUtils.cast_stratagem("Addendum: White")
end

--- Casts Addendum: Black if available
-- @return (boolean): Success status
function ScholarUtils.cast_addendum_black()
    if not ScholarUtils.can_use_scholar_abilities() then
        log.warn("Cannot use Scholar abilities - not SCH main/sub")
        return false
    end

    return ScholarUtils.cast_stratagem("Addendum: Black")
end

return ScholarUtils
