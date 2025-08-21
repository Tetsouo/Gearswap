---============================================================================
--- FFXI GearSwap Commands - Dancer (DNC) Specific Commands
---============================================================================
--- Dancer command handlers for step rotations, flourishes, healing waltz,
--- and TP management automation.
---
--- @file commands/DNC_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local DNCCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Dancer Commands
-- ===========================================================================================================

--- Handles commands specific to the Dancer (DNC) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function DNCCommands.handle_dnc_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for DNC")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("DNC command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local dncCommands = {
        steps = function()
            -- Perform step rotation
            send_command('input /ja "Box Step" <t>; wait 2; input /ja "Quickstep" <t>')
            return true
        end,
        boxstep = function()
            send_command('input /ja "Box Step" <t>')
            return true
        end,
        quickstep = function()
            send_command('input /ja "Quickstep" <t>')
            return true
        end,
        featherstep = function()
            send_command('input /ja "Feather Step" <t>')
            return true
        end,
        stutter = function()
            send_command('input /ja "Stutter Step" <t>')
            return true
        end,
        flourish = function()
            -- Perform flourish combo
            send_command('input /ja "Violent Flourish" <t>')
            return true
        end,
        violent = function()
            send_command('input /ja "Violent Flourish" <t>')
            return true
        end,
        desperate = function()
            send_command('input /ja "Desperate Flourish" <t>')
            return true
        end,
        reverse = function()
            send_command('input /ja "Reverse Flourish" <me>')
            return true
        end,
        waltz = function()
            local target = cmdParams[2] or '<me>'
            if target == 'party' then
                send_command('input /ja "Divine Waltz" <me>')
            else
                send_command('input /ja "Curing Waltz III" ' .. target)
            end
            return true
        end,
        divine = function()
            send_command('input /ja "Divine Waltz" <me>')
            return true
        end,
        curing = function()
            local target = cmdParams[2] or '<me>'
            send_command('input /ja "Curing Waltz III" ' .. target)
            return true
        end,
        samba = function()
            send_command('input /ja "Haste Samba" <me>')
            return true
        end,
        drain = function()
            send_command('input /ja "Drain Samba III" <me>')
            return true
        end,
        aspir = function()
            send_command('input /ja "Aspir Samba" <me>')
            return true
        end
    }

    if dncCommands[cmd] then
        local success = dncCommands[cmd]()
        if success then
            log.info("Executed DNC command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown DNC command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_dnc_commands = DNCCommands.handle_dnc_commands

return DNCCommands
