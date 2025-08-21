---============================================================================
--- FFXI GearSwap Messages - Formatting and Color Utilities
---============================================================================
--- Core formatting utilities for message display including color codes,
--- duration formatting, and text styling utilities.
---
--- @file messages/MESSAGE_FORMATTING.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires config/config
---============================================================================

local MessageFormatting = {}

-- Load critical dependencies
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

-- ===========================================================================================================
--                                     Color Constants and Codes
-- ===========================================================================================================


--- CODES COULEURS STANDARDISÉS FFXI
MessageFormatting.STANDARD_COLORS = {
    -- Couleurs de base
    WHITE = 001,      -- Blanc (info générale)
    GRAY = 160,       -- Gris-violet (debug/separateurs)
    LIGHT_GRAY = 166, -- Gris-beige (texte secondaire)

    -- Couleurs par type d'action
    JOB_NAME = 207,    -- Bleu clair (noms de jobs)
    MAGIC = 005,       -- Cyan (sorts/magie)
    ABILITY = 050,     -- Jaune (job abilities)
    WEAPONSKILL = 167, -- Rouge-rose (weapon skills)

    -- Couleurs de statut
    SUCCESS = 030, -- Vert (succès/actif)
    WARNING = 208, -- Orange (avertissements)
    ERROR = 167,   -- Rouge (erreurs)
    INFO = 003,    -- Bleu (informations)

    -- Couleurs spéciales
    RECAST = 125, -- Rouge foncé (recasts)
    ACTIVE = 158, -- Vert clair (buffs actifs)
    TIME = 123,   -- Jaune pâle (temps/durées)

    -- Couleurs job-spécifiques
    BRD_SONG = 207,     -- Bleu pour les chants BRD
    BRD_ACTIVE = 030,   -- Vert pour les chants actifs
    BRD_ROTATION = 050, -- Jaune pour les rotations

    WAR_BUFF = 050,     -- Jaune pour les buffs WAR
    WAR_ACTIVE = 030,   -- Vert pour les buffs actifs

    THF_ACTION = 158,   -- Vert clair pour les actions THF
    THF_STATUS = 207,   -- Bleu pour le statut

    BLM_SPELL = 005,    -- Cyan pour les sorts BLM
    BLM_TIER = 123,     -- Jaune pour les tiers de sorts
}

-- Legacy color mappings (backward compatibility)
MessageFormatting.colors = {
    GRAY = config.get_color('debug'),
    ORANGE = config.get_color('warning'),
    YELLOW = config.get_color('info'),
    RED = config.get_color('error'),
    GREEN = config.get_color('success')
}

-- ===========================================================================================================
--                                     Color Code Generation
-- ===========================================================================================================

--- Creates a color code string for FFXI chat
-- @param color_number (number): FFXI color code number
-- @return (string): Formatted color code string
function MessageFormatting.create_color_code(color_number)
    if not color_number or type(color_number) ~= 'number' then
        return '' -- Return empty string for invalid input
    end

    -- Ensure color number is within valid FFXI range (1-255)
    if color_number < 1 or color_number > 255 then
        return ''
    end

    -- FFXI uses string.char(0x1F, color_number) for color codes
    return string.char(0x1F, color_number)
end

--- Legacy color code function (backward compatibility)
-- @param color (number): Color code
-- @return (string): Color code string
function MessageFormatting.create_color_code_legacy(color)
    if not color then
        return ""
    end
    -- Use string.char format for FFXI colors
    return string.char(0x1F, color)
end

-- ===========================================================================================================
--                                     Duration and Time Formatting
-- ===========================================================================================================

--- Formats recast duration into human-readable string
-- @param recast (number): Recast time in seconds
-- @return (string): Formatted duration string
function MessageFormatting.format_recast_duration(recast)
    if not recast or type(recast) ~= 'number' then
        return "0s"
    end

    -- Handle negative or zero values
    if recast <= 0 then
        return "Ready"
    end

    -- For very long durations (> 1 hour), show hours
    if recast >= 3600 then
        local hours = math.floor(recast / 3600)
        local minutes = math.floor((recast % 3600) / 60)
        local seconds = recast % 60
        return string.format("%dh %02dm %02ds", hours, minutes, seconds)
    end

    -- For durations > 60 seconds, show MM:SS min format (matching original)
    if recast >= 60 then
        local minutes = math.floor(recast / 60)
        local seconds = math.floor(recast % 60)
        return string.format("%02d:%02d min", minutes, seconds)
    end

    -- For short durations, show seconds with decimal (matching original)
    return string.format("%.1f sec", recast)
end

--- Formats time value with appropriate unit
-- @param time_value (number): Time in seconds
-- @return (string): Formatted time string
function MessageFormatting.format_time_value(time_value)
    if not time_value or type(time_value) ~= 'number' then
        return "0s"
    end

    if time_value < 60 then
        return string.format("%.0fs", time_value)
    elseif time_value < 3600 then
        local minutes = math.floor(time_value / 60)
        local seconds = time_value % 60
        if seconds == 0 then
            return string.format("%dm", minutes)
        else
            return string.format("%dm %ds", minutes, seconds)
        end
    else
        local hours = math.floor(time_value / 3600)
        local minutes = math.floor((time_value % 3600) / 60)
        return string.format("%dh %dm", hours, minutes)
    end
end

-- ===========================================================================================================
--                                     Text Styling Utilities
-- ===========================================================================================================

--- Creates a separator line for visual organization
-- @param char (string): Character to use for separator (default: "=")
-- @param length (number): Length of separator (default: 50)
-- @return (string): Formatted separator string
function MessageFormatting.create_separator(char, length)
    char = char or "="
    length = length or 50
    return string.rep(char, length)
end

--- Formats a job name with consistent styling
-- @param job_name (string): Job name to format
-- @return (string): Formatted job name with color
function MessageFormatting.format_job_name(job_name)
    if not job_name then
        return "UNKNOWN"
    end

    local color = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.JOB_NAME)
    return color .. job_name
end

--- Formats an ability name with appropriate color
-- @param ability_name (string): Ability name
-- @param ability_type (string): Type of ability ("magic", "ability", "weaponskill")
-- @return (string): Formatted ability name
function MessageFormatting.format_ability_name(ability_name, ability_type)
    if not ability_name then
        return "Unknown"
    end

    local color_code
    if ability_type == "magic" then
        color_code = MessageFormatting.STANDARD_COLORS.MAGIC
    elseif ability_type == "weaponskill" then
        color_code = MessageFormatting.STANDARD_COLORS.WEAPONSKILL
    else
        color_code = MessageFormatting.STANDARD_COLORS.ABILITY
    end

    local color = MessageFormatting.create_color_code(color_code)
    return color .. ability_name
end

--- Formats a status message with appropriate color
-- @param status (string): Status type ("success", "error", "warning", "info")
-- @param message (string): Message text
-- @return (string): Formatted status message
function MessageFormatting.format_status_message(status, message)
    if not message then
        return ""
    end

    local color_code
    if status == "success" then
        color_code = MessageFormatting.STANDARD_COLORS.SUCCESS
    elseif status == "error" then
        color_code = MessageFormatting.STANDARD_COLORS.ERROR
    elseif status == "warning" then
        color_code = MessageFormatting.STANDARD_COLORS.WARNING
    else
        color_code = MessageFormatting.STANDARD_COLORS.INFO
    end

    local color = MessageFormatting.create_color_code(color_code)
    return color .. message
end

--- Formats recast time with color coding
-- @param recast_time (number): Recast time in seconds
-- @return (string): Formatted and colored recast time
function MessageFormatting.format_colored_recast(recast_time)
    if not recast_time or recast_time <= 0 then
        local color = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.SUCCESS)
        return color .. "Ready"
    end

    local color = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.RECAST)
    local formatted_time = MessageFormatting.format_recast_duration(recast_time)
    return color .. formatted_time
end

-- ===========================================================================================================
--                                     Legacy Support Functions
-- ===========================================================================================================

--- Legacy formatted message creation (backward compatibility)
-- @param startMessage (string): Start of message
-- @param spellName (string): Spell name
-- @param recastTime (number): Recast time
-- @param endMessage (string): End of message
-- @param isLastMessage (boolean): Whether this is the last message
-- @param isColored (boolean): Whether to apply coloring
-- @return (string): Formatted message
function MessageFormatting.create_formatted_message(startMessage, spellName, recastTime, endMessage, isLastMessage,
                                                    isColored)
    -- Legacy function maintained for backward compatibility
    if not spellName then
        return ""
    end

    local message = (startMessage or "") .. spellName

    if recastTime and recastTime > 0 then
        local formatted_recast = MessageFormatting.format_recast_duration(recastTime)
        message = message .. " (" .. formatted_recast .. ")"
    end

    if endMessage then
        message = message .. endMessage
    end

    if isColored then
        local color_code = MessageFormatting.STANDARD_COLORS.INFO
        local color = MessageFormatting.create_color_code(color_code)
        message = color .. message
    end

    return message
end

-- Export all functions for global access (backward compatibility)
_G.format_recast_duration = MessageFormatting.format_recast_duration
_G.create_color_code = MessageFormatting.create_color_code

return MessageFormatting
