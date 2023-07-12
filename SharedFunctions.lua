--============================================================--
--=                    SHARED FUNCTIONS                       =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-10                  =--
--============================================================--

-- Helper function to format recast time
function formatRecastTime(recast)
    if recast then
        if recast >= 60 then
            local minutes = math.floor(recast / 60)
            local seconds = math.floor(recast % 60)
            return string.format('%02d:%02d min', minutes, seconds)
        else
            return string.format('%.1f sec', recast)
        end
    end
end

    -- Helper function to create a message with spell name and recast time
    function createMessage(spellName, recast)
        if recast then
            local message =
                string.char(0x1F, 050) .. '[' ..
                string.char(0x1F, 221) .. spellName ..
                string.char(0x1F, 050) .. ']' ..
                ' Recast: ' ..
                string.char(0x1F, 050) .. '(' ..
                string.char(0x1F, 221) ..
                formatRecastTime(recast) .. string.char(0x1F, 050) .. ')'
            return message
        else
            local message =
                string.char(0x1F, 050) .. '[' ..
                string.char(0x1F, 221) .. spellName ..
                string.char(0x1F, 050) .. ']'
            return message
        end
    end

-- Handle recast cooldown and display messages
function handleRecastCooldown(spell, eventArgs)
    -- Check if the action type is not "Weapon Skill"
    if spell.action_type ~= 'Weapon Skill' then
        -- Retrieve the recast time of the spell or ability
        local recast = 0
        if spell.action_type == 'Magic' then
            recast = windower.ffxi.get_spell_recasts()[spell.id] / 60 -- Convert milliseconds to seconds
        elseif spell.action_type == 'Ability' then
            recast = windower.ffxi.get_ability_recasts()[spell.recast_id] -- Recasts are already in seconds
        end
        -- Check if the recast value is not nil
        if recast and recast > 0 then
            cancel_spell()
            eventArgs.cancel = true
            -- Format and display the recast message
            local message = createMessage(spell.name, recast)
            add_to_chat(123, message)
            add_to_chat(259, '=================================================')
        end
    end
end

-- Check for incapacitated state
function incapacitated(spell, eventArgs)
    -- List of incapacitated states
    local incapacitated_states =
        T {
        'Stun', -- Stun status
        'Petrification', -- Petrification status
        'Terror', -- Terror status
        'Sleep' -- Sleep status
    }
    -- Iterate over each value in the incapacitated_states table
    for _, value in ipairs(incapacitated_states) do
        -- Check if the value exists as a buff in the buffactive table
        if buffactive[value] then
            -- If an incapacitated state is detected, equip the idle gear and return the incapacitation type and name
            cancel_spell()
            eventArgs.handled = true
            equip(sets.idle)
            local message =
                string.char(0x1F, 159) ..
                'Cannot use: [' ..
                    string.char(0x1F, 221) ..
                        spell.name ..
                            string.char(0x1F, 028) ..
                                ']' ..
                                    ' Incapacitated: (' ..
                                        string.char(0x1F, 221) .. value .. string.char(0x1F, 028) .. ')'
            add_to_chat(167, message)
            add_to_chat(259, '=================================================')
            return true, value
        end
    end
    -- If no incapacitated state is detected, return false and nil for the incapacitation type and name
    return false, nil
end

-- Check current main weapon set
function check_weaponset()
    equip(sets[state.WeaponSet.current])
end

-- Check current sub weapon set
function check_subset()
    equip(sets[state.SubSet.current])
end

-- Actions to perform when the player's equipment changes
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check and adjust the weapon set
    check_weaponset()
    -- Check and adjust the gear subset
    check_subset()
    -- Check if Moving state is true and equip MoveSpeed gear
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end

-- Actions to perform when the job state changes
function job_state_change(field, new_value, old_value)
    -- Handle equipping gear based on player status
    job_handle_equipping_gear(player.status)
    -- Check and adjust the weapon set
    check_weaponset()
    -- Check and adjust the gear subset
    check_subset()
end

-- Perform actions after a spell is cast
function handleSpellAftercast(spell, eventArgs)
    if spell.name == 'Crusade' or spell.name == 'Reprisal' or spell.name == 'Phalanx' or spell.name == 'Cocoon' then
        -- Handle Crusade, Reprisal, Phalanx, or Cocoon spells
        if spell.interrupted then
            -- Spell was interrupted
            handleInterruptedSpell(spell, eventArgs)
        else
            -- Spell completed normally
            handleCompletedSpell(spell)
        end
    else
        -- Process other spells
        if not spellHandled then
            if spell.interrupted then
                -- Spell was interrupted
                handleInterruptedSpell(spell, eventArgs)
            else
                -- Spell completed normally
                handleCompletedSpell(spell)
            end
            -- Mark the spell as handled
            spellHandled = true
        else
            -- Reset the variable for subsequent spells
            spellHandled = false
        end
    end
end

-- Handle actions for an interrupted spell
function handleInterruptedSpell(spell, eventArgs)
    eventArgs.handled = true
    equip(sets.idle)
    local bracketColor = string.char(0x1F, 050) -- Color code for the brackets
    local message =
        bracketColor .. 'Spell interrupted: ' ..
        bracketColor .. '[' .. string.char(0x1F, 221) .. spell.name .. bracketColor .. ']'
    add_to_chat(123, message)
    add_to_chat(259, '=================================================')
end

-- Handle actions for a completed spell
function handleCompletedSpell(spell)
    -- Perform appropriate actions after the spell is completed normally
end

return {
    handleRecastCooldown = handleRecastCooldown,
    incapacitated = incapacitated,
    check_weaponset = check_weaponset,
    check_subset = check_subset,
    job_handle_equipping_gear = job_handle_equipping_gear,
    job_state_change = job_state_change,
    handleSpellAftercast = handleSpellAftercast,
}
