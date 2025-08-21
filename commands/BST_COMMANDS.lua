---============================================================================
--- FFXI GearSwap Commands - Beastmaster (BST) Specific Commands
---============================================================================
--- Beastmaster command handlers for pet management, ecosystem cycling,
--- species changing, and Ready move coordination.
---
--- @file commands/BST_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local BSTCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Beastmaster Commands
-- ===========================================================================================================

--- Handles commands specific to the Beastmaster (BST) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function BSTCommands.handle_bst_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for BST")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("BST command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local bstCommands = {
        ecosystem = function()
            -- Cycle through ecosystems (F4 functionality)
            if state and state.PetEcosystem and state.PetEcosystem.cycle then
                state.PetEcosystem:cycle()
                universal_message("BST", "status", "Ecosystem changed", state.PetEcosystem.value, nil, nil, nil)
                return true
            else
                log.error("PetEcosystem state not available")
                return false
            end
        end,
        species = function()
            -- Cycle through species (F5 functionality)  
            if state and state.PetSpecies and state.PetSpecies.cycle then
                state.PetSpecies:cycle()
                universal_message("BST", "status", "Species changed", state.PetSpecies.value, nil, nil, nil)
                return true
            else
                log.error("PetSpecies state not available")
                return false
            end
        end,
        charm = function()
            send_command('input /ja "Charm" <t>')
            return true
        end,
        call = function()
            -- Call pet based on current ecosystem/species
            if state and state.PetEcosystem and state.PetSpecies then
                local pet_command = string.format('input /ja "Call Beast" <me>')
                send_command(pet_command)
                return true
            else
                send_command('input /ja "Call Beast" <me>')
                return true
            end
        end,
        reward = function()
            send_command('input /ja "Reward" <me>')
            return true
        end,
        ready = function()
            -- Use Ready move
            send_command('input /ja "Ready" <t>')
            return true
        end,
        sic = function()
            send_command('input /ja "Sic" <t>')
            return true
        end,
        stay = function()
            send_command('input /ja "Stay" <me>')
            return true
        end,
        heel = function()
            send_command('input /ja "Heel" <me>')
            return true
        end
    }

    if bstCommands[cmd] then
        local success = bstCommands[cmd]()
        if success then
            log.info("Executed BST command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown BST command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_bst_commands = BSTCommands.handle_bst_commands

return BSTCommands
