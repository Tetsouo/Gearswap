--============================================================--
--=                    SHARED FUNCTIONS                       =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-10                  =--
--============================================================--

-- Helper function to format recast time
-- Formats a recast time value into a readable string representation
-- Parameters:
--   recast (number): The recast time value in seconds
-- Returns:
--   (string) The formatted recast time string
function formatRecastTime(recast)
    -- Check if a recast value is provided
    if recast then
        -- Check if the recast time is greater than or equal to 60 seconds (1 minute)
        if recast >= 60 then
            -- Calculate the number of minutes and seconds
            local minutes = math.floor(recast / 60)
            local seconds = math.floor(recast % 60)
            -- Format the recast time as 'MM:SS min'
            return string.format('%02d:%02d min', minutes, seconds)
        else
            -- Format the recast time as 'X.X sec' (with one decimal place)
            return string.format('%.1f sec', recast)
        end
    end
end

-- Helper function to create a message with spell name and recast time
-- Creates a formatted message with the spell name and its recast time
-- Parameters:
--   spellName (string): The name of the spell
--   recast (number): The recast time value in seconds
-- Returns:
--   (string) The formatted message with spell name and recast time
function createMessage(spellName, recast)
    -- Check if a recast value is provided
    if recast then
        -- Build the message with spell name and recast time
        local message =
            string.char(0x1F, 050) .. '[' ..
            string.char(0x1F, 221) .. spellName ..
            string.char(0x1F, 050) .. ']' ..
            ' Recast: ' ..
            string.char(0x1F, 050) .. '(' ..
            string.char(0x1F, 221) ..
            formatRecastTime(recast) .. string.char(0x1F, 050) .. ')'
        -- Return the constructed message
        return message
    else
        -- Build the message with only the spell name
        local message =
            string.char(0x1F, 050) .. '[' ..
            string.char(0x1F, 221) .. spellName ..
            string.char(0x1F, 050) .. ']'
        -- Return the constructed message
        return message
    end
end

-- Handle recast cooldown and display messages
-- Handles the recast cooldown for spells and abilities and displays appropriate messages
-- Parameters:
--   spell (table): The spell or ability being used
--   eventArgs (table): Additional event arguments
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

-- Helper function to handle the command logic
-- Handles the logic for executing commands based on spell availability
-- Parameters:
--   spellTable (table): A table containing spell data (name and ID)
function handleCommand(spellTable)
    local messages = {}
    -- Iterate over each spell in the spellTable
    for _, spellData in ipairs(spellTable) do
        local spellName = spellData.name
        local spellId = spellData.id
        -- Retrieve the recast time of the spell in minutes
        local recast = windower.ffxi.get_spell_recasts()[spellId] / 60
        -- Check if the recast time is less than 1 minute
        if recast < 1 then
            -- Execute the spell command with <stnpc> as the target
            send_command('input /ma "' .. spellName .. '" <stnpc>')
            return
        elseif recast > 0 then
            -- Create a message for the spell with its name and recast time
            local message = createMessage(spellName, recast)
            -- Add the spell message to the messages table
            table.insert(messages, {spell = spellName, recast = recast, message = message})
        end
    end
    -- Check if there are any messages
    if #messages > 0 then
        -- Sort the messages table based on recast time in ascending order
        table.sort(
            messages,
            function(a, b)
                return a.recast < b.recast
            end
        )
        -- Display a message indicating no spells are available
        add_to_chat(159, 'No spells available')
        -- Display each spell message in the messages table
        for _, msgData in ipairs(messages) do
            add_to_chat(167, msgData.message)
        end
        add_to_chat(259, '=================================================')
    else
        -- Display a message indicating all spells are unavailable
        add_to_chat(159, 'All spells are unavailable')
    end
end

-- Check for incapacitated state
-- Checks if the player is in an incapacitated state that prevents spell usage
-- Parameters:
--   spell (table): The spell being cast
--   eventArgs (table): Additional event arguments
-- Returns:
--   (boolean) true if incapacitated, false otherwise
--   (string or nil) The type of incapacitation if incapacitated, nil otherwise
function incapacitated(spell, eventArgs)
    -- List of incapacitated states
    local incapacitated_states =
        T {
        'Stun', -- Stun status
        'Petrification', -- Petrification status
        'Terror', -- Terror status
        'Sleep', -- Sleep status
    }
    -- Iterate over each value in the incapacitated_states table
    for _, value in ipairs(incapacitated_states) do
        -- Check if the value exists as a buff in the buffactive table
        if buffactive[value] then
            -- If an incapacitated state is detected, equip the idle gear and return the incapacitation type and name
            cancel_spell()
            eventArgs.handled = true
            equip(sets.idle)
            -- Create and display the incapacitated message
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
-- Checks the current main weapon set and equips the corresponding gear
function check_weaponset()
    -- Equip the gear set based on the current state of the WeaponSet
    equip(sets[state.WeaponSet.current])
end

-- Check current sub weapon set
-- Checks the current sub weapon set and equips the corresponding gear
function check_subset()
    -- Equip the gear set based on the current state of the SubSet
    equip(sets[state.SubSet.current])
end

-- Actions to perform when the player's equipment changes
-- Handles the necessary gear adjustments when the player's equipment changes
-- Parameters:
--   playerStatus (table): The player's current status information
--   eventArgs (table): Additional event arguments
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check and adjust the main weapon set
    check_weaponset()
    -- Check and adjust the sub weapon set
    check_subset()
    -- Check if Moving state is true and equip MoveSpeed gear
    if state.Moving.value == 'true' then
        -- Equip the MoveSpeed gear set
        send_command('gs equip sets.MoveSpeed')
    end
end

-- Actions to perform when the job state changes
-- Handles the necessary actions when the job state changes
-- Parameters:
--   field (string): The field that changed in the job state
--   new_value (any): The new value of the changed field
--   old_value (any): The old value of the changed field
function job_state_change(field, new_value, old_value)
    -- Handle equipping gear based on player status
    job_handle_equipping_gear(player.status)
    -- Check and adjust the main weapon set
    check_weaponset()
    -- Check and adjust the sub weapon set
    check_subset()
end

-- Perform actions after a spell is cast
-- Handles actions to be performed after a spell has been cast
-- Parameters:
--   spell (table): The spell that was cast
--   eventArgs (table): Additional event arguments
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
-- Handles actions to be performed when a spell is interrupted
-- Parameters:
--   spell (table): The interrupted spell
--   eventArgs (table): Additional event arguments
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
-- Handles actions to be performed when a spell is completed normally
-- Parameters:
--   spell (table): The completed spell
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