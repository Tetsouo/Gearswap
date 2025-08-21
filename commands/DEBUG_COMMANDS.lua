---============================================================================
--- FFXI GearSwap Core Module - Debug Command Handlers
---============================================================================
--- Debug and diagnostic commands for troubleshooting job configurations,
--- analyzing states, and testing functionality. Provides tools for developers
--- and advanced users to diagnose issues.
---
--- @file core/DEBUG_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local DebugCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Debug and Analysis Commands
-- ===========================================================================================================

--- Handles debug-related commands for BRD song tracking
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function DebugCommands.handle_brd_debug_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    local cmd = cmdParams[1]:lower()

    local debugCommands = {
        clearsongs = function()
            -- Clear song tracker when sync issues occur
            if clear_song_tracker then
                clear_song_tracker()
                log.info("[DEBUG] Song tracker cleared")
                return true
            else
                log.error("[DEBUG] clear_song_tracker function not available")
                return false
            end
        end,
        debugsongs = function()
            -- Show current song tracker state
            if debug_song_tracker then
                debug_song_tracker()
                log.info("[DEBUG] Song tracker debug output displayed")
                return true
            else
                log.error("[DEBUG] debug_song_tracker function not available")
                return false
            end
        end,
        analyze = function()
            -- Analyze current active songs using all detection methods
            if analyze_active_songs then
                local analysis = analyze_active_songs()
                log.info("[DEBUG] Song analysis complete - check chat for details")
                return true
            else
                log.error("[DEBUG] analyze_active_songs function not available")
                return false
            end
        end,
        analyze_silent = function()
            -- Silent analysis for automatic desync checking
            if analyze_songs_silent then
                analyze_songs_silent()
                log.debug("[DEBUG] Silent song analysis performed")
                return true
            else
                log.error("[DEBUG] analyze_songs_silent function not available")
                return false
            end
        end
    }

    if debugCommands[cmd] then
        return debugCommands[cmd]()
    end

    return false
end

--- Handles alt player debug commands (from THF)
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function DebugCommands.handle_alt_debug_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- Load dependencies
    local success_config, config = pcall(require, 'config/config')
    local success_DualBox, DualBoxUtils = pcall(require, 'features/DUALBOX')

    local altDebugCommands = {
        altquery = function()
            -- Test the send command job query
            if not success_config or not success_DualBox then
                log.error("[DEBUG] Dependencies not available for altquery")
                return false
            end

            local alt_name = config and config.get_alt_player() or 'Kaories'

            if not DualBoxUtils then
                log.error("[DEBUG] DualBoxUtils not available")
                return false
            end

            add_to_chat(123, '[Alt Query DEBUG] Sending job query to ' .. alt_name .. '...')
            DualBoxUtils.query_alt_job()
            add_to_chat(123, '[Alt Query DEBUG] Wait for response: [ALTJOB_RESPONSE_xxxxx] JOB_NAME')
            log.info("[DEBUG] Alt job query sent to %s", alt_name)
            return true
        end,
        altsetjob = function()
            -- Manually set alt job (debug workaround for detection issues)
            if not success_config or not success_DualBox then
                log.error("[DEBUG] Dependencies not available for altsetjob")
                return false
            end

            local job = cmdParams[2]
            if not job then
                add_to_chat(167, '[Alt Set Job DEBUG] Usage: //gs c altsetjob <job_name>')
                add_to_chat(123, '[Alt Set Job DEBUG] Examples: GEO, WHM, RDM, SCH')
                return false
            end

            job = job:upper() -- Convert to uppercase

            if DualBoxUtils and DualBoxUtils.update_alt_job then
                DualBoxUtils.update_alt_job(job)
                add_to_chat(207,
                    '[Alt Set Job DEBUG] Manually set ' ..
                    (config and config.get_alt_player() or 'Kaories') .. ' job to: ' .. job)
                log.info("[DEBUG] Alt job manually set to %s", job)
                return true
            else
                log.error("[DEBUG] DualBoxUtils.update_alt_job not available")
                return false
            end
        end
    }

    if altDebugCommands[cmd] then
        return altDebugCommands[cmd]()
    end

    return false
end

--- Handles general debug commands
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function DebugCommands.handle_general_debug_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        return false
    end

    local cmd = cmdParams[1]:lower()

    local generalDebugCommands = {
        debugstate = function()
            -- Display current state values
            if state then
                log.info("[DEBUG] === Current State Values ===")
                for key, value in pairs(state) do
                    if type(value) == 'table' and value.value then
                        log.info("[DEBUG] %s: %s", key, tostring(value.value))
                    end
                end
                add_to_chat(123, '[DEBUG] State values logged to console')
                return true
            else
                log.error("[DEBUG] State not available")
                return false
            end
        end,
        debugbuffs = function()
            -- Display current active buffs
            if buffactive then
                log.info("[DEBUG] === Active Buffs ===")
                local buff_count = 0
                for buff_name, is_active in pairs(buffactive) do
                    if is_active then
                        log.info("[DEBUG] %s: active", buff_name)
                        buff_count = buff_count + 1
                    end
                end
                add_to_chat(123, string.format('[DEBUG] %d active buffs logged to console', buff_count))
                return true
            else
                log.error("[DEBUG] Buffactive not available")
                return false
            end
        end,
        debugequip = function()
            -- Display current equipment
            if player and player.equipment then
                log.info("[DEBUG] === Current Equipment ===")
                for slot, item in pairs(player.equipment) do
                    log.info("[DEBUG] %s: %s", slot, tostring(item))
                end
                add_to_chat(123, '[DEBUG] Equipment logged to console')
                return true
            else
                log.error("[DEBUG] Player equipment not available")
                return false
            end
        end,
        debugrecast = function()
            -- Display spell and ability recast times
            log.info("[DEBUG] === Recast Times ===")

            -- Ability recasts
            if windower and windower.ffxi and windower.ffxi.get_ability_recasts then
                local ability_recasts = windower.ffxi.get_ability_recasts()
                local active_recasts = 0
                for id, time in pairs(ability_recasts) do
                    if time > 0 then
                        log.info("[DEBUG] Ability %d: %d seconds", id, time)
                        active_recasts = active_recasts + 1
                    end
                end
                add_to_chat(123, string.format('[DEBUG] %d abilities on cooldown', active_recasts))
            end

            -- Spell recasts
            if windower and windower.ffxi and windower.ffxi.get_spell_recasts then
                local spell_recasts = windower.ffxi.get_spell_recasts()
                local active_spell_recasts = 0
                for id, time in pairs(spell_recasts) do
                    if time > 0 then
                        log.info("[DEBUG] Spell %d: %.1f seconds", id, time / 60)
                        active_spell_recasts = active_spell_recasts + 1
                    end
                end
                add_to_chat(123, string.format('[DEBUG] %d spells on cooldown', active_spell_recasts))
            end

            return true
        end,
        debugplayer = function()
            -- Display player information
            if player then
                log.info("[DEBUG] === Player Info ===")
                log.info("[DEBUG] Name: %s", player.name or "Unknown")
                log.info("[DEBUG] Job: %s/%s", player.main_job or "Unknown", player.sub_job or "None")
                log.info("[DEBUG] Level: %d/%d", player.main_job_level or 0, player.sub_job_level or 0)
                log.info("[DEBUG] HP: %d/%d", player.hp or 0, player.max_hp or 0)
                log.info("[DEBUG] MP: %d/%d", player.mp or 0, player.max_mp or 0)
                log.info("[DEBUG] TP: %d", player.tp or 0)
                log.info("[DEBUG] Status: %s", player.status or "Unknown")
                add_to_chat(123, '[DEBUG] Player info logged to console')
                return true
            else
                log.error("[DEBUG] Player info not available")
                return false
            end
        end,
        debugmode = function()
            -- Toggle debug mode if available
            if state and state.DebugMode then
                state.DebugMode:toggle()
                add_to_chat(123, '[DEBUG] Debug mode: ' .. state.DebugMode.value)
                log.info("[DEBUG] Debug mode toggled to: %s", state.DebugMode.value)
                return true
            else
                log.warn("[DEBUG] DebugMode state not available")
                return false
            end
        end
    }

    if generalDebugCommands[cmd] then
        return generalDebugCommands[cmd]()
    end

    return false
end

--- Main debug command handler
-- @param cmdParams (table): Command parameters
-- @return (boolean): True if handled, false otherwise
function DebugCommands.handle_debug_commands(cmdParams)
    -- Try each debug handler in order
    if DebugCommands.handle_brd_debug_commands(cmdParams) then
        return true
    end

    if DebugCommands.handle_alt_debug_commands(cmdParams) then
        return true
    end

    if DebugCommands.handle_general_debug_commands(cmdParams) then
        return true
    end

    -- Command not recognized as debug command
    return false
end

return DebugCommands
