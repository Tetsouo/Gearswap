---============================================================================
--- FFXI GearSwap Core Module - Spell Management and Validation Utilities
---============================================================================
--- Comprehensive spell handling system for GearSwap automation.
--- Provides spell validation, incapacitation checking, cooldown management,
--- and safe casting utilities for reliable spell execution.
---
--- @file core/spells.lua
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
---   local SpellUtils = require('core/SPELLS')
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
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

--- @type table Logging utilities for error reporting and debugging
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

--- @type table Message formatting utilities for user feedback
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

--- @type table Validation utilities for parameter checking
local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return false
    end

    if not ValidationUtils.validate_spell(spell) then
        return false
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return false
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return false
    end

    -- Exclude Quick Draw and pet commands Sic, Ready from cooldown checks
    -- Check by name instead of hardcoded IDs for better maintainability
    local excluded_abilities = { 'Quick Draw', 'Sic', 'Ready' }
    for _, ability_name in ipairs(excluded_abilities) do
        if spell.name == ability_name then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return false, "Invalid spell parameter"
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return false, "Invalid spell parameter"
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return false, "Invalid eventArgs parameter"
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return false, "Invalid eventArgs parameter"
    end

    if not spell.action_type or not spell.name then
        return false, "Invalid spell structure"
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return false
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return false
    end

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return
    end

    if not SpellUtils.try_cast_spell(spell, eventArgs) then
        cancel_spell()
        eventArgs.handled = true

        -- Call job-specific equipment handling if available
        if job_handle_equipping_gear then
            job_handle_equipping_gear(player.status, eventArgs)
        end

        local spell_name = spell.name or 'Unknown Spell'
        MessageUtils.status_message('error', 'Cannot cast ' .. spell_name)
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
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
    -- Check by name instead of hardcoded IDs for better maintainability
    local excluded_abilities = { 'Quick Draw', 'Sic', 'Ready' }
    for _, ability_name in ipairs(excluded_abilities) do
        if spell.name == ability_name then
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

    -- Special exceptions for important self-buff spells that should show cooldown
    local importantBuffSpells = {
        'Cocoon', 'Stoneskin', 'Aquaveil', 'Blink', 'Phalanx',
        'Protect', 'Shell', 'Haste', 'Refresh', 'Regen', 'Cure', 'Sleep'
    }
    local isImportantBuff = false
    for _, important in ipairs(importantBuffSpells) do
        if spell.name:find(important) then
            isImportantBuff = true
            break
        end
    end

    -- Skip cooldown check for certain types, BUT allow important buff spells
    ignoredOrSpecialTypes = ignoredOrSpecialTypes or
        (spell.skill == 'Elemental Magic' and not isImportantBuff) or
        spell.type == 'Scholar' or
        spell.action_type == 'Weapon Skill'

    if ignoredOrSpecialTypes then return end

    -- Get cooldown based on action type
    local recast = 0

    if spell.action_type == 'Magic' then
        local recasts = windower.ffxi.get_spell_recasts()
        if recasts and recasts[spell.recast_id] then
            -- IMPORTANT: get_spell_recasts() returns centiseconds (1/100th), convert to seconds
            recast = recasts[spell.recast_id] / 100
        end
    elseif (spell.english == 'Utsusemi: Ni' or spell.english == 'Utsusemi: Ichi') then
        -- Special case: Utsusemi spells might not have action_type='Magic' for subjobs
        local recasts = windower.ffxi.get_spell_recasts()
        if recasts and recasts[spell.recast_id] then
            -- Convert from centiseconds to seconds
            recast = recasts[spell.recast_id] / 100
        end
    elseif spell.action_type == 'Ability' then
        local recasts = windower.ffxi.get_ability_recasts()
        if recasts and recasts[spell.recast_id] then
            recast = recasts[spell.recast_id] -- Already in seconds
        end
    end

    -- Check if buff is already active (for abilities/spells that create buffs)
    -- SKIP Utsusemi - we want to allow refreshing shadows even when Copy Image is active
    -- SKIP RUN Runes - we want to allow stacking multiple runes (up to 3)
    local isBuffActive = false

    local runRunes = {
        'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda', 'Lux', 'Tenebrae'
    }

    local isRuneSpell = false
    for _, rune in ipairs(runRunes) do
        if spell.name == rune then
            isRuneSpell = true
            break
        end
    end

    if not (spell.name == 'Utsusemi: Ni' or spell.name == 'Utsusemi: Ichi' or spell.name == 'Utsusemi: San' or isRuneSpell) then
        if spell.action_type == 'Ability' then
            -- Standard case for abilities - spell name matches buff name
            isBuffActive = buffactive[spell.name]
        elseif spell.action_type == 'Magic' then
            -- Magic spells that create buffs with same name (only for long recast spells)
            local magic_buff_spells = {
                'Reprisal' -- Long recast, should show "Active" when up
                -- Phalanx, Stoneskin, Blink removed - short recast, need refreshing
            }
            for _, buff_spell in ipairs(magic_buff_spells) do
                if spell.name == buff_spell then
                    isBuffActive = buffactive[spell.name]
                    break
                end
            end
        end
    end

    if isBuffActive then
        -- Set handled BEFORE canceling to prevent interrupted message
        eventArgs.handled = true
        -- Display active message using unified system with job name
        local messages = { { type = 'active', name = spell.name } }
        MessageUtils.unified_status_message(messages, nil, true)
        -- Then cancel the spell/ability
        cancel_spell()
        return
    end


    -- Display cooldown if on recast
    if recast and recast > 0 then
        -- Special case for Utsusemi - only show recast if BOTH are on cooldown
        if spell.name == 'Utsusemi: Ni' or spell.name == 'Utsusemi: Ichi' or spell.name == 'Utsusemi: San' then
            local spell_recasts = windower.ffxi.get_spell_recasts()
            local success_res, res = pcall(require, 'resources')
            if not success_res then
                error("Failed to load resources: " .. tostring(res))
            end

            -- Get spell IDs dynamically
            local ni_spell = res.spells:with('en', 'Utsusemi: Ni')
            local ichi_spell = res.spells:with('en', 'Utsusemi: Ichi')
            local ni_id = ni_spell and ni_spell.id or 339
            local ichi_id = ichi_spell and ichi_spell.id or 338

            -- Convert from centiseconds to seconds (spell recasts are in centiseconds!)
            local ni_recast = (spell_recasts[ni_id] or 0) / 100
            local ichi_recast = (spell_recasts[ichi_id] or 0) / 100

            -- Only show message if BOTH are on cooldown
            if ni_recast > 0 and ichi_recast > 0 then
                -- Set handled BEFORE canceling to prevent interrupted message
                eventArgs.handled = true

                -- Use unified message system like before modernization
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end
                local messages = {
                    { type = 'recast', name = 'Utsusemi: Ni',   time = ni_recast },
                    { type = 'recast', name = 'Utsusemi: Ichi', time = ichi_recast }
                }
                MessageUtils.unified_status_message(messages, 'THF', true)

                -- Then cancel the spell
                cancel_spell()
            end
            -- If only one is on recast, don't show message (let refine_utsusemi handle the switch)
        else
            -- Standard recast handling for non-Utsusemi spells
            -- Set a flag to indicate this was a cooldown cancel, not an interruption
            _G.cooldown_cancel_in_progress = true
            -- Set handled BEFORE canceling to prevent interrupted message
            eventArgs.handled = true

            -- Display cooldown message using unified system
            local messages = { { type = 'recast', name = spell.name, time = recast } }
            MessageUtils.unified_status_message(messages, nil, true)

            -- Then cancel the spell
            cancel_spell()
            -- Clear the flag after a small delay
            coroutine.schedule(function()
                _G.cooldown_cancel_in_progress = nil
            end, 0.1)
        end
    end
end

-- ===========================================================================================================
--                                     Spell Refinement (Utsusemi)
-- ===========================================================================================================

--- Refines the casting of Utsusemi spells based on their cooldown status.
-- @param spell (table): The spell that the player is casting.
-- @param eventArgs (table): Additional event arguments.
function SpellUtils.refine_utsusemi(spell, eventArgs)
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return
    end

    if not spell.name then
        log.error('Spell must have a name field')
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    if not spell_recasts then
        log.error('Failed to get spell recasts')
        return
    end

    -- Get spell IDs dynamically from resources
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local ni_spell = res.spells:with('en', 'Utsusemi: Ni')
    local ichi_spell = res.spells:with('en', 'Utsusemi: Ichi')

    local NiCD = spell_recasts[ni_spell and ni_spell.id or 339] or 0
    local IchiCD = spell_recasts[ichi_spell and ichi_spell.id or 338] or 0

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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return
    end

    if auto_abilities ~= nil and not ValidationUtils.validate_type(auto_abilities, 'table', 'auto_abilities') then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return
    end

    if not ValidationUtils.validate_not_nil(abilityId, 'abilityId') then
        return
    end

    if not ValidationUtils.validate_type(abilityId, 'number', 'abilityId') then
        return
    end

    if not ValidationUtils.validate_not_nil(waitTime, 'waitTime') then
        return
    end

    if not ValidationUtils.validate_type(waitTime, 'number', 'waitTime') then
        return
    end

    if not ValidationUtils.validate_not_nil(abilityName, 'abilityName') then
        return
    end

    if not ValidationUtils.validate_string_not_empty(abilityName, 'abilityName') then
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
    -- SA/TA messages are handled in job_precast, no need for custom interruption handling

    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return false
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return false
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return false
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return false
    end

    if not spell.name or not ValidationUtils.validate_type(spell.name, 'string', 'spell.name') then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return false
    end

    if not ValidationUtils.validate_type(spell, 'table', 'spell') then
        return false
    end

    if not ValidationUtils.validate_not_nil(eventArgs, 'eventArgs') then
        return false
    end

    if not ValidationUtils.validate_type(eventArgs, 'table', 'eventArgs') then
        return false
    end

    if not spell.name then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(mainSpell, 'mainSpell') then
        return
    end

    if not ValidationUtils.validate_string_not_empty(mainSpell, 'mainSpell') then
        return
    end

    if tier ~= nil and not ValidationUtils.validate_type(tier, 'string', 'tier') then
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
    -- Parameter validation using ValidationUtils
    if not ValidationUtils.validate_not_nil(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_string_not_empty(spell, 'spell') then
        return
    end

    if not ValidationUtils.validate_not_nil(arts, 'arts') then
        return
    end

    if not ValidationUtils.validate_string_not_empty(arts, 'arts') then
        return
    end

    if not ValidationUtils.validate_not_nil(addendum, 'addendum') then
        return
    end

    if not ValidationUtils.validate_string_not_empty(addendum, 'addendum') then
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
        -- Check if stratagems are available using proper Scholar utils
        local success_ScholarUtils, ScholarUtils = pcall(require, 'utils/SCHOLAR')
        if not success_ScholarUtils then
            error("Failed to load utils/scholar: " .. tostring(ScholarUtils))
        end
        local strat_count = ScholarUtils.get_available_stratagem_count()

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
