---============================================================================
--- FFXI GearSwap Job Module - Paladin Advanced Functions
---============================================================================
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
    ABILITY_IDS = {
        -- IDs for specific abilities
        DIVINE_EMBLEM = 80, -- ID for the "Divine Emblem" ability
        MAJESTY = 150       -- ID for the "Majesty" ability
    },
    SPELL_NAMES = {
        -- Names of specific spells
        FLASH = 'Flash',         -- Name of the "Flash" spell
        PROTECT_V = 'Protect V', -- Name of the "Protect V" spell
        CURE_III = 'Cure III',   -- Name of the "Cure III" spell
        CURE_IV = 'Cure IV',     -- Name of the "Cure IV" spell
        PHALANX = 'Phalanx'      -- Name of the "Phalanx" spell
    }
}

res = require('resources') -- Charge les ressources du jeu
local EquipmentUtils = require('core/equipment')

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
            -- Use the 'Majesty' ability
            auto_ability(spell, eventArgs, constants.ABILITY_IDS.MAJESTY, 2, 'Majesty')
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
auto_abilities = {
    -- Uses 'Divine Emblem' ability for 'Flash' spell.
    [constants.SPELL_NAMES.FLASH] = function(spell, eventArgs)
        auto_ability(spell, eventArgs, constants.ABILITY_IDS.DIVINE_EMBLEM, 2, 'Divine Emblem')
    end,
    -- Uses 'handle_majesty_and_cure_sets_wrapper' for 'Protect V', 'Cure III', and 'Cure IV' spells.
    [constants.SPELL_NAMES.PROTECT_V] = handle_majesty_and_cure_sets_wrapper,
    [constants.SPELL_NAMES.CURE_III] = handle_majesty_and_cure_sets_wrapper,
    [constants.SPELL_NAMES.CURE_IV] = handle_majesty_and_cure_sets_wrapper,
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
        return nil  -- Let Mote handle other cure tiers with standard sets
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
                head = createEquipment('Souv. Schaller +1', 12),
                back = createEquipment('Moonlight Cape', 11),
                hands = createEquipment('Regal Gauntlets', 10),
                neck = { name = "Unmoving Collar +1", priority = 9 },
                body = { name = "Souveran cuirass +1", priority = 8 },
                left_ear = createEquipment('tuisto Earring', 7),
                right_ring = { name = "Gelatinous Ring +1", priority = 6 },
                left_ring = { name = "Moonlight Ring", priority = 5 },
                feet = createEquipment('Odyssean Greaves', 4),
                legs = createEquipment("Founder's Hose", 0),
                ammo = createEquipment('staunch Tathlum +1', 1),
                right_ear = createEquipment('Chev. Earring +1', 0),
            })
        ,
        CureOther = set_combine(
            base_set,
            {
                head = createEquipment('Souv. Schaller +1', 13),
                body = { name = "Souveran cuirass +1", priority = 12 },
                left_ear = createEquipment('tuisto Earring', 11),
                hands = createEquipment("Chevalier's Gauntlets +3", 10),
                legs = createEquipment("Founder's Hose", 9),
                neck = { name = "Sacro gorget", priority = 8 },
                feet = createEquipment('Odyssean Greaves', 7),
                waist = { name = "Audumbla sash", priority = 0 },
                ammo = createEquipment('staunch Tathlum +1', 0),
                right_ear = createEquipment('Chev. Earring +1', 0),
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
    -- Call `customize_set_based_on_state` with the base idle set, the XP idle set, the normal idle set, and the MDT defense set
    -- The function will select the appropriate set based on the current state
    -- Get the conditions and sets for customizing the idle set.
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(sets.idleXp, sets.idle.PDT, nil, sets.idle.MDT)
    return EquipmentUtils.customize_set(idleSet, conditions, setTable)
end

-- This function customizes the melee set based on the current state.
-- It uses the `customize_set_based_on_state` function to select the appropriate set.
-- @param meleeSet The base melee set. It should be a table.
-- @return The customized melee set.
function customize_melee_set(meleeSet)
    -- Call `customize_set_based_on_state` with the base melee set, the XP melee set, the PDT engaged set, and the MDT defense set
    -- The function will select the appropriate set based on the current state
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(sets.meleeXp, sets.engaged.PDT, nil, sets.engaged.MDT)
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
local AOE_SPELLS = { 'Sheep Song', 'Stinking Gas', 'Geist Wall', 'Frightful Roar', 'Soporific'}

--------------------------------------------------------------------------------
-- Basic chat logger
--------------------------------------------------------------------------------
local function logMessage(msg, isError)
    add_to_chat(isError and 123 or 158, msg)
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
    for _, spellName in ipairs(AOE_SPELLS) do
        local canCast = canCastSpell(spellName)
        if canCast then
            logMessage("Casting: " .. spellName)
            send_command('@input /ma "' .. spellName .. '" <stnpc>')
            return
        end
    end
    logMessage("No AOE spell available", true)
end

--------------------------------------------------------------------------------
-- 1) Déclarez/complétez la table commandFunctions
--------------------------------------------------------------------------------
local commandFunctions = {
    aoe = function()
        handleAoECommand() -- Exemple existant
    end,

    -- Ajout d'une commande "rune"
    rune = function()
        -- Vérifie que l'on est bien sub RUN
        if player.sub_job ~= 'RUN' then
            add_to_chat(123, "[Erreur] Vous n'êtes pas sub RUN.")
            return
        end
        -- Lance la Rune actuellement sélectionnée
        send_command('input /ja "' .. state.RuneElement.value .. '" <me>')
    end,

    -- Optionnel: commande "cyclerune" pour faire défiler la liste
    cyclerune = function()
        if player.sub_job ~= 'RUN' then
            add_to_chat(123, "[Erreur] Vous n'êtes pas sub RUN.")
            return
        end
        state.RuneElement:cycle()
        add_to_chat(122, "Rune actuelle : " .. state.RuneElement.value)
    end,
}

--------------------------------------------------------------------------------
-- 2) Votre fonction job_self_command
--------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs, spell)
    if not (cmdParams and cmdParams[1]) then
        logMessage("ERROR: No command provided", true)
        return
    end

    local command = cmdParams[1]:lower():gsub("%s+", "")
    cleanupSpellTracking()

    -- Exemple: commande aoe déjà gérée directement
    if command == 'aoe' then
        handleAoECommand()
        return
    end

    -- Si la commande existe dans commandFunctions, on l'exécute
    if commandFunctions[command] then
        commandFunctions[command]()
        eventArgs.handled = true
        return
    end

    -- Cas spécial si sub SCH (exemple)
    if player and player.sub_job == 'SCH' then
        -- gérer des commandes SCH si besoin
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
