---============================================================================
--- FFXI GearSwap BRD Song Counter Module
---============================================================================
--- Handles intelligent song counting and detection for BRD job.
--- Provides accurate song counting using player.buffs to avoid buffactive
--- duplicates and ensure precise refresh logic.
---
--- @file jobs/brd/modules/brd_song_counter.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires BRD_BUFF_IDS, player.buffs
---============================================================================

-- Load dependencies
local success_BRD_BUFF_IDS, BRD_BUFF_IDS = pcall(require, 'jobs/brd/modules/BRD_BUFF_IDS')
if not success_BRD_BUFF_IDS then
    error("Failed to load jobs/brd/modules/BRD_BUFF_IDS: " .. tostring(BRD_BUFF_IDS))
end

local BRDSongCounter = {}

---============================================================================
--- SONG COUNTING FUNCTIONS
---============================================================================

--- Count songs correctly using player.buffs and BRD_BUFF_IDS reference
--- @return number Total song count
--- @return table Song families with counts
function BRDSongCounter.count_active_songs()
    local song_count = 0
    local families = {}

    -- Build buff ID set from BRD_BUFF_IDS families
    local brd_buff_ids = {}
    local brd_buff_ids_set = {}

    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
            local status_id = family_data.status_id
            table.insert(brd_buff_ids, status_id)
            brd_buff_ids_set[status_id] = true
        end
    end

    -- Method 1: Use player.buffs for precise counting (avoids buffactive duplicates)
    if player and player.buffs then
        for _, buff_id in pairs(player.buffs) do
            if brd_buff_ids_set[buff_id] then
                song_count = song_count + 1
                families[buff_id] = (families[buff_id] or 0) + 1
            end
        end
    else
        -- Fallback: Use buffactive but only count IDs (not names) to avoid duplicates
        for buff_key, _ in pairs(buffactive) do
            local buff_id = tonumber(buff_key)
            if buff_id and brd_buff_ids_set[buff_id] then
                song_count = song_count + 1
                families[buff_id] = (families[buff_id] or 0) + 1
            end
        end
    end

    return song_count, families
end

--- Get current song status information
--- @return table Status information with count and families
function BRDSongCounter.get_song_status()
    local count, families = BRDSongCounter.count_active_songs()

    return {
        total_count = count,
        families = families,
        has_songs = count > 0
    }
end

--- Check if we can refresh a specific number of songs
--- @param target_count number Target number of songs to check
--- @return boolean true if can refresh this many songs
function BRDSongCounter.can_refresh_song_count(target_count)
    local current_count, _ = BRDSongCounter.count_active_songs()
    return current_count >= target_count
end

--- Check if a specific song family is active
--- @param family_name string Name of the song family to check
--- @return boolean true if family is active
--- @return number count of songs in that family
function BRDSongCounter.is_family_active(family_name)
    local _, families = BRDSongCounter.count_active_songs()

    -- Find the buff ID for this family
    local target_id = nil
    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family, data in pairs(BRD_BUFF_IDS.FAMILIES) do
            if family:upper() == family_name:upper() then
                target_id = data.status_id
                break
            end
        end
    end

    if target_id and families[target_id] then
        return true, families[target_id]
    end

    return false, 0
end

--- Get detailed song analysis using BRD_BUFF_IDS reference
--- @return table Detailed analysis with buff names and IDs
function BRDSongCounter.get_detailed_analysis()
    local analysis = {
        song_buffs = {},
        other_buffs = {},
        song_count = 0
    }

    -- Build buff ID to name mapping from BRD_BUFF_IDS
    local brd_buff_names = {}
    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
            brd_buff_names[family_data.status_id] = family_name
        end
    end

    if player and player.buffs then
        -- Count each buff ID occurrence
        local buff_counts = {}
        for _, buff_id in pairs(player.buffs) do
            buff_counts[buff_id] = (buff_counts[buff_id] or 0) + 1
        end

        -- Categorize buffs using BRD_BUFF_IDS reference
        for buff_id, count in pairs(buff_counts) do
            if brd_buff_names[buff_id] then
                analysis.song_count = analysis.song_count + count
                table.insert(analysis.song_buffs, {
                    id = buff_id,
                    name = brd_buff_names[buff_id],
                    count = count
                })
            else
                table.insert(analysis.other_buffs, buff_id)
            end
        end
    end

    return analysis
end

return BRDSongCounter
