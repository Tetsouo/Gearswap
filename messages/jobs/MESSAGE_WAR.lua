---============================================================================
--- FFXI GearSwap Messages - Warrior (WAR) Specific Messages
---============================================================================
--- Warrior-specific messaging functions for buff management, TP tracking,
--- and combat status.
---
--- @file messages/jobs/MESSAGE_WAR.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageWAR = {}

-- Load critical dependencies
local success_core, MessageCore = pcall(require, 'messages/MESSAGE_CORE')
if not success_core then
    error("Failed to load messages/MESSAGE_CORE: " .. tostring(MessageCore))
end

local success_formatting, MessageFormatting = pcall(require, 'messages/MESSAGE_FORMATTING')
if not success_formatting then
    error("Failed to load messages/MESSAGE_FORMATTING: " .. tostring(MessageFormatting))
end

-- ===========================================================================================================
--                                     WAR JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates WAR buff detection message
-- @param sub_job (string): Detected subjob
function MessageWAR.war_smartbuff_detection_message(sub_job)
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
function MessageWAR.war_buff_execution_message(buffs, action_type, sub_job)
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
function MessageWAR.war_shadows_message(shadow_type)
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
function MessageWAR.war_buff_active_message(buff_name)
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
function MessageWAR.war_compact_status_message(messages, job_name)
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
function MessageWAR.war_tp_message()
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207) -- Light Blue for job names
    local colorTP = string.char(0x1F, 030)  -- Green for sufficient TP

    local job_name = MessageCore.get_standardized_job_name()
    local current_tp = player.tp or 0

    local message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] TP: ' ..
        colorTP .. current_tp .. colorGray .. ' (Sufficient for WS)'

    windower.add_to_chat(001, message)
end

return MessageWAR