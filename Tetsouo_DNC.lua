-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    -- Load and initialize the include file.
    include('Mote-Include.lua')
    include('organizer-lib')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    include('/Misc/0_AutoMove.lua')
    include('Mote-TreasureHunter')
    include('/Misc/SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions
    state.HybridMode:options('PDT', 'Normal', 'Evasion')
    state.OffenseMode:options('Normal', 'Acc')
    state.TreasureMode:set('none')
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Twashtar', 'Tauret'} --gs c cycle WeaponSet
    state.SubSet = M {['description'] = 'Sub Weapon', 'Centovente', 'Blurred', 'Gleti'} --gs c cycle SubSet
    climactic = buffactive['climactic flourish'] or false
    building = buffactive['building flourish'] or false
    ternary = buffactive['ternary flourish'] or false
    state.MainStep = M {['description'] = 'Main Step', 'Box Step', 'Quickstep', 'Stutter Step', 'Feather Step'}
    state.AltStep = M {['description'] = 'Alt Step', 'Feather Step', 'Quickstep', 'Stutter Step', 'Box Step'}
    state.UseAltStep = M(true, 'Use Alt Step')
    state.SelectStepTarget = M(true, 'Select Step Target')
    state.CurrentStep = M {['description'] = 'Current Step', 'Main', 'Alt'}
    state.SkillchainPending = M(false, 'Skillchain Pending')
    select_default_macro_book()
    --[[ determine_haste_group() ]]
    --______________________________________________________________________________________
    -- Pour la Fonction th_action_check():
    -- IDs des Job ability pour les actions qui ont toujours TH: Provoke, Animated Flourish.
    info.default_ja_ids = S {35, 204}
    -- IDs des Job ability qui ne Blink pas Pour les actions qui ont toujours TH: =>
    -- Quick/Box/Stutter Step, Desperate/Violent Flourish.
    info.default_u_ja_ids = S {201, 202, 203, 205, 207}
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Define sets and vars used by this job file.
function init_gear_sets()
    sets['Twashtar'] = {main = 'Twashtar'}
    sets['Tauret'] = {main = 'Tauret'}
    sets['Aern Dagger II'] = {main = 'Aern Dagger II'}
    sets['Centovente'] = {sub = 'Centovente'}
    sets['Blurred'] = {sub = 'Blurred Knife +1'}
    sets['Gleti'] = {sub = "Gleti's Knife"}
    include('/DNC/DNC_SET.lua')
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Automatically use Presto for steps when it's available and we have less than 3 finishing moves
function auto_presto(spell)
    if spell.type == 'Step' then
        local allRecasts = windower.ffxi.get_ability_recasts()
        local prestoCooldown = allRecasts[236]
        --[[ local under3FMs = not buffactive['Finishing Move 3'] and not buffactive['Finishing Move 4'] and not buffactive['Finishing Move 5'] ]]
        if player.main_job_level >= 77 and prestoCooldown < 1 then
            cast_delay(1.1)
            send_command('@input /ja "Presto" <me>')
        end
    end
end

-- Automatically use Contradance for steps when it's available and we have less than 3 finishing moves
function auto_contradance(spell)
    if spell.name == 'Divine Waltz II' then
        local allRecasts = windower.ffxi.get_ability_recasts()
        local contradanceCd = allRecasts[229]
        if contradanceCd < 1 and player.tp > 800 then
            cast_delay(1.1)
            send_command('input /ja "Contradance" <me>; wait 2; input /ja "Divine Waltz II" <me>')
        end
    end
end

-- Automatically use CLimatic Flourish when use Rudra's Storm
function auto_WS_flourish(spell)
    if spell.name == "Rudra's Storm" or spell.name == 'Shark Bite' then
        local allRecasts = windower.ffxi.get_ability_recasts()
        local ClimCD = allRecasts[226]
        local BuilCD = allRecasts[222]
        if
            (buffactive['Finishing Move 3'] or buffactive['Finishing Move 4'] or buffactive['Finishing Move 5'] or
                buffactive['Finishing Move (6+)']) and
                (player.tp > 1000 and player.target.hpp > 25)
        then
            if ClimCD < 1 and climactic == false then
                cancel_spell()
                send_command(
                    'input /ja "Climactic Flourish" <me>; wait 1; input /ws "' .. spell.name .. '"' .. spell.target.id
                )
            end
        end
    end
end

function refine_Utsusemi(spell, eventArgs)
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local NiCD = spell_recasts[339]
    local IchiCD = spell_recasts[338]
    if spell.name == 'Utsusemi: Ni' then
        if NiCD > 1 then
            eventArgs.cancel = true
            if IchiCD < 1 then
                cancel_spell()
                cast_delay(1.1)
                send_command('input /ma "Utsusemi: Ichi" <me>')
            else
                add_to_chat(123, "Aucun des sorts n'est pret !!!")
            end
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    refine_Utsusemi(spell, eventArgs)
    auto_presto(spell)
    auto_contradance(spell)
    auto_WS_flourish(spell)
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        if state.Buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
        if state.SkillchainPending.value == true then
            equip(sets.precast.Skillchain)
        end
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
end

-- ********************************************************
-- * Ce lance après que le midcast principal est construit. *
-- ********************************************************
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

-- ******************************
-- * Appelé après le Aftercast. *
-- ******************************
function job_post_aftercast(spell, action, spellMap, eventArgs)
end

-- ***********************
-- * Hooks Personalisés. *
-- ***********************
function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode
    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end
    return wsmode
end

-- ***************************************************************************
-- * Appelé à chaque changement de stuffs automatique (ex: Engaged ou Idle). *
-- ***************************************************************************
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_range_lock()
    check_weaponset()
    check_subset()
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S {'haste', 'march', 'embrava', 'haste samba'}:contains(buff:lower()) then
        determine_haste_group()
        handle_equipping_gear(player.status)
    elseif buff == 'Saber Dance' or buff == 'Climactic Flourish' then
        handle_equipping_gear(player.status)
    end
end

-- ************************************************************************************************************
-- * Vérifie l'état du <<Buff>> qui equipera le set correspondant et marquera que l'évenement a été manipulé. *
-- ************************************************************************************************************
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end

-- **************************************************************************************
-- * Fonction qui vérouille les slots Ranged et Ammo si on a une ranged weapon équipée. *
-- **************************************************************************************
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo')
    else
        enable('range', 'ammo')
    end
end

function job_status_change(new_status, old_status)
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the default 'update' self-command.
function job_update(cmdParams, eventArgs)
end

function customize_idle_set(idleSet)
    if player.hpp < 80 and not areas.Cities:contains(world.area) then
        idleSet = set_combine(idleSet, sets.ExtraRegen)
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if buffactive['saber dance'] then
        meleeSet =
            set_combine(
            meleeSet,
            {
                legs = 'horos tights +3'
            }
        )
    end
    if state.Buff['Climactic Flourish'] then
        meleeSet =
            set_combine(
            meleeSet,
            {
                head = 'Maculele Tiara +3'
            }
        )
    end
    if buffactive['fan dance'] then
        meleeSet =
            set_combine(
            meleeSet,
            {
                hands = 'Horos Bangles +3'
            }
        )
    end
    if player.hp <= 800 then
        meleeSet = sets.engaged.PDT
    end
    if state.OffenseMode.value == 'Accuracy' then
        meleeSet = set_combine(sets.engaged, sets.engaged.Acc)
    end
    return meleeSet
end

-- Function to display the current relevant user state when doing an update.
-- Set eventArgs.handled to true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = 'Melee'

    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end

    msg = msg .. ': '

    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value

    if state.DefenseMode.value ~= 'None' then
        msg =
            msg ..
            ', ' ..
                'Defense: ' ..
                    state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end

    if state.Kiting.value then
        msg = msg .. ', Kiting'
    end

    msg = msg .. ', [' .. state.MainStep.current

    if state.UseAltStep.value == true then
        msg = msg .. '/' .. state.AltStep.current
    end

    msg = msg .. ']'

    if state.SelectStepTarget.value == true then
        steps = steps .. ' (Targetted)'
    end

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

--[[ function determine_haste_group()
    -- We have three groups of DW in gear: Charis body, Charis neck + DW earrings, and Patentia Sash.

    -- For high haste, we want to be able to drop one of the 10% groups (body, preferably).
    -- High haste buffs:
    -- 2x Marches + Haste
    -- 2x Marches + Haste Samba
    -- 1x March + Haste + Haste Samba
    -- Embrava + any other haste buff

    -- For max haste, we probably need to consider dropping all DW gear.
    -- Max haste buffs:
    -- Embrava + Haste/March + Haste Samba
    -- 2x March + Haste + Haste Samba

    classes.CustomMeleeGroups:clear()

    if buffactive.embrava and (buffactive.haste or buffactive.march) and buffactive['haste samba'] then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.march == 2 and buffactive.haste and buffactive['haste samba'] then
        classes.CustomMeleeGroups:append('MaxHaste')
    elseif buffactive.embrava and (buffactive.haste or buffactive.march or buffactive['haste samba']) then
        classes.CustomMeleeGroups:append('HighHaste')
    elseif buffactive.march == 1 and buffactive.haste and buffactive['haste samba'] then
        classes.CustomMeleeGroups:append('HighHaste')
    elseif buffactive.march == 2 and (buffactive.haste or buffactive['haste samba']) then
        classes.CustomMeleeGroups:append('HighHaste')
    end
end ]]

-- ************************************************************************************
-- * Vérifie diverse actions que l'on a spécifié dans le code qui utilise le sets TH. *
-- * Ne sera appelé seulement si treasureMode n'est pas 'None'.                       *
-- * Catégories et et paramètres qui ont été spécifiés dans l'action event packet.    *
-- ************************************************************************************
function th_action_check(category, param)
    if
        category == 2 or -- any ranged attack
            -- category == 4 or -- any magic action
            (category == 3 and param == 30) or -- Aeolian Edge
            (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
            (category == 14 and info.default_u_ja_ids:contains(param))
    then -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        return true
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
        set_macro_page(1, 5)
        send_command('lua unload dressup')
        send_command('wait 15;input /lockstyleset 2; wait 5; lua load dressup')
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 6)
        send_command('lua unload dressup')
        send_command('wait 15;input /lockstyleset 2; wait 5; lua load dressup')
    else
        set_macro_page(1, 5)
        send_command('lua unload dressup')
        send_command('wait 15;input /lockstyleset 2; wait 5; lua load dressup')
    end
end
