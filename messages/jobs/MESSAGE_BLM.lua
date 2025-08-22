---============================================================================
--- FFXI GearSwap Messages - Black Mage (BLM) Specific Messages
---============================================================================
--- Black Mage-specific messaging functions for spell management, element
--- states, and dual-box synchronization.
---
--- @file messages/jobs/MESSAGE_BLM.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageBLM = {}

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
--                                     BLM JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates BLM resource error message
function MessageBLM.blm_resource_error_message()
    MessageCore.error("BLM", "Resources module not found")
end

--- Creates BLM spell cooldown message
-- @param spell_name (string): Name of the spell on cooldown
-- @param recast_time (number): Recast time in centiseconds
function MessageBLM.blm_spell_cooldown_message(spell_name, recast_time)
    if not spell_name or not recast_time then return end

    -- Convert centiseconds to seconds for unified system
    local recast_seconds = recast_time / 100
    MessageCore.cooldown_message(spell_name, recast_seconds)
end

--- Creates BLM buff status message
function MessageBLM.blm_buff_status_message()
    MessageCore.info("BLM", "All buff spells ready but already active")
end

--- Creates BLM dual-box synchronization message
-- @param sync_type (string): Type of synchronization ('light', 'dark', 'tier')
-- @param value (string): The synchronized value
function MessageBLM.blm_sync_message(sync_type, value)
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
function MessageBLM.blm_alt_cast_message(action, spell_name, tier)
    if action == 'cast_light' or action == 'cast_dark' then
        -- Element color codes
        local element_colors = {
            FIRE = 057,      -- Orange
            THUNDER = 012,   -- Yellow
            AERO = 006,      -- Cyan
            STONE = 050,     -- Yellow/Gold
            WATER = 056,     -- Light Blue
            BLIZZARD = 005,  -- Blue
            ICE = 005,       -- Blue
            LIGHT = 001,     -- White
            DARK = 201       -- Purple
        }
        
        -- Get color for element (uppercase for matching)
        local element_upper = spell_name:upper()
        local element_color_code = element_colors[element_upper] or 001
        
        -- Create colored message manually like other BLM messages
        local gray = string.char(0x1F, 160)
        local job_color = string.char(0x1F, 207)
        local spell_color = string.char(0x1F, 056) -- Cyan for "spell:"
        local element_color = string.char(0x1F, element_color_code)
        local tier_color = string.char(0x1F, 050) -- Yellow for tier
        
        local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                       spell_color .. 'spell' .. gray .. ': Alt casting: ' ..
                       element_color .. spell_name .. gray .. ' ' ..
                       tier_color .. tier .. gray
        windower.add_to_chat(001, message)
    elseif action == 'error_light' then
        MessageCore.error("BLM", "Alt light states not available")
    elseif action == 'error_dark' then
        MessageCore.error("BLM", "Alt dark states not available")
    end
end

--- Creates BLM element state message with colored element names (matching PLD rune format)
-- @param state_type (string): State type ('MainLight', 'SubLight', 'MainDark', 'SubDark')
-- @param element_name (string): Name of the element
function MessageBLM.blm_element_message(state_type, element_name)
    if not state_type or not element_name then return end
    
    -- Element color codes matching user specifications
    local element_colors = {
        Fire = 057,      -- Orange
        Ice = 005,       -- Blue
        Thunder = 012,   -- Yellow  
        Aero = 006,      -- Cyan
        Stone = 010,     -- Brown
        Earth = 010,     -- Brown (alias for Stone)
        Water = 056,     -- Light Blue
        Blizzard = 005,  -- Blue (same as Ice)
        Light = 001,     -- White
        Dark = 201       -- Purple
    }
    
    local color_code = element_colors[element_name] or 001 -- Default to white if not found
    local gray_code = string.char(0x1F, 160) -- Light gray for "Current:"
    local colored_element = string.char(0x1F, color_code) .. element_name .. string.char(0x1F, 001)
    
    -- Create custom formatted message matching PLD rune format
    local formatted_msg = gray_code .. "Current " .. state_type .. ": " .. colored_element
    MessageCore.info("BLM", formatted_msg)
end

return MessageBLM