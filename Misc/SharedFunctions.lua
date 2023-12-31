--============================================================--
--=                    SHARED FUNCTIONS                      =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- List of colors for objects in messages
-- Color can be found in directory Misc/Color.png
PUNCTUATION = 161 -- Color for punctuation marks
SPELLANDRECAST = 057 -- Color for spell names and recast timers
SEPARATOR = 161 -- Color for separators
INCAP = 167 -- Color for incapacitated state
local strat_charge_time = {240,120,80,60,48}

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
function createFormatMsg(startMsg, spellName, recast, endMsg, isLast)
    -- Assign default values if parameters are nil
    startMsg = startMsg or nil
    spellName = spellName or nil
    recast = recast or nil
    endMsg = endMsg or nil
    isLast = isLast == nil or isLast
    local startMessage = nil
    local endMessage = nil
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
        if startMsg then
            startMessage = startMsg .. ' ' .. string.char(0x1F, PUNCTUATION) .. '['
        else
            startMessage = string.char(0x1F, PUNCTUATION) .. '['
        end
        if endMsg then
            endMessage = string.char(0x1F, PUNCTUATION) .. ']' .. ' ' .. endMsg
        else
            endMessage = string.char(0x1F, PUNCTUATION) .. ']'
        end
        local message =
            startMessage ..
            string.char(0x1F, SPELLANDRECAST) .. spellName ..
            endMessage
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

-- Checks and displays the cooldown for a spell or ability.
-- Parameters:
--   spell (table): The spell or ability being checked.
--   eventArgs (table): Additional event arguments.
function checkDisplayCooldown(spell, eventArgs)
    -- Check if the skill is Elemental Magic
    if spell.skill == 'Elemental Magic' then
        return  -- Skip cooldown check for Elemental Magic spells
    end
    if spell.type == "Scholar" then
        return  -- Skip cooldown check for Stratagems Magic spells
    end
    -- Check if the action type is not "Weapon Skill" and is not elemental
    if spell.action_type ~= 'Weapon Skill' then
        -- Retrieve the recast time of the spell or ability
        local recast = 0
        if spell.action_type == 'Magic' then
            recast = windower.ffxi.get_spell_recasts()[spell.id] / 60  -- Convert milliseconds to seconds
        elseif spell.action_type == 'Ability' then
            recast = windower.ffxi.get_ability_recasts()[spell.recast_id]  -- Recasts are already in seconds
        end
        -- Check if the recast value is not nil and greater than 0
        if recast and recast > 0 then
            cancel_spell()
            eventArgs.handled = true
            -- Format and display the recast message
            local message = createFormatMsg(nil,spell.name, recast)
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
                -- Cast the spell on the target
                send_command(
                    string.format(
                        'input /ma "%s" <t>',
                        spellToCast.name
                    )
                )
            else
                -- Check if the spell to cast is the same as the spell to test
                if spellToCast == spellToTest then
                    -- Check if the recast time is 0
                    if spellRecast == 0 then
                        -- Cast the spell on the target
                        send_command(
                            string.format(
                                'input /ma "%s" <t>',
                                spellToCast.name
                            )
                        )
                    end
                else
                    -- Check if the recast time is 0
                    if spellRecast == 0 then
                        -- Cast the first spell, wait for x seconds, then cast the second spell
                        send_command(
                            string.format(
                                'input /ma "%s" <t>; wait 6; input /ma "%s" <t>',
                                spellToCast.name,
                                spellToTest.name
                            )
                        )
                    else
                        -- Check if the recast time is greater than 0
                        if spellRecast > 0 then
                            spellToTest = spellToTest + 1 -- Increment the spell to test
                        end
                        -- Cast the spell to test on the target
                        send_command(
                            string.format(
                                'input /ma "%s" <t>',
                                spellToTest.name
                            )
                        )
                    end
                end
            end
        else
            -- Check the step of the spell to cast
            if spellToCast.step == 'Aftercast' then
                -- Cast the spell on the target
                send_command(
                    string.format(
                        'input /ma "%s" <t>',
                        spellToCast.name
                    )
                )
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
                    string.format(
                        'input /ma "%s" <t>; wait 6; input /ma "%s" <t>',
                        spellToCast.name,
                        spellToTest.name
                    )
                )
            end
        end
        -- Check if there are messages in the table
        checkAndDisplayMessages(messages)
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
            local message = createFormatMsg('Cannot Use:', spell.name, nil, value)
            add_to_chat(167, message)
            return true, value
        end
    end
    -- If no incapacitated state is detected, return false and nil for the incapacitation type and name
    return false, nil
end

-- Checks the current main weapon set and equips the corresponding gear.
function check_weaponset()
    -- Equip the gear set based on the current state of the WeaponSet
    if player.main_job ~= 'BLM' then
        equip(sets[state.WeaponSet.current])
    end
end

-- Checks the current sub weapon set and equips the corresponding gear.
function check_subset()
    -- Equip the gear set based on the current state of the SubSet
    if state.SubSet then
        equip(sets[state.SubSet.current])
    end
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
        handleCompletedSpell(spell, eventArgs)
    end
end

-- Handles actions to be performed when a spell is completed normally.
-- Parameters:
--   spell (table): The completed spell.
function handleCompletedSpell(spell, eventArgs)
    -- Perform appropriate actions after the spell is completed normally
    if state.Moving.value == 'true' then
        -- Equip the MoveSpeed gear set
        send_command('gs equip sets.MoveSpeed')
    end
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
            if state.Moving.value == 'true' then
                -- Equip the MoveSpeed gear set
                send_command('gs equip sets.MoveSpeed')
            end
        else
            -- Buff is lost, update sets and display a message
            enable('neck')
            send_command('gs c update')
            local message = createFormatMsg(nil, 'Doom', nil, 'is no longer active!')
            add_to_chat(123, message)
            if state.Moving.value == 'true' then
                -- Equip the MoveSpeed gear set
                send_command('gs equip sets.MoveSpeed')
            end
        end
    end
    if player.main_job == 'THF' then
        if state.Buff[buff] ~= nil then
            state.Buff[buff] = gain
            if not midaction() then
                handle_equipping_gear(player.status) -- Handle gear setup when specific buffs change.
            end
        end
    end
    if player.main_job == 'BLM' then
        if buff == 'Manawall' then
            if gain then
                equip({
                    back == "Taranus's Cape",
                    feet == "Wicce sabot +3",
                })
                disable(back, feet)
            else
                enable(back, feet)
            end
        end
    end
end

-- update the table with actual Step Cast of spell
function updateTable(table, spellName, step)
    for i, spell in ipairs(table) do
        if spell.name == spellName then
            spell.step = step
            return
        end
    end
end

-- Check if there are messages in the table
function checkAndDisplayMessages(msgTable)
    if #msgTable > 0 then
        -- Sort the messages table based on recast time in ascending order
        table.sort(
            msgTable,
            function(a, b)
                return a.recast < b.recast
            end
        )
    end

    -- Display each spell message in the messages table
    for i, msgData in ipairs(msgTable) do
        local isLast = (i == #msgTable) -- Check if it's the last message
        add_to_chat(167,
        createFormatMsg(nil, msgData.spell, msgData.recast, nil, isLast)) -- Output the spell message
    end
end

-- Handles custom commands specific to the job.
-- Parameters:
--   cmdParams (table): The command parameters
--   eventArgs (table): Additional event arguments
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'btank' then
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send Kaories haste2 ' .. targetid .. '; wait 4; send Kaories refresh3 ' .. targetid .. '; wait 5; send Kaories phalanx2 ' .. targetid .. '; wait 5; send Kaories regen2 ' .. targetid)
    elseif cmdParams[1]:lower() == 'bdd' then
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send Kaories haste2 ' .. targetid .. '; wait 4; send Kaories phalanx2 ' .. targetid .. '; wait 4; send Kaories regen2 ' .. targetid)
    elseif cmdParams[1]:lower() == 'bddrng' then
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send Kaories flurry2 ' .. targetid .. '; wait 4; send Kaories phalanx2 ' .. targetid .. '; wait 4; send Kaories regen2 ' .. targetid)
    elseif cmdParams[1]:lower() == 'curaga' then
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send Kaories curaga3 ' .. targetid)
    elseif cmdParams[1]:lower() == 'debuff' then
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send Kaories distract3 ' .. targetid .. '; wait 6; send Kaories dia3 ' .. targetid .. '; wait 4; send Kaories slow2 ' .. targetid .. '; wait 5; send Kaories Blind2 ' .. targetid .. '; wait 5; send Kaories paralyze2 ' .. targetid)
    end
    if player.main_job == 'PLD' and player.sub_job == 'BLU' then
        if cmdParams[1]:lower() == 'single' then
            handleSingleCommand() -- Handle the "single" command
        elseif cmdParams[1]:lower() == 'aoe' then
            handleAoeCommand() -- Handle the "aoe" command
        end
    end
    if player.main_job == 'BLM' then
        local tierSpell = state.TierSpell.value
        local mainLight = state.MainLightSpell.value
        local subLight = state.SubLightSpell.value
        local mainDark = state.MainDarkSpell.value
        local subDark = state.SubDarkSpell.value
        local ajaSpell = state.Aja.value
        local StormSpell = state.Storm.value
        if cmdParams[1]:lower() == 'buffself' then
            BuffSelf()
        elseif cmdParams[1]:lower() == 'mainlight' then
            local spellToCast = mainLight .. tierSpell
            send_command('input /ma "' .. spellToCast .. '" <stnpc>')
        elseif cmdParams[1]:lower() == 'sublight' then
            local spellToCast = subLight .. tierSpell
            send_command('input /ma "' .. spellToCast .. '" <stnpc>')
        elseif cmdParams[1]:lower() == 'maindark' then
            local spellToCast = mainDark .. tierSpell
            send_command('input /ma "' .. spellToCast .. '" <stnpc>')
        elseif cmdParams[1]:lower() == 'subdark' then
            local spellToCast = subDark .. tierSpell
            send_command('input /ma "' .. spellToCast .. '" <stnpc>')
        elseif cmdParams[1]:lower() == 'aja' then
            local spellToCast = ajaSpell
            send_command('input /ma "' .. spellToCast .. '" <stnpc>')
        elseif cmdParams[1]:lower() == 'lightarts' then
            if not buffactive['Light Arts'] then
                send_command('input /ja "Light Arts" <me>')
            else
                send_command('input /ja "Addendum: White" <me>')
            end
        elseif cmdParams[1]:lower() == 'darkarts' then
            if not buffactive['Dark Arts'] then
                send_command('input /ja "Dark Arts" <me>')
            else
                send_command('input /ja "Addendum: Black" <me>')
            end
        elseif cmdParams[1]:lower() == 'storm' then
            local spellToCast = StormSpell
            if not buffactive['Klimaform'] then
                send_command('input /ma "Klimaform" <me>; wait 4; input /ma "' .. spellToCast .. '" <me>')
            else
                send_command('input /ma "' .. spellToCast .. '" <me>')
            end
        end
        if player.sub_job == 'SCH' then
            if cmdParams[1]:lower() == 'blindna' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Blindna" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Blindna" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Blindna" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'poisona' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Poisona" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Poisona" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Poisona" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'viruna' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Viruna" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Viruna" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Viruna" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'stona' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Stona" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Stona" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Stona" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'silena' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Silena" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Silena" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Silena" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'paralyna' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Paralyna" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Paralyna" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Paralyna" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'cursna' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Cursna" <stal>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Cursna" <stal>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Cursna" <stal>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'erase' then
                if buffactive['addendum: white'] then
                    send_command('input /ma "Erase" <stpc>')
                    return
                elseif buffactive['white arts'] and not buffactive['addendum: white'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: White" <me>; wait 1; input /ma "Erase" <stpc>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Addendum: White" <me>; wait 1; input /ma "Erase" <stpc>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'dispel' then
                if buffactive['addendum: black'] then
                    send_command('input /ma "Dispel" <stnpc>')
                    return
                elseif buffactive['dark arts'] and not buffactive['addendum: black'] then
                    if stratagems_available() then
                        send_command('input /ja "Addendum: Black" <me>; wait 1; input /ma "Dispel" <stnpc>')
                    end
                else
                    if stratagems_available() then
                        send_command('input /ja "Dark Arts" <me>; wait 2; input /ja "Addendum: Black" <me>; wait 1; input /ma "Dispel" <stnpc>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'sneak' then
                if buffactive['Light Arts'] or buffactive['Addendum: White'] then
                    if stratagems_available() then
                        send_command('input /ja "Accession" <me>; wait 1; input /ma "Sneak" <stpt>')
                    else
                        send_command('input /ma "Sneak" <stpt>')
                    end
                else
                    if stratagems_available() then
                    send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Accession" <me>; wait 1; input /ma "Sneak" <stpt>')
                else
                    send_command('input /ja "Light Arts" <me>; wait 1; input /ma "Sneak" <stpt>')
                    end
                end
            end
            if cmdParams[1]:lower() == 'invi' then
                if buffactive['Light Arts'] or buffactive['Addendum: White'] then
                    if stratagems_available() then
                        send_command('input /ja "Accession" <me>; wait 1; input /ma "Invisible" <stpt>')
                    else
                        send_command('input /ma "Invisible" <stpt>')
                    end
                else
                    if stratagems_available() then
                    send_command('input /ja "Light Arts" <me>; wait 2; input /ja "Accession" <me>; wait 1; input /ma "Invisible" <stpt>')
                else
                    send_command('input /ja "Light Arts" <me>; wait 1; input /ma "Invisible" <stpt>')
                    end
                end
            end
        end
    end
    if player.main_job == 'WAR' then
    -- Check the input command parameters
        if cmdParams[1] == 'Berserk' then
            local buffDefender = buffactive['Defender']
            -- Cancel Defender if active
            if buffDefender then
                send_command('cancel defender')
            end
            -- Call buffSelf with the appropriate parameter
            buffSelf('Berserk')
        elseif cmdParams[1] == 'Defender' then
            local buffBerserk = buffactive['Berserk']
            -- Handle HybridMode if necessary
            if state.HybridMode.value == 'Normal' then
                send_command('gs c set HybridMode PDT')
            end
            -- Cancel Berserk if active
            if buffBerserk then
                send_command('cancel berserk')
            end
            -- Call buffSelf with the appropriate parameter
            buffSelf('Defender')
        elseif cmdParams[1] == 'ThirdEye' then
            -- Call ThirdEye function
            ThirdEye()
        elseif cmdParams[1] == 'Jump' then
            -- Call Jump function
            jump()
        end
    end
    if player.main_job == 'DNC' then
        if cmdParams[1] == 'step' then
            if cmdParams[2] == 't' then
                local doStep = ''
                if state.UseAltStep.value == true then
                    doStep = state[state.CurrentStep.current .. 'Step'].current
                    state.CurrentStep:cycle()
                else
                    doStep = state.MainStep.current
                end
                if player.target.name ~= nil and player.target.hpp > 5 and player.tp >= 100 then
                    send_command('@input /ja "' .. doStep .. '" <t>')
                else
                    send_command('@input /echo Unable to cast ' .. doStep .. '')
                end
            end
        end
    end
end


-- Calculates and returns the maximum number of SCH stratagems available for use.
function get_max_stratagem_count()
    if S{player.main_job, player.sub_job}:contains('SCH') then
        local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
        return math.floor(((lvl  - 10) / 20) + 1)
    else
        return 0
    end
end

--[[ Calculates the number of SCH stratagems that are currently available for use.
    Calculated from the combined recast timer for stratagems and the maximum number of stratagems
    that are available.  The recast time for each stratagem charge corresponds directly with the
    maximum number of stratagems that can be used.  The table that links these is strat_charge_time,
    and is defined in mappings.lua. ]]
function get_available_stratagem_count()
    local recastTime = windower.ffxi.get_ability_recasts()[231] or 0
    local maxStrats = get_max_stratagem_count()
    if maxStrats == 0 then return 0 end
    local stratsUsed = (recastTime/strat_charge_time[maxStrats]):ceil()
    return maxStrats - stratsUsed
end

function stratagems_available()
    return get_available_stratagem_count() > 0
end

-- Function to handle the Jump ability
function jump()
    -- Initialize variables
    local messages = {}  -- Stores messages to display
    local jaName1 = 'Jump'  -- Name of the first jump ability
    local jaName2 = 'High Jump'  -- Name of the second jump ability
    local JaRecasts = windower.ffxi.get_ability_recasts()  -- Retrieves ability recast times
    local jumpId = 158  -- ID of the first jump ability
    local highJumpId = 159  -- ID of the second jump ability
    local playerTP = player.tp  -- Retrieves player's TP
    
    if playerTP < 1000 then
        -- Check if Jump and High Jump can be used
        if JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP < 500 then
            -- Execute command to use both jump abilities
            send_command(
                string.format('input /ja "%s" <t>; wait 1; input /ja "%s" <t>', jaName1, jaName2)
            )
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP > 500 and playerTP < 1000 then
            -- Execute command to use the first jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName1)
            )
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] > 1 then
            -- Execute command to use the first jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName1)
            )
        elseif JaRecasts[jumpId] > 1 and JaRecasts[highJumpId] < 1 then
            -- Execute command to use the second jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName2)
            )
        end
    else
            add_to_chat(057, "You have Enough TP !!!")
    end
end