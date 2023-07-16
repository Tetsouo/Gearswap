--============================================================--
--=                        PALADIN                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- Sets up the necessary libraries and files for Gearswap.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Includes the Mote-Include.lua library (Version 2)
    include('0_AutoMove.lua') -- Includes the AutoMove.lua file for movement speed gear management
    include('SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions
    include('PLD_FUNCTION.lua') -- Includes the PLD_FUNCTION.lua file for advanced functions specific to Paladin
end

-- Handles user-specific configuration and setup.
function user_setup()
    -- Hybrid mode options: 'PDT' (physical), 'MDT' (magical), 'Normal'
    state.HybridMode:options('PDT', 'MDT', 'Normal') -- Command to change hybrid mode: /console gs c cycle HybridMode
    -- Main weapon choice: 'Burtgang', 'Naegling'
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Command to cycle main weapon set: /console gs c cycle WeaponSet
    -- Sub weapon choice: 'Duban', 'Aegis', 'Ochain', 'Blurred'
    state.SubSet = M {['description'] = 'Sub Weapon', 'Duban', 'Aegis', 'Ochain', 'Blurred'} -- Command to cycle sub weapon set: /console gs c cycle SubSet
    -- Calls the function to select the default macro book
    select_default_macro_book()
    -- Binds F9 to cycle through hybrid modes
    send_command('bind F9 gs c cycle HybridMode')
    -- Binds F10 to cycle through main weapon sets
    send_command('bind F10 gs c cycle WeaponSet')
    -- Binds F11 to cycle through sub weapon sets
    send_command('bind F11 gs c cycle SubSet')

    -- [gs c Single] subjob/Blu cast spell from PLD_FUNCTION.lua table spellsSingle:
    -- Flash
    -- Blank Gaze

    -- [gs c Aoe] subjob/Blu cast spell from PLD_FUNCTION.lua table spellsAoe:
    -- Jettatura
    -- Sheep Song
    -- Geist Wall
end

-- Handles the unload event when changing job or reloading the file.
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('unbind F9')
    send_command('unbind F10')
    send_command('unbind F11')
end

-- Loads the gear sets from the PLD_SET.lua file.
function init_gear_sets()
    include('PLD_SET.lua')
end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    updateTable(spellsSingle, spell.name, 'Precast')
    updateTable(spellsAoe, spell.name, 'Precast')
    if incapacitated(spell, eventArgs, true) then
        -- Spell cannot be cast due to incapacitation, no further actions needed
    else
        auto_majesty(spell, eventArgs) -- Automatically cast Majesty ability before certain spells
        auto_divineEmblem(spell, eventArgs) -- Automatically use Divine Emblem ability
        checkDisplayCooldown(spell, eventArgs) -- Handle recast cooldown and display messages
    end
end

-- Handles actions to perform during the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    updateTable(spellsSingle, spell.name, 'Midcast')
    updateTable(spellsAoe, spell.name, 'Midcast')
    incapacitated(spell, eventArgs) -- Check for incapacitated state
end

-- Handles actions to perform after the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    updateTable(spellsSingle, spell.name, 'Aftercast')
    updateTable(spellsAoe, spell.name, 'Aftercast')
    handleSpellAftercast(spell, eventArgs) -- Perform actions after the spell is cast
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    -- If sub job is WAR
    if player.sub_job == 'WAR' then
        -- If sub job is BLU
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for sub job WAR
        send_command('wait 20; input /lockstyleset 4') -- Lockstyle command for sub job WAR
    elseif player.sub_job == 'BLU' then
        -- For other sub jobs
        set_macro_page(1, 23) -- Set macro book page 1, macro 22 for sub job BLU
        send_command('wait 20; input /lockstyleset 3') -- Lockstyle command for sub job BLU
    else
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for other sub jobs
        send_command('wait 20;input /lockstyleset 4') -- Default lockstyle command
    end
end