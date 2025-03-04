--============================================================--
--=                        RUNE FENCER                       =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 07/02/2024                  =--
--============================================================--

-- Initializes GearSwap for the Paladin job by setting up the necessary libraries and files.
-- This function is called once when the script is loaded.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('/Misc/0_AutoMove.lua')      -- Module for movement speed gear management
end

-- Initializes gear sets for the Paladin job.
-- This function is called once when the script is loaded.
function init_gear_sets()
end

-- Sets up user-specific configurations and binds keys for the Paladin job.
function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

-- Sets up user-specific configurations and binds keys for the Paladin job.
-- This function is called once when the script is loaded.
function job_setup()
    -- Define options for hybrid mode
    state.HybridMode:options('PDT', 'MDT')
    -- Define options for main weapon set
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Aettir', }
    -- Define options for sub weapon set
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Refined Grip +1', 'Utu Grip' }
    -- Define options for XP mode
    state.Xp = M { ['description'] = 'XP', 'False', 'True' }
    -- Bind keys to cycle through modes and sets
    send_command('bind F2 gs c cycle HybridMode')
    send_command('bind F3 gs c cycle WeaponSet')
    send_command('bind F4 gs c cycle SubSet')

    -- Define options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Haste', 'Geo-Malaise', 'Geo-Frailty',
        'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Refresh', 'Indi-Acumen', 'Indi-Fury')
    state.altPlayerEntrust = M('Indi-Fury', 'Indi-Refresh', 'Indi-Haste', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end

-- Handles the unload event when changing job or reloading the script.
-- This function is called once when the script is unloaded.
function file_unload()
    -- Unbind the keys associated with the hybrid mode, weapon set, and sub weapon set.
    send_command('unbind F2')  -- Unbind key for cycling hybrid mode
    send_command('unbind F3') -- Unbind key for cycling main weapon set
    send_command('unbind F4') -- Unbind key for cycling sub weapon set
end

-- Initializes the gear sets for the Paladin job.
-- This function is called once when the script is loaded.
function init_gear_sets()
    -- The actual gear sets are defined in the PLD_SET.lua file.
end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- If the spell is Phalanx, call the handle_phalanx_while_xp function
    if spell.name == 'Phalanx' then
        handle_phalanx_while_xp(spell, eventArgs)
    end
    -- Handle the spell casting
    handle_spell(spell, eventArgs, auto_abilities)
    -- Check and display the recast cooldown
    checkDisplayCooldown(spell, eventArgs)
end

-- Handles actions to perform during the casting of a spell or ability.
-- This function is called after the precast phase and before the aftercast phase.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    -- Check if the player is incapacitated
    --[[ incapacitated(spell, eventArgs) ]]
end

-- Handles actions to perform after the casting of a spell or ability.
-- This function is called after the spell or ability has been cast.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Perform actions specific to the spell that was cast
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book based on the player's sub job.
-- This function is called once when the script is loaded.
function select_default_macro_book()
    -- Unloads the 'dressup' Lua script.
    send_command('lua unload dressup')

    -- Set macro book and lockstyle based on sub job
    if player.sub_job == 'BLU' then
        set_macro_page(1, 23) -- BLU sub job
        send_command('wait 5; input /lockstyleset 3')
    elseif player.sub_job == 'WAR' then
        set_macro_page(1, 21) -- WAR sub job
        send_command('wait 5; input /lockstyleset 4')
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 28) -- RDM sub job
        send_command('wait 5; input /lockstyleset 3')
    else
        set_macro_page(1, 23) -- Default for other sub jobs
        send_command('wait 5; input /lockstyleset 3')
    end

    -- Waits for 15 seconds, locks the style set to 1, waits for another 5 seconds, and then loads the 'dressup' Lua script.
    send_command('wait 15; lua load dressup')
end
