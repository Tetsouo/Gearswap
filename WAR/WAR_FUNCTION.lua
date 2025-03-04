--============================================================--
--=                    WAR_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

--[[
    Function: buffSelf
    Buffs the player with job abilities, excluding a specified ability if provided.
    The function retrieves the ability recast timers and active buffs, then iterates through a list of abilities.
    It uses abilities that are ready (off cooldown), not currently active, and not excluded based on the parameter.
    The first available ability is used immediately, and subsequent abilities are scheduled with incremental delays.

    Parameters:
        param (string): (Optional) The name of the ability to exclude from the buffing process.
        If 'Berserk' is provided, 'Defender' will be excluded, and vice versa.
]]
function buffSelf(param)
    -- Retrieve ability recast timers and active buffs
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Define abilities with their IDs and associated buffs
    local abilities = {
        { name = 'Berserk',     id = 1, buff = 'Berserk' },
        { name = 'Defender',    id = 3, buff = 'Defender' },
        { name = 'Aggressor',   id = 4, buff = 'Aggressor' },
        { name = 'Retaliation', id = 8, buff = 'Retaliation' },
        { name = 'Restraint',   id = 9, buff = 'Restraint' },
    }

    -- Handle Warcry and Blood Rage abilities
    -- If 'Warcry' is not active, attempt to use 'Warcry' or 'Blood Rage' based on recast timers
    local warcryRecast = AbilityRecasts[2] or 0     -- Warcry ID: 2
    local bloodRageRecast = AbilityRecasts[11] or 0 -- Blood Rage ID: 11
    if not buffs['Warcry'] then
        if warcryRecast == 0 then
            -- Add 'Warcry' to abilities list if it's ready and not active
            table.insert(abilities, { name = 'Warcry', id = 2, buff = 'Warcry' })
        elseif bloodRageRecast == 0 then
            -- Add 'Blood Rage' to abilities list if 'Warcry' is on cooldown and 'Blood Rage' is ready
            -- 'Blood Rage' grants the 'Warcry' effect
            table.insert(abilities, { name = 'Blood Rage', id = 11, buff = 'Warcry' })
        end
    end

    -- Exclude abilities based on the parameter
    -- If 'Berserk' is specified, exclude 'Defender', and vice versa
    local exclude = {}
    if param == 'Berserk' then
        exclude['Defender'] = true
    elseif param == 'Defender' then
        exclude['Berserk'] = true
    end

    -- Initialize delay and a flag to track if the first ability has been used
    local delay = 0
    local firstAbilityUsed = false

    -- Iterate through the abilities to determine which ones to use
    for _, ability in ipairs(abilities) do
        local recast = AbilityRecasts[ability.id] or 0
        local isActive = buffs[ability.buff]
        local isExcluded = exclude[ability.name]

        -- Check if the ability is ready, not active, and not excluded
        if not isActive and recast == 0 and not isExcluded then
            if not firstAbilityUsed then
                -- Use the first available ability immediately
                send_command('input /ja "' .. ability.name .. '" <me>')
                firstAbilityUsed = true
                delay = delay + 1 -- Increment delay for subsequent abilities
            else
                -- Schedule subsequent abilities with incremental delays
                send_command('wait ' .. delay .. '; input /ja "' .. ability.name .. '" <me>')
                delay = delay + 2 -- Increase delay to prevent ability overlap
            end
        end
    end
end

function ThirdEye()
    -- Exit early if the player's sub-job is not Samurai
    if player.sub_job ~= 'SAM' then
        return
    end

    -- Retrieve ability recast timers and active buffs
    local allRecasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Define abilities with their IDs, active status, and recast timers
    local abilities = {
        Seigan = {
            id = 139,
            active = buffs['Seigan'],
            recast = allRecasts[139],
        },
        Hasso = {
            id = 138,
            active = buffs['Hasso'],
            recast = allRecasts[138],
        },
        ThirdEye = {
            id = 133,
            active = buffs['Third Eye'],
            recast = allRecasts[133],
        },
    }

    -- Check for specific active buffs
    local defenderActive = buffs['Defender']
    -- Note: 'Berserk' is checked in original code but not used; removed for clarity

    -- Determine the preferred ability based on active buffs
    local preferredAbilityName = defenderActive and 'Seigan' or 'Hasso'
    local preferredAbility = abilities[preferredAbilityName]
    local thirdEye = abilities['ThirdEye']

    -- Function to display a formatted cooldown message for an ability
    local function displayCooldownMessage(abilityName, cooldown)
        local message = createFormattedMessage(nil, abilityName, cooldown, nil, true)
        add_to_chat(123, message)
    end

    -- Attempt to activate the preferred ability
    if not preferredAbility.active and preferredAbility.recast == 0 then
        -- Activate the preferred ability
        send_command('input /ja "' .. preferredAbilityName .. '" <me>')
        -- After a short delay, attempt to activate 'Third Eye'
        if not thirdEye.active and thirdEye.recast == 0 then
            send_command('wait 1; input /ja "Third Eye" <me>')
        elseif thirdEye.recast > 0 then
            -- Display cooldown message if 'Third Eye' is on cooldown
            displayCooldownMessage('Third Eye', thirdEye.recast)
        end
    else
        -- Preferred ability is either active or on cooldown
        -- Attempt to activate 'Third Eye' directly
        if not thirdEye.active and thirdEye.recast == 0 then
            send_command('input /ja "Third Eye" <me>')
        elseif thirdEye.recast > 0 then
            -- Display cooldown message if 'Third Eye' is on cooldown
            displayCooldownMessage('Third Eye', thirdEye.recast)
        end
    end
end

function jump()
    -- Ability names and IDs
    local jumpName = 'Jump'
    local highJumpName = 'High Jump'
    local jumpId = 158
    local highJumpId = 159

    -- Retrieve ability recast timers
    local JaRecasts = windower.ffxi.get_ability_recasts()
    local jumpRecast = JaRecasts[jumpId] or 0
    local highJumpRecast = JaRecasts[highJumpId] or 0

    -- Get the player's current TP
    local playerTP = player.tp

    -- Check if the player already has enough TP
    if playerTP >= 1000 then
        add_to_chat(057, 'You have enough TP!')
        return
    end

    -- Determine which jumps are available
    local jumpReady = jumpRecast == 0
    local highJumpReady = highJumpRecast == 0

    -- Decide which jumps to use based on TP and ability availability
    if jumpReady and highJumpReady then
        if playerTP < 500 then
            -- Use both Jump and High Jump to build TP quickly
            send_command('input /ja "' .. jumpName .. '" <t>; wait 1; input /ja "' .. highJumpName .. '" <t>')
        else
            -- Use only Jump to avoid overcapping TP
            send_command('input /ja "' .. jumpName .. '" <t>')
        end
    elseif jumpReady then
        -- Use Jump if it's ready
        send_command('input /ja "' .. jumpName .. '" <t>')
    elseif highJumpReady then
        -- Use High Jump if Jump is not ready
        send_command('input /ja "' .. highJumpName .. '" <t>')
    else
        -- Neither Jump nor High Jump are ready; display recast times
        local message1 = createFormattedMessage(nil, jumpName, jumpRecast, nil)
        add_to_chat(057, message1)
        local message2 = createFormattedMessage(nil, highJumpName, highJumpRecast, nil)
        add_to_chat(057, message2)
    end
end

function customize_idle_set(idleSet)
    -- Check if the player is in a city area and not in Dynamis
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        -- Use the town idle set when in cities
        idleSet = sets.idle.Town
    elseif state.HybridMode.value == 'PDT' then
        -- Use the physical damage taken (PDT) idle set when HybridMode is 'PDT'
        idleSet = sets.idle.PDT
    else
        -- Default to the standard idle set
        idleSet = sets.idle
    end
    return idleSet
end

function customize_melee_set(meleeSet)
    if state.HybridMode.value == 'PDT' then
        if player.equipment.main == 'Ukonvasara' and buffactive["Aftermath: Lv.3"] then
            -- Use the PDT set optimized for Ukonvasara with Aftermath Level 3
            meleeSet = sets.engaged.PDTAFM3
        else
            -- Use the standard PDT melee set
            meleeSet = sets.engaged.PDTTP
        end
    else
        -- Use the normal melee set
        meleeSet = sets.engaged.Normal
    end
    return meleeSet
end

-- =========================================================================================================
-- Table defining TP bonuses and always-equipped gear per weapon skill
-- =========================================================================================================
local ws_info = {
    ["Upheaval"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Chango provides +500 TP bonus when equipped
            return (player.equipment.main == 'Chango') and 500 or 0
        end,
    },
    ["Ukko's Fury"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Ukonvasara does not provide a TP bonus
            return 0
        end,
    },
    ["King's Justice"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Chango provides +500 TP bonus when equipped
            return (player.equipment.main == 'Chango') and 500 or 0
        end,
    },
    ["Armor Break"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Chango provides +500 TP bonus when equipped
            return (player.equipment.main == 'Chango') and 500 or 0
        end,
    },
    ["Fell Cleave"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Chango provides +500 TP bonus when equipped
            return (player.equipment.main == 'Chango') and 500 or 0
        end,
    },
    ["Impulse Drive"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Impulse Drive uses polearms; Chango does not apply
            return 0
        end,
    },
    ["Savage Blade"] = {
        tp_bonus_gear_always = 100, -- Boii Cuisses +3 always provide +100 TP
        tp_bonus_from_weapon = function()
            -- Savage Blade uses swords; Chango does not apply
            return 0
        end,
    },
    ["Judgment"] = {
        tp_bonus_gear_always = 0, -- No Boii Cuisses +3 for Judgment
        tp_bonus_from_weapon = function()
            -- Judgment uses clubs; Chango does not apply
            return 0
        end,
    },
    -- Add additional weapon skills as necessary
}

-- =========================================================================================================
-- Helper function to determine the TP threshold reached
-- =========================================================================================================
function get_tp_threshold(tp)
    if tp >= 3000 then
        return 3000
    elseif tp >= 2000 then
        return 2000
    else
        return 1000 -- Cannot WS below 1000 TP
    end
end

-- =========================================================================================================
-- Function to determine the custom mode for Weapon Skills
-- =========================================================================================================
function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode = nil

    if spell.type == 'WeaponSkill' then
        local current_tp = player.tp
        local tp_bonus_buffs = 0
        local tp_bonus_gear_always = 0
        local weapon_tp_bonus = 0

        -- Retrieve WS-specific information from the ws_info table
        local ws = ws_info[spell.english]
        if ws then
            tp_bonus_gear_always = ws.tp_bonus_gear_always or 0
            weapon_tp_bonus = ws.tp_bonus_from_weapon()
        else
            -- Default values if the WS is not in ws_info
            tp_bonus_gear_always = 0
            weapon_tp_bonus = (player.equipment.main == 'Chango') and 500 or 0
        end

        -- TP bonus from Warcry (+500 TP)
        if buffactive['Warcry'] then
            tp_bonus_buffs = tp_bonus_buffs + 500
        end

        -- Calculate total TP without optional TP bonus gear
        local total_tp_without_gear = current_tp + tp_bonus_buffs + weapon_tp_bonus + tp_bonus_gear_always

        -- Ensure sufficient TP for a WS
        if total_tp_without_gear < 1000 then
            return nil -- Not enough TP to perform a WS
        end

        -- Determine TP threshold reached without optional gear
        local tp_threshold_without_gear = get_tp_threshold(total_tp_without_gear)

        -- Define possible TP bonus gear sets (e.g., Moonshade Earring)
        local gear_sets = {
            { mode = 'TPBonus', tp_bonus_gear = 250 }, -- Moonshade Earring
            { mode = nil,       tp_bonus_gear = 0 },   -- Default gear
        }

        -- Check if optional gear improves the TP threshold
        for _, gear_option in ipairs(gear_sets) do
            local total_tp_with_gear = total_tp_without_gear + gear_option.tp_bonus_gear
            local tp_threshold_with_gear = get_tp_threshold(total_tp_with_gear)

            if tp_threshold_with_gear > tp_threshold_without_gear and tp_threshold_with_gear >= 2000 then
                -- Equip this gear if it helps reach a higher TP threshold (2000 or 3000)
                wsmode = gear_option.mode
                break
            end
        end
    end

    return wsmode
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

--------------------------------------------------------------------------------
-- removeRetaliationOnLongMovement()
-- Cancels Retaliation if the player moves (distance > 1) for 5 seconds
-- (adjustable) while not engaged in combat.
--------------------------------------------------------------------------------
function removeRetaliationOnLongMovement()
    local checkInterval = 0.5    -- How often (seconds) we check position
    local moveDurationNeeded = 5 -- Seconds of continuous movement needed
    local timeMoving = 0
    local lastPos = { x = 0, y = 0, z = 0 }

    windower.raw_register_event('prerender', function()
        -- We'll count frames to approximate time
        if not lastPos.frameCount then
            lastPos.frameCount = 0
        end
        lastPos.frameCount = lastPos.frameCount + 1

        -- Convert checkInterval to frames (assuming ~60 frames per second)
        local framesNeeded = math.floor(checkInterval * 60 + 0.5)

        -- Only run logic every checkInterval
        if lastPos.frameCount < framesNeeded then
            return
        end
        lastPos.frameCount = 0

        local pl = windower.ffxi.get_mob_by_index(player.index)
        if pl and pl.x and (lastPos.x ~= 0 or lastPos.y ~= 0 or lastPos.z ~= 0) then
            local dist = math.sqrt((pl.x - lastPos.x) ^ 2 + (pl.y - lastPos.y) ^ 2 + (pl.z - lastPos.z) ^ 2)

            -- If moving (dist > 1) & not engaged & 'Retaliation' is active
            if dist > 1 and player.status ~= 'Engaged' and buffactive['Retaliation'] then
                timeMoving = timeMoving + checkInterval
                -- Once time exceeds threshold, cancel Retaliation
                if timeMoving >= moveDurationNeeded then
                    send_command('cancel Retaliation')
                end
            else
                -- Reset the movement timer if not continuously moving
                timeMoving = 0
            end
        end

        -- Update stored position
        if pl and pl.x then
            lastPos.x = pl.x
            lastPos.y = pl.y
            lastPos.z = pl.z
        end
    end)
end
