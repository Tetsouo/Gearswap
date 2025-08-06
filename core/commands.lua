---============================================================================
--- FFXI GearSwap Core Module - Command Processing Utilities
---============================================================================
--- Professional command processing system for GearSwap job configurations.
--- Provides centralized command parsing, job-specific command handlers, and
--- unified command execution with error handling. Core features include:
---
--- • **Job-Specific Command Handlers** - BLM, BST, THF specialized commands
--- • **Dual-Boxing Command Integration** - Multi-character coordination
--- • **Safe Command Execution** - Error handling and validation
--- • **State Management Integration** - Command-driven state changes
--- • **Spell Automation Commands** - Intelligent casting and targeting
--- • **Equipment Set Commands** - Dynamic gear set switching
--- • **Debug and Utility Commands** - Development and troubleshooting tools
---
--- This module serves as the command processing hub for all interactive
--- features across job configurations, enabling both macro and chat-based
--- command execution with comprehensive error handling and logging.
---
--- @file core/commands.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, core/dualbox
---
--- @usage
---   local CommandUtils = require('core/commands')
---   CommandUtils.handle_blm_commands({'mainlight'})
---   CommandUtils.handle_bst_commands({'ecosystem'})
---   CommandUtils.handle_thf_commands({'treasuremode', 'sata'})
---
--- @see core/dualbox.lua for multi-character command coordination
---============================================================================

local CommandUtils = {}

-- Load critical dependencies for command processing operations
local config = require('config/config')              -- Centralized configuration system
local log = require('utils/logger')                  -- Professional logging framework
local DualBoxUtils = require('core/dualbox')        -- Dual-boxing command coordination

-- ===========================================================================================================
--                                     Job-Specific Command Handlers
-- ===========================================================================================================

--- Handles Black Mage (BLM) commands based on the given command parameters.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function CommandUtils.handle_blm_commands(cmdParams)
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
            return false  -- Return false so it falls back to standard GearSwap handling
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
                return true  -- Don't show error, this is normal
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

--- Handles commands specific to the Scholar (SCH) subjob.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function CommandUtils.handle_sch_subjob_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.error("Invalid command parameters for SCH subjob")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.error("SCH command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local function castStormSpell(spell)
        if not buffactive['Klimaform'] and windower.ffxi.get_spell_recasts()[287] < 1 then
            send_command('input /ma "Klimaform" ; wait 5; input /ma "' .. spell .. '" ')
        else
            send_command('input /ma "' .. spell .. '" ')
        end
    end

    local function castArtsOrAddendum(arts, addendum)
        local command
        if not buffactive[arts] then
            command = 'input /ja "' .. arts .. '" <me>'
        else
            command = 'input /ja "' .. addendum .. '" <me>'
        end
        send_command(command)
    end

    local function castSchSpell(spell, arts, addendum)
        local SpellUtils = require('core/spells')
        return SpellUtils.cast_sch_spell(spell, arts, addendum)
    end

    local schSpells = {
        storm = function()
            if state and state.Storm then
                castStormSpell(state.Storm.value)
                return true
            else
                log.error("state.Storm not available")
                return false
            end
        end,
        lightarts = function()
            castArtsOrAddendum('Light Arts', 'Addendum: White')
            return true
        end,
        darkarts = function()
            castArtsOrAddendum('Dark Arts', 'Addendum: Black')
            return true
        end,
        blindna = function()
            castSchSpell('Blindna', 'Light Arts', 'Addendum: White')
            return true
        end,
        poisona = function()
            castSchSpell('Poisona', 'Light Arts', 'Addendum: White')
            return true
        end,
        viruna = function()
            castSchSpell('Viruna', 'Light Arts', 'Addendum: White')
            return true
        end,
        stona = function()
            castSchSpell('Stona', 'Light Arts', 'Addendum: White')
            return true
        end,
        silena = function()
            castSchSpell('Silena', 'Light Arts', 'Addendum: White')
            return true
        end,
        paralyna = function()
            castSchSpell('Paralyna', 'Light Arts', 'Addendum: White')
            return true
        end,
        cursna = function()
            castSchSpell('Cursna', 'Light Arts', 'Addendum: White')
            return true
        end,
        erase = function()
            castSchSpell('Erase', 'Light Arts', 'Addendum: White')
            return true
        end,
        dispel = function()
            castSchSpell('Dispel', 'Dark Arts', 'Addendum: Black')
            return true
        end,
        sneak = function()
            castSchSpell('Sneak', 'Light Arts', 'Accession')
            return true
        end,
        invi = function()
            castSchSpell('Invisible', 'Light Arts', 'Accession')
            return true
        end
    }

    if schSpells[cmd] then
        local success = schSpells[cmd]()
        if success then
            log.info("Executed SCH subjob command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown SCH subjob command: %s", cmd)
        return false
    end
end

--- Handles commands specific to the Warrior (WAR) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function CommandUtils.handle_war_commands(cmdParams)
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

--- Handles commands specific to the Thief (THF) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function CommandUtils.handle_thf_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid THF command parameters")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("THF command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- Use the real THF buffSelf function if available
    local buffSelf_func = _G.buffSelf or function(ability)
        send_command('input /ja "' .. ability .. '" <me>')
    end

    local thfCommands = {
        thfbuff = function()
            -- THF buffSelf expects 'thfBuff' as parameter to chain Feint, Bully, Conspirator
            buffSelf_func('thfBuff')
            return true
        end,
        buff = function()
            -- Alias for thfbuff
            buffSelf_func('thfBuff')
            return true
        end
    }

    if thfCommands[cmd] then
        local success, err = pcall(thfCommands[cmd])
        if success then
            log.info("Executed THF command: %s", cmd)
            return true
        else
            log.error("Error executing THF command %s: %s", cmd, err)
            return false
        end
    else
        log.debug("Unknown THF command: %s", cmd)
        return false
    end
end

-- ===========================================================================================================
--                                     Command Functions Mapping
-- ===========================================================================================================

-- Map of command functions for easy access and extension
CommandUtils.commandFunctions = {
    handle_blm_commands = CommandUtils.handle_blm_commands,
    handle_sch_subjob_commands = CommandUtils.handle_sch_subjob_commands,
    handle_war_commands = CommandUtils.handle_war_commands,
    handle_thf_commands = CommandUtils.handle_thf_commands
}

return CommandUtils
