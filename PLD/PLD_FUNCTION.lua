--============================================================--
--=                    PALADIN_FUNCTION                      =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- A table containing the spell IDs and names for single target spells.
spellsSingle = {
    {name = 'Flash', id = 112, step = "Aftercast"}, -- Spell ID for the "Flash" spell
    {name = 'Blank Gaze', id = 592, step = "Aftercast"} -- Spell ID for the "Blank Gaze" spell
}

-- A table containing the spell IDs and names for area of effect spells.
spellsAoe = {
    {name = 'Jettatura', id = 575, step = "Aftercast"}, -- Spell ID for the "Jettatura" spell
    {name = 'Sheep Song', id = 584, step = "Aftercast"}, -- Spell ID for the "Sheep Song" spell
    {name = 'Geist Wall', id = 605, step = "Aftercast"} -- Spell ID for the "Geist Wall" spell
}

-- Calls the handleCommand function with the spellsSingle table.
function handleSingleCommand()
    handleCommand(spellsSingle)
end

-- Calls the handleCommand function with the spellsAoe table.
function handleAoeCommand()
    handleCommand(spellsAoe)
end

-- Automatically uses the "Divine Emblem" ability before casting the "Flash" spell if conditions are met.
-- Parameters:
--   spell (table): The spell being cast.
--   eventArgs (table): Additional event arguments.
function auto_divineEmblem(spell, eventArgs)
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
    local divineEmblemCD = windower.ffxi.get_ability_recasts()[80]
    if spell.name == 'Flash' then
        if spellRecast == 0 then
            if not (buffactive['Amnesia'] or buffactive['Silence']) then
                if divineEmblemCD < 1 and not buffactive['Divine Emblem'] then
                    cancel_spell()
                    send_command(
                        string.format(
                            'input /ja "Divine Emblem" <me>; wait 1.5; input /ma %s %s',
                            spell.name,
                            spell.target.id
                        )
                    )
                end
            end
        else
            cancel_spell()
            eventArgs.handled = true
        end
    end
end

-- Automatically triggers the use of the 'Majesty' ability before casting certain spells
-- Parameters:
--   spell (table): The spell being cast
--   eventArgs (table): Additional event arguments
function auto_majesty(spell, eventArgs)
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
    local majestyCD = windower.ffxi.get_ability_recasts()[150]
    if (spell.action_type == 'Magic' and spell.skill == 'Healing Magic') or spell.name == 'Protect V' then
        if spellRecast == 0 then
            if not (buffactive['Amnesia'] or buffactive['Silence']) then
                if majestyCD < 1 and not buffactive['Majesty'] then
                    cancel_spell()
                    send_command(
                        string.format(
                            'input /ja "Majesty" <me>; wait 1.5; input /ma %s %s',
                            spell.name,
                            spell.target.id
                        )
                    )
                end
            end
        else
            cancel_spell()
            eventArgs.handled = true
        end
    end
end

-- Modifies the default idle gear set to customize it based on the current conditions and modes.
-- Parameters:
--   idleSet (table): The default idle gear set.
-- Returns:
--   idleSet (table): The customized idle gear set.
function customize_idle_set(idleSet)
    -- Set the default idle gear set based on HybridMode.
    if state.HybridMode.value == 'PDT' then
        idleSet = sets.idle -- Use the default idle gear set 'sets.idle'
    elseif state.HybridMode.value == 'Ody' then
        idleSet = sets.idle.Ody -- Use the 'sets.idle.Ody' idle gear set specific to 'Ody'
    elseif state.HybridMode.value == 'MDT' then
        idleSet = sets.defense.MDT -- Use the magical defense gear set 'sets.defense.MDT'
    elseif state.HybridMode.value == 'Normal' then
        idleSet = sets.engaged -- Use the engaged gear set 'sets.engaged'
    end
    -- Check if in a city area and adjust idle gear set accordingly.
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        if player.mp < 700 then
            idleSet = set_combine(idleSet, sets.latent_refresh) -- Combine the idle gear set with 'sets.latent_refresh'
        else
            idleSet = set_combine(idleSet, sets.idle.Town) -- Combine the idle gear set with 'sets.idle.Town'
        end
    end
    return idleSet -- Return the customized idle gear set
end

-- Customizes the gear set for melee based on different conditions and modes
-- Parameters:
--   meleeSet (table): The default melee gear set
-- Returns:
--   meleeSet (table): The customized melee gear set
function customize_melee_set(meleeSet)
    -- Set the default melee gear set based on HybridMode
    if state.HybridMode.value == 'PDT' then
        meleeSet = sets.idle -- Use the default idle gear set 'sets.idle'
    elseif state.HybridMode.value == 'Ody' then
        meleeSet = sets.idle.Ody -- Use the 'sets.idle.Ody' idle gear set specific to 'Ody'
    elseif state.HybridMode.value == 'MDT' then
        meleeSet = sets.defense.MDT -- Use the magical defense gear set 'sets.defense.MDT'
    elseif state.HybridMode.value == 'Normal' then
        meleeSet = sets.engaged -- Use the engaged gear set 'sets.engaged'
    end
    return meleeSet -- Return the customized melee gear set
end

-- Handles custom commands specific to the job.
-- Parameters:
--   cmdParams (table): The command parameters
--   eventArgs (table): Additional event arguments
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'single' then
        handleSingleCommand() -- Handle the "single" command
    elseif cmdParams[1]:lower() == 'aoe' then
        handleAoeCommand() -- Handle the "aoe" command
    end
end

-- Handles actions to be performed when a spell is interrupted.
-- Parameters:
--   spell (table): The interrupted spell.
--   eventArgs (table): Additional event arguments.
function handleInterruptedSpell(spell, eventArgs)
    for _, spellTest in ipairs(spellsSingle) do
        if spellTest.name == spell.name then
            spellTest.step = 'Midcast'
        end
    end
    for _, spellTest in ipairs(spellsAoe) do
        if spellTest.name == spell.name then
            spellTest.step = 'Midcast'
        end
    end
    equip(sets.idle)
    eventArgs.handled = true
    local message = createFormatMsg('Spell interrupted:', spell.name)
    add_to_chat(123, message)
end