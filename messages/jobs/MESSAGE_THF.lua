---============================================================================
--- FFXI GearSwap Messages - Thief (THF) Specific Messages
---============================================================================
--- Thief-specific messaging functions for treasure hunter, stealing,
--- and stealth mechanics.
---
--- @file messages/jobs/MESSAGE_THF.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageTHF = {}

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
--                                     THF JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates THF theft attempt message
-- @param target_name (string): Name of the target
-- @param attempt_count (number): Current attempt number
-- @param max_attempts (number): Maximum attempts allowed
function MessageTHF.thf_theft_attempt_message(target_name, attempt_count, max_attempts)
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
function MessageTHF.thf_treasure_hunter_message(th_level, target_name)
    if not th_level or not target_name then return end

    local details = "TH" .. th_level .. " on " .. target_name
    MessageCore.universal_message("THF", "status", "Treasure Hunter", details, "active", nil,
        MessageFormatting.STANDARD_COLORS.THF_STATUS)
end

--- Creates THF dual-box synchronization message
-- @param sync_type (string): Type of sync ("spell", "ability", "status")
-- @param value (string): Synchronized value
function MessageTHF.thf_sync_message(sync_type, value)
    if not sync_type or not value then return end

    local sync_text = "Alt " .. sync_type .. " synchronized"
    MessageCore.universal_message("THF", "sync", sync_text, value, nil, nil, MessageFormatting.STANDARD_COLORS.INFO)
end

--- Creates THF spell abort message (matching original format exactly)
-- @param spell_name (string): Name of the spell being aborted
-- @param recast_time (string): Remaining recast time
function MessageTHF.thf_spell_abort_message(spell_name, recast_time)
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
function MessageTHF.thf_combined_status_message(messages, job_name, show_separator)
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

    -- Use unified system with job name and separators
    MessageCore.unified_status_message(unified_messages, job_name, show_separator)
end

return MessageTHF