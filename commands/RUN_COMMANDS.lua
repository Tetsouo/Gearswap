---============================================================================
--- FFXI GearSwap Commands - Rune Fencer (RUN) Specific Commands
---============================================================================
--- Rune Fencer command handlers for rune management, defensive spells,
--- tanking abilities, and enmity generation.
---
--- @file commands/RUN_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local RUNCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Rune Fencer Commands
-- ===========================================================================================================

--- Handles commands specific to the Rune Fencer (RUN) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function RUNCommands.handle_run_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for RUN")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("RUN command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local runCommands = {
        ignis = function()
            send_command('input /ja "Ignis" <me>')
            return true
        end,
        gelus = function()
            send_command('input /ja "Gelus" <me>')
            return true
        end,
        flabra = function()
            send_command('input /ja "Flabra" <me>')
            return true
        end,
        tellus = function()
            send_command('input /ja "Tellus" <me>')
            return true
        end,
        sulpor = function()
            send_command('input /ja "Sulpor" <me>')
            return true
        end,
        unda = function()
            send_command('input /ja "Unda" <me>')
            return true
        end,
        lux = function()
            send_command('input /ja "Lux" <me>')
            return true
        end,
        tenebrae = function()
            send_command('input /ja "Tenebrae" <me>')
            return true
        end,
        vallation = function()
            send_command('input /ja "Vallation" <me>')
            return true
        end,
        valiance = function()
            send_command('input /ja "Valiance" <me>')
            return true
        end,
        pflug = function()
            send_command('input /ja "Pflug" <me>')
            return true
        end,
        swordplay = function()
            send_command('input /ja "Swordplay" <me>')
            return true
        end,
        embolden = function()
            send_command('input /ja "Embolden" <me>')
            return true
        end,
        vivacious = function()
            send_command('input /ja "Vivacious Pulse" <me>')
            return true
        end,
        gambit = function()
            send_command('input /ja "Gambit" <me>')
            return true
        end,
        rayke = function()
            send_command('input /ja "Rayke" <t>')
            return true
        end,
        liement = function()
            send_command('input /ja "Liement" <me>')
            return true
        end,
        battuta = function()
            send_command('input /ja "Battuta" <me>')
            return true
        end,
        lunge = function()
            send_command('input /ja "Lunge" <t>')
            return true
        end,
        swipe = function()
            send_command('input /ja "Swipe" <t>')
            return true
        end
    }

    if runCommands[cmd] then
        local success = runCommands[cmd]()
        if success then
            log.info("Executed RUN command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown RUN command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_run_commands = RUNCommands.handle_run_commands

return RUNCommands
