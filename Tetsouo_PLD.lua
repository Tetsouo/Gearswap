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
    -- Commande pour changer le mode hybride : /console gs c cycle HybridMode
    state.HybridMode:options('PDT', 'MDT', 'Normal') -- Hybrid mode options: 'PDT' (physical), 'MDT' (magical), 'Normal'
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Main weapon choice: 'Burtgang', 'Naegling'
-- Commande pour changer l'ensemble d'armes principales : /console gs c cycle WeaponSet
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Main weapon choice: 'Burtgang', 'Naegling'
    -- Commande pour changer l'ensemble d'armes secondaires : /console gs c set SubSet [Nom de l'ensemble]
    state.SubSet = M {['description'] = 'Sub Weapon', 'Duban', 'Aegis', 'Ochain', 'Blurred'} -- Sub weapon choice: 'Duban', 'Aegis', 'Ochain', 'Blurred'
    select_default_macro_book() -- Select default macro book
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
    include('PldSet.lua')
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
            -- If an incapacitated state is detected, equip the idle gear and return true
            equip(sets.idle)
            return true
        end
    end
    -- If no incapacitated state is detected, return false
    return false
end

-- Check the recast time of a spell or ability and cancel the action if not ready
function check_recast_and_cancel(spell, eventArgs)
    local recast = 0
    if spell.action_type == 'Magic' then
        recast = windower.ffxi.get_spell_recasts()[spell.id]
    elseif spell.action_type == 'Ability' then
        recast = windower.ffxi.get_ability_recasts()[spell.recast_id]
    end
    if recast > 0 then
        cancel_spell()
        eventArgs.cancel = true
        add_to_chat(167, string.char(0x1F, 167) .. 'Cannot use ' .. string.char(0x1F, 005) .. spell.name .. string.char(0x1F, 167) .. ' . Waiting on recast.')
    end
end

-- Actions to perform before casting a spell or ability
function job_precast(spell, action, spellMap, eventArgs)
    -- Check for incapacitated state
    if incapacitated() then
        eventArgs.handled = true
        equip(sets.idle)
        return
    end
    auto_majesty(spell, eventArgs)
    auto_divineEmblem(spell, eventArgs)
    check_recast_and_cancel(spell, eventArgs)
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
            add_to_chat(123, string.char(0x1F, 167) .. "Spell interrupted: " .. string.char(0x1F, 005) .. spell.name)
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
                add_to_chat(123, string.char(0x1F, 167) .. "Spell interrupted: " .. string.char(0x1F, 005) .. spell.name)
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