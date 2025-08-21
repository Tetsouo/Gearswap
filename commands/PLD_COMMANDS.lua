---============================================================================
--- FFXI GearSwap Commands - Paladin (PLD) Specific Commands
---============================================================================
--- Paladin command handlers for tanking abilities, enmity control,
--- cure support, and defensive cooldown management.
---
--- @file commands/PLD_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local PLDCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Paladin Commands
-- ===========================================================================================================

--- Handles commands specific to the Paladin (PLD) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function PLDCommands.handle_pld_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for PLD")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("PLD command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local pldCommands = {
        provoke = function()
            send_command('input /ja "Provoke" <t>')
            return true
        end,
        sentinel = function()
            send_command('input /ja "Sentinel" <me>')
            return true
        end,
        cover = function()
            send_command('input /ja "Cover" <p1>')
            return true
        end,
        rampart = function()
            send_command('input /ja "Rampart" <me>')
            return true
        end,
        cure = function()
            local target = cmdParams[2] or '<t>'
            send_command('input /ma "Cure IV" ' .. target)
            return true
        end,
        flash = function()
            send_command('input /ma "Flash" <t>')
            return true
        end,
        enlight = function()
            send_command('input /ma "Enlight" <me>')
            return true
        end
    }

    if pldCommands[cmd] then
        local success = pldCommands[cmd]()
        if success then
            log.info("Executed PLD command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown PLD command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_pld_commands = PLDCommands.handle_pld_commands

return PLDCommands
