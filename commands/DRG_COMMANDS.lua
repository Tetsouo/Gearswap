---============================================================================
--- FFXI GearSwap Commands - Dragoon (DRG) Specific Commands
---============================================================================
--- Dragoon command handlers for jump abilities, wyvern coordination,
--- polearm skills, and pet management.
---
--- @file commands/DRG_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local DRGCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Dragoon Commands
-- ===========================================================================================================

--- Handles commands specific to the Dragoon (DRG) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function DRGCommands.handle_drg_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for DRG")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("DRG command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local drgCommands = {
        jump = function()
            send_command('input /ja "Jump" <t>')
            return true
        end,
        highjump = function()
            send_command('input /ja "High Jump" <t>')
            return true
        end,
        superjump = function()
            send_command('input /ja "Super Jump" <me>')
            return true
        end,
        spiritjump = function()
            send_command('input /ja "Spirit Jump" <t>')
            return true
        end,
        soulsiphon = function()
            send_command('input /ja "Soul Jump" <t>')
            return true
        end,
        call = function()
            -- Call wyvern
            send_command('input /ja "Call Wyvern" <me>')
            return true
        end,
        dismiss = function()
            -- Dismiss wyvern
            send_command('input /ja "Dismiss" <me>')
            return true
        end,
        breath = function()
            -- Healing breath
            send_command('input /ja "Healing Breath" <me>')
            return true
        end,
        restorebreath = function()
            send_command('input /ja "Restoring Breath" <me>')
            return true
        end,
        barrier = function()
            send_command('input /ja "Steady Wing" <me>')
            return true
        end,
        ancient = function()
            send_command('input /ja "Ancient Circle" <me>')
            return true
        end,
        lance = function()
            send_command('input /ja "Lance Charge" <me>')
            return true
        end,
        fly = function()
            send_command('input /ja "Spirit Link" <me>')
            return true
        end
    }

    if drgCommands[cmd] then
        local success = drgCommands[cmd]()
        if success then
            log.info("Executed DRG command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown DRG command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_drg_commands = DRGCommands.handle_drg_commands

return DRGCommands
