---============================================================================
--- FFXI GearSwap Messages - Core Message Functions (Fixed Version)
---============================================================================
--- Core message system providing universal messaging functions that work
--- across all jobs and provide the foundation for job-specific messaging.
---
--- Fixed to match the original MESSAGES.lua format exactly.
---
--- @file messages/MESSAGE_CORE.lua
--- @author Tetsouo
--- @version 1.1
--- @date Fixed: 2025-08-20
---============================================================================

local MessageCore = {}

-- Load critical dependencies
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end

local success_formatting, MessageFormatting = pcall(require, 'messages/MESSAGE_FORMATTING')
if not success_formatting then
    error("Failed to load messages/MESSAGE_FORMATTING: " .. tostring(MessageFormatting))
end

-- ===========================================================================================================
--                                     Helper Functions
-- ===========================================================================================================

--- Get standardized job name with subjob if applicable
-- @param override_job_name string Optional job name override
-- @return string Standardized job name (e.g., "WAR", "WAR/SAM", "BLM/SCH")
function MessageCore.get_standardized_job_name(override_job_name)
    if override_job_name then
        return override_job_name
    end

    -- Auto-generate from player data
    local main_job = player.main_job or 'JOB'
    local sub_job = player.sub_job

    if sub_job and sub_job ~= 'NON' and sub_job ~= '' then
        return main_job .. '/' .. sub_job
    else
        return main_job
    end
end

-- ===========================================================================================================
--                                     Universal Message System (Fixed)
-- ===========================================================================================================

--- Universal message system copied from original MESSAGES.lua
function MessageCore.universal_message(job, action_type, message, details, status, time_value, force_color)
    -- Parameter validation
    if not action_type or not message then
        log.error("universal_message: Missing parameters")
        return
    end

    -- Standardize job name using same function
    job = MessageCore.get_standardized_job_name(job)

    -- Determine color based on action type
    local color = force_color
    if not color then
        local action_lower = action_type:lower()
        if action_lower:find("magic") or action_lower:find("spell") then
            color = MessageFormatting.STANDARD_COLORS.MAGIC
        elseif action_lower:find("ability") or action_lower:find("ja") then
            color = MessageFormatting.STANDARD_COLORS.ABILITY
        elseif action_lower:find("weapon") or action_lower:find("ws") then
            color = MessageFormatting.STANDARD_COLORS.WEAPONSKILL
        elseif action_lower:find("error") then
            color = MessageFormatting.STANDARD_COLORS.ERROR
        elseif action_lower:find("warning") then
            color = MessageFormatting.STANDARD_COLORS.WARNING
        elseif action_lower:find("success") or action_lower:find("active") then
            color = MessageFormatting.STANDARD_COLORS.SUCCESS
        else
            color = MessageFormatting.STANDARD_COLORS.WHITE
        end
    end

    -- Construire le message formaté
    local colorJob = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.JOB_NAME)
    local colorGray = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.GRAY)
    local colorAction = MessageFormatting.create_color_code(color)

    local formatted_message = colorGray .. '[' .. colorJob .. job .. colorGray .. '] '

    -- Ajouter le message principal
    if action_type ~= job then
        formatted_message = formatted_message .. action_type .. ': '
    end
    formatted_message = formatted_message .. colorAction .. message .. colorGray

    -- Ajouter les détails si présents
    if details then
        formatted_message = formatted_message .. ' - ' .. details
    end

    -- Ajouter le statut et temps si présents
    if status then
        if status:lower() == "active" then
            local colorActive = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.ACTIVE)
            formatted_message = formatted_message .. ' (' .. colorActive .. 'ACTIVE' .. colorGray .. ')'
        elseif status:lower() == "ready" then
            local colorReady = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.SUCCESS)
            formatted_message = formatted_message .. ' (' .. colorReady .. 'READY' .. colorGray .. ')'
        elseif time_value and time_value > 0 then
            local time_str = MessageFormatting.format_recast_duration(time_value) -- Keep in seconds
            local colorCooldown = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.RECAST)
            formatted_message = formatted_message .. ' (' .. colorCooldown .. time_str .. colorGray .. ')'
        end
    elseif time_value and time_value > 0 then
        -- Show recast even without status
        local time_str = MessageFormatting.format_recast_duration(time_value) -- Keep in seconds
        local colorCooldown = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.RECAST)
        formatted_message = formatted_message .. ' (' .. colorCooldown .. time_str .. colorGray .. ')'
    end

    -- Envoyer le message
    windower.add_to_chat(MessageFormatting.STANDARD_COLORS.WHITE, formatted_message)
end

--- Enhanced status message with color coding and validation
-- @param status (string): Status type ("success", "error", "warning", "info")
-- @param message (string): Message content
-- @return (boolean): True if message was sent successfully
function MessageCore.status_message(status, message)
    if not message then
        return false
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

    windower.add_to_chat(color_code, message)
    return true
end

--- Success message (green)
-- @param job (string): Job identifier
-- @param message (string): Message content
function MessageCore.success(job, message)
    return MessageCore.universal_message(job, "status", message, nil, "success")
end

--- Error message (red)
-- @param job (string): Job identifier
-- @param message (string): Message content
function MessageCore.error(job, message)
    return MessageCore.universal_message(job, "status", message, nil, "error")
end

--- Warning message (orange)
-- @param job (string): Job identifier
-- @param message (string): Message content
function MessageCore.warning(job, message)
    return MessageCore.universal_message(job, "status", message, nil, "warning")
end

--- Info message (blue)
-- @param job (string): Job identifier
-- @param message (string): Message content
function MessageCore.info(job, message)
    return MessageCore.universal_message(job, "status", message, nil, "info")
end

--- Spell interrupted message
-- @param spell (table): Spell object with name and other properties
function MessageCore.spell_interrupted_message(spell)
    if not spell then
        return false
    end

    local spell_name = spell.name or spell.en or "Unknown Spell"

    -- Determine spell color based on type
    local spell_color = MessageFormatting.STANDARD_COLORS.MAGIC -- Default cyan for spells

    -- Load resources to check if it's really a spell
    local success_res, res = pcall(require, 'resources')
    if success_res and res then
        -- Check if it's in job abilities instead of spells
        local ability_data = res.job_abilities:with('en', spell_name)
        if ability_data then
            spell_color = MessageFormatting.STANDARD_COLORS.ABILITY -- Yellow for abilities
        end
    end

    -- Check spell.type as fallback
    if spell.type and spell.type == "JobAbility" then
        spell_color = MessageFormatting.STANDARD_COLORS.ABILITY     -- Yellow for abilities
    elseif spell.type == "WeaponSkill" then
        spell_color = MessageFormatting.STANDARD_COLORS.WEAPONSKILL -- Red for weapon skills
    end

    -- Build the message with proper colors like the original
    local colorGray = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.GRAY)
    local colorOrange = MessageFormatting.create_color_code(57) -- Orange for interrupt prefixes
    local spellColor = MessageFormatting.create_color_code(spell_color)

    -- Determine message prefix
    local message_prefix
    if spell.type == 'WeaponSkill' then
        message_prefix = 'WS interrupted'
    elseif spell.type == 'JobAbility' then
        message_prefix = 'JA interrupted'
    else
        message_prefix = 'Spell interrupted'
    end

    -- Build multi-colored message like original
    local messageParts = {}

    -- Add prefix with orange color and gray brackets
    table.insert(messageParts, colorGray .. '[' .. colorOrange .. message_prefix .. colorGray .. ']:')

    -- Add spell name with its specific color
    table.insert(messageParts, ' ' .. spellColor .. spell_name)

    -- Add separator line in gray
    table.insert(messageParts, '\n' .. colorGray .. '===============================================================')

    local final_message = table.concat(messageParts)

    -- Send directly to chat like the original
    windower.add_to_chat(MessageFormatting.STANDARD_COLORS.WHITE, final_message)

    return true
end

--- Shows a separator line
-- @param char (string): Character for separator (default: "=")
-- @param length (number): Length of separator (default: 70)
function MessageCore.show_separator(char, length)
    char = char or '='
    length = length or 70
    local colorSep = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.GRAY)
    local separator = colorSep .. string.rep(char, length)
    windower.add_to_chat(MessageFormatting.STANDARD_COLORS.WHITE, separator)
end

--- Displays multiple lines of text with a title
-- @param job (string): Job name
-- @param title (string): Title for the multiline message
-- @param lines (table): Array of lines to display
function MessageCore.multiline(job, title, lines)
    if not title or not lines or #lines == 0 then return end

    job = MessageCore.get_standardized_job_name(job)

    -- Display title
    MessageCore.universal_message(job, "info", title, nil, nil, nil, MessageFormatting.STANDARD_COLORS.INFO)

    -- Display each line
    for _, line in ipairs(lines) do
        if line and line ~= "" then
            MessageCore.universal_message(job, "detail", line, nil, nil, nil, MessageFormatting.STANDARD_COLORS.WHITE)
        end
    end
end

--- Grouped message function for displaying multiple messages
-- @param job (string): Job name
-- @param messages (table): Array of message data
-- @param show_separators (boolean): Whether to show separators
function MessageCore.grouped_message(job, messages, show_separators)
    if not messages or #messages == 0 then return end

    if show_separators then
        MessageCore.show_separator()
    end

    for _, msg_data in ipairs(messages) do
        MessageCore.universal_message(
            job,
            msg_data.action_type or "Status",
            msg_data.message,
            msg_data.details,
            msg_data.status,
            msg_data.time_value,
            msg_data.color
        )
    end

    if show_separators then
        MessageCore.show_separator()
    end
end

--- Unified status message system for arrays of status items
-- @param messages (table): Array of message objects with type, name, time properties
-- @param job_name (string): Optional job name override
-- @param show_separator (boolean): Whether to show separator lines
function MessageCore.unified_status_message(messages, job_name, show_separator)
    if not messages or #messages == 0 then return end

    job_name = MessageCore.get_standardized_job_name(job_name)

    -- Load resources for spell detection
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end

    -- Convertir les messages vers le format unifié
    local unified_messages = {}

    for _, msg in ipairs(messages) do
        local unified_msg = {
            action_type = "Ability",
            message = msg.name,
            status = nil,
            time_value = nil
        }

        -- Auto-detect if this is a spell (needs centiseconds conversion) or ability (already in seconds)
        local is_spell = false
        if msg.name then
            local spell_data = res.spells:with('en', msg.name)
            if spell_data then
                is_spell = true
                unified_msg.action_type = "Magic"
            end
        end

        if msg.type == 'active' then
            unified_msg.status = "Active"
        elseif msg.type == 'recast' and msg.time then
            -- Auto-convert centiseconds to seconds for spells only
            if is_spell and msg.time > 100 then
                -- If it's a spell and time > 100, likely in centiseconds - convert
                unified_msg.time_value = msg.time / 100
            else
                -- If it's an ability or time <= 100, already in seconds
                unified_msg.time_value = msg.time
            end
        elseif msg.type == 'ready' then
            unified_msg.status = "Ready"
        elseif msg.type == 'info' then
            -- For info messages, use the message field as status
            unified_msg.status = msg.message or "Info"
        end

        table.insert(unified_messages, unified_msg)
    end

    -- Use unified system
    MessageCore.grouped_message(job_name, unified_messages, show_separator)
end

--- Creates an error message for incapacitated state
-- @param action_name (string): Name of the action attempted
-- @param reason (string): Reason for incapacitation
function MessageCore.incapacitated_message(action_name, reason)
    if not action_name or action_name == "" then
        action_name = "N/A"
    end
    
    if not reason or reason == "" then
        reason = "Unknown"
    end
    
    local colorGray = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.GRAY)
    local colorRed = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.ERROR)
    local colorSpell = MessageFormatting.create_color_code(MessageFormatting.STANDARD_COLORS.MAGIC)
    
    local message = colorGray .. '[' .. colorRed .. 'Cannot Use' .. colorGray .. ']: ' .. 
                    colorSpell .. action_name .. colorGray .. ' (' .. colorRed .. reason .. colorGray .. ')'
    
    windower.add_to_chat(167, message)
end

-- Export functions for global access (backward compatibility)
_G.universal_message = MessageCore.universal_message
_G.status_message = MessageCore.status_message
_G.spell_interrupted_message = MessageCore.spell_interrupted_message
_G.unified_status_message = MessageCore.unified_status_message
_G.incapacitated_message = MessageCore.incapacitated_message

return MessageCore
