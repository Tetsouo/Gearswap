---============================================================================
--- FFXI GearSwap Core Module - Buff Management Utilities
---============================================================================
--- Professional buff management system for GearSwap automation.
--- Provides intelligent buff tracking, equipment optimization, automatic
--- gear switching, and comprehensive buff state management. Core features:
---
--- • **Buff State Tracking** - Real-time monitoring of all character buffs
--- • **Equipment Optimization** - Automatic gear switching based on buffs
--- • **Buff Duration Management** - Timing and refresh coordination
--- • **Priority Buff Handling** - Critical buff preservation (Doom, etc.)
--- • **Job-Specific Integration** - Buff handling tailored to job requirements
--- • **Performance Optimization** - Efficient buff change processing
--- • **Error Recovery** - Robust handling of buff state inconsistencies
--- • **Configuration Driven** - Customizable buff handling behavior
---
--- This module serves as the central buff management hub for all GearSwap
--- functionality, ensuring optimal equipment selection based on active buffs
--- with comprehensive error handling and performance optimization.
---
--- @file core/buffs.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, utils/messages
--- @requires Windower FFXI
---
--- @usage
---   local BuffUtils = require('core/buffs')
---   BuffUtils.handle_buff_change(buff_name, gained)
---============================================================================

local BuffUtils = {}

-- Load dependencies
local config = require('config/config')
local log = require('utils/logger')
local MessageUtils = require('utils/messages')

-- ===========================================================================================================
--                                     Buff Management Functions
-- ===========================================================================================================

--- Handles changes in buffs with optimized logic
-- @param buff (string): The name of the buff.
-- @param gain (boolean): Whether the buff was gained or lost.
function BuffUtils.handle_buff_change(buff, gain)
    -- Validation
    if not buff or not gain then
        log.error("Invalid buff change parameters: buff=%s, gain=%s", tostring(buff), tostring(gain))
        return
    end

    -- Local variables for optimization
    local equip_set = {}
    local isMoving = state and state.Moving and state.Moving.value == 'true'
    local isTHFOrBLM = player and (player.main_job == 'THF' or player.main_job == 'BLM')
    local isWARWithUkonvasara = player and player.main_job == 'WAR' and
        player.equipment and player.equipment.main == 'Ukonvasara'

    -- Priority handling for Doom
    if buff:lower() == 'doom' then
        BuffUtils.handle_doom_buff(gain)
        return
    end

    -- WAR-specific Aftermath handling
    if isWARWithUkonvasara and buff == 'Aftermath: Lv.3' then
        BuffUtils.handle_aftermath_buff(gain)
        return
    end

    -- Don't change gear while engaged except for specific buffs
    if player and player.status == 'Engaged' and
        not (buff == 'Aftermath: Lv.3' or buff == 'Doom' or
            buff == 'Sneak Attack' or buff == 'Trick Attack') then
        return
    end

    -- THF/BLM specific handling
    if isTHFOrBLM then
        BuffUtils.handle_thf_blm_buffs(buff, gain)
    end

    -- Standard buff handling
    if state and state.Buff and state.Buff[buff] ~= nil then
        BuffUtils.handle_standard_buff(buff, gain, equip_set)
    end

    -- Sneak Attack / Trick Attack specific handling
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        BuffUtils.handle_sa_ta_buffs(buff, gain)
    else
        -- Normal equipment update
        if job_handle_equipping_gear then
            job_handle_equipping_gear(player.status, nil)
        end
    end
end

--- Handles Doom buff specifically
-- @param gain (boolean): Whether Doom was gained or lost
function BuffUtils.handle_doom_buff(gain)
    if gain then
        -- Apply Doom set if available
        if sets and sets.buff and sets.buff.Doom then
            equip(sets.buff.Doom)
        end

        -- Lock critical slots
        disable('neck', 'ring1', 'waist')

        -- Notifications
        MessageUtils.status_message('error', 'WARNING: Doom is active!')
        send_command('input /p [DOOM] <call21>')

        log.warn("Doom activated - critical slots locked")
    else
        -- Unlock slots
        enable('neck', 'ring1', 'waist')

        -- Update equipment
        send_command('gs c update')

        MessageUtils.status_message('info', 'Doom is no longer active!')
        send_command('input /p [Doom] Off !')

        log.info("Doom removed - slots unlocked")
    end
end

--- Handles Aftermath buff for WAR with Ukonvasara
-- @param gain (boolean): Whether Aftermath was gained or lost
function BuffUtils.handle_aftermath_buff(gain)
    if not state or not state.HybridMode then
        return
    end

    local isPDT = state.HybridMode.value == 'PDT'

    if gain then
        if isPDT then
            if sets and sets.engaged and sets.engaged.PDTAFM3 then
                equip(sets.engaged.PDTAFM3)
            end
        else
            if sets and sets.engaged then
                equip(sets.engaged)
            end
        end
        log.info("Aftermath Lv.3 activated")
    else
        if isPDT then
            if sets and sets.engaged and sets.engaged.PDTTP then
                equip(sets.engaged.PDTTP)
            end
        else
            if sets and sets.engaged then
                equip(sets.engaged)
            end
        end
        log.info("Aftermath Lv.3 faded")
    end
end

--- Handles THF/BLM specific buff logic
-- @param buff (string): The buff name
-- @param gain (boolean): Whether buff was gained or lost
function BuffUtils.handle_thf_blm_buffs(buff, gain)
    if not state or not state.Buff then
        return
    end

    -- Update state
    if state.Buff[buff] ~= nil then
        state.Buff[buff] = gain
    end

    -- BLM Mana Wall specific handling
    if player and player.main_job == 'BLM' and buff == 'Mana Wall' then
        if gain then
            if sets and sets.precast and sets.precast.JA and sets.precast.JA['Mana Wall'] then
                equip(sets.precast.JA['Mana Wall'])
            end
            disable('back', 'feet')
            log.info("Mana Wall activated - back/feet locked")
        else
            enable('back', 'feet')
            log.info("Mana Wall faded - back/feet unlocked")
        end
    end
end

--- Handles standard buff equipment changes
-- @param buff (string): The buff name
-- @param gain (boolean): Whether buff was gained or lost
-- @param equip_set (table): Equipment set to modify
function BuffUtils.handle_standard_buff(buff, gain, equip_set)
    if gain and sets and sets.buff and sets.buff[buff] then
        equip_set = set_combine(equip_set, sets.buff[buff])
    end

    -- Treasure Hunter mode handling
    if state and state.TreasureMode and
        (state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime') then
        if sets and sets.TreasureHunter then
            equip_set = set_combine(equip_set, sets.TreasureHunter)
        end
    end
end

--- Handles Sneak Attack and Trick Attack buffs
-- @param buff (string): The buff name (should be 'Sneak Attack' or 'Trick Attack')
-- @param gain (boolean): Whether buff was gained or lost
function BuffUtils.handle_sa_ta_buffs(buff, gain)
    if not state or not state.Buff then
        return
    end

    local equip_set = {}

    if gain then
        -- Both buffs active
        if state.Buff['Sneak Attack'] and state.Buff['Trick Attack'] and
            sets and sets.buff then
            equip_set = set_combine(equip_set,
                sets.buff['Sneak Attack'], sets.buff['Trick Attack'])
        elseif sets and sets.buff and sets.buff[buff] then
            -- Single buff active
            equip_set = set_combine(equip_set, sets.buff[buff])
        end
    else
        -- Handle buff loss
        if state.Buff['Sneak Attack'] and sets and sets.buff then
            equip_set = set_combine(equip_set, sets.buff['Sneak Attack'])
        elseif state.Buff['Trick Attack'] and sets and sets.buff then
            equip_set = set_combine(equip_set, sets.buff['Trick Attack'])
        else
            -- No more SA/TA buffs - return to normal gear
            equip_set = player and player.status == 'Engaged' and
                sets and sets.engaged or sets and sets.idle or {}
        end
    end

    -- Apply equipment set if changes were made
    if next(equip_set) then
        equip(equip_set)
    end

    -- Final equipment update if no SA/TA active
    if not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack'] then
        if job_handle_equipping_gear then
            job_handle_equipping_gear(player.status, nil)
        end
    end
end

-- ===========================================================================================================
--                                     Treasure Hunter Functions
-- ===========================================================================================================

--- Determines if a given action inherently triggers the Treasure Hunter effect.
-- @param category (number): The category of the action.
-- @param param (number): The specific action within the category.
-- @return (boolean): True if the action inherently triggers Treasure Hunter, false otherwise.
function BuffUtils.th_action_check(category, param)
    if type(category) ~= 'number' or type(param) ~= 'number' then
        log.error("TH action check requires numeric parameters")
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
        return th_actions[category](param)
    end

    return false
end

-- ===========================================================================================================
--                                     Party and Pet Functions
-- ===========================================================================================================

--- Checks if a specific party member has a pet.
-- @param name (string): The name of the party member to check.
-- @return (boolean): True if the party member is found and they have a pet, false otherwise.
function BuffUtils.find_member_and_pet_in_party(name)
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
                return member.mob.pet_index ~= nil
            end
        end
    end

    return false
end

-- ===========================================================================================================
--                                     Auto-Buff Functions
-- ===========================================================================================================

--- Automatically maintains specified buffs based on duration and cooldown
-- @param buff_list (table): Table of buffs to maintain with their settings
-- @param force_refresh (boolean): Force refresh even if buff is active
function BuffUtils.maintain_buffs(buff_list, force_refresh)
    if type(buff_list) ~= 'table' then
        log.error("buff_list must be a table")
        return
    end

    local refresh_threshold = config.get('automation.buffs.refresh_threshold') or 30
    local cast_delay = config.get('automation.buffs.cast_delay') or 2
    local total_delay = 0

    for _, buff_data in ipairs(buff_list) do
        if type(buff_data) == 'table' and buff_data.name and buff_data.spell then
            local should_cast = false

            if force_refresh then
                should_cast = true
            elseif not buffactive[buff_data.name] then
                should_cast = true
            elseif buff_data.duration and buffactive[buff_data.name] then
                -- Check remaining duration if available
                -- This would need integration with buff tracking
                should_cast = false -- Placeholder
            end

            if should_cast then
                local spell_recasts = windower.ffxi.get_spell_recasts()
                if spell_recasts and spell_recasts[buff_data.spell_id] == 0 then
                    local command = string.format('wait %d; input /ma "%s" <me>',
                        total_delay, buff_data.spell)
                    send_command(command)
                    total_delay = total_delay + cast_delay

                    log.info("Queued buff refresh: %s", buff_data.name)
                end
            end
        end
    end
end

--- Gets the remaining duration of a buff (if tracking is available)
-- @param buff_name (string): Name of the buff
-- @return (number): Remaining duration in seconds, or nil if not available
function BuffUtils.get_buff_remaining_duration(buff_name)
    -- This would require integration with a buff tracking system
    -- For now, return nil as a placeholder
    return nil
end

return BuffUtils
