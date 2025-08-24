---============================================================================
--- FFXI GearSwap BRD Party Buff Monitor Module
---============================================================================
--- Optimized party member buff monitoring system for BRD
--- Uses packet 0x076 efficiently to track party member buffs without lag
---
--- @file jobs/brd/modules/BRD_PARTY_MONITOR.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-24
---============================================================================

local BRDPartyMonitor = {}

-- Cache for party member buffs (updated from packet 0x076)
local party_buffs_cache = {}
local packet_event_id = nil
local monitoring_active = false
local last_update_time = 0
local update_throttle = 0.5 -- Only process packets every 0.5 seconds
local casting_pause = false -- Pause during casting to prevent lag

-- Load BRD buff IDs for song detection
local success_BRD_BUFF_IDS, BRD_BUFF_IDS = pcall(require, 'jobs/brd/modules/BRD_BUFF_IDS')
if not success_BRD_BUFF_IDS then
    error("Failed to load jobs/brd/modules/BRD_BUFF_IDS: " .. tostring(BRD_BUFF_IDS))
end

-- Load message utilities
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get player name from party data
--- @param player_id number Player ID to lookup
--- @return string|nil Player name or nil if not found
local function get_player_name(player_id)
    local party = windower.ffxi.get_party()
    if not party then return nil end
    
    -- Check all possible party positions including alliance
    local positions = {'p0', 'p1', 'p2', 'p3', 'p4', 'p5', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a20', 'a21', 'a22', 'a23', 'a24', 'a25'}
    for _, pos in ipairs(positions) do
        local member = party[pos]
        if member and member.mob and member.mob.id == player_id then
            return member.name
        end
    end
    
    return nil
end

---============================================================================
--- PACKET PARSING (OPTIMIZED)
---============================================================================

--- Parse party buff packet (0x076) - SIMPLE VERSION NO LAG
--- @param data string Raw packet data
local function parse_party_buffs_optimized(data)
    -- Direct parsing, no coroutine overhead
    for k = 0, 4 do
        local id = data:unpack('I', k*48+5)
        
        if id ~= 0 and id ~= player.id then
            -- Get player name immediately
            local name = get_player_name(id)
            
            -- Get or create cache entry
            if not party_buffs_cache[id] then
                party_buffs_cache[id] = {
                    buffs = {},
                    name = name
                }
            else
                -- Update name if we have it
                if name and not party_buffs_cache[id].name then
                    party_buffs_cache[id].name = name
                end
            end
            
            -- Clear buffs
            party_buffs_cache[id].buffs = {}
            
            -- Only check first 8 buffs (songs are always first)
            for i = 1, 8 do
                local buff = data:byte(k*48+5+16+i-1) + 256 * (math.floor(data:byte(k*48+5+8+math.floor((i-1)/4)) / 4^((i-1)%4)) % 4)
                if buff > 0 and buff ~= 255 then
                    party_buffs_cache[id].buffs[#party_buffs_cache[id].buffs + 1] = buff
                end
            end
        end
    end
end

---============================================================================
--- MONITORING CONTROL
---============================================================================

--- Manual update - call this BEFORE casting a song
function BRDPartyMonitor.update_now()
    local data = windower.packets.last_incoming(0x076)
    if data then
        parse_party_buffs_optimized(data)
        return true
    end
    return false
end

--- Start party buff monitoring (simplified - no continuous monitoring)
function BRDPartyMonitor.start()
    if monitoring_active then
        MessageUtils.brd_message("Monitor", "Already active", "Party buff monitoring")
        return
    end
    
    monitoring_active = true
    MessageUtils.brd_message("Monitor", "Enabled", "Manual buff checking")
    
    -- Do ONE initial scan only
    BRDPartyMonitor.update_now()

end

--- Stop party buff monitoring
function BRDPartyMonitor.stop()
    if not monitoring_active then
        MessageUtils.brd_message("Monitor", "Already stopped", "Party buff monitoring")
        return
    end
    
    monitoring_active = false
    MessageUtils.brd_message("Monitor", "Stopped", "Party buff monitoring")
end

---============================================================================
--- BUFF CHECKING FUNCTIONS
---============================================================================

--- Count BRD songs on a specific party member
--- @param player_name string Name of the party member
--- @return number Song count (-1 if not found)
--- @return table|nil List of song buff IDs
function BRDPartyMonitor.count_member_songs(player_name)
    -- Build BRD buff ID set
    local brd_buff_ids_set = {}
    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
            brd_buff_ids_set[family_data.status_id] = family_name
        end
    end
    
    -- Find player in cache (try case insensitive)
    for player_id, data in pairs(party_buffs_cache) do
        local cache_name = data.name
        if cache_name and cache_name:lower() == player_name:lower() then
            local song_count = 0
            local song_list = {}
            
            for _, buff_id in ipairs(data.buffs) do
                if brd_buff_ids_set[buff_id] then
                    song_count = song_count + 1
                    table.insert(song_list, {
                        id = buff_id,
                        name = brd_buff_ids_set[buff_id]
                    })
                end
            end
            
            return song_count, song_list
        end
    end
    
    return -1, nil
end

--- Get all party member song counts
--- @return table Table of member names and their song counts
function BRDPartyMonitor.get_all_member_songs()
    local results = {}
    
    -- Build BRD buff ID set
    local brd_buff_ids_set = {}
    if BRD_BUFF_IDS and BRD_BUFF_IDS.FAMILIES then
        for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
            brd_buff_ids_set[family_data.status_id] = family_name
        end
    end
    
    -- Process each cached player
    for player_id, data in pairs(party_buffs_cache) do
        if data.name then
            local song_count = 0
            local song_names = {}
            
            for _, buff_id in ipairs(data.buffs) do
                if brd_buff_ids_set[buff_id] then
                    song_count = song_count + 1
                    table.insert(song_names, brd_buff_ids_set[buff_id])
                end
            end
            
            table.insert(results, {
                name = data.name,
                song_count = song_count,
                songs = song_names,
                last_update = data.last_update
            })
        end
    end
    
    -- Sort by name
    table.sort(results, function(a, b) return a.name < b.name end)
    
    return results
end

--- Check specific party member (like Kaories)
--- @param target_name string Name to check (optional, uses current target if nil)
function BRDPartyMonitor.check_member(target_name)
    -- Use current target if no name provided
    if not target_name then
        local target = windower.ffxi.get_mob_by_target('t')
        if target then
            target_name = target.name
        else
            MessageUtils.error("Monitor", "No target selected")
            return
        end
    end
    
    -- Update cache before checking
    BRDPartyMonitor.update_now()
    
    local song_count, song_list = BRDPartyMonitor.count_member_songs(target_name)
    
    if song_count == -1 then
        MessageUtils.error("Monitor", target_name .. " not found in party buffer cache")
        MessageUtils.brd_message("Tip", "Make sure monitoring is active", "//gs c partymonitor start")
        return
    end
    
    MessageUtils.brd_message("Monitor", target_name .. " has " .. song_count .. " songs", "")
    
    if song_list and #song_list > 0 then
        local song_names = {}
        for _, song in ipairs(song_list) do
            table.insert(song_names, song.name)
        end
        MessageUtils.brd_message("Songs", table.concat(song_names, ", "), "")
    end
end

--- Display all party members' song status
function BRDPartyMonitor.show_party_status()
    if not monitoring_active then
        MessageUtils.error("Monitor", "Not active - use //gs c partymonitor start")
        return
    end
    
    local members = BRDPartyMonitor.get_all_member_songs()
    
    if #members == 0 then
        MessageUtils.brd_message("Monitor", "No party members in cache", "")
        return
    end
    
    MessageUtils.brd_message("Monitor", "=== PARTY SONG STATUS ===", "")
    
    for _, member in ipairs(members) do
        local age = math.floor(os.clock() - member.last_update)
        local status = member.song_count .. " songs"
        
        if #member.songs > 0 then
            status = status .. " (" .. table.concat(member.songs, ",") .. ")"
        end
        
        MessageUtils.brd_message(member.name, status, "Updated " .. age .. "s ago")
    end
end

--- Get monitoring status
--- @return boolean True if monitoring is active
function BRDPartyMonitor.is_active()
    return monitoring_active
end

--- Clear cache
function BRDPartyMonitor.clear_cache()
    party_buffs_cache = {}
    MessageUtils.brd_message("Monitor", "Cache cleared", "")
end



--- Pause monitoring during casting to prevent lag
function BRDPartyMonitor.pause_for_casting()
    casting_pause = true
    -- Auto-resume after 5 seconds
    coroutine.schedule(function()
        casting_pause = false
    end, 5)
end

--- Resume monitoring after casting
function BRDPartyMonitor.resume_after_casting()
    casting_pause = false
end

return BRDPartyMonitor