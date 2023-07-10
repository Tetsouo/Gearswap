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
        'stun', -- Stun status
        'petrification', -- Petrification status
        'terror', -- Terror status
        'sleep' -- Sleep status
    }
end

-- User-specific configuration
function user_setup()
    state.HybridMode:options('PDT', 'MDT', 'Normal') -- Hybrid mode options: 'PDT' (physical), 'MDT' (magical), 'Normal'
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Main weapon choice: 'Burtgang', 'Naegling'
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

-- Function to automatically cast 'Majesty' ability
function auto_majesty(spell)
    -- Check if the spell belongs to the 'Healing Magic' category or if its name is 'Protect V'
    -- It should not be 'Phalanx'
    if (spell.skill == 'Healing Magic' or spell.name == 'Protect V') and spell.name ~= 'Phalanx' then
        -- Check if the player is not currently under 'Amnesia' debuff and 'Majesty' is not already active
        if not buffactive['Amnesia'] and not buffactive['Majesty'] then
            -- Check if the recast time for 'Majesty' is less than 1
            if windower.ffxi.get_ability_recasts()[150] < 1 then
                -- If all conditions are met, cancel the current spell
                cancel_spell()
                -- Cast 'Majesty', wait 1 second, then cast the original spell on the original target
                send_command('input /ja "Majesty" <me>; wait 1; input /ma "' .. spell.name .. '" ' .. spell.target.name)
            end
        end
    end
end

-- Automatically use "Divine Emblem" ability
function auto_divineEmblem(spell)
    if spell.name == 'Flash' then
        local allRecasts = windower.ffxi.get_ability_recasts()
        local DivineEmblemCD = allRecasts[80]
        if DivineEmblemCD < 1 then
            if state.Buff.Divine == false then
                cancel_spell()
                send_command(
                    'input /ja "Divine Emblem" <me>; wait 1; input /ma "' .. spell.name .. '"' .. spell.target.id
                )
            end
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

-- Actions to perform before casting a spell or ability
function job_precast(spell, action, spellMap, eventArgs)
    if incapacitated() then
        eventArgs.handled = true
        return
    end
    auto_majesty(spell)
    auto_divineEmblem(spell)
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

-- Actions to perform on buff change
function job_buff_change(buff, gain)
    -- Add actions to be performed when a buff changes
    -- Modify the function body as per your requirements
end

-- Customize the idle gear set
function customize_idle_set(idleSet)
    -- Check if 'Doom' buff is active
    local isDoomActive = buffactive['Doom']
    -- Set the default idle gear set based on HybridMode
    if state.HybridMode.value == 'PDT' and not isDoomActive then
        idleSet = sets.idle
    elseif state.HybridMode.value == 'Ody' and not isDoomActive then
        idleSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' and not isDoomActive then
        idleSet = set_combine(sets.idle, sets.defense.MDT)
    elseif state.HybridMode.value == 'Normal' and not isDoomActive then
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
    if state.HybridMode.value == 'PDT' and not isDoomActive then
        meleeSet = sets.idle
    elseif state.HybridMode.value == 'Ody' and not isDoomActive then
        meleeSet = sets.idle.Ody
    elseif state.HybridMode.value == 'MDT' and not isDoomActive then
        meleeSet = set_combine(sets.idle, sets.defense.MDT)
    elseif state.HybridMode.value == 'Normal' and not isDoomActive then
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