---============================================================================
--- FFXI GearSwap BRD Refresh Module
---============================================================================
--- Handles song refresh functionality with intelligent counting and optimization.
--- Provides refresh logic that maintains current song counts without full rotations.
---
--- @file jobs/brd/modules/brd_refresh.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires BRD_CONFIG, BRDAbilities, BRDSongCounter, MessageUtils
---============================================================================

-- Load dependencies
local success_BRD_CONFIG, BRD_CONFIG = pcall(require, 'jobs/brd/BRD_CONFIG')
if not success_BRD_CONFIG then
    error("Failed to load jobs/brd/BRD_CONFIG: " .. tostring(BRD_CONFIG))
end
local success_BRDAbilities, BRDAbilities = pcall(require, 'jobs/brd/modules/BRD_ABILITIES')
if not success_BRDAbilities then
    error("Failed to load jobs/brd/modules/brd_abilities: " .. tostring(BRDAbilities))
end
local success_BRDSongCounter, BRDSongCounter = pcall(require, 'jobs/brd/modules/BRD_SONG_COUNTER')
if not success_BRDSongCounter then
    error("Failed to load jobs/brd/modules/brd_song_counter: " .. tostring(BRDSongCounter))
end
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
local success_BRDUtils, BRDUtils = pcall(require, 'jobs/brd/modules/brd_utils')
if not success_BRDUtils then
    error("Failed to load jobs/brd/modules/brd_utils: " .. tostring(BRDUtils))
end

local BRDRefresh = {}


---============================================================================
--- REFRESH FUNCTIONS
---============================================================================

--- Refresh songs (recast the default set) with intelligent song counting
--- @param pack_name string Optional pack name, defaults to current BRDRotation
function BRDRefresh.refresh_songs(pack_name)
    -- Use provided pack name or current BRDRotation
    local set_name = pack_name or (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local buff_songs = BRDUtils.get_song_pack(set_name)

    -- Fast song counting via BRDSongCounter module
    local current_song_count, active_families = BRDSongCounter.count_active_songs()

    -- For refresh, maintain the current number of songs (don't add more)
    local total_songs = current_song_count > 0 and current_song_count or 4

    -- Inform user about song count decision
    MessageUtils.brd_message("Refresh", "Songs",
        "Detected " .. current_song_count .. " active, refreshing " .. total_songs .. " (fast mode)")

    -- Set to Party mode
    BRDUtils.set_song_mode('Party')

    -- Check if first song is Honor March and use Marcato if available
    local marcato_used = false
    if buff_songs[1] == 'Honor March' then
        if BRDAbilities.is_marcato_available() then
            send_command('input /ja "Marcato" <me>')
            marcato_used = true
        end
    end

    -- Cast songs with delays
    local song_delay = BRDUtils.get_song_delay()

    for i = 1, total_songs do
        if buff_songs[i] then
            local delay = (i - 1) * song_delay
            if marcato_used then
                delay = delay + BRD_CONFIG.TIMINGS.marcato_delay
            end
            send_command('wait ' .. delay .. '; input /ma "' .. buff_songs[i] .. '" <me>')
        end
    end

    local song_list = {}
    for i = 1, total_songs do
        if buff_songs[i] then
            table.insert(song_list, BRDUtils.shorten_song_name(buff_songs[i]))
        end
    end
    MessageUtils.brd_song_rotation_with_separator(song_list, set_name .. " Songs (" .. total_songs .. ")", true)
end

--- Refresh melee songs (party buffs) with intelligent counting
function BRDRefresh.refresh_melee_songs()
    BRDRefresh.refresh_songs()
end

--- Generic refresh function for specific packs
--- @param pack_name string Song pack name ('Tank', 'Healer', etc.)
--- @param display_name string Display name for messages
local function refresh_pack_songs(pack_name, display_name)
    MessageUtils.brd_message("BRD", display_name .. " Refresh", "Starting...")

    -- Get specified pack
    local buff_songs = BRDUtils.get_song_pack(pack_name)

    -- Fast song counting via BRDSongCounter module
    local current_song_count, active_families = BRDSongCounter.count_active_songs()
    local total_songs = current_song_count > 0 and current_song_count or 4

    MessageUtils.brd_message(display_name .. " Refresh", "Songs",
        "Detected " .. current_song_count .. " active, casting " .. total_songs .. " (fast mode)")

    -- Set to Party mode
    BRDUtils.set_song_mode('Party')

    -- Get dynamic song delay
    local song_delay = BRDUtils.get_song_delay()

    -- Cast songs with delays
    for i = 1, total_songs do
        if buff_songs[i] then
            send_command('wait ' .. ((i - 1) * song_delay) .. '; input /ma "' .. buff_songs[i] .. '" <me>')
        end
    end

    local song_list = {}
    for i = 1, total_songs do
        if buff_songs[i] then
            table.insert(song_list, BRDUtils.shorten_song_name(buff_songs[i]))
        end
    end
    MessageUtils.brd_song_rotation_with_separator(song_list, display_name .. " Songs (" .. total_songs .. ")", true)
end

--- Refresh tank songs (party buffs using Tank pack) with intelligent counting
function BRDRefresh.refresh_tank_songs()
    refresh_pack_songs('Tank', 'Tank')
end

--- Refresh healer songs (party buffs using Healer pack) with intelligent counting
function BRDRefresh.refresh_healer_songs()
    refresh_pack_songs('Healer', 'Healer')
end

--- Refresh Carol songs (party buffs using Carol pack) with intelligent counting
function BRDRefresh.refresh_carol_songs()
    refresh_pack_songs('Carol', 'Carol')
end

--- Refresh Scherzo songs (party buffs using Scherzo pack) with intelligent counting
function BRDRefresh.refresh_scherzo_songs()
    refresh_pack_songs('Scherzo', 'Scherzo')
end

return BRDRefresh
