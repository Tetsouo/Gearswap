---============================================================================
--- FFXI GearSwap BRD Party Tracker Module (Manual)
---============================================================================
--- Manual party member song tracking system for BRD
--- Since GearSwap cannot access other players' buffs without lag,
--- this provides a manual way to track party members' songs
---
--- @file jobs/brd/modules/BRD_PARTY_TRACKER.lua  
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-24
---============================================================================

local BRDPartyTracker = {}

-- Manual cache for party member song counts
local party_song_counts = {}

-- Load message utilities
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

---============================================================================
--- MANUAL TRACKING FUNCTIONS
---============================================================================

--- Set song count for a party member manually
--- @param player_name string Name of the party member
--- @param song_count number Number of songs they have
function BRDPartyTracker.set_member_songs(player_name, song_count)
    if not player_name then
        MessageUtils.error("Tracker", "No player name provided")
        return
    end
    
    song_count = tonumber(song_count) or 0
    party_song_counts[player_name:lower()] = {
        count = song_count,
        timestamp = os.time(),
        name = player_name
    }
    
    MessageUtils.brd_message("Tracker", player_name .. " set to " .. song_count .. " songs", "")
end

--- Get song count for a party member
--- @param player_name string Name of the party member
--- @return number Song count (-1 if not tracked)
function BRDPartyTracker.get_member_songs(player_name)
    if not player_name then return -1 end
    
    local data = party_song_counts[player_name:lower()]
    if data then
        return data.count
    end
    return -1
end

--- Clear tracking for a member
--- @param player_name string Name to clear (or "all" for everyone)
function BRDPartyTracker.clear_member(player_name)
    if player_name and player_name:lower() == "all" then
        party_song_counts = {}
        MessageUtils.brd_message("Tracker", "Cleared all tracked members", "")
    elseif player_name then
        party_song_counts[player_name:lower()] = nil
        MessageUtils.brd_message("Tracker", "Cleared " .. player_name, "")
    else
        MessageUtils.error("Tracker", "Specify a name or 'all'")
    end
end

--- Show all tracked members
function BRDPartyTracker.show_tracked()
    local count = 0
    for _, data in pairs(party_song_counts) do
        count = count + 1
    end
    
    if count == 0 then
        MessageUtils.brd_message("Tracker", "No members tracked", "Use //gs c setsongs <name> <count>")
        return
    end
    
    MessageUtils.brd_message("Tracker", "=== TRACKED MEMBERS ===", "")
    for _, data in pairs(party_song_counts) do
        local age = os.time() - data.timestamp
        local age_str = ""
        if age < 60 then
            age_str = age .. "s ago"
        elseif age < 3600 then
            age_str = math.floor(age/60) .. "m ago"
        else
            age_str = math.floor(age/3600) .. "h ago"
        end
        
        MessageUtils.brd_message(data.name, data.count .. " songs", "Set " .. age_str)
    end
end

--- Quick presets for common scenarios
function BRDPartyTracker.apply_preset(preset_name)
    local presets = {
        -- Everyone has 0 songs (start of party)
        fresh = function()
            MessageUtils.brd_message("Tracker", "Preset: Fresh party (0 songs)", "")
        end,
        
        -- Everyone has 4 songs
        full = function()
            MessageUtils.brd_message("Tracker", "Preset: Full songs (4 each)", "")
            -- Would need party member names to set
        end,
        
        -- Tank has 4, others have 0
        tank = function()
            MessageUtils.brd_message("Tracker", "Preset: Tank buffed", "")
            -- Would need to identify tank
        end
    }
    
    if presets[preset_name] then
        presets[preset_name]()
    else
        MessageUtils.error("Tracker", "Unknown preset: " .. (preset_name or "nil"))
        MessageUtils.brd_message("Tracker", "Available presets", "fresh, full, tank")
    end
end

--- Get tracking info for current target
function BRDPartyTracker.check_target()
    local target = windower.ffxi.get_mob_by_target('t')
    if not target then
        MessageUtils.error("Tracker", "No target selected")
        return -1
    end
    
    local count = BRDPartyTracker.get_member_songs(target.name)
    if count == -1 then
        MessageUtils.brd_message("Tracker", target.name .. " not tracked", "Use //gs c setsongs " .. target.name .. " <count>")
    else
        MessageUtils.brd_message("Tracker", target.name .. " has " .. count .. " songs", "(manually set)")
    end
    
    return count
end

return BRDPartyTracker