---============================================================================
--- FFXI GearSwap Job Module - Paladin Advanced Functions
---============================================================================

-- Load critical dependencies
-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
--- Professional Paladin job-specific functionality providing intelligent
--- tanking optimization, spell casting management, enmity control, and
--- advanced defensive combat automation. Core features include:
---
--- • **Intelligent Enmity Management** - Flash timing and threat generation
--- • **Spell Casting Optimization** - Cure potency and enhancing magic efficiency
--- • **Divine/Majesty Integration** - Job ability timing for spell enhancement
--- • **Hybrid Defense Modes** - PDT/MDT switching based on encounter type
--- • **Phalanx Management** - Automatic Phalanx casting and gear optimization
--- • **Shield Mastery** - Shield block rate and damage reduction optimization
--- • **MP Conservation** - Efficient spell usage and mana management
--- • **Error Recovery Systems** - Robust handling of spell interruptions
---
--- This module implements the advanced tanking algorithms that make PLD
--- automation intelligent and reliable, handling complex enmity management
--- and spell casting coordination with comprehensive error handling.
---
--- @file jobs/pld/PLD_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires resources.lua, Windower FFXI, GearSwap addon
--- @requires config/config.lua for PLD-specific settings
---
--- @usage
---   handle_phalanx_while_xp(spell, eventArgs) -- XP mode Phalanx handling
---   [Additional PLD functions as implemented]
---
--- @see jobs/pld/PLD_SET.lua for tanking and spell casting equipment sets
--- @see Tetsouo_PLD.lua for job configuration and defensive mode management
---============================================================================

---============================================================================
--- PALADIN JOB CONSTANTS AND CONFIGURATION
---============================================================================

--- Job-specific constants for Paladin abilities, spells, and mechanics
--- Centralizes all magic numbers and spell/ability IDs for maintainability
--- @type table<string, any> PLD constants including ability IDs and spell names
local constants = {
    ACTION_TYPE_MAGIC = 'Magic',               -- Action type for magic spells
    SKILL_HEALING_MAGIC = 'Healing Magic',     -- Skill type for healing spells
    SKILL_ENHANCING_MAGIC = 'Enhancing Magic', -- Skill type for enhancing spells
    SPELL_NAMES = {
        -- Names of specific spells
        FLASH = 'Flash',             -- Name of the "Flash" spell
        PROTECT_III = 'Protect III', -- Name of the "Protect III" spell
        PROTECT_IV = 'Protect IV',   -- Name of the "Protect IV" spell
        PROTECT_V = 'Protect V',     -- Name of the "Protect V" spell
        CURE_III = 'Cure III',       -- Name of the "Cure III" spell
        CURE_IV = 'Cure IV',         -- Name of the "Cure IV" spell
        PHALANX = 'Phalanx'          -- Name of the "Phalanx" spell
    }
}

local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end
local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
if not success_EquipmentUtils then
    error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
end

--- Wrapper function for `handle_majesty_and_cure_sets`.
-- This function checks if `spell` and `eventArgs` are tables, and if so, it calls `handle_majesty_and_cure_sets` in a protected environment using `pcall`.
-- If `pcall` returns `false`, indicating that an error occurred in `handle_majesty_and_cure_sets`, it asserts `false` and includes the error message in the assertion.
-- @function handle_majesty_and_cure_sets_wrapper
-- @tparam table spell The spell to handle. Must be a table.
-- @tparam table eventArgs The event arguments. Must be a table.
-- @treturn nil This function does not return a value.
function handle_majesty_and_cure_sets_wrapper(spell, eventArgs)
    -- Assert that spell and eventArgs are tables
    assert(type(spell) == 'table', "Error: spell must be a table")
    assert(type(eventArgs) == 'table', "Error: eventArgs must be a table")

    -- Use pcall to safely call handle_majesty_and_cure_sets
    local status, error = pcall(handle_majesty_and_cure_sets, spell, eventArgs)

    -- If pcall returned false, an error occurred in handle_majesty_and_cure_sets
    if not status then
        assert(false, "Error in handle_majesty_and_cure_sets: " .. tostring(error))
    end
end

-- This function automatically uses the 'Majesty' ability for spells that are magic actions and have 'Healing Magic' or 'Enhancing Magic' as their skill.
-- It also equips the appropriate cure set for 'Cure III' and 'Cure IV' spells.
-- @param spell The spell object to attempt to cast. It should be a table with `action_type` and `skill` fields.
-- @param eventArgs The event arguments object. It should have a `handled` field.
function handle_majesty_and_cure_sets(spell, eventArgs)
    -- Try to cast the spell
    if try_cast_spell(spell, eventArgs) then
        -- If the spell is a magic action and its skill is either 'Healing Magic' or 'Enhancing Magic'
        if
            spell.action_type == constants.ACTION_TYPE_MAGIC and
            (spell.skill == constants.SKILL_HEALING_MAGIC or spell.skill == constants.SKILL_ENHANCING_MAGIC)
        then
            -- Use the 'Majesty' ability - get ID dynamically
            local majesty_data = res.job_abilities:with('en', 'Majesty')
            local majesty_id = majesty_data and majesty_data.id
            auto_ability(spell, eventArgs, majesty_id, 2, 'Majesty')
        end

        -- If the spell is 'Cure III' or 'Cure IV'
        if spell.name == constants.SPELL_NAMES.CURE_III or spell.name == constants.SPELL_NAMES.CURE_IV then
            -- Determine the target type
            local target_type = spell.target.type == 'SELF' and 'SELF' or 'OTHER'
            -- Generate the appropriate cure set
            local cure_set = generate_cure_set(spell, target_type)
            -- Equip the cure set
            equip(cure_set)
        end
    end
end

--- Maps spells to their corresponding automatic abilities.
-- @table auto_abilities
local success_H, H = pcall(require, 'utils/ABILITY_HELPER')
if not success_H then
    error("Failed to load utils/ability_helper: " .. tostring(H))
end

auto_abilities = {
    [constants.SPELL_NAMES.FLASH] = function(spell, eventArgs)
        H.try_ability(spell, eventArgs, 'Divine Emblem', 2)
    end,
    [constants.SPELL_NAMES.PROTECT_III] = function(spell, eventArgs)
        H.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    [constants.SPELL_NAMES.PROTECT_IV] = function(spell, eventArgs)
        H.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    [constants.SPELL_NAMES.PROTECT_V] = function(spell, eventArgs)
        H.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    [constants.SPELL_NAMES.CURE_III] = function(spell, eventArgs)
        H.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
    [constants.SPELL_NAMES.CURE_IV] = function(spell, eventArgs)
        H.try_ability_smart(spell, eventArgs, 'Majesty', 2)
    end,
}


-- This function generates a cure set for 'Cure III' or 'Cure IV' spells.
-- The cure set is different depending on whether the target is the caster or another player.
-- The generated set is assigned to `sets.midcast.Cure`.
-- @param spell The spell object. It should be a table with a `name` field.
-- @param target_type The type of the target. It should be either 'SELF' or 'OTHER'.
-- @return The generated cure set.
function generate_cure_set(spell, target_type)
    -- ═══════════════════════════════════════════════════════════════════════════
    -- DYNAMIC CURE SET GENERATION FOR HIGH-TIER CURES
    -- ═══════════════════════════════════════════════════════════════════════════
    -- This function creates specialized cure sets for Cure III/IV based on target:
    -- • Self-targeting: Emphasizes survivability (PDT, HP+, regen)
    -- • Other-targeting: Maximizes cure potency and healing power

    -- ───────────────────────────────────────────────────────────────────────
    -- VALIDATION: Only process high-tier cures that benefit from specialization
    -- ───────────────────────────────────────────────────────────────────────
    if spell.name ~= 'Cure III' and spell.name ~= 'Cure IV' then
        return nil -- Let Mote handle other cure tiers with standard sets
    end

    -- ───────────────────────────────────────────────────────────────────────
    -- BASE SET: Start with standard cure equipment
    -- This provides MND, cure potency, and basic healing optimization
    -- ───────────────────────────────────────────────────────────────────────
    local base_set = sets.Cure

    -- ───────────────────────────────────────────────────────────────────────
    -- SPECIALIZED SET DEFINITIONS
    -- Two distinct approaches based on healing target and tactical needs
    -- ───────────────────────────────────────────────────────────────────────
    local cure_sets = {
        CureSelf = set_combine(
            base_set,
            {
                waist = { name = "Plat. Mog. Belt", priority = 13 },
                head = EquipmentFactory.create('Souv. Schaller +1', 12),
                back = EquipmentFactory.create('Moonlight Cape', 11),
                hands = EquipmentFactory.create('Regal Gauntlets', 10),
                neck = { name = "Unmoving Collar +1", priority = 9 },
                body = { name = "Souveran cuirass +1", priority = 8 },
                left_ear = EquipmentFactory.create('tuisto Earring', 7),
                right_ring = { name = "Gelatinous Ring +1", priority = 6 },
                left_ring = { name = "Moonlight Ring", priority = 5 },
                feet = EquipmentFactory.create('Odyssean Greaves', 4),
                legs = EquipmentFactory.create("Founder's Hose", 0),
                ammo = EquipmentFactory.create('staunch Tathlum +1', 1),
                right_ear = EquipmentFactory.create('Chev. Earring +1', 0),
            })
        ,
        CureOther = set_combine(
            base_set,
            {
                head = EquipmentFactory.create('Souv. Schaller +1', 13),
                body = { name = "Souveran cuirass +1", priority = 12 },
                left_ear = EquipmentFactory.create('tuisto Earring', 11),
                hands = EquipmentFactory.create("Chevalier's Gauntlets +3", 10),
                legs = EquipmentFactory.create("Founder's Hose", 9),
                neck = { name = "Sacro gorget", priority = 8 },
                feet = EquipmentFactory.create('Odyssean Greaves', 7),
                waist = { name = "Audumbla sash", priority = 0 },
                ammo = EquipmentFactory.create('staunch Tathlum +1', 0),
                right_ear = EquipmentFactory.create('Chev. Earring +1', 0),
                right_ring = { name = "Apeile Ring +1", priority = 0 },
                left_ring = { name = "Apeile Ring +1", priority = 0 },
                back = { name = "Rudianos's Mantle", augments = { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%', }, priority = 0 },
            }
        )
    }

    -- Select the appropriate cure set based on the target type
    local selected_set = target_type == 'SELF' and cure_sets.CureSelf or cure_sets.CureOther

    -- Assign the selected set to `sets.midcast.Cure`
    sets.midcast.Cure = selected_set

    -- Return the selected set
    return sets.midcast.Cure
end

-- This function customizes the idle set based on the current state.
-- It uses the `customize_set_based_on_state` function to select the appropriate set.
-- @param idleSet The base idle set. It should be a table.
-- @return The customized idle set.
function customize_idle_set(idleSet)
    -- Use standardized Town/Dynamis logic with modular customization
    -- Movement is now handled in the standard function
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    return EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        sets.idleXp,    -- XP set
        sets.idle.PDT,  -- PDT set
        sets.idle.MDT   -- MDT set
    )
end

-- This function customizes the melee set based on the current state.
-- It uses the `customize_set_based_on_state` function to select the appropriate set.
-- @param meleeSet The base melee set. It should be a table.
-- @return The customized melee set.
function customize_melee_set(meleeSet)
    -- Call `customize_set_based_on_state` with the base melee set, the XP melee set, the PDT engaged set, and the MDT defense set
    -- The function will select the appropriate set based on the current state
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(sets.meleeXp, sets.engaged.PDT, nil,
        sets.engaged.MDT)
    return EquipmentUtils.customize_set(meleeSet, conditions, setTable)
end

-- This function manages the casting of the 'Phalanx' spell.
-- It attempts to cast the spell using `try_cast_spell`. If the spell can't be cast, it handles the failure using `handle_unable_to_cast`.
-- If the spell can be cast, it adjusts the midcast set based on `state.Xp`.
-- @param spell The spell to be cast.
-- @param eventArgs The event arguments.
-- @return A boolean indicating whether the spell was cast successfully, and the value returned by `try_cast_spell` or `handle_unable_to_cast`.
function handle_phalanx_while_xp(spell, eventArgs)
    -- If the spell was cast and `state.Xp` is true, adjust the midcast set
    if state.Xp and state.Xp.value then
        sets.midcast['Phalanx'] = state.Xp.value == 'True' and sets.midcast.SIRDPhalanx or sets.midcast.PhalanxPotency
    end

    -- Return that the spell was cast successfully
    return true, value
end

-- Enhanced Spell Management (Short Version)

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------
local CONFIG = {
    RECAST_SAFETY_MARGIN = 2, -- Safety window (seconds) to avoid double-cast
    PRECAST_TIMEOUT      = 5, -- Delay (seconds) to detect stuck spells
    RECENT_SPELL_EXPIRY  = 60 -- Expiry (seconds) for recent casts
}

--------------------------------------------------------------------------------
-- Single table for tracking:
-- SpellTracker[spellName] = { timestamp = <last event>, is_casting = <bool> }
--------------------------------------------------------------------------------
local SpellTracker = {}

-- Example AOE spells
local AOE_SPELLS = { 'Sheep Song', 'Stinking Gas', 'Geist Wall', 'Frightful Roar', 'Soporific' }

--------------------------------------------------------------------------------
-- Basic chat logger
--------------------------------------------------------------------------------
local function logMessage(msg, isError)
    local message_type = isError and 'error' or 'info'
    local messages = { { type = message_type, name = 'PLD', message = msg } }
    MessageUtils.unified_status_message(messages, nil, true)
end

--------------------------------------------------------------------------------
-- Cleanup old/stuck spells
--------------------------------------------------------------------------------
local function cleanupSpellTracking()
    local now = os.time()
    for spellName, data in pairs(SpellTracker) do
        if data.is_casting and (now - data.timestamp) > CONFIG.PRECAST_TIMEOUT then
            -- Spell likely stuck; consider it cast
            data.is_casting = false
            data.timestamp = now
        elseif not data.is_casting and (now - data.timestamp) > CONFIG.RECENT_SPELL_EXPIRY then
            -- Remove expired entry
            SpellTracker[spellName] = nil
        end
    end
end

--------------------------------------------------------------------------------
-- Checks if a spell can be cast
--------------------------------------------------------------------------------
local function canCastSpell(spellName)
    local spellData = res.spells:with('en', spellName)
    if not spellData then return false, "unknown_spell" end

    local recasts = windower.ffxi.get_spell_recasts()
    local recast  = recasts[spellData.id] or 0
    local now     = os.time()

    if recast > 0.5 then
        return false, "on_cooldown", recast
    end

    local track = SpellTracker[spellName]
    if track then
        if track.is_casting then
            return false, "still_casting"
        end
        if (now - track.timestamp) < CONFIG.RECAST_SAFETY_MARGIN then
            return false, "recently_cast"
        end
    end

    return true, nil, recast
end

--------------------------------------------------------------------------------
-- Track start/end of spell casting
--------------------------------------------------------------------------------
function track_spell_precast(spell)
    if spell.action_type == 'Magic' then
        cleanupSpellTracking()
        SpellTracker[spell.name] = { timestamp = os.time(), is_casting = true }
    end
end

function track_spell_aftercast(spell)
    if spell.action_type == 'Magic' then
        SpellTracker[spell.name] = { timestamp = os.time(), is_casting = false }
    end
end

--------------------------------------------------------------------------------
-- Action event handler (backup detection if the game says the spell succeeded)
--------------------------------------------------------------------------------
local function onActionEvent(act)
    if act.actor_id ~= player.id or act.category ~= 4 then return end
    for _, target in pairs(act.targets) do
        for _, action in pairs(target.actions) do
            if action.message == 0 then
                local s = res.spells[act.param]
                if s then
                    SpellTracker[s.en] = { timestamp = os.time(), is_casting = false }
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- AOE command: casts first available spell in AOE_SPELLS
--------------------------------------------------------------------------------
local function handleAoECommand()
    cleanupSpellTracking()
    local spellsOnCooldown = {}

    for _, spellName in ipairs(AOE_SPELLS) do
        local canCast, reason, recast = canCastSpell(spellName)
        if canCast then
            -- Create specialized message with proper colors
            -- Use unified status message system
            local messages = { { type = 'info', name = spellName, message = 'Casting' } }
            MessageUtils.unified_status_message(messages, nil, true)
            send_command('@input /ma "' .. spellName .. '" <stnpc>')
            return
        elseif reason == "on_cooldown" and recast then
            -- Collect cooldown information
            table.insert(spellsOnCooldown, { name = spellName, recast = recast })
        end
    end

    -- Display recast information using mutualized system (should handle units correctly)
    if #spellsOnCooldown > 0 then
        -- Use unified status message system for all spells on cooldown
        local messages = {}
        for _, spell in ipairs(spellsOnCooldown) do
            local spell_data = res.spells:with('en', spell.name)
            if spell_data then
                local recasts = windower.ffxi.get_spell_recasts()
                local recast_id = spell_data.recast_id or spell_data.id
                local cooldown = recasts and recasts[recast_id] or 0
                if cooldown > 0 then
                    -- Add to unified message (conversion will be done automatically)
                    table.insert(messages, { type = 'recast', name = spell.name, time = cooldown })
                end
            end
        end

        if #messages > 0 then
            MessageUtils.unified_status_message(messages, nil, true)
        end
    else
        logMessage("No AOE spell available", true)
    end
end

--------------------------------------------------------------------------------
-- 1) Declare/complete the commandFunctions table
--------------------------------------------------------------------------------
local commandFunctions = {
    aoe = function()
        handleAoECommand() -- Exemple existant
    end,

    -- Ajout d'une commande "rune"
    rune = function()
        -- Check that we are indeed sub RUN
        if player.sub_job ~= 'RUN' then
            MessageUtils.pld_rune_message('error_not_run')
            return
        end
        -- Cast the currently selected Rune
        send_command('input /ja "' .. state.RuneElement.value .. '" <me>')
    end,

    -- Optional: "cyclerune" command to cycle through the list
    cyclerune = function()
        if player.sub_job ~= 'RUN' then
            MessageUtils.pld_rune_message('error_not_run')
            return
        end
        state.RuneElement:cycle()
        MessageUtils.pld_rune_message('current_rune', state.RuneElement.value)
        
        -- Update UI when rune changes
        local success_KeybindUI, KeybindUI = pcall(require, 'ui/KEYBIND_UI')
        if success_KeybindUI and KeybindUI then
            KeybindUI.update()
        end
    end,
}

--------------------------------------------------------------------------------
-- 2) Your job_self_command function
--------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs, spell)
    if not (cmdParams and cmdParams[1]) then
        logMessage("ERROR: No command provided", true)
        return
    end

    local command = cmdParams[1]:lower():gsub("%s+", "")
    cleanupSpellTracking()

    -- Try universal commands first (test, modules, cache, metrics, help)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end

    -- Debug commands for troubleshooting
    if command == 'debug' then
        local success_DebugSets, DebugSets = pcall(require, 'debug_sets')
        if not success_DebugSets then
            error("Failed to load debug_sets: " .. tostring(DebugSets))
        end
        if cmdParams[2] then
            DebugSets.debug_command(cmdParams[2])
        else
            DebugSets.test_common_sets()
        end
        return
    end

    -- Example: aoe command already handled directly
    if command == 'aoe' then
        handleAoECommand()
        return
    end

    -- If the command exists in commandFunctions, we execute it
    if commandFunctions[command] then
        commandFunctions[command]()
        eventArgs.handled = true
        return
    end

    -- Special case if sub SCH (example)
    if player and player.sub_job == 'SCH' then
        -- handle SCH commands if needed
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function setup_spell_tracking()
    windower.register_event('action', onActionEvent)
    logMessage("Spell tracking initialized.")
end

setup_spell_tracking()
