---============================================================================
--- Spell & Ability Helper - Unified magic management
---============================================================================
--- Provides simple functions to manage spells and abilities without complex
--- constants, tables or initialization. Just call and use!
---
--- @file utils/ability_helper.lua
--- @author Tetsouo
--- @version 2.0
--- @date 2025-08-18
---============================================================================

local SpellAbilityHelper = {}
local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end

--- Get ability ID by name
--- @param ability_name string The English name of the ability
--- @return number|nil The ability ID or nil if not found
function SpellAbilityHelper.get_ability_id(ability_name)
    local ability_data = res.job_abilities:with('en', ability_name)
    return ability_data and ability_data.id
end

--- Get spell ID by name
--- @param spell_name string The English name of the spell
--- @return number|nil The spell ID or nil if not found
function SpellAbilityHelper.get_spell_id(spell_name)
    local spell_data = res.spells:with('en', spell_name)
    return spell_data and spell_data.id
end

---============================================================================
--- UNIFIED RECAST CONVERSION SYSTEM
---============================================================================

--- Convert raw recast values to seconds based on type
--- @param recast_value number Raw recast value from Windower API
--- @param is_spell boolean True for spells (centiseconds), false for abilities (seconds)
--- @return number Recast time in seconds
local function convert_recast_to_seconds(recast_value, is_spell)
    if not recast_value or recast_value == 0 then
        return 0
    end

    if is_spell then
        -- Spells: get_spell_recasts() returns centiseconds (1/100 sec)
        return recast_value / 100
    else
        -- Abilities: get_ability_recasts() returns seconds
        return recast_value
    end
end

--- Check if an ability is available (not on cooldown)
--- @param ability_name string The English name of the ability
--- @return boolean True if ability is ready to use
function SpellAbilityHelper.is_ability_ready(ability_name)
    local ability_data = res.job_abilities:with('en', ability_name)
    if not ability_data then return false end

    local recasts = windower.ffxi.get_ability_recasts()
    -- IMPORTANT: utiliser recast_id, pas id !
    local recast_id = ability_data.recast_id or ability_data.id
    local cooldown = recasts and recasts[recast_id] or 0
    return cooldown < 1
end

--- Check if a spell is available (not on cooldown)
--- @param spell_name string The English name of the spell
--- @return boolean True if spell is ready to cast
function SpellAbilityHelper.is_spell_ready(spell_name)
    local spell_data = res.spells:with('en', spell_name)
    if not spell_data then return false end

    local recasts = windower.ffxi.get_spell_recasts()
    -- Use recast_id if available, otherwise fall back to id
    local recast_id = spell_data.recast_id or spell_data.id
    local cooldown = recasts and recasts[recast_id] or 0


    return cooldown < 1
end

--- Check if an ability buff is active
--- @param ability_name string The English name of the ability
--- @return boolean True if the buff is currently active
function SpellAbilityHelper.is_buff_active(ability_name)
    return buffactive[ability_name] or false
end

--- Smart auto-ability: Detects if ability creates a buff and shows appropriate message
--- @param spell table The spell object
--- @param eventArgs table The event arguments
--- @param ability_name string The English name of the ability to use
--- @param wait_time number Time to wait after ability (default: 2)
function SpellAbilityHelper.try_ability_smart(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end

    local ability_ready = SpellAbilityHelper.is_ability_ready(ability_name)
    local ability_active = SpellAbilityHelper.is_buff_active(ability_name)

    -- Check if this ability creates a buff that enhances the spell
    local creates_buff = SpellAbilityHelper.ability_creates_buff(ability_name, spell.name)

    -- Si ability active ET crée un buff → affiche "Active" et laisse spell se caster
    if ability_active and creates_buff then
        local messages = { { type = 'active', name = ability_name } }
        MessageUtils.unified_status_message(messages, nil, true)
        return -- Laisse le spell se caster normalement
    end

    -- Si ability prête et pas active → utilise ability + spell
    if ability_ready and not ability_active then
        eventArgs.handled = true
        cancel_spell()
        send_command(string.format('input /ja "%s" <me>; wait %d; input /ma "%s" %s',
            ability_name, wait_time, spell.name, spell.target.id))
        return
    end

    -- Si ability pas prête → affiche recast ability
    if not ability_ready then
        local ability_data = res.job_abilities:with('en', ability_name)
        if ability_data then
            local recasts = windower.ffxi.get_ability_recasts()
            local recast_id = ability_data.recast_id or ability_data.id
            local cooldown = recasts and recasts[recast_id] or 0
            -- Use unified conversion system
            cooldown = convert_recast_to_seconds(cooldown, false) -- false = ability (already in seconds)
            local messages = { { type = 'recast', name = ability_name, time = cooldown } }
            MessageUtils.unified_status_message(messages, nil, true)
        end

        -- Si l'ability crée un buff, ne pas vérifier le spell recast - laisse se caster
        if creates_buff then
            return -- Laisse le spell se caster normalement
        end

        -- Sinon, vérifier si le spell est aussi en recast (comportement original)
        local spell_ready = SpellAbilityHelper.is_spell_ready(spell.name)
        if not spell_ready then
            local spell_data = res.spells:with('en', spell.name)
            if spell_data then
                local recasts = windower.ffxi.get_spell_recasts()
                local recast_id = spell_data.recast_id or spell_data.id
                local cooldown = recasts and recasts[recast_id] or 0
                -- Use unified conversion system
                cooldown = convert_recast_to_seconds(cooldown, true) -- true = spell
                local messages = { { type = 'recast', name = spell.name, time = cooldown } }
                MessageUtils.unified_status_message(messages, nil, true)
            end
            -- Si spell aussi en recast, on annule tout
            eventArgs.handled = true
            cancel_spell()
        end
        return
    end

    -- Si ability active mais ne crée pas de buff → laisse spell se caster normalement
end

--- Check if an ability creates a buff that enhances a specific spell
--- @param ability_name string The English name of the ability
--- @param spell_name string The English name of the spell
--- @return boolean True if the ability creates a relevant buff for this spell
function SpellAbilityHelper.ability_creates_buff(ability_name, spell_name)
    -- Define known ability->spell buff relationships
    local buff_relationships = {
        ['Majesty'] = { 'Cure III', 'Cure IV', 'Protect III', 'Protect IV', 'Protect V' },
        ['Reprisal'] = { 'Reprisal' },
        -- Add more as needed
    }

    local enhanced_spells = buff_relationships[ability_name]
    if not enhanced_spells then return false end

    for _, enhanced_spell in ipairs(enhanced_spells) do
        if spell_name == enhanced_spell then
            return true
        end
    end

    return false
end

--- Simple auto-ability: Use ability + spell if ready, otherwise just cast spell
--- @param spell table The spell object
--- @param eventArgs table The event arguments
--- @param ability_name string The English name of the ability to use
--- @param wait_time number Time to wait after ability (default: 2)
function SpellAbilityHelper.try_ability(spell, eventArgs, ability_name, wait_time)
    wait_time = wait_time or 2
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end

    local ability_ready = SpellAbilityHelper.is_ability_ready(ability_name)
    local ability_active = SpellAbilityHelper.is_buff_active(ability_name)

    -- Si ability prête et pas active → utilise ability + spell
    if ability_ready and not ability_active then
        eventArgs.handled = true
        cancel_spell()
        send_command(string.format('input /ja "%s" <me>; wait %d; input /ma "%s" %s',
            ability_name, wait_time, spell.name, spell.target.id))
        return
    end

    -- Si ability pas prête → affiche recast ability ET recast spell si nécessaire
    if not ability_ready then
        local ability_data = res.job_abilities:with('en', ability_name)
        if ability_data then
            local recasts = windower.ffxi.get_ability_recasts()
            local recast_id = ability_data.recast_id or ability_data.id
            local cooldown = recasts and recasts[recast_id] or 0
            -- Use unified conversion system
            cooldown = convert_recast_to_seconds(cooldown, false) -- false = ability (already in seconds)
            local messages = { { type = 'recast', name = ability_name, time = cooldown } }
            MessageUtils.unified_status_message(messages, nil, true)
        end

        -- Vérifier si le spell est aussi en recast
        local spell_ready = SpellAbilityHelper.is_spell_ready(spell.name)
        if not spell_ready then
            local spell_data = res.spells:with('en', spell.name)
            if spell_data then
                local recasts = windower.ffxi.get_spell_recasts()
                local recast_id = spell_data.recast_id or spell_data.id
                local cooldown = recasts and recasts[recast_id] or 0
                -- Use unified conversion system
                cooldown = convert_recast_to_seconds(cooldown, true) -- true = spell
                local messages = { { type = 'recast', name = spell.name, time = cooldown } }
                MessageUtils.unified_status_message(messages, nil, true)
            end
            -- Si spell aussi en recast, on annule tout
            eventArgs.handled = true
            cancel_spell()
        end
        -- Si spell prêt, on le laisse se caster normalement
        return
    end

    -- Si ability active → laisse spell se caster normalement
end

--- Auto-enhance spell with ability if conditions are met
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments
--- @param spell_name string Name of spell to trigger on
--- @param ability_name string Name of ability to use
--- @param wait_time number Wait time (optional)
function SpellAbilityHelper.auto_enhance(spell, eventArgs, spell_name, ability_name, wait_time)
    if spell.name == spell_name then
        SpellAbilityHelper.try_ability(spell, eventArgs, ability_name, wait_time)
    end
end

--- PUBLIC: Get properly converted recast time for any spell or ability
--- @param name string The English name of the spell or ability
--- @param is_spell boolean True for spells, false for abilities
--- @return number Recast time in seconds (0 if ready or not found)
function SpellAbilityHelper.get_recast_seconds(name, is_spell)
    if is_spell then
        local spell_data = res.spells:with('en', name)
        if not spell_data then return 0 end

        local recasts = windower.ffxi.get_spell_recasts()
        local recast_id = spell_data.recast_id or spell_data.id
        local cooldown = recasts and recasts[recast_id] or 0
        return convert_recast_to_seconds(cooldown, true)
    else
        local ability_data = res.job_abilities:with('en', name)
        if not ability_data then return 0 end

        local recasts = windower.ffxi.get_ability_recasts()
        local recast_id = ability_data.recast_id or ability_data.id
        local cooldown = recasts and recasts[recast_id] or 0
        return convert_recast_to_seconds(cooldown, false)
    end
end

return SpellAbilityHelper
