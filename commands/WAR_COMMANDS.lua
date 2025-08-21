---============================================================================
--- FFXI GearSwap Commands - Warrior (WAR) Specific Commands
---============================================================================
--- Warrior command handlers for ability management, tanking mode switching,
--- and combat buff automation.
---
--- @file commands/WAR_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local WARCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Warrior Commands
-- ===========================================================================================================

--- Handles commands specific to the Warrior (WAR) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function WARCommands.handle_war_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for WAR")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("WAR command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- Use the real WAR functions if available
    local buffSelf_func = _G.buffSelf or function(ability)
        send_command('input /ja "' .. ability .. '" <me>')
    end

    local ThirdEye_func = _G.ThirdEye or function()
        send_command('input /ja "Third Eye" <me>')
    end

    local jump_func = _G.jump or function()
        send_command('input /ja "Jump" <t>')
    end

    local warCommands = {
        berserk = function()
            if buffactive['Defender'] then
                send_command('cancel defender')
            end
            buffSelf_func('Berserk')
            return true
        end,
        defender = function()
            if state and state.HybridMode and state.HybridMode.value == 'Normal' then
                send_command('gs c set HybridMode PDT')
            end
            if buffactive['Berserk'] then
                send_command('cancel berserk')
            end
            buffSelf_func('Defender')
            return true
        end,
        thirdeye = function()
            ThirdEye_func()
            return true
        end,
        jump = function()
            jump_func()
            return true
        end
    }

    if warCommands[cmd] then
        local success = warCommands[cmd]()
        if success then
            log.info("Executed WAR command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown WAR command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_war_commands = WARCommands.handle_war_commands

return WARCommands
