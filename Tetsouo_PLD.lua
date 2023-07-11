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
    -- List of incapacitated states
    incapacitated_states =
        T {
        'Stun', -- Stun status
        'Petrification', -- Petrification status
        'Terror', -- Terror status
        'Sleep', -- Sleep status
    }
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

-- Check current main weapon set
function check_weaponset()
    equip(sets[state.WeaponSet.current])
end

-- Check current sub weapon set
function check_subset()
    equip(sets[state.SubSet.current])
end

-- Automatically casts the 'Majesty' ability before casting spells of the 'Healing Magic' type or the spell 'Protect V'
function auto_majesty(spell, eventArgs)
    -- Retrieve the recast time of 'Majesty'
    local MajestyCD = windower.ffxi.get_ability_recasts()[150]
    -- Retrieve the recast time of the spell
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
    -- Check if the spell belongs to the 'Healing Magic' category or if its name is 'Protect V', excluding 'Phalanx'
    if (spell.name == 'Cure III' or spell.name == 'Cure IV' or spell.name == 'Protect V') and spell.name ~= 'Phalanx' then
        -- Check if the recast time of the spell is less than 1 second
        if spellRecast < 1 then
            -- Check if the player is not affected by the 'Amnesia' debuff and 'Majesty' is not already active
            if not (buffactive['Amnesia'] or buffactive['Silence']) and not buffactive['Majesty'] then
                -- Check if the recast time of 'Majesty' is less than 1 second
                if MajestyCD < 1 then
                    -- Cancel the current spell
                    cancel_spell()
                    -- Perform the command to cast 'Majesty', wait for 1 seconds, then cast the original spell on the original target
                    send_command(string.format('input /ja "Majesty" <me>; wait 1.1; input /ma "%s" %s', spell.name, spell.target.name))
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
                    -- Perform the command to cast 'Divine Emblem', wait for 1 seconds, then cast the original spell on the original target
                    send_command('input /ja "Divine Emblem" <me>; wait 1; input /ma "' .. spell.name .. '" ' .. spell.target.id)
                end
            end
        else
            eventArgs.handled = true -- Mark the event as handled
            cancel_spell() -- Cancel the current spell
        end
    end
end

-- Check for incapacitated state
function incapacitated()
    -- Iterate over each value in the incapacitated_states table
    for _, value in ipairs(incapacitated_states) do
        -- Check if the value exists as a buff in the buffactive table
        if buffactive[value] then
            -- If an incapacitated state is detected, equip the idle gear and return the incapacitation type and name
            equip(sets.idle)
            return true, value
        end
    end
    -- If no incapacitated state is detected, return false and nil for the incapacitation type and name
    return false, nil
end

-- Check the recast time of a spell or ability and cancel the action if not ready
function handleRecastCooldown(spell, eventArgs)
    -- Retrieve the recast time of the spell or ability
    local recast = 0
    if spell.action_type == 'Magic' then
        recast = windower.ffxi.get_spell_recasts()[spell.id] / 1000 -- Convert milliseconds to seconds
    elseif spell.action_type == 'Ability' then
        recast = windower.ffxi.get_ability_recasts()[spell.recast_id] -- Recasts are already in seconds
    end
    -- If recast is greater than 0, cancel the action and display a message indicating the remaining recast time
    if recast > 0 then
        cancel_spell()
        eventArgs.cancel = true
        -- Format the message based on the recast time, either in minutes or seconds
        local recastFormatted = ""
        if recast >= 60 then
            local minutes = math.floor(recast / 60)
            local seconds = math.floor(recast % 60)
            recastFormatted = string.format("%02d:%02d min", minutes, seconds)
        else
            recastFormatted = string.format("%.1f sec", recast)
        end
        -- Display the formatted message indicating the remaining recast time
        local message = 
            string.char(0x1F, 159) .. "Cannot use: " ..
            string.char(0x1F, 050) .. "[" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 050) .. "]" ..
            string.char(0x1F, 159) .. " Recast: " ..
            string.char(0x1F, 050) .. "(" .. string.char(0x1F, 221) .. recastFormatted .. string.char(0x1F, 050) .. ")"
        add_to_chat(167, message)
    end
end

-- Actions to perform before casting a spell or ability
function job_precast(spell, action, spellMap, eventArgs)
    -- Get the incapacitation state and name
    local isIncapacitated, incapType = incapacitated()
    if isIncapacitated then
        eventArgs.handled = true
        equip(sets.idle)
        local message =
            string.char(0x1F, 159) .. "Cannot use: " ..
            string.char(0x1F, 050) .. "[" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 050) .. "]" ..
            string.char(0x1F, 159) .. " Incapacitated: " ..
            string.char(0x1F, 050) .. "(" .. string.char(0x1F, 221) .. incapType .. string.char(0x1F, 050) .. ")"
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

-- Variable pour suivre si le sort a déjà été traité
local spellHandled = false

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Check if the spell is Crusade, Reprisal, Phalanx or Cocoon
    if spell.name == 'Crusade' or spell.name == 'Reprisal' or spell.name == 'Phalanx' or spell.name == 'Cocoon' then
        if spell.interrupted then
            -- The spell was interrupted
            -- Perform the appropriate actions, for example:
            eventArgs.handled = true
            equip(sets.idle)
            local message =
                string.char(0x1F, 159) .. "Spell interrupted: " ..
                string.char(0x1F, 050) .. "[" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 050) .. "]"
                add_to_chat(123, message)
        else
            -- The spell completed normally
            -- Perform the appropriate actions after the spell
        end
    else
        -- Process other spells
        if not spellHandled then
            if spell.interrupted then
                -- The spell was interrupted
                -- Perform the appropriate actions, for example:
                eventArgs.handled = true
                equip(sets.idle)
                local message =
                string.char(0x1F, 159) .. "Spell interrupted: " ..
                string.char(0x1F, 050) .. "[" .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 050) .. "]"
                add_to_chat(123, message)
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

-- Perform actions when a buff changes
function job_buff_change(buff, gain)
    -- Check if the buff changed is 'Doom'
    if buff == 'Doom' then
        -- Check if the buff was gained
        if gain then
            -- Equip the 'Doom' buff set
            equip(sets.buff.Doom)
            -- Disable the 'neck' slot
            disable('neck')
        else
            -- Enable the 'neck' slot
            enable('neck')
        end
    end
end

-- Customize the idle gear set
function customize_idle_set(idleSet)
    -- Check if 'Doom' buff is active
    local isDoomActive = buffactive['Doom']
    -- Set the default idle gear set based on HybridMode
    if state.HybridMode.value == 'PDT' then
        idleSet = sets.idle
    elseif state.HybridMode.value == 'Ody' then
        idleSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' then
        idleSet = set_combine(sets.idle, sets.defense.MDT)
    elseif state.HybridMode.value == 'Normal' then
        idleSet = set_combine(sets.idle, sets.engaged)
    else
        idleSet = set_combine(sets.idle, sets.buff.Doom)
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

-- Customize the gear set for melee mode
function customize_melee_set(meleeSet)
    -- Check if 'Doom' buff is active
    local isDoomActive = buffactive['Doom']
    -- Set the default melee gear set based on HybridMode
    if state.HybridMode.value == 'PDT' then
        meleeSet = sets.idle
    elseif state.HybridMode.value == 'Ody' then
        meleeSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' then
        meleeSet = set_combine(sets.idle, sets.defense.MDT)
    elseif state.HybridMode.value == 'Normal' then
        meleeSet = set_combine(sets.idle, sets.engaged)
    else
        meleeSet = set_combine(sets.idle, sets.buff.Doom)
    end
    return meleeSet
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