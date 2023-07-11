--============================================================--
--=                        PALADIN                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-10                  =--
--============================================================--

-- Required library inclusions
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Inclusion of the Mote-Include.lua library (Version 2)
    include('0_AutoMove.lua') -- (Movement Speed Gear Management)
    include('SharedFunctions.lua') -- (Movement Speed Gear Management)
end

-- Initial job configuration
function job_setup()
    -- Check if the Sentinel buff is active
    state.Buff.Sentinel = buffactive['Sentinel'] or false
    -- Check if the Divine buff is active
    state.Buff.Divine = buffactive['Divine Emblem'] or false
    -- Check if the Doom buff is active
    state.Buff.Doom = buffactive['Doom'] or false
    -- Check if the Majesty buff is active
    state.Buff.Majesty = buffactive['majesty'] or false
end

-- User-specific configuration
function user_setup()
    -- Command to change hybrid mode: /console gs c cycle HybridMode
    state.HybridMode:options('PDT', 'MDT', 'Normal') -- Hybrid mode options: 'PDT' (physical), 'MDT' (magical), 'Normal'
    -- Command to cycle main weapon set: /console gs c cycle WeaponSet
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Main weapon choice: 'Burtgang', 'Naegling'
    -- Command to set sub weapon set: /console gs c set SubSet [Name of the set]
    state.SubSet = M {['description'] = 'Sub Weapon', 'Duban', 'Aegis', 'Ochain', 'Blurred'} -- Sub weapon choice: 'Duban', 'Aegis', 'Ochain', 'Blurred'
    -- Select default macro book
    select_default_macro_book()
end

-- Load gear sets
function init_gear_sets()
    -- Equipment sets for different weapons and shields
    sets['Burtgang'] = {main = 'Burtgang'}
    sets['Naegling'] = {main = 'Naegling'}
    sets['Ochain'] = {sub = 'Ochain'}
    sets['Aegis'] = {sub = 'Aegis'}
    sets['Duban'] = {sub = 'Duban'}
    sets['Blurred'] = {sub = 'Blurred Shield +1'}

    -- Include the PldSet.lua file containing equipment sets
    include('PLD_SET.lua')
end

-- Automatically casts the 'Majesty' ability before casting spells of the 'Healing Magic' type or the spell 'Protect V'
function auto_majesty(spell, eventArgs)
    -- Retrieve the recast time of 'Majesty'
    local MajestyCD = windower.ffxi.get_ability_recasts()[150]
    -- Retrieve the recast time of the spell
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
    -- Check if the spell belongs to the 'Healing Magic' category or if its name is 'Protect V', excluding 'Phalanx'
    if (spell.action_type == 'Magic' and spell.skill == 'Healing Magic') or spell.name == 'Protect V' then
        -- Check if the recast time of the spell is less than 1 second
        if spellRecast < 1 then
            -- Check if the player is not affected by the 'Amnesia' debuff and 'Majesty' is not already active
            if not (buffactive['Amnesia'] or buffactive['Silence']) and not buffactive['Majesty'] then
                -- Check if the recast time of 'Majesty' is less than 1 second
                if MajestyCD < 1 then
                    -- Cancel the current spell
                    cancel_spell()
                    -- Perform the command to cast 'Majesty', wait for 1 second, then cast the original spell on the original target
                    send_command(string.format('input /ja "Majesty" <me>; wait 1.2; input /ma "%s" %s', spell.name, spell.target.id))
                end
            end
        else
            eventArgs.handled = true -- Mark the event as handled
            cancel_spell() -- Cancel the current spell
        end
    end
end

-- Automatically use "Divine Emblem" ability
function auto_divineEmblem(spell, eventArgs)
    if spell.name == 'Flash' then
        local spellRecast = windower.ffxi.get_spell_recasts()[spell.id] -- Retrieve the recast time of the spell
        if spellRecast < 1 then -- Check if the recast time of the spell is less than 1 second
            local DivineEmblemCD = windower.ffxi.get_ability_recasts()[80] -- Retrieve the recast time of 'Divine Emblem'
            if DivineEmblemCD < 1 then -- Check if the recast time of 'Divine Emblem' is less than 1 second
                if not state.Buff.Divine then -- Check if the 'Divine' buff is not active
                    cancel_spell() -- Cancel the current spell
                    -- Perform the command to cast 'Divine Emblem', wait for 1 second, then cast the original spell on the original target
                    send_command('input /ja "Divine Emblem" <me>; wait 1.2; input /ma "' .. spell.name .. '" ' .. spell.target.id)
                end
            end
        else
            eventArgs.handled = true -- Mark the event as handled
            cancel_spell() -- Cancel the current spell
        end
    end
end

-- Actions to perform before casting a spell or ability
function job_precast(spell, action, spellMap, eventArgs)
    -- Get the incapacitation state and name
    local isIncapacitated, incapType = incapacitated()
    if isIncapacitated then
        eventArgs.handled = true
        equip(sets.idle)
        local message = string.char(0x1F, 159) .. "Cannot use: [" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 159) .. "]" ..
                        " Incapacitated: (" .. string.char(0x1F, 221) .. incapType .. string.char(0x1F, 159) .. ")"
        add_to_chat(167, message)
        return
    end
    -- Rest of the code for precast actions
    auto_majesty(spell, eventArgs)
    auto_divineEmblem(spell, eventArgs)
    handleRecastCooldown(spell, eventArgs)
end

-- Actions to perform during casting of a spell or ability
function job_midcast(spell, action, spellMap, eventArgs)
    -- Check for incapacitated state
    if incapacitated() then
        eventArgs.handled = true
        equip(sets.idle)
        return
    end
end

-- Aftercast actions
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Check if the spell is Crusade, Reprisal, Phalanx, or Cocoon
    if spell.name == 'Crusade' or spell.name == 'Reprisal' or spell.name == 'Phalanx' or spell.name == 'Cocoon' then
        if spell.interrupted then
            -- The spell was interrupted
            -- Perform the appropriate actions
            eventArgs.handled = true
            equip(sets.idle)
            local message = string.char(0x1F, 159) .. "Spell interrupted: [" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 159) .. "]"
            add_to_chat(123, message)
            add_to_chat(259, "=======================================")
        else
            -- The spell completed normally
            -- Perform the appropriate actions after the spell
        end
    else
        -- Process other spells
        if not spellHandled then
            if spell.interrupted then
                -- The spell was interrupted
                -- Perform the appropriate actions
                eventArgs.handled = true
                equip(sets.idle)
                local message = string.char(0x1F, 159) .. "Spell interrupted: [" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 159) .. "]"
                add_to_chat(123, message)
                add_to_chat(259, "=======================================")
            else
                -- The spell completed normally
                -- Perform the appropriate actions after the spell
            end
            -- Mark the spell as handled
            spellHandled = true
        else
            -- Reset the variable for subsequent spells
            spellHandled = false
        end
    end
end

-- Variables to store the spell IDs
local spellsSingle = {
    Flash = 112,
    BlankGaze = 592
}

local spellsAoe = {
    GeistWall = 605,
    SheepSong = 584,
    Jettatura = 575
}

-- Helper function to handle the Single command logic
local function handleSingleCommand()
    local messages = {}
    local recastFlash = windower.ffxi.get_spell_recasts()[spellsSingle.Flash]
    local recastBlankGaze = windower.ffxi.get_spell_recasts()[spellsSingle.BlankGaze]
    if recastFlash < 1 then
        send_command('input /ma "Flash" <stnpc>')
    elseif recastFlash > 1 and recastBlankGaze < 1 then
        send_command('input /ma "Blank Gaze" <stnpc>')
    else
        if recastFlash > 0 then
            local message = createMessage("Flash", recastFlash / 60)
            table.insert(messages, { spell = "Flash", recast = recastFlash, message = message })
        end
        if recastBlankGaze > 0 then
            local message = createMessage("Blank Gaze", recastBlankGaze / 60)
            table.insert(messages, { spell = "Blank Gaze", recast = recastBlankGaze, message = message })
        end
    end
    if #messages > 0 then
        table.sort(messages, function(a, b) return a.recast < b.recast end) -- Sort messages by recast time in ascending order
        add_to_chat(159, "No spells available")
        for _, msgData in ipairs(messages) do
            add_to_chat(167, msgData.message)
        end
        add_to_chat(259, "=======================================")
    end
end

-- Helper function to handle the Aoe command logic
local function handleAoeCommand()
    local messages = {}
    local recastGeistWall = windower.ffxi.get_spell_recasts()[spellsAoe.GeistWall]
    local recastSheepSong = windower.ffxi.get_spell_recasts()[spellsAoe.SheepSong]
    local recastJettatura = windower.ffxi.get_spell_recasts()[spellsAoe.Jettatura]
    if recastGeistWall < 1 then
        send_command('input /ma "Geist Wall" <stnpc>')
    elseif recastGeistWall > 1 and recastSheepSong < 1 then
        send_command('input /ma "Sheep Song" <stnpc>')
    elseif recastGeistWall > 1 and recastSheepSong > 1 and recastJettatura < 1 then
        send_command('input /ma "Jettatura" <stnpc>')
    else
        if recastGeistWall > 0 then
            local message = createMessage("Geist Wall", recastGeistWall / 60)
            table.insert(messages, { spell = "Geist Wall", recast = recastGeistWall, message = message })
        end
        if recastSheepSong > 0 then
            local message = createMessage("Sheep Song", recastSheepSong / 60)
            table.insert(messages, { spell = "Sheep Song", recast = recastSheepSong, message = message })
        end
        if recastJettatura > 0 then
            local message = createMessage("Jettatura", recastJettatura / 60)
            table.insert(messages, { spell = "Jettatura", recast = recastJettatura, message = message })
        end
    end
    if #messages > 0 then
        table.sort(messages, function(a, b) return a.recast < b.recast end) -- Sort messages by recast time in ascending order
        add_to_chat(159, "No spells available")
        for _, msgData in ipairs(messages) do
            add_to_chat(167, msgData.message)
        end
        add_to_chat(259, "=======================================")
    end
end

-- Handle custom commands
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'single' then
        handleSingleCommand()
        eventArgs.handled = true
    elseif cmdParams[1]:lower() == 'aoe' then
        handleAoeCommand()
        eventArgs.handled = true
    end
end

-- Select the default macro book
function select_default_macro_book()
    if player.sub_job == 'WAR' then
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for sub job WAR
        send_command('wait 20;input /lockstyleset 4') -- Lockstyle command for sub job WAR
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 22) -- Set macro book page 1, macro 22 for sub job BLU
        send_command('wait 20;input /lockstyleset 3') -- Lockstyle command for sub job BLU
    else
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for other sub jobs
        send_command('wait 20;input /lockstyleset 4') -- Default lockstyle command
    end
end