--____________________________________________________________________________________________________________________________________________________

--                                                            WARRIOR BY TETSOUO
--____________________________________________________________________________________________________________________________________________________
---------------------------------------------------
--                  VARIABLES
---------------------------------------------------

---------------------------------------------------
-- Initialisation des function pour ce fichier.
---------------------------------------------------
function get_sets()
    mote_include_version = 2

    -----------------------------------------------
    -- Chargement et initialisation des inclusions.
    -----------------------------------------------
    include('Mote-Include.lua')
    include('0_AutoMove.lua')
    include('SharedFunctions.lua') -- (Function Shared)
end

----------------------------------------------------------------------------------------------------------------------
-- Configuration des variables pour ce job. les variables State.Buff initialisées ici seront automatiquement suivies.
----------------------------------------------------------------------------------------------------------------------
function job_setup()
end

-------------------------------------------------------------------------------------------------------------------
-- Configuration des functions utilisateurs pour ce job.
-------------------------------------------------------------------------------------------------------------------

------------------------------------------------------
-- Configuration des variables pour cet utilisateurs.
------------------------------------------------------
function user_setup()
    state.HybridMode:options('PDT', 'Normal')
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Lycurgos', 'Naegling', 'Shining', 'Loxotic'} --gs c cycle WeaponSet
    state.SubSet = M {['description'] = 'Sub Weapon', 'Utu', 'Blurred'} --gs c cycle SubSet
    select_default_macro_book()
end

-------------------------------------------------------------------------------------------------------------------------
-- Vide les variables (ex: Bind de touches) lorsque l'ont quitte ce fichier (ex: Changement de job quitte le jeu etc.)
-------------------------------------------------------------------------------------------------------------------------
function user_unload()
end

----------------------------------------------------
-- Initialise les Sets d'équipement pour ce Job.
----------------------------------------------------
function init_gear_sets()
    sets['Shining'] = {main = 'Shining one'}
    sets['Naegling'] = {main = 'Naegling'}
    sets['Lycurgos'] = {main = 'Lycurgos'}
    sets['Bonesplitter'] = {main = 'Bonesplitter'}
    sets['Loxotic'] = {main = 'Loxotic Mace +1'}
    sets['Blurred'] = {sub = 'Blurred Shield +1'}
    sets['Utu'] = {sub = 'Utu Grip'}
    include('WarSet.lua')
end

--____________________________________________________________________________________________________________________________________________________

--                                                                          FUNCTION
--____________________________________________________________________________________________________________________________________________________

--------------------------------------------------
-- Etablie quel Arme principal doit être équipée
--------------------------------------------------
function check_weaponset()
    equip(sets[state.WeaponSet.current])
end

--------------------------------------------------
-- Etablie quel Arme secondaire doit être équipée
--------------------------------------------------
function check_subset()
    equip(sets[state.SubSet.current])
end

include('Tetsouo_WAR_FUNCTION.lua')

--------------------------------------------------------------------------------------------------------------
-- Function qui s'applique juste avant que le sort/Abilité soit lancés.

-- Mettre eventArgs.handled en true Si on ne veut pas que le changement automatique d'equipement ce fasse.
--------------------------------------------------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    incapacitated(spell, eventArgs)
    handleRecastCooldown(spell, eventArgs)
end

--------------------------------------------------------------------------------------------------------------
-- Function qui s'applique pendant que le sort soit lancé.

-- Mettre eventArgs.handled en true Si on ne veut pas que le changement automatique d'equipement ce fasse.
--------------------------------------------------------------------------------------------------------------
-- Actions to perform during casting of a spell or ability
function job_midcast(spell, action, spellMap, eventArgs)
    -- Check for incapacitated state
    if incapacitated() then
        eventArgs.handled = true
        equip(sets.idle)
        return
    end
end

-- Aftercast actions
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Check if the spell is Crusade, Reprisal, Phalanx, or Cocoon
    if spell.name == 'Crusade' or spell.name == 'Reprisal' or spell.name == 'Phalanx' or spell.name == 'Cocoon' then
        if spell.interrupted then
            -- The spell was interrupted
            -- Perform the appropriate actions
            eventArgs.handled = true
            equip(sets.idle)
            local message =
                string.char(0x1F, 159) ..
                'Spell interrupted: [' .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 159) .. ']'
            add_to_chat(123, message)
            add_to_chat(259, '=================================================')
        else
            -- The spell completed normally
            -- Perform the appropriate actions after the spell
        end
    else
        -- Process other spells
        if not spellHandled then
            if spell.interrupted then
                -- The spell was interrupted
                -- Perform the appropriate actions
                eventArgs.handled = true
                equip(sets.idle)
                local message =
                    string.char(0x1F, 159) ..
                    'Spell interrupted: [' .. string.char(0x1F, 221) .. spell.name .. string.char(0x1F, 159) .. ']'
                add_to_chat(123, message)
                add_to_chat(259, '=================================================')
            else
                -- The spell completed normally
                -- Perform the appropriate actions after the spell
            end
            -- Mark the spell as handled
            spellHandled = true
        else
            -- Reset the variable for subsequent spells
            spellHandled = false
        end
    end
end

-------------------------------------------------------------------------------
-- Function qui verifie si un buff vient d'être appliqué ou retiré du joueur.
-------------------------------------------------------------------------------
function job_buff_change(buff, gain)
end

------------------------------------------------------------
-- Function qui change le idleSet sous certaines conditions.
------------------------------------------------------------
function customize_idle_set(idleSet)
    if state.HybridMode.value == 'PDT' then
        idleSet = sets.idle.PDT
    end
    if state.HybridMode.value == 'Normal' then
        idleSet = set_combine(sets.idle, sets.engaged)
    end
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        idleSet = sets.idle.Town
    end
    return idleSet
end

------------------------------------------------------------
-- Function qui change le melee sous certaines conditions.
------------------------------------------------------------
function customize_melee_set(meleeSet)
    if state.HybridMode.value == 'PDT' then
        meleeSet = sets.engaged.PDT
    end
    if state.HybridMode.value == 'Normal' then
        meleeSet = set_combine(sets.idle, sets.engaged)
    end
    return meleeSet
end

----------------------------------------------------------------------------------------------
-- Function qui verifie et équipe L'arme principale et secondaire et la pièce movement speed.
----------------------------------------------------------------------------------------------
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_weaponset()
    check_subset()
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end

---------------------------------------------
-- Function qui vérifie le status du joueur.
---------------------------------------------
function job_status_change(new)
    if new == 'Engaged' then
        if state.HybridMode.value == 'Normal' then
            equip(sets.engaged)
        elseif state.HybridMode.value == 'PDT' then
            equip(sets.engaged.PDT)
        end
    else
        equip(sets.idle)
    end
end

---------------------------------------------------------
-- Function qui vérifie si l'état d'une variable change.
---------------------------------------------------------
function job_state_change(field, new_value, old_value)
    job_handle_equipping_gear(player.status)
    check_weaponset()
    check_subset()
end

-------------------------------------------------------------------------------------------------
-- Function  qui sélectionne le book de macro a appliqué et le lockstyle en fonction du sub job.
-------------------------------------------------------------------------------------------------
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DRG' then
        set_macro_page(1, 24)
        send_command('wait 20;input /lockstyleset 13')
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 27)
        send_command('wait 20;input /lockstyleset 13')
    end
end