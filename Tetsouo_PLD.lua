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
    include('SharedFunctions.lua') -- (Function Shared)
    include('PLD_FUNCTION.lua') -- (advanced function for Paladin)
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
    include('PLD_SET.lua')
end

-- Actions to perform before casting a spell or ability
function job_precast(spell, action, spellMap, eventArgs)
    if incapacitated(spell, eventArgs) then
    else
        auto_majesty(spell, eventArgs)
        auto_divineEmblem(spell, eventArgs)
        handleRecastCooldown(spell, eventArgs)
    end
end

-- Actions to perform during casting of a spell or ability
function job_midcast(spell, action, spellMap, eventArgs)
    incapacitated(spell, eventArgs)
end

-- Aftercast actions
function job_aftercast(spell, action, spellMap, eventArgs)
    handleSpellAftercast(spell, eventArgs)
end

-- Handle custom commands
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'single' then
        handleSingleCommand()
    elseif cmdParams[1]:lower() == 'aoe' then
        handleAoeCommand()
    end
end

-- Select the default macro book
function select_default_macro_book()
    if player.sub_job == 'WAR' then
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for sub job WAR
        send_command('wait 20; input /lockstyleset 4') -- Lockstyle command for sub job WAR
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 22) -- Set macro book page 1, macro 22 for sub job BLU
        send_command('wait 20; input /lockstyleset 3') -- Lockstyle command for sub job BLU
    else
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for other sub jobs
        send_command('wait 20;input /lockstyleset 4') -- Default lockstyle command
    end
end