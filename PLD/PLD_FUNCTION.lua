--============================================================--
--=                    PLD_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024-01-28                  =--
--============================================================--

-- Constants used throughout the script
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
            auto_ability(spell, eventArgs, constants.ABILITY_IDS.MAJESTY, "2", 'Majesty')
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
        auto_ability(spell, eventArgs, constants.ABILITY_IDS.DIVINE_EMBLEM, "2", 'Divine Emblem')
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
    -- If the spell is not 'Cure III' or 'Cure IV', return nil
    if spell.name ~= 'Cure III' and spell.name ~= 'Cure IV' then
        return nil
    end

    -- Define the base set of equipment
    local base_set = sets.Cure

    -- Define the cure sets for self and other targets
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
    local conditions, setTable = get_conditions_and_sets(sets.idleXp, sets.idle.PDT, nil, sets.idle.MDT)
    return customize_set(idleSet, conditions, setTable)
end

-- This function customizes the melee set based on the current state.
-- It uses the `customize_set_based_on_state` function to select the appropriate set.
-- @param meleeSet The base melee set. It should be a table.
-- @return The customized melee set.
function customize_melee_set(meleeSet)
    -- Call `customize_set_based_on_state` with the base melee set, the XP melee set, the PDT engaged set, and the MDT defense set
    -- The function will select the appropriate set based on the current state
    local conditions, setTable = get_conditions_and_sets(sets.meleeXp, sets.engaged.PDT, nil, sets.engaged.MDT)
    return customize_set(meleeSet, conditions, setTable)
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

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
-- Handles custom commands specific to the job.
-- It updates the altState object, handles a set of predefined commands, and handles job-specific and subjob-specific commands.
-- @param cmdParams (table): The command parameters. The first element is expected to be the command name.
-- @param eventArgs (table): Additional event arguments.
-- @param spell (table): The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the altState object
    update_altState()
    local command = cmdParams[1]:lower()

    -- If the command is defined, execute it
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- Handle PLD-specific commands

        -- Handle subjob-specific commands
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end
