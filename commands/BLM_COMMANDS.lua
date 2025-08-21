---============================================================================
--- FFXI GearSwap Commands - Black Mage (BLM) Specific Commands
---============================================================================
--- Black Mage command handlers for elemental magic automation, spell tier
--- management, Magic Burst detection, and dual-boxing coordination.
---
--- @file commands/BLM_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local BLMCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Black Mage Commands
-- ===========================================================================================================

--- Handles Black Mage (BLM) commands based on the given command parameters.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function BLMCommands.handle_blm_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.error("Invalid BLM command parameters")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.error("BLM command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- Handle standard GearSwap cycle commands
    if cmd == 'cycle' and cmdParams[2] then
        local stateName = cmdParams[2]
        if state and state[stateName] and state[stateName].cycle then
            -- Let GearSwap handle the cycle natively to avoid conflicts
            return false -- Return false so it falls back to standard GearSwap handling
        else
            log.warn("Unknown state to cycle: %s", stateName)
            return false
        end
    end

    local spells = {
        buffself = function()
            if BuffSelf and type(BuffSelf) == 'function' then
                BuffSelf()
                return true
            else
                log.error("BuffSelf function not available")
                return false
            end
        end,
        mainlight = function()
            if castElementalSpells and state and state.MainLightSpell and state.TierSpell then
                castElementalSpells(state.MainLightSpell.value, state.TierSpell.value)
                return true
            else
                log.error("castElementalSpells or state not available for mainlight")
                return false
            end
        end,
        sublight = function()
            if castElementalSpells and state and state.SubLightSpell and state.TierSpell then
                castElementalSpells(state.SubLightSpell.value, state.TierSpell.value)
                return true
            else
                log.error("castElementalSpells or state not available for sublight")
                return false
            end
        end,
        maindark = function()
            if castElementalSpells and state and state.MainDarkSpell and state.TierSpell then
                castElementalSpells(state.MainDarkSpell.value, state.TierSpell.value)
                return true
            else
                log.error("castElementalSpells or state not available for maindark")
                return false
            end
        end,
        subdark = function()
            if castElementalSpells and state and state.SubDarkSpell and state.TierSpell then
                castElementalSpells(state.SubDarkSpell.value, state.TierSpell.value)
                return true
            else
                log.error("castElementalSpells or state not available for subdark")
                return false
            end
        end,
        aja = function()
            if castElementalSpells and state and state.Aja then
                castElementalSpells(state.Aja.value)
                return true
            else
                log.error("castElementalSpells or state.Aja not available")
                return false
            end
        end,
        update = function()
            -- Handle the update command - refresh current gear
            if job_handle_equipping_gear and type(job_handle_equipping_gear) == 'function' then
                job_handle_equipping_gear(player.status, nil)
                log.debug("Equipment updated via BLM update command")
                return true
            else
                log.debug("Update command called but job_handle_equipping_gear not available")
                return true -- Don't show error, this is normal
            end
        end,
        altlight = function()
            if handle_altNuke and state and state.MainLightSpell and state.TierSpell then
                -- RDM can only cast up to tier V, so limit the tier
                local tierToUse = state.TierSpell.value
                if tierToUse == 'VI' then
                    tierToUse = 'V'
                    log.debug("Limiting spell tier to V for RDM alt")
                end
                handle_altNuke(state.MainLightSpell.value, tierToUse, false)
                log.info("Alt casting Light spell: %s %s", state.MainLightSpell.value, tierToUse)
                return true
            else
                log.error("handle_altNuke or state not available for altlight")
                return false
            end
        end,
        altdark = function()
            if handle_altNuke and state and state.MainDarkSpell and state.TierSpell then
                -- RDM can only cast up to tier V, so limit the tier
                local tierToUse = state.TierSpell.value
                if tierToUse == 'VI' then
                    tierToUse = 'V'
                    log.debug("Limiting spell tier to V for RDM alt")
                end
                handle_altNuke(state.MainDarkSpell.value, tierToUse, false)
                log.info("Alt casting Dark spell: %s %s", state.MainDarkSpell.value, tierToUse)
                return true
            else
                log.error("handle_altNuke or state not available for altdark")
                return false
            end
        end
    }

    if spells[cmd] then
        local success = spells[cmd]()
        if success then
            log.info("Executed BLM command: %s", cmd)
        end
        return success
    else
        -- Don't warn about unknown commands, they might be handled elsewhere
        log.debug("BLM command not found, trying other handlers: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_blm_commands = BLMCommands.handle_blm_commands

return BLMCommands
