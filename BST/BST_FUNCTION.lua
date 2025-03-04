--============================================================--
--=                    BST_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-11-27                     =--
--=               Last Modified: 2023-11-27                  =--
--============================================================--
-- Define a function named "idle" that takes a pet object as a parameter.
function petActive(pet)
    -- Check if the pet object is valid.
    if pet.isvalid then
        -- If the pet is valid, set the mode to 'pan'.
        mode = 'pet'
    else
        -- If the pet is not valid, set the mode to 'me'.
        mode = 'me'
    end
end

sets.Adoulin = set_combine(sets.MoveSpeed, { body = "Councilor's Garb" })
state.Moving = M('false', 'true')
state.EngagedMoving = M('Disabled', 'Enabled')
mov = { counter = 0 }
if player and player.index and windower.ffxi.get_mob_by_index(player.index) then
    mov.x = windower.ffxi.get_mob_by_index(player.index).x
    mov.y = windower.ffxi.get_mob_by_index(player.index).y
    mov.z = windower.ffxi.get_mob_by_index(player.index).z
end
moving = false

windower.raw_register_event(
    'prerender',
    function()
        mov.counter = mov.counter + 1
        if mov.counter > 15 then
            local pl = windower.ffxi.get_mob_by_index(player.index)
            if pl and pl.x and mov.x and state.EngagedMoving.Value == 'Disabled' then
                --we want this to return a false value if these conditions were met, but we drew our weapons whilst moving.
                --we also want this value to become false if we Disable EngagedMovement while engaged.
                if state.Moving.value == 'true' and player.status == 'Engaged' then
                    state.Moving.value = 'false'
                end
                if player.status ~= 'Engaged' then
                    dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)
                    if dist > 1 and not moving then
                        state.Moving.value = 'true'
                        send_command('gs c update')
                        if world.area:contains('Adoulin') then
                            send_command('gs equip sets.Adoulin')
                        else
                        end

                        moving = true
                    elseif dist < 1 and moving then
                        state.Moving.value = 'false'
                        send_command('gs c update')
                        moving = false
                    end
                end
            elseif pl and pl.x and mov.x and state.EngagedMoving.Value == 'Enabled' then
                dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)
                if dist > 1 and not moving then
                    state.Moving.value = 'true'
                    send_command('gs c update')
                    if world.area:contains('Adoulin') then
                        send_command('gs equip sets.Adoulin')
                    else
                    end

                    moving = true
                elseif dist < 1 and moving then
                    state.Moving.value = 'false'
                    send_command('gs c update')
                    moving = false
                end
            end
            if pl and pl.x then
                mov.x = pl.x
                mov.y = pl.y
                mov.z = pl.z
            end
            mov.counter = 0
        end
    end
)

function customize_idle_set(idleSet)
    petActive(pet)

    -- S'assure que l'ammo est toujours appliqué en premier
    if state.ammoSet and state.ammoSet.value then
        idleSet = set_combine(idleSet, sets[state.ammoSet.value])
    end

    -- Gestion des sets en fonction de l'état du Pet
    if not pet then
        -- Cas où le Pet n'existe pas
        idleSet = sets.me.idle
    else
        -- Cas où le Pet existe
        if state.petEngaged.value == 'true' then
            -- Pet engagé
            idleSet = sets.pet.engaged.PDT
        else
            -- Pet non engagé
            idleSet = sets.pet.idle.PDT
        end
    end

    -- Application du mode PDT si actif
    if state.HybridMode.current == 'PDT' then
        idleSet = set_combine(idleSet, sets[mode].PDT)
    end

    -- Application du MoveSpeed si le joueur est en mouvement
    if state.Moving.value == 'true' then
        idleSet = set_combine(idleSet, sets.MoveSpeed)
    end

    -- S'assure que l'ammo est toujours appliqué en dernier
    if state.ammoSet and state.ammoSet.value then
        idleSet = set_combine(idleSet, sets[state.ammoSet.value])
    end

    return idleSet
end

function customize_melee_set(meleeSet)
    petActive(pet)

    -- Cas 1: Pet n'existe pas
    if not pet then
        if player.status == 'Engaged' then
            meleeSet = sets.me.engaged.PDT
        else
            meleeSet = sets.me.idle
        end

        -- Cas 2: Pet existe
    else
        -- Cas 2.1: Pet et Joueur Engagés
        if state.petEngaged.value == 'true' and player.status == 'Engaged' then
            meleeSet = sets.pet.engagedBoth

            -- Cas 2.2: Seulement Pet Engagé
        elseif state.petEngaged.value == 'true' and player.status ~= 'Engaged' then
            meleeSet = sets.pet.engaged

            -- Cas 2.3: Seulement Joueur Engagé
        elseif state.petEngaged.value == 'false' and player.status == 'Engaged' then
            meleeSet = sets.me.engaged

            -- Cas 2.4: Ni Pet ni Joueur Engagés
        else
            meleeSet = sets.pet.idle
        end
    end

    -- Application du mode PDT si actif
    if state.HybridMode.current == 'PDT' then
        meleeSet = set_combine(meleeSet, sets[mode].PDT)
    end

    return meleeSet
end

--- Checks if the player is engaged, the pet exists, and the pet is not engaged.
-- If all these conditions are met, it sends a command to make the pet engage the target.
function check_and_engage_pet()
    petActive(pet)
    if player.status == 'Engaged' and pet.isvalid and state.petEngaged.value == 'false' then
        windower.send_command('input /pet "Fight" <t>')
    end
end

--- Checks if the pet is engaged and customizes gear sets.
-- This function retrieves the pet using `windower.ffxi.get_mob_by_target('pet')`.
-- If the pet exists and its status is 1 (engaged), and `state.petEngaged.current` is not 'true', it sets `state.petEngaged` to 'true' and calls `job_state_change` with 'petEngaged', 'true', and 'false'.
-- If the pet exists and its status is not 1 (not engaged), and `state.petEngaged.current` is not 'false', it sets `state.petEngaged` to 'false' and calls `job_state_change` with 'petEngaged', 'false', and 'true'.
-- If the pet does not exist, it sets `state.petEngaged` to 'false' and calls `job_state_change` with 'petEngaged', 'false', and 'true'.
function check_pet_engaged()
    local pet = windower.ffxi.get_mob_by_target('pet')
    if pet then
        if pet.status == 1 and state.petEngaged.current ~= 'true' then
            -- Pet is engaged and state.petEngaged was not 'true'
            state.petEngaged:set('true')
            job_state_change('petEngaged', 'true', 'false')
        elseif pet.status ~= 1 and state.petEngaged.current ~= 'false' then
            -- Pet is not engaged and state.petEngaged was not 'false'
            state.petEngaged:set('false')
            job_state_change('petEngaged', 'false', 'true')
        end
    else
        state.petEngaged:set('false')
        job_state_change('petEngaged', 'false', 'true')
    end
end

-- Registers a 'time change' event with Windower.
-- When the time changes, it calls `check_pet_engaged` and `check_and_engage_pet`.
windower.register_event('time change', function(new_time)
    check_pet_engaged()
    --[[ check_and_engage_pet() ]]
    send_command('gs c update')
end)

--- Executes custom job-specific commands.
-- @param {table} cmdParams - The command parameters, with the command name expected as the first element.
-- @param {table} eventArgs - Additional event arguments.
-- @param {table} spell - The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the alternate state.
    update_altState()
    local command = cmdParams[1]:lower()

    -- If the command is predefined, execute it.
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- If the command is not predefined, handle it as a Thief-specific command.
        handle_thf_commands(cmdParams)

        -- If the subjob is Scholar, handle it as a Scholar-specific command.
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end

--- Sets the precast gear for pet actions.
-- This function checks the name of the spell and sets the precast gear accordingly.
-- If the spell name is not 'Fight', 'Heel', 'Leave', or 'Stay', it includes the "Charmer's Merlin" as the main item.
-- Otherwise, it excludes the "Charmer's Merlin" from the precast set.
-- @param spell The spell to be checked.
-- @param action The action to be performed.
-- @param spellMap The map of the spell.
-- @param eventArgs The event arguments.
function job_pet_precast(spell, action, spellMap, eventArgs)
    if spell.name ~= 'Fight' and spell.name ~= 'Bestial Loyalty' and spell.name ~= 'Call Beast' and spell.name ~= 'Heel' and spell.name ~= 'Leave' and spell.name ~= 'Stay' and player.status ~= 'Engaged' then
        sets.precast.JA = {
            main = "Charmer's Merlin",
            hands = "Ankusa Gloves +3",
            legs = "Gleti's Breeches",
        }
    else
        sets.precast.JA = {
            hands = "Ankusa Gloves +3",
            legs = "Gleti's Breeches",
        }
    end
end

function job_pet_midcast(spell, action, spellMap, eventArgs)
    if pet_physical_moves:contains(spell.name) then
        equip(sets.midcast.pet_physical_moves)
    end

    if pet_physicalMulti_moves:contains(spell.name) then
        equip(sets.midcast.pet_physicalMulti_moves)
    end

    if pet_magicAtk_moves:contains(spell.name) then
        if player.status == 'Engaged' then
            equip(sets.midcast.pet_magicAtk_moves_ww)
        else
            equip(sets.midcast.pet_magicAtk_moves)
        end
    end

    if pet_magicAcc_moves:contains(spell.name) then
        if player.status == 'Engaged' then
            equip(sets.midcast.pet_magicAcc_moves_ww)
        else
            equip(sets.midcast.pet_magicAcc_moves)
        end
    end

    if petTp_moves:contains(spell.name) then
        equip(sets.midcast.pet_physical_moves)
    end
end
