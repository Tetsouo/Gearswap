---============================================================================
--- FFXI GearSwap BRD Debug & Monitoring Module
---============================================================================
--- Handles debug functionality, packet monitoring, and status display for BRD.
--- Provides comprehensive debugging tools and monitoring capabilities with
--- minimal performance impact for real-time song tracking.
---
--- @file jobs/brd/modules/brd_debug.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires BRDSongCounter, BRDAbilities
---============================================================================

-- Load dependencies
local success_BRDSongCounter, BRDSongCounter = pcall(require, 'jobs/brd/modules/BRD_SONG_COUNTER')
if not success_BRDSongCounter then
    error("Failed to load jobs/brd/modules/brd_song_counter: " .. tostring(BRDSongCounter))
end
local success_BRDAbilities, BRDAbilities = pcall(require, 'jobs/brd/modules/BRD_ABILITIES')
if not success_BRDAbilities then
    error("Failed to load jobs/brd/modules/brd_abilities: " .. tostring(BRDAbilities))
end
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

local BRDDebug = {}

-- Helper function for debug output
local function debug_print(message, color)
    if MessageUtils.brd_debug_message then
        MessageUtils.brd_debug_message(message)
    else
        -- Use unified message system
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        local messages = { { type = 'info', name = 'Debug', message = message } }
        MessageUtils.unified_status_message(messages, nil, true)
    end
end

-- Monitoring state variables
local packet_debug_enabled = false
local last_song_count = 0
local last_song_families = {}
local packet_event_id = nil

---============================================================================
--- PACKET MONITORING FUNCTIONS
---============================================================================

--- Optimized packet parser - minimal processing
--- @param data string Raw packet data
--- @return table List of buff IDs found in packet
local function parse_status_packet_lightweight(data)
    local buff_ids = {}
    local buff_count = data:byte(5) or 0

    -- Only parse if we have a reasonable number of buffs
    if buff_count > 50 then return buff_ids end

    for i = 0, buff_count - 1 do
        local offset = 9 + (i * 2)
        if offset + 1 <= #data then
            local buff_id = data:byte(offset) + (data:byte(offset + 1) * 256)
            if buff_id > 0 then
                table.insert(buff_ids, buff_id)
            end
        end
    end

    return buff_ids
end

--- Toggle lightweight packet monitoring for song changes
function BRDDebug.toggle_packet_debug()
    packet_debug_enabled = not packet_debug_enabled

    if packet_debug_enabled then
        debug_print('[MONITOR] Song monitoring ENABLED (lightweight mode)')

        -- Store event ID for potential cleanup
        packet_event_id = windower.register_event('incoming chunk', function(id, data, modified, injected, blocked)
            if not packet_debug_enabled then return end

            -- Only process status packets and limit frequency
            if id == 0x063 then
                local buff_ids = parse_status_packet_lightweight(data)

                if #buff_ids > 0 then
                    local song_counts = {}
                    local total_songs = 0

                    -- Use BRDSongCounter for consistent counting
                    local current_count, current_families = BRDSongCounter.count_active_songs()

                    -- Only report changes in song count or composition
                    local changed = (current_count ~= last_song_count)
                    if not changed then
                        for family, count in pairs(current_families) do
                            if last_song_families[family] ~= count then
                                changed = true
                                break
                            end
                        end
                        for family, count in pairs(last_song_families) do
                            if current_families[family] ~= count then
                                changed = true
                                break
                            end
                        end
                    end

                    if changed then
                        debug_print('[MONITOR] Songs: ' .. current_count .. ' active')

                        -- Brief summary of active families
                        local active_families = {}
                        for family_id, count in pairs(current_families) do
                            table.insert(active_families, 'ID' .. family_id .. ':' .. count)
                        end

                        if #active_families > 0 then
                            debug_print('[MONITOR] Active: ' .. table.concat(active_families, ', '))
                        end

                        -- Update tracking variables
                        last_song_count = current_count
                        last_song_families = current_families
                    end
                end
            end
        end)
    else
        debug_print('[MONITOR] Song monitoring DISABLED')
        packet_event_id = nil
    end
end

--- Show current song status from packet monitoring
function BRDDebug.show_packet_song_status()
    debug_print('[MONITOR] === CURRENT SONG STATUS ===')
    debug_print('[MONITOR] Total songs tracked: ' .. (last_song_count or 0))

    if next(last_song_families) then
        local families = {}
        for family, count in pairs(last_song_families) do
            table.insert(families, 'ID' .. family .. ':' .. count)
        end
        debug_print('[MONITOR] Active families: ' .. table.concat(families, ', '))
    else
        debug_print('[MONITOR] No songs currently tracked')
    end
end

---============================================================================
--- DEBUG DISPLAY FUNCTIONS
---============================================================================

--- Show BRD song buffs using BRDSongCounter module
function BRDDebug.debug_active_buffs()
    debug_print('[BRD DEBUG] =========================================')
    debug_print('[BRD DEBUG] === BRD SONG BUFFS (REAL DATA) ===')
    debug_print('[BRD DEBUG] =========================================')

    -- Use BRDSongCounter module for detailed analysis
    local analysis = BRDSongCounter.get_detailed_analysis()

    if analysis.song_count > 0 then
        debug_print('[SONGS] Active BRD songs (from BRDSongCounter):', 121)

        -- Display BRD songs
        for _, song_data in pairs(analysis.song_buffs) do
            if song_data.count > 1 then
                debug_print('  ID ' .. song_data.id .. ' (' .. song_data.name .. ') x' .. song_data.count, 121)
            else
                debug_print('  ID ' .. song_data.id .. ' (' .. song_data.name .. ')', 121)
            end
        end

        debug_print('[BRD DEBUG] =========================================')
        debug_print('Total BRD songs active: ' .. analysis.song_count, 158)
        debug_print('Other buffs: ' .. #analysis.other_buffs .. ' (Food, JA effects, etc.)', 8)
        debug_print('[BRD DEBUG] =========================================')
    else
        debug_print('No BRD songs detected', 167)
        if not player or not player.buffs then
            debug_print('ERROR: player.buffs not available', 167)
        end
    end
end

--- Get current song status via BRDSongCounter module
function BRDDebug.get_current_song_status()
    local status = BRDSongCounter.get_song_status()
    debug_print('[BRD SONGS] Current song count: ' .. status.total_count)

    if status.has_songs then
        for buff_id, count in pairs(status.families) do
            debug_print('[BRD SONGS] Active: ID ' .. buff_id .. ' (count: ' .. count .. ')')
        end
    else
        debug_print('[BRD SONGS] No BRD songs detected. Use //gs c debugbuffs to see all active buffs')
    end
end

--- Check if we can refresh a 5th song (lightweight)
--- @param fifth_song_family string Family name for the 5th song
function BRDDebug.can_refresh_fifth_song(fifth_song_family)
    local status = BRDSongCounter.get_song_status()
    local family = fifth_song_family and fifth_song_family:upper() or 'UNKNOWN'
    local count = status.total_count

    if count < 5 then
        debug_print('[BRD SONGS] Can refresh - currently have ' .. count .. ' songs')
        return true
    elseif count == 5 then
        local has_target_family, family_count = BRDSongCounter.is_family_active(family)
        if not has_target_family then
            debug_print('[BRD SONGS] Can refresh - no ' .. family .. ' detected in 5 songs')
            return true
        else
            debug_print('[BRD SONGS] No refresh needed - ' .. family .. ' already active (' .. family_count .. ' songs)')
            return false
        end
    else
        debug_print('[BRD SONGS] No refresh needed - have ' .. count .. ' songs')
        return false
    end
end

---============================================================================
--- COMPREHENSIVE STATUS DISPLAY
---============================================================================

--- Display comprehensive BRD status (songs + abilities)
function BRDDebug.display_full_status()
    debug_print('[BRD STATUS] ==========================================')
    debug_print('[BRD STATUS] === COMPREHENSIVE BRD STATUS ===')
    debug_print('[BRD STATUS] ==========================================')

    -- Song status
    local song_status = BRDSongCounter.get_song_status()
    debug_print('[STATUS] Songs: ' .. song_status.total_count .. ' active', 121)

    if song_status.has_songs then
        local families = {}
        for buff_id, count in pairs(song_status.families) do
            table.insert(families, 'ID' .. buff_id .. ':' .. count)
        end
        debug_print('[STATUS] Families: ' .. table.concat(families, ', '), 121)
    end

    -- Abilities status
    local ability_status = BRDAbilities.get_abilities_status()

    -- Nitro status
    if ability_status.nitro_active then
        debug_print('[STATUS] NITRO: ACTIVE (NT both up)', 030)
    else
        local nt_ready = ability_status.nightingale.ready and ability_status.troubadour.ready
        if nt_ready then
            debug_print('[STATUS] NITRO: Ready to cast', 158)
        else
            debug_print('[STATUS] NITRO: Not ready', 8)
        end
    end

    -- Marcato status
    if ability_status.marcato.available then
        debug_print('[STATUS] MARCATO: AVAILABLE', 030)
    elseif ability_status.marcato.ready then
        debug_print('[STATUS] MARCATO: Ready (need Nitro)', 8)
    else
        debug_print('[STATUS] MARCATO: On cooldown', 8)
    end

    -- Soul Voice status
    if ability_status.soul_voice.active then
        debug_print('[STATUS] SOUL VOICE: ACTIVE', 167)
    elseif ability_status.soul_voice.ready then
        debug_print('[STATUS] SOUL VOICE: Ready', 8)
    else
        debug_print('[STATUS] SOUL VOICE: On cooldown', 8)
    end

    debug_print('[BRD STATUS] ==========================================')
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Check if packet debugging is currently enabled
--- @return boolean true if packet debugging is active
function BRDDebug.is_packet_debug_enabled()
    return packet_debug_enabled
end

--- Get last tracked song count from packet monitoring
--- @return number Last song count from packet monitoring
function BRDDebug.get_last_song_count()
    return last_song_count or 0
end

--- Reset packet monitoring state
function BRDDebug.reset_monitoring_state()
    last_song_count = 0
    last_song_families = {}
    debug_print('[BRD DEBUG] Monitoring state reset')
end

return BRDDebug
