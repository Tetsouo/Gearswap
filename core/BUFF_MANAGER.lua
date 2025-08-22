---============================================================================
--- FFXI GearSwap Core Module - Advanced Buff Manager Utilities
---============================================================================
--- Professional advanced buff management system for critical buff handling.
--- Provides specialized management for high-priority buffs requiring immediate
--- attention and specific equipment coordination. Core features include:
---
--- • **Critical Buff Management** - Doom, Petrification, Terror priority handling
--- • **Slot Locking System** - Automatic equipment slot protection
--- • **Emergency Response** - Rapid gear switching for survival buffs
--- • **Buff Conflict Resolution** - Intelligent handling of conflicting effects
--- • **Status Ailment Recovery** - Automated recovery from debilitating effects
--- • **Priority Queue System** - Ordered buff processing by importance
--- • **Notification Integration** - User alerts for critical buff changes
--- • **Safety Mechanisms** - Fail-safe protection for essential equipment
---
--- This specialized module handles the most critical aspects of buff management,
--- focusing on survival-critical buffs and emergency response situations that
--- require immediate and reliable equipment coordination.
---
--- @file core/buff_manager.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, utils/messages
--- @requires Windower FFXI
---
--- @usage
---   local BuffManagerUtils = require('core/BUFF_MANAGER')
---   BuffManagerUtils.handle_doom_buff(gained)
---============================================================================

local BuffManagerUtils = {}

-- Load dependencies
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

-- ===========================================================================================================
--                                     Doom Buff Management
-- ===========================================================================================================

--- Handles Doom buff specifically with priority logic
-- @param gain (boolean): Whether the buff was gained or lost
function BuffManagerUtils.handle_doom_buff(gain)
    if gain then
        -- Apply Doom set
        if sets.buff.Doom then
            equip(sets.buff.Doom)
        end
        -- Lock critical slots
        disable('neck', 'ring1', 'waist')
        -- Notifications
        MessageUtils.universal_message(nil, 'error', 'WARNING: Doom is active!', nil, nil, nil, 201)
        send_command('input /p [DOOM] <call21>')
        log.warn("Doom buff gained - critical slots locked")
    else
        -- Unlock slots
        enable('neck', 'ring1', 'waist')
        -- Update equipment
        send_command('gs c update')
        MessageUtils.universal_message(nil, 'info', 'Doom is no longer active!', nil, nil, nil, 069)
        send_command('input /p [Doom] Off !')
        log.info("Doom buff lost - equipment updated")
    end
end

-- ===========================================================================================================
--                                   Aftermath Buff Management
-- ===========================================================================================================

--- Handles Aftermath buffs for specific weapons
-- @param buff (string): The buff name
-- @param gain (boolean): Whether the buff was gained or lost
-- @param weapon (string): The weapon name (optional, uses player.equipment.main if not provided)
function BuffManagerUtils.handle_aftermath_buff(buff, gain, weapon)
    weapon = weapon or player.equipment.main

    -- WAR with Ukonvasara specific handling
    if player.main_job == 'WAR' and weapon == 'Ukonvasara' then
        if buff == 'Aftermath: Lv.3' then
            if gain then
                if state.HybridMode.value == 'PDT' then
                    equip(sets.engaged.PDTAFM3)
                else
                    equip(sets.engaged)
                end
                log.debug("Aftermath Lv.3 gained - equipped appropriate set")
            else
                if state.HybridMode.value == 'PDT' then
                    equip(sets.engaged.PDTTP)
                else
                    equip(sets.engaged)
                end
                log.debug("Aftermath Lv.3 lost - equipped appropriate set")
            end
            return true
        end
    end

    -- Add more weapon-specific aftermath handling here as needed
    return false
end

-- ===========================================================================================================
--                                    Job-Specific Buff Management
-- ===========================================================================================================

--- Handles job-specific buff logic
-- @param buff (string): The buff name
-- @param gain (boolean): Whether the buff was gained or lost
-- @param job (string): The job name (optional, uses player.main_job if not provided)
function BuffManagerUtils.handle_job_specific_buffs(buff, gain, job)
    job = job or player.main_job
    local handled = false

    -- THF and BLM specific handling
    if job == 'THF' or job == 'BLM' then
        if state.Buff[buff] ~= nil then
            state.Buff[buff] = gain
            handled = true
        end

        -- BLM Mana Wall specific handling
        if job == 'BLM' and buff == 'Mana Wall' then
            if gain then
                equip(sets.precast.JA['Mana Wall'])
                disable('back', 'feet')
                log.debug("Mana Wall gained - slots disabled")
            else
                enable('back', 'feet')
                log.debug("Mana Wall lost - slots enabled")
            end
            handled = true
        end
    end

    return handled
end

-- ===========================================================================================================
--                                    Sneak Attack / Trick Attack Management
-- ===========================================================================================================

--- Handles SA/TA buff combinations with proper equipment logic
-- @param buff (string): The buff name ('Sneak Attack' or 'Trick Attack')
-- @param gain (boolean): Whether the buff was gained or lost
function BuffManagerUtils.handle_sa_ta_buffs(buff, gain)
    if buff ~= 'Sneak Attack' and buff ~= 'Trick Attack' then
        return false
    end

    local equip_set = {}

    if gain then
        if state.Buff['Sneak Attack'] and state.Buff['Trick Attack'] then
            -- Both buffs are active
            equip_set = set_combine(equip_set,
                sets.buff['Sneak Attack'],
                sets.buff['Trick Attack'])
            log.debug("Both SA and TA active - combined sets equipped")
        else
            -- Single buff is active
            equip_set = set_combine(equip_set, sets.buff[buff])
            log.debug("%s gained - specific set equipped", buff)
        end
    else
        -- Handle buff loss
        if state.Buff['Sneak Attack'] then
            equip_set = set_combine(equip_set, sets.buff['Sneak Attack'])
            log.debug("SA still active after %s loss", buff)
        elseif state.Buff['Trick Attack'] then
            equip_set = set_combine(equip_set, sets.buff['Trick Attack'])
            log.debug("TA still active after %s loss", buff)
        else
            -- No more SA/TA buffs active
            equip_set = player.status == 'Engaged' and sets.engaged or sets.idle
            log.debug("No SA/TA buffs active - default set equipped")
        end
    end

    -- Apply equipment set if changes were made
    if next(equip_set) then
        equip(equip_set)
    end

    -- Update equipment if no SA/TA buffs are active
    if not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack'] then
        local success_StateUtils, StateUtils = pcall(require, 'core/STATE')
        if not success_StateUtils then
            error("Failed to load core/STATE: " .. tostring(StateUtils))
        end
        StateUtils.job_handle_equipping_gear(player.status, nil)
    end

    return true
end

-- ===========================================================================================================
--                                    Standard Buff Management
-- ===========================================================================================================

--- Handles standard buff logic with Treasure Hunter mode
-- @param buff (string): The buff name
-- @param gain (boolean): Whether the buff was gained or lost
function BuffManagerUtils.handle_standard_buffs(buff, gain)
    local equip_set = {}

    if state.Buff[buff] ~= nil then
        -- Apply buff-specific set if it exists
        if sets.buff[buff] then
            equip_set = set_combine(equip_set, sets.buff[buff])
        end

        -- Handle Treasure Hunter mode
        if state.TreasureMode and
            (state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime') then
            equip_set = set_combine(equip_set, sets.TreasureHunter)
        end

        -- Apply equipment if changes were made
        if next(equip_set) then
            equip(equip_set)
        end

        return true
    end

    return false
end

-- ===========================================================================================================
--                                    Main Buff Change Handler
-- ===========================================================================================================

--- Main buff change handler that coordinates all buff management
-- @param buff (string): The name of the buff
-- @param gain (boolean): Whether the buff was gained or lost
function BuffManagerUtils.handle_buff_change(buff, gain)
    -- Parameter validation
    if buff == nil then
        log.error("buff_change called with nil buff")
        return
    end

    if gain == nil then
        log.error("buff_change called with nil gain")
        return
    end

    log.debug("Buff change: %s %s", buff, gain and "gained" or "lost")

    -- Priority 1: Doom handling (always takes precedence)
    if buff:lower() == 'doom' then
        BuffManagerUtils.handle_doom_buff(gain)
        return
    end

    -- Priority 2: Aftermath handling for specific weapons
    if BuffManagerUtils.handle_aftermath_buff(buff, gain) then
        return
    end

    -- Don't change equipment during combat except for specific buffs
    if player.status == 'Engaged' and
        not (buff == 'Aftermath: Lv.3' or buff == 'Doom' or
            buff == 'Sneak Attack' or buff == 'Trick Attack') then
        log.debug("Skipping buff equipment change during combat: %s", buff)
        return
    end

    -- Priority 3: Job-specific buff handling
    if BuffManagerUtils.handle_job_specific_buffs(buff, gain) then
        -- Continue to other handlers as job-specific might not be exclusive
    end

    -- Priority 4: SA/TA specific handling
    if BuffManagerUtils.handle_sa_ta_buffs(buff, gain) then
        return
    end

    -- Priority 5: Standard buff handling
    if BuffManagerUtils.handle_standard_buffs(buff, gain) then
        return
    end

    -- Fallback: General equipment handling
    local success_StateUtils, StateUtils = pcall(require, 'core/STATE')
    if not success_StateUtils then
        error("Failed to load core/state: " .. tostring(StateUtils))
    end
    StateUtils.job_handle_equipping_gear(player.status, nil)
end

return BuffManagerUtils
