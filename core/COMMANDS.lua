---============================================================================
--- FFXI GearSwap Core Module - Dynamic Command Router
---============================================================================
--- Lightweight command router that dynamically loads job-specific command
--- handlers only when needed. Provides optimal memory usage and clean
--- separation of job-specific functionality.
---
--- @file core/COMMANDS.lua
--- @author Tetsouo
--- @version 3.0
--- @date Created: 2025-01-05 | Modified: 2025-08-20
--- @requires utils/logger
---============================================================================

local CommandUtils = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- Cache for loaded command modules
local command_modules = {}

-- ===========================================================================================================
--                                     Dynamic Module Loading
-- ===========================================================================================================

--- Loads a job-specific command module on demand
-- @param job (string): Job name (BLM, BRD, etc.)
-- @return (table|nil): Command module or nil if failed
local function load_job_commands(job)
    if command_modules[job] then
        return command_modules[job]
    end

    local module_path = 'commands/' .. job .. '_COMMANDS'
    local success, module = pcall(require, module_path)

    if success then
        command_modules[job] = module
        log.debug("Loaded command module: %s", module_path)
        return module
    else
        log.warn("Failed to load command module %s: %s", module_path, module)
        return nil
    end
end

--- Loads debug commands module on demand
-- @return (table|nil): Debug module or nil if failed
local function load_debug_commands()
    if command_modules.DEBUG then
        return command_modules.DEBUG
    end

    local success, module = pcall(require, 'commands/DEBUG_COMMANDS')

    if success then
        command_modules.DEBUG = module
        log.debug("Loaded debug command module")
        return module
    else
        log.warn("Failed to load debug commands: %s", module)
        return nil
    end
end

-- ===========================================================================================================
--                                     Command Delegation Functions
-- ===========================================================================================================

--- Delegates BLM commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_blm_commands(cmdParams)
    local module = load_job_commands('BLM')
    return module and module.handle_blm_commands(cmdParams) or false
end

--- Delegates BRD commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_brd_commands(cmdParams)
    local module = load_job_commands('BRD')
    return module and module.handle_brd_commands(cmdParams) or false
end

--- Delegates WAR commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_war_commands(cmdParams)
    local module = load_job_commands('WAR')
    return module and module.handle_war_commands(cmdParams) or false
end

--- Delegates THF commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_thf_commands(cmdParams)
    local module = load_job_commands('THF')
    return module and module.handle_thf_commands(cmdParams) or false
end

--- Delegates PLD commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_pld_commands(cmdParams)
    local module = load_job_commands('PLD')
    return module and module.handle_pld_commands(cmdParams) or false
end

--- Delegates BST commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_bst_commands(cmdParams)
    local module = load_job_commands('BST')
    return module and module.handle_bst_commands(cmdParams) or false
end

--- Delegates DNC commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_dnc_commands(cmdParams)
    local module = load_job_commands('DNC')
    return module and module.handle_dnc_commands(cmdParams) or false
end

--- Delegates DRG commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_drg_commands(cmdParams)
    local module = load_job_commands('DRG')
    return module and module.handle_drg_commands(cmdParams) or false
end

--- Delegates RUN commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_run_commands(cmdParams)
    local module = load_job_commands('RUN')
    return module and module.handle_run_commands(cmdParams) or false
end

--- Delegates SCH subjob commands to the job-specific handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_sch_subjob_commands(cmdParams)
    local module = load_job_commands('SCH')
    return module and module.handle_sch_subjob_commands(cmdParams) or false
end

--- Handles debug commands
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function CommandUtils.handle_debug_commands(cmdParams)
    local module = load_debug_commands()
    return module and module.handle_debug_commands(cmdParams) or false
end

-- ===========================================================================================================
--                                     Smart Command Processing
-- ===========================================================================================================

--- Processes a command string and delegates to appropriate handler
-- @param command (string): The full command string
-- @return (boolean): True if command was handled, false otherwise
function CommandUtils.process_command(command)
    if not command or type(command) ~= 'string' then
        log.error("Invalid command: %s", tostring(command))
        return false
    end

    -- Parse command into parameters
    local cmdParams = {}
    for word in command:gmatch("%S+") do
        table.insert(cmdParams, word)
    end

    if #cmdParams == 0 then
        log.error("Empty command")
        return false
    end

    -- Try debug commands first (they can apply to any job)
    if cmdParams[1]:lower():match("^debug") or
        cmdParams[1]:lower():match("^alt") or
        cmdParams[1]:lower() == "clearsongs" or
        cmdParams[1]:lower() == "analyze" then
        if CommandUtils.handle_debug_commands(cmdParams) then
            return true
        end
    end

    -- Then try job-specific handlers based on current job
    if player and player.main_job then
        local job = player.main_job:upper()

        if job == 'BLM' then
            return CommandUtils.handle_blm_commands(cmdParams)
        elseif job == 'BRD' then
            return CommandUtils.handle_brd_commands(cmdParams)
        elseif job == 'WAR' then
            return CommandUtils.handle_war_commands(cmdParams)
        elseif job == 'THF' then
            return CommandUtils.handle_thf_commands(cmdParams)
        elseif job == 'PLD' then
            return CommandUtils.handle_pld_commands(cmdParams)
        elseif job == 'BST' then
            return CommandUtils.handle_bst_commands(cmdParams)
        elseif job == 'DNC' then
            return CommandUtils.handle_dnc_commands(cmdParams)
        elseif job == 'DRG' then
            return CommandUtils.handle_drg_commands(cmdParams)
        elseif job == 'RUN' then
            return CommandUtils.handle_run_commands(cmdParams)
        end
    end

    -- Check for SCH subjob commands
    if player and player.sub_job and player.sub_job:upper() == 'SCH' then
        if CommandUtils.handle_sch_subjob_commands(cmdParams) then
            return true
        end
    end

    log.debug("Command not handled: %s", cmdParams[1])
    return false
end

-- ===========================================================================================================
--                                     Command Functions Mapping
-- ===========================================================================================================

-- Map of command functions for backward compatibility
CommandUtils.commandFunctions = {
    handle_blm_commands = CommandUtils.handle_blm_commands,
    handle_brd_commands = CommandUtils.handle_brd_commands,
    handle_war_commands = CommandUtils.handle_war_commands,
    handle_thf_commands = CommandUtils.handle_thf_commands,
    handle_pld_commands = CommandUtils.handle_pld_commands,
    handle_bst_commands = CommandUtils.handle_bst_commands,
    handle_dnc_commands = CommandUtils.handle_dnc_commands,
    handle_drg_commands = CommandUtils.handle_drg_commands,
    handle_run_commands = CommandUtils.handle_run_commands,
    handle_sch_subjob_commands = CommandUtils.handle_sch_subjob_commands,
    handle_debug_commands = CommandUtils.handle_debug_commands
}

--- Gets a list of available commands for the current job
-- @return (table): List of available command names
function CommandUtils.get_available_commands()
    local commands = {}

    -- Add debug commands (always available)
    table.insert(commands, "debugstate")
    table.insert(commands, "debugbuffs")
    table.insert(commands, "debugequip")
    table.insert(commands, "debugrecast")
    table.insert(commands, "debugplayer")
    table.insert(commands, "debugmode")

    -- Add job-specific commands based on current job
    if player and player.main_job then
        local job = player.main_job:upper()

        if job == 'BLM' then
            table.insert(commands, "buffself")
            table.insert(commands, "mainlight")
            table.insert(commands, "sublight")
            table.insert(commands, "maindark")
            table.insert(commands, "subdark")
            table.insert(commands, "aja")
            table.insert(commands, "altlight")
            table.insert(commands, "altdark")
        elseif job == 'BRD' then
            table.insert(commands, "dummy")
            table.insert(commands, "songs")
            table.insert(commands, "smart")
            table.insert(commands, "honormarch")
            table.insert(commands, "aria")
            table.insert(commands, "clearsongs")
            table.insert(commands, "debugsongs")
            table.insert(commands, "analyze")
        elseif job == 'WAR' then
            table.insert(commands, "berserk")
            table.insert(commands, "defender")
            table.insert(commands, "thirdeye")
            table.insert(commands, "jump")
        elseif job == 'THF' then
            table.insert(commands, "thfbuff")
            table.insert(commands, "buff")
            table.insert(commands, "warbuff")
            table.insert(commands, "smartbuff")
            table.insert(commands, "macros")
            table.insert(commands, "altgeo")
            table.insert(commands, "altindi")
            table.insert(commands, "altjob")
            table.insert(commands, "altcast")
        end
        -- Additional jobs can be added here as needed
    end

    -- Add SCH subjob commands if applicable
    if player and player.sub_job and player.sub_job:upper() == 'SCH' then
        table.insert(commands, "storm")
        table.insert(commands, "lightarts")
        table.insert(commands, "darkarts")
        table.insert(commands, "blindna")
        table.insert(commands, "poisona")
        table.insert(commands, "paralyna")
        table.insert(commands, "cursna")
        table.insert(commands, "erase")
        table.insert(commands, "dispel")
    end

    return commands
end

log.info("Commands module loaded - Dynamic Router version 3.0")
log.debug("Job commands loaded on-demand from /commands/ directory")

return CommandUtils
