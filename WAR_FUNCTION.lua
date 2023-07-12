-- Table containing the equipment sets for each Job Ability
local abilityEquipment = {
    Berserk = {body = 'Pumm. Lorica +3', feet = 'Agoge Calligae +3'},
    Defender = {hands = 'Agoge Mufflers +3'},
    Aggressor = {body = 'Agoge Lorica +3'},
    Warcry = {body = 'Agoge Mask +3'},
    Retaliation = {feet = 'Boii Calligae +3'},
    Restraint = {feet = 'Boii Mufflers +3'}
}

-- Function to buff self with Job Abilities
local function buffSelf(param)
    -- Retrieve the ability recasts and buff status
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
    local buffBloodRage = buffactive['Blood Rage']
    local buffWarcry = buffactive['Warcry']

    -- Define the abilities and their recasts
    local abilities = {
        {name = 'Berserk', recast = AbilityRecasts[1]},
        {name = 'Defender', recast = AbilityRecasts[3]},
        {name = 'Aggressor', recast = AbilityRecasts[4]},
        {name = 'Retaliation', recast = AbilityRecasts[8]},
        {name = 'Restraint', recast = AbilityRecasts[9]},
        {
            name = (AbilityRecasts[2] > 1 and not buffWarcry) and 'Blood Rage' or 'Warcry',
            recast = (AbilityRecasts[2] > 1 and not buffWarcry) and AbilityRecasts[11] or AbilityRecasts[2]
        }
    }
    -- Initialize variables
    local delay = 1 -- Delay in seconds between each ability usage
    local readyAbility = nil -- Next ability to be used
    local delayedAbilities = {} -- Abilities to be used after the delay
    -- Loop through the abilities
    for _, ability in ipairs(abilities) do
        local buffActive = buffactive[ability.name]
        local abilityRecast = ability.recast
        local abilityName = ability.name
        -- Check if the ability is ready and not already active
        if
            not buffActive and abilityRecast < 1 and
                ((param == 'Berserk' and abilityName ~= 'Defender') or
                    (param == 'Defender' and abilityName ~= 'Berserk'))
        then
            -- Assign the first ready ability to be used immediately
            if not readyAbility then
                readyAbility = abilityName
            else
                -- Add other ready abilities to be used after the delay
                table.insert(delayedAbilities, abilityName)
            end
        end
    end
    -- Use the ready ability immediately
    if readyAbility then
        send_command('input /ja "' .. readyAbility .. '" <me>')
    end
    -- Use delayed abilities with a delay between each usage
    for _, abilityName in ipairs(delayedAbilities) do
        send_command('wait ' .. delay .. '; input /ja "' .. abilityName .. '" <me>')
        delay = delay + 1
    end
end

-- Function to handle job-specific self commands
function job_self_command(cmdParams)
    -- Check the input command parameters
    if cmdParams[1] == 'Berserk' then
        local buffDefender = buffactive['Defender']
        -- Handle HybridMode if necessary
        if state.HybridMode.value == 'PDT' then
            send_command('gs c set HybridMode Normal')
        end
        -- Cancel Defender if active
        if buffDefender then
            send_command('cancel defender')
        end
        -- Call buffSelf with the appropriate parameter
        buffSelf('Berserk')
    elseif cmdParams[1] == 'Defender' then
        local buffBerserk = buffactive['Berserk']
        -- Handle HybridMode if necessary
        if state.HybridMode.value == 'Normal' then
            send_command('gs c set HybridMode PDT')
        end
        -- Cancel Berserk if active
        if buffBerserk then
            send_command('cancel berserk')
        end
        -- Call buffSelf with the appropriate parameter
        buffSelf('Defender')
    elseif cmdParams[1] == 'ThirdEye' then
        -- Call ThirdEye function
        ThirdEye()
    elseif cmdParams[1] == 'Jump' then
        -- Call Jump function
        jump()
    end
end

-- Function to handle the Third Eye ability
function ThirdEye()
    -- Retrieve ability recasts and buff statuses
    local allRecasts = windower.ffxi.get_ability_recasts()
    local SeiganCD = allRecasts[139]
    local HassoCD = allRecasts[138]
    local ThirdEyeCD = allRecasts[133]
    local SeiganActive = buffactive['Seigan']
    local HassoActive = buffactive['Hasso']
    local ThirdEyeActive = buffactive['Third Eye']

    -- Check if the subjob is SAM
    if player.sub_job == 'SAM' then
        local isPDTMode = state.HybridMode.value == 'PDT'
        -- Function to activate Third Eye if conditions are met
        local function activateThirdEye()
            if not ThirdEyeActive and ThirdEyeCD < 1 then
                send_command('wait 1; input /ja "Third Eye" <me>')
            end
        end
        if isPDTMode then
            -- Check if Seigan should be activated
            if not SeiganActive and SeiganCD < 1 then
                send_command('input /ja "Seigan" <me>')
                activateThirdEye()
            else
                activateThirdEye()
            end
        else
            -- Check if Hasso should be activated
            if not HassoActive and HassoCD < 1 then
                send_command('input /ja "Hasso" <me>')
                activateThirdEye()
            else
                activateThirdEye()
            end
        end
    end
end

-- Function to handle the Jump ability
function jump()
    -- Retrieve ability recasts and TP
    local JaRecasts = windower.ffxi.get_ability_recasts()
    local JumpCD = JaRecasts[158]
    local HighJumpCD = JaRecasts[159]
    local playerTP = player.tp
    -- Check if Jump and High Jump can be used
    if JumpCD < 1 and HighJumpCD < 1 then
        -- Check if TP is below 500 for using Jump and High Jump together
        if playerTP < 500 then
            send_command('input /ja "Jump" <t>; wait 1; input /ja "High Jump" <t>')
        else
            send_command('input /ja "Jump" <t>')
        end
    elseif HighJumpCD < 1 and playerTP < 800 then
        send_command('input /ja "High Jump" <t>')
    elseif JumpCD < 1 and playerTP < 800 then
        send_command('input /ja "Jump" <t>')
    else
        windower.add_to_chat(123, 'You have enough TP!')
    end
end