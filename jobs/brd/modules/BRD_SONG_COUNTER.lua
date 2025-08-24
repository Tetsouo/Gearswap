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

--- Count songs on a party member by ID or current target
--- @param player_id number Optional player ID, uses current target if nil
--- @return number Song count on that player
--- @return boolean true if player found
function BRDSongCounter.count_target_songs(player_id)
    local song_count = 0
    local brd_buff_ids_set = {}
    
    -- Build BRD buff ID set
    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
            local status_id = family_data.status_id
            brd_buff_ids_set[status_id] = true
        end
    end
    
    -- Method 1: Direct target access using windower API
    local target_buffs = nil
    local target_name = "Unknown"
    
    if not player_id then
        -- Use current target
        local success, target = pcall(windower.ffxi.get_mob_by_target, 'st')
        if success and target then
            target_buffs = target.buffs
            target_name = target.name or "Unknown"
        else
            return 0, false
        end
    else
        -- Use specific player ID
        local success, target = pcall(windower.ffxi.get_mob_by_id, player_id)
        if success and target then
            target_buffs = target.buffs
            target_name = target.name or "Unknown"
        else
            return 0, false
        end
    end
    
    -- Count BRD songs in target's buffs
    if target_buffs then
        for _, buff_id in pairs(target_buffs) do
            if brd_buff_ids_set[buff_id] then
                song_count = song_count + 1
            end
        end
        return song_count, true
    else
        return -1, true -- Special return value indicating "can't check buffs"
    end
end

--- Get current target's song count (any player)
--- @return number Song count (0 if not found)
--- @return string Target name or "No target"
function BRDSongCounter.get_target_song_count()
    local success, target = pcall(windower.ffxi.get_mob_by_target, 'st')
    if not success or not target then
        return 0, "No target"
    end
    
    if target.spawn_type ~= 13 then -- 13 = PC/Player Character
        return 0, "Not a player"
    end
    
    local count, found = BRDSongCounter.count_target_songs()
    local name = target.name or "Unknown"
    
    if not found then
        return 0, name .. " (buff data unavailable)"
    end
    
    if count == -1 then
        return 0, name .. " (buffs not accessible)"
    end
    
    return count, name
end

--- Debug function to check party data
--- @return table Debug information about party and target
function BRDSongCounter.debug_party_info()
    local debug_info = {
        target_exists = false,
        target_name = "None",
        target_id = "None",
        target_type = "None",
        party_exists = false,
        party_members = {},
        found_in_party = false
    }
    
    -- Check target
    if player and player.target then
        debug_info.target_exists = true
        debug_info.target_name = player.target.name or "Unknown"
        debug_info.target_id = tostring(player.target.id or "Unknown")
        debug_info.target_type = player.target.type or "Unknown"
    end
    
    -- Check party
    local party = windower.ffxi.get_party()
    if party then
        debug_info.party_exists = true
        
        local search_positions = {
            'p0', 'p1', 'p2', 'p3', 'p4', 'p5',
            'a10', 'a11', 'a12', 'a13', 'a14', 'a15',
            'a20', 'a21', 'a22', 'a23', 'a24', 'a25'
        }
        
        for _, pos in ipairs(search_positions) do
            local member = party[pos]
            if member and member.name then
                local member_info = {
                    position = pos,
                    name = member.name,
                    id = tostring(member.id or "Unknown"),
                    has_buffs = member.buffs ~= nil,
                    buff_count = member.buffs and #member.buffs or 0
                }
                
                table.insert(debug_info.party_members, member_info)
                
                -- Check if this is our target (by ID or name)
                local is_target = false
                if player.target then
                    if member.id and member.id == player.target.id then
                        is_target = true
                    elseif member.name == player.target.name then
                        is_target = true
                    end
                end
                
                if is_target then
                    debug_info.found_in_party = true
                end
            end
        end
    end
    
    return debug_info
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
