-------------------------------------------------------------------------------------------------------------
-- ***********************************************************
-- * Fonction Initial qui définie les sets et les variables. *
-- ***********************************************************

-- IMPORTANT: Soyez sur d'avoir le fichier Mote-Include.lua (Et les fichiers suplémentaires) qui vont avec.
-- Mote-Globals.lua
-- Mote-Mappings.lua
-- Mote-SelfCommands.lua
-- Mote-TreasureHunter.lua
-- Mote-Utility.lua
-- ils sont normalement dans le répertoire => Windower\addons\GearSwap\libs

function get_sets()
    -- Chargement et initialisation des fichiers inclus.
    mote_include_version = 2
    include('Mote-Include.lua')
    include('organizer-lib')
end
-------------------------------------------------------------------------------------------------------------
-- ********************************************************************
-- * Configuration des variables et des dépendences de l'utilisateur. *
-- ********************************************************************
function job_setup()
    include('0_AutoMove.lua')
    include('Mote-TreasureHunter')
    -- State
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    state.HasteMode = M {['description'] = 'Haste Mode', 'Normal', 'Hi'}
    -- Variables
    treasureHunter = state.TreasureMode.value
    determine_haste_group()
    --______________________________________________________________________________________
    -- Pour la Fonction th_action_check():
    -- IDs des Job ability pour les actions qui ont toujours TH: Provoke, Animated Flourish.
    info.default_ja_ids = S {35, 204}
    -- IDs des Job ability qui ne Blink pas Pour les actions qui ont toujours TH: =>
    -- Quick/Box/Stutter Step, Desperate/Violent Flourish.
    info.default_u_ja_ids = S {201, 202, 203, 205, 207}
end
-------------------------------------------------------------------------------------------------------------

-- **************************************************
-- * Configuration des variables de l'utilisateurs. *
-- **************************************************
function user_setup()
    -- Options: Ecrase les valeurs par défaut
    state.HybridMode:options('PDT', 'Normal')
    state.OffenseMode:options('Normal', 'Acc')
    state.TreasureMode:set('tag')
    state.WeaponSet = M {['description'] = 'Main Weapon', 'TwashtarM', 'Tauret', 'Malevolence', 'Naegling'} --gs c cycle WeaponSet
    --[[ state.WeaponSet = M{['description']='Main Weapon','Qutrub', 'Excalipoor', 'Lament', 'Iapetus', 'Chac', 'Ram', 'Sickle','Malevolence', 'TwashtarM'} --gs c cycle WeaponSet ]]
    state.SubSet = M {['description'] = 'Sub Weapon', 'Centovente', 'Blurred', 'Gleti', 'Crepu'} --gs c cycle SubSet

    -- ***************************
    -- * Macros supplémentaires. *
    -- ***************************
    select_default_macro_book()
end

-- ****************************
-- * Initialisation des Sets. *
-- ****************************
function init_gear_sets()
    sets['TwashtarM'] = {main = 'Twashtar'}
    sets['TwashtarS'] = {sub = 'Twashtar'}
    sets['Tauret'] = {main = 'Tauret'}
    sets['Malevolence'] = {main = 'Malevolence'}
    sets['Naegling'] = {main = 'Naegling'}
    sets['Qutrub'] = {main = 'Qutrub Knife'}
    sets['Excalipoor'] = {main = 'Excalipoor'}
    sets['Lament'] = {main = 'Lament'}
    sets['Iapetus'] = {main = 'Iapetus'}
    sets['Chac'] = {main = 'Chac-Chacs'}
    sets['Ram'] = {main = 'Ram staff'}
    sets['Crepu'] = {main = 'Crepuscular Knife'}
    sets['Centovente'] = {sub = 'Centovente'}
    sets['Blurred'] = {sub = 'Blurred Knife +1'}
    sets['Gleti'] = {sub = "Gleti's Knife"}
    sets['Sickle'] = {main = 'Lost Sickle'}
    include('THF_SET.lua')
end

-- *******************************************************************************************************************************************
--                                                                      HOOKS
-- Un hook (littéralement « crochet » ou « hameçon ») permet à l'utilisateur d'un logiciel de personnaliser le fonctionnement de ce dernier,
-- en lui faisant réaliser des actions supplémentaires à des moments déterminés. Le concepteur du logiciel prévoit des hooks tout au long
-- du fonctionnement de son programme, qui sont des points d'entrée vers des listes d'actions. Par défaut, le hook est généralement vide et
-- seules les fonctionnalités de base de l'application sont exécutées. Cependant, l'utilisateur peut « accrocher » des morceaux de programme
-- à ces hooks pour personnaliser le logiciel.

-- Hameçon qui est appelé quand le joueur execute une action.

-- *******************************************************************************************************************************************

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

function job_precast(spell, action, spellMap, eventArgs)
    refine_Utsusemi(spell, eventArgs)
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
end

-- ********************************************************
-- * Ce lance après que le precast général est construit. *
-- ********************************************************
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.english == 'Aeolian Edge' and treasureHunter ~= 'None' then
        equip(sets.AeolianTH)
    elseif spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' or spell.type == 'WeaponSkill' then
        if treasureHunter == 'SATA' or treasureHunter == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
end

-- ********************************************************
-- * Ce lance après que le midcast principal est construit. *
-- ********************************************************
function job_post_midcast(spell, action, spellMap, eventArgs)
    if treasureHunter ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

--[[ windower.register_event('tp change', function()
    if player.tp > 1000 then
        send_command('input /ws "Evisceration" <t>')
    end
    end) ]]
-- *************************************************************************************************************************************
-- Vérifie que eventArgs.handled est <<Vrai>>
-- ex: <<Sneak attack>>, <<Trick attack>>, <<Doom>> etc.
-- Equipera le set correspondant.
function job_aftercast(spell, action, spellMap, eventArgs)
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- Passe les variables Sneak Attack , Trick Attack, Feint en <<Fausse>> avant que le set TP soit rééquipé, quand on Weapon Skill.
    ---------------------------------------------------------------------------------------------------------------------------------------
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end
end
-- *************************************************************************************************************************************

-- ******************************
-- * Appelé après le Aftercast. *
-- ******************************
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- Si <<Feint>> est actif place sont set d'équipement en priorité.
    -- Ceci inclus SA et TA.
    check_buff('Feint', eventArgs)
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
    -- ****************************************************
    -- * Vérifie si les slots Range et ammo sont bloqués. *
    -- ****************************************************
    check_range_lock()

    -- ***********************************************************************
    -- * Vérififie Sneak attack et Trick Attack quand une piece est équipée. *
    -- * Bloque l'equipement concerné par Sneak et Trick Attack.             *
    -- ***********************************************************************
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)
    check_weaponset()
    check_subset()
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end
--------------------------------------------------------------------------

function customize_idle_set(idleSet)
    if player.hp < 1500 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end
    if state.HybridMode.value == 'PDT' then
        idleSet = set_combine(idleSet, sets.idle.PDT)
    end
    if state.HybridMode.value == 'MDT' then
        idleSet = sets.defense.MDT
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end
    if state.HybridMode.value == 'MDT' then
        meleeSet = sets.defense.MDT
    end
    if player.hp <= 800 then
        meleeSet = sets.engaged.PDT
    end
    if state.OffenseMode.current == 'Mid' then
        melee = set_combine(meleeSet, sets.engaged.Mid)
    end
    if state.ccuracy == 'Accuracy' then
        melee = set_combine(meleeSet, sets.engaged.Acc)
    end
    return meleeSet
end

-------------------------------------------------------------------------------------------------------------------
-- General hooks for change events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S {'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
        determine_haste_group()
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
    if state.Buff[buff] ~= nil then
        state.Buff[buff] = gain
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
end

-- ***********************************
-- * Mise a jour d'évenement divers. *
-- ***********************************
-- **********************************************
-- * Appelé par la mise a jour de Self-Command. *
-- **********************************************
function job_update(cmdParams, eventArgs)
    th_update(cmdParams, eventArgs)
    -- determine_haste_group()
end

function job_state_change(stateField, newValue, oldValue)
    if stateField == 'moving' then
        if state.Moving.value then
            local res = require('resources')
            local info = windower.ffxi.get_info()
            local zone = res.zones[info.zone].name
            if zone:match('Adoulin') then
                equip(sets.Adoulin)
            end
            equip(select_movement())
        end
        local msg = ''
        if newValue == 'Ignis' then
            msg = msg .. 'Increasing resistence against ICE and deals FIRE damage.'
        elseif newValue == 'Gelus' then
            msg = msg .. 'Increasing resistence against WIND and deals ICE damage.'
        elseif newValue == 'Flabra' then
            msg = msg .. 'Increasing resistence against EARTH and deals WIND damage.'
        elseif newValue == 'Tellus' then
            msg = msg .. 'Increasing resistence against LIGHTNING and deals EARTH damage.'
        elseif newValue == 'Sulpor' then
            msg = msg .. 'Increasing resistence against WATER and deals LIGHTNING damage.'
        elseif newValue == 'Unda' then
            msg = msg .. 'Increasing resistence against FIRE and deals WATER damage.'
        elseif newValue == 'Lux' then
            msg = msg .. 'Increasing resistence against DARK and deals LIGHT damage.'
        elseif newValue == 'Tenebrae' then
            msg = msg .. 'Increasing resistence against LIGHT and deals DARK damage.'
        end
        add_to_chat(123, msg)
    elseif stateField == 'Use Rune' then
        send_command('@input /ja ' .. state.Runes.value .. ' <me>')
    elseif stateField == 'Use Warp' then
        add_to_chat(8, '------------WARPING-----------')
        -- equip({ring1="Warp Ring"})
        send_command('input //gs equip sets.Warp;@wait 10.0;input /item "Warp Ring" <me>;')
    end
    check_weaponset()
    check_subset()
end
-- ********************************************************************************************************
-- * Fonction pour afficher l'état actuel de l'utilisateur quand il est mit à jour.                       *
-- * Retourne <<Vrai>> si l'affichage à été modifié, et que vous ne voulez pas affiché l'état par défaut. *
-- ********************************************************************************************************
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

    if state.HasteMode.value ~= 'Normal' then
        msg = msg .. ', Haste: ' .. state.HasteMode.current
    else
        msg = msg .. ', Haste: ' .. state.HasteMode.current
    end

    if state.DefenseMode.value ~= 'None' then
        msg =
            msg ..
            ', ' ..
                'Defense: ' ..
                    state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end

    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: ' .. state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end

    msg = msg .. ', TH: ' .. state.TreasureMode.value
    add_to_chat(122, msg)
    eventArgs.handled = true
end

-- *******************************
-- * Fonction utile pour le Job. *
-- *******************************

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

function determine_haste_group()
    classes.CustomMeleeGroups:clear()
    --Haste (white magic) 15%
    --Haste Samba (Sub) 5%
    --Haste (Merited DNC) 10%
    --Victory March +3/+4/+5     14%/15.6%/17.1%
    --Advancing March +3/+4/+5   10.9%/12.5%/14%
    --Embrava 25%
    if (buffactive.embrava or buffactive.haste) and buffactive.march == 2 then
        add_to_chat(8, '-------------Haste 43%-------------')
        classes.CustomMeleeGroups:append('Haste_43')
    elseif buffactive.embrava and buffactive.haste then
        add_to_chat(8, '-------------Haste 40%-------------')
        classes.CustomMeleeGroups:append('Haste_40')
    elseif (buffactive.haste) or (buffactive.march == 2 and buffactive['haste samba']) then
        add_to_chat(8, '-------------Haste 30%-------------')
        classes.CustomMeleeGroups:append('Haste_30')
    elseif buffactive.embrava or buffactive.march == 2 then
        add_to_chat(8, '-------------Haste 25%-------------')
        classes.CustomMeleeGroups:append('Haste_25')
    end
end

-- ***********************************************************************
-- * Fonction qui détermine dans quel groupe de haste vous vous trouvez. *
-- * (Non utilisé pour le moment).                                       *
-- ***********************************************************************
function determine_haste_group()
    classes.CustomMeleeGroups:clear()
    -- assuming +4 for marches (ghorn has +5)
    -- Haste (white magic) 15%
    -- Haste Samba (Sub) 5%
    -- Haste (Merited DNC) 10% (never account for this)
    -- Victory March +0/+3/+4/+5    9.4/14%/15.6%/17.1% +0
    -- Advancing March +0/+3/+4/+5  6.3/10.9%/12.5%/14%  +0
    -- Embrava 30% with 500 enhancing skill
    -- Mighty Guard - 15%
    -- buffactive[580] = geo haste
    -- buffactive[33] = regular haste
    -- buffactive[604] = mighty guard
    -- state.HasteMode = toggle for when you know Haste II is being cast on you
    -- Hi = Haste II is being cast. This is clunky to use when both haste II and haste I are being cast
    if state.HasteMode.value == 'Hi' then
        if
            (((buffactive[33] or buffactive[580] or buffactive.embrava) and (buffactive.march or buffactive[604])) or
                (buffactive[33] and (buffactive[580] or buffactive.embrava)) or
                (buffactive.march == 2 and buffactive[604]))
         then
            add_to_chat(8, '-------------Max-Haste Mode Enabled--------------')
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif
            ((buffactive[580] or buffactive[33] or buffactive.march == 2) or (buffactive.march == 1 and buffactive[604]))
         then
            add_to_chat(8, '-------------Haste 30%-------------')
            classes.CustomMeleeGroups:append('Haste_30')
        elseif (buffactive.march == 1 or buffactive[604]) then
            add_to_chat(8, '-------------Haste 15%-------------')
            classes.CustomMeleeGroups:append('Haste_15')
        end
    else
        if
            (buffactive[580] and (buffactive.march or buffactive[33] or buffactive.embrava or buffactive[604])) or -- geo haste + anything
                (buffactive.embrava and (buffactive.march or buffactive[33] or buffactive[604])) or -- embrava + anything
                (buffactive.march == 2 and (buffactive[33] or buffactive[604])) or -- two marches + anything
                (buffactive[33] and buffactive[604] and buffactive.march)
         then -- haste + mighty guard + any marches
            add_to_chat(8, '-------------Max Haste Mode Enabled--------------')
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif
            (buffactive.march == 2) or -- two marches from ghorn
                ((buffactive[33] or buffactive[604]) and buffactive.march == 1) or -- MG or haste + 1 march
                (buffactive[580]) or -- geo haste
                (buffactive[33] and buffactive[604])
         then -- haste with MG
            add_to_chat(8, '-------------Haste 30%-------------')
            classes.CustomMeleeGroups:append('Haste_30')
        elseif buffactive[33] or buffactive[604] or buffactive.march == 1 then
            add_to_chat(8, '-------------Haste 15%-------------')
            classes.CustomMeleeGroups:append('Haste_15')
        end
    end
end

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

-- *************************************************************************************
-- * Selectionne le livre de Macro par defaut quand on choisi sont job ou sont subJob. *
-- *************************************************************************************
function select_default_macro_book()
    -- Default macro set/book
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
