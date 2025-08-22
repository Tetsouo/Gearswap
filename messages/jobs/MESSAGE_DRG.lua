---============================================================================
--- FFXI GearSwap Messages - Dragoon (DRG) Specific Messages
---============================================================================
--- Dragoon-specific messaging functions for wyvern management and jump
--- abilities tracking.
---
--- @file messages/jobs/MESSAGE_DRG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageDRG = {}

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
--                                     DRG JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates DRG wyvern status message
-- @param wyvern_status (string): Status of the wyvern ("active", "dismissed", "dead")
-- @param wyvern_name (string): Name of the wyvern
function MessageDRG.drg_wyvern_status_message(wyvern_status, wyvern_name)
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
function MessageDRG.drg_jump_message(jump_type, target_name)
    if not jump_type then return end

    local details = target_name and ("-> " .. target_name) or nil
    MessageCore.universal_message("DRG", "ability", jump_type, details, nil, nil,
        MessageFormatting.STANDARD_COLORS.ABILITY)
end

return MessageDRG