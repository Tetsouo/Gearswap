--============================================================--
--=                    PLD_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

-- A table containing the spell IDs and names for single target spells.
spellsSingle = {
    {name = 'Flash', id = 112, step = "Aftercast"}, -- Spell ID for the "Flash" spell
    {name = 'Blank Gaze', id = 592, step = "Aftercast"}, -- Spell ID for the "Blank Gaze" spell
    
}

-- A table containing the spell IDs and names for area of effect spells.
spellsAoe = {
    {name = 'Jettatura', id = 575, step = "Aftercast"}, -- Spell ID for the "Jettatura" spell
    {name = 'Sheep Song', id = 584, step = "Aftercast"}, -- Spell ID for the "Sheep Song" spell
    {name = 'Geist Wall', id = 605, step = "Aftercast"}, -- Spell ID for the "Geist Wall" spell
    {name = 'Frightful Roar', id = 561, step = "Aftercast"}, -- Spell ID for the "Frightful Roar" spell
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
                            'input /ja "Divine Emblem" <me>; wait 1; input /ma %s %s',
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
                            'input /ja "Majesty" <me>; wait 1; input /ma %s %s',
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

function customize_cure_set(spell)
    if spell.name == 'Cure III' or spell.name == 'Cure IV' then
        if player.target.type == 'SELF' then
            sets.midcast.Cure = {
                ammo = {name = 'staunch Tathlum +1', priority = 1},
                head = SouvHead,
                neck = {name = 'Unmoving Collar +1', priority = 16},
                left_ear = {name = 'tuisto Earring', priority = 15},
                right_ear = {name = 'Chev. Earring +1', priority = 0},
                body = {name = 'Rev. Surcoat +3', priority = 2},
                hands = {name = 'Regal Gauntlets', priority = 14},
                left_ring = {name = 'Supershear Ring', priority = 5},
                right_ring = {name = 'Defending Ring', priority = 6},
                back = Rudianos.cure,
                waist = {name = 'Plat. Mog. Belt', priority = 17},
                legs = {name = "Founder's Hose", priority = 8},
                feet = {name = 'Odyssean Greaves', priority = 9}
            }
        else
            sets.midcast.Cure = {
                ammo = {name = 'staunch Tathlum +1', priority = 1},
                head = SouvHead,
                neck = {name = 'Sacro Gorget', priority = 10},
                left_ear = {name = 'tuisto Earring', priority = 15},
                right_ear = {name = 'Chev. Earring +1', priority = 0},
                body = SouvBody,
                hands = {name = 'Regal Gauntlets', priority = 14},
                left_ring = {name = 'Apeile Ring +1', priority = 0},
                right_ring = {name = 'Defending Ring', priority = 0},
                back = Rudianos.cure,
                waist = {name = 'Creed Baudrier', priority = 4},
                legs = {name = "Founder's Hose", priority = 8},
                feet = {name = 'Odyssean Greaves', priority = 9}
            }
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
    if state.HybridMode.value == 'PDT' and state.Xp.value == 'True' then
        idleSet = sets.idleXp
    elseif state.HybridMode.value == 'PDT' and state.Xp.value == 'False' then
        idleSet = sets.idleNormal
    elseif state.HybridMode.value == 'MDT' then
        idleSet = sets.defense.MDT -- Use the magical defense gear set 'sets.defense.MDT'
    end
    -- Check if in a city area and adjust idle gear set accordingly.
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        if player.mp < 500 then
            idleSet = set_combine(idleSet, sets.latent_refresh) -- Combine the idle gear set with 'sets.latent_refresh'
        end
        idleSet = set_combine(idleSet, {neck = "Elite Royal Collar"})
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
    if state.HybridMode.value == 'PDT' and state.Xp.value == 'True' then
        meleeSet = sets.meleeXp
    elseif state.HybridMode.value == 'PDT' and state.Xp.value == 'False' then
        meleeSet = sets.engaged.PDT -- Use the default idle gear set 'sets.idleNormal'
    elseif state.HybridMode.value == 'MDT' then
        meleeSet = sets.defense.MDT -- Use the magical defense gear set 'sets.defense.MDT'
    end
    return meleeSet -- Return the customized melee gear set
end

-- Handles actions to be performed when a spell is interrupted.
-- Parameters:
--   spell (table): The interrupted spell.
--   eventArgs (table): Additional event arguments.
function handleInterruptedSpell(spell, eventArgs)
    equip(sets.idleNormal)
    eventArgs.handled = true
    local message = createFormatMsg('Spell interrupted:', spell.name)
    add_to_chat(123, message)
end

function PhalanXp(spell, eventArgs)
    if spell.name == 'Phalanx' and buffactive['Silence'] then
        cancel_spell()
        eventArgs.handled = true
        equip(sets.idle)
        local message = createFormatMsg('Cannot Use:', spell.name, nil, value)
        add_to_chat(167, message)
        return true, value
    else
        if state.Xp.value == 'True' then
            sets.midcast['Phalanx'] = sets.midcast.SIRDPhalanx
        else
            sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
        end
    end
end

-- ***************************************************************************
-- * Appelé à chaque changement de stuffs automatique (ex: Engaged ou Idle). *
-- ***************************************************************************
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_weaponset()
    check_subset()
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end