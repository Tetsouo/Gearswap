--============================================================--
--=                    WAR_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

-- Buffs the player with job abilities, excluding a specified ability.
-- The function retrieves the ability recasts and buff status, then loops through the abilities.
-- If an ability is ready and not already active, it is assigned to be used immediately or after a delay.
-- The function then uses the ready ability immediately and the delayed abilities with a delay between each usage.
-- Parameters:
--   param (string): The name of the ability to exclude from the buffing process
function buffSelf(param)
    -- Retrieves the ability recasts and buff status.
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
    local buffWarcry = buffactive['Warcry']

    -- Defines the abilities and their recasts.
    local abilities = {
        { name = 'Berserk',     recast = AbilityRecasts[1] },
        { name = 'Defender',    recast = AbilityRecasts[3] },
        { name = 'Aggressor',   recast = AbilityRecasts[4] },
        { name = 'Retaliation', recast = AbilityRecasts[8] },
        { name = 'Restraint',   recast = AbilityRecasts[9] },
        {
            name = (AbilityRecasts[2] > 1 and not buffWarcry) and 'Blood Rage' or 'Warcry',
            recast = (AbilityRecasts[2] > 1 and not buffWarcry) and AbilityRecasts[11] or AbilityRecasts[2]
        }
    }

    local delay = 1
    local readyAbility = nil
    local delayedAbilities = {}

    for _, ability in ipairs(abilities) do
        local buffActive = buffactive[ability.name]
        local abilityRecast = ability.recast
        local abilityName = ability.name

        if
            not buffActive and abilityRecast < 1 and
            ((param == 'Berserk' and abilityName ~= 'Defender') or
                (param == 'Defender' and abilityName ~= 'Berserk'))
        then
            if not readyAbility then
                readyAbility = ability
            else
                table.insert(delayedAbilities, ability)
            end
        end
    end

    if readyAbility then
        send_command('input /ja "' .. readyAbility.name .. '" <me>')
        delay = delay + 1
    end

    for _, ability in ipairs(delayedAbilities) do
        send_command('wait ' .. delay .. '; input /ja "' .. ability.name .. '" <me>')
        delay = delay + 2
    end
end

-- Handles the "Third Eye" ability based on the player's subjob and current buffs.
function ThirdEye()
    local allRecasts = windower.ffxi.get_ability_recasts()
    local SeiganCD = allRecasts[139]
    local HassoCD = allRecasts[138]
    local ThirdEyeCD = allRecasts[133]
    local SeiganActive = buffactive['Seigan']
    local HassoActive = buffactive['Hasso']
    local ThirdEyeActive = buffactive['Third Eye']
    local BerserkActive = buffactive['Berserk']
    local DefenderActive = buffactive['Defender']

    if player.sub_job == 'SAM' then
        local function activateThirdEye()
            if not ThirdEyeActive and ThirdEyeCD == 0 then
                send_command('wait 1; input /ja "Third Eye" <me>')
            else
                add_to_chat(123, createFormattedMessage(nil, 'Third Eye', ThirdEyeCD, nil, true))
            end
        end

        local function checkSeiganOrHasso(active, CD, ability)
            if not active and CD == 0 then
                send_command('input /ja ' .. ability .. ' <me>')
                send_command('wait 1; input /ja "Third Eye" <me>')
            elseif SeiganActive and SeiganCD > 0 then
                add_to_chat(createFormattedMessage(nil, ability, CD, nil, true))
                send_command('input /ja "Third Eye" <me>')
            else
                send_command('input /ja "Third Eye" <me>')
            end
        end

        if DefenderActive then
            checkSeiganOrHasso(SeiganActive, SeiganCD, 'Seigan')
        elseif BerserkActive then
            checkSeiganOrHasso(HassoActive, HassoCD, 'Hasso')
        else
            checkSeiganOrHasso(HassoActive, HassoCD, 'Hasso')
        end
    end
end

-- Handles the "Jump" and "High Jump" abilities based on the player's TP and ability recast times.
function jump()
    local jaName1 = 'Jump'
    local jaName2 = 'High Jump'
    local JaRecasts = windower.ffxi.get_ability_recasts()
    local jumpId = 158
    local highJumpId = 159
    local playerTP = player.tp

    if playerTP < 1000 then
        if JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP < 500 then
            send_command(string.format('input /ja "%s" <t>; wait 1; input /ja "%s" <t>', jaName1, jaName2))
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP > 500 and playerTP < 1000 then
            send_command(string.format('input /ja "%s" <t>', jaName1))
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] > 1 then
            send_command(string.format('input /ja "%s" <t>', jaName1))
        elseif JaRecasts[jumpId] > 1 and JaRecasts[highJumpId] < 1 then
            send_command(string.format('input /ja "%s" <t>', jaName2))
        else
            local message1 = createFormattedMessage(nil, jaName1, JaRecasts[jumpId], nil)
            add_to_chat(057, message1)
            local message2 = createFormattedMessage(nil, jaName2, JaRecasts[highJumpId], nil)
            add_to_chat(057, message2)
        end
    else
        add_to_chat(057, 'You dont have Enough TP !!!')
        local message = createFormattedMessage('TP:', playerTP, nil, 'You have enough TP !!!')
        add_to_chat(057, message)
    end
end

-- Adjusts the idle set based on the current HybridMode and area.
-- @param idleSet: The initial set of equipment.
-- @return: The adjusted set of equipment.
function customize_idle_set(idleSet)
    if state.HybridMode.value == 'PDT' then
        idleSet = sets.idle.PDT
    elseif state.HybridMode.value == 'Normal' then
        idleSet = set_combine(sets.idle, sets.engaged)
    elseif areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        idleSet = sets.idle.Town
    end
    return idleSet
end

-- Adjusts the precast weapon skill set based on the player's TP and the type of spell.
-- @param spell: The spell object containing information about the spell being cast.
function TPWS(spell)
    -- Base set for precast weapon skill
    local baseSet = sets.precast.WS
    -- Check if the player's TP is between 1650 and 2000 or between 2650 and 3000, and the spell is a WeaponSkill.
    if ((player.tp >= 1650 and player.tp < 2000) or (player.tp >= 2650 and player.tp < 3000)) and spell.type == 'WeaponSkill' then
        sets.precast.WS = baseSet
        -- Check if the player's TP is between 1900 and 2000 or between 2900 and 3000, and the spell is a WeaponSkill.
    elseif ((player.tp >= 1900 and player.tp < 2000) or (player.tp >= 2900 and player.tp < 3000)) and spell.type == 'WeaponSkill' then
        baseSet.right_ear = {
            name = 'Boii Earring +1',
            augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4' }
        }
        sets.precast.WS = baseSet
    else
        baseSet.legs = 'Valorous Hose'
        baseSet.right_ear = {
            name = 'Boii Earring +1',
            augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4' }
        }
        sets.precast.WS = baseSet
    end
end

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
-- Handles custom commands specific to the job.
-- It updates the altState object, handles a set of predefined commands, and handles job-specific and subjob-specific commands.
-- @param cmdParams (table): The command parameters. The first element is expected to be the command name.
-- @param eventArgs (table): Additional event arguments.
-- @param spell (table): The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the altState object
    update_altState()
    local command = cmdParams[1]:lower()

    -- If the command is defined, execute it
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        handle_war_commands(cmdParams)

        -- Handle subjob-specific commands
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end
