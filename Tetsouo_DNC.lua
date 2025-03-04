--============================================================--
--=                        DANCER                            =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024/02/03                  =--
--============================================================--

-- Initializes GearSwap for the Dancer job by setting up the necessary libraries and files.
-- This function is called once when the script is loaded.

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('/Misc/0_AutoMove.lua')      -- Module for movement speed gear management
    include('/Misc/SharedFunctions.lua') -- Shared functions across jobs
    include('/DNC/DNC_SET.lua')          -- Dancer specific gear sets
    include('/DNC/DNC_FUNCTION.lua')     -- Advanced functions specific to Dancer
end

-- Initializes gear sets for the Dancer job.
-- This function is called once when the script is loaded.
function init_gear_sets()
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    include('Mote-TreasureHunter.lua') -- Includes the file for handling Treasure Hunter.
    -- Initializes the treasureHunter state variable from TreasureMode and sets default treasure mode
    treasureHunter = state.TreasureMode.value
    state.TreasureMode:set('tag')
    -- Configures hybrid and offense mode options
    state.HybridMode:options('PDT', 'Normal')
    state.OffenseMode:options('Normal', 'Acc')
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Twashtar', 'Mpu Gandring', 'Demersal', 'Tauret' } --gs c cycle WeaponSet
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Centovente', 'Blurred', 'Gleti' }                    --gs c cycle SubSet
    state.ammoSet = M { ['description'] = 'Ammo', 'Aurgelmir' }                                              --gs c cycle SubSet
    climactic = buffactive['climactic flourish'] or false
    building = buffactive['building flourish'] or false
    ternary = buffactive['ternary flourish'] or false
    state.MainStep = M { ['description'] = 'Main Step', 'Box Step', 'Quickstep', 'Stutter Step', 'Feather Step' }
    state.AltStep = M { ['description'] = 'Alt Step', 'Feather Step', 'Quickstep', 'Stutter Step', 'Box Step' }
    state.UseAltStep = M(true, 'Use Alt Step')
    state.SelectStepTarget = M(true, 'Select Step Target')
    state.CurrentStep = M { ['description'] = 'Current Step', 'Main', 'Alt' }
    state.SkillchainPending = M(false, 'Skillchain Pending')
    state.Buff['Climactic Flourish'] = buffactive['Climactic Flourish'] or false
    -- Defines options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi = M('Indi-Barrier', 'Indi-Refresh', 'Indi-Fend', 'Indi-Fury', 'Indi-Acumen', 'Indi-Precision',
        'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Refresh', 'Indi-Haste', 'Indi-AGI', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
    -- Sets up default job ability IDs for actions that always have Treasure Hunter
    info.default_ja_ids = S { 35, 204 }
    info.default_u_ja_ids = S { 201, 202, 203, 205, 207 }
end

function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    handle_spell(spell, eventArgs, auto_abilities) -- Handles the spell based on its type and the current state.
    checkDisplayCooldown(spell, eventArgs)         -- Checks and displays the cooldown for the spell.
    refine_Utsusemi(spell, eventArgs)
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell) -- Selects the earrings based on the weapon and TP.
    handle_presto_and_step(spell, eventArgs)
    auto_WS_flourish(spell)
    Ws_range(spell)
    -- Sets the state for the buff corresponding to the spell being cast to true, if it exists.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
end

-- Return true if we handled the aftercast work.  Otherwise it will fall back
-- to the general aftercast() code in Mote-Include.
function job_aftercast(spell, action, spellMap, eventArgs)
    if not spell.interrupted then
        if state.Buff[spell.english] ~= nil then
            state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
        end
    end
    -- Perform additional actions after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book based on the player's sub job.
-- This function is called once when the script is loaded.
function select_default_macro_book()
    -- Unloads the 'dressup' Lua script.
    send_command('lua unload dressup')
    -- If the player's sub-job is 'DNC', 'WAR', or 'NIN', selects the corresponding macro page. Otherwise, selects the first macro page.
    if player.sub_job == 'WAR' then
        set_macro_page(1, 6)
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 8)
    else
        set_macro_page(1, 6)
    end

    -- Waits for 15 seconds, locks the style set to 1, waits for another 5 seconds, and then loads the 'dressup' Lua script.
    send_command('wait 10;input /lockstyleset 2; wait 5; lua load dressup')
end
