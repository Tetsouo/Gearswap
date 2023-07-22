--============================================================--
--=                        WARRIOR                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

-- Sets up the necessary libraries and files for Gearswap.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Includes the Mote-Include.lua library (Version 2).
    include('/Misc/0_AutoMove.lua') -- Includes the AutoMove.lua file for movement speed gear management.
    include('/Misc/SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions.
    include('/COR/COR_FUNCTION.lua') -- Includes the WAR_FUNCTION.lua file for advanced functions specific to Warrior.
end

-- Handles user-specific configuration and setup.
function user_setup()
    -- Hybrid mode options: 'PDT' (Defense physical), 'Normal' (Damage Dealer)'
    state.HybridMode:options('PDT', 'Normal')
    -- Ranged mode options: 'STP' (Store TP), 'Acc' (Ranged Accuracy)'
    state.RangedMode:options('STP', 'Acc')
    -- Ranged Weapon Choice: 'Death Penalty', 'Doomsday' 
    state.RangedSet = M{['description']='Weapon Set', 'DeathPenalty', 'Doomsday'}
    -- Sub weapon choice: 'Tauret', 'Blurred'
    state.SubSet = M {['description'] = 'Sub Weapon','Tauret', 'Blurred'} -- Command to cycle sub weapon set: /console gs c cycle SubSet
    -- Ranged attack Bullet: Eminent Bullet
	gear.RAbullet = "Eminent Bullet"
    -- Magic attack Bullet: Living Bullet
    gear.MAbullet = "Living Bullet"
    -- Weapons skill Bullet
    gear.WSbullet = "Eminent Bullet"
    -- Quick Draw Bullet
    gear.QDbullet = "Eminent Bullet"
    -- Options: Ammo Left.
    options.ammo_warning_limit = 10
    -- Calls the function to select the default macro book

    send_command('bind !` input /ja "Bolter\'s Roll" <me>')
    send_command('bind numpad0 input /ra <t>')
    send_command('bind ^numpad8 input /ws "Evisceration" <t>')
    send_command('bind ^numpad7 input /ws "Aeolian Edge" <t>')
    send_command('bind ^numpad5 input /ws "Requiescat" <t>')
    send_command('bind ^numpad4 input /ws "Savage Blade" <t>')
    send_command('bind ^numpad3 input /ws "Last Stand" <t>')
    send_command('bind ^numpad2 input /ws "Wildfire" <t>')
    send_command('bind ^numpad1 input /ws "Leaden Salute" <t>')
    send_command ('bind @` gs c toggle LuzafRing')
    select_default_macro_book()


    -- OTHER SELF COMMAND Parameters to put in your in-game Macro or bind a key with it.
    --===================================================================================
        -- [gs c Berserk] Cast job ability with logic from WAR_FUNCTION.lua:
            -- state.HybridMode: Normal
            -- Berserk
            -- Aggressor
            -- Retaliation
            -- Restraint
            -- Warcry or Blood Rage
    --===================================================================================
        -- [gs c Defender] Cast job ability with logic from WAR_FUNCTION.lua:
            -- state.HybridMode: PDT
            -- Defender
            -- Aggressor
            -- Retaliation
            -- Restraint
            -- Warcry or Blood Rage
    --===================================================================================
        -- [gs c ThirdEye] Cast Third Eye with logic from WAR_FUNCTION.lua:
            -- with state.HybridMode: Normal
                -- Hasso + Third Eye
            -- with state.HybridMode: PDT
                -- Seigan + Third Eye
end

-- Handles the unload event when changing job or reloading the file.
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^numpad8')
    send_command('unbind ^numpad7')
    send_command('unbind ^numpad5')
    send_command('unbind ^numpad4')
    send_command('unbind ^numpad3')
    send_command('unbind ^numpad2')
    send_command('unbind ^numpad1')
    send_command('unbind numpad0')
end

-- Loads the gear sets from the PLD_SET.lua file.
function init_gear_sets()
    include('/WAR/WAR_SET.lua')
end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    if incapacitated(spell, eventArgs, true) then
        -- Spell cannot be cast due to incapacitation, no further actions needed
    else
        -- Check that proper ammo is available if we're using ranged attacks or similar.
        if spell.action_type == 'Ranged Attack' or spell.type == 'WeaponSkill' or spell.type == 'CorsairShot' then
            do_bullet_checks(spell, spellMap, eventArgs)
        end

        -- Gear
        if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") then
            if player.status ~= 'Engaged' then
                equip(sets.precast.CorsairRoll.Duration)
            end
            if state.LuzafRing.value then
                equip(sets.precast.LuzafRing)
            end
        end

        if spell.english == 'Fold' and buffactive['Bust'] == 2 then
            if sets.precast.FoldDoubleBust then
                equip(sets.precast.FoldDoubleBust)
                eventArgs.handled = true
            end
        end
        if spellMap == 'Utsusemi' then
            if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
                cancel_spell()
                add_to_chat(123, '**!! '..spell.english..' Canceled: [3+ IMAGES] !!**')
                eventArgs.handled = true
                return
            elseif buffactive['Copy Image'] or buffactive['Copy Image (2)'] then
                send_command('cancel 66; cancel 444; cancel Copy Image; cancel Copy Image (2)')
            end
        end
        checkDisplayCooldown(spell, eventArgs) -- Handle recast cooldown and display messages
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        special_ammo_check()
        if flurry == 2 then
            equip(sets.precast.RA.Flurry2)
        elseif flurry == 1 then
            equip(sets.precast.RA.Flurry1)
        end
    elseif spell.type == 'WeaponSkill' then
        if spell.skill == 'Marksmanship' then
            special_ammo_check()
        end
        -- Replace TP-bonus gear if not needed.
        if spell.english == 'Leaden Salute' or spell.english == 'Aeolian Edge' and player.tp > 2900 then
            equip(sets.FullTP)
        end
        if elemental_ws:contains(spell.name) then
            -- Matching double weather (w/o day conflict).
            if spell.element == world.weather_element and (get_weather_intensity() == 2 and spell.element ~= elements.weak_to[world.day_element]) then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 1.7 yalms.
            elseif spell.target.distance < (1.7 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 8 yalms.
            elseif spell.target.distance < (8 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Match day or weather.
            elseif spell.element == world.day_element or spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            end
        end
    end
end

-- Handles actions to perform during the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    incapacitated(spell, eventArgs) -- Check for incapacitated state
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
        if (spell.english ~= 'Light Shot' and spell.english ~= 'Dark Shot') then
            -- Matching double weather (w/o day conflict).
            if spell.element == world.weather_element and (get_weather_intensity() == 2 and spell.element ~= elements.weak_to[world.day_element]) then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 1.7 yalms.
            elseif spell.target.distance < (1.7 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 8 yalms.
            elseif spell.target.distance < (8 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Match day or weather.
            elseif spell.element == world.day_element or spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            end
            if state.QDMode.value == 'Enhance' then
                equip(sets.midcast.CorsairShot.Enhance)
            elseif state.QDMode.value == 'TH' then
                equip(sets.midcast.CorsairShot)
                equip(sets.TreasureHunter)
            elseif state.QDMode.value == 'STP' then
                equip(sets.midcast.CorsairShot.STP)
            end
        end
    elseif spell.action_type == 'Ranged Attack' then
        if buffactive['Triple Shot'] then
            equip(sets.TripleShot)
            if buffactive['Aftermath: Lv.3'] and player.equipment.ranged == "Armageddon" then
                equip(sets.TripleShotCritical)
            end
        elseif buffactive['Aftermath: Lv.3'] and player.equipment.ranged == "Armageddon" then
            equip(sets.midcast.RA.Critical)
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    equip(sets[state.WeaponSet.current])
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") and not spell.interrupted then
        display_roll_info(spell)
    end
    if spell.english == "Light Shot" then
        send_command('@timers c "Light Shot ['..spell.target.name..']" 60 down abilities/00195.png')
    end
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    -- If sub job is DRG
    if player.sub_job == 'DRG' then
        set_macro_page(1, 25)
        -- If sub job is SAM
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 27)
    -- Others Sub-Job    
    else
        set_macro_page(1, 25)
    end
    send_command('wait 20; input /lockstyleset 13')
end