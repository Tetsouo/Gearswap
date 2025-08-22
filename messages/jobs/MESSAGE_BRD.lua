---============================================================================
--- FFXI GearSwap Messages - Bard (BRD) Specific Messages
---============================================================================
--- Bard-specific messaging functions for song management, rotations,
--- and performance tracking.
---
--- @file messages/jobs/MESSAGE_BRD.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageBRD = {}

-- Load critical dependencies
local success_core, MessageCore = pcall(require, 'messages/MESSAGE_CORE')
if not success_core then
    error("Failed to load messages/MESSAGE_CORE: " .. tostring(MessageCore))
end

local success_formatting, MessageFormatting = pcall(require, 'messages/MESSAGE_FORMATTING')
if not success_formatting then
    error("Failed to load messages/MESSAGE_FORMATTING: " .. tostring(MessageFormatting))
end

-- Helper function for standardized job names
local function get_standardized_job_name(override_job_name)
    return MessageCore.get_standardized_job_name(override_job_name)
end

-- ===========================================================================================================
--                                     BRD JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates BRD song list message with status information
-- @param song_data (table): Array of song objects with name and status
-- @param title (string): Optional title for the message
function MessageBRD.brd_song_list_message(song_data, title)
    if not song_data or #song_data == 0 then
        return
    end

    local job_name = get_standardized_job_name()
    MessageCore.show_separator("-", 40)

    if title then
        MessageCore.universal_message(job_name, "info", title, nil, nil, nil, MessageFormatting.STANDARD_COLORS.BRD_SONG)
    end

    for _, song in ipairs(song_data) do
        if song.recast and song.recast > 0 then
            MessageCore.universal_message(job_name, "song", song.name, nil, "recast", song.recast,
                MessageFormatting.STANDARD_COLORS.BRD_SONG)
        elseif song.active then
            MessageCore.universal_message(job_name, "song", song.name, "Active", "active", nil,
                MessageFormatting.STANDARD_COLORS.BRD_ACTIVE)
        else
            MessageCore.universal_message(job_name, "song", song.name, "Ready", "ready", nil,
                MessageFormatting.STANDARD_COLORS.SUCCESS)
        end
    end

    MessageCore.show_separator("-", 40)
end

--- Creates BRD singing message with rotation info
-- @param song_name (string): Name of the song being sung
-- @param rotation_count (number): Current rotation count
-- @param max_rotations (number): Maximum rotations
function MessageBRD.brd_singing_message(song_name, rotation_count, max_rotations)
    if not song_name then return end

    local details = ""
    if rotation_count and max_rotations then
        details = string.format("Rotation %d/%d", rotation_count, max_rotations)
    end

    MessageCore.universal_message("BRD", "song", "Singing: " .. song_name, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.BRD_ROTATION)
end

--- Creates BRD rotation completion message
-- @param song_name (string): Name of the completed song
-- @param completion_type (string): Type of completion ("completed", "interrupted", "failed")
function MessageBRD.brd_rotation_complete_message(song_name, completion_type)
    if not song_name or not completion_type then return end

    local color_code
    local status_text
    if completion_type == "completed" then
        color_code = MessageFormatting.STANDARD_COLORS.SUCCESS
        status_text = "Rotation completed"
    elseif completion_type == "interrupted" then
        color_code = MessageFormatting.STANDARD_COLORS.WARNING
        status_text = "Rotation interrupted"
    else
        color_code = MessageFormatting.STANDARD_COLORS.ERROR
        status_text = "Rotation failed"
    end

    MessageCore.universal_message("BRD", "song", song_name, status_text, completion_type, nil, color_code)
end

--- Creates BRD colored message matching original format exactly
-- @param action (string): Action being performed
-- @param details (string): Details about the action
-- @param extra (string): Extra information (optional)
-- @param action_color (number): Color code for action (optional, defaults to 050/yellow)
function MessageBRD.brd_colored_message(action, details, extra, action_color)
    if not action or not details then return end

    action_color = action_color or 050 -- Default yellow

    -- Color codes matching original exactly
    local white = string.char(0x1F, 001)               -- White for brackets and separators
    local action_col = string.char(0x1F, action_color) -- Action color
    local cyan = string.char(0x1F, 005)                -- Cyan for spells/magic
    local orange = string.char(0x1F, 057)              -- Orange for arrows/transitions

    local message = white .. "[" .. action_col .. "BRD" .. white .. "] " ..
        action_col .. action .. white .. ": " ..
        cyan .. details

    if extra then
        message = message .. white .. " " .. orange .. extra
    end

    windower.add_to_chat(001, message)
end

--- Creates BRD general message
-- @param action_type (string): Type of action
-- @param message (string): Message text
-- @param details (string): Details (optional)
function MessageBRD.brd_message(action_type, message, details)
    MessageCore.universal_message("BRD", action_type, message, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.BRD_SONG)
end

--- Creates BRD spell message
-- @param spell_name (string): Name of the spell
-- @param action (string): Action being performed
-- @param details (string): Details about the spell
-- @param spell_type (string): Type of spell (optional)
function MessageBRD.brd_spell_message(spell_name, action, details, spell_type)
    MessageCore.universal_message("BRD", "Magic", spell_name .. " " .. action, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.MAGIC)
end

--- Creates BRD job ability message
-- @param ja_name (string): Name of the job ability
-- @param action (string): Action being performed
-- @param details (string): Details about the ability
function MessageBRD.brd_ja_message(ja_name, action, details)
    MessageCore.universal_message("BRD", "Ability", ja_name .. " " .. action, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

--- Creates BRD debug message
-- @param debug_text (string): Debug text to display
function MessageBRD.brd_debug_message(debug_text)
    if not debug_text then return end
    MessageCore.universal_message("BRD", "Debug", debug_text, nil, nil, nil, MessageFormatting.STANDARD_COLORS.GRAY)
end

--- Creates BRD cooldown message
-- @param ability_name (string): Name of the ability
-- @param cooldown_time (number): Cooldown time in seconds
function MessageBRD.brd_cooldown_message(ability_name, cooldown_time)
    if not ability_name or not cooldown_time then return end
    MessageCore.universal_message("BRD", "Ability", ability_name, nil, "recast", cooldown_time,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

--- Creates BRD song cooldown message
-- @param song_name (string): Name of the song
-- @param cooldown_seconds (number): Cooldown time in seconds
function MessageBRD.brd_song_cooldown_message(song_name, cooldown_seconds)
    if not song_name or not cooldown_seconds then return end
    MessageCore.universal_message("BRD", "Magic", song_name, nil, "recast", cooldown_seconds,
        MessageFormatting.STANDARD_COLORS.MAGIC)
end

--- Creates BRD weapon skill message
-- @param ws_name (string): Name of the weapon skill
-- @param gear_type (string): Type of gear equipped
function MessageBRD.brd_ws_message(ws_name, gear_type)
    if not ws_name then return end
    local details = gear_type and ("Gear: " .. gear_type) or nil
    MessageCore.universal_message("BRD", "WeaponSkill", ws_name, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.WEAPONSKILL)
end

--- Creates BRD song rotation message with separator (matching original format exactly)
-- @param songs (table): Array of song names
-- @param rotation_name (string): Name of the rotation
-- @param show_separator (boolean): Whether to show separator lines
function MessageBRD.brd_song_rotation_with_separator(songs, rotation_name, show_separator)
    if not songs or not rotation_name then return end

    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)  -- Job name (Light Blue)
    local colorSong = string.char(0x1F, 056) -- Song names (Electric Cyan)

    if show_separator then
        -- Top separator
        windower.add_to_chat(001, colorGray .. '===============================================================')
    end

    -- Main message
    local messageParts = {}
    table.insert(messageParts, colorGray .. '[')
    local job_name = MessageCore.get_standardized_job_name()
    table.insert(messageParts, colorJob .. job_name .. colorGray)
    table.insert(messageParts, '] ')
    table.insert(messageParts, colorGray .. rotation_name .. ': ')

    -- Add songs with gray arrows
    for i, song in ipairs(songs) do
        if i > 1 then
            table.insert(messageParts, colorGray .. ' -> ')
        end
        local short_name = song:gsub("'s", ""):gsub(" March", " Mar"):gsub(" Minuet", " Min"):gsub(" Madrigal", " Mad")
            :gsub(" Ballad", " Bal")
        table.insert(messageParts, colorSong .. short_name .. colorGray)
    end

    windower.add_to_chat(001, table.concat(messageParts))

    if show_separator then
        -- Bottom separator
        windower.add_to_chat(001, colorGray .. '===============================================================')
    end
end

return MessageBRD