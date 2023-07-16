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
    local buffWarcry = buffactive['Warcry']
    -- Define the abilities and their recasts
    local abilities = {
        {name = 'Berserk', recast = AbilityRecasts[1], equip = abilityEquipment['Berserk']},
        {name = 'Defender', recast = AbilityRecasts[3], equip = abilityEquipment['Defender']},
        {name = 'Aggressor', recast = AbilityRecasts[4], equip = abilityEquipment['Aggressor']},
        {name = 'Retaliation', recast = AbilityRecasts[8], equip = abilityEquipment['Retaliation']},
        {name = 'Restraint', recast = AbilityRecasts[9], equip = abilityEquipment['Restraint']},
        {
            name = (AbilityRecasts[2] > 1 and not buffWarcry) and 'Blood Rage' or 'Warcry',
            recast = (AbilityRecasts[2] > 1 and not buffWarcry) and AbilityRecasts[11] or AbilityRecasts[2],
            equip = {}
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
                readyAbility = ability
            else
                -- Add other ready abilities to be used after the delay
                table.insert(delayedAbilities, ability)
            end
        end
    end
    -- Use the ready ability immediately
    if readyAbility then
        -- Equip the corresponding gear
        for slot, item in pairs(readyAbility.equip) do
            send_command('equip ' .. item .. ' ' .. slot)
        end   
        send_command('input /ja "' .. readyAbility.name .. '" <me>')
    end
    -- Use delayed abilities with a delay between each usage
    for _, ability in ipairs(delayedAbilities) do
        -- Equip the corresponding gear
        for slot, item in pairs(ability.equip) do
            send_command('equip ' .. item .. ' ' .. slot)
        end   
        send_command('wait ' .. delay .. '; input /ja "' .. ability.name .. '" <me>')
        delay = delay + 1
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
    -- Initialize variables
    local messages = {}  -- Stores messages to display
    local jaName1 = 'Jump'  -- Name of the first jump ability
    local jaName2 = 'High Jump'  -- Name of the second jump ability
    local JaRecasts = windower.ffxi.get_ability_recasts()  -- Retrieves ability recast times
    local jumpId = 158  -- ID of the first jump ability
    local highJumpId = 159  -- ID of the second jump ability
    local playerTP = player.tp  -- Retrieves player's TP

    if playerTP < 1000 then
        -- Check if Jump and High Jump can be used
        if JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP < 500 then
            -- Execute command to use both jump abilities
            send_command(
                string.format('input /ja "%s" <t>; wait 1; input /ja "%s" <t>', jaName1, jaName2)
            )
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] < 1 and playerTP > 500 and playerTP < 1000 then
            -- Execute command to use the first jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName1)
            )
        elseif JaRecasts[jumpId] < 1 and JaRecasts[highJumpId] > 1 then
            -- Execute command to use the first jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName1)
            )
        elseif JaRecasts[jumpId] > 1 and JaRecasts[highJumpId] < 1 then
            -- Execute command to use the second jump ability
            send_command(
                string.format('input /ja "%s" <t>', jaName2)
            )
        else
            -- Create messages for both jump abilities and store them in the messages table
            local message1 = createFormatMsg(nil, jaName1, JaRecasts[jumpId], nil)
            table.insert(messages, {spell = jaName1, recast = JaRecasts[jumpId], message = message1})
            local message2 = createFormatMsg(nil, jaName2, JaRecasts[highJumpId], nil)
            table.insert(messages, {spell = jaName2, recast = JaRecasts[highJumpId], message = message2})
        end
    else
        -- Create a message indicating that the player has enough TP and display it
        local message = createFormatMsg('TP:', playerTP, nil, 'You have enough TP !!!')
        add_to_chat(057, message)
    end
    -- Check if there are messages in the table and display them
    checkAndDisplayMessages(messages)
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

-- Handles actions to be performed when a spell is interrupted.
-- Parameters:
--   spell (table): The interrupted spell.
--   eventArgs (table): Additional event arguments.
function handleInterruptedSpell(spell, eventArgs)
    equip(sets.idle)
    eventArgs.handled = true
    local message = createFormatMsg('Spell interrupted:', spell.name)
    add_to_chat(123, message)
end