--============================================================--
--=                        PALADIN                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-10                  =--
--============================================================--

-- Includes the necessary libraries and files
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Inclusion of the Mote-Include.lua library (Version 2)
    include('0_AutoMove.lua') -- Includes the AutoMove.lua file for movement speed gear management
    include('SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions
    include('PLD_FUNCTION.lua') -- Includes the PLD_FUNCTION.lua file for advanced functions specific to Paladin
end

-- Handles user-specific configuration and setup
function user_setup()
    -- Command to change hybrid mode: /console gs c cycle HybridMode
    state.HybridMode:options('PDT', 'MDT', 'Normal') -- Hybrid mode options: 'PDT' (physical), 'MDT' (magical), 'Normal'
    -- Command to cycle main weapon set: /console gs c cycle WeaponSet
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Burtgang', 'Naegling'} -- Main weapon choice: 'Burtgang', 'Naegling'
    -- Command to set sub weapon set: /console gs c cycle SubSet
    state.SubSet = M {['description'] = 'Sub Weapon', 'Duban', 'Aegis', 'Ochain', 'Blurred'} -- Sub weapon choice: 'Duban', 'Aegis', 'Ochain', 'Blurred'

    -- Select default macro book
    select_default_macro_book()

    -- Keybinds --
    send_command('bind F9 gs c cycle HybridMode')
    send_command('bind F10 gs c cycle WeaponSet')
    send_command('bind F11 gs c cycle SubSet')

    -- [gs c Single] subjob/Blu cast spell from PLD_FUNCTION.lua table spellsSingle:
    -- Flash
    -- Blank Gaze

    -- [gs c Aoe] subjob/Blu cast spell from PLD_FUNCTION.lua table spellsAoe:
    -- Jettatura
    -- Sheep Song
    -- Geist Wall  
end

-- Handles the unload event when changing job or reloading the file
function file_unload()
    -- Unbind the keys associated with the states
    unbind_key('^F9')
    unbind_key('^F10')
    unbind_key('^F11')
end

-- Loads the gear sets from the PLD_SET.lua file
function init_gear_sets()
    include('PLD_SET.lua') -- Includes the PLD_SET.lua file for gear sets
end

-- Handles actions and checks to perform before casting a spell or ability
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    if incapacitated(spell, eventArgs) then
        -- Spell cannot be cast due to incapacitation, no further actions needed
    else
        auto_majesty(spell, eventArgs) -- Automatically cast Majesty ability before certain spells
        auto_divineEmblem(spell, eventArgs) -- Automatically use Divine Emblem ability
        handleRecastCooldown(spell, eventArgs) -- Handle recast cooldown and display messages
    end
end

-- Handles actions to perform during the casting of a spell or ability
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    incapacitated(spell, eventArgs) -- Check for incapacitated state
end

-- Handles actions to perform after the casting of a spell or ability
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    handleSpellAftercast(spell, eventArgs) -- Perform actions after the spell is cast
end

-- Handles custom commands specific to the job
-- Parameters:
--   cmdParams (table): The command parameters
--   eventArgs (table): Additional event arguments
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'single' then
        handleSingleCommand() -- Handle the "single" command
    elseif cmdParams[1]:lower() == 'aoe' then
        handleAoeCommand() -- Handle the "aoe" command
    end
end

-- Sets the default macro book based on the player's sub job
function select_default_macro_book()
--              WAR              
    if player.sub_job == 'WAR' then
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for sub job WAR
        send_command('wait 20; input /lockstyleset 4') -- Lockstyle command for sub job WAR
--              BLU                           
    elseif player.sub_job == 'BLU' then
        set_macro_page(1, 22) -- Set macro book page 1, macro 22 for sub job BLU
        send_command('wait 20; input /lockstyleset 3') -- Lockstyle command for sub job BLU
--              Other            
    else
        set_macro_page(1, 21) -- Set macro book page 1, macro 21 for other sub jobs
        send_command('wait 20;input /lockstyleset 4') -- Default lockstyle command
    end
end