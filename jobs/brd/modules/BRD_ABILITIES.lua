---============================================================================
--- FFXI GearSwap BRD Abilities Module
---============================================================================
--- Handles BRD job abilities like Marcato, Nightingale, Troubadour combos,
--- and ability availability checking. Provides centralized ability management
--- for the BRD job with proper recast checking and combo logic.
---
--- @file jobs/brd/modules/brd_abilities.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires Windower resources, MessageUtils
---============================================================================

-- Load dependencies
local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

local BRDAbilities = {}

---============================================================================
--- ABILITY STATUS CHECKING
---============================================================================

--- Check if Nitro (Nightingale + Troubadour) combo is active
--- @return boolean true if both Nightingale and Troubadour are active
function BRDAbilities.is_nitro_active()
    return buffactive['Nightingale'] and buffactive['Troubadour']
end

--- Check if Marcato is available and should be used
--- @return boolean true if Marcato is available for use
function BRDAbilities.is_marcato_available()
    -- Don't use Marcato if Soul Voice is active (they don't stack)
    if buffactive['Soul Voice'] then
        return false
    end

    -- Only use Marcato if both Nightingale AND Troubadour are active
    if not (buffactive['Nightingale'] and buffactive['Troubadour']) then
        return false
    end

    local recast_data = windower.ffxi.get_ability_recasts()
    local abilities = windower.ffxi.get_abilities()

    for _, ability in pairs(abilities.job_abilities) do
        local ability_info = res.job_abilities[ability]
        if ability_info and ability_info.en == 'Marcato' then
            -- Use recast_id instead of ability id
            local recast = recast_data[ability_info.recast_id] or 0
            return recast <= 1
        end
    end

    return false
end

--- Get ability recast time in seconds
--- @param ability_name string Name of the ability to check
--- @return number Recast time in seconds (0 if ready)
function BRDAbilities.get_ability_recast(ability_name)
    local recast_data = windower.ffxi.get_ability_recasts()
    local abilities = windower.ffxi.get_abilities()

    for _, ability in pairs(abilities.job_abilities) do
        local ability_info = res.job_abilities[ability]
        if ability_info and ability_info.en == ability_name then
            local recast = recast_data[ability_info.recast_id] or 0
            return recast
        end
    end

    return 0
end

--- Check if a specific ability is ready to use
--- @param ability_name string Name of the ability to check
--- @return boolean true if ability is ready
function BRDAbilities.is_ability_ready(ability_name)
    return BRDAbilities.get_ability_recast(ability_name) <= 1
end

---============================================================================
--- ABILITY COMBO FUNCTIONS
---============================================================================

--- Cast Nightingale + Troubadour combo with recast checking
--- @return boolean true if combo was executed, false if on cooldown
function BRDAbilities.cast_nightingale_troubadour()
    local nightingale_recast = BRDAbilities.get_ability_recast('Nightingale')
    local troubadour_recast = BRDAbilities.get_ability_recast('Troubadour')

    -- Check if both abilities are available
    if nightingale_recast <= 1 and troubadour_recast <= 1 then
        -- Use unified system
        local messages = { { type = 'info', name = 'Nitro Combo', message = 'Activating Nightingale + Troubadour' } }
        MessageUtils.unified_status_message(messages, nil, true)

        -- Equip Nightingale set and cast
        if sets and sets.precast and sets.precast.Nightingale then
            equip(sets.precast.Nightingale)
        end
        send_command('input /ja "Nightingale" <me>')

        -- Load config for delays
        local success_BRD_CONFIG, BRD_CONFIG = pcall(require, 'jobs/brd/BRD_CONFIG')
        if not success_BRD_CONFIG then
            error("Failed to load jobs/brd/BRD_CONFIG: " .. tostring(BRD_CONFIG))
        end

        -- Wait, equip Troubadour set, and cast
        if sets and sets.precast and sets.precast.Troubadour then
            send_command('wait ' ..
                BRD_CONFIG.TIMINGS.ability_delay ..
                '; gs equip sets.precast.Troubadour; wait ' ..
                BRD_CONFIG.TIMINGS.mode_switch_delay .. '; input /ja "Troubadour" <me>')
        else
            send_command('wait ' .. BRD_CONFIG.TIMINGS.ability_delay .. '; input /ja "Troubadour" <me>')
        end

        return true
    else
        -- Show only recast information (no "Not ready" message)
        if nightingale_recast > 1 then
            MessageUtils.brd_cooldown_message('Nightingale', nightingale_recast)
        else
            MessageUtils.brd_ability_status("Nightingale", "Ready")
        end

        if troubadour_recast > 1 then
            MessageUtils.brd_cooldown_message('Troubadour', troubadour_recast)
        else
            MessageUtils.brd_ability_status("Troubadour", "Ready")
        end

        return false
    end
end

--- Cast Marcato for song enhancement
--- @param target_song string Optional name of the song Marcato is being used for
--- @return boolean true if Marcato was cast, false if not available
function BRDAbilities.cast_marcato(target_song)
    if BRDAbilities.is_marcato_available() then
        local message = target_song and ("Auto-casting for " .. target_song) or "Casting"
        MessageUtils.brd_ja_message("Marcato", message)

        -- Equip Marcato set if available
        if sets and sets.precast and sets.precast.Marcato then
            equip(sets.precast.Marcato)
        end

        send_command('input /ja "Marcato" <me>')
        return true
    else
        local recast = BRDAbilities.get_ability_recast('Marcato')
        if recast > 1 then
            MessageUtils.brd_cooldown_message('Marcato', recast)
        else
            MessageUtils.brd_ability_status("Marcato", "Conditions not met (need Nitro)")
        end
        return false
    end
end

---============================================================================
--- ABILITY STATUS QUERIES
---============================================================================

--- Get comprehensive status of all BRD abilities
--- @return table Status information for all major BRD abilities
function BRDAbilities.get_abilities_status()
    return {
        nightingale = {
            ready = BRDAbilities.is_ability_ready('Nightingale'),
            recast = BRDAbilities.get_ability_recast('Nightingale'),
            active = buffactive['Nightingale'] or false
        },
        troubadour = {
            ready = BRDAbilities.is_ability_ready('Troubadour'),
            recast = BRDAbilities.get_ability_recast('Troubadour'),
            active = buffactive['Troubadour'] or false
        },
        marcato = {
            ready = BRDAbilities.is_ability_ready('Marcato'),
            available = BRDAbilities.is_marcato_available(),
            recast = BRDAbilities.get_ability_recast('Marcato'),
            active = buffactive['Marcato'] or false
        },
        soul_voice = {
            ready = BRDAbilities.is_ability_ready('Soul Voice'),
            recast = BRDAbilities.get_ability_recast('Soul Voice'),
            active = buffactive['Soul Voice'] or false
        },
        nitro_active = BRDAbilities.is_nitro_active()
    }
end

--- Display current status of all BRD abilities
function BRDAbilities.display_abilities_status()
    local status = BRDAbilities.get_abilities_status()

    -- Use unified system like other jobs
    local messages = {}

    -- Nightingale status
    if status.nightingale.active then
        table.insert(messages, { type = 'active', name = 'Nightingale' })
    elseif status.nightingale.recast and status.nightingale.recast > 0 then
        table.insert(messages, { type = 'recast', name = 'Nightingale', time = status.nightingale.recast })
    end

    -- Troubadour status
    if status.troubadour.active then
        table.insert(messages, { type = 'active', name = 'Troubadour' })
    elseif status.troubadour.recast and status.troubadour.recast > 0 then
        table.insert(messages, { type = 'recast', name = 'Troubadour', time = status.troubadour.recast })
    end

    -- Marcato status
    if status.marcato.active then
        table.insert(messages, { type = 'active', name = 'Marcato' })
    elseif status.marcato.recast and status.marcato.recast > 0 then
        table.insert(messages, { type = 'recast', name = 'Marcato', time = status.marcato.recast })
    end

    -- Soul Voice status
    if status.soul_voice.active then
        table.insert(messages, { type = 'active', name = 'Soul Voice' })
    elseif status.soul_voice.recast and status.soul_voice.recast > 0 then
        table.insert(messages, { type = 'recast', name = 'Soul Voice', time = status.soul_voice.recast })
    end

    -- Display all status messages using unified system
    if #messages > 0 then
        MessageUtils.unified_status_message(messages, nil, true)
    end

    -- Nitro combo status as separate message
    if status.nitro_active then
        local nitro_messages = { { type = 'active', name = 'NITRO COMBO' } }
        MessageUtils.unified_status_message(nitro_messages, nil, true)
    end
end

return BRDAbilities
