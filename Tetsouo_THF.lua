--============================================================--
--=                        THIEF                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-22                  =--
--============================================================--

-- This script is for the Thief job in Gearswap.

-- Sets up the necessary libraries and files for Gearswap.
function get_sets()
    -- Set the Mote-Include version to 2.
    mote_include_version = 2
    -- Include the Mote-Include.lua library (Version 2) for common functions.
    include('Mote-Include.lua')
    -- Include the AutoMove.lua file for movement speed gear management.
    include('/Misc/0_AutoMove.lua')
    -- Include the SharedFunctions.lua file for shared functions.
    include('/Misc/SharedFunctions.lua')
    -- Include the THF_FUNCTION.lua file for advanced functions specific to Thief.
    include('/THF/THF_FUNCTION.lua')
end

-- Handles user-specific configuration and setup.
function user_setup()
    -- Include the Mote-TreasureHunter.lua file for handling Treasure Hunter.
    include('Mote-TreasureHunter.lua')
    ---------------------------------------------------------------------------------------------------------
    -- Initialize the treasureHunter state variable from TreasureMode.
    treasureHunter = state.TreasureMode.value
    ---------------------------------------------------------------------------------------------------------
    -- Set up state variables for buffs, modes, and gear sets.
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    ---------------------------------------------------------------------------------------------------------
    -- Set default treasure mode to 'tag'.
    state.TreasureMode:set('tag')
    ---------------------------------------------------------------------------------------------------------
    -- Hybrid mode options: 'Normal' and 'PDT'.
    -- Command to change hybrid mode: /console gs c cycle HybridMode
    state.HybridMode:options('PDT', 'Normal')
    ---------------------------------------------------------------------------------------------------------
    -- Offense mode options: 'Normal' and 'Acc'.
    -- Command to change offense mode: /console gs c cycle OffenseMode
    state.OffenseMode:options('Normal', 'Acc')
    ---------------------------------------------------------------------------------------------------------
    -- Gear set for main weapon options.
    -- Command to cycle main weapon set: /console gs c cycle WeaponSet
    --[[ state.WeaponSet = M {['description'] = 'Main Weapon', 'TwashtarM', 'Tauret', 'Malevolence', 'Naegling'} ]]
    ---------------------------------------------------------------------------------------------------------
    -- Gear set for  alt main weapon options.
    -- Command to cycle main weapon set: /console gs c cycle WeaponSet
    state.WeaponSet = M {['description'] = 'Main Weapon', 'TwashtarM', 'Qutrub', 'Excalipoor', 'Lament', 'Iapetus', 'Chac', 'Ram', 'Sickle'}
    ---------------------------------------------------------------------------------------------------------
    -- Gear set for sub weapon options.
    -- Command to cycle sub weapon set: /console gs c cycle SubSet
    state.SubSet = M {['description'] = 'Sub Weapon', 'Centovente', 'Blurred', 'Gleti', 'Crepu'}
    ---------------------------------------------------------------------------------------------------------
    -- Set up default job ability IDs for actions that always have Treasure Hunter.
    -- [35] = Provoke, [204] Animated Flourish
    info.default_ja_ids = S {35, 204}
    -- Set up job ability IDs for actions that don't blink and always have Treasure Hunter.
    -- [201] Quickstep, [202] Boxstep, [203] Stutterstep, [205] Desperate Flourish, [207] Violent Flourish.
    info.default_u_ja_ids = S {201, 202, 203, 205, 207} 
    ---------------------------------------------------------------------------------------------------------
    -- Select the default macro book based on sub-job.
    select_default_macro_book()
end

-- Initialize gear sets.
function init_gear_sets()
    -- Include the gear sets for Thief.
    include('THF/THF_SET.lua')
end

-- Actions to perform before a spell is cast.
function job_precast(spell, action, spellMap, eventArgs)
    -- Check if the player is incapacitated (unable to act) before casting the spell.
    if not incapacitated(spell, eventArgs, true) then
        -- Check for display cooldowns for actions.
        checkDisplayCooldown(spell, eventArgs)
        -- Refine Utsusemi spell.
        refine_Utsusemi(spell, eventArgs)
        -- Set the state for the buff corresponding to the spell being cast to true.
        if state.Buff[spell.english] ~= nil then
            state.Buff[spell.english] = true
        end
    end
end

-- Actions to perform after precast but before the action is sent to the server.
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Equip the AeolianTH gear set for Aeolian Edge if Treasure Hunter is active.
    if spell.english == 'Aeolian Edge' and treasureHunter ~= 'None' then
        equip(sets.AeolianTH)
    -- Equip the TreasureHunter gear set for Sneak Attack, Trick Attack, or WeaponSkills if applicable.
    elseif spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' or spell.type == 'WeaponSkill' then
        if treasureHunter == 'SATA' or treasureHunter == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
end

-- Actions to perform after midcast but before the action is sent to the server.
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Check for incapacitated state.
    incapacitated(spell, eventArgs)
    -- Equip Ranged Attack gear with Treasure Hunter if it's active.
    if treasureHunter ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

-- Actions to perform after a spell or ability is used.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Update the state of the buff based on whether the spell was interrupted or buff is active.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end

    -- Reset the state of certain buffs after a successful WeaponSkill.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end

    -- Perform actions after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

-- Actions to perform after aftercast but before the action is sent to the server.
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- Check for the Feint buff.
    check_buff('Feint', eventArgs)
end

-- Select the default macro book based on sub-job.
function select_default_macro_book()
    if player.sub_job == 'DNC' then
        set_macro_page(1, 1)
        send_command('wait 25;input /lockstyleset 1')
    elseif player.sub_job == 'WAR' then
        set_macro_page(1, 2)
        send_command('wait 25;input /lockstyleset 1')
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 3)
        send_command('wait 25;input /lockstyleset 1')
    else
        set_macro_page(1, 1)
        send_command('wait 25;input /lockstyleset 1')
    end
end