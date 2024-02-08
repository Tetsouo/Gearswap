--============================================================--
--=                        THIEF                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024/02/03                  =--
--============================================================--

-- Initializes GearSwap for the Thief job by setting up the necessary libraries and files.
-- This function is called once when the script is loaded.
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('/Misc/0_AutoMove.lua')      -- Module for movement speed gear management
    include('/Misc/SharedFunctions.lua') -- Shared functions across jobs
    include('THF/THF_SET.lua')           -- Thief specific gear sets
    include('/THF/THF_FUNCTION.lua')     -- Advanced functions specific to Thief
end

-- Initializes gear sets for the Thief job.
-- This function is called once when the script is loaded.
function init_gear_sets()
end

-- Sets up user-specific configurations and binds keys for the Thief job.
function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

-- Sets up user-specific configurations and binds keys for the Thief job.
-- This function is called once when the script is loaded.
function job_setup()
    include('Mote-TreasureHunter.lua') -- Includes the file for handling Treasure Hunter.
    -- Initializes the treasureHunter state variable from TreasureMode and sets default treasure mode
    treasureHunter = state.TreasureMode.value
    state.TreasureMode:set('tag')
    -- Sets up state variables for buffs
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    -- Configures hybrid and offense mode options
    state.HybridMode:options('PDT', 'Normal')
    state.OffenseMode:options('Normal', 'Acc')
    -- Define options for AbysseaProc mode
    state.AbysseaProc = M(false, 'Abyssea Proc')
    -- Configures gear sets for main and sub weapons
    state.WeaponSet1 = M { ['description'] = 'Main Weapon', 'Vajra', 'Malevolence' }
    state.WeaponSet2 = M { ['description'] = 'Main Weapon', 'Dagger', 'Sword', 'Great Sword', 'Polearm', 'Club', 'Staff', 'Scythe' }
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Gleti', 'Centovente', 'TwashtarS' }
    -- Sets up default job ability IDs for actions that always have Treasure Hunter
    info.default_ja_ids = S { 35, 204 }
    info.default_u_ja_ids = S { 201, 202, 203, 205, 207 }
    -- Defines options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi =
        M('Indi-Frailty', 'Indi-Refresh', 'Indi-Barrier', 'Indi-Fend', 'Indi-Fury', 'Indi-Acumen', 'Indi-Precision',
            'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Haste', 'Indi-Refresh', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end


-- Adjusts gear sets based on the action being performed.
-- @param {table} spell - The spell or ability being used.
-- @param {table} action - The action being performed.
-- @param {string} spellMap - The type of the spell or ability.
-- @param {table} eventArgs - Additional arguments for the event.
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Equip AeolianTH gear set if 'Aeolian Edge' is being used and Treasure Hunter is active.
    if spell.english == 'Aeolian Edge' and treasureHunter ~= 'None' then
        -- Equip TreasureHunter gear set if 'Sneak Attack' or 'Trick Attack' is being used and Treasure Mode is 'SATA' or 'Fulltime'.
        equip(sets.AeolianTH)
    elseif spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
    check_range_lock()
end

-- Prepares for a spell cast by performing several actions.
-- @param {table} spell - The spell or ability being used.
-- @param {table} action - The action being performed.
-- @param {string} spellMap - The type of the spell or ability.
-- @param {table} eventArgs - Additional arguments for the event.
function job_precast(spell, action, spellMap, eventArgs)
    handle_spell(spell, eventArgs, auto_abilities) -- Handles the spell based on its type and the current state.
    checkDisplayCooldown(spell, eventArgs)         -- Checks and displays the cooldown for the spell.
    refine_Utsusemi(spell, eventArgs)              -- Refines the Utsusemi spell if it's being cast.
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell) -- Selects the earrings based on the weapon and TP.
    -- Sets the state for the buff corresponding to the spell being cast to true, if it exists.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
end

-- Adjusts gear sets for ranged attacks when Treasure Mode is active.
-- @param {table} spell - The spell or ability being used.
-- @param {table} action - The action being performed.
-- @param {string} spellMap - The type of the spell or ability.
-- @param {table} eventArgs - Additional arguments for the event.
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- If Treasure Mode is active and a ranged attack is being performed, equip the RATH gear set.
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

-- Performs actions after a spell or ability is used.
-- @param {table} spell - The spell or ability that was used.
-- @param {table} action - The action that was performed.
-- @param {string} spellMap - The type of the spell or ability.
-- @param {table} eventArgs - Additional arguments for the event.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- If a buff corresponding to the spell exists, update its state based on whether the spell was interrupted or the buff is active.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end

    -- If a WeaponSkill was successfully used, reset the state of 'Sneak Attack', 'Trick Attack', and 'Feint' buffs.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
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
    if player.sub_job == 'DNC' then
        set_macro_page(1, 1)
    elseif player.sub_job == 'WAR' then
        set_macro_page(1, 2)
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 3)
    else
        set_macro_page(1, 1)
    end

    -- Waits for 15 seconds, locks the style set to 1, waits for another 5 seconds, and then loads the 'dressup' Lua script.
    send_command('wait 15;input /lockstyleset 1; wait 5; lua load dressup')
end
