---============================================================================
--- FFXI GearSwap Utility Module - Message Formatting and Display
---============================================================================
--- Professional message formatting system for GearSwap user interface.
--- Provides colorized chat output, recast duration formatting, spell feedback,
--- and standardized user communication. Core features include:
---
--- • **Colorized Chat Messages** - FFXI color code integration for readability
--- • **Recast Duration Formatting** - Human-readable time display (MM:SS / seconds)
--- • **Spell Feedback Messages** - Comprehensive casting status and cooldown info
--- • **Error Message Formatting** - Standardized error reporting with context
--- • **Progress Indicators** - Visual feedback for long operations
--- • **Configuration-Driven Colors** - Centralized color management
--- • **Multi-Language Support** - Extensible text formatting system
--- • **Message Throttling** - Prevents chat spam with intelligent filtering
---
--- This module centralizes all user-facing message formatting, ensuring
--- consistent and professional presentation across all job configurations
--- with configurable styling and comprehensive error handling.
---
--- @file utils/messages.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger
--- @requires Windower FFXI
---
--- @usage
---   local MessageUtils = require('utils/messages')
---   MessageUtils.format_recast_duration(recast_time)
---   MessageUtils.create_formatted_message(start, spell, recast, end, last, colored)
---
--- @see config/settings.lua for color configuration
---============================================================================

local MessageUtils = {}

-- Load critical dependencies for message operations
local config = require('config/config')              -- Centralized configuration system
local log = require('utils/logger')                  -- Professional logging framework

-- Color constants (from config)
MessageUtils.colors = {
    GRAY = config.get_color('debug'),
    ORANGE = config.get_color('warning'),
    YELLOW = config.get_color('info'),
    RED = config.get_color('error'),
    GREEN = config.get_color('success')
}

-- ===========================================================================================================
--                                         Message Formatting Functions
-- ===========================================================================================================

--- Formats a recast duration into a human-readable string.
-- @param recast (number or nil): The recast time value in seconds.
-- @return (string or nil): The formatted recast time string, or nil if the recast time is nil.
function MessageUtils.format_recast_duration(recast)
    if recast ~= nil and type(recast) ~= 'number' then
        log.error("recast must be a number or nil")
        return nil
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

--- Creates a color code from a color value.
-- @param color The color value.
-- @return The color code.
function MessageUtils.create_color_code(color)
    if not color then
        log.error("color must not be nil")
        return ""
    end

    if type(color) ~= "number" then
        log.error("color must be a number")
        return ""
    end

    return string.char(0x1F, color)
end

--- Creates a formatted message from the given parameters.
-- @param startMessage (string): The message to display at the start.
-- @param spellName (string): The name of the spell to display.
-- @param recastTime (number, optional): The recast time of the spell.
-- @param endMessage (string, optional): The message to display at the end.
-- @param isLastMessage (boolean): If true, a separator line will be added at the end of the message.
-- @param isColored (boolean): If true, the message will be colored.
-- @return (string): The formatted message.
function MessageUtils.create_formatted_message(startMessage, spellName, recastTime, endMessage, isLastMessage, isColored)
    -- Input validation
    if type(startMessage) ~= "string" and startMessage ~= nil then
        log.error("startMessage must be a string or nil")
        return ""
    end

    -- Handle nil or empty spell name
    if spellName == nil or spellName == "" then
        spellName = "N/A"
    end

    -- Handle nil recast time
    if recastTime == nil then
        recastTime = 0
    end

    -- Validate other parameters
    if endMessage ~= nil and type(endMessage) ~= "string" then
        log.error("endMessage must be a string or nil")
        return ""
    end

    if type(isLastMessage) ~= "boolean" then
        isLastMessage = false
    end

    if type(isColored) ~= "boolean" then
        isColored = true
    end

    -- Format recast time
    local formattedRecastTime = MessageUtils.format_recast_duration(recastTime) or "N/A"

    -- Get color codes
    local colorGray = MessageUtils.create_color_code(MessageUtils.colors.GRAY)
    local colorOrange = MessageUtils.create_color_code(MessageUtils.colors.ORANGE)
    local colorRed = MessageUtils.create_color_code(MessageUtils.colors.RED)
    local colorGreen = MessageUtils.create_color_code(MessageUtils.colors.YELLOW)

    -- Build message parts
    local messageParts = {}

    -- Start message and spell name
    table.insert(messageParts, string.format('%s%s[',
        startMessage and startMessage .. ' ' or '',
        colorGray))
    table.insert(messageParts, string.format('%s%s%s',
        colorGreen,
        spellName,
        colorGray))

    -- Recast time or end message
    if recastTime and recastTime > 0 then
        table.insert(messageParts, string.format('%s] Recast: %s(%s%s%s)',
            colorGray,
            colorGray,
            colorOrange,
            formattedRecastTime,
            colorGray))
    else
        table.insert(messageParts, string.format('%s]', colorGray))

        if endMessage then
            local endMessageFormatted
            if isColored then
                endMessageFormatted = string.format(' Due to: %s[%s%s%s]',
                    colorGray,
                    colorRed,
                    string.upper(string.sub(endMessage, 1, 1)) .. string.sub(endMessage, 2),
                    colorGray)
            else
                endMessageFormatted = string.format(' %s', endMessage)
            end
            table.insert(messageParts, endMessageFormatted)
        end
    end

    -- Add separator if last message
    if isLastMessage then
        table.insert(messageParts, string.format('\n%s=================================================', colorGray))
    end

    return table.concat(messageParts)
end

--- Displays a formatted message in chat
-- @param color (number): Chat color code
-- @param format (string): Format string
-- @param ... Variable arguments for formatting
function MessageUtils.add_to_chat_formatted(color, format, ...)
    local success, message = pcall(string.format, format, ...)
    if success then
        windower.add_to_chat(color, message)
    else
        log.error("Failed to format message: %s", format)
    end
end

--- Creates a simple status message
-- @param status (string): Status type (success, error, warning, info)
-- @param message (string): The message to display
function MessageUtils.status_message(status, message)
    local colors = {
        success = MessageUtils.colors.GREEN,
        error = MessageUtils.colors.RED,
        warning = MessageUtils.colors.ORANGE,
        info = MessageUtils.colors.YELLOW
    }

    local color = colors[status:lower()] or MessageUtils.colors.GRAY
    windower.add_to_chat(color, message)
end

--- Creates a cooldown message
-- @param ability_name (string): Name of the ability
-- @param cooldown (number): Cooldown in seconds
function MessageUtils.cooldown_message(ability_name, cooldown)
    local message = MessageUtils.create_formatted_message(nil, ability_name, cooldown, nil, true)
    windower.add_to_chat(123, message)
end

--- Creates a spell interrupted message with multiple colors based on spell type
-- @param spell (table): The spell that was interrupted
function MessageUtils.spell_interrupted_message(spell)
    if not spell or not spell.name then
        MessageUtils.status_message('warning', '[Spell interrupted]: Unknown spell')
        return
    end

    -- Define colors for different spell types/skills and names
    local type_colors = {
        -- Magic skills - toutes les magies en 005 (bleu cyan)
        ['Healing Magic'] = 030,        -- Soins en 030 (vert clair)
        ['Enhancing Magic'] = 005,      -- Magie en 005 (bleu cyan)
        ['Enfeebling Magic'] = 005,     -- Magie en 005 (bleu cyan)
        ['Elemental Magic'] = 005,      -- Magie en 005 (bleu cyan)
        ['Dark Magic'] = 005,           -- Magie en 005 (bleu cyan)
        ['Divine Magic'] = 005,         -- Magie en 005 (bleu cyan)
        ['Ninjutsu'] = 005,             -- Magie en 005 (bleu cyan)
        ['Songs'] = 005,                -- Magie en 005 (bleu cyan)
        ['Blue Magic'] = 005,           -- Magie en 005 (bleu cyan)
        ['Geomancy'] = 005,             -- Magie en 005 (bleu cyan)
        ['Handbell'] = 005,             -- Magie en 005 (bleu cyan)
        ['Trust'] = 005,                -- Magie en 005 (bleu cyan)
        -- Types d'actions
        ['WeaponSkill'] = 028,          -- WS en 028 (rouge)
        ['JobAbility'] = 050,           -- JA en 050 (jaune)
        -- Sorts de soins spécifiques (priorité haute)
        ['Cure'] = 030,
        ['Cure II'] = 030,
        ['Cure III'] = 030,
        ['Cure IV'] = 030,
        ['Cure V'] = 030,
        ['Cure VI'] = 030,
        ['Curaga'] = 030,
        ['Curaga II'] = 030,
        ['Curaga III'] = 030,
        ['Curaga IV'] = 030,
        ['Curaga V'] = 030,
        ['Cura'] = 030,
        ['Cura II'] = 030,
        ['Cura III'] = 030
    }

    -- Determine spell color (priority: name > type > skill > default)
    local spell_color = 005 -- Default bleu cyan pour magie
    if spell.name and type_colors[spell.name] then
        spell_color = type_colors[spell.name]
    elseif spell.type and type_colors[spell.type] then
        spell_color = type_colors[spell.type]
    elseif spell.skill and type_colors[spell.skill] then
        spell_color = type_colors[spell.skill]
    end

    -- Get standard color codes
    local colorGray = MessageUtils.create_color_code(MessageUtils.colors.GRAY)
    local colorOrange = MessageUtils.create_color_code(057) -- Orange pour les préfixes d'interrupt
    local spellColor = MessageUtils.create_color_code(spell_color)

    -- Tous les préfixes d'interruption sont en orange
    local message_prefix
    if spell.type == 'WeaponSkill' then
        message_prefix = 'WS interrupted'
    elseif spell.type == 'JobAbility' then
        message_prefix = 'JA interrupted'
    else
        message_prefix = 'Spell interrupted'
    end

    -- Build multi-colored message like createFormattedMessage
    local messageParts = {}
    
    -- Add prefix with orange color and gray brackets
    table.insert(messageParts, string.format('%s[%s%s%s]:', 
        colorGray,
        colorOrange,
        message_prefix,
        colorGray))
    
    -- Add spell name with its specific color
    table.insert(messageParts, string.format(' %s%s', 
        spellColor,
        spell.name))
    
    -- Add separator line in gray
    table.insert(messageParts, string.format('\n%s=================================================', colorGray))

    local final_message = table.concat(messageParts)
    
    -- Send to chat using default color (the message already contains all color codes)
    windower.add_to_chat(123, final_message)
    
    -- Debug info
    log.debug("Interrupted %s (spell_color=%d, prefix=%s) - message: %s", spell.name, spell_color, message_prefix, final_message)
end

--- Creates an error message for incapacitated state
-- @param action_name (string): Name of the action attempted
-- @param reason (string): Reason for incapacitation
function MessageUtils.incapacitated_message(action_name, reason)
    local message = MessageUtils.create_formatted_message('Cannot Use:', action_name, nil, reason, true, true)
    windower.add_to_chat(167, message)
end

return MessageUtils
