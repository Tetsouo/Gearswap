-- Function to handle interrupted spells.
function handleInterruptedSpell(spell, eventArgs)
    equip(sets.engaged.PDT) -- Equip PDT (Physical Damage Taken) gear to reduce damage taken.
    eventArgs.handled = true -- Mark the event as handled to prevent further processing.
    local message = createFormatMsg('Spell interrupted:', spell.name) -- Create a formatted message indicating the interrupted spell.
    add_to_chat(123, message) -- Display the message in the chat log.
end

-- Function to refine Utsusemi spells.
function refine_Utsusemi(spell, eventArgs)
    local spell_recasts = windower.ffxi.get_spell_recasts() -- Get spell recast times.
    local NiCD = spell_recasts[339] -- Utsusemi: Ni recast time.
    local IchiCD = spell_recasts[338] -- Utsusemi: Ichi recast time.

    if spell.name == 'Utsusemi: Ni' then -- If the spell is Utsusemi: Ni.
        if NiCD > 1 then -- If Utsusemi: Ni is not ready (recast > 1 second).
            eventArgs.cancel = true -- Cancel the spell activation.
            if IchiCD < 1 then -- If Utsusemi: Ichi is ready (recast < 1 second).
                cancel_spell() -- Cancel the current spell cast.
                cast_delay(1.1) -- Delay casting for 1.1 seconds.
                send_command('input /ma "Utsusemi: Ichi" <me>') -- Cast Utsusemi: Ichi on self.
            else
                add_to_chat(123, "Neither Utsusemi spell is ready!") -- Display a message indicating that neither Utsusemi spell is ready.
            end
        end
    end
end

-- Function to get custom weapon skill mode.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode

    if state.Buff['Sneak Attack'] then
        wsmode = 'SA' -- Weapon skill mode with Sneak Attack.
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA' -- Weapon skill mode with Trick Attack.
    end

    return wsmode -- Return the custom weapon skill mode if any buffs are active.
end

-- Function to check if a specific buff is active and equip the corresponding gear.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {}) -- Equip specific gear for the buff if defined in the sets table.
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter) -- Equip TreasureHunter gear if SATA or Fulltime treasure mode is active.
        end
        eventArgs.handled = true -- Mark the event as handled to prevent further processing.
    end
end

-- Function to check if a ranged weapon is equipped and disable/enable the corresponding slots.
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo') -- Disable the range and ammo slots if a ranged weapon is equipped.
    else
        enable('range', 'ammo') -- Enable the range and ammo slots if no ranged weapon is equipped.
    end
end

-- Function to handle gear setup upon status change (buff gain or loss).
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_range_lock() -- Check if a ranged weapon is equipped and handle gear setup accordingly.
    check_weaponset() -- Check and handle main weapon gear set changes.
    check_subset() -- Check and handle sub weapon gear set changes.
    check_buff('Sneak Attack', eventArgs) -- Check if Sneak Attack buff is active and equip corresponding gear.
    check_buff('Trick Attack', eventArgs) -- Check if Trick Attack buff is active and equip corresponding gear.
end

-- Function to customize the idle gear set based on player's HP and HybridMode.
function customize_idle_set(idleSet)
    if player.hp < 1500 then
        idleSet = set_combine(idleSet, sets.idle.Regen) -- If HP is less than 1500, equip Regen gear.
    end
    if state.HybridMode.value == 'PDT' then
        idleSet = set_combine(idleSet, sets.idle.PDT) -- If HybridMode is PDT, equip PDT gear.
    end
    return idleSet -- Return the customized idle gear set.
end

-- Function to customize the melee gear set based on player's HP, TreasureMode, and HybridMode.
function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter) -- If Fulltime treasure mode is active, equip TreasureHunter gear.
    end
    if player.hp <= 800 then
        meleeSet = sets.engaged.PDT -- If HP is less than or equal to 800, equip PDT gear.
    end
    if state.HybridMode.value == 'PDT' then
        meleeSet = set_combine(idleSet, sets.engaged.PDT) -- If HybridMode is PDT, equip PDT gear.
    end
    if state.OffenseMode.current == 'Acc' then
        melee = set_combine(meleeSet, sets.engaged.Acc) -- If OffenseMode is Acc, equip Acc gear for melee.
    end
    return meleeSet -- Return the customized melee gear set.
end

-- Function to update treasure hunter information.
function job_update(cmdParams, eventArgs)
    th_update(cmdParams, eventArgs)
end

-- Function to handle state changes.
function job_state_change(stateField, newValue, oldValue)
    check_weaponset() -- Check and handle main weapon gear set changes.
    check_subset() -- Check and handle sub weapon gear set changes.
end

-- Function to check if certain actions have inherent Treasure Hunter and return true if so.
function th_action_check(category, param)
    if
        category == 2 or -- Any ranged attack
        category == 4 or -- Any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param))
    then -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        return true
    end
end