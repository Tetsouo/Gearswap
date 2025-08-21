---============================================================================
--- FFXI GearSwap Commands - Bard (BRD) Specific Commands
---============================================================================
--- Bard command handlers for song management, dummy song casting, song rotation
--- automation, and song tracking diagnostics.
---
--- @file commands/BRD_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger
---============================================================================

local BRDCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Bard Commands
-- ===========================================================================================================

--- Handles commands specific to the Bard (BRD) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function BRDCommands.handle_brd_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid command parameters for BRD")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("BRD command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- BRD-specific commands
    local brdCommands = {
        dummy = function()
            -- Cast dummy songs using current state or optional set number
            local set_num = cmdParams[2] -- Don't default to 1, let function handle it
            if cast_dummy_songs then
                cast_dummy_songs(set_num)
                return true
            else
                log.error("cast_dummy_songs function not available")
                return false
            end
        end,
        dummyset = function()
            -- Alias for dummy with set number
            local set_num = cmdParams[2] or 1
            if cast_dummy_songs then
                cast_dummy_songs(set_num)
                return true
            else
                log.error("cast_dummy_songs function not available")
                return false
            end
        end,
        honormarch = function()
            -- Force cast Honor March with Marsyas
            equip({ range = "Marsyas" })
            send_command('wait 0.5; input /ma "Honor March" <me>')
            return true
        end,
        aria = function()
            -- Force cast Aria of Passion with Loughnashade
            equip({ range = "Loughnashade" })
            send_command('wait 0.5; input /ma "Aria of Passion" <me>')
            return true
        end,
        songs = function()
            -- Cast real song set using current state or optional set name
            local set_name = cmdParams[2] -- Don't default, let function handle it
            if cast_song_set then
                cast_song_set(set_name)
                return true
            else
                log.error("cast_song_set function not available")
                return false
            end
        end,
        smart = function()
            -- Cast intelligent automatic song sequence (real songs -> dummies)
            local set_name = cmdParams[2] -- Optional set name
            if cast_smart_songs then
                cast_smart_songs(set_name)
                return true
            else
                log.error("cast_smart_songs function not available")
                return false
            end
        end,
        clearsongs = function()
            -- Clear song tracker when sync issues occur
            if clear_song_tracker then
                clear_song_tracker()
                log.info("[BRD] Song tracker cleared")
                return true
            else
                log.error("clear_song_tracker function not available")
                return false
            end
        end,
        debugsongs = function()
            -- Show current song tracker state
            if debug_song_tracker then
                debug_song_tracker()
                log.info("[BRD] Song tracker debug output displayed")
                return true
            else
                log.error("debug_song_tracker function not available")
                return false
            end
        end,
        analyze = function()
            -- Analyze current active songs using all detection methods
            if analyze_active_songs then
                local analysis = analyze_active_songs()
                log.info("[BRD] Song analysis complete - check chat for details")
                return true
            else
                log.error("analyze_active_songs function not available")
                return false
            end
        end,
        analyze_silent = function()
            -- Silent analysis for automatic desync checking
            if analyze_songs_silent then
                analyze_songs_silent()
                log.debug("[BRD] Silent song analysis performed")
                return true
            else
                log.error("analyze_songs_silent function not available")
                return false
            end
        end
    }

    if brdCommands[cmd] then
        local success = brdCommands[cmd]()
        if success then
            log.info("Executed BRD command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown BRD command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_brd_commands = BRDCommands.handle_brd_commands

return BRDCommands
