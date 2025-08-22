---============================================================================
--- FFXI GearSwap Messages - Paladin (PLD) Specific Messages
---============================================================================
--- Paladin-specific messaging functions for rune management and defensive
--- abilities tracking.
---
--- @file messages/jobs/MESSAGE_PLD.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessagePLD = {}

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
--                                     PLD JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates PLD general message (log function replacement)
-- @param msg_text (string): Message text
-- @param is_error (boolean): Whether this is an error message
function MessagePLD.pld_message(msg_text, is_error)
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
function MessagePLD.pld_rune_message(action, rune_name)
    if action == 'error_not_run' then
        MessageCore.error("PLD", "You are not sub RUN")
    elseif action == 'current_rune' and rune_name then
        -- Format rune name with color based on element
        local rune_colors = {
            Ignis = 167,   -- Red for Fire
            Gelus = 207,   -- Blue for Ice
            Flabra = 158,  -- Green for Wind
            Tellus = 057,  -- Brown/Orange for Earth
            Sulpor = 008,  -- Purple/Violet for Lightning
            Unda = 039,    -- Light Blue for Water
            Lux = 001,     -- White for Light
            Tenebrae = 008 -- Purple/Dark for Dark
        }
        
        local color_code = rune_colors[rune_name] or 001 -- Default to white if not found
        local gray_code = string.char(0x1F, 160) -- Light gray/violet for "Current Rune:"
        local colored_rune = string.char(0x1F, color_code) .. rune_name .. string.char(0x1F, 001)
        
        -- Create custom formatted message with colored "Current Rune:" text
        local formatted_msg = gray_code .. "Current Rune: " .. colored_rune
        MessageCore.info("PLD", formatted_msg)
    end
end

return MessagePLD