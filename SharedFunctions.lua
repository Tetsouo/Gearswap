--============================================================--
--=                    SHARED FUNCTIONS                       =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- Shared Variables
spellLanded = ''

-- List of colors for objects in messages
PUNCTUATION = 161 -- Color for punctuation marks
SPELLANDRECAST = 057 -- Color for spell names and recast timers
SEPARATOR = 161 -- Color for separators
INCAP = 167 -- Color for incapacitated state

-- List of incapacitated states
local incapacitated_states =
    T {
    'Stun', -- Stun status
    'Petrification', -- Petrification status
    'Terror', -- Terror status
    'Sleep', -- Sleep status
}

-- Formats a recast time value into a readable string representation.
-- Parameters:
--   recast (number): The recast time value in seconds.
-- Returns:
--   (string) The formatted recast time string.
local function formatRecastDuration(recast)
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

-- Creates a formatted message with the spell name, its recast time, and additional text.
-- Parameters:
--   startMsg (string): The starting part of the message (can be nil).
--   spellName (string): The name of the spell.
--   recast (number): The recast time value in seconds (can be nil).
--   endMsg (string): The ending part of the message (can be nil).
--   isLast (boolean): Indicates if it is the last message in a sequence (default: true).
-- Returns:
--   (string) The formatted message with spell name, recast time, additional text, and separator.
local function createFormatMsg(startMsg, spellName, recast, endMsg, isLast)
    -- Assign default values if parameters are nil
    startMsg = startMsg or ''
    spellName = spellName or ''
    recast = recast or nil
    endMsg = endMsg or ''
    isLast = isLast == nil or isLast
    -- Check if a recast value is provided
    if recast then
        -- Build the message with spell name, recast time, and additional text
        local message =
            string.char(0x1F, PUNCTUATION) .. '[' ..
            string.char(0x1F, SPELLANDRECAST) .. spellName ..
            string.char(0x1F, PUNCTUATION) .. ']' .. ' Recast: ' ..
            string.char(0x1F, PUNCTUATION) .. '(' ..
            string.char(0x1F, SPELLANDRECAST) .. formatRecastDuration(recast) .. 
            string.char(0x1F, PUNCTUATION) .. ')'
        -- Append the separator to the message
        if isLast then
            message =
                message .. '\n' .. 
                string.char(0x1F, SEPARATOR) .. '================================================='
        end
        -- Return the constructed message
        return message
    else
        -- Build the message with only the spell name and additional text
        for _, value in ipairs(incapacitated_states) do
            if endMsg == value then
                originalEndMsg = endMsg
                endMsg =
                    string.char(0x1F, INCAP) .. 'Incapacitated: ' ..
                    string.char(0x1F, PUNCTUATION) .. '[' ..
                    string.char(0x1F, SPELLANDRECAST) .. originalEndMsg ..
                    string.char(0x1F, PUNCTUATION) .. ']'
            end
        end
        local message =
            startMsg ..
            ' ' ..
            string.char(0x1F, PUNCTUATION) .. '[' ..
            string.char(0x1F, SPELLANDRECAST) .. spellName ..
            string.char(0x1F, PUNCTUATION) .. ']' .. ' ' .. endMsg
        -- Append the separator to the message
        if isLast then
            message =
                message .. '\n' .. 
                string.char(0x1F, SEPARATOR) .. '================================================='
        end
        -- Return the constructed message
        return message
    end
end

-- Handles the recast cooldown for spells and abilities and displays appropriate messages.
-- Parameters:
--   spell (table): The spell or ability being used.
--   eventArgs (table): Additional event arguments.
function checkDisplayCooldown(spell, eventArgs)
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
            eventArgs.handled = true
            -- Format and display the recast message
            local message = createFormatMsg(nil, spell.name, recast, nil)
            add_to_chat(123, message)
        end
    end
end

-- Function to handle a command for gearswap Lua script
function handleCommand(spellTable)
    local messages = {} -- Table to store spell messages
    local spellId = nil -- ID of the current spell
    local spellStep = nil -- Current step of the spell
    local spellToCast = nil -- Spell ready to be cast
    local spellToTest = nil -- Spell to test if it's ready to be cast
    local spellRecast = nil -- Recast time of the spell
    local spellPosition = nil -- Position of the spell in the spellTable

    -- Find the spell ready to be cast
    for i, spellData in ipairs(spellTable) do
        spellId = spellData.id
        spellStep = spellData.step
        spellRecast = windower.ffxi.get_spell_recasts()[spellId] / 60 -- Convert recast time to minutes
        spellPosition = i

        if spellRecast == 0 then
            if spellStep == 'Aftercast' then
                spellToCast = spellData
                break
            else
                spellToTest = spellData

                if i < #spellTable then
                    spellToTest = spellData
                    spellToCast = spellTable[i + 1]
                    spellRecast = windower.ffxi.get_spell_recasts()[spellToCast.id] / 60
                    break
                else
                    spellToCast = spellTable[#spellTable]
                    spellRecast = windower.ffxi.get_spell_recasts()[spellToCast.id] / 60
                    break
                end
            end
        elseif spellRecast > 0 then
            local message = createFormatMsg(nil, spellData.name, spellRecast, nil)
            -- Add the spell message to the messages table
            table.insert(messages, {spell = spellData.name, recast = spellRecast, message = message})
        end
    end

    -- If there is a spell ready to be cast
    if spellRecast == 0 then
        -- Check if there is a spell to test
        if spellToTest then
            -- Check the step of the spell to test
            if spellToTest.step == 'Aftercast' then
                send_command('input /ma "' .. spellToCast.name .. '" <stnpc>') -- Cast the spell on the target
            else
                -- Check if the spell to cast is the same as the spell to test
                if spellToCast == spellToTest then
                    -- Check if the recast time is 0
                    if spellRecast == 0 then
                        send_command('input /ma "' .. spellToCast.name .. '" <stnpc>') -- Cast the spell on the target
                    end
                else
                    -- Check if the recast time is 0
                    if spellRecast == 0 then
                        -- Cast the first spell, wait for 6 seconds, then cast the second spell
                        send_command(
                            'input /ma "' ..
                                spellToCast.name .. 
                                '" <stnpc>; wait 6; input /ma "' .. 
                                spellToTest.name .. '" <t>'
                        )
                    else
                        -- Check if the recast time is greater than 0
                        if spellRecast > 0 then
                            spellToTest = spellToTest + 1 -- Increment the spell to test
                        end
                        send_command('input /ma "' .. spellToTest.name .. '" <stnpc>') -- Cast the spell to test on the target
                    end
                end
            end
        else
            -- Check the step of the spell to cast
            if spellToCast.step == 'Aftercast' then
                send_command('input /ma "' .. spellToCast.name .. '" <stnpc>') -- Cast the spell on the target
            end
        end
    else
        -- Check if there is a spell two positions ahead in the spellTable
        if spellPosition + 2 <= #spellTable then
            spellToCast = spellTable[spellPosition + 2]
            spellRecast = windower.ffxi.get_spell_recasts()[spellToCast.id] / 60

            -- Check if the recast time of the spell to cast is 0
            if spellRecast == 0 then
                -- Cast the second spell, wait for 6 seconds, then cast the first spell
                send_command(
                    'input /ma "' .. spellToCast.name .. 
                    '" <stnpc>; wait 6; input /ma "' .. 
                    spellToTest.name .. '" <t>'
                )
            end
        end

        -- Check if there are messages in the table
        if #messages > 0 then
            -- Sort the messages table based on recast time in ascending order
            table.sort(
                messages,
                function(a, b)
                    return a.recast < b.recast
                end
            )
        end

        -- Display each spell message in the messages table
        for i, msgData in ipairs(messages) do
            local isLast = (i == #messages) -- Check if it's the last message
            add_to_chat(167, 
            createFormatMsg(nil, msgData.spell, msgData.recast, nil, isLast)) -- Output the spell message
        end
    end
end

-- Checks if the player is in an incapacitated state that prevents spell usage.
-- Parameters:
--   spell (table): The spell being cast.
--   eventArgs (table): Additional event arguments.
-- Returns:
--   (boolean) true if incapacitated, false otherwise.
--   (string or nil) The type of incapacitation if incapacitated, nil otherwise.
function incapacitated(spell, eventArgs, cancel)
    cancel = false
    -- Iterate over each value in the incapacitated_states table
    for _, value in ipairs(incapacitated_states) do
        -- Check if the value exists as a buff in the buffactive table
        if buffactive[value] then
            -- If an incapacitated state is detected, equip the idle gear and return the incapacitation type and name
            -- Create and display the incapacitated message
            cancel_spell()
            eventArgs.handled = true
            equip(sets.idle)
            local message = createFormatMsg('Cannot Use: ', spell.name, nil, value)
            add_to_chat(167, message)
            return true, value
        end
    end
    -- If no incapacitated state is detected, return false and nil for the incapacitation type and name
    return false, nil
end

-- Checks the current main weapon set and equips the corresponding gear.
local function check_weaponset()
    -- Equip the gear set based on the current state of the WeaponSet
    equip(sets[state.WeaponSet.current])
end

-- Checks the current sub weapon set and equips the corresponding gear.
local function check_subset()
    -- Equip the gear set based on the current state of the SubSet
    equip(sets[state.SubSet.current])
end

-- Handles the necessary gear adjustments when the player's equipment changes.
-- Parameters:
--   playerStatus (table): The player's current status information.
--   eventArgs (table): Additional event arguments.
local function job_handle_equipping_gear()
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

-- Handles the necessary actions when the job state changes.
-- Parameters:
--   field (string): The field that changed in the job state.
--   new_value (any): The new value of the changed field.
--   old_value (any): The old value of the changed field.
function job_state_change(field, new_value, old_value)
    -- Handle equipping gear based on player status
    job_handle_equipping_gear()
    -- Check and adjust the main weapon set
    check_weaponset()
    -- Check and adjust the sub weapon set
    check_subset()
end

-- Handles actions to be performed after a spell has been cast.
-- Parameters:
--   spell (table): The spell that was cast.
--   eventArgs (table): Additional event arguments.
function handleSpellAftercast(spell, eventArgs)
    if spell.interrupted then
        -- Spell was interrupted
        handleInterruptedSpell(spell, eventArgs)
    else
        -- Spell completed normally
        handleCompletedSpell(spell)
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

-- Handles actions to be performed when a spell is completed normally.
-- Parameters:
--   spell (table): The completed spell.
function handleCompletedSpell(spell)
    recast = windower.ffxi.get_spell_recasts()[spell.id]
    local message = createFormatMsg(nil, spell.name, nil, 'Completed !')
    add_to_chat(123, message)
    -- Perform appropriate actions after the spell is completed normally
end

-- Handles equipment and actions based on changes in buffs.
-- Parameters:
--   buff (string): The name of the buff that changed.
--   gain (boolean): Indicates whether the buff was gained (true) or lost (false).
function buff_change(buff, gain)
    if buff == 'Doom' then
        if gain then
            -- Buff is gained, equip the Doom set and display a message
            equip(sets.buff.Doom)
            disable('neck')
            local message = createFormatMsg('WARNING:', 'Doom', nil, 'is active!')
            add_to_chat(123, message)
        else
            -- Buff is lost, update sets and display a message
            enable('neck')
            send_command('gs c update')
            local message = createFormatMsg(nil, 'Doom', nil, 'is no longer active!')
            add_to_chat(123, message)
        end
    end
end

function updateTable(table, spellName, step)
    for i, spell in ipairs(table) do
        if spell.name == spellName then
            spell.step = step
            return
        end
    end
end