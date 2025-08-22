---============================================================================
--- FFXI GearSwap Messages - Dancer (DNC) Specific Messages
---============================================================================
--- Dancer-specific messaging functions for buff management and smartbuff
--- detection.
---
--- @file messages/jobs/MESSAGE_DNC.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageDNC = {}

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
--                                     DNC JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates DNC smartbuff detection message
-- @param sub_job (string): Detected subjob
function MessageDNC.dnc_smartbuff_detection_message(sub_job)
    if not sub_job then
        MessageCore.error("DNC", "Unable to detect subjob")
    else
        MessageCore.info("DNC", "Smartbuff: DNC/" .. sub_job .. " detected")
    end
end

--- Creates DNC smartbuff subjob message (matching original format exactly)
-- @param sub_job (string): Detected subjob
function MessageDNC.dnc_smartbuff_subjob_message(sub_job)
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
function MessageDNC.dnc_buff_execution_message(buffs, action_type, sub_job)
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

return MessageDNC