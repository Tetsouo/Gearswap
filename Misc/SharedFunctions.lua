-- ============================================================
-- =                    SHARED FUNCTIONS                      =
-- ============================================================
-- =                    Author: Tetsouo                       =
-- =                     Version: 1.0                         =
-- =                  Created: 2023/07/10                     =
-- =               Last Modified: 2024/02/04                  =
-- ============================================================

-- ===========================================================================================================
--                                     Constants and Global Variables
-- ===========================================================================================================
local SharedFunctions = {}

-- Constants used throughout the script
SharedFunctions.GRAY = 160      -- Color code for gray
SharedFunctions.ORANGE = 057    -- Color code for orange
SharedFunctions.YELLOW = 050    -- Color code for yellow
SharedFunctions.RED = 028       -- Color code for red
SharedFunctions.WAIT_TIME = 1.2 -- Time to wait between actions, in seconds

-- Array of stratagem charge times
SharedFunctions.strat_charge_time = { 240, 120, 80, 60, 48 }

-- Array of spell names to be ignored
SharedFunctions.ignoredSpells = { 'Breakga', 'Aspir III', 'Aspir II' }

-- The name of the main player
SharedFunctions.mainPlayerName = 'Tetsouo'

-- The name of the alternate player
SharedFunctions.altPlayerName = 'Kaories'

-- Define an object to store the current state values
SharedFunctions.altState = {}

-- Set of incapacitating buffs
SharedFunctions.incapacitating_buffs_set = {
    silence = true,
    stun = true,
    petrification = true,
    terror = true,
    sleep = true,
    mute = true,
}

-- ===========================================================================================================
--                                         1. Message Formatting Functions
-- ===========================================================================================================

--- Formats a recast duration into a human-readable string.
-- @param recast (number or nil): The recast time value in seconds.
-- @return (string or nil): The formatted recast time string, or nil if the recast time is nil.
function formatRecastDuration(recast)
    if recast ~= nil and type(recast) ~= 'number' then
        error("recast must be a number or nil")
    end

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

--- Asserts that a value is of the expected type or nil.
-- @param value The value to check.
-- @param expectedType The expected type of the value.
-- @param name The name of the value (for error messages).
function assertType(value, expectedType, name)
    assert(value == nil or type(value) == expectedType,
        string.format("%s must be a %s or nil, got %s", name, expectedType, type(value)))
end

--- Creates a color code from a color value.
-- @param color The color value.
-- @return The color code.
function createColorCode(color)
    assert(color ~= nil, "color must not be nil")
    assertType(color, "number", "color")
    return string.char(0x1F, color)
end

--- Adds a formatted message to a table of message parts.
-- @param messageParts The table of message parts.
-- @param format The format string for the message.
-- @param ... The values to insert into the format string.
function addFormattedMessage(messageParts, format, ...)
    assert(messageParts ~= nil, "messageParts must not be nil")
    assert(format ~= nil, "format must not be nil")
    assertType(messageParts, "table", "messageParts")
    assertType(format, "string", "format")
    return table.insert(messageParts, string.format(format, ...))
end

--- Creates a formatted message from the given parameters.
-- @param startMessage (string): The message to display at the start.
-- @param spellName (string): The name of the spell to display.
-- @param recastTime (number, optional): The recast time of the spell.
-- @param endMessage (string, optional): The message to display at the end.
-- @param isLastMessage (boolean): If true, a separator line will be added at the end of the message.
-- @param isColored (boolean): If true, the message will be colored.
-- @return (string): The formatted message.
function createFormattedMessage(startMessage, spellName, recastTime, endMessage, isLastMessage, isColored)
    assertType(startMessage, "string", "startMessage")
    assert(startMessage ~= "", "startMessage cannot be an empty string")
    assertType(spellName, "string", "spellName")
    assert(spellName ~= "", "spellName cannot be an empty string")
    if recastTime ~= nil then
        assertType(recastTime, "number", "recastTime")
        assert(recastTime >= 0, "recastTime cannot be negative")
    end
    if endMessage ~= nil then
        assertType(endMessage, "string", "endMessage")
        assert(endMessage ~= "", "endMessage cannot be an empty string")
    end
    assertType(isLastMessage, "boolean", "isLastMessage")
    assertType(isColored, "boolean", "isColored")

    assert(type(formatRecastDuration) == "function", "formatRecastDuration must be a function")
    local formattedRecastTime = formatRecastDuration(recastTime)
    assertType(formattedRecastTime, "string", "formattedRecastTime")

    assert(SharedFunctions.GRAY and SharedFunctions.ORANGE and SharedFunctions.RED and SharedFunctions.YELLOW,
        "Color values must be defined in SharedFunctions")
    for _, color in ipairs({ SharedFunctions.GRAY, SharedFunctions.ORANGE, SharedFunctions.RED, SharedFunctions.YELLOW }) do
        assertType(color, "number", "color")
        assert(color >= 0 and color <= 255, "color must be between 0 and 255")
    end

    local colorGray = createColorCode(SharedFunctions.GRAY)
    local colorOrange = createColorCode(SharedFunctions.ORANGE)
    local colorRed = createColorCode(SharedFunctions.RED)
    local colorGreen = createColorCode(SharedFunctions.YELLOW)

    local messageParts = {}

    addFormattedMessage(messageParts, '%s%s[', startMessage and startMessage .. ' ' or '', colorGray)
    addFormattedMessage(messageParts, '%s%s%s', colorGreen, spellName, colorGray)

    if recastTime then
        addFormattedMessage(messageParts, '%s] Recast: %s(%s%s%s)', colorGray, colorGray, colorOrange,
            formattedRecastTime, colorGray)
    else
        addFormattedMessage(messageParts, '%s]', colorGray)

        if endMessage then
            local endMessageFormatted = isColored and
                string.format(' Due to: %s[%s%s%s]', colorGray, colorRed,
                    string.upper(string.sub(endMessage, 1, 1)) .. string.sub(endMessage, 2), colorGray) or
                string.format(' %s', endMessage)
            addFormattedMessage(messageParts, endMessageFormatted)
        end
    end

    if isLastMessage then
        addFormattedMessage(messageParts, '\n%s=================================================', colorGray)
    end

    return table.concat(messageParts)
end

-- ===========================================================================================================
--                                    2. Alternate Player Functions
-- ===========================================================================================================

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

--- Updates the `SharedFunctions.altState` object with the current state values.
-- This function synchronizes the alternate state with the main state variables.
function update_altState()
    assert(type(state) == 'table', "state is not a table")

    local function updateStateField(stateField, altStateField)
        assert(type(state[stateField]) == 'table', stateField .. " is not a table")
        SharedFunctions.altState[altStateField] = state[stateField].value
    end

    updateStateField('altPlayerLight', 'Light')
    updateStateField('altPlayerTier', 'Tier')
    updateStateField('altPlayerDark', 'Dark')
    updateStateField('altPlayera', 'Ra')
    updateStateField('altPlayerGeo', 'Geo')
    updateStateField('altPlayerIndi', 'Indi')
    updateStateField('altPlayerEntrust', 'Entrust')
end

--- Buffing sequence handler for an alternate Geomancer character.
-- @param altSpell (string): The name of the spell to cast.
-- @param isEntrust (boolean): If true, the "Entrust" ability will be used before casting the spell.
-- @param isGeo (boolean): If true, the "Full Circle" ability will be used before casting the Geo spell.
function bubbleBuffForAltGeo(altSpell, isEntrust, isGeo)
    if type(altSpell) ~= 'string' or type(isEntrust) ~= 'boolean' or type(isGeo) ~= 'boolean' then
        error('Invalid input parameters')
    end

    local targetid, targetname = get_current_target_id_and_name()

    if not targetid or not targetname then
        targetid = 0
        targetname = 'NoTarget'
    end

    local spellToCast = altSpell
    local targetForGeo = targetid

    if table.contains(mainPlayerSpells, altSpell) then
        targetForGeo = '<' .. SharedFunctions.mainPlayerName .. '>'
    end

    local command = 'send ' .. SharedFunctions.altPlayerName

    if isEntrust then
        if targetname ~= SharedFunctions.altPlayerName then
            command = command .. ' /ja "Entrust" <' .. SharedFunctions.altPlayerName .. '>'
        end
        command = command .. '; wait 2; send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid
    elseif isGeo then
        if find_member_and_pet_in_party(SharedFunctions.altPlayerName) then
            command = command .. ' /ja "Full Circle" <' .. SharedFunctions.altPlayerName .. '>'
            command = command ..
                '; wait 2; send ' ..
                SharedFunctions.altPlayerName ..
                ' ' ..
                spellToCast ..
                ' ' ..
                targetForGeo ..
                '; wait 4; send ' .. SharedFunctions.altPlayerName .. ' Cure <' .. SharedFunctions.mainPlayerName .. '>'
        else
            command = command ..
                ' ' ..
                spellToCast ..
                ' ' ..
                targetForGeo ..
                '; wait 4; send ' .. SharedFunctions.altPlayerName .. ' Cure <' .. SharedFunctions.mainPlayerName .. '>'
        end
    else
        command = command .. ' ' .. spellToCast .. ' ' .. '<' .. SharedFunctions.altPlayerName .. '>'
    end

    local success, error = pcall(send_command, command)
    if not success then
        error('Failed to send command: ' .. error)
    end
end

--- Handles the casting of an alternate spell.
-- @param altSpell (string): The name of the alternate spell to cast.
-- @param altTier (string or nil): The tier of the alternate spell to cast.
-- @param isRaSpell (boolean): Indicates whether the spell is a Ra spell.
function handle_altNuke(altSpell, altTier, isRaSpell)
    assert(altSpell ~= '' and (altTier ~= '' or altTier == nil),
        "Invalid arguments: altSpell and altTier must not be empty strings")
    assert(type(altSpell) == 'string' and (altTier == nil or type(altTier) == 'string') and type(isRaSpell) == 'boolean',
        'Invalid input parameters')

    local spellToCast = altSpell .. (isRaSpell and ' III' or altTier)

    local targetid, targetname = get_current_target_id_and_name()

    if player.status == 'Engaged' then
        if targetid then
            local success, err = pcall(send_command,
                'send ' ..
                SharedFunctions.altPlayerName ..
                ' /assist <' ..
                SharedFunctions.mainPlayerName ..
                '>; wait 1; send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' <t>'
            )
            if not success then
                assert(false, 'Failed to send command: ' .. (err or 'Unknown error'))
            end
        end
    else
        local mob = windower.ffxi.get_mob_by_target('lastst')
        if mob and mob.id then
            targetid = mob.id
            local success, err = pcall(send_command,
                'send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid)
            if not success then
                assert(false, 'Failed to send command: ' .. (err or 'Unknown error'))
            end
        end
    end
end

--- Casts a sequence of spells on a target.
-- @param spells (table): A table of spells to cast.
-- @return (boolean): True if successful, false otherwise.
function applySpellSequenceToTarget(spells)
    if type(spells) ~= 'table' or #spells == 0 then
        return false
    end

    local success, targetid, targetname = pcall(get_current_target_id_and_name)
    if not success then
        return false
    end

    for _, spell in ipairs(spells) do
        local command
        if spell.delay == 0 then
            command = string.format('send %s %s %s', SharedFunctions.altPlayerName, spell.name, tostring(targetid))
        else
            command =
                string.format('wait %d; send %s %s %s', spell.delay, SharedFunctions.altPlayerName, spell.name,
                    tostring(targetid))
        end
        if spell.name == 'Phalanx2' and targetname == SharedFunctions.mainPlayerName and player.main_job == 'PLD' then
            local bothPhalanx
            if spell.delay == 0 then
                bothPhalanx =
                    string.format(
                        'send %s Phalanx %s; send %s Phalanx2 %s',
                        SharedFunctions.mainPlayerName,
                        tostring(targetid),
                        SharedFunctions.altPlayerName,
                        tostring(targetid)
                    )
            else
                bothPhalanx =
                    string.format(
                        'wait %d; send %s Phalanx %s; send %s Phalanx2 %s',
                        spell.delay,
                        SharedFunctions.mainPlayerName,
                        tostring(targetid),
                        SharedFunctions.altPlayerName,
                        tostring(targetid)
                    )
            end
            local success, message = pcall(send_command, bothPhalanx)
            if not success then
                return false
            end
        else
            local success, message = pcall(send_command, command)
            if not success then
                return false
            end
        end
    end

    return true
end

--- Handles the command sequence for a character.
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'bdd', 'buffrng', 'curaga', 'debuff').
-- @return (boolean): True if successful, false otherwise.
function bufferRoleForAltRdm(commandType)
    if type(commandType) ~= 'string' then
        return false
    end

    local success, targetid, targetname = pcall(get_current_target_id_and_name)
    if not success then
        return false
    end

    local spells = {}

    if commandType == 'bufftank' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Refresh3', delay = 4 },
            { name = 'Phalanx2', delay = 9 },
            { name = 'Regen2',   delay = 13 },
        }
    elseif commandType == 'buffmelee' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'buffrng' then
        spells = {
            { name = 'flurry2',  delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
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
            { name = 'paralyze2', delay = 17 }
        }
    end

    local success, message = pcall(applySpellSequenceToTarget, spells)
    if not success then
        return false
    end

    return true
end

-- ===========================================================================================================
--                            3. Equipment and Gear Set Management Functions
-- ===========================================================================================================

--- Creates an equipment object with the given parameters.
-- @param name (string) The name of the equipment.
-- @param priority (number, optional) The priority of the equipment.
-- @param bag (string, optional) The bag in which the equipment is stored.
-- @param augments (table, optional) The augments of the equipment.
-- @return table A table representing the equipment.
function createEquipment(name, priority, bag, augments)
    assert(type(name) == 'string', "Parameter 'name' must be a string")
    assert(priority == nil or type(priority) == 'number', "Parameter 'priority' must be a number or nil")
    assert(bag == nil or type(bag) == 'string', "Parameter 'bag' must be a string or nil")
    assert(not augments or type(augments) == 'table', "Parameter 'augments' must be a table")

    return {
        name = name,
        priority = priority or nil,
        bag = bag or nil,
        augments = augments or {}
    }
end

--- Combines the default equipment set with the first matching condition's set.
-- Iterates over the conditions, and if a condition is true and has a corresponding set,
-- it combines that set with the default set and returns it.
-- If no conditions are met, returns the default set.
-- @param defaultSet (table): The base equipment set.
-- @param conditions (table): A table of conditions with boolean values.
-- @param setTable (table): A table mapping condition names to equipment sets.
-- @return (table): The combined equipment set based on the first true condition, or the default set.
function customize_set(defaultSet, conditions, setTable)
    assert(defaultSet and conditions and setTable, "Invalid parameters")
    assert(type(conditions) == "table" and type(setTable) == "table",
        "Invalid parameters: 'conditions' and 'setTable' must be tables")

    for conditionName, isActive in pairs(conditions) do
        if isActive then
            local conditionSet = setTable[conditionName]
            if conditionSet then
                -- Combine the default set with the condition's set and return
                return set_combine(defaultSet, conditionSet)
            else
                -- If the set for this condition is not defined, log a warning and continue
                add_to_chat(123, "Note: No set defined for condition '" .. conditionName .. "', using default set.")
            end
        end
    end
    -- If no conditions are met, return the default set
    return defaultSet
end

--- Generates conditions and corresponding sets based on the current state.
-- Constructs tables of conditions and sets to be used in set customization functions.
-- Only includes conditions for which sets are provided (non-nil).
-- @param setPDT_XP (table|nil): Equipment set for 'PDT_XP' condition.
-- @param setPDT (table|nil): Equipment set for 'PDT' condition.
-- @param setPDT_ACC (table|nil): Equipment set for 'PDT_ACC' condition.
-- @param setMDT (table|nil): Equipment set for 'MDT' condition.
-- @return (table, table): A table of conditions and a table mapping conditions to sets.
function get_conditions_and_sets(setPDT_XP, setPDT, setPDT_ACC, setMDT)
    -- Validate input sets
    local function validate_set(set)
        return set == nil or type(set) == "table"
    end
    assert(validate_set(setPDT_XP) and validate_set(setPDT) and validate_set(setPDT_ACC) and validate_set(setMDT),
        "Invalid parameters: Equipment sets must be tables or nil")

    -- Ensure 'state' and required state variables are valid
    assert(type(state) == "table", "Invalid state: 'state' must be a table")
    assert(type(state.HybridMode) == "table" and type(state.OffenseMode) == "table",
        "Invalid state: 'HybridMode' and 'OffenseMode' must be tables")
    assert(type(state.HybridMode.value) == "string" and type(state.OffenseMode.value) == "string",
        "Invalid state: 'HybridMode.value' and 'OffenseMode.value' must be strings")

    -- Handle optional 'state.Xp'
    local xpValue = (type(state.Xp) == "table" and state.Xp.value) or 'False'
    assert(type(xpValue) == "string", "Invalid state: 'Xp.value' must be a string")

    local conditions = {}
    local setTable = {}

    -- Only include conditions if their sets are provided
    if setPDT_XP then
        conditions['PDT_XP'] = (state.HybridMode.value == 'PDT') and (xpValue == 'True')
        setTable['PDT_XP'] = setPDT_XP
    end

    if setPDT then
        conditions['PDT'] = (state.HybridMode.value == 'PDT') and (xpValue == 'False')
        setTable['PDT'] = setPDT
    end

    if setPDT_ACC then
        conditions['PDT_ACC'] = (state.HybridMode.value == 'PDT') and (state.OffenseMode.value == 'Acc')
        setTable['PDT_ACC'] = setPDT_ACC
    end

    if setMDT then
        conditions['MDT'] = (state.HybridMode.value == 'MDT') and (xpValue == 'False')
        setTable['MDT'] = setMDT
    end

    return conditions, setTable
end

--- Customizes a set based on the current state by combining it with condition-specific sets.
-- @param baseSet (table): The equipment set to customize.
-- @param setXp (table|nil): Equipment set to use when 'Xp' condition is true.
-- @param setPDT (table|nil): Equipment set to use when 'PDT' condition is true.
-- @param setMDT (table|nil): Equipment set to use when 'MDT' condition is true.
-- @return (table): The customized equipment set.
function customize_set_based_on_state(baseSet, setXp, setPDT, setMDT)
    local conditions, setTable = get_conditions_and_sets(setXp, setPDT, nil, setMDT)
    return customize_set(baseSet, conditions, setTable)
end

--- Adjusts the earring equipment based on the player's TP and the spell being cast.
-- @param spell (table): The spell that the player is casting.
function adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
    assert(spell, "Spell is nil")
    assert(sets and sets.precast and sets.precast.WS, "Required tables do not exist")
    assert(player and player.equipment and player.tp, "Player information is not available")

    if not sets.precast.WS[spell.name] then
        sets.precast.WS[spell.name] = sets.precast.WS
    end

    sets.precast.WS[spell.name].left_ear = adjust_Left_Ear_Equipment(spell, player)
end

-- ===========================================================================================================
--                         4. State Management and Basic Data Handling Functions
-- ===========================================================================================================

--- Retrieves the ID and name of the current target.
-- @return (number, string) The ID and name of the current target, or nil if no target is selected.
function get_current_target_id_and_name()
    local status, target = pcall(windower.ffxi.get_mob_by_target, 'lastst')
    if not status or not target then
        return nil, nil
    end
    return target.id, target.name
end

--- Checks if the player is incapacitated by any defined buffs.
-- If incapacitated, it cancels the spell, marks the event as handled, reverts to the previous gear set, and notifies the player.
-- @param spell (table): The spell currently being cast.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean, string or nil): True if incapacitated, false otherwise, and the type of incapacitation.
function incapacitated(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.action_type or not spell.name then
        return false, "Invalid inputs"
    end

    if (spell.action_type == 'Ability' or spell.action_type == 'Item') and (buffactive['silence'] or buffactive['mute']) then
        return false, nil
    end

    if next(buffactive) then
        for buff in pairs(buffactive) do
            if SharedFunctions.incapacitating_buffs_set[buff] then
                local success, error = pcall(cancel_spell)
                if not success then
                    return false, "Error in cancel_spell: " .. error
                end

                eventArgs.handled = true

                local success, error = pcall(function()
                    add_to_chat(167, createFormattedMessage('Cannot Use:', spell.name, nil, buff, true, true))
                end)
                if not success then
                    return false, "Error in add_to_chat or createFormattedMessage: " .. error
                end

                return true, buff
            end
        end
    end

    return false, nil
end

--- Checks if a specific party member has a pet.
-- @param name (string): The name of the party member to check.
-- @return (boolean): True if the party member is found and they have a pet, false otherwise.
function find_member_and_pet_in_party(name)
    if type(name) ~= 'string' then
        error("name must be a string")
    end
    if type(party) ~= 'table' then
        error("party must be a table")
    end
    for _, member in ipairs(party) do
        if type(member) ~= 'table' then
            error("party member must be a table")
        end
        if not member.mob or type(member.mob) ~= 'table' then
            error("mob must be a table")
        end
        if member.mob.name == name then
            return member.mob.pet_index ~= nil
        end
    end
    return false
end

--- Checks if a table contains a specific element.
-- @param tbl (table): The table to search in.
-- @param element (any): The element to search for in the table.
-- @return (boolean): True if the element is found in the table, false otherwise.
function table.contains(tbl, element)
    assert(type(tbl) == 'table', "tbl must be a table")
    assert(element ~= nil, "element cannot be nil")
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

--- Determines if a given action inherently triggers the Treasure Hunter effect.
-- @param category (number): The category of the action.
-- @param param (number): The specific action within the category.
-- @return (boolean): True if the action inherently triggers Treasure Hunter, false otherwise.
function th_action_check(category, param)
    if type(category) ~= 'number' then
        error("category must be a number")
    end
    if type(param) ~= 'number' then
        error("param must be a number")
    end

    local th_actions = {
        [2] = function() return true end,                                       -- Any ranged attack
        [4] = function() return true end,                                       -- Any magic action
        [3] = function(param) return param == 30 end,                           -- Aeolian Edge
        [6] = function(param) return info.default_ja_ids:contains(param) end,   -- Provoke, Animated Flourish
        [14] = function(param) return info.default_u_ja_ids:contains(param) end -- Quick/Box/Stutter Step, etc.
    }

    if th_actions[category] and th_actions[category](param) then
        return true
    end

    return false
end

-- ===========================================================================================================
--                                     5. Spell Casting Functions
-- ===========================================================================================================

--- Checks if a spell can be cast.
-- This function checks if the spell is valid, not on cooldown, and if the player is not incapacitated.
-- @param spell (table): The spell to check.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if the spell can be cast, false otherwise.
function can_cast_spell(spell, eventArgs)
    if spell == nil or spell.id == nil or spell.action_type == nil then
        return false
    end

    if type(incapacitated) ~= "function" then
        error("incapacitated function does not exist or is not a function")
    end

    local is_incapacitated, incapacity_type
    local status, err = pcall(function()
        is_incapacitated, incapacity_type = incapacitated(spell, eventArgs)
    end)
    if not status then
        print("Error calling incapacitated function: " .. err)
        return false
    end
    if is_incapacitated then
        return false
    end

    local spellRecasts
    status, err = pcall(function()
        spellRecasts = windower.ffxi.get_spell_recasts()
    end)
    if not status then
        print("Error getting spell recasts: " .. err)
        return false
    end
    if spellRecasts ~= nil then
        local spellRecast = spellRecasts[spell.id]
        if spellRecast ~= nil and spellRecast > 0 then
            return false
        end
    end

    return true
end

--- Attempts to cast a spell if possible.
-- If the spell cannot be cast, it cancels the spell and returns false.
-- @param spell (table): The spell to attempt to cast.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if the spell was cast successfully, false otherwise.
function try_cast_spell(spell, eventArgs)
    if type(cancel_spell) ~= "function" then
        error("cancel_spell function does not exist or is not a function")
    end

    local status, result_or_err = pcall(function()
        if not can_cast_spell(spell, eventArgs) then
            cancel_spell()
            return false
        end
        return true
    end)

    if not status then
        print(result_or_err)
        return false
    end

    return result_or_err
end

--- Handles the scenario when a spell cannot be cast.
-- @param spell (table): The spell that cannot be cast.
-- @param eventArgs (table): Additional event arguments.
function handle_unable_to_cast(spell, eventArgs)
    if not try_cast_spell(spell, eventArgs) then
        cancel_spell()
        eventArgs.handled = true
        job_handle_equipping_gear(playerStatus, eventArgs)
        add_to_chat(167, createFormattedMessage('Cannot Use:', spell.name, nil, value, true, true))
    end
end

--- Checks and displays cooldowns for spells.
-- @param spell (table): The spell being cast.
-- @param eventArgs (table): Additional event arguments.
function checkDisplayCooldown(spell, eventArgs)
    assert(type(spell) == 'table', "Error: spell is not a table")
    assert(type(eventArgs) == 'table', "Error: eventArgs is not a table")

    local requiredKeys = { 'name', 'type', 'action_type', 'id' }
    for _, key in ipairs(requiredKeys) do
        assert(spell[key], "Error: spell does not have a '" .. key .. "' key")
    end

    local ignoredOrSpecialTypes = table.contains(SharedFunctions.ignoredSpells, spell.name) or
        spell.skill == 'Elemental Magic' or
        spell.type == 'Scholar' or
        spell.action_type == 'Weapon Skill'
    if ignoredOrSpecialTypes then return end

    local recast = 0

    local status, recasts
    if spell.action_type == 'Magic' then
        status, recasts = pcall(windower.ffxi.get_spell_recasts)
        if status and type(recasts) == 'table' and recasts[spell.id] then
            recast = recasts[spell.id] / 60
        end
    elseif spell.action_type == 'Ability' then
        status, recasts = pcall(windower.ffxi.get_ability_recasts)
        if status and type(recasts) == 'table' and recasts[spell.recast_id] then
            recast = recasts[spell.recast_id]
        end
    end

    if recast and recast > 0 then
        local status, err = pcall(cancel_spell)
        if not status then
            assert(status, "Error: failed to cancel spell: " .. (err or ""))
        end

        assert(type(eventArgs.handled) == 'boolean', "Error: eventArgs does not have a 'handled' field of type boolean")

        status, err = pcall(add_to_chat, 123, createFormattedMessage(nil, spell.name, recast, nil, true))
        if not status then
            assert(status, "Error: failed to add message to chat: " .. (err or ""))
        end
        eventArgs.handled = true
    end
end

--- Attempts to cast a spell and call an associated auto-ability function if it exists.
-- @param spell (table): The spell to attempt to cast.
-- @param eventArgs (table): Additional event arguments.
-- @param auto_abilities (table): A table mapping spell names to functions.
function handle_spell(spell, eventArgs, auto_abilities)
    assert(type(spell) == 'table', "Error: spell must be a table")
    assert(type(eventArgs) == 'table', "Error: eventArgs must be a table")

    if not eventArgs.handled and try_cast_spell(spell, eventArgs) then
        if auto_abilities ~= nil then
            local auto_ability_function = auto_abilities[spell.name]
            if auto_ability_function ~= nil then
                local status, err = pcall(auto_ability_function, spell, eventArgs)
                if not status then
                    error("Error in auto_ability_function: " .. tostring(err))
                end
            end
        end
    end
end

--- Automatically casts an ability before a spell if possible.
-- @param spell (table): The spell to attempt to cast.
-- @param eventArgs (table): Additional event arguments.
-- @param abilityId (number): The ID of the ability to use before the spell.
-- @param waitTime (number): The time to wait after using the ability.
-- @param abilityName (string): The name of the ability to use before the spell.
function auto_ability(spell, eventArgs, abilityId, waitTime, abilityName)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or type(abilityId) ~= 'number' or type(waitTime) ~= 'string' or type(abilityName) ~= 'string' then
        return
    end

    if try_cast_spell(spell, eventArgs) then
        local abilityCooldown
        local status, err = pcall(function() abilityCooldown = windower.ffxi.get_ability_recasts()[abilityId] end)
        if not status then
            return
        end

        if abilityCooldown < 1 and not buffactive[abilityName] then
            cancel_spell()
            send_command(
                string.format(
                    'input /ja "%s" <me>; wait %f; input /ma %s %s',
                    abilityName,
                    waitTime,
                    spell.name,
                    spell.target.id
                )
            )
        end
    else
        handle_unable_to_cast(spell, eventArgs)
    end
end

--- Handles an interrupted spell event.
-- @param spell (table): The spell that was interrupted.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if successful, false otherwise.
function handleInterruptedSpell(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or type(spell.name) ~= 'string' then
        return false
    end

    local success, message = pcall(job_handle_equipping_gear, playerStatus, eventArgs)
    if not success then
        return false
    end

    eventArgs.handled = true

    success, message = pcall(add_to_chat, 123,
        createFormattedMessage('[Spell interrupted]:', spell.name, nil, nil, true, nil))
    if not success then
        return false
    end

    return true
end

--- Handles actions after a spell has been successfully cast.
-- @param spell (table): The spell that has been successfully cast.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if successful, false otherwise.
function handleCompletedSpell(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if state.Moving.value == 'true' then
        local success, message = pcall(send_command, 'gs equip sets.MoveSpeed')
        if not success then
            return false
        end
    end

    return true
end

--- Handles actions after a spell has been cast.
-- @param spell (table): The spell that has been cast.
-- @param eventArgs (table): Additional event arguments.
-- @return (boolean): True if successful, false otherwise.
function handleSpellAftercast(spell, eventArgs)
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if spell.interrupted then
        local success, message = pcall(handleInterruptedSpell, spell, eventArgs)
        if not success then
            return false
        end
    else
        local success, message = pcall(handleCompletedSpell, spell, eventArgs)
        if not success then
            return false
        end
    end

    return true
end

--- Casts an elemental spell.
-- @param mainSpell (string): The name of the main spell to cast.
-- @param tier (string or nil): The tier of the spell to cast.
function castElementalSpells(mainSpell, tier)
    assert(type(mainSpell) == 'string' and mainSpell ~= nil, 'Invalid mainSpell parameter')
    assert(tier == nil or type(tier) == 'string', 'Invalid tier parameter')

    local spell = mainSpell
    if tier then
        spell = spell .. tier
    end

    local success, err = pcall(function() send_command('input /ma "' .. spell .. '" <stnpc>') end)
    assert(success, 'Failed to send command: ' .. tostring(err))
end

--- Casts arts or addendum.
-- @param arts (string): The name of the arts to cast.
-- @param addendum (string): The name of the addendum to cast.
function castArtsOrAddendum(arts, addendum)
    assert(type(arts) == 'string' and arts ~= nil, 'Invalid arts parameter')
    assert(type(addendum) == 'string' and addendum ~= nil, 'Invalid addendum parameter')

    local command
    if not buffactive[arts] then
        command = 'input /ja "' .. arts .. '" <me>'
    else
        command = 'input /ja "' .. addendum .. '" <me>'
    end

    local success, err = pcall(function() send_command(command) end)
    assert(success, 'Failed to send command: ' .. tostring(err))
end

--- Casts a Scholar spell with the appropriate arts and addendum.
-- @param spell (string): The name of the spell to cast.
-- @param arts (string): The name of the art to use.
-- @param addendum (string): The name of the addendum to use.
function castSchSpell(spell, arts, addendum)
    assert(type(spell) == 'string', "Invalid parameters. 'spell' must be a string.")
    assert(type(arts) == 'string', "Invalid parameters. 'arts' must be a string.")
    assert(type(addendum) == 'string', "Invalid parameters. 'addendum' must be a string.")

    local delay = (spell == 'Sneak' or spell == 'Invisible') and 1 or 2.1
    local targetid, targetname = get_current_target_id_and_name()

    assert(send_command, "Required function 'send_command' is not available.")
    assert(buffactive, "Required variable 'buffactive' is not available.")
    assert(stratagems_available, "Required function 'stratagems_available' is not available.")
    assert(add_to_chat, "Required function 'add_to_chat' is not available.")

    local command
    if buffactive[addendum] then
        command = 'input /ma "' .. spell .. '" ' .. targetid
    elseif buffactive[arts] and not buffactive[addendum] then
        assert(stratagems_available(), "No stratagems are available.")
        command = 'input /ja "' .. addendum .. '" <me>; wait 2; input /ma "' .. spell .. '" ' .. targetid
    elseif stratagems_available() then
        command = 'input /ja "' ..
            arts ..
            '" <me>; wait 2; input /ja "' ..
            addendum .. '" <me>; wait ' .. delay .. '; input /ma "' .. spell .. '" ' .. targetid
    else
        add_to_chat(123, "No stratagems are available.")
        return
    end

    local success, err = pcall(function() send_command(command) end)
    assert(success, "Failed to send command: " .. tostring(err))
end

--- Refines the casting of Utsusemi spells based on their cooldown status.
-- @param spell (table): The spell that the player is casting.
-- @param eventArgs (table): Additional event arguments.
function refine_Utsusemi(spell, eventArgs)
    assert(spell ~= nil and type(spell) == 'table' and spell.name ~= nil,
        'Invalid spell: spell must be a table with a name field')
    assert(eventArgs ~= nil and type(eventArgs) == 'table', 'Invalid eventArgs: eventArgs must be a table')

    local spell_recasts = windower.ffxi.get_spell_recasts()

    assert(spell_recasts ~= nil, 'Failed to get spell recasts')

    local NiCD = spell_recasts[339]
    local IchiCD = spell_recasts[338]

    if spell.name == 'Utsusemi: Ni' then
        if NiCD > 1 then
            eventArgs.cancel = true

            if IchiCD < 1 then
                cancel_spell()
                cast_delay(1.1)
                send_command('input /ma "Utsusemi: Ichi" <me>')
            else
                add_to_chat(123, "Neither spell is ready!")
            end
        end
    end
    if spell.name == 'Utsusemi: Ichi' then
        if IchiCD > 1 then
            eventArgs.cancel = true
        end
    end
end

-- ===========================================================================================================
--                               6. Job-Specific Command Handling Functions
-- ===========================================================================================================

--- Handles Black Mage (BLM) commands based on the given command parameters.
-- @param cmdParams (table): A table containing the command parameters.
function handle_blm_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        error("Invalid command parameters.")
    end

    if type(cmdParams[1]) ~= 'string' then
        error("Command must be a string.")
    end

    local cmd = cmdParams[1]:lower()

    local spells = {
        buffself = function()
            BuffSelf()
        end,
        mainlight = function()
            castElementalSpells(state.MainLightSpell.value, state.TierSpell.value)
        end,
        sublight = function()
            castElementalSpells(state.SubLightSpell.value, state.TierSpell.value)
        end,
        maindark = function()
            castElementalSpells(state.MainDarkSpell.value, state.TierSpell.value)
        end,
        subdark = function()
            castElementalSpells(state.SubDarkSpell.value, state.TierSpell.value)
        end,
        aja = function()
            castElementalSpells(state.Aja.value)
        end
    }

    if spells[cmd] then
        spells[cmd]()
    end
end

--- Handles commands specific to the Scholar (SCH) subjob.
-- @param cmdParams (table): A table containing the command parameters.
function handle_sch_subjob_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        error("Invalid command parameters.")
    end

    if type(cmdParams[1]) ~= 'string' then
        error("Command must be a string.")
    end

    local cmd = cmdParams[1]:lower()

    function castStormSpell(spell)
        if not buffactive['Klimaform'] and windower.ffxi.get_spell_recasts()[287] < 1 then
            send_command('input /ma "Klimaform" ; wait 5; input /ma "' .. spell .. '" ')
        else
            send_command('input /ma "' .. spell .. '" ')
        end
    end

    local schSpells = {
        storm = function()
            castStormSpell(state.Storm.value)
        end,
        lightarts = function()
            castArtsOrAddendum('Light Arts', 'Addendum: White')
        end,
        darkarts = function()
            castArtsOrAddendum('Dark Arts', 'Addendum: Black')
        end,
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
        dispel = function()
            castSchSpell('Dispel', 'Dark Arts', 'Addendum: Black')
        end,
        sneak = function()
            castSchSpell('Sneak', 'Light Arts', 'Accession')
        end,
        invi = function()
            castSchSpell('Invisible', 'Light Arts', 'Accession')
        end
    }

    if schSpells[cmd] then
        schSpells[cmd]()
    end
end

--- Handles commands specific to the Warrior (WAR) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if the command was successfully executed, false otherwise.
function handle_war_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        return false
    end

    local cmd = cmdParams[1]:lower()

    local warCommands = {
        berserk = function()
            if buffactive['Defender'] then
                send_command('cancel defender')
            end
            buffSelf('Berserk')
        end,
        defender = function()
            if state.HybridMode.value == 'Normal' then
                send_command('gs c set HybridMode PDT')
            end
            if buffactive['Berserk'] then
                send_command('cancel berserk')
            end
            buffSelf('Defender')
        end,
        thirdeye = ThirdEye,
        jump = jump
    }

    if warCommands[cmd] then
        warCommands[cmd]()
        return true
    end

    return false
end

--- Handles commands specific to the Thief (THF) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if the command was successfully executed, false otherwise.
function handle_thf_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        return false
    end

    local cmd = cmdParams[1]:lower()

    local thfCommands = {
        thfbuff = function()
            buffSelf('thfBuff')
        end
    }

    if thfCommands[cmd] then
        local status, err = pcall(thfCommands[cmd])
        if status then
            return true
        end
    end

    return false
end

-- ===========================================================================================================
--                              7. Weapon Skill Adjustment Functions
-- ===========================================================================================================

--- Checks if a weapon skill is within range of the target.
-- @param spell (table): A table containing information about the spell.
function Ws_range(spell)
    if spell.type == "WeaponSkill" then
        assert(type(spell) == 'table', "Error: 'spell' is not a table.")
        assert(type(spell.target) == 'table', "Error: 'spell.target' is not a table.")
        assert(type(spell.range) == 'number', "Error: 'spell.range' is not a number.")
        assert(type(spell.type) == 'string', "Error: 'spell.type' is not a string.")
        assert(type(spell.target.distance) == 'number', "Error: 'spell.target.distance' is not a number.")
        assert(type(spell.target.model_size) == 'number', "Error: 'spell.target.model_size' is not a number.")

        local mult = 1.55
        if (spell.target.model_size + spell.range * mult) < spell.target.distance then
            cancel_spell()
            local message = createFormattedMessage("[Cancel]", spell.name, nil, "Too Far!", true, true)
            add_to_chat(057, message)
            return
        end
    end
end

--- Adjusts the left ear equipment based on the spell name, player's TP, and Treasure Hunter status.
-- @param spell (table): The spell that the player is casting.
-- @param player (table): The player's current status.
-- @return (string): The name of the earring to equip.
function adjust_Left_Ear_Equipment(spell, player)
    if ((player.equipment.sub == 'Centovente' and player.tp >= 1750 and player.tp < 2000) or
            (player.equipment.sub ~= 'Centovente' and ((player.tp >= 1750 and player.tp < 2000) or (player.tp >= 2750 and player.tp < 3000)))) then
        return 'MoonShade Earring'
    else
        return (spell.name == 'Exenterator') and 'Dawn Earring' or
            ((spell.name == 'Aeolian Edge' and treasureHunter ~= 'None') and 'Sortiarius Earring' or
                (spell.name == 'Aeolian Edge' and 'Sortiarius Earring' or 'Sherida Earring'))
    end
end

-- ===========================================================================================================
--                           8. Equipment Management Functions (Player Gear)
-- ===========================================================================================================

--- Checks and equips the correct weapon set based on the player's main job and the weapon type.
-- @param weaponType (string): The type of weapon to check. Must be 'main' or 'sub'.
function check_weaponset(weaponType)
    assert(player ~= nil, 'player is nil')
    assert(player.main_job ~= nil, 'player.main_job is nil')
    assert(weaponType == 'main' or weaponType == 'sub', 'Invalid weaponType: ' .. tostring(weaponType))

    if player.main_job == 'THF' then
        assert(state.AbysseaProc ~= nil and state.WeaponSet2 ~= nil and state.WeaponSet1 ~= nil and state.SubSet ~= nil,
            'state.AbysseaProc, state.WeaponSet2, state.WeaponSet1, or state.SubSet is nil')

        assert(
            sets[state.WeaponSet1.current] ~= nil and sets[state.WeaponSet2.current] ~= nil and
            sets[state.SubSet.current] ~= nil, 'One of the sets does not exist')

        if weaponType == 'main' then
            if state.AbysseaProc.value then
                equip(sets[state.WeaponSet2.current])
            else
                equip(sets[state.WeaponSet1.current])
            end
        elseif weaponType == 'sub' then
            equip(sets[state.SubSet.current])
        end
    elseif player.main_job == 'BST' then
        assert(state.WeaponSet ~= nil and state.SubSet ~= nil and state.ammoSet ~= nil,
            'state.WeaponSet or state.SubSet or state.ammoSet is nil')

        -- Gestion de l'ammo pour BST avec priorité combat
        if player.status == 'Engaged' then
            equip({ ammo = "Aurgelmir Orb +1" }) -- Ammo de combat par défaut
        elseif state.ammoSet and sets[state.ammoSet.value] then
            equip(sets[state.ammoSet.value])     -- Sinon, utilise l'ammo de pet
        end

        -- Gestion des armes pour BST
        if weaponType == 'main' then
            assert(sets[state.WeaponSet.current] ~= nil, 'Main weapon set does not exist')
            equip(sets[state.WeaponSet.current])
        elseif weaponType == 'sub' then
            assert(sets[state.SubSet.current] ~= nil, 'Sub weapon set does not exist')
            equip(sets[state.SubSet.current])
        end
    elseif player.main_job ~= 'BLM' then
        assert(state.WeaponSet ~= nil and state.SubSet ~= nil, 'state.WeaponSet or state.SubSet is nil')

        assert(sets[state.WeaponSet.current] ~= nil and sets[state.SubSet.current] ~= nil,
            'One of the sets does not exist')

        if weaponType == 'main' then
            equip(sets[state.WeaponSet.current])
        elseif weaponType == 'sub' then
            equip(sets[state.SubSet.current])
        end
    end
end

--- Checks if a ranged weapon is equipped and locks or unlocks the range and ammo slots accordingly.
function check_range_lock()
    assert(player and player.equipment and player.equipment.range,
        'player, player.equipment, or player.equipment.range is nil')

    if player.equipment.range ~= 'empty' then
        local status, err = pcall(disable, 'range', 'ammo')
        if not status then
            err = err or 'Unknown error'
            assert(status, 'Failed to disable range and ammo slots: ' .. err)
        end
    else
        local status, err = pcall(enable, 'range', 'ammo')
        if not status then
            err = err or 'Unknown error'
            err = type(err) == "table" and table.concat(err, ", ") or err
            assert(status, 'Failed to enable range and ammo slots: ' .. err)
        end
    end
end

--- Resets the player's equipment to its default state.
function reset_to_default_equipment()
    assert(sets.engaged ~= nil and sets.idle ~= nil and sets.MoveSpeed ~= nil, 'Necessary equipment set is nil')

    local baseSet = player.status == 'Engaged' and sets.engaged or sets.idle

    if state.Moving.value == 'true' and player.status ~= 'Engaged' then
        baseSet = set_combine(baseSet, sets.MoveSpeed)
    end

    if state.HybridMode then
        if state.HybridMode.value == 'PDT' then
            if state.Xp and state.Xp.value == 'True' then
                equip(baseSet.PDT_XP)
            elseif state.OffenseMode.value == 'Acc' then
                equip(baseSet.PDT_ACC)
            else
                equip(baseSet.PDT)
            end
        elseif state.HybridMode.value == 'MDT' then
            equip(baseSet.MDT)
        else
            equip(baseSet)
        end
    else
        equip(baseSet)
    end
end

--- Handles the player's equipment based on their status and the event arguments.
-- @param playerStatus (string or nil): The player's status.
-- @param eventArgs (table or nil): Additional event arguments.
function job_handle_equipping_gear(playerStatus, eventArgs)
    assert(playerStatus == nil or type(playerStatus) == 'string', 'playerStatus must be either nil or a string')
    assert(eventArgs == nil or type(eventArgs) == 'table', 'eventArgs must be either nil or a table')
    assert(state, 'state must not be nil')
    assert(state.Xp == nil or type(state.Xp) == "table", 'state.Xp must be either nil or a table')
    assert(type(reset_to_default_equipment) == 'function', 'reset_to_default_equipment must be a function')
    assert(type(check_weaponset) == 'function', 'check_weaponset must be a function')
    assert(type(check_range_lock) == 'function', 'check_range_lock must be a function')

    if state and state.Xp and state.Xp.value == 'True' then
        if reset_to_default_equipment then
            reset_to_default_equipment()
        end
    else
        if check_weaponset then
            check_weaponset('main')
        end
        if check_weaponset then
            check_weaponset('sub')
        end
        if reset_to_default_equipment then
            reset_to_default_equipment()
        end
        if player and player.main_job == 'THF' then
            if check_range_lock then
                check_range_lock()
            end
        end
    end
end

--- Handles necessary actions when the job state changes.
-- @param field (string): The field that has changed in the job state.
-- @param new_value (any): The new value of the changed field.
-- @param old_value (any): The old value of the changed field.
function job_state_change(field, new_value, old_value)
    assert(type(check_weaponset) == 'function', "Error: check_weaponset is not a function")

    assert(field ~= nil, "Error: field is nil")
    assert(new_value ~= nil, "Error: new_value is nil")
    assert(old_value ~= nil, "Error: old_value is nil")

    check_weaponset('main')
    check_weaponset('sub')
end

--- Handles changes in buffs.
-- @param buff (string): The name of the buff.
-- @param gain (boolean): Whether the buff was gained or lost.
function buff_change(buff, gain)
    -- Validation des paramètres
    assert(buff ~= nil, "Error: buff is nil")
    assert(gain ~= nil, "Error: gain is nil")

    -- Variables locales pour l'optimisation
    local equip_set = {}
    local isMoving = state.Moving.value == 'true'
    local isTHFOrBLM = player.main_job == 'THF' or player.main_job == 'BLM'
    local isWARWithUkonvasara = player.main_job == 'WAR' and player.equipment.main == 'Ukonvasara'

    -- Gestion prioritaire de Doom
    if buff:lower() == 'doom' then
        if gain then
            -- Applique le set Doom
            if sets.buff.Doom then
                equip(sets.buff.Doom)
            end
            -- Verrouille les slots critiques
            disable('neck', 'ring1', 'waist')
            -- Notifications
            add_to_chat(123, createFormattedMessage('WARNING:', 'Doom', nil, 'is active!', true, nil))
            send_command('input /p [DOOM] <call21>')
        else
            -- Déverrouille les slots
            enable('neck', 'ring1', 'waist')
            -- Mise à jour de l'équipement
            send_command('gs c update')
            add_to_chat(123, createFormattedMessage(nil, 'Doom', nil, 'is no longer active!', true, nil))
            send_command('input /p [Doom] Off !')
        end
        return
    end

    -- Gestion spécifique pour WAR avec Ukonvasara
    if isWARWithUkonvasara then
        if buff == 'Aftermath: Lv.3' then
            if gain then
                if state.HybridMode.value == 'PDT' then
                    equip(sets.engaged.PDTAFM3)
                    add_to_chat(123, 'WAR: Switching to PDTAFM3 set for Aftermath: Lv.3')
                else
                    equip(sets.engaged)
                end
            else
                if state.HybridMode.value == 'PDT' then
                    equip(sets.engaged.PDTTP)
                    add_to_chat(123, 'WAR: Switching to PDTTP set after Aftermath: Lv.3 fades')
                else
                    equip(sets.engaged)
                end
            end
            return
        end
    end

    -- Ne pas changer le set si en combat, sauf pour des buffs spécifiques
    if player.status == 'Engaged' and
        not (buff == 'Aftermath: Lv.3' or buff == 'Doom' or
            buff == 'Sneak Attack' or buff == 'Trick Attack') then
        return
    end

    -- Gestion pour THF ou BLM
    if isTHFOrBLM then
        if state.Buff[buff] ~= nil then
            state.Buff[buff] = gain
        end

        -- Gestion spécifique de Mana Wall pour BLM
        if player.main_job == 'BLM' and buff == 'Mana Wall' then
            if gain then
                equip(sets.precast.JA['Mana Wall'])
                disable('back', 'feet')
            else
                enable('back', 'feet')
            end
        end
    end

    -- Gestion des buffs standards
    if state.Buff[buff] ~= nil then
        -- Applique le set spécifique au buff si existant
        if sets.buff[buff] then
            equip_set = set_combine(equip_set, sets.buff[buff])
        end

        -- Gestion du mode Treasure Hunter
        if state.TreasureMode and
            (state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime') then
            equip_set = set_combine(equip_set, sets.TreasureHunter)
        end
    end

    -- Gestion spécifique de Sneak Attack et Trick Attack
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        if gain then
            if state.Buff['Sneak Attack'] and state.Buff['Trick Attack'] then
                -- Les deux buffs sont actifs
                equip_set = set_combine(equip_set,
                    sets.buff['Sneak Attack'],
                    sets.buff['Trick Attack'])
            else
                -- Un seul buff est actif
                equip_set = set_combine(equip_set, sets.buff[buff])
            end
        else
            -- Gestion de la perte d'un buff
            if state.Buff['Sneak Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Sneak Attack'])
            elseif state.Buff['Trick Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Trick Attack'])
            else
                -- Plus aucun buff actif
                equip_set = player.status == 'Engaged' and sets.engaged or sets.idle
            end
        end

        -- Application du set si des modifications ont été faites
        if next(equip_set) then
            equip(equip_set)
        end

        -- Mise à jour finale de l'équipement si nécessaire
        if not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack'] then
            job_handle_equipping_gear(player.status, nil)
        end
    else
        -- Gestion normale des autres situations
        job_handle_equipping_gear(player.status, nil)
    end
end

-- ===========================================================================================================
--                             9. Stratagem Management Functions (SCH Job)
-- ===========================================================================================================

--- Returns the maximum number of Scholar (SCH) stratagems available based on the player's job level.
-- @return (number): The maximum number of SCH stratagems available, or 0 if 'SCH' is neither the main nor sub job.
function get_max_stratagem_count()
    assert(player, "Error: 'player' object is not defined.")
    assert(type(player.main_job) == 'string', "Error: 'player.main_job' is not a string.")
    assert(type(player.sub_job) == 'string', "Error: 'player.sub_job' is not a string.")
    assert(type(player.main_job_level) == 'number', "Error: 'player.main_job_level' is not a number.")
    assert(type(player.sub_job_level) == 'number', "Error: 'player.sub_job_level' is not a number.")

    if S { player.main_job, player.sub_job }:contains('SCH') then
        local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
        if lvl >= 99 then
            return 5
        elseif lvl >= 90 then
            return 5
        elseif lvl >= 70 then
            return 4
        elseif lvl >= 50 then
            return 3
        elseif lvl >= 30 then
            return 2
        else
            return 1
        end
    end
    return 0
end

--- Returns the recast time for a stratagem based on the player's job level.
-- @return (number): The recast time for a stratagem in seconds.
function get_stratagem_recast_time()
    assert(player, "Error: 'player' object is not defined.")
    assert(type(player.main_job) == 'string', "Error: 'player.main_job' is not a string.")
    assert(type(player.sub_job) == 'string', "Error: 'player.sub_job' is not a string.")
    assert(type(player.main_job_level) == 'number', "Error: 'player.main_job_level' is not a number.")
    assert(type(player.sub_job_level) == 'number', "Error: 'player.sub_job_level' is not a number.")

    local lvl = player.main_job == 'SCH' and player.main_job_level or player.sub_job_level
    if lvl >= 99 then
        return 33
    elseif lvl >= 90 then
        return 48
    elseif lvl >= 70 then
        return 60
    elseif lvl >= 50 then
        return 80
    elseif lvl >= 30 then
        return 120
    else
        return 240
    end
end

--- Returns the number of available Scholar (SCH) stratagems.
-- @return (number): The number of available SCH stratagems.
function get_available_stratagem_count()
    local recastTime = windower.ffxi.get_ability_recasts()[231] or 0
    assert(type(recastTime) == 'number', "Error: 'recastTime' is not a number.")

    local maxStrats = get_max_stratagem_count()
    assert(type(maxStrats) == 'number', "Error: 'maxStrats' is not a number.")

    if maxStrats == 0 then
        return 0
    end

    local stratagemRecastTime = get_stratagem_recast_time()
    assert(type(stratagemRecastTime) == 'number', "Error: 'stratagemRecastTime' is not a number.")

    local stratsUsed = recastTime > stratagemRecastTime and math.ceil(recastTime / stratagemRecastTime) or 0

    if recastTime == stratagemRecastTime then
        stratsUsed = math.floor(recastTime / stratagemRecastTime)
    end

    return math.max(0, maxStrats - stratsUsed)
end

--- Checks if there are any Scholar (SCH) stratagems available for use.
-- @return (boolean): True if there are stratagems available, false otherwise.
function stratagems_available()
    assert(type(get_available_stratagem_count) == 'function', "Error: 'get_available_stratagem_count' is not a function.")

    local stratagem_count = get_available_stratagem_count()
    assert(type(stratagem_count) == 'number', "Error: 'get_available_stratagem_count' did not return a number.")

    return stratagem_count > 0
end

-- ===========================================================================================================
--                                     10. Command Functions Mapping
-- ===========================================================================================================

commandFunctions = {
    bufftank = function()
        assert(type(bufferRoleForAltRdm) == 'function', "Error: 'bufferRoleForAltRdm' is not a function.")
        return bufferRoleForAltRdm('bufftank')
    end,
    buffmelee = function()
        assert(type(bufferRoleForAltRdm) == 'function', "Error: 'bufferRoleForAltRdm' is not a function.")
        return bufferRoleForAltRdm('buffmelee')
    end,
    buffrng = function()
        assert(type(bufferRoleForAltRdm) == 'function', "Error: 'bufferRoleForAltRdm' is not a function.")
        return bufferRoleForAltRdm('buffrng')
    end,
    curaga = function()
        assert(type(bufferRoleForAltRdm) == 'function', "Error: 'bufferRoleForAltRdm' is not a function.")
        return bufferRoleForAltRdm('curaga')
    end,
    debuff = function()
        assert(type(bufferRoleForAltRdm) == 'function', "Error: 'bufferRoleForAltRdm' is not a function.")
        return bufferRoleForAltRdm('debuff')
    end,
    altlight = function()
        assert(type(handle_altNuke) == 'function', "Error: 'handle_altNuke' is not a function.")
        return handle_altNuke(state.altPlayerLight.value, state.altPlayerTier.value, false)
    end,
    altdark = function()
        assert(type(handle_altNuke) == 'function', "Error: 'handle_altNuke' is not a function.")
        return handle_altNuke(state.altPlayerDark.value, state.altPlayerTier.value, false)
    end,
    altra = function()
        assert(type(handle_altNuke) == 'function', "Error: 'handle_altNuke' is not a function.")
        return handle_altNuke(state.altPlayera.value, nil, true)
    end,
    altindi = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Indi, false, false)
    end,
    altentrust = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Entrust, true, false)
    end,
    altgeo = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Geo, false, true)
    end,
}

return SharedFunctions
