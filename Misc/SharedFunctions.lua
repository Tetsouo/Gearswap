-- ============================================================--
-- =                    SHARED FUNCTIONS                      =--
-- ============================================================--
-- =                    Author: Tetsouo                       =--
-- =                     Version: 1.0                         =--
-- =                  Created: 2023/07/10                     =--
-- =               Last Modified: 2024/02/04                  =--
-- ============================================================--

-- ===========================================================================================================
--                                     Constants and Global Variables
-- ===========================================================================================================
-- Constants used throughout the script
GRAY = 160      -- Color code for the gray.
ORANGE = 057    -- Color code for the orange.
YELLOW = 050    -- Color code for the green.
RED = 028       -- Color code for the red.
WAIT_TIME = 1.2 -- Time to wait between actions, in seconds
-- Array of stratagem charge times.
strat_charge_time = { 240, 120, 80, 60, 48 }
-- Array of spell names to be ignored. Add more spell names here as needed.
local ignoredSpells = { 'Breakga', 'Aspir III', 'Aspir II' }
-- The name of the main player.
mainPlayerName = 'Tetsouo'
-- The name of the alternate player.
altPlayerName = 'Kaories'
-- Define an object to store the current state values
local altState = {}
isCast = false -- Flag to indicate if a spell is being cast

-- Set of incapacitating buffs. Each buff name is a key with a value of `true`.
local incapacitating_buffs_set = {
    silence = true,
    stun = true,
    petrification = true,
    terror = true,
    sleep = true,
    mute = true,
}
-- ===========================================================================================================
--                                    Equipment and Gear Set Functions
-- ===========================================================================================================
-- Creates an equipment item with the given name, priority, bag, and augments.
-- Parameters:
--   name (string): The name of the equipment item
--   priority (number, optional): The priority of the equipment item. Defaults to 0.
--   bag (number, optional): The bag where the equipment item is located. Defaults to 0.
--   augments (table, optional): The augments of the equipment item. Defaults to an empty table.
-- Returns:
--   A table representing the equipment item
function createEquipment(name, priority, bag, augments)
    return {
        name = name,
        priority = priority or 0,
        bag = bag or 0,
        augments = augments or {}
    }
end

-- ===========================================================================================================
--                              State Management and Basic Data Handling
-- ===========================================================================================================
-- Update the altState object whenever the state changes
function update_altState()
    altState.Light = state.altPlayerLight.value
    altState.Tier = state.altPlayerTier.value
    altState.Dark = state.altPlayerDark.value
    altState.Ra = state.altPlayera.value
    altState.Geo = state.altPlayerGeo.value
    altState.Indi = state.altPlayerIndi.value
    altState.Entrust = state.altPlayerEntrust.value
end

-- Retrieves the ID and name of the current target.
-- @return target.id, target.name The ID and name of the current target, or nil if no target is selected.
function get_current_target_id_and_name()
    local target = windower.ffxi.get_mob_by_target('lastst')
    if target then
        return target.id, target.name
    end
    return nil, nil
end

-- Checks if the player is incapacitated by any defined buffs.
-- If incapacitated, it cancels the spell, marks the event as handled, reverts to the previous gear set, and notifies the player.
-- @param spell (table): The spell currently being cast. It should be a table with `action_type` and `name` fields.
-- @param eventArgs (table): A table that can be used to pass additional event arguments. It should have a `handled` field.
-- @return (boolean): true if the player is incapacitated, false otherwise.
-- @return (string or nil): The type of incapacitation if the player is incapacitated, nil otherwise.
function incapacitated(spell, eventArgs)
    -- If the action type is 'Ability' or 'Item' and the player is silenced or muted, the player is not incapacitated.
    if (spell.action_type == 'Ability' or spell.action_type == 'Item') and (buffactive['silence'] or buffactive['mute']) then
        return false, nil
    end

    -- If the player has any active buffs, check each one to see if it's an incapacitating buff.
    if next(buffactive) then
        for buff in pairs(buffactive) do
            -- If the buff incapacitates, cancel the spell, handle the event, revert gear, and notify.
            if incapacitating_buffs_set[buff] then
                cancel_spell()
                eventArgs.handled = true
                add_to_chat(167, createFormattedMessage('Cannot Use:', spell.name, nil, buff, true, true))
                return true, buff
            end
        end
    end

    -- If no incapacitating buffs are found, the player is not incapacitated.
    return false, nil
end

-- Checks if a specific party member has a pet.
-- @param name (string) : The name of the party member to check.
-- @return (boolean) true if the party member is found and they have a pet, false otherwise.
function find_member_and_pet_in_party(name)
    for i, member in ipairs(party) do
        if member.mob and member.mob.name == name then
            return member.mob.pet_index ~= nil
        end
    end
    return false
end

-- Checks if a table contains a specific element.
-- @param tbl (table) : The table to search in.
-- @param element (any) : The element to search for in the table.
-- @return (boolean) true if the element is found in the table, false otherwise.
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

--- Determines if a given action inherently triggers the Treasure Hunter effect.
-- @param {number} category - The category of the action.
-- @param {number} param - The specific action within the category.
-- @return {boolean} - Returns true if the action inherently triggers Treasure Hunter, false otherwise.
function th_action_check(category, param)
    -- Define a mapping of action categories to functions that check if the specific action within the category triggers Treasure Hunter.
    local th_actions = {
        [2] = function() return true end,                                       -- Any ranged attack triggers Treasure Hunter.
        [4] = function() return true end,                                       -- Any magic action triggers Treasure Hunter.
        [3] = function(param) return param == 30 end,                           -- Aeolian Edge triggers Treasure Hunter.
        [6] = function(param) return info.default_ja_ids:contains(param) end,   -- Provoke, Animated Flourish trigger Treasure Hunter.
        [14] = function(param) return info.default_u_ja_ids:contains(param) end -- Quick/Box/Stutter Step, Desperate/Violent Flourish trigger Treasure Hunter.
    }

    -- If the action category exists in the mapping and the specific action triggers Treasure Hunter, return true.
    if th_actions[category] and th_actions[category](param) then
        return true
    end

    -- If the action category does not exist in the mapping or the specific action does not trigger Treasure Hunter, return false.
    return false
end

-- ===========================================================================================================
--                                      Message Formatting Functions
-- ===========================================================================================================
-- Formats a recast duration into a human-readable string representation.
-- @param recast (number) : The recast time value in seconds.
-- @return (string) The formatted recast time string.
local function formatRecastDuration(recast)
    if recast then
        if recast >= 60 then
            local minutes = math.floor(recast / 60)
            local seconds = math.floor(recast % 60)
            return string.format('%02d:%02d min', minutes, seconds)
        else
            return string.format('%.1f sec', recast)
        end
    end
end

-- Constructs a formatted message string with optional color and recast time.
-- @param startMessage (string): The initial part of the message.
-- @param spellName (string): The name of the spell to be included in the message.
-- @param recastTime (number): The recast time in seconds to be included in the message.
-- @param endMessage (string): The final part of the message.
-- @param isLastMessage (boolean): A flag indicating whether this is the last message.
-- @param isColored (boolean): A flag indicating whether the message should be colored.
-- @return (string) The formatted message string.
function createFormattedMessage(startMessage, spellName, recastTime, endMessage, isLastMessage, isColored)
    local colorGray = string.char(0x1F, GRAY)
    local colorOrange = string.char(0x1F, ORANGE)
    local colorRed = string.char(0x1F, RED)
    local colorGreen = string.char(0x1F, YELLOW)

    local messageParts = {}

    local function addMessage(message)
        table.insert(messageParts, message)
    end

    local startBracket =
        startMessage and string.format('%s %s[', startMessage, colorGray) or string.format('%s[', colorGray)
    addMessage(startBracket)

    addMessage(string.format('%s%s%s', colorGreen, spellName, colorGray))

    if recastTime then
        addMessage(
            string.format(
                '%s] Recast: %s(%s%s%s)',
                colorGray,
                colorGray,
                colorOrange,
                formatRecastDuration(recastTime),
                colorGray
            )
        )
    else
        addMessage(string.format('%s]', colorGray))

        if isColored and endMessage then
            local buffFirstLetterUpper = string.upper(string.sub(endMessage, 1, 1)) .. string.sub(endMessage, 2)
            addMessage(string.format(' Due to: %s[%s%s%s]', colorGray, colorRed, buffFirstLetterUpper, colorGray))
        elseif endMessage then
            addMessage(string.format(' %s', endMessage))
        end
    end

    if isLastMessage then
        addMessage(string.format('\n%s=================================================', colorGray))
    end

    return table.concat(messageParts)
end

-- ===========================================================================================================
--                                     Spell Casting Functions
-- ===========================================================================================================

-- Checks if a spell can be cast by verifying its recast time and any active spell-blocking buffs.
-- @param spell The spell to check. It should be a table with `id` and `action_type` fields.
-- @return true if the spell can be cast, false otherwise.
function can_cast_spell(spell, eventArgs)
    if spell == nil or spell.id == nil then
        return false
    end

    local is_incapacitated, incapacity_type = incapacitated(spell, eventArgs)
    if is_incapacitated then
        return false
    end

    local spellRecasts = windower.ffxi.get_spell_recasts()
    if spellRecasts ~= nil then
        local spellRecast = spellRecasts[spell.id]
        if spellRecast ~= nil and spellRecast > 0 then
            return false
        end
    end

    return true
end

-- Attempts to cast a spell if possible.
-- @param spell The spell to attempt to cast. It should be a table with `id`, `action_type` and `target` fields.
-- @return true if the spell can be cast, false otherwise.
function try_cast_spell(spell, eventArgs)
    if not can_cast_spell(spell, eventArgs) then
        cancel_spell()
        return false
    end
    return true
end

-- Handles the scenario when a spell cannot be cast.
-- If the spell cannot be cast, the function cancels the spell, marks the event as handled,
-- reverts to the previous gear set, and sends a chat message.
-- @param spell (table): The spell to attempt to cast. It should be a table with `id` and `action_type` fields.
-- @param eventArgs (table): A table that can be used to pass additional event arguments. It should have a `handled` field.
function handle_unable_to_cast(spell, eventArgs)
    if not try_cast_spell(spell, eventArgs) then
        cancel_spell()
        eventArgs.handled = true
        -- Revert to the previous gear set if the spell cannot be cast
        job_handle_equipping_gear(playerStatus, eventArgs)
        add_to_chat(167, createFormattedMessage('Cannot Use:', spell.name, nil, value, true, true))
    end
end

-- Checks the cooldown of a given spell or ability and displays it if it's not ready.
-- @param spell (table): The spell or ability to check.
-- @param eventArgs (table): Additional event arguments.
function checkDisplayCooldown(spell, eventArgs)
    -- Skip cooldown check for ignored spells or certain types of spells and abilities
    if
        table.contains(ignoredSpells, spell.name) or spell.skill == 'Elemental Magic' or spell.type == 'Scholar' or
        spell.action_type == 'Weapon Skill'
    then
        return
    end

    local recast = 0 -- Initialize recast time

    -- Get recast time from the appropriate list based on the action type
    if spell.action_type == 'Magic' then
        local spellRecasts = windower.ffxi.get_spell_recasts()
        recast = spellRecasts[spell.id] / 60 -- Convert recast time to seconds
    elseif spell.action_type == 'Ability' then
        local abilityRecasts = windower.ffxi.get_ability_recasts()
        recast = abilityRecasts[spell.recast_id]
    end

    -- If the spell or ability is not ready, cancel it and display the recast time
    if recast and recast > 0 then
        cancel_spell()
        eventArgs.handled = true
        add_to_chat(123, createFormattedMessage(nil, spell.name, recast, nil, true))
    end
end

-- If the spell was not cancelled and can be cast, it checks if there's an associated auto ability function and calls it.
-- If the spell is 'Cure III' or 'Cure IV', it generates and equips a cure set.
-- @param spell The spell object to attempt to cast. It should be a table with `name` and `target.type` fields.
-- @param eventArgs The event arguments object. It should have a `handled` field.
-- @param auto_abilities The table of auto abilities. It should map spell names to functions.
-- Initialisez auto_abilities comme une table avant d'appeler handle_spell
function handle_spell(spell, eventArgs, auto_abilities)
    if not eventArgs.handled and try_cast_spell(spell, eventArgs) then
        if auto_abilities ~= nil then
            local auto_ability_function = auto_abilities[spell.name]
            if auto_ability_function ~= nil then
                auto_ability_function(spell, eventArgs)
            end
        end
    end
end

-- This function is used to handle the automatic use of abilities for 'Protect V', 'Cure III', and 'Cure IV' spells.
-- It simply calls the 'handle_majesty_and_cure_sets' function with the provided spell and event arguments.
-- @param spell The spell to be cast. It should be one of 'Protect V', 'Cure III', or 'Cure IV'.
-- @param eventArgs The event arguments.
function handle_majesty_and_cure_sets_wrapper(spell, eventArgs)
    handle_majesty_and_cure_sets(spell, eventArgs)
end

-- Automatically casts an ability before a spell if possible.
-- If the spell can be cast and the ability is ready and not active, it cancels the current spell, uses the ability, waits for `WAIT_TIME` seconds, and then casts the spell.
-- If the spell cannot be cast, it cancels the spell and marks the event as handled.
-- @param spell The spell object to attempt to cast. It should be a table with `name` and `target.id` fields.
-- @param eventArgs The event arguments object. It should have a `handled` field.
-- @param abilityId The ID of the ability to use before the spell.
-- @param abilityName The name of the ability to use before the spell.
function auto_ability(spell, eventArgs, abilityId, abilityName)
    if try_cast_spell(spell, eventArgs) then
        local abilityCooldown = windower.ffxi.get_ability_recasts()[abilityId]
        if abilityCooldown < 1 and not buffactive[abilityName] then
            cancel_spell()
            send_command(
                string.format(
                    'input /ja "%s" <me>; wait %f; input /ma %s %s',
                    abilityName,
                    WAIT_TIME,
                    spell.name,
                    spell.target.id
                )
            )
        end
    else
        handle_unable_to_cast(spell, eventArgs)
    end
end

-- Handles the event of a spell being interrupted.
-- This function reverts to the previous gear set, marks the event as handled, and sends a chat message.
-- @param spell (table): The spell that was interrupted.
-- @param eventArgs (table): Additional event arguments. This is modified by the function to mark the event as handled.
function handleInterruptedSpell(spell, eventArgs)
    eventArgs.handled = true -- Mark the event as handled
    job_handle_equipping_gear(playerStatus, eventArgs)
    -- Notify the user via chat that the spell was interrupted
    add_to_chat(123, createFormattedMessage('Spell interrupted:', spell.name, nil, nil, true, nil))
end

-- Handles actions to be performed after a spell has been successfully cast.
-- @param spell (table): The spell that has been successfully cast.
-- @param eventArgs (table): Additional event arguments.
-- This function equips the MoveSpeed gear set if the Moving state is true.
function handleCompletedSpell(spell, eventArgs)
    if state.Moving.value == 'true' then
        send_command('gs equip sets.MoveSpeed')
    end
end

-- Handles actions to be performed after a spell has been cast.
-- @param spell (table): The spell that has been cast.
-- @param eventArgs (table): Additional event arguments.
-- This function checks if the spell was interrupted or completed and calls the appropriate handler function.
function handleSpellAftercast(spell, eventArgs)
    if spell.interrupted then
        -- If the spell was interrupted, handle the interruption.
        handleInterruptedSpell(spell, eventArgs)
    else
        -- If the spell was successfully cast, handle the completion.
        handleCompletedSpell(spell, eventArgs)
    end
end

-- Casts a sequence of spells on a target.
-- @param altPlayerName (string): The name of the alternate player casting the spell.
-- @param mainPlayerName (string): The name of the main player.
-- @param spells (table): A table of spells to cast. Each spell is a table with a 'name' and a 'delay'.
-- This function iterates over the spells table and sends a command to cast each spell on the current target.
-- If the spell is 'phalanx2', the main player is the target, and the main player's job is 'PLD',
-- both 'phalanx' and 'phalanx2' are cast.
function applySpellSequenceToTarget(altPlayerName, mainPlayerName, spells)
    local targetid, targetname = get_current_target_id_and_name()
    for _, spell in ipairs(spells) do
        local command
        if spell.delay == 0 then
            command = string.format('send %s %s %s', altPlayerName, spell.name, tostring(targetid))
        else
            command =
                string.format('wait %d; send %s %s %s', spell.delay, altPlayerName, spell.name, tostring(targetid))
        end
        if spell.name == 'phalanx2' and targetname == mainPlayerName and player.main_job == 'PLD' then
            local bothPhalanx
            if spell.delay == 0 then
                bothPhalanx =
                    string.format(
                        'send %s phalanx %s; send %s phalanx2 %s',
                        mainPlayerName,
                        tostring(targetid),
                        altPlayerName,
                        tostring(targetid)
                    )
            else
                bothPhalanx =
                    string.format(
                        'wait %d; send %s phalanx %s; send %s phalanx2 %s',
                        spell.delay,
                        mainPlayerName,
                        tostring(targetid),
                        altPlayerName,
                        tostring(targetid)
                    )
            end
            send_command(bothPhalanx)
        else
            send_command(command)
        end
    end
end

-- Handles the command sequence for a character.
-- @param altPlayerName (string): The name of the alternate player casting the spells.
-- @param mainPlayerName (string): The name of the main player.
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'bdd', 'buffrng', 'curaga', 'debuff').
-- This function defines a sequence of spells to be cast on the current target,
-- and calls the function 'applySpellSequenceToTarget' to apply them.
function bufferRoleForAltRdm(altPlayerName, mainPlayerName, commandType)
    local targetid, targetname = get_current_target_id_and_name()
    tank = {
        { name = 'haste2',   delay = 0 },
        { name = 'refresh3', delay = 4.5 },
        { name = 'phalanx2', delay = 9.2 },
        { name = 'regen2',   delay = 13.2 }
    }
    melee = {
        { name = 'haste2',   delay = 0 },
        { name = 'phalanx2', delay = 4.7 },
        { name = 'regen2',   delay = 8 }
    }
    ranger = {
        { name = 'flurry2',  delay = 0 },
        { name = 'phalanx2', delay = 4.5 },
        { name = 'regen2',   delay = 9.2 }
    }

    local spells = {}

    if commandType == 'bufftank' then
        spells = tank
    elseif commandType == 'buffmelee' then
        spells = melee
    elseif commandType == 'buffrng' then
        spells = ranger
    elseif commandType == 'curaga' then
        spells = {
            { name = 'curaga3', delay = 0 }
        }
    elseif commandType == 'debuff' then
        spells = {
            { name = 'distract3', delay = 0 },
            { name = 'dia3',      delay = 4 },
            { name = 'slow2',     delay = 8 },
            { name = 'Blind2',    delay = 12 },
            { name = 'paralyze2', delay = 16 }
        }
    end

    applySpellSequenceToTarget(altPlayerName, mainPlayerName, spells)
end

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

-- This function handles the buffing sequence for an alternate Geomancer character in the game.
--
-- @param altSpell (string): The name of the spell to cast.
-- @param altPlayerName (string): The name of the alternate player casting the spell.
-- @param mainPlayerName (string): The name of the main player.
-- @param isEntrust (boolean): If true, the "Entrust" ability will be used before casting the spell.
-- @param isGeo (boolean): If true, the "Full Circle" ability will be used before casting the Geo spell.
--
-- The function first retrieves the current target's ID and name. It then checks the name of the spell to cast.
-- If the spell is a Geo spell that should be cast on the main player, it changes the target to the main player.
-- If the 'isEntrust' parameter is true, it sends a command to use the "Entrust" ability before casting the spell.
-- If the 'isGeo' parameter is true, it sends a command to use the "Full Circle" ability before casting the Geo spell.
-- Finally, it sends the command to cast the spell on the appropriate target.
function bubbleBuffForAltGeo(altSpell, altPlayerName, mainPlayerName, isEntrust, isGeo)
    local targetid, targetname = get_current_target_id_and_name()
    local spellToCast = altSpell
    local targetForGeo = targetid

    -- Si le sort est dans la liste mainPlayerSpells, changez la cible pour mainPlayerName
    if table.contains(mainPlayerSpells, altSpell) then
        targetForGeo = '<' .. mainPlayerName .. '>'
    end

    local command = 'send ' .. altPlayerName

    if isEntrust then
        if targetname ~= altPlayerName then
            command = command .. ' /ja "Entrust" <' .. altPlayerName .. '>'
        end
        command = command .. '; wait 2; send ' .. altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid
    elseif isGeo then
        if find_member_and_pet_in_party(altPlayerName) then
            command = command .. ' /ja "Full Circle" <' .. altPlayerName .. '>'
            command = command ..
                '; wait 2; send ' ..
                altPlayerName ..
                ' ' ..
                spellToCast ..
                ' ' .. targetForGeo .. '; wait 4; send ' .. altPlayerName .. ' Cure <' .. mainPlayerName .. '>'
        else
            command = command ..
                ' ' ..
                spellToCast ..
                ' ' .. targetForGeo .. '; wait 4; send ' .. altPlayerName .. ' Cure <' .. mainPlayerName .. '>'
        end
    else
        command = command .. ' ' .. spellToCast .. ' ' .. '<' .. altPlayerName .. '>'
    end

    send_command(command)
end

-- Handles the 'alt' command for an alternate character.
-- @param altSpell (string): The name of the elemental damage spell to cast.
-- @param altTier (string): The level of the spell to cast.
-- @param altPlayerName (string): The name of the alternate player casting the spell.
-- @param mainPlayerName (string): The name of the main player.
-- @param isRaSpell (boolean): If true, the spell is of type 'Ra'.
-- This function defines the spell to be cast, gets the current target,
-- and sends the appropriate command to the alternate player.
function handle_altNuke(altSpell, altTier, altPlayerName, mainPlayerName, isRaSpell)
    local spellToCast = altSpell .. (isRaSpell and ' III' or altTier)
    local targetid, targetname = get_current_target_id_and_name()

    if player.status == 'Engaged' then
        send_command(
            'send ' ..
            altPlayerName ..
            ' /assist <' ..
            mainPlayerName .. '>; wait 1; send ' .. altPlayerName .. ' ' .. spellToCast .. ' <t>'
        )
    else
        local targetid = windower.ffxi.get_mob_by_target('lastst').id
        send_command('send ' .. altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid)
    end
end

-- Casts a specified spell on the selected Non-Player Character (NPC) target.
-- @param mainSpell (string): The name of the main spell to cast (e.g., "Fire", "Blizzard").
-- @param tier (string): The tier of the spell to cast. If not provided, the function will cast the main spell without a tier.
function castElementalSpells(mainSpell, tier)
    local spell = mainSpell
    if tier then
        spell = spell .. tier
    end
    send_command('input /ma "' .. spell .. '" <stnpc>')
end

-- Casts a specified art or addendum.
-- @param arts (string): The name of the art to cast (e.g., "Light Arts").
-- @param addendum (string): The name of the addendum to cast (e.g., "Addendum: White").
-- This function checks if the specified art is active. If not, it casts the art. If the art is already active, it casts the addendum instead.
function castArtsOrAddendum(arts, addendum)
    if not buffactive[arts] then
        send_command('input /ja "' .. arts .. '" <me>')
    else
        send_command('input /ja "' .. addendum .. '" <me>')
    end
end

-- Casts a Scholar spell with the appropriate arts and addendum.
-- @param spell (string): The name of the spell to cast.
-- @param arts (string): The name of the art to use (e.g., "Light Arts" or "Dark Arts").
-- @param addendum (string): The name of the addendum to use (e.g., "Addendum: White" or "Addendum: Black").
-- This function checks if the appropriate addendum is active. If not, it casts the art and addendum before casting the spell.
-- If the addendum is active, it casts the spell directly.
-- If the art is active but not the addendum, and a stratagem is available, it casts the addendum and then the spell.
-- If a stratagem is available, it casts the art, then the addendum, then the spell.
function castSchSpell(spell, arts, addendum)
    local delay = (spell == 'Sneak' or spell == 'Invisible') and 1 or 2.1
    local targetid, targetname = get_current_target_id_and_name()

    if buffactive[addendum] then
        send_command('input /ma "' .. spell .. '" ' .. targetid)
    elseif buffactive[arts] and not buffactive[addendum] and stratagems_available() then
        send_command('input /ja "' .. addendum .. '" <me>; wait 2; input /ma "' .. spell .. '" ' .. targetid)
    elseif stratagems_available() then
        send_command(
            'input /ja "' ..
            arts ..
            '" <me>; wait 2; input /ja "' ..
            addendum .. '" <me>; wait ' .. delay .. '; input /ma "' .. spell .. '" ' .. targetid
        )
    end
end

-- This function handles the commands specific to the Black Mage (BLM) job.
-- @param cmdParams: A table where the first element is the command to be executed.
function handle_blm_commands(cmdParams)
    -- Define a table where each key is a command and the value is the function to execute for that command.
    local spells = {
        -- Casts a self buff.
        buffself = function()
            BuffSelf()
        end,
        -- Casts the main light spell.
        mainlight = function()
            castElementalSpells(state.MainLightSpell.value, state.TierSpell.value)
        end,
        -- Casts the sub light spell.
        sublight = function()
            castElementalSpells(state.SubLightSpell.value, state.TierSpell.value)
        end,
        -- Casts the main dark spell.
        maindark = function()
            castElementalSpells(state.MainDarkSpell.value, state.TierSpell.value)
        end,
        -- Casts the sub dark spell.
        subdark = function()
            castElementalSpells(state.SubDarkSpell.value, state.TierSpell.value)
        end,
        -- Casts the Aja spell.
        aja = function()
            castElementalSpells(state.Aja.value)
        end
    }

    -- Convert the command to lower case to ensure case-insensitive matching.
    local cmd = cmdParams[1]:lower()

    -- If the command exists in the spells table, execute the corresponding function.
    if spells[cmd] then
        spells[cmd]()
    end
end

-- This function handles the commands specific to the Scholar (SCH) subjob.
-- @param cmdParams: A table where the first element is the command to be executed.
function handle_sch_subjob_commands(cmdParams)
    -- Convert the command to lower case to ensure case-insensitive matching.
    local cmd = cmdParams[1]:lower()

    -- Function to cast a storm spell. If the 'Klimaform' buff is not active and the spell is ready to cast,
    -- it first casts 'Klimaform', waits for 4 seconds, and then casts the storm spell.
    function castStormSpell(spell)
        if not buffactive['Klimaform'] and windower.ffxi.get_spell_recasts()[287] < 1 then
            send_command('input /ma "Klimaform" ; wait 4; input /ma "' .. spell .. '" ')
        else
            send_command('input /ma "' .. spell .. '" ')
        end
    end

    -- Define a table where each key is a command and the value is the function to execute for that command.
    local schSpells = {
        -- Casts a storm spell.
        storm = function()
            castStormSpell(state.Storm.value)
        end,
        -- Casts 'Light Arts' or 'Addendum: White' depending on which is available.
        lightarts = function()
            castArtsOrAddendum('Light Arts', 'Addendum: White')
        end,
        -- Casts 'Dark Arts' or 'Addendum: Black' depending on which is available.
        darkarts = function()
            castArtsOrAddendum('Dark Arts', 'Addendum: Black')
        end,
        -- The following commands cast specific spells with 'Light Arts' or 'Addendum: White'.
        blindna = function()
            castSchSpell('Blindna', 'Light Arts', 'Addendum: White')
        end,
        poisona = function()
            castSchSpell('Poisona', 'Light Arts', 'Addendum: White')
        end,
        viruna = function()
            castSchSpell('Viruna', 'Light Arts', 'Addendum: White')
        end,
        stona = function()
            castSchSpell('Stona', 'Light Arts', 'Addendum: White')
        end,
        silena = function()
            castSchSpell('Silena', 'Light Arts', 'Addendum: White')
        end,
        paralyna = function()
            castSchSpell('Paralyna', 'Light Arts', 'Addendum: White')
        end,
        cursna = function()
            castSchSpell('Cursna', 'Light Arts', 'Addendum: White')
        end,
        erase = function()
            castSchSpell('Erase', 'Light Arts', 'Addendum: White')
        end,
        -- Casts 'Dispel' with 'Dark Arts' or 'Addendum: Black'.
        dispel = function()
            castSchSpell('Dispel', 'Dark Arts', 'Addendum: Black')
        end,
        -- The following commands cast specific spells with 'Light Arts' or 'Accession'.
        sneak = function()
            castSchSpell('Sneak', 'Light Arts', 'Accession')
        end,
        invi = function()
            castSchSpell('Invisible', 'Light Arts', 'Accession')
        end
    }

    -- If the command exists in the schSpells table, execute the corresponding function.
    if schSpells[cmd] then
        schSpells[cmd]()
    end
end

-- This function handles the commands specific to the Warrior (WAR) job.
-- @param cmdParams: A table where the first element is the command to be executed.
function handle_war_commands(cmdParams)
    -- Convert the command to lower case to ensure case-insensitive matching.
    local cmd = cmdParams[1]:lower()
    -- Define a table where each key is a command and the value is the function to execute for that command.
    local warCommands = {
        -- If 'Defender' is active, cancel it and activate 'Berserk'.
        berserk = function()
            if buffactive['Defender'] then
                send_command('cancel defender')
            end
            buffSelf('Berserk')
        end,
        -- If 'Berserk' is active, cancel it and activate 'Defender'.
        -- Also, if the hybrid mode is 'Normal', set it to 'PDT'.
        defender = function()
            if state.HybridMode.value == 'Normal' then
                send_command('gs c set HybridMode PDT')
            end
            if buffactive['Berserk'] then
                send_command('cancel berserk')
            end
            buffSelf('Defender')
        end,
        -- Execute the 'ThirdEye' function.
        thirdeye = ThirdEye,
        -- Execute the 'jump' function.
        jump = jump
    }

    -- If the command exists in the warCommands table, execute the corresponding function.
    if warCommands[cmd] then
        warCommands[cmd]()
    end
end

-- Handles Thief-specific commands.
-- @param cmdParams: A table where the first element is the command to execute.
function handle_thf_commands(cmdParams)
    -- Convert the command to lower case for case-insensitive comparison.
    local cmd = cmdParams[1]:lower()

    -- Define a table mapping commands to their corresponding functions.
    local thfCommands = {
        -- 'thfbuff' command applies the Thief-specific buff.
        thfbuff = function()
            buffSelf('thfBuff')
        end
    }

    -- If the command exists in the thfCommands table, execute the corresponding function.
    if thfCommands[cmd] then
        thfCommands[cmd]()
    end
end

--- Adjusts the earring equipment based on the player's TP and the spell being cast.
-- @param spell The spell that the player is casting.
function adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
    -- Check if the spell type is a WeaponSkill
    if spell.type == 'WeaponSkill' then
        -- Check if 'Centovente' is equipped as a sub weapon
        if player.equipment.sub == 'Centovente' then
            -- Check if player's TP is between 1750 and 2000
            if player.tp >= 1750 and player.tp < 2000 then
                sets.precast.WS[spell.name].left_ear = 'MoonShade Earring'
            else
                -- Adjust earring based on the spell name and Treasure Hunter status
                sets.precast.WS[spell.name].left_ear =
                    (spell.name == 'Exenterator') and 'Dawn Earring' or
                    ((spell.name == 'Aeolian Edge' and treasureHunter ~= 'None') and 'Sortiarius Earring' or
                        (spell.name == 'Aeolian Edge' and 'Sortiarius Earring' or 'Sherida Earring'))
            end
        else
            -- If 'Centovente' is not equipped
            -- Check if player's TP is between 1750 and 2000 or between 2750 and 3000
            if (player.tp >= 1750 and player.tp < 2000) or (player.tp >= 2750 and player.tp < 3000) then
                sets.precast.WS[spell.name].left_ear = 'MoonShade Earring'
            else
                -- Adjust earring based on the spell name and Treasure Hunter status
                sets.precast.WS[spell.name].left_ear =
                    (spell.name == 'Exenterator') and 'Dawn Earring' or
                    ((spell.name == 'Aeolian Edge' and treasureHunter ~= 'None') and 'Sortiarius Earring' or
                        (spell.name == 'Aeolian Edge' and 'Sortiarius Earring' or 'Sherida Earring'))
            end
        end
    end
end

--- Refines the casting of Utsusemi spells based on their cooldown status.
-- @param spell The spell that the player is casting.
-- @param eventArgs Event arguments that can be modified to change the behavior of the casting.
function refine_Utsusemi(spell, eventArgs)
    -- Get the current cooldown status of all spells
    local spell_recasts = windower.ffxi.get_spell_recasts()

    -- Get the cooldown status of Utsusemi: Ni and Utsusemi: Ichi
    local NiCD = spell_recasts[339]
    local IchiCD = spell_recasts[338]

    -- If the player is casting Utsusemi: Ni
    if spell.name == 'Utsusemi: Ni' then
        -- If Utsusemi: Ni is on cooldown
        if NiCD > 1 then
            -- Cancel the casting of Utsusemi: Ni
            eventArgs.cancel = true

            -- If Utsusemi: Ichi is not on cooldown
            if IchiCD < 1 then
                -- Cancel the current spell, wait for 1.1 seconds, then cast Utsusemi: Ichi
                cancel_spell()
                cast_delay(1.1)
                send_command('input /ma "Utsusemi: Ichi" <me>')
            else
                -- If both Utsusemi: Ni and Utsusemi: Ichi are on cooldown, display a message
                add_to_chat(123, "Neither spell is ready!")
            end
        end
    end
end

-- ===========================================================================================================
--                                     Equipment Management Functions
-- ===========================================================================================================
--- Checks and equips the appropriate weapon set based on the player's job and state.
-- This function is specifically designed for the 'THF' and 'BLM' jobs, but also handles other jobs.
-- For 'THF', it checks the 'AbysseaProc' state and equips the corresponding weapon set.
-- For 'BLM', it does not equip any main weapon set.
-- For other jobs, it equips the main or sub weapon set based on the 'weaponType' parameter.
-- @param weaponType A string indicating the type of weapon to check ('main' or 'sub').
function check_weaponset(weaponType)
    if player.main_job == 'THF' then
        if state.AbysseaProc ~= nil then
            if state.AbysseaProc.value then
                equip(sets[state.WeaponSet2.current])
            else
                equip(sets[state.WeaponSet1.current])
            end
        else
            equip(sets[state.WeaponSet.current])
        end
        if state.SubSet then
            equip(sets[state.SubSet.current])
        end
    elseif weaponType == 'main' and player.main_job ~= 'BLM' then
        equip(sets[state.WeaponSet.current])
    elseif weaponType == 'sub' and state.SubSet then
        equip(sets[state.SubSet.current])
    end
end

-- Function to check if a ranged weapon is equipped and disable/enable the corresponding slots.
-- This is specific to THF job.
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo') -- Disable the range and ammo slots if a ranged weapon is equipped.
    else
        enable('range', 'ammo')  -- Enable the range and ammo slots if no ranged weapon is equipped.
    end
end

--- Resets the player's equipment to the default set based on their current state.
-- This function determines the base equipment set based on whether the player is engaged or idle.
-- If the player's HybridMode state is set, it equips the corresponding Physical Damage Taken (PDT) or Magical Damage Taken (MDT) set.
-- If the HybridMode state is not set or does not match 'PDT' or 'MDT', it equips the base set.
-- If the Xp state is set, it equips the XP set.
function reset_to_default_equipment()
    -- Determine the base equipment set based on the player's status
    local baseSet = player.status == 'Engaged' and sets.engaged or sets.idle

    -- Check the HybridMode state
    if state.HybridMode then
        if state.HybridMode.value == 'PDT' and state.Xp and state.Xp.value == 'False' then
            equip(baseSet.PDT)
        elseif state.HybridMode.value == 'PDT' and state.Xp and state.Xp.value == 'True' then
            equip(baseSet.PDT_XP)
        elseif state.HybridMode.value == 'MDT' then
            equip(baseSet.MDT)
        else
            equip(baseSet)
        end
    else
        equip(baseSet)
    end
end

-- Function to handle gear setup upon status change (buff gain or loss).
-- @param playerStatus (string) : The current status of the player.
-- @param eventArgs (table) : Additional event arguments.
function job_handle_equipping_gear(playerStatus, eventArgs)
    if state.Xp and state.Xp.value == 'True' then
        reset_to_default_equipment() -- Reset to default equipment
    else
        -- Check and handle main weapon gear set changes.
        check_weaponset('main')
        -- Check and handle sub weapon gear set changes.
        check_weaponset('sub')
        reset_to_default_equipment() -- Reset to default equipment
        -- Only proceed if the player's main job is THF.
        if player.main_job == 'THF' then
            -- Check if a ranged weapon is equipped and handle gear setup accordingly.
            check_range_lock()
        end
    end
end

-- Handles necessary actions when the job state changes.
-- @param field (string): The field that has changed in the job state.
-- @param new_value (any): The new value of the changed field.
-- @param old_value (any): The old value of the changed field.
-- This function is typically called when a job state change event occurs to ensure the correct gear sets are used.
function job_state_change(field, new_value, old_value)
    -- Handles equipping gear based on the player's state.
    -- This ensures that the correct gear set is used based on the current state of the player.

    -- Checks and adjusts the main weapon set.
    -- This ensures that the correct main weapon gear set is used based on the current main weapon.
    check_weaponset('main')

    -- Checks and adjusts the sub weapon set.
    -- This ensures that the correct sub weapon gear set is used based on the current sub weapon.
    check_weaponset('sub')
end

-- This function handles changes in buffs for the player.
-- @param buff: The name of the buff that has changed.
-- @param gain: A boolean indicating whether the buff was gained (true) or lost (false).
function buff_change(buff, gain)
    -- Initialize an empty set for equipment
    local equip_set = {}

    -- Handle 'Doom' buff changes
    if buff == 'doom' then
        if gain then
            -- If 'Doom' buff is gained, equip the 'Doom' set and disable the 'neck' slot
            equip_set = sets.buff.Doom
            disable('neck')
            -- Send a warning message and a party message
            add_to_chat(123, createFormattedMessage('WARNING:', 'Doom', nil, 'is active!', true, nil))
            send_command('input /p [DOOM] <call21>')
        else
            -- If 'Doom' buff is lost, enable the 'neck' slot and update the gear set
            enable('neck')
            send_command('gs c update')
            -- Send a message indicating that 'Doom' is no longer active and a party message
            add_to_chat(123, createFormattedMessage(nil, 'Doom', nil, 'is no longer active!', true, nil))
            send_command('input /p [Doom] Off !')
        end
        -- If the player is moving, combine the 'MoveSpeed' set with the current equipment set
        if state.Moving.value == 'true' then
            equip_set = set_combine(equip_set, sets.MoveSpeed)
        end
    end

    -- Handle buff changes for 'THF' or 'BLM' main jobs
    if player.main_job == 'THF' or player.main_job == 'BLM' then
        if state.Buff[buff] ~= nil then
            -- If the buff is recognized, update its state and re-equip gear
            state.Buff[buff] = gain
            handle_equipping_gear(player.status)
        end
        -- If the player is a 'BLM' and the 'Manawall' buff has changed, handle it
        if player.main_job == 'BLM' and buff == 'Manawall' then
            if gain then
                -- If 'Manawall' is gained, equip the 'Mana Wall' set and disable the 'back' and 'feet' slots
                equip_set = sets.precast.JA['Mana Wall']
                disable(back, feet)
            else
                -- If 'Manawall' is lost, enable the 'back' and 'feet' slots
                enable(back, feet)
            end
        end
    end

    -- Check if the buff is active and equip the corresponding gear
    if state.Buff[buff] then
        equip_set = set_combine(equip_set, sets.buff[buff] or {})
        -- If the 'TreasureMode' is 'SATA' or 'Fulltime', combine the 'TreasureHunter' set with the current equipment set
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip_set = set_combine(equip_set, sets.TreasureHunter)
        end
    end

    -- Handle 'Sneak Attack' and 'Trick Attack' buffs
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        if gain then
            -- If both 'Sneak Attack' and 'Trick Attack' are active, equip the combined set
            if state.Buff['Sneak Attack'] and state.Buff['Trick Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])
            else
                -- Otherwise, equip the set for the active buff
                equip_set = set_combine(equip_set, sets.buff[buff])
            end
        else
            -- If one buff is lost but the other is still active, equip the set for the active buff
            if state.Buff['Sneak Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Sneak Attack'])
            elseif state.Buff['Trick Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Trick Attack'])
            else
                -- If both buffs are lost, revert to the previous gear set
                job_handle_equipping_gear(playerStatus, eventArgs)
            end
        end
    end
    -- Equip the final gear set
    job_handle_equipping_gear(playerStatus, eventArgs)
end

-- Customizes a set based on given conditions.
-- It checks each condition in the `conditions` table. If a condition is true, it returns the corresponding set from the `setTable`.
-- If no conditions are met, it returns the default `set`.
-- @param set The default set.
-- @param conditions A table mapping from conditions to boolean values.
-- @param setTable A table mapping from conditions to sets.
-- @return The customized set.
function customize_set(set, conditions, setTable)
    for condition, value in pairs(conditions) do
        if value then
            return setTable[condition]
        end
    end
    return set
end

-- Generates the conditions and set tables for customization based on the current state.
-- The conditions are based on the `HybridMode` and `Xp` values of the state.
-- The set table maps the conditions to the corresponding sets.
-- @param setPDT_XP The set to use when the `HybridMode` is 'PDT' and `Xp` is 'True'.
-- @param setPDT The set to use when the `HybridMode` is 'PDT' and `Xp` is 'False'.
-- @param setMDT The set to use when the `HybridMode` is 'MDT'.
-- @return The conditions and the set table.
function get_conditions_and_sets(setPDT_XP, setPDT, setMDT)
    local xpValue = state.Xp and state.Xp.value or 'False'

    local conditions = {
        ['PDT_XP'] = state.HybridMode.value == 'PDT' and xpValue == 'True',
        ['PDT'] = state.HybridMode.value == 'PDT' and xpValue == 'False',
        ['MDT'] = state.HybridMode.value == 'MDT'
    }

    local setTable = {
        ['PDT_XP'] = setPDT_XP,
        ['PDT'] = setPDT,
        ['MDT'] = setMDT
    }

    return conditions, setTable
end

-- Customizes a set based on the current state.
-- It generates the conditions and set tables using `get_conditions_and_sets` and then customizes the set using `customize_set`.
-- @param set The set to be customized.
-- @param setXp The set to be used when Xp is true.
-- @param setPDT The set to be used when PDT is true.
-- @param setMDT The set to be used when MDT is true.
-- @return The customized set.
function customize_set_based_on_state(set, setXp, setPDT, setMDT)
    local conditions, setTable = get_conditions_and_sets(setXp, setPDT, setMDT)
    return customize_set(set, conditions, setTable)
end

-- ===========================================================================================================
--                                    Stratagem Management Functions
-- ===========================================================================================================
-- Returns the maximum number of Scholar (SCH) stratagems available based on the player's job level.
-- Stratagems are available when 'SCH' is either the player's main or sub job.
-- @return number: The maximum number of SCH stratagems available, or 0 if 'SCH' is neither the main nor sub job.
function get_max_stratagem_count()
    if S { player.main_job, player.sub_job }:contains('SCH') then
        local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
        return math.floor(((lvl - 10) / 20) + 1)
    end
    return 0
end

-- Calculates the number of Scholar (SCH) stratagems currently available for use.
-- @return number: The number of SCH stratagems currently available for use.
function get_available_stratagem_count()
    -- Get the recast time of the Stratagem ability (ID 231)
    local recastTime = windower.ffxi.get_ability_recasts()[231] or 0
    -- Get the maximum number of stratagems available
    local maxStrats = get_max_stratagem_count()
    -- If no stratagems are available, return 0
    if maxStrats == 0 then
        return 0
    end
    -- Calculate the number of stratagems used
    local stratsUsed = (recastTime / strat_charge_time[maxStrats]):ceil()
    -- Return the number of stratagems available
    return maxStrats - stratsUsed
end

-- Checks if there are any Scholar (SCH) stratagems available for use.
-- @return boolean: True if there are stratagems available, false otherwise.
function stratagems_available()
    return get_available_stratagem_count() > 0
end

-- Define a set of commands and their corresponding handlers
commandFunctions = {
    bufftank = function()
        bufferRoleForAltRdm(altPlayerName, mainPlayerName, 'bufftank')
    end,
    buffmelee = function()
        bufferRoleForAltRdm(altPlayerName, mainPlayerName, 'buffmelee')
    end,
    buffrng = function()
        bufferRoleForAltRdm(altPlayerName, mainPlayerName, 'buffrng')
    end,
    curaga = function()
        bufferRoleForAltRdm(altPlayerName, mainPlayerName, 'curaga')
    end,
    debuff = function()
        bufferRoleForAltRdm(altPlayerName, mainPlayerName, 'debuff')
    end,
    altlight = function()
        handle_altNuke(altState.Light, altState.Tier, altPlayerName, mainPlayerName, false) -- for 'altLight'
    end,
    altdark = function()
        handle_altNuke(altState.Dark, altState.Tier, altPlayerName, mainPlayerName, false) -- for 'altDark'
    end,
    altra = function()
        handle_altNuke(altState.Ra, nil, altPlayerName, mainPlayerName, true) -- for 'altRa'
    end,
    altindi = function()
        bubbleBuffForAltGeo(altState.Indi, altPlayerName, false, false) -- for 'altIndi'
    end,
    altentrust = function()
        bubbleBuffForAltGeo(altState.Entrust, altPlayerName, mainPlayerName, true, false) -- for 'altEntrust'
    end,
    altgeo = function()
        bubbleBuffForAltGeo(altState.Geo, altPlayerName, mainPlayerName, false, true) -- for 'altGeo'
    end,
}
