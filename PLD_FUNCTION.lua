--============================================================--
--=                    PALADIN_FUNCTION                      =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- Spell IDs for single target spells
local spellsSingle = {
    {name = 'Flash', id = 112},  -- Spell ID for the "Flash" spell
    {name = 'Blank Gaze', id = 592}  -- Spell ID for the "Blank Gaze" spell
}

-- Spell IDs for area of effect spells
local spellsAoe = {
    {name = 'Jettatura', id = 575},  -- Spell ID for the "Jettatura" spell
    {name = 'Sheep Song', id = 584},  -- Spell ID for the "Sheep Song" spell
    {name = 'Geist Wall', id = 605}  -- Spell ID for the "Geist Wall" spell
}

-- Handles the execution of a single command
function handleSingleCommand()
    handleCommand(spellsSingle)
end

-- Handles the execution of an AoE command
function handleAoeCommand()
    handleCommand(spellsAoe)
end

-- Automatically triggers the use of the "Divine Emblem" ability
-- Parameters:
--   spell (table): The spell being cast
--   eventArgs (table): Additional event arguments
function auto_divineEmblem(spell, eventArgs)
    if spell.name == 'Flash' then
        local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
        local divineEmblemCD = windower.ffxi.get_ability_recasts()[80]
        if spellRecast < 1 and divineEmblemCD < 1 and not buffactive['Divine Emblem'] then
            cancel_spell()
            send_command(
                string.format(
                    'input /ja "Divine Emblem" <me>; wait 1.2; input /ma %s %s',
                    spell.name,
                    spell.target.id
                )
            )
        else
            incapacitated(spell, eventArgs)
        end
    end
end

-- Automatically triggers the use of the 'Majesty' ability before casting certain spells
-- Parameters:
--   spell (table): The spell being cast
--   eventArgs (table): Additional event arguments
function auto_majesty(spell, eventArgs)
    local MajestyCD = windower.ffxi.get_ability_recasts()[150]
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]

    if (spell.action_type == 'Magic' and spell.skill == 'Healing Magic') or spell.name == 'Protect V' then
        if spellRecast < 1 then
            if not (buffactive['Amnesia'] or buffactive['Silence']) and not state.Buff.Majesty then
                if MajestyCD < 1 then
                    cancel_spell()
                    send_command(
                        string.format(
                            'input /ja "Majesty" <me>; wait 1.2; input /ma %s %s',
                            spell.name,
                            spell.target.id
                        )
                    )
                end
            end
        else
            eventArgs.handled = true
            cancel_spell()
        end
    end
end

-- Customizes the idle gear set based on different conditions and modes
-- Parameters:
--   idleSet (table): The default idle gear set
-- Returns:
--   idleSet (table): The customized idle gear set
function customize_idle_set(idleSet)
    -- Set the default idle gear set based on HybridMode
    if state.HybridMode.value == 'PDT' then
        idleSet = sets.idle
    elseif state.HybridMode.value == 'Ody' then
        idleSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' then
        idleSet = sets.defense.MDT
    elseif state.HybridMode.value == 'Normal' then
        idleSet = sets.engaged
    end

    -- Check if in a city area and adjust idle gear set accordingly
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        if player.mp < 700 then
            idleSet = set_combine(idleSet, sets.latent_refresh)
        else
            idleSet = set_combine(idleSet, sets.idle.Town)
        end
    end

    return idleSet
end

-- Customizes the gear set for melee based on different conditions and modes
-- Parameters:
--   meleeSet (table): The default melee gear set
-- Returns:
--   meleeSet (table): The customized melee gear set
function customize_melee_set(meleeSet)
    -- Set the default melee gear set based on HybridMode
    if state.HybridMode.value == 'PDT' then
        meleeSet = sets.idle
    elseif state.HybridMode.value == 'Ody' then
        meleeSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' then
        meleeSet = sets.defense.MDT
    elseif state.HybridMode.value == 'Normal' then
        meleeSet = sets.engaged
    end

    return meleeSet
end

-- Handle changes in buffs
-- Handles equipment and actions based on changes in buffs
-- Parameters:
--   buff (string): The name of the buff that changed
--   gain (boolean): Indicates whether the buff was gained (true) or lost (false)
function buff_change(buff, gain)
    if buff == 'Doom' then
        if gain then
            -- Buff is gained, equip the Doom set and display a message
            equip(sets.buff.Doom)
            disable('neck')
            add_to_chat(123, 'WARNING: Doom is active!')
        else
            -- Buff is lost, update sets and display a message
            enable('neck')
            send_command('gs c update')
            add_to_chat(123, 'Doom is no longer active.')
        end
    end
end