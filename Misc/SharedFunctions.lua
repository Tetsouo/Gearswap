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
local SharedFunctions = {}

-- Constants used throughout the script
SharedFunctions.GRAY = 160      -- Color code for the gray.
SharedFunctions.ORANGE = 057    -- Color code for the orange.
SharedFunctions.YELLOW = 050    -- Color code for the green.
SharedFunctions.RED = 028       -- Color code for the red.
SharedFunctions.WAIT_TIME = 1.2 -- Time to wait between actions, in seconds
-- Array of stratagem charge times.
SharedFunctions.strat_charge_time = { 240, 120, 80, 60, 48 }
-- Array of spell names to be ignored. Add more spell names here as needed.
SharedFunctions.ignoredSpells = { 'Breakga', 'Aspir III', 'Aspir II' }
-- The name of the main player.
SharedFunctions.mainPlayerName = 'Tetsouo'
-- The name of the alternate player.
SharedFunctions.altPlayerName = 'Kaories'
-- Define an object to store the current state values
SharedFunctions.altState = {}

-- Set of incapacitating buffs. Each buff name is a key with a value of `true`.
SharedFunctions.incapacitating_buffs_set = {
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
--- Creates an equipment object.
-- This function creates an equipment object with the given parameters.
-- If a parameter is not provided, it will be set to a default value.
-- @param name (string) The name of the equipment. This must be a string.
-- @param priority (number, optional) The priority of the equipment. This must be a number or nil. Defaults to nil if not provided.
-- @param bag (string, optional) The bag in which the equipment is stored. This must be a string or nil. Defaults to nil if not provided.
-- @param augments (table, optional) The augments of the equipment. This must be a table. Defaults to an empty table if not provided.
-- @return table A table representing the equipment, with fields for name, priority, bag, and augments.
-- @usage local equipment = createEquipment("Sword", 1, "Bag1", {"Augment1", "Augment2"})
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

-- ===========================================================================================================
--                              State Management and Basic Data Handling
-- ===========================================================================================================
-- Update the SharedFunctions.altState object with the current state values.
-- This function updates each field of the SharedFunctions.altState object with the corresponding value from the state object.
-- If a state field does not exist or its value is nil, the corresponding SharedFunctions.altState field is set to nil.
-- @function update_SharedFunctions.altState
-- @param None
-- @return None
-- @usage
-- update_SharedFunctions.altState()
function update_altState()
    assert(type(state) == 'table', "state is not a table")

    -- Update a specific field of the SharedFunctions.altState object.
    -- This internal function is used to update a specific field of the SharedFunctions.altState object.
    -- @local
    -- @param stateField (string) The field of the state object to use for the update.
    -- @param altStateField (string) The field of the SharedFunctions.altState object to update.
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

--- Retrieves the ID and name of the current target.
-- @return (number, string): The ID and name of the current target, or nil if no target is selected.
-- @usage This function relies on the `windower.ffxi.get_mob_by_target` function to get the current target.
-- If this function doesn't behave as expected, it could potentially lead to issues.
function get_current_target_id_and_name()
    local status, target = pcall(windower.ffxi.get_mob_by_target, 'lastst')
    if not status or not target then
        return nil, nil
    end
    return target.id, target.name
end

--- Checks if the player is incapacitated by any defined buffs.
-- If incapacitated, it cancels the spell, marks the event as handled, reverts to the previous gear set, and notifies the player.
-- @param spell (table): The spell currently being cast. It should be a table with `action_type` and `name` fields.
-- @param eventArgs (table): A table that can be used to pass additional event arguments. It should have a `handled` field.
-- @return (boolean): true if the player is incapacitated, false otherwise.
-- @return (string or nil): The type of incapacitation if the player is incapacitated, nil otherwise.
function incapacitated(spell, eventArgs)
    -- Validate inputs
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.action_type or not spell.name then
        return false, "Invalid inputs"
    end

    -- Check for silence or mute
    if (spell.action_type == 'Ability' or spell.action_type == 'Item') and (buffactive['silence'] or buffactive['mute']) then
        return false, nil
    end

    -- Check for incapacitating buffs
    if next(buffactive) then
        for buff in pairs(buffactive) do
            if SharedFunctions.incapacitating_buffs_set[buff] then
                -- Handle errors in cancel_spell
                local success, error = pcall(cancel_spell)
                if not success then
                    return false, "Error in cancel_spell: " .. error
                end

                eventArgs.handled = true

                -- Handle errors in add_to_chat and createFormattedMessage
                success, error = pcall(function()
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
-- @return (boolean): true if the party member is found and they have a pet, false otherwise.
-- @usage This function relies on the `party` table, which should be a list of party members.
-- Each party member should be a table with a `mob` property, which should also be a table with `name` and `pet_index` properties.
-- If these don't behave as expected, it could potentially lead to issues.
-- @error Raises an error if `name` is not a string, if `party` is not a table, if a party member is not a table, or if `mob` is not a table.
function find_member_and_pet_in_party(name)
    if type(name) ~= 'string' then
        error("name must be a string")
    end
    if type(party) ~= 'table' then
        error("party must be a table")
    end
    for i, member in ipairs(party) do
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
-- @param tbl (table): The table to search in. This parameter is mandatory.
-- @param element (any): The element to search for in the table. This parameter is mandatory.
-- @return (boolean): true if the element is found in the table, false otherwise.
-- @usage This function iterates over the provided table and checks for the presence of the specified element.
-- It checks the types of its parameters to avoid issues.
-- @error Raises an error if `tbl` is not a table or if `element` is nil.
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
-- @param {number} category - The category of the action.
-- @param {number} param - The specific action within the category.
-- @return {boolean} - Returns true if the action inherently triggers Treasure Hunter, false otherwise.
-- @error Raises an error if `category` or `param` is not a number.
function th_action_check(category, param)
    if type(category) ~= 'number' then
        error("category must be a number")
    end
    if type(param) ~= 'number' then
        error("param must be a number")
    end

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
--- Formats a recast duration into a human-readable string representation.
-- This function takes a recast time value in seconds and returns a string that represents the recast time in a human-readable format.
-- If the recast time is 60 seconds or more, it is formatted as "MM:SS min", where MM is the number of minutes and SS is the number of seconds.
-- If the recast time is less than 60 seconds, it is formatted as "S.S sec", where S.S is the number of seconds with one decimal place.
-- If the recast time is nil, the function returns nil.
-- @param recast (number or nil) : The recast time value in seconds. This parameter can be nil.
-- @return (string or nil) The formatted recast time string, or nil if the recast time is nil.
-- @usage This function is useful for formatting recast times for display in a user interface.
-- @error Raises an error if `recast` is not a number or nil.
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
-- @param startMessage (string) - The message to display at the start.
-- @param spellName (string) - The name of the spell to display.
-- @param recastTime (number, optional) - The recast time of the spell. If nil, the recast time will not be displayed.
-- @param endMessage (string, optional) - The message to display at the end. If nil, no end message will be displayed.
-- @param isLastMessage (boolean) - If true, a separator line will be added at the end of the message.
-- @param isColored (boolean) - If true, the message will be colored.
-- @return (string) - The formatted message.
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
--                                     Spell Casting Functions
-- ===========================================================================================================
--- Checks if a spell can be cast.
-- This function checks if the spell is not nil, if the spell ID is not nil, if the spell is not on cooldown, and if the player is not incapacitated.
-- @param spell (table): The spell to check. It should be a table with `id` and `action_type` fields.
-- @param eventArgs (table): A table that can be used to pass additional event arguments.
-- @return (boolean): true if the spell can be cast, false otherwise.
-- @usage This function is used to check if a spell can be cast before attempting to cast it.
-- It is used in conjunction with the `try_cast_spell` function to handle the casting of spells.
-- @error Raises an error if the incapacitated function does not exist or is not a function.
function can_cast_spell(spell, eventArgs)
    -- Check if the spell or the spell ID is nil
    if spell == nil or spell.id == nil or spell.action_type == nil then
        return false
    end

    -- Check if the incapacitated function exists and is a function
    if type(incapacitated) ~= "function" then
        error("incapacitated function does not exist or is not a function")
    end

    -- Call the incapacitated function to check if the player is incapacitated
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

    -- Check the spell's cooldown
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

    -- If all checks pass, the spell can be cast
    return true
end

--- Attempts to cast a spell if possible.
-- This function checks if the spell can be cast using the `can_cast_spell` function. If the spell can be cast, it returns true. If the spell cannot be cast, it cancels the spell using the `cancel_spell` function and returns false. If an error occurs during this process, it prints the error and returns false.
-- @function try_cast_spell
-- @tparam table spell The spell to attempt to cast. It should be a table with `id` and `action_type` fields.
-- @tparam table eventArgs A table that can be used to pass additional event arguments. It should have a `handled` field.
-- @treturn boolean true if the spell was cast successfully, false otherwise.
-- @usage This function is used to attempt to cast a spell and handle potential errors. It is used in conjunction with the `handle_unable_to_cast` function to handle the casting of spells.
-- @raise Raises an error if the `cancel_spell` function does not exist or is not a function.
function try_cast_spell(spell, eventArgs)
    -- Check if the cancel_spell function exists and is a function
    if type(cancel_spell) ~= "function" then
        error("cancel_spell function does not exist or is not a function")
    end

    -- Try to cast the spell and handle potential errors
    local status, result_or_err = pcall(function()
        if not can_cast_spell(spell, eventArgs) then
            cancel_spell()
            return false
        end
        return true
    end)

    -- If an error occurred, print the error and return false
    if not status then
        print(result_or_err) -- Print the error message
        return false
    end

    return result_or_err
end

--- Handles the scenario when a spell cannot be cast.
-- If the spell cannot be cast, the function cancels the spell, marks the event as handled,
-- reverts to the previous gear set, and sends a chat message.
-- @function handle_unable_to_cast
-- @tparam table spell The spell to attempt to cast. It should be a table with `id` and `action_type` fields.
-- @tparam table eventArgs A table that can be used to pass additional event arguments. It should have a `handled` field.
-- @usage This function is used in the event handling system to handle the scenario when a spell cannot be cast. It is typically called when a spell casting event is triggered and the `can_cast_spell` function returns false.
function handle_unable_to_cast(spell, eventArgs)
    if not try_cast_spell(spell, eventArgs) then
        cancel_spell()
        eventArgs.handled = true
        -- Revert to the previous gear set if the spell cannot be cast
        job_handle_equipping_gear(playerStatus, eventArgs)
        add_to_chat(167, createFormattedMessage('Cannot Use:', spell.name, nil, value, true, true))
    end
end

function checkDisplayCooldown(spell, eventArgs)
    -- Check argument types
    assert(type(spell) == 'table', "Error: spell is not a table")
    assert(type(eventArgs) == 'table', "Error: eventArgs is not a table")

    -- Check required keys in spell
    local requiredKeys = { 'name', 'type', 'action_type', 'id' }
    for _, key in ipairs(requiredKeys) do
        assert(spell[key], "Error: spell does not have a '" .. key .. "' key")
    end

    -- Check for ignored spells or certain types of spells and abilities
    local ignoredOrSpecialTypes = table.contains(SharedFunctions.ignoredSpells, spell.name) or
        spell.skill == 'Elemental Magic' or
        spell.type == 'Scholar' or
        spell.action_type == 'Weapon Skill'
    if ignoredOrSpecialTypes then return end

    -- Initialize recast time
    local recast = 0

    -- Get recast time from the appropriate list based on action type
    local status, recasts
    if spell.action_type == 'Magic' then
        status, recasts = pcall(windower.ffxi.get_spell_recasts)
        if status and type(recasts) == 'table' and recasts[spell.id] then
            recast = recasts[spell.id] / 60 -- Convert recast time to seconds
        end
    elseif spell.action_type == 'Ability' then
        status, recasts = pcall(windower.ffxi.get_ability_recasts)
        if status and type(recasts) == 'table' and recasts[spell.recast_id] then
            recast = recasts[spell.recast_id]
        end
    end

    -- If the spell or ability is not ready, cancel it and display the recast time
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
-- If the spell has not been cancelled and can be cast, the function checks if there is an associated auto-ability function and calls it.
-- @function handle_spell
-- @tparam table spell The spell object to attempt to cast. It should be a table with `name` and `target.type` fields.
-- @tparam table eventArgs The event arguments object. It should have a `handled` field.
-- @tparam table auto_abilities The table of auto-abilities. It should map spell names to functions.
-- @treturn nil This function does not return a value.
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
-- This function attempts to cast a spell, and if the spell can be cast, it checks if an ability is ready and not active.
-- If the ability is ready and not active, it cancels the current spell, uses the ability, waits for a specified amount of time, and then casts the spell.
-- If the spell cannot be cast, it calls `handle_unable_to_cast` and marks the event as handled.
-- @function auto_ability
-- @tparam table spell The spell object to attempt to cast. It should be a table with `name` and `target.id` fields.
-- @tparam table eventArgs The event arguments object. It should have a `handled` field.
-- @tparam number abilityId The ID of the ability to use before the spell.
-- @tparam number waitTime The amount of time to wait after using the ability and before casting the spell.
-- @tparam string abilityName The name of the ability to use before the spell.
-- @usage This function is used in the event handling system to automatically use abilities before casting spells.
function auto_ability(spell, eventArgs, abilityId, waitTime, abilityName)
    -- Check input arguments
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or type(abilityId) ~= 'number' or type(waitTime) ~= 'string' or type(abilityName) ~= 'string' then
        return
    end

    if try_cast_spell(spell, eventArgs) then
        local abilityCooldown
        -- Handle potential errors when calling windower.ffxi.get_ability_recasts()
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
-- This function checks that the `spell` and `eventArgs` are tables and that `spell` has a `name` property.
-- It then calls `job_handle_equipping_gear` and `add_to_chat` using `pcall` to handle any errors.
-- If an error occurs in either function, it prints an error message and returns `false`.
-- If no errors occur, it marks the event as handled by setting `eventArgs.handled` to `true` and returns `true`.
-- @param spell The spell that was interrupted. This should be a table with a `name` property.
-- @param eventArgs The event arguments. This should be a table.
-- @return `true` if the function completed successfully, `false` otherwise.
-- @function handleInterruptedSpell
function handleInterruptedSpell(spell, eventArgs)
    -- Check that spell and eventArgs are tables and that spell has a name property
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or type(spell.name) ~= 'string' then
        return false
    end

    -- Use pcall to call job_handle_equipping_gear and handle any errors
    local success, message = pcall(job_handle_equipping_gear, playerStatus, eventArgs)
    if not success then
        return false
    end

    -- Mark the event as handled
    eventArgs.handled = true

    -- Use pcall to call add_to_chat and handle any errors
    success, message = pcall(add_to_chat, 123,
        createFormattedMessage('[Spell interrupted]:', spell.name, nil, nil, true, nil))
    if not success then
        return false
    end

    return true
end

--- Handles actions to be performed after a spell has been successfully cast.
-- This function checks that the `spell` and `eventArgs` are tables.
-- It then checks if the Moving state is true and if so, calls `send_command` using `pcall` to handle any errors.
-- If an error occurs in `send_command`, it prints an error message and returns `false`.
-- If no errors occur, it returns `true`.
-- @param spell The spell that has been successfully cast. This should be a table.
-- @param eventArgs Additional event arguments. This should be a table.
-- @return `true` if the function completed successfully, `false` otherwise.
-- @function handleCompletedSpell
function handleCompletedSpell(spell, eventArgs)
    -- Check that spell and eventArgs are tables
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if state.Moving.value == 'true' then
        -- Use pcall to call send_command and handle any errors
        local success, message = pcall(send_command, 'gs equip sets.MoveSpeed')
        if not success then
            return false
        end
    end

    return true
end

--- Handles actions to be performed after a spell has been cast.
-- This function checks that the `spell` and `eventArgs` are tables.
-- It then checks if the spell was interrupted or completed and calls the appropriate handler function using `pcall` to handle any errors.
-- If an error occurs in the handler function, it prints an error message and returns `false`.
-- If no errors occur, it returns `true`.
-- @param spell The spell that has been cast. This should be a table.
-- @param eventArgs Additional event arguments. This should be a table.
-- @return `true` if the function completed successfully, `false` otherwise.
-- @function handleSpellAftercast
function handleSpellAftercast(spell, eventArgs)
    -- Check that spell and eventArgs are tables
    if type(spell) ~= 'table' or type(eventArgs) ~= 'table' or not spell.name then
        return false
    end

    if spell.interrupted then
        -- Use pcall to call handleInterruptedSpell and handle any errors
        local success, message = pcall(handleInterruptedSpell, spell, eventArgs)
        if not success then
            return false
        end
    else
        -- Use pcall to call handleCompletedSpell and handle any errors
        local success, message = pcall(handleCompletedSpell, spell, eventArgs)
        if not success then
            return false
        end
    end

    return true
end

--- Casts a sequence of spells on a target.
-- This function checks that the `spells` is a table.
-- It then gets the current target id and name using `get_current_target_id_and_name` and sends a command to cast each spell on the current target.
-- If the spell is 'phalanx2', the main player is the target, and the main player's job is 'PLD',
-- both 'phalanx' and 'phalanx2' are cast.
-- @param spells A table of spells to cast. Each spell is a table with a 'name' and a 'delay'.
-- @return `true` if the function completed successfully, `false` otherwise.
-- @function applySpellSequenceToTarget
function applySpellSequenceToTarget(spells)
    -- Check that spells is a table and not empty
    if type(spells) ~= 'table' or #spells == 0 then
        return false
    end

    -- Use pcall to call get_current_target_id_and_name and handle any errors
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
            -- Use pcall to call send_command and handle any errors
            local success, message = pcall(send_command, bothPhalanx)
            if not success then
                return false
            end
        else
            -- Use pcall to call send_command and handle any errors
            local success, message = pcall(send_command, command)
            if not success then
                return false
            end
        end
    end

    return true
end

--- Handles the command sequence for a character.
-- This function checks that the `commandType` is a string.
-- It then gets the current target id and name using `get_current_target_id_and_name` and defines a sequence of spells based on the command type.
-- It calls the function 'applySpellSequenceToTarget' to apply the spell sequence to the current target.
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'bdd', 'buffrng', 'curaga', 'debuff').
-- @return `true` if the function completed successfully, `false` otherwise.
-- @function bufferRoleForAltRdm
function bufferRoleForAltRdm(commandType)
    -- Check that commandType is a string
    if type(commandType) ~= 'string' then
        return false
    end

    -- Use pcall to call get_current_target_id_and_name and handle any errors
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

    -- Use pcall to call applySpellSequenceToTarget and handle any errors
    local success, message = pcall(applySpellSequenceToTarget, spells)
    if not success then
        return false
    end

    return true
end

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

--- Buffing sequence handler for an alternate Geomancer character in the game.
-- This function retrieves the current target's ID and name, checks the name of the spell to cast,
-- and changes the target to the main player if the spell is a Geo spell that should be cast on the main player.
-- If the 'isEntrust' parameter is true, it sends a command to use the "Entrust" ability before casting the spell.
-- If the 'isGeo' parameter is true, it sends a command to use the "Full Circle" ability before casting the Geo spell.
-- Finally, it sends the command to cast the spell on the appropriate target.
-- @param altSpell (string): The name of the spell to cast.
-- @param isEntrust (boolean): If true, the "Entrust" ability will be used before casting the spell.
-- @param isGeo (boolean): If true, the "Full Circle" ability will be used before casting the Geo spell.
-- @return nil
-- @usage bubbleBuffForAltGeo('Geo-Regen', true, false) -- Casts 'Geo-Regen' using 'Entrust' ability.
-- @function bubbleBuffForAltGeo
function bubbleBuffForAltGeo(altSpell, isEntrust, isGeo)
    -- Check input parameters
    if type(altSpell) ~= 'string' or type(isEntrust) ~= 'boolean' or type(isGeo) ~= 'boolean' then
        error('Invalid input parameters')
    end

    local targetid, targetname = get_current_target_id_and_name()

    -- If targetid or targetname is nil, set them to default values
    if not targetid or not targetname then
        targetid = 0
        targetname = 'NoTarget'
    end

    local spellToCast = altSpell
    local targetForGeo = targetid

    -- Si le sort est dans la liste mainPlayerSpells, changez la cible pour SharedFunctions.mainPlayerName
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

    -- Try to send the command and handle any errors
    local success, error = pcall(send_command, command)
    if not success then
        error('Failed to send command: ' .. error)
    end
end

--- Handles the casting of an alternate spell.
-- This function checks the input parameters, determines the spell to cast, and sends the command to cast the spell.
-- If the player is engaged, the function assists the main player and casts the spell on the target.
-- If the player is not engaged, the function casts the spell on the last targeted monster.
-- @param altSpell The name of the alternate spell to cast. Must be a string.
-- @param altTier The tier of the alternate spell to cast. Must be a string.
-- @param isRaSpell A boolean indicating whether the spell is a Ra spell.
-- @usage handle_altNuke('Fire', 'IV', false) -- Casts Fire IV on the target.
-- @function handle_altNuke
function handle_altNuke(altSpell, altTier, isRaSpell)
    -- Add argument validation
    assert(altSpell ~= '' and altTier ~= '', "Invalid arguments: altSpell and altTier must not be empty strings")

    -- Check input parameters
    assert(type(altSpell) == 'string' and (altTier == nil or type(altTier) == 'string') and type(isRaSpell) == 'boolean',
        'Invalid input parameters')

    -- Determine the spell to cast
    local spellToCast = altSpell .. (isRaSpell and ' III' or altTier)

    -- Get the current target's ID and name
    local targetid, targetname = get_current_target_id_and_name()

    -- If the player is engaged
    if player.status == 'Engaged' then
        -- If there is a target
        if targetid then
            -- Try to send the command to assist the main player and cast the spell on the target
            local success, err = pcall(send_command,
                'send ' ..
                SharedFunctions.altPlayerName ..
                ' /assist <' ..
                SharedFunctions.mainPlayerName ..
                '>; wait 1; send ' .. SharedFunctions.altPlayerName .. ' ' .. spellToCast .. ' <t>'
            )
            -- If the command could not be sent, throw an error
            if not success then
                assert(false, 'Failed to send command: ' .. (err or 'Unknown error'))
            end
        end
    else
        -- If the player is not engaged, try to cast the spell on the last targeted monster
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

--- Casts an elemental spell.
-- This function takes a main spell and an optional tier, concatenates them to form the full spell name, and sends a command to cast the spell.
-- It checks the input parameters and handles errors that might occur when sending the command.
-- @param mainSpell The name of the main spell to cast. Must be a string and not nil.
-- @param tier The tier of the spell to cast. Must be a string or nil.
-- @usage castElementalSpells('Fire', ' II') -- Casts Fire II.
-- @function castElementalSpells
function castElementalSpells(mainSpell, tier)
    -- Check that mainSpell is a string and not nil
    assert(type(mainSpell) == 'string' and mainSpell ~= nil, 'Invalid mainSpell parameter')

    -- Check that tier is a string or nil
    assert(tier == nil or type(tier) == 'string', 'Invalid tier parameter')

    -- Concatenate the main spell and the tier to form the full spell name
    local spell = mainSpell
    if tier then
        spell = spell .. tier
    end

    -- Call send_command and check for errors
    local success, err = pcall(function() send_command('input /ma "' .. spell .. '" <stnpc>') end)
    assert(success, 'Failed to send command: ' .. tostring(err))
end

--- Casts arts or addendum.
-- This function checks the type of `arts` and `addendum` parameters and throws an error if they are not strings or are nil.
-- It then checks if the `arts` buff is active. If it is not, it sends a command to cast `arts`. If it is, it sends a command to cast `addendum`.
-- It also checks for errors when sending the command and throws an error if one occurs.
-- @param arts The name of the arts to cast. Must be a string and not nil.
-- @param addendum The name of the addendum to cast. Must be a string and not nil.
-- @usage castArtsOrAddendum('Light Arts', 'Addendum: White') -- Casts Light Arts if it is not active, otherwise casts Addendum: White.
-- @function castArtsOrAddendum
function castArtsOrAddendum(arts, addendum)
    -- Check that arts is a string and not nil
    assert(type(arts) == 'string' and arts ~= nil, 'Invalid arts parameter')

    -- Check that addendum is a string and not nil
    assert(type(addendum) == 'string' and addendum ~= nil, 'Invalid addendum parameter')

    local command
    if not buffactive[arts] then
        command = 'input /ja "' .. arts .. '" <me>'
    else
        command = 'input /ja "' .. addendum .. '" <me>'
    end

    -- Call send_command and check for errors
    local success, err = pcall(function() send_command(command) end)
    assert(success, 'Failed to send command: ' .. tostring(err))
end

--- Casts a Scholar spell with the appropriate arts and addendum.
-- @param spell (string): The name of the spell to cast.
-- @param arts (string): The name of the art to use (e.g., "Light Arts" or "Dark Arts").
-- @param addendum (string): The name of the addendum to use (e.g., "Addendum: White" or "Addendum: Black").
-- This function checks if the appropriate addendum is active. If not, it casts the art and addendum before casting the spell.
-- If the addendum is active, it casts the spell directly.
-- If the art is active but not the addendum, and a stratagem is available, it casts the addendum and then the spell.
-- If a stratagem is available, it casts the art, then the addendum, then the spell.
function castSchSpell(spell, arts, addendum)
    -- Validate input parameters
    assert(type(spell) == 'string', "Invalid parameters. 'spell' must be a string.")
    assert(type(arts) == 'string', "Invalid parameters. 'arts' must be a string.")
    assert(type(addendum) == 'string', "Invalid parameters. 'addendum' must be a string.")

    local delay = (spell == 'Sneak' or spell == 'Invisible') and 1 or 2.1
    local targetid, targetname = get_current_target_id_and_name()

    -- Check if the required functions and variables are available
    assert(send_command, "Required function 'send_command' is not available.")
    assert(buffactive, "Required variable 'buffactive' is not available.")
    assert(stratagems_available, "Required function 'stratagems_available' is not available.")
    assert(add_to_chat, "Required function 'add_to_chat' is not available.")

    local command
    if buffactive[addendum] then
        command = 'input /ma "' .. spell .. '" ' .. targetid
    elseif buffactive[arts] and not buffactive[addendum] then
        assert(stratagems_available(), "Aucun stratagème n'est disponible.")
        command = 'input /ja "' .. addendum .. '" <me>; wait 2; input /ma "' .. spell .. '" ' .. targetid
    elseif stratagems_available() then
        command = 'input /ja "' ..
            arts ..
            '" <me>; wait 2; input /ja "' ..
            addendum .. '" <me>; wait ' .. delay .. '; input /ma "' .. spell .. '" ' .. targetid
    else
        add_to_chat(123, "Aucun stratagème n'est disponible.")
        return
    end

    -- Send the command and handle potential errors
    local success, err = pcall(function() send_command(command) end)
    assert(success, "Failed to send command: " .. tostring(err))
end

--- Handles Black Mage (BLM) commands based on the given command parameters.
-- This function first checks if the command parameters are valid (i.e., they form a table and contain at least one element, and the first element is a string).
-- Then, it defines a table of spells, where each key is a command and the value is the function to execute for that command.
-- Finally, it executes the function corresponding to the given command, or throws an error if no matching command is found.
-- @function handle_blm_commands
-- @param cmdParams A table containing the command parameters. The first element should be a string representing the command.
-- @usage handle_blm_commands({'mainlight'}) -- Executes the function for the 'mainlight' command.
-- @usage handle_blm_commands({'unknown'}) -- Throws an error "Unknown command: unknown".
-- @within SharedFunctions
function handle_blm_commands(cmdParams)
    -- Check if cmdParams is a table and contains at least one element
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        error("Invalid command parameters.")
    end

    -- Check if cmdParams[1] is a string
    if type(cmdParams[1]) ~= 'string' then
        error("Command must be a string.")
    end

    local cmd = cmdParams[1]:lower()

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

    -- If the command is in the spells table, execute it
    if spells[cmd] then
        spells[cmd]()
    end
end

--- This function handles the commands specific to the Scholar (SCH) subjob.
-- @param cmdParams: A table where the first element is the command to be executed.
function handle_sch_subjob_commands(cmdParams)
    -- Check if cmdParams is a table and contains at least one element
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        error("Invalid command parameters.")
    end

    -- Check if cmdParams[1] is a string
    if type(cmdParams[1]) ~= 'string' then
        error("Command must be a string.")
    end

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

--- Handles the commands specific to the Warrior (WAR) job.
-- This function checks if the command parameters are valid, converts the command to lower case for case-insensitive matching,
-- and then executes the corresponding function from the `warCommands` table if it exists.
-- The `warCommands` table defines the following commands:
-- * `berserk`: If 'Defender' is active, cancel it and activate 'Berserk'.
-- * `defender`: If 'Berserk' is active, cancel it and activate 'Defender'. Also, if the hybrid mode is 'Normal', set it to 'PDT'.
-- * `thirdeye`: Execute the 'ThirdEye' function.
-- * `jump`: Execute the 'jump' function.
-- @param cmdParams A table where the first element is the command to be executed. The command must be a string.
-- @function handle_war_commands
function handle_war_commands(cmdParams)
    -- Check if cmdParams is a table and has at least one element
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    -- Check if the first element of cmdParams is a string
    if type(cmdParams[1]) ~= 'string' then
        return false
    end

    -- Convert the command to lower case to ensure case-insensitive matching.
    local cmd = cmdParams[1]:lower()

    -- Define a table where each key is a command and the value is the function to execute for that command.
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

    -- If the command exists in the warCommands table, execute the corresponding function.
    if warCommands[cmd] then
        warCommands[cmd]()
        return true
    end

    return false
end

--- Handles the commands specific to the Thief (THF) job.
-- This function checks if the command parameters are valid, converts the command to lower case for case-insensitive matching,
-- and then executes the corresponding function from the `thfCommands` table if it exists.
-- The `thfCommands` table defines the following command:
-- * `thfbuff`: Applies the Thief-specific buff.
-- @param cmdParams A table where the first element is the command to be executed. The command must be a string.
-- @return true if the command was successfully executed, false otherwise.
-- @function handle_thf_commands
function handle_thf_commands(cmdParams)
    -- Check if cmdParams is a table and has at least one element
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    -- Check if the first element of cmdParams is a string
    if type(cmdParams[1]) ~= 'string' then
        return false
    end

    -- Convert the command to lower case for case-insensitive comparison.
    local cmd = cmdParams[1]:lower()

    -- Define a table mapping commands to their corresponding functions.
    local thfCommands = {
        -- 'thfbuff' command applies the Thief-specific buff.
        thfbuff = function()
            buffSelf('thfBuff')
        end
    }

    if thfCommands[cmd] then
        -- Check for errors when calling the command function.
        local status, err = pcall(thfCommands[cmd])
        if status then
            return true
        end
    end

    -- Return false if the command was not recognized or if an error occurred.
    return false
end

--- Adjusts the earring equipment based on the player's TP and the spell being cast.
-- @param spell The spell that the player is casting.
-- @usage
-- adjust_Gear_Based_On_TP_For_WeaponSkill({type = 'WeaponSkill', name = 'Exenterator'})
function adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
    -- Check if the necessary tables and fields exist
    -- If not, throw an error to avoid nil errors
    assert(spell, "Spell is nil")
    assert(sets and sets.precast and sets.precast.WS, "Required tables do not exist")
    assert(player and player.equipment and player.tp, "Player information is not available")

    -- Initialize sets.precast.WS[spell.name] to sets.precast.WS if it does not exist
    -- This avoids nil errors when trying to access sets.precast.WS[spell.name]
    if not sets.precast.WS[spell.name] then
        sets.precast.WS[spell.name] = sets.precast.WS
    end

    -- Adjust the left ear equipment based on the spell name and Treasure Hunter status
    sets.precast.WS[spell.name].left_ear = adjust_Left_Ear_Equipment(spell, player)
end

--- Adjusts the left ear equipment based on the spell name, player's TP, and Treasure Hunter status.
-- @param spell The spell that the player is casting.
-- @param player The player's current status.
-- @return The name of the earring to equip.
function adjust_Left_Ear_Equipment(spell, player)
    -- Check if 'Centovente' is equipped as a sub weapon and player's TP is between 1750 and 2000
    -- or if 'Centovente' is not equipped and player's TP is between 1750 and 2000 or between 2750 and 3000
    -- If so, set the left ear equipment to 'MoonShade Earring'
    -- Otherwise, adjust the left ear equipment based on the spell name and Treasure Hunter status
    if ((player.equipment.sub == 'Centovente' and player.tp >= 1750 and player.tp < 2000) or
            (player.equipment.sub ~= 'Centovente' and ((player.tp >= 1750 and player.tp < 2000) or (player.tp >= 2750 and player.tp < 3000)))) then
        return 'MoonShade Earring'
    else
        return (spell.name == 'Exenterator') and 'Dawn Earring' or
            ((spell.name == 'Aeolian Edge' and treasureHunter ~= 'None') and 'Sortiarius Earring' or
                (spell.name == 'Aeolian Edge' and 'Sortiarius Earring' or 'Sherida Earring'))
    end
end

--- Refines the casting of Utsusemi spells based on their cooldown status.
-- This function checks the cooldown status of Utsusemi: Ni and Utsusemi: Ichi. If the player is casting Utsusemi: Ni
-- but it is on cooldown, the function cancels the casting and tries to cast Utsusemi: Ichi instead if it is not on cooldown.
-- If both spells are on cooldown, the function displays a message.
-- @param spell The spell that the player is casting. This parameter should be a table with a 'name' field.
-- @param eventArgs Event arguments that can be modified to change the behavior of the casting. This parameter should be a table.
-- @usage
-- refine_Utsusemi(spell, eventArgs)
function refine_Utsusemi(spell, eventArgs)
    -- Check if spell and eventArgs are not nil and have the appropriate fields
    assert(spell ~= nil and type(spell) == 'table' and spell.name ~= nil,
        'Invalid spell: spell must be a table with a name field')
    assert(eventArgs ~= nil and type(eventArgs) == 'table', 'Invalid eventArgs: eventArgs must be a table')

    -- Get the current cooldown status of all spells
    local spell_recasts = windower.ffxi.get_spell_recasts()

    -- Check if spell_recasts is not nil
    assert(spell_recasts ~= nil, 'Failed to get spell recasts')

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
    -- If the player is casting Utsusemi: Ichi
    if spell.name == 'Utsusemi: Ichi' then
        -- If Utsusemi: Ichi is on cooldown
        if IchiCD > 1 then
            -- Cancel the casting of Utsusemi: Ichi
            eventArgs.cancel = true
        end
    end
end

-- ===========================================================================================================
--                                     Equipment Management Functions
-- ===========================================================================================================
--- Checks and equips the correct weapon set based on the player's main job and the weapon type.
-- @param weaponType The type of weapon to check. Must be 'main' or 'sub'.
-- @error If the player is not defined, if the player's main job is not defined, if the weapon type is not valid, if the necessary state variables are not defined, or if one of the weapon sets does not exist.
function check_weaponset(weaponType)
    -- Check if player is defined
    assert(player ~= nil, 'player is nil')

    -- Check if player.main_job is not nil
    assert(player.main_job ~= nil, 'player.main_job is nil')

    -- Check if weaponType is valid
    assert(weaponType == 'main' or weaponType == 'sub', 'Invalid weaponType: ' .. tostring(weaponType))

    if player.main_job == 'THF' then
        -- Check if state variables are not nil
        assert(state.AbysseaProc ~= nil and state.WeaponSet2 ~= nil and state.WeaponSet1 ~= nil and state.SubSet ~= nil,
            'state.AbysseaProc, state.WeaponSet2, state.WeaponSet1, or state.SubSet is nil')

        -- Check if sets exist
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
    elseif player.main_job ~= 'BLM' then
        -- Check if state variables are not nil
        assert(state.WeaponSet ~= nil and state.SubSet ~= nil, 'state.WeaponSet or state.SubSet is nil')

        -- Check if sets exist
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
-- This function checks if the player, player.equipment, and player.equipment.range exist.
-- If they do, it checks if a ranged weapon is equipped. If a ranged weapon is equipped, it disables the range and ammo slots.
-- If no ranged weapon is equipped, it enables the range and ammo slots.
-- If player, player.equipment, or player.equipment.range do not exist, it raises an error.
-- @function check_range_lock
function check_range_lock()
    -- Check if player, player.equipment, and player.equipment.range exist
    assert(player and player.equipment and player.equipment.range,
        'player, player.equipment, or player.equipment.range is nil')

    if player.equipment.range ~= 'empty' then
        -- Try to disable the range and ammo slots if a ranged weapon is equipped.
        local status, err = pcall(disable, 'range', 'ammo')
        if not status then
            err = err or 'Unknown error'
            assert(status, 'Failed to disable range and ammo slots: ' .. err)
        end
    else
        -- Try to enable the range and ammo slots if no ranged weapon is equipped.
        local status, err = pcall(enable, 'range', 'ammo')
        if not status then
            err = err or 'Unknown error'
            err = type(err) == "table" and table.concat(err, ", ") or err
            assert(status, 'Failed to enable range and ammo slots: ' .. err)
        end
    end
end

--- Resets the player's equipment to its default state.
-- This function first checks the player's status. If the player is in 'Event', 'Mount', 'Crafting', or 'Resting', the function returns without doing anything.
-- Next, it checks that the player's status is 'Engaged' or 'Idle', and that the necessary equipment sets exist.
-- It then determines the base equipment set based on the player's status.
-- If the player is moving and not engaged, the base equipment set is combined with the MoveSpeed equipment set.
-- Finally, it checks the HybridMode state and adjusts the equipment set accordingly before equipping the player with the final equipment set.
-- @function reset_to_default_equipment
function reset_to_default_equipment()
    -- Check if the necessary equipment sets exist
    assert(sets.engaged ~= nil and sets.idle ~= nil and sets.MoveSpeed ~= nil, 'Necessary equipment set is nil')

    -- Determine the base equipment set based on the player's status
    local baseSet = player.status == 'Engaged' and sets.engaged or sets.idle

    -- Check the Moving state and adjust the baseSet if necessary
    if state.Moving.value == 'true' and player.status ~= 'Engaged' then
        baseSet = set_combine(baseSet, sets.MoveSpeed)
    end

    -- Check the HybridMode state
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
-- This function checks the player's state and the event arguments, and adjusts the player's equipment accordingly.
-- It also checks if certain functions are not `nil` before calling them, to avoid runtime errors.
-- @param playerStatus The player's status.
-- @param eventArgs The event arguments.
-- @function job_handle_equipping_gear
function job_handle_equipping_gear(playerStatus, eventArgs)
    assert(playerStatus == nil or type(playerStatus) == 'string', 'playerStatus must be either nil or a string')
    assert(eventArgs == nil or type(eventArgs) == 'table', 'eventArgs must be either nil or a table')
    assert(state, 'state must not be nil')
    assert(state.Xp == nil or type(state.Xp) == "table", 'state.Xp must be either nil or a table')
    assert(type(reset_to_default_equipment) == 'function', 'reset_to_default_equipment must be a function')
    assert(type(check_weaponset) == 'function', 'check_weaponset must be a function')
    assert(type(check_range_lock) == 'function', 'check_range_lock must be a function')
    -- Checks that `state` and `state.Xp` are not `nil`
    if state and state.Xp and state.Xp.value == 'True' then
        if reset_to_default_equipment then -- Checks that `reset_to_default_equipment` is not `nil`
            reset_to_default_equipment()   -- Resets to the default equipment
        end
    else
        -- Checks and handles equipment set changes for the main weapon.
        if check_weaponset then -- Checks that `check_weaponset` is not `nil`
            check_weaponset('main')
        end
        -- Checks and handles equipment set changes for the sub weapon.
        if check_weaponset then -- Checks that `check_weaponset` is not `nil`
            check_weaponset('sub')
        end
        if reset_to_default_equipment then -- Checks that `reset_to_default_equipment` is not `nil`
            reset_to_default_equipment()   -- Resets to the default equipment
        end
        -- Continues only if the player's main job is 'THF'.
        if player and player.main_job == 'THF' then
            -- Checks if a ranged weapon is equipped and handles the equipment setup accordingly.
            if check_range_lock then -- Checks that `check_range_lock` is not `nil`
                check_range_lock()
            end
        end
    end
end

-- Handles necessary actions when the job state changes.
-- @param field (string): The field that has changed in the job state.
-- @param new_value (any): The new value of the changed field.
-- @param old_value (any): The old value of the changed field.
-- This function is typically called when a job state change event occurs to ensure the correct gear sets are used.
function job_state_change(field, new_value, old_value)
    -- Ensure that check_weaponset is a function
    assert(type(check_weaponset) == 'function', "Error: check_weaponset is not a function")

    -- Ensure that field, new_value, and old_value are not nil
    assert(field ~= nil, "Error: field is nil")
    assert(new_value ~= nil, "Error: new_value is nil")
    assert(old_value ~= nil, "Error: old_value is nil")

    -- Checks and adjusts the main weapon set.
    check_weaponset('main')

    -- Checks and adjusts the sub weapon set.
    check_weaponset('sub')
end

--- @function buff_change
-- Handles changes in buffs.
-- @param buff The name of the buff.
-- @param gain Whether the buff was gained or lost.
function buff_change(buff, gain)
    -- Ensure that buff and gain are not nil
    assert(buff ~= nil, "Error: buff is nil")
    assert(gain ~= nil, "Error: gain is nil")

    local equip_set = {}
    local isMoving = state.Moving.value == 'true'
    local isTHFOrBLM = player.main_job == 'THF' or player.main_job == 'BLM'
    local isSneakOrTrick = buff == 'Sneak Attack' or buff == 'Trick Attack'
    local isBuffActive = state.Buff[buff]

    if buff == 'doom' then
        if gain then
            equip_set = sets.buff.Doom
            disable('neck')
            add_to_chat(123, createFormattedMessage('WARNING:', 'Doom', nil, 'is active!', true, nil))
            send_command('input /p [DOOM] <call21>')
        else
            enable('neck')
            send_command('gs c update')
            add_to_chat(123, createFormattedMessage(nil, 'Doom', nil, 'is no longer active!', true, nil))
            send_command('input /p [Doom] Off !')
        end
        if isMoving then
            equip_set = set_combine(equip_set, sets.MoveSpeed)
        end
    end

    if isTHFOrBLM then
        if isBuffActive ~= nil then
            state.Buff[buff] = gain
        end
        if player.main_job == 'BLM' and buff == 'Mana Wall' then
            if gain then
                equip_set = sets.precast.JA['Mana Wall']
                disable('back', 'feet')
            else
                enable('back', 'feet')
            end
        end
    end

    if isBuffActive then
        equip_set = set_combine(equip_set, sets.buff[buff] or {})
        if state.TreasureMode and (state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime') then
            equip_set = set_combine(equip_set, sets.TreasureHunter)
        end
    end

    if isSneakOrTrick then
        if gain then
            if state.Buff['Sneak Attack'] and state.Buff['Trick Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])
            else
                equip_set = set_combine(equip_set, sets.buff[buff])
            end
        else
            if state.Buff['Sneak Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Sneak Attack'])
            elseif state.Buff['Trick Attack'] then
                equip_set = set_combine(equip_set, sets.buff['Trick Attack'])
            else
                equip_set = player.status == 'Engaged' and sets.engaged or sets.idle
            end
        end
        if next(equip_set) then
            equip(equip_set)
        end
        if not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack'] then
            job_handle_equipping_gear(playerStatus, eventArgs)
        end
    else
        job_handle_equipping_gear(playerStatus, eventArgs)
    end
end

--- Returns a set based on the first true condition.
-- @param set The default set.
-- @param conditions A table of conditions.
-- @param setTable A table mapping conditions to sets.
-- @return The set corresponding to the first true condition or the default set.
-- @raise Error if parameters are nil or not tables, or if a true condition is not in setTable.
function customize_set(set, conditions, setTable)
    -- Check for null or undefined parameters
    assert(set and conditions and setTable, "Invalid parameters")

    -- Check that conditions and setTable are tables
    assert(type(conditions) == "table" and type(setTable) == "table",
        "Invalid parameters: conditions and setTable must be tables")

    for condition, value in pairs(conditions) do
        if value then
            -- Check that the condition is present in setTable
            assert(setTable[condition], "Invalid condition: " .. condition)
            return setTable[condition]
        end
    end
    return set
end

--- Generates conditions and sets based on the current state.
-- This function generates a table of conditions and a table of sets based on the current state.
-- The conditions are determined by the values of `state.HybridMode`, `state.Xp`, and `state.OffenseMode`.
-- The sets are determined by the input parameters `setPDT_XP`, `setPDT`, `setPDT_ACC`, and `setMDT`.
-- @param setPDT_XP The set to use when the `PDT_XP` condition is true.
-- @param setPDT The set to use when the `PDT` condition is true.
-- @param setPDT_ACC The set to use when the `PDT_ACC` condition is true.
-- @param setMDT The set to use when the `MDT` condition is true.
-- @return conditions A table mapping condition names to their truth values.
-- @return setTable A table mapping condition names to their corresponding sets.
-- @function get_conditions_and_sets
function get_conditions_and_sets(setPDT_XP, setPDT, setPDT_ACC, setMDT)
    -- Check the validity of the parameters
    if (setPDT_XP ~= nil and type(setPDT_XP) ~= 'table') or
        (setPDT ~= nil and type(setPDT) ~= 'table') or
        (setPDT_ACC ~= nil and type(setPDT_ACC) ~= 'table') or
        (setMDT ~= nil and type(setMDT) ~= 'table') then
        error("Invalid parameters: setPDT_XP, setPDT, setPDT_ACC and setMDT must be either nil or tables")
    end

    -- Check that state is a table
    assert(type(state) == "table", "Invalid state: state must be a table")

    -- Check that state.HybridMode and state.OffenseMode are tables
    assert(type(state.HybridMode) == "table" and type(state.OffenseMode) == "table",
        "Invalid state: HybridMode and OffenseMode must be tables")

    -- Check that state.HybridMode.value and state.OffenseMode.value are strings
    assert(type(state.HybridMode.value) == "string" and type(state.OffenseMode.value) == "string",
        "Invalid state: HybridMode.value and OffenseMode.value must be strings")

    -- If state.Xp exists and is a table, get its value. Otherwise, set xpValue to 'False'
    local xpValue = type(state.Xp) == "table" and state.Xp.value or 'False'

    -- Check that xpValue is a string
    assert(type(xpValue) == "string", "Invalid state: Xp.value must be a string")

    -- Check that setPDT_XP, setPDT, setPDT_ACC and setMDT are either nil or tables
    assert(
        (setPDT_XP == nil or type(setPDT_XP) == "table") and
        (setPDT == nil or type(setPDT) == "table") and
        (setPDT_ACC == nil or type(setPDT_ACC) == "table") and
        (setMDT == nil or type(setMDT) == "table"),
        "Invalid parameters: setPDT_XP, setPDT, setPDT_ACC and setMDT must be either nil or tables")

    local conditions = {
        ['PDT_XP'] = state.HybridMode.value == 'PDT' and xpValue == 'True',
        ['PDT'] = state.HybridMode.value == 'PDT' and xpValue == 'False',
        ['PDT_ACC'] = state.HybridMode.value == 'PDT' and state.OffenseMode.value == 'Acc',
        ['MDT'] = state.HybridMode.value == 'MDT' and xpValue == 'False',
    }

    local setTable = {
        ['PDT_XP'] = setPDT_XP,
        ['PDT'] = setPDT,
        ['PDT_ACC'] = setPDT_ACC,
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
    assert(player, "Erreur : l'objet 'player' n'est pas défini.")
    assert(type(player.main_job) == 'string', "Erreur : 'player.main_job' n'est pas une chaîne.")
    assert(type(player.sub_job) == 'string', "Erreur : 'player.sub_job' n'est pas une chaîne.")
    assert(type(player.main_job_level) == 'number', "Erreur : 'player.main_job_level' n'est pas un nombre.")
    assert(type(player.sub_job_level) == 'number', "Erreur : 'player.sub_job_level' n'est pas un nombre.")

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
-- The recast time depends on the player's job level. If the player's main job is 'SCH',
-- the main job level is used. Otherwise, the sub job level is used. The recast time
-- decreases as the job level increases.
-- @return number: The recast time for a stratagem in seconds.
-- @usage
-- -- Get the recast time for a stratagem
-- local recast_time = get_stratagem_recast_time()
-- print("The recast time for a stratagem is " .. recast_time .. " seconds.")
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
-- The number of available stratagems is calculated based on the recast time of the Stratagem ability and the maximum number of stratagems available.
-- @return number: The number of available SCH stratagems.
-- @usage
-- -- Get the number of available stratagems
-- local available_stratagems = get_available_stratagem_count()
-- print("The number of available stratagems is " .. available_stratagems)
function get_available_stratagem_count()
    -- Get the recast time of the Stratagem ability (ID 231)
    local recastTime = windower.ffxi.get_ability_recasts()[231] or 0
    assert(type(recastTime) == 'number', "Error: 'recastTime' is not a number.")

    -- Get the maximum number of stratagems available
    local maxStrats = get_max_stratagem_count()
    assert(type(maxStrats) == 'number', "Error: 'maxStrats' is not a number.")

    -- If no stratagems are available, return 0
    if maxStrats == 0 then
        return 0
    end

    -- Calculate the number of stratagems used
    local stratagemRecastTime = get_stratagem_recast_time()
    assert(type(stratagemRecastTime) == 'number', "Error: 'stratagemRecastTime' is not a number.")

    local stratsUsed = recastTime > stratagemRecastTime and math.ceil(recastTime / stratagemRecastTime) or 0

    -- If recastTime is equal to stratagemRecastTime, set stratsUsed to 0
    if recastTime == stratagemRecastTime then
        stratsUsed = math.floor(recastTime / stratagemRecastTime)
    end

    -- Return the number of stratagems available
    return math.max(0, maxStrats - stratsUsed)
end

-- Checks if there are any Scholar (SCH) stratagems available for use.
-- @return boolean: True if there are stratagems available, false otherwise.
function stratagems_available()
    -- Check that get_available_stratagem_count is a function
    assert(type(get_available_stratagem_count) == 'function', "Error: 'get_available_stratagem_count' is not a function.")

    -- Call get_available_stratagem_count and check that it returns a number
    local stratagem_count = get_available_stratagem_count()
    assert(type(stratagem_count) == 'number', "Error: 'get_available_stratagem_count' did not return a number.")

    return stratagem_count > 0
end

-- Define a set of commands and their corresponding handlers
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
        return handle_altNuke(state.altPlayerLight.value, state.altPlayerTier.value, false) -- for 'altLight'
    end,
    altdark = function()
        assert(type(handle_altNuke) == 'function', "Error: 'handle_altNuke' is not a function.")
        return handle_altNuke(state.altPlayerDark.value, state.altPlayerTier.value, false) -- for 'altDark'
    end,
    altra = function()
        assert(type(handle_altNuke) == 'function', "Error: 'handle_altNuke' is not a function.")
        return handle_altNuke(state.altPlayera.value, nil, true) -- for 'altRa'
    end,
    altindi = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Indi, false, false) -- for 'altIndi'
    end,
    altentrust = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Entrust, true, false) -- for 'altEntrust'
    end,
    altgeo = function()
        assert(type(bubbleBuffForAltGeo) == 'function', "Error: 'bubbleBuffForAltGeo' is not a function.")
        return bubbleBuffForAltGeo(SharedFunctions.altState.Geo, false, true) -- for 'altGeo'
    end,
}

--- Checks if a spell of type "WeaponSkill" is within range of the target.
-- @param spell table: A table containing information about the spell. Must include 'type', 'range', 'target' fields.
-- 'target' should be a table containing 'distance' and 'model_size' fields.
-- @return Nothing if the spell is within range, otherwise cancels the spell and displays a message in the chat.
-- @usage Ws_range(spell) -- where 'spell' is a table containing information about the spell.
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
            local message = createFormattedMessage("[Cancel]", spell.name, nil, "Too Far !", isLastMessage, isColored)
            add_to_chat(057, message)
            return
        end
    end
end

return SharedFunctions
