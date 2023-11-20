--============================================================--
--=                    WAR_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--


-- Function to buff self with Job Abilities
function buffSelf(param)
    -- Retrieve the ability recasts and buff status
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
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
                readyAbility = ability
            else
                -- Add other ready abilities to be used after the delay
                table.insert(delayedAbilities, ability)
            end
        end
    end
    -- Use the ready ability immediately
    if readyAbility then
        send_command('input /ja "' .. readyAbility.name .. '" <me>')
        delay = delay + 1
    end
    -- Use delayed abilities with a delay between each usage
    for _, ability in ipairs(delayedAbilities) do
        send_command('wait ' .. delay .. '; input /ja "' .. ability.name .. '" <me>')
        delay = delay + 2
        job_handle_equipping_gear()
    end
end

-- Function to handle the Third Eye ability
function ThirdEye()
    -- Retrieve ability recasts and buff statuses
    local messages = {}  -- Table to store messages for display
    local allRecasts = windower.ffxi.get_ability_recasts()  -- Get all ability recasts
    local SeiganCD = allRecasts[139]  -- Get the recast time for Seigan ability
    local HassoCD = allRecasts[138]  -- Get the recast time for Hasso ability
    local ThirdEyeCD = allRecasts[133]  -- Get the recast time for Third Eye ability
    local SeiganActive = buffactive['Seigan']  -- Check if Seigan buff is active
    local HassoActive = buffactive['Hasso']  -- Check if Hasso buff is active
    local ThirdEyeActive = buffactive['Third Eye']  -- Check if Third Eye buff is active
    local BerserkActive = buffactive['Berserk']  -- Check if Third Eye buff is active
    local DefenderActive = buffactive['Defender']  -- Check if Third Eye buff is active
    
    -- Check if the subjob is SAM (Samurai)
    if player.sub_job == 'SAM' then
        -- Function to activate Third Eye if conditions are met
        local function activateThirdEye()
            if not ThirdEyeActive and ThirdEyeCD == 0 then
                send_command('wait 1; input /ja "Third Eye" <me>')  -- Activate Third Eye ability
            else
                local message = createFormatMsg(nil, 'Third Eye', ThirdEyeCD)  -- Create message for Third Eye recast time
                table.insert(messages, {spell = 'Third Eye', recast = ThirdEyeCD, message = message})  -- Insert message into messages table
                checkAndDisplayMessages(messages)  -- Check and display messages
            end
        end

    local function checkSeiganOrHasso(active, CD, ability)
        if not active and CD == 0 then
            send_command('input /ja ' .. ability .. ' <me>')  -- Activate Seigan ability
            activateThirdEye()  -- Call activateThirdEye function
        elseif SeiganActive and SeiganCD > 0 then
            local message = createFormatMsg(nil, ability, CD)  -- Create message for Seigan recast time
            table.insert(messages, {spell = ability, recast = CD, message = message})  -- Insert message into messages table
            activateThirdEye()  -- Call activateThirdEye function
        else
            activateThirdEye()  -- Call activateThirdEye function
        end
    end


        -- If in Defender, check if Seigan should be activated
        if DefenderActive then
            checkSeiganOrHasso(SeiganActive, SeiganCD, "Seigan")
        elseif BerserkActive then
            checkSeiganOrHasso(HassoActive, HassoCD, "Hasso")
        else
            checkSeiganOrHasso(HassoActive, HassoCD, "Hasso")
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
        add_to_chat(057, "You dont have Enough TP !!!")
        local message = createFormatMsg('TP:', playerTP, nil, 'You have enough TP !!!')
        add_to_chat(057, message)
    end
    -- Check if there are messages in the table and display them
    checkAndDisplayMessages(messages)
end

-- Customize idle_set based on the current HybridMode and the current area.
    function customize_idle_set(idleSet)
        -- If the HybridMode is set to 'PDT' (Physical Damage Taken), assign the 'sets.idle.PDT' equipment set to idleSet.
        if state.HybridMode.value == 'PDT' then
            idleSet = sets.idle.PDT
        end
        -- If the HybridMode is set to 'Normal', combine the 'sets.idle' and 'sets.engaged' equipment sets and assign them to idleSet.
        if state.HybridMode.value == 'Normal' then
            idleSet = set_combine(sets.idle, sets.engaged)
        end
        -- If the character is in a city area (excluding Dynamis), assign the 'sets.idle.Town' equipment set to idleSet.
        if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
            idleSet = sets.idle.Town
        end
        -- Return the modified equipment set.
        return idleSet
    end

-- -- Customize melee_set based on the current HybridMode and the current area.
    function customize_melee_set(meleeSet)
        -- If the HybridMode is set to 'PDT' (Physical Damage Taken), assign the 'sets.engaged.PDT' equipment set to meleeSet.
        if state.HybridMode.value == 'PDT' then
            meleeSet = sets.engaged.PDT
        end
        -- If the HybridMode is set to 'Normal', combine the 'sets.idle' and 'sets.engaged' equipment sets and assign them to meleeSet.
        if state.HybridMode.value == 'Normal' then
            meleeSet = set_combine(sets.idle, sets.engaged)
        end
        -- Return the modified equipment set.
        return meleeSet
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

-- ***************************************************************************
-- * Appelé à chaque changement de stuffs automatique (ex: Engaged ou Idle). *
-- ***************************************************************************
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_weaponset()
    check_subset()
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end

function TPWS(spell)
    if 
    (player.tp >= 1650 and player.tp < 2000) or 
    (player.tp >= 2650 and player.tp < 3000) and
    spell.type == 'WeaponSkill' then
        sets.precast.WS = {
            ammo = 'Knobkierrie',
            head = 'Agoge Mask +3',
            body = 'Pumm. Lorica +3',
            hands = 'Boii Mufflers +3',
            legs = 'Boii Cuisses +3',
            feet = 'Sulev. Leggings +2',
            neck = {name = 'War. Beads +2', augments = {'Path: A'}},
            waist = 'Sailfi Belt +1',
            left_ear = 'Thrud Earring',
            right_ear = 'MoonShade Earring',
            left_ring = 'Regal Ring',
            right_ring = "Cornelia's Ring",
            back = Cichol.ws1
        }
    elseif (player.tp >= 1900 and player.tp < 2000) or 
    (player.tp >= 2900 and player.tp < 3000) and
    spell.type == 'WeaponSkill' then
        sets.precast.WS = {
            ammo = 'Knobkierrie',
            head = 'Agoge Mask +3',
            body = 'Pumm. Lorica +3',
            hands = 'Boii Mufflers +3',
            legs = 'Boii Cuisses +3',
            feet = 'Sulev. Leggings +2',
            neck = {name = 'War. Beads +2', augments = {'Path: A'}},
            waist = 'Sailfi Belt +1',
            left_ear = 'Thrud Earring',
            right_ear = {
                name = 'Boii Earring +1',
                augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
            },
            left_ring = 'Regal Ring',
            right_ring = "Cornelia's Ring",
            back = Cichol.ws1
        }
    else
        sets.precast.WS = {
            ammo = 'Knobkierrie',
            head = 'Agoge Mask +3',
            body = 'Pumm. Lorica +3',
            hands = 'Boii Mufflers +3',
            legs = 'Valorous Hose',
            feet = 'Sulev. Leggings +2',
            neck = {name = 'War. Beads +2', augments = {'Path: A'}},
            waist = 'Sailfi Belt +1',
            left_ear = 'Thrud Earring',
            right_ear = {
                name = 'Boii Earring +1',
                augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
            },
            left_ring = 'Regal Ring',
            right_ring = "Cornelia's Ring",
            back = Cichol.ws1
        }
    end
end