local abilityEquipment = {
    Berserk = {body = 'Pumm. Lorica +3', feet = 'Agoge Calligae +3'},
    Defender = {hands = 'Agoge Mufflers +3'},
    Aggressor = {body = 'Agoge Lorica +3'},
    Warcry = {body = 'Agoge Mask +3'},
    Retaliation = {feet = 'Boii Calligae +3'},
    Restraint = {feet = 'Boii Mufflers +3'}
}

local function buffSelf(mode, recastId)
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
    local currentDelay = 0
    local buffDefender = buffactive['Defender']
    local buffBerserk = buffactive['Berserk']
    local buffBloodRage = buffactive['Blood Rage']
    local buffWarcry = buffactive['Warcry']
    local abilities = {
        {name = mode, recast = recastId, index = 1},
        {name = 'Aggressor', recast = AbilityRecasts[4], index = 3},
        {name = 'Retaliation', recast = AbilityRecasts[8], index = 4},
        {name = 'Restraint', recast = AbilityRecasts[9], index = 5},
        {
            name = AbilityRecasts[2] > 1 and not buffactive['Warcry'] and 'Blood Rage' or 'Warcry',
            recast = (AbilityRecasts[2] > 1 and not buffactive['Warcry']) and AbilityRecasts[11] or AbilityRecasts[2],
            index = 2
        }
    }

    for _, ability in ipairs(abilities) do
        local buffActive = buffactive[ability.name]
        local abilityRecast = AbilityRecasts[ability.recast] or 0
        if not buffActive and abilityRecast == 0 then
            local abilityName = ability.name
            if abilityEquipment[abilityName] then
                equip(abilityEquipment[abilityName])
            end
            if abilityName == 'Blood Rage' and not (buffBloodRage and buffWarcry) and ability.recast > 1 then
                -- Do nothing in this particular case
            else
                send_command('wait ' .. currentDelay .. '; input /ja "' .. abilityName .. '" <me>')
                currentDelay = currentDelay + 1
            end
        end
    end
end

function job_self_command(cmdParams, eventArgs)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local BerserkCD = allRecasts[1]
    local DefenderCD = allRecasts[3]
    local BerserkActive = buffactive['Berserk']
    local DefenderActive = buffactive['Defender']
    if cmdParams[1] == 'Berserk' then
        local buffDefender = buffactive['Defender']
        if state.HybridMode.value == 'PDT' then
            send_command('gs c set HybridMode Normal')
        end
        if buffDefender then
            send_command('cancel defender')
        end
        buffSelf('Berserk', 1)
    elseif cmdParams[1] == 'Defender' then
        local buffBerserk = buffactive['Berserk']
        if state.HybridMode.value == 'Normal' then
            send_command('gs c set HybridMode PDT')
        end
        if buffBerserk then
            send_command('cancel berserk')
        end
        buffSelf('Defender', 3)
    elseif cmdParams[1] == 'ThirdEye' then
        ThirdEye(DefenderActive, BerserkActive)
    end
end

function ThirdEye(DefenderActive, BerserkActive)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local SeiganCD = allRecasts[139]
    local HassoCD = allRecasts[138]
    local ThirdEyeCD = allRecasts[133]
    local SeiganActive = buffactive['Seigan']
    local HassoActive = buffactive['Hasso']
    local ThirdEyeActive = buffactive['Third Eye']
    if player.sub_job == 'SAM' then
        local isPDTMode = state.HybridMode.value == 'PDT'
        local function activateThirdEye()
            if not ThirdEyeActive and ThirdEyeCD < 1 then
                send_command('wait 1; input /ja "Third Eye" <me>')
            end
        end
        if isPDTMode then
            if not SeiganActive and SeiganCD < 1 then
                send_command('input /ja "Seigan" <me>')
                activateThirdEye()
            else
                activateThirdEye()
            end
        else
            if not HassoActive and HassoCD < 1 then
                send_command('input /ja "Hasso" <me>')
                activateThirdEye()
            else
                activateThirdEye()
            end
        end
    end
end
