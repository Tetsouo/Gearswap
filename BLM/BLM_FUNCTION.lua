--============================================================--
--=                    BLM_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

-- Stores the last cast times for each spell
-- lastCastTimes: A table where the keys are spell names and the values are timestamps of the last cast time
local lastCastTimes = {}

-- spellCorrespondence maps spell names to their downgrade versions.
-- For example, 'Fire' spell can be downgraded from 'VI' to 'V', 'V' to 'IV', etc.
-- This table is used when the current spell version cannot be cast.
spellCorrespondence = {
    Fire = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzard = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aero = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stone = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thunder = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Water = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Sleepga = { ['II'] = { replace = '' } },
    Sleep = { ['II'] = { replace = '' } },
    Aspir = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Firaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aeroga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stonega = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thundaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Waterga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Firaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aeroja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stoneja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thundaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Waterja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } }
}

-- This function manages self-buff spells in the game Final Fantasy XI.
-- It checks the recast time of each spell and if the buff is active.
-- If the buff is not active or is about to expire, it queues the spell to be cast.
function BuffSelf()
    -- Get the current time
    local currentTime = os.time()
    -- Get the recast times for all spells
    local SpellRecasts = windower.ffxi.get_spell_recasts()

    -- Assert that SpellRecasts is a table
    assert(type(SpellRecasts) == "table", "Failed to get spell recasts")

    -- Define the spells to manage
    local spells = {
        { name = 'Stoneskin',  recast = 54,  delay = 0, buffName = 'Stoneskin',  duration = 488 },
        { name = 'Blink',      recast = 53,  delay = 5, buffName = 'Blink',      duration = 488 },
        { name = 'Aquaveil',   recast = 55,  delay = 5, buffName = 'Aquaveil',   duration = 914 },
        { name = 'Ice Spikes', recast = 251, delay = 5, buffName = 'Ice Spikes', duration = 274 }
    }

    -- Initialize the list of spells ready to be cast
    local readySpells = {}
    -- Initialize the total delay for casting spells
    local totalDelay = 0

    -- For each spell
    for _, spell in ipairs(spells) do
        -- Get the recast time for the spell
        spell.recast = SpellRecasts[spell.recast]
        -- Calculate the remaining time for the spell
        local remainingTime = spell.duration - (currentTime - (lastCastTimes[spell.name] or 0))

        -- If the spell duration is greater than 0 and the buff is not active or is about to expire
        if spell.duration > 0 and (not buffactive[spell.buffName] or (buffactive[spell.buffName] and spell.recast < 1 and remainingTime <= 30)) then
            -- Check if the spell is ready to be cast
            if spell.recast == 0 then
                if #readySpells > 0 then
                    -- Increase the total delay
                    totalDelay = totalDelay + spell.delay
                end
                -- Add the spell to the list of spells ready to be cast
                table.insert(readySpells, { spell = spell, delay = totalDelay })
            end
        end
    end

    -- For each spell ready to be cast
    for _, readySpell in ipairs(readySpells) do
        -- Send the command to cast the spell after the delay
        send_command('wait ' .. readySpell.delay .. '; input /ma "' .. readySpell.spell.name .. '" <me>')
        -- Update the last cast time for the spell
        lastCastTimes[readySpell.spell.name] = currentTime
    end
end

--- Handles the replacement of a spell.
-- This function checks if a spell needs to be replaced based on the current recast time and player's MP.
-- If a replacement is needed, it modifies the spell name accordingly.
-- @param spell The spell to be checked for replacement.
-- @param spell_recasts The table containing the recast times for all spells.
-- @param player_mp The current MP of the player.
-- @param correspondence The table containing the correspondence between spells and their replacements.
-- @param spellCategory The category of the spell (e.g., 'Cure', 'Fire', etc.).
-- @param spellLevel The level of the spell (e.g., 'I', 'II', 'III', etc.).
-- @return newSpell The name of the new spell after replacement.
-- @return replacement The name of the replacement spell.
function handle_spell_replacement(spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel)
    assert(spell, "spell cannot be nil")
    assert(spell_recasts, "spell_recasts cannot be nil")
    assert(player_mp, "player_mp cannot be nil")
    assert(spellCategory, "spellCategory cannot be nil")
    assert(spellLevel, "spellLevel cannot be nil")

    local replacement = correspondence and (spellLevel ~= '' and correspondence[spellLevel] or correspondence)
    local newSpell = spell.english

    if replacement and (spell_recasts[spell.recast_id] > 0 or player_mp < spell.mp_cost) then
        replacement = correspondence[spellLevel] and correspondence[spellLevel].replace or ''
        newSpell = replacement == '' and spellCategory or spellCategory .. ' ' .. replacement

        if spell.name:find('ja') then
            newSpell = string.gsub(spell.name, 'ja', 'ga') .. ' III'
        end
    end

    return newSpell, replacement
end

--- Handles the cancellation of a spell.
-- This function checks if a spell needs to be cancelled based on the replacement spell and player's MP.
-- If a cancellation is needed, it cancels the spell and returns true.
-- @param newSpell The name of the new spell after replacement.
-- @param replacement The name of the replacement spell.
-- @param player_mp The current MP of the player.
-- @param spell The original spell before replacement.
-- @return A boolean indicating whether the spell was cancelled.
function handle_spell_cancellation(newSpell, replacement, player_mp, spell)
    assert(newSpell, "newSpell cannot be nil")
    assert(player_mp, "player_mp cannot be nil")
    assert(spell, "spell cannot be nil")

    if replacement == '' and newSpell ~= 'Aspir' and player_mp < (newSpell == 'Aspir' and 10 or 9) then
        cancel_spell()
        return true
    end

    return false
end

--- Refines various spells based on their recast times and player's MP.
-- This function checks if a spell needs to be replaced or cancelled based on the current recast time and player's MP.
-- If a replacement or cancellation is needed, it modifies the spell accordingly and updates the eventArgs.
-- @param spell The spell to be checked for replacement or cancellation.
-- @param eventArgs The event arguments to be updated if a replacement or cancellation is needed.
-- @param spellCorrespondence The table containing the correspondence between spells and their replacements.
function refine_various_spells(spell, eventArgs, spellCorrespondence)
    assert(spell, "spell cannot be nil")
    assert(eventArgs, "eventArgs cannot be nil")
    assert(spellCorrespondence, "spellCorrespondence cannot be nil")

    local newSpell = spell.english
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp

    local spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
    local correspondence = spellCorrespondence[spellCategory]

    newSpell, replacement = handle_spell_replacement(spell, spell_recasts, player_mp, correspondence, spellCategory,
        spellLevel)

    if handle_spell_cancellation(newSpell, replacement, player_mp, spell) then
        eventArgs.cancel = true
        windower.add_to_chat(123, createFormattedMessage(
            'Cannot cast spell:',
            newSpell,
            nil,
            'Not enough Mana: (' .. player_mp .. 'MP)',
            true,
            true
        ))
        return
    end

    if newSpell ~= spell.english then
        send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true
    elseif state.CastingMode.value == 'MagicBurst' and spell.skill == 'Elemental Magic' then
        send_command((spellLevel == 'VI' and 'wait 2; ' or '') ..
            'input /p Casting: [' .. spellCategory .. ' ' .. spellLevel .. '] => Nuke')
    end

    if spell.english == 'Breakga' and spell_recasts[spell.recast_id] > 0 then
        cancel_spell()
        newSpell = 'Break'
        if spell_recasts[255] > 0 then
            cancel_spell()
            eventArgs.cancel = true
            local recastTime = spell_recasts[255] / 60
            local msg = createFormattedMessage(nil, newSpell, recastTime)
            add_to_chat(123, msg)
        else
            send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
            eventArgs.cancel = true
        end
    end
end

--- Customizes the idle set based on the current conditions.
-- This function uses the `customize_set` function to modify the `idleSet` based on the current conditions and the corresponding sets. It checks if the 'Mana Wall' buff is active and, if so, it applies the 'Mana Wall' set to the `idleSet`.
-- @param idleSet The set to be customized. This should be a table that represents the current idle set. This parameter must not be `nil`.
-- @return The customized idle set. This will be a table that represents the idle set after it has been modified by the `customize_set` function.
-- @usage
-- -- Define the current idle set
-- local idleSet = { item1 = 'item1', item2 = 'item2' }
-- -- Customize the idle set
-- idleSet = customize_idle_set(idleSet)
function customize_idle_set(idleSet)
    assert(idleSet, "idleSet must not be nil")

    -- Define the conditions and the corresponding sets
    local conditions = { Manawall = Manawall }
    local setTable = { Manawall = sets.buff['Mana Wall'] }

    assert(setTable.Manawall, "'Mana Wall' set must not be nil")

    -- Use the customize_set function to customize the idleSet
    return customize_set(idleSet, conditions, setTable)
end

-- Function: mergeTables
-- This function merges two tables together.
function mergeTables(t1, t2)
    assert(t1 and type(t1) == 'table', "t1 must be a table")
    assert(t2 and type(t2) == 'table', "t2 must be a table")

    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Base equipment set
local baseSet = {
    main = "Bunzi's Rod",
    sub = "Ammurapi Shield",
    ammo = { name = "Ghastly Tathlum +1", augments = { 'Path: A', } },
    head = "Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands = "Wicce Gloves +3",
    legs = "Wicce Chausses +3",
    feet = "Wicce Sabots +3",
    neck = { name = "Src. Stole +2", augments = { 'Path: A', } },
    waist = { name = "Acuity Belt +1", augments = { 'Path: A', } },
    left_ear = "Malignance Earring",
    right_ear = "Regal Earring",
    left_ring = "Freke Ring",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = "Taranus's cape"
}

-- Equipment set for 'Elemental Magic' in 'Normal' mode when MP < 1000
-- This set merges the base set with an additional body piece.
local normalSetLowMP = mergeTables(baseSet, {
    body = "Spaekona's Coat +3",
    waist = "Orpheus's Sash"
})

-- Equipment set for 'Elemental Magic' in 'Normal' mode when MP >= 1000
-- This set merges the base set with a different body piece.
local normalSetHighMP = mergeTables(baseSet, {
    body = 'Wicce Coat +3',
    waist = "Orpheus's Sash"
})

-- Equipment set for 'Elemental Magic' in 'MagicBurst' mode when MP < 1000
-- This set merges the base set with additional pieces for body, ammo, feet, and waist.
local magicBurstSetLowMP = mergeTables(baseSet, {
    body = "Spaekona's Coat +3",
    hands = "Agwu's Gages",
    ammo = 'Ghastly tathlum +1',
    feet = "Agwu's Pigaches",
    waist = 'Hachirin-no-obi'
})

-- Equipment set for 'Elemental Magic' in 'MagicBurst' mode when MP >= 1000
-- This set merges the base set with different pieces for body, and additional pieces for ammo, feet, and waist.
local magicBurstSetHighMP = mergeTables(baseSet, {
    body = 'Wicce Coat +3',
    hands = "Agwu's Gages",
    ammo = 'Ghastly tathlum +1',
    feet = "Agwu's Pigaches",
    waist = 'Hachirin-no-obi'
})

-- Function: SaveMP
-- Adjusts player's gear based on current MP and casting mode.
function SaveMP()
    assert(player.mp, "player.mp must not be nil")
    assert(state and state.CastingMode and state.CastingMode.value, "state.CastingMode.value must not be nil")

    -- If MP is less than 1000, adjust gear based on casting mode.
    if player.mp < 1000 then
        -- If casting mode is 'Normal', use normalSetLowMP. Otherwise, use magicBurstSetLowMP.
        if state.CastingMode.value == 'Normal' then
            sets.midcast['Elemental Magic'] = normalSetLowMP
        else
            sets.midcast['Elemental Magic'].MagicBurst = magicBurstSetLowMP
        end
    else
        -- If MP is 1000 or more, adjust gear based on casting mode.
        -- If casting mode is 'Normal', use normalSetHighMP. Otherwise, use magicBurstSetHighMP.
        if state.CastingMode.value == 'Normal' then
            sets.midcast['Elemental Magic'] = normalSetHighMP
        else
            sets.midcast['Elemental Magic'].MagicBurst = magicBurstSetHighMP
        end
    end
end

-- Function: checkArts
-- This function checks if the player's sub-job is Scholar (SCH) and if the 'Dark Arts' ability is available.
-- If these conditions are met and the player is casting an 'Elemental Magic' spell without 'Dark Arts' or 'Addendum: Black' active,
-- it cancels the current spell, activates 'Dark Arts', and then recasts the original spell.
-- Parameters:
--   spell (table): The spell being cast.
--   eventArgs (table): Additional event arguments.
function checkArts(spell, eventArgs)
    -- Check if the parameters are tables.
    assert(type(spell) == 'table', "Parameter 'spell' must be a table.")
    assert(type(eventArgs) == 'table', "Parameter 'eventArgs' must be a table.")

    -- Check if the necessary keys exist in the 'spell' table.
    assert(spell.name, "Key 'name' must exist in the 'spell' table.")

    -- Check if the player's sub-job is Scholar (SCH).
    if player.sub_job == 'SCH' and player.sub_job_level ~= 0 then
        -- Get the recast time for the 'Dark Arts' ability.
        local darkArtsRecast = windower.ffxi.get_ability_recasts()[232]
        -- Check if the player is casting an 'Elemental Magic' spell and doesn't have 'Dark Arts' or 'Addendum: Black' active,
        -- and if the 'Dark Arts' ability is available (recast time is less than 1).
        if
            spell.skill == 'Elemental Magic' and not (buffactive['Dark Arts'] or buffactive['Addendum: Black']) and
            darkArtsRecast < 1
        then
            -- Cancel the current spell.
            cancel_spell()
            -- Activate 'Dark Arts' and recast the original spell after a 2-second delay.
            send_command('input /ja "Dark Arts" <me>; wait 2; input /ma ' .. spell.name .. ' <t>')
        end
    end
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
        handle_blm_commands(cmdParams)

        -- Handle subjob-specific commands
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end
