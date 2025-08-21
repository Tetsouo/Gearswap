---============================================================================
--- FFXI GearSwap Messages - Job-Specific Message Functions
---============================================================================
--- Job-specific messaging functions for all supported jobs. Each job has
--- specialized functions for their unique features and abilities.
---
--- @file messages/MESSAGE_JOBS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING, utils/logger
---============================================================================

local MessageJobs = {}

-- Load critical dependencies
local success_core, MessageCore = pcall(require, 'messages/MESSAGE_CORE')
if not success_core then
    error("Failed to load messages/MESSAGE_CORE: " .. tostring(MessageCore))
end

local success_formatting, MessageFormatting = pcall(require, 'messages/MESSAGE_FORMATTING')
if not success_formatting then
    error("Failed to load messages/MESSAGE_FORMATTING: " .. tostring(MessageFormatting))
end

local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
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
function MessageJobs.brd_song_list_message(song_data, title)
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
function MessageJobs.brd_singing_message(song_name, rotation_count, max_rotations)
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
function MessageJobs.brd_rotation_complete_message(song_name, completion_type)
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
function MessageJobs.brd_colored_message(action, details, extra, action_color)
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
function MessageJobs.brd_message(action_type, message, details)
    MessageCore.universal_message("BRD", action_type, message, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.BRD_SONG)
end

--- Creates BRD spell message
-- @param spell_name (string): Name of the spell
-- @param action (string): Action being performed
-- @param details (string): Details about the spell
-- @param spell_type (string): Type of spell (optional)
function MessageJobs.brd_spell_message(spell_name, action, details, spell_type)
    MessageCore.universal_message("BRD", "Magic", spell_name .. " " .. action, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.MAGIC)
end

--- Creates BRD job ability message
-- @param ja_name (string): Name of the job ability
-- @param action (string): Action being performed
-- @param details (string): Details about the ability
function MessageJobs.brd_ja_message(ja_name, action, details)
    MessageCore.universal_message("BRD", "Ability", ja_name .. " " .. action, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

--- Creates BRD debug message
-- @param debug_text (string): Debug text to display
function MessageJobs.brd_debug_message(debug_text)
    if not debug_text then return end
    MessageCore.universal_message("BRD", "Debug", debug_text, nil, nil, nil, MessageFormatting.STANDARD_COLORS.GRAY)
end

--- Creates BRD cooldown message
-- @param ability_name (string): Name of the ability
-- @param cooldown_time (number): Cooldown time in seconds
function MessageJobs.brd_cooldown_message(ability_name, cooldown_time)
    if not ability_name or not cooldown_time then return end
    MessageCore.universal_message("BRD", "Ability", ability_name, nil, "recast", cooldown_time,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

--- Creates BRD song cooldown message
-- @param song_name (string): Name of the song
-- @param cooldown_seconds (number): Cooldown time in seconds
function MessageJobs.brd_song_cooldown_message(song_name, cooldown_seconds)
    if not song_name or not cooldown_seconds then return end
    MessageCore.universal_message("BRD", "Magic", song_name, nil, "recast", cooldown_seconds,
        MessageFormatting.STANDARD_COLORS.MAGIC)
end

--- Creates BRD weapon skill message
-- @param ws_name (string): Name of the weapon skill
-- @param gear_type (string): Type of gear equipped
function MessageJobs.brd_ws_message(ws_name, gear_type)
    if not ws_name then return end
    local details = gear_type and ("Gear: " .. gear_type) or nil
    MessageCore.universal_message("BRD", "WeaponSkill", ws_name, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.WEAPONSKILL)
end

--- Creates BRD song rotation message with separator (matching original format exactly)
-- @param songs (table): Array of song names
-- @param rotation_name (string): Name of the rotation
-- @param show_separator (boolean): Whether to show separator lines
function MessageJobs.brd_song_rotation_with_separator(songs, rotation_name, show_separator)
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

-- ===========================================================================================================
--                                     WAR JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates WAR buff detection message
-- @param sub_job (string): Detected subjob
function MessageJobs.war_smartbuff_detection_message(sub_job)
    if not sub_job then
        MessageCore.error("WAR", "Unable to detect subjob")
    else
        MessageCore.info("WAR", "Smartbuff: WAR/" .. sub_job .. " detected")
    end
end

--- Creates WAR buff execution message
-- @param buffs (table): List of buffs being executed
-- @param action_type (string): Type of action
-- @param sub_job (string): Subjob for context
function MessageJobs.war_buff_execution_message(buffs, action_type, sub_job)
    if action_type == 'buffs' and buffs and #buffs > 0 then
        local buff_list = table.concat(buffs, " > ")
        MessageCore.universal_message("WAR", "buff", "-> " .. buff_list, nil, "active", nil,
            MessageFormatting.STANDARD_COLORS.WAR_BUFF)
    elseif action_type == 'all_active' then
        MessageCore.info("WAR", "WAR Buffs: All active")
    elseif action_type == 'no_buffs' and sub_job then
        MessageCore.error("WAR", "No buffs available for /" .. sub_job .. " subjob")
    end
end

--- Creates WAR shadows message
-- @param shadow_type (string): Type of shadow action
function MessageJobs.war_shadows_message(shadow_type)
    if shadow_type == 'new' then
        MessageCore.universal_message("WAR", "spell", "-> Utsusemi: Ni", nil, nil, nil,
            MessageFormatting.STANDARD_COLORS.MAGIC)
    elseif shadow_type == 'refresh' then
        MessageCore.universal_message("WAR", "spell", "-> Refreshing shadows", nil, nil, nil,
            MessageFormatting.STANDARD_COLORS.MAGIC)
    end
end

--- Creates WAR buff active message (matching original format exactly)
-- @param buff_name (string): Name of the buff that is active
function MessageJobs.war_buff_active_message(buff_name)
    if not buff_name then return end

    -- Use create_formatted_message with custom status text instead of recast time
    -- This will produce: [Hasso] Status: (ACTIVE)
    local colorGray = string.char(0x1F, 160)
    local colorOrange = string.char(0x1F, 057) -- Orange for buff name
    local colorGreen = string.char(0x1F, 158)  -- Green for active status

    local message = colorGray .. '[' .. colorOrange .. buff_name .. colorGray .. '] ' ..
        'Status: ' .. colorGray .. '(' .. colorGreen .. 'ACTIVE' .. colorGray .. ')'

    windower.add_to_chat(160, message)
end

--- Creates WAR compact status message (matching original format exactly)
-- @param messages (table): Array of message data
-- @param job_name (string): Job name
function MessageJobs.war_compact_status_message(messages, job_name)
    if not messages or #messages == 0 then return end

    job_name = job_name or 'WAR'

    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)    -- Light Blue for job names
    local colorOrange = string.char(0x1F, 057) -- Orange for ability names
    local colorGreen = string.char(0x1F, 158)  -- Green for active status
    local colorRed = string.char(0x1F, 167)    -- Red for cooldown time

    -- Start with job tag
    local message_parts = { colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ' }

    -- Process each message
    for i, msg in ipairs(messages) do
        local part = ""

        if msg.type == 'active' then
            part = colorOrange .. msg.name .. colorGray .. ': ' .. colorGreen .. 'Active'
        elseif msg.type == 'recast' then
            -- Format time appropriately
            local time_str
            if msg.time >= 60 then
                local minutes = math.floor(msg.time / 60)
                local seconds = msg.time % 60
                time_str = string.format("%dm%02ds", minutes, seconds)
            else
                time_str = string.format("%ds", msg.time)
            end
            part = colorOrange .. msg.name .. colorGray .. ': ' .. colorRed .. time_str
        end

        -- Add separator if not first item
        if i > 1 then
            table.insert(message_parts, colorGray .. ' | ')
        end

        table.insert(message_parts, part)
    end

    local full_message = table.concat(message_parts)
    windower.add_to_chat(001, full_message)
end

--- Creates WAR TP message (matching original format exactly)
function MessageJobs.war_tp_message()
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207) -- Light Blue for job names
    local colorTP = string.char(0x1F, 030)  -- Green for sufficient TP

    local job_name = MessageCore.get_standardized_job_name()
    local current_tp = player.tp or 0

    local message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] TP: ' ..
        colorTP .. current_tp .. colorGray .. ' (Sufficient for WS)'

    windower.add_to_chat(001, message)
end

-- ===========================================================================================================
--                                     THF JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates THF theft attempt message
-- @param target_name (string): Name of the target
-- @param attempt_count (number): Current attempt number
-- @param max_attempts (number): Maximum attempts allowed
function MessageJobs.thf_theft_attempt_message(target_name, attempt_count, max_attempts)
    if not target_name then return end

    local details = ""
    if attempt_count and max_attempts then
        details = string.format("Attempt %d/%d", attempt_count, max_attempts)
    end

    MessageCore.universal_message("THF", "ability", "Stealing from: " .. target_name, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.THF_ACTION)
end

--- Creates THF treasure hunter status message
-- @param th_level (number): Current TH level
-- @param target_name (string): Target name
function MessageJobs.thf_treasure_hunter_message(th_level, target_name)
    if not th_level or not target_name then return end

    local details = "TH" .. th_level .. " on " .. target_name
    MessageCore.universal_message("THF", "status", "Treasure Hunter", details, "active", nil,
        MessageFormatting.STANDARD_COLORS.THF_STATUS)
end

--- Creates THF dual-box synchronization message
-- @param sync_type (string): Type of sync ("spell", "ability", "status")
-- @param value (string): Synchronized value
function MessageJobs.thf_sync_message(sync_type, value)
    if not sync_type or not value then return end

    local sync_text = "Alt " .. sync_type .. " synchronized"
    MessageCore.universal_message("THF", "sync", sync_text, value, nil, nil, MessageFormatting.STANDARD_COLORS.INFO)
end

--- Creates THF spell abort message (matching original format exactly)
-- @param spell_name (string): Name of the spell being aborted
-- @param recast_time (string): Remaining recast time
function MessageJobs.thf_spell_abort_message(spell_name, recast_time)
    if not spell_name or not recast_time then return end

    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)   -- Light Blue for job names
    local colorSpell = string.char(0x1F, 056) -- Electric Cyan for spells
    local colorTime = string.char(0x1F, 167)  -- Red for abort/cooldown

    local message = colorGray .. '[' .. colorJob .. 'THF' .. colorGray .. '] Abort: ' ..
        colorSpell .. spell_name .. colorGray .. ' on cooldown: ' ..
        colorTime .. recast_time

    windower.add_to_chat(001, message)
end

--- Creates THF combined status message (uses unified system)
-- @param messages (table): Array of message data
-- @param job_name (string): Job name
-- @param show_separator (boolean): Whether to show separator
function MessageJobs.thf_combined_status_message(messages, job_name, show_separator)
    if not messages or #messages == 0 then return end

    job_name = job_name or 'THF'

    -- Convert messages to unified format
    local unified_messages = {}

    for _, msg in ipairs(messages) do
        -- Auto-detect action type
        local action_type = "Ability" -- Default for THF JAs
        if msg.name == "Utsusemi: Ni" or msg.name == "Utsusemi: Ichi" then
            action_type = "Magic"     -- Utsusemi are spells
        end

        local unified_msg = {
            action_type = action_type,
            message = msg.name,
            status = nil,
            time_value = nil
        }

        if msg.type == 'active' then
            unified_msg.status = "Active"
        elseif msg.type == 'recast' then
            unified_msg.time_value = msg.time
        elseif msg.type == 'ready' then
            unified_msg.status = "Ready"
        elseif msg.type == 'upgrade' then
            unified_msg.status = "Upgrading"
            unified_msg.message = msg.name .. " -> " .. (msg.target or "Better tier")
        elseif msg.type == 'fallback' then
            unified_msg.status = "Fallback"
            unified_msg.message = msg.name .. " -> " .. (msg.target or "Lower tier")
        end

        table.insert(unified_messages, unified_msg)
    end

    -- Use unified system
    MessageCore.grouped_message(job_name, unified_messages, show_separator)
end

-- ===========================================================================================================
--                                     DNC JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates DNC smartbuff detection message
-- @param sub_job (string): Detected subjob
function MessageJobs.dnc_smartbuff_detection_message(sub_job)
    if not sub_job then
        MessageCore.error("DNC", "Unable to detect subjob")
    else
        MessageCore.info("DNC", "Smartbuff: DNC/" .. sub_job .. " detected")
    end
end

--- Creates DNC smartbuff subjob message (matching original format exactly)
-- @param sub_job (string): Detected subjob
function MessageJobs.dnc_smartbuff_subjob_message(sub_job)
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)    -- Light Blue for job names
    local colorAction = string.char(0x1F, 050) -- Yellow for smartbuff

    if not sub_job then
        local colorError = string.char(0x1F, 167) -- Red for error
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. 'Smartbuff' .. colorGray .. ': ' ..
            colorError .. 'Unable to detect subjob'
        windower.add_to_chat(001, message)
    else
        local colorSubjob = string.char(0x1F, 030) -- Green for successful detection
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. 'Smartbuff' .. colorGray .. ': DNC/' ..
            colorSubjob .. sub_job .. colorGray .. ' detected'
        windower.add_to_chat(001, message)
    end
end

--- Creates DNC buff execution message (matching original format exactly)
-- @param buffs (table): List of buffs being executed
-- @param action_type (string): Type of action
-- @param sub_job (string): Subjob for context
function MessageJobs.dnc_buff_execution_message(buffs, action_type, sub_job)
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)    -- Light Blue for job names
    local colorAction = string.char(0x1F, 030) -- Green for actions
    local colorBuff = string.char(0x1F, 050)   -- Yellow for buff names

    if action_type == 'buffs' and buffs and #buffs > 0 then
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. '-> ' .. colorBuff .. table.concat(buffs, colorGray .. ' > ' .. colorBuff)
        windower.add_to_chat(001, message)
    elseif action_type == 'all_active' then
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. 'WAR Buffs: All active'
        windower.add_to_chat(001, message)
    elseif action_type == 'shadows_new' then
        local colorSpell = string.char(0x1F, 056) -- Electric Cyan for spells
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. '-> ' .. colorSpell .. 'Utsusemi: Ni'
        windower.add_to_chat(001, message)
    elseif action_type == 'shadows_refresh' then
        local colorSpell = string.char(0x1F, 056) -- Electric Cyan for spells
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorAction .. '-> Refreshing ' .. colorSpell .. 'shadows'
        windower.add_to_chat(001, message)
    elseif action_type == 'no_buffs' and sub_job then
        local colorError = string.char(0x1F, 167) -- Red for no buffs available
        local message = colorGray .. '[' .. colorJob .. 'DNC' .. colorGray .. '] ' ..
            colorError .. 'No buffs available for /' .. sub_job .. ' subjob'
        windower.add_to_chat(001, message)
    end
end

-- ===========================================================================================================
--                                     PLD JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates PLD general message (log function replacement)
-- @param msg_text (string): Message text
-- @param is_error (boolean): Whether this is an error message
function MessageJobs.pld_message(msg_text, is_error)
    if not msg_text then return end

    if is_error then
        MessageCore.error("PLD", msg_text)
    else
        MessageCore.info("PLD", msg_text)
    end
end

--- Creates PLD rune management message
-- @param action (string): Action type ('error_not_run', 'current_rune')
-- @param rune_name (string): Name of the rune for current_rune action
function MessageJobs.pld_rune_message(action, rune_name)
    if action == 'error_not_run' then
        MessageCore.error("PLD", "You are not sub RUN")
    elseif action == 'current_rune' and rune_name then
        MessageCore.info("PLD", "Current Rune: " .. rune_name)
    end
end

-- ===========================================================================================================
--                                     BLM JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates BLM resource error message
function MessageJobs.blm_resource_error_message()
    MessageCore.error("BLM", "Resources module not found")
end

--- Creates BLM spell cooldown message
-- @param spell_name (string): Name of the spell on cooldown
-- @param recast_time (number): Recast time in centiseconds
function MessageJobs.blm_spell_cooldown_message(spell_name, recast_time)
    if not spell_name or not recast_time then return end

    -- Convert centiseconds to seconds for unified system
    local recast_seconds = recast_time / 100
    MessageCore.cooldown_message(spell_name, recast_seconds)
end

--- Creates BLM buff status message
function MessageJobs.blm_buff_status_message()
    MessageCore.info("BLM", "All buff spells ready but already active")
end

--- Creates BLM dual-box synchronization message
-- @param sync_type (string): Type of synchronization ('light', 'dark', 'tier')
-- @param value (string): The synchronized value
function MessageJobs.blm_sync_message(sync_type, value)
    if not sync_type or not value then return end

    local sync_text
    if sync_type == 'light' then
        sync_text = 'Alt Light spell synchronized'
    elseif sync_type == 'dark' then
        sync_text = 'Alt Dark spell synchronized'
    elseif sync_type == 'tier' then
        sync_text = 'Alt Tier synchronized'
    end

    MessageCore.universal_message("BLM", "sync", sync_text, value, nil, nil, MessageFormatting.STANDARD_COLORS.BLM_SPELL)
end

--- Creates BLM alt casting message
-- @param action (string): Action type ('cast_light', 'cast_dark', 'error_light', 'error_dark')
-- @param spell_name (string): Spell name for cast actions
-- @param tier (string): Tier for cast actions
function MessageJobs.blm_alt_cast_message(action, spell_name, tier)
    if action == 'cast_light' or action == 'cast_dark' then
        local cast_text = "Alt casting: " .. spell_name .. " " .. tier
        MessageCore.universal_message("BLM", "spell", cast_text, nil, nil, nil,
            MessageFormatting.STANDARD_COLORS.BLM_SPELL)
    elseif action == 'error_light' then
        MessageCore.error("BLM", "Alt light states not available")
    elseif action == 'error_dark' then
        MessageCore.error("BLM", "Alt dark states not available")
    end
end

-- ===========================================================================================================
--                                     BST JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates BST resource error message
function MessageJobs.bst_resource_error_message()
    MessageCore.error("BST", "Resources module not found")
end

--- Creates enhanced BST ecosystem change message with pets and correlation info (matching original format exactly)
-- @param ecosystem (string): Name of the ecosystem
-- @param pet_count (number): Number of available pets
function MessageJobs.bst_ecosystem_message(ecosystem, pet_count)
    if not ecosystem or not pet_count then return end

    -- Show separator before ecosystem info
    MessageCore.show_separator()

    -- BST-specific ecosystem message with specialized colors
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)         -- Light Blue for job names
    local colorEcosystem = string.char(0x1F, 050)   -- Yellow for ecosystem
    local colorInfo = string.char(0x1F, 030)        -- Green for info
    local colorPet = string.char(0x1F, 087)         -- Light cyan for pet names
    local colorCorrelation = string.char(0x1F, 158) -- Orange for correlation

    local job_name = MessageCore.get_standardized_job_name()

    -- Main ecosystem message
    local main_message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] Ecosystem: ' ..
        colorEcosystem .. ecosystem .. colorGray .. ' | ' ..
        colorInfo .. pet_count .. ' pets available'
    windower.add_to_chat(001, main_message)

    -- Show monster correlation if ecosystem is not "All"
    if ecosystem ~= "All" then
        local success_correlation, MonsterCorrelation = pcall(require, 'jobs/bst/MONSTER_CORRELATION')
        if success_correlation and MonsterCorrelation then
            local correlation_summary = MonsterCorrelation.get_correlation_summary_colored(ecosystem)
            if correlation_summary and correlation_summary ~= "No correlation data available" then
                local correlation_message = colorGray ..
                    '[' .. colorJob .. job_name .. colorGray .. '] Correlation: ' ..
                    correlation_summary
                windower.add_to_chat(001, correlation_message)
            end
        end
    end

    -- Show separator after ecosystem info
    MessageCore.show_separator()
end

--- Creates BST species/pet selection message (matching original format exactly)
-- @param pet_name (string): Name of the selected pet
-- @param is_species_change (boolean): Whether this is a species change or pet info
function MessageJobs.bst_pet_selection_message(pet_name, is_species_change)
    if not pet_name then return end

    -- Show separator before species change info
    MessageCore.show_separator()

    -- BST-specific pet selection message with specialized colors
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)    -- Light Blue for job names
    local colorPet = string.char(0x1F, 050)    -- Yellow for pet name
    local colorAction = string.char(0x1F, 030) -- Green for action

    local job_name = MessageCore.get_standardized_job_name()
    local action_text = is_species_change and "Species changed to: " or "Selected pet: "
    local message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ' ..
        colorAction .. action_text .. colorPet .. pet_name

    windower.add_to_chat(001, message)

    -- Show separator after species change info
    MessageCore.show_separator()
end

--- Creates BST pet not found error message
-- @param species (string): Species that wasn't found
function MessageJobs.bst_pet_not_found_message(species)
    if not species then return end

    MessageCore.error("BST", "No pets found for species: " .. species)
end

--- Creates BST broth equipped message
-- @param pet_name (string): Name of the pet the broth is for
function MessageJobs.bst_broth_equipped_message(pet_name)
    if not pet_name then return end

    MessageCore.info("BST", "Equipped broth for " .. pet_name)
end

--- Creates BST ammo/broth error messages
-- @param error_type (string): Type of error ('no_ammo_set', 'broth_not_recognized')
-- @param additional_info (string): Additional info for broth_not_recognized
function MessageJobs.bst_ammo_error_message(error_type, additional_info)
    if error_type == 'no_ammo_set' then
        MessageCore.error("BST", "No ammoSet or invalid ammo data")
    elseif error_type == 'broth_not_recognized' and additional_info then
        MessageCore.error("BST", "Broth name not recognized: " .. additional_info)
    end
end

--- Creates BST pet info message with detailed information
-- @param pet_name (string): Name of the pet
-- @param family (string): Pet family
-- @param jug_count (number): Number of jugs available
function MessageJobs.bst_pet_info_message(pet_name, family, jug_count)
    if not pet_name or not family or not jug_count then return end

    local info = pet_name .. ' | Family: ' .. family .. ' | Jug(s): ' .. jug_count
    MessageCore.info("BST", "Pet Info: " .. info)
end

--- Creates BST ready move error message
-- @param slot_number (number): Ready move slot number that's unavailable
function MessageJobs.bst_ready_move_error_message(slot_number)
    if not slot_number then return end

    MessageCore.error("BST", "Ready Move #" .. slot_number .. " unavailable")
end

--- Creates BST selection info message with multiple lines
-- @param ecosystem (string): Current ecosystem
-- @param species (string): Current species
-- @param current_pet (string): Current selected pet
-- @param available_count (number): Number of available pets
function MessageJobs.bst_selection_info_message(ecosystem, species, current_pet, available_count)
    if not ecosystem or not species or not current_pet or not available_count then return end

    MessageCore.show_separator()

    MessageCore.multiline("BST", "Current Selection:", {
        "Ecosystem: " .. ecosystem,
        "Species: " .. species,
        "Pet: " .. current_pet,
        "Available: " .. available_count .. " pets"
    })

    MessageCore.show_separator()
end

-- ===========================================================================================================
--                                     DRG JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates DRG wyvern status message
-- @param wyvern_status (string): Status of the wyvern ("active", "dismissed", "dead")
-- @param wyvern_name (string): Name of the wyvern
function MessageJobs.drg_wyvern_status_message(wyvern_status, wyvern_name)
    if not wyvern_status then return end

    local status_text = wyvern_name and (wyvern_name .. " " .. wyvern_status) or ("Wyvern " .. wyvern_status)

    if wyvern_status == "active" then
        MessageCore.success("DRG", status_text)
    elseif wyvern_status == "dismissed" then
        MessageCore.warning("DRG", status_text)
    else
        MessageCore.error("DRG", status_text)
    end
end

--- Creates DRG jump ability message
-- @param jump_type (string): Type of jump ability used
-- @param target_name (string): Name of the target
function MessageJobs.drg_jump_message(jump_type, target_name)
    if not jump_type then return end

    local details = target_name and ("-> " .. target_name) or nil
    MessageCore.universal_message("DRG", "ability", jump_type, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

-- ===========================================================================================================
--                                     RUN JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates RUN rune status message
-- @param rune_name (string): Name of the rune
-- @param rune_count (number): Number of runes active
-- @param max_runes (number): Maximum runes possible
function MessageJobs.run_rune_status_message(rune_name, rune_count, max_runes)
    if not rune_name then return end

    local details = ""
    if rune_count and max_runes then
        details = string.format("%d/%d runes", rune_count, max_runes)
    end

    MessageCore.universal_message("RUN", "rune", rune_name, details, "active", nil,
        MessageFormatting.STANDARD_COLORS.SUCCESS)
end

--- Creates RUN ward status message
-- @param ward_type (string): Type of ward ("Battuta", "Vallation", etc.)
-- @param ward_status (string): Status of the ward
function MessageJobs.run_ward_message(ward_type, ward_status)
    if not ward_type or not ward_status then return end

    MessageCore.universal_message("RUN", "ward", ward_type, ward_status, ward_status == "active" and "active" or "info",
        nil, MessageFormatting.STANDARD_COLORS.INFO)
end

-- Export functions for global access (backward compatibility)
_G.brd_song_list_message = MessageJobs.brd_song_list_message
_G.brd_singing_message = MessageJobs.brd_singing_message
_G.brd_colored_message = MessageJobs.brd_colored_message
_G.brd_message = MessageJobs.brd_message
_G.brd_spell_message = MessageJobs.brd_spell_message
_G.brd_ja_message = MessageJobs.brd_ja_message
_G.brd_debug_message = MessageJobs.brd_debug_message
_G.brd_cooldown_message = MessageJobs.brd_cooldown_message
_G.brd_song_cooldown_message = MessageJobs.brd_song_cooldown_message
_G.brd_ws_message = MessageJobs.brd_ws_message
_G.brd_song_rotation_with_separator = MessageJobs.brd_song_rotation_with_separator
_G.war_smartbuff_detection_message = MessageJobs.war_smartbuff_detection_message
_G.war_buff_execution_message = MessageJobs.war_buff_execution_message
_G.war_buff_active_message = MessageJobs.war_buff_active_message
_G.war_compact_status_message = MessageJobs.war_compact_status_message
_G.war_tp_message = MessageJobs.war_tp_message
_G.thf_theft_attempt_message = MessageJobs.thf_theft_attempt_message
_G.thf_treasure_hunter_message = MessageJobs.thf_treasure_hunter_message
_G.thf_spell_abort_message = MessageJobs.thf_spell_abort_message
_G.thf_combined_status_message = MessageJobs.thf_combined_status_message
_G.dnc_smartbuff_detection_message = MessageJobs.dnc_smartbuff_detection_message
_G.dnc_smartbuff_subjob_message = MessageJobs.dnc_smartbuff_subjob_message
_G.dnc_buff_execution_message = MessageJobs.dnc_buff_execution_message
_G.pld_message = MessageJobs.pld_message
_G.pld_rune_message = MessageJobs.pld_rune_message
_G.blm_resource_error_message = MessageJobs.blm_resource_error_message
_G.blm_spell_cooldown_message = MessageJobs.blm_spell_cooldown_message
_G.blm_sync_message = MessageJobs.blm_sync_message
_G.blm_alt_cast_message = MessageJobs.blm_alt_cast_message
_G.bst_resource_error_message = MessageJobs.bst_resource_error_message
_G.bst_ecosystem_message = MessageJobs.bst_ecosystem_message
_G.bst_pet_selection_message = MessageJobs.bst_pet_selection_message
_G.bst_pet_not_found_message = MessageJobs.bst_pet_not_found_message
_G.bst_broth_equipped_message = MessageJobs.bst_broth_equipped_message
_G.bst_ammo_error_message = MessageJobs.bst_ammo_error_message
_G.bst_pet_info_message = MessageJobs.bst_pet_info_message
_G.bst_ready_move_error_message = MessageJobs.bst_ready_move_error_message
_G.bst_selection_info_message = MessageJobs.bst_selection_info_message
_G.drg_wyvern_status_message = MessageJobs.drg_wyvern_status_message
_G.drg_jump_message = MessageJobs.drg_jump_message
_G.run_rune_status_message = MessageJobs.run_rune_status_message
_G.run_ward_message = MessageJobs.run_ward_message

return MessageJobs
