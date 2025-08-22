---============================================================================
--- FFXI GearSwap Messages - Rune Fencer (RUN) Specific Messages
---============================================================================
--- Rune Fencer-specific messaging functions for rune management and ward
--- abilities tracking.
---
--- @file messages/jobs/MESSAGE_RUN.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageRUN = {}

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
--                                     RUN JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates RUN rune status message
-- @param rune_name (string): Name of the rune
-- @param rune_count (number): Number of runes active
-- @param max_runes (number): Maximum runes possible
function MessageRUN.run_rune_status_message(rune_name, rune_count, max_runes)
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
function MessageRUN.run_ward_message(ward_type, ward_status)
    if not ward_type or not ward_status then return end

    MessageCore.universal_message("RUN", "ward", ward_type, ward_status, ward_status == "active" and "active" or "info",
        nil, MessageFormatting.STANDARD_COLORS.INFO)
end

return MessageRUN