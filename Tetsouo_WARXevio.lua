--============================================================--
--=                        WARRIOR                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

-- Initializes GearSwap for the Warrior job by setting up the necessary libraries and files.
-- This function is called once when the script is loaded.
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    -- Include necessary libraries and modules
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('/Misc/0_AutoMove.lua')      -- Module for movement speed gear management
    include('/Misc/SharedFunctions.lua') -- Shared functions across jobs
    include('/WAR/WAR_SET_Xevio.lua')    -- Warrior specific gear sets
    include('/WAR/WAR_FUNCTION.lua')     -- Advanced functions specific to Warrior
end

function init_gear_sets()
end

-- Initializes the Warrior job script.
-- This function is called once when the script is loaded.
function job_setup()
    -- Sets the options for the hybrid mode.
    state.HybridMode:options('PDT', 'Normal')

    -- Sets the options for the main weapon set.
    state.WeaponSet = M { ['description'] = 'Main Weapon','Shining', 'Ukonvasara',}
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Utu Grip'}
    state.ammoSet = M { ['description'] = 'Ammo', 'Aurgelmir Orb +1' }

    -- Binds keys to cycle through hybrid modes and weapon sets.
    send_command('bind F9 gs c cycle HybridMode')
    send_command('bind F10 gs c cycle WeaponSet')
    send_command('bind F11 gs c cycle SubSet')

    -- Sets the options for the alternative player state.
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Fury', 'Indi-Agi', 'Indi-Refresh', 'Indi-Barrier', 'Indi-Fend', 'Indi-Acumen',
        'Indi-Precision',
        'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Refresh', 'Indi-Barrier', 'Indi-Haste', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end

function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

-- Cleans up the Warrior job script.
-- This function is called once when the script is unloaded.
function file_unload()
    -- Unbinds the keys previously bound to cycle through states.
    send_command('unbind F9')
    send_command('unbind F10')
    send_command('unbind F11')
end

-- Prepares for the casting of a spell or ability.
-- This function is called before each spell or ability is cast.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- Handle the spell casting
    handle_spell(spell, eventArgs, auto_abilities)
    -- Check and display the recast cooldown
    checkDisplayCooldown(spell, eventArgs)
    Ws_range(spell)
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
end

-- Manages actions during the casting of a spell or ability.
-- This function is called during each spell or ability cast.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
end

-- Manages actions after a spell or ability has been cast.
-- This function is called after each spell or ability cast.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Handles actions to be performed after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    -- Unloads the dressup plugin.
    send_command('lua unload dressup')
    -- Sets the macro page and style set based on the sub job.
    if player.sub_job == 'DRG' then
        set_macro_page(1, 32)
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 30)
    else
        set_macro_page(1, 30)
    end
    -- Locks the style set.
    send_command('wait 15;input /lockstyleset 5; wait 5; lua load dressup')
end
