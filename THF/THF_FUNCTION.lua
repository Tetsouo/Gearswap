--============================================================--
--=                    THF_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024/02/08                  =--
--============================================================--

-- Initialize an empty table to store automatic abilities mappings
local auto_abilities = {}

-- Buffs the player with specific abilities if the provided parameter is 'thfBuff'.
-- @param {string} param - The parameter to determine if the function should run.
function buffSelf(param)
    -- Get the current ability recast times.
    local AbilityRecasts = windower.ffxi.get_ability_recasts()

    -- Define the abilities to use and their corresponding recast times.
    local abilities = {
        { name = 'Feint',       recast = AbilityRecasts[68] },
        { name = 'Bully',       recast = AbilityRecasts[240] },
        { name = 'Conspirator', recast = AbilityRecasts[40] }
    }

    -- Initialize variables.
    local delay = 1             -- The delay in seconds between each ability usage.
    local readyAbility = nil    -- The next ability to be used.
    local delayedAbilities = {} -- The list of abilities to be used after the delay.

    -- Iterate over the abilities.
    for _, ability in ipairs(abilities) do
        -- Check if the ability is ready to use, not active, and the param is 'thfBuff'.
        if not buffactive[ability.name] and ability.recast < 1 and param == 'thfBuff' then
            -- If no ability is ready, set the current ability as the ready ability.
            if not readyAbility then
                readyAbility = ability
            else
                -- If an ability is already ready, add the current ability to the delayed abilities list.
                table.insert(delayedAbilities, ability)
            end
        end
    end

    -- Use the ready ability immediately.
    if readyAbility then
        send_command('input /ja "' .. readyAbility.name .. '" ' .. (readyAbility.name == 'Bully' and '<t>' or '<me>'))
        delay = delay + 1
    end

    -- Use delayed abilities with a delay between each usage.
    for _, ability in ipairs(delayedAbilities) do
        send_command(
            'wait ' .. delay .. '; input /ja "' .. ability.name .. '" ' .. (ability.name == 'Bully' and '<t>' or '<me>')
        )
        delay = delay + 2
    end
end

-- Determines the custom weapon skill mode based on active buffs.
-- @param {table} spell - The spell being cast.
-- @param {string} spellMap - The map of the spell.
-- @param {string} default_wsmode - The default weapon skill mode.
-- @return {string} The custom weapon skill mode if 'Sneak Attack' or 'Trick Attack' buffs are active.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode

    -- Check if 'Sneak Attack' buff is active. If so, set the weapon skill mode to 'SA'.
    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end

    -- Check if 'Trick Attack' buff is active. If so, append 'TA' to the weapon skill mode.
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    -- Return the custom weapon skill mode. If no buffs are active, this will be nil.
    return wsmode
end

-- Customizes the idle set based on the current state.
-- @param {table} idleSet - The base idle set.
-- @return {table} The customized idle set.
function customize_idle_set(idleSet)
    -- If player's HP is less than 2000, add the Regen set to the idle set.
    if player.hp < 2000 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end

    -- Get the conditions and sets for customizing the idle set.
    local conditions, setTable = get_conditions_and_sets(sets.idle.PDT, sets.idle.PDT, sets.defense.MDT)

    -- Customize the idle set based on the conditions and sets.
    return customize_set(idleSet, conditions, setTable)
end

-- Customizes the melee set based on the current state.
-- @param {table} meleeSet - The base melee set.
-- @return {table} The customized melee set.
function customize_melee_set(meleeSet)
    -- If Treasure Mode is set to 'Fulltime', add the Treasure Hunter set to the melee set.
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end

    -- If player's HP is less than or equal to 2000, switch to the PDT engaged set.
    if player.hp <= 2000 then
        meleeSet = sets.engaged.PDT
    end

    -- If Offense Mode is set to 'Acc', add the Accuracy engaged set to the melee set.
    if state.OffenseMode.current == 'Acc' then
        meleeSet = set_combine(meleeSet, sets.engaged.Acc)
    end

    -- Get the conditions and sets for customizing the melee set.
    local conditions, setTable = get_conditions_and_sets(sets.engaged.PDT, sets.engaged.PDT, sets.defense.MDT)

    -- Customize the melee set based on the conditions and sets.
    return customize_set(meleeSet, conditions, setTable)
end

--- Handles job updates by refreshing the Treasure Hunter status.
-- @param {table} cmdParams - The parameters of the command triggering the job update.
-- @param {table} eventArgs - Additional arguments associated with the event.
function job_update(cmdParams, eventArgs)
    -- Delegate the update to the Treasure Hunter specific function.
    th_update(cmdParams, eventArgs)
end

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
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
