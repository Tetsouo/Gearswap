---============================================================================
--- FFXI GearSwap Core Module - Spell Management and Validation Utilities
---============================================================================
--- Comprehensive spell handling system for GearSwap automation.
--- Provides spell validation, incapacitation checking, cooldown management,
--- and safe casting utilities for reliable spell execution.
---
--- @file spells.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05
--- @date Modified: 2025-08-05
--- @requires config/config.lua
--- @requires utils/logger.lua
--- @requires utils/messages.lua
--- @requires Windower FFXI
--- @requires GearSwap addon
---
--- Features:
---   - Comprehensive spell validation before casting
---   - Incapacitation detection and handling (silence, stun, sleep, etc.)
---   - Spell recast timer checking and management
---   - Safe spell casting with error handling
---   - Cooldown display and user feedback
---   - Special handling for excluded abilities (Quick Draw, pet commands)
---   - Integration with job-specific equipment handling
---   - Automatic spell cancellation on failure conditions
---
--- Usage:
---   local SpellUtils = require('core/spells')
---   
---   -- Check if spell can be cast
---   local can_cast = SpellUtils.can_cast_spell(spell, eventArgs)
---   
---   -- Try to cast with automatic error handling
---   local success = SpellUtils.try_cast_spell(spell, eventArgs)
---   
---   -- Check for incapacitation
---   local incapacitated, type = SpellUtils.check_incapacitated(spell, eventArgs)
---   
---   -- Display cooldown information
---   SpellUtils.check_display_cooldown(spell, eventArgs)
---
--- Thread Safety:
---   All functions are designed to be called safely from GearSwap events.
---   Windower API calls are properly protected with error handling.
---============================================================================

---============================================================================
--- MODULE INITIALIZATION
---============================================================================

--- @class SpellUtils Spell management and validation utility module
local SpellUtils = {}

--- @type table Configuration module for spell-related settings
local config = require('config/config')

--- @type table Logging utilities for error reporting and debugging
local log = require('utils/logger')

--- @type table Message formatting utilities for user feedback
local MessageUtils = require('utils/messages')

--- Spells excluded from standard cooldown checking
--- @type table List of spell names that bypass normal recast validation
SpellUtils.ignoredSpells = { 'Breakga', 'Aspir III', 'Aspir II' }

---============================================================================
--- SPELL VALIDATION AND CHECKING
---============================================================================

--- Perform comprehensive validation to determine if a spell can be cast.
--- Checks spell validity, recast timers, incapacitation status, and
--- handles special exclusions for specific ability types.
---
--- Validation Steps:
---   1. Basic spell data validation (id, action_type)
---   2. Special exclusions (Quick Draw, pet commands)
---   3. Incapacitation checking (silence, stun, sleep, etc.)
---   4. Recast timer validation
---
--- @param spell table The spell object to validate
--- @param eventArgs table Event arguments for cancellation handling
--- @return boolean True if spell can be cast safely, false otherwise
function SpellUtils.can_cast_spell(spell, eventArgs)
    if spell == nil or spell.id == nil or spell.action_type == nil then
        log.debug("Invalid spell data")
        return false
    end

    -- Exclude Quick Draw and pet commands Sic, Ready from cooldown checks
    local excluded_ids = { 124, 72, 251 }
    for _, id in ipairs(excluded_ids) do
        if spell.id == id then
            return true
        end
    end

    -- Check if incapacitated
    local is_incapacitated, incapacity_type = SpellUtils.check_incapacitated(spell, eventArgs)
    if is_incapacitated then
        return false
    end

    -- Get spell recasts
    local spellRecasts = windower.ffxi.get_spell_recasts()
    if spellRecasts then
        local spellRecast = spellRecasts[spell.id]
        if spellRecast and spellRecast > 0 then
            return false
        end
    end

    return true
end

--- Check for player incapacitation that would prevent spell casting.
--- Detects various debuff conditions that prevent spell execution
--- and automatically cancels spells with appropriate user feedback.
---
--- Incapacitation Types Detected:
---   - Silence/Mute: Prevents magic spells (but not abilities/items)
---   - Stun: Prevents all actions
---   - Petrification: Complete action prevention
---   - Terror: Movement and action restriction
---   - Sleep: Unconscious state
---
--- @param spell table The spell being attempted
--- @param eventArgs table Event arguments for spell cancellation
--- @return boolean True if player is incapacitated
--- @return string|nil Type of incapacitation, or nil if not incapacitated
function SpellUtils.check_incapacitated(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.action_type or not spell.name then
        return false, "Invalid inputs"
    end

    -- Define incapacitating buffs
    local incapacitating_buffs = {
        silence = true,
        stun = true,
        petrification = true,
        terror = true,
        sleep = true,
        mute = true,
    }

    -- Job abilities and items aren't affected by silence/mute
    if (spell.action_type == 'Ability' or spell.action_type == 'Item') and
        (buffactive['silence'] or buffactive['mute']) then
        return false, nil
    end

    -- Check for incapacitating buffs
    if next(buffactive) then
        for buff in pairs(buffactive) do
            if incapacitating_buffs[buff] then
                local success = pcall(cancel_spell)
                if success then
                    eventArgs.handled = true
                    MessageUtils.incapacitated_message(spell.name, buff)
                end
                return true, buff
            end
        end
    end

    return false, nil
end

---============================================================================
--- SPELL CASTING HELPERS
---============================================================================

--- Attempt to cast a spell with automatic validation and error handling.
--- Performs complete validation check and cancels spell if any
--- conditions prevent successful casting.
---
--- @param spell table The spell to attempt to cast
--- @param eventArgs table Event arguments for cancellation handling
--- @return boolean True if spell can proceed, false if cancelled
function SpellUtils.try_cast_spell(spell, eventArgs)
    local can_cast = SpellUtils.can_cast_spell(spell, eventArgs)

    if not can_cast then
        cancel_spell()
        return false
    end

    return true
end

--- Handle spell casting failure with comprehensive cleanup.
--- Cancels the spell, updates equipment state, and provides
--- user feedback when a spell cannot be cast successfully.
---
--- Cleanup Operations:
---   - Spell cancellation
---   - Event handling flag setting
---   - Job-specific equipment state updates
---   - User error message display
---
--- @param spell table The spell that failed to cast
--- @param eventArgs table Event arguments for state management
function SpellUtils.handle_unable_to_cast(spell, eventArgs)
    if not SpellUtils.try_cast_spell(spell, eventArgs) then
        cancel_spell()
        eventArgs.handled = true

        -- Call job-specific equipment handling if available
        if job_handle_equipping_gear then
            job_handle_equipping_gear(player.status, eventArgs)
        end

        MessageUtils.status_message('error', 'Cannot cast ' .. spell.name)
    end
end

---============================================================================
--- COOLDOWN MANAGEMENT
---============================================================================

--- Check spell recast timers and display cooldown information to user.
--- Provides real-time feedback on spell availability and recast status
--- with intelligent filtering for spells that should be ignored.
---
--- @param spell table The spell being checked for cooldown
--- @param eventArgs table Event arguments for context
function SpellUtils.check_display_cooldown(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' then
        log.error("Invalid parameters for check_display_cooldown")
        return
    end

    -- Validate spell structure
    local requiredKeys = { 'name', 'type', 'action_type', 'id' }
    for _, key in ipairs(requiredKeys) do
        if not spell[key] then
            log.error("Spell does not have required key: %s", key)
            return
        end
    end

    -- Exclude Quick Draw, Sic, Ready from cooldown checks
    local excluded_ids = { 124, 72, 251 }
    for _, id in ipairs(excluded_ids) do
        if spell.id == id then
            return
        end
    end

    -- Check if spell should be ignored
    local ignoredOrSpecialTypes = false
    for _, ignored in ipairs(SpellUtils.ignoredSpells) do
        if spell.name == ignored then
            ignoredOrSpecialTypes = true
            break
        end
    end

    ignoredOrSpecialTypes = ignoredOrSpecialTypes or
        spell.skill == 'Elemental Magic' or
        spell.type == 'Scholar' or
        spell.action_type == 'Weapon Skill'

    if ignoredOrSpecialTypes then return end

    -- Get cooldown based on action type
    local recast = 0

    if spell.action_type == 'Magic' then
        local recasts = windower.ffxi.get_spell_recasts()
        if recasts and recasts[spell.id] then
            recast = recasts[spell.id] / 60
        end
    elseif spell.action_type == 'Ability' then
        local recasts = windower.ffxi.get_ability_recasts()
        if recasts and recasts[spell.recast_id] then
            recast = recasts[spell.recast_id]
        end
    end

    -- Display cooldown if on recast
    if recast and recast > 0 then
        cancel_spell()
        MessageUtils.cooldown_message(spell.name, recast)
        eventArgs.handled = true
    end
end

-- ===========================================================================================================
--                                     Spell Refinement (Utsusemi)
-- ===========================================================================================================

--- Refines the casting of Utsusemi spells based on their cooldown status.
-- @param spell (table): The spell that the player is casting.
-- @param eventArgs (table): Additional event arguments.
function SpellUtils.refine_utsusemi(spell, eventArgs)
    if not spell or type(spell) ~= 'table' or not spell.name then
        log.error('Invalid spell: spell must be a table with a name field')
        return
    end

    if not eventArgs or type(eventArgs) ~= 'table' then
        log.error('Invalid eventArgs: eventArgs must be a table')
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then
        log.error('Failed to get spell recasts')
        return
    end

    local NiCD = spell_recasts[339] or 0
    local IchiCD = spell_recasts[338] or 0

    if spell.name == 'Utsusemi: Ni' then
        if NiCD > 1 then
            eventArgs.cancel = true

            if IchiCD < 1 then
                cancel_spell()
                cast_delay(1.1)
                send_command('input /ma "Utsusemi: Ichi" <me>')
            else
                MessageUtils.status_message('error', "Neither Utsusemi spell is ready!")
            end
        end
    elseif spell.name == 'Utsusemi: Ichi' then
        if IchiCD > 1 then
            eventArgs.cancel = true
        end
    end
end

-- ===========================================================================================================
--                                     Spell Event Handlers
-- ===========================================================================================================

--- Handles spell casting with auto-ability support.
-- @param spell (table): The spell to attempt to cast.
-- @param eventArgs (table): Additional event arguments.
-- @param auto_abilities (table): A table mapping spell names to functions.
function SpellUtils.handle_spell(spell, eventArgs, auto_abilities)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' then
        log.error("Invalid parameters for handle_spell")
        return
    end

    if not eventArgs.handled and SpellUtils.try_cast_spell(spell, eventArgs) then
        if auto_abilities and type(auto_abilities) == 'table' then
            local auto_ability_function = auto_abilities[spell.name]
            if auto_ability_function and type(auto_ability_function) == 'function' then
                local success, err = pcall(auto_ability_function, spell, eventArgs)
                if not success then
                    log.error("Error in auto_ability_function: %s", tostring(err))
                end
            end
        end
    end
end

--- Automatically casts an ability before a spell if possible.
-- @param spell (table): The spell to attempt to cast.
-- @param eventArgs (table): Additional event arguments.
-- @param abilityId (number): The ID of the ability to use before the spell.
-- @param waitTime (number): The time to wait after using the ability.
-- @param abilityName (string): The name of the ability to use before the spell.
function SpellUtils.auto_ability(spell, eventArgs, abilityId, waitTime, abilityName)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or
        type(abilityId) ~= 'number' or type(waitTime) ~= 'number' or
        type(abilityName) ~= 'string' then
        log.error("Invalid parameters for auto_ability")
        return
    end

    if SpellUtils.try_cast_spell(spell, eventArgs) then
        local abilityCooldown = 0
        local recasts = windower.ffxi.get_ability_recasts()
        if recasts and recasts[abilityId] then
            abilityCooldown = recasts[abilityId]
        end

        if abilityCooldown < 1 and not buffactive[abilityName] then
            cancel_spell()
            send_command(string.format(
                'input /ja "%s" <me>; wait %f; input /ma %s %s',
                abilityName,
                waitTime,
                spell.name,
                spell.target.id
            ))
        end
    else
        SpellUtils.handle_unable_to_cast(spell, eventArgs)
    end
end

--- Handles an interrupted spell event.
-- @param spell (table): The spell that was interrupted.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if successful, false otherwise.
function SpellUtils.handle_interrupted_spell(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or type(spell.name) ~= 'string' then
        return false
    end

    -- Call job-specific equipment handling
    if job_handle_equipping_gear then
        local success = pcall(job_handle_equipping_gear, player.status, eventArgs)
        if not success then
            return false
        end
    end

    -- Suppress default messages and handle with our custom function
    eventArgs.handled = true
    MessageUtils.spell_interrupted_message(spell)

    return true
end

--- Handles actions after a spell has been cast.
-- @param spell (table): The spell that has been cast.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if successful, false otherwise.
function SpellUtils.handle_spell_aftercast(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if spell.interrupted then
        return SpellUtils.handle_interrupted_spell(spell, eventArgs)
    else
        -- Handle movement speed gear if configured
        if state and state.Moving and state.Moving.value == 'true' then
            send_command('gs equip sets.MoveSpeed')
        end

        return true
    end
end

-- ===========================================================================================================
--                                     Spell Casting Commands
-- ===========================================================================================================

--- Casts an elemental spell.
-- @param mainSpell (string): The name of the main spell to cast.
-- @param tier (string or nil): The tier of the spell to cast.
function SpellUtils.cast_elemental_spell(mainSpell, tier)
    if type(mainSpell) ~= 'string' or mainSpell == '' then
        log.error('Invalid mainSpell parameter')
        return
    end

    if tier ~= nil and type(tier) ~= 'string' then
        log.error('Invalid tier parameter')
        return
    end

    local spell = mainSpell
    if tier and tier ~= '' then
        spell = spell .. ' ' .. tier
    end

    send_command('input /ma "' .. spell .. '" <stnpc>')
end

--- Casts a Scholar spell with the appropriate arts and addendum.
-- @param spell (string): The name of the spell to cast.
-- @param arts (string): The name of the art to use.
-- @param addendum (string): The name of the addendum to use.
function SpellUtils.cast_sch_spell(spell, arts, addendum)
    if type(spell) ~= 'string' or type(arts) ~= 'string' or type(addendum) ~= 'string' then
        log.error("Invalid parameters for cast_sch_spell")
        return
    end

    local delay = (spell == 'Sneak' or spell == 'Invisible') and 1 or 2.1

    -- Get current target
    local target = windower.ffxi.get_mob_by_target('t')
    local targetid = target and target.id or '<me>'

    local command
    if buffactive[addendum] then
        command = 'input /ma "' .. spell .. '" ' .. tostring(targetid)
    elseif buffactive[arts] and not buffactive[addendum] then
        -- Check if stratagems are available
        local strat_count = 0
        if windower.ffxi.get_ability_recasts()[231] == 0 then
            strat_count = 1
        end

        if strat_count > 0 then
            command = 'input /ja "' .. addendum .. '" <me>; wait 2; input /ma "' .. spell .. '" ' .. tostring(targetid)
        else
            MessageUtils.status_message('error', "No stratagems available")
            return
        end
    else
        MessageUtils.status_message('error', "Need " .. arts .. " active")
        return
    end

    send_command(command)
end

return SpellUtils
