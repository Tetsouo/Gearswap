---============================================================================
--- FFXI GearSwap BRD Song Caster Module
---============================================================================
--- Handles all song casting functionality including rotations, pianissimo,
--- dummy songs, and various song pack systems. Provides centralized song
--- casting logic with proper timing and equipment management.
---
--- @file jobs/brd/modules/brd_song_caster.lua
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

local BRDSongCaster = {}


---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Cast a phase of songs with proper mode and delays
--- @param songs table Array of songs to cast
--- @param start_index number Starting song index
--- @param count number Number of songs to cast
--- @param mode string Song mode ('Party' or 'Dummy')
--- @param base_delay number Starting delay
--- @param song_delay number Delay between songs
--- @param marcato_used boolean Whether Marcato was used
--- @return number Updated delay for next phase
local function cast_song_phase(songs, start_index, count, mode, base_delay, song_delay, marcato_used)
    BRDUtils.set_song_mode(mode)
    local delay = base_delay

    for i = start_index, start_index + count - 1 do
        if songs[i] then
            local current_delay = delay
            if marcato_used and start_index == 1 and i == 1 then
                -- Add marcato delay to the first song (Honor March)
                current_delay = current_delay + BRD_CONFIG.TIMINGS.marcato_delay
                -- Also add marcato delay to the running delay for subsequent songs
                delay = delay + BRD_CONFIG.TIMINGS.marcato_delay
            end
            send_command('wait ' .. current_delay .. '; input /ma "' .. songs[i] .. '" <me>')
            delay = delay + song_delay
        end
    end

    return delay
end

---============================================================================
--- CORE SONG CASTING FUNCTIONS
---============================================================================

--- Cast songs with proper timing and phases
--- @param buff_songs table Array of main songs to cast
--- @param dummy_songs table Array of dummy songs to cast
--- @param total_songs number Total number of songs to cast
--- @param use_marcato boolean Whether to use Marcato for first song
--- @param pack_name string Name of the song pack for display
local function cast_songs_with_phases(buff_songs, dummy_songs, total_songs, use_marcato, pack_name)
    local song_delay = BRDUtils.get_song_delay()
    local delay = 0

    -- Use Marcato if requested and available
    local marcato_used = false
    if use_marcato and BRDUtils.should_use_marcato(buff_songs) then
        send_command('input /ja "Marcato" <me>')
        marcato_used = true
    end

    if total_songs >= 5 then
        -- 5+ song rotation with Clarion Call
        -- Use unified message system instead of old job_message
        local messages = { {
            type = 'action',
            name = pack_name .. " Clarion",
            message = "Full rotation (" .. total_songs .. " songs)"
        } }
        MessageUtils.unified_status_message(messages, nil, true)

        -- Phase 1: First 3 real songs
        delay = cast_song_phase(buff_songs, 1, 3, 'Party', 0, song_delay, marcato_used)

        -- Phase 2: 2 dummy songs
        delay = cast_song_phase(dummy_songs, 1, 2, 'Dummy', delay, song_delay, false)

        -- Phase 3: Last 2 real songs (replace dummies)
        delay = cast_song_phase(buff_songs, 4, math.min(2, #buff_songs - 3), 'Party', delay, song_delay, false)
    else
        -- 4 song rotation
        -- Phase 1: First 2 real songs
        delay = cast_song_phase(buff_songs, 1, 2, 'Party', 0, song_delay, marcato_used)

        -- Phase 2: 2 dummy songs
        delay = cast_song_phase(dummy_songs, 1, 2, 'Dummy', delay, song_delay, false)

        -- Phase 3: Last 2 real songs (replace dummies)
        delay = cast_song_phase(buff_songs, 3, 2, 'Party', delay, song_delay, false)
    end

    -- Return to Party mode at the end (silent)
    local total_time = delay + song_delay
    coroutine.schedule(function()
        BRDUtils.set_song_mode('Party')
    end, total_time)

    -- Display song list
    local song_list = {}
    for i = 1, total_songs do
        if buff_songs[i] then
            table.insert(song_list, BRDUtils.shorten_song_name(buff_songs[i]))
        end
    end
    MessageUtils.brd_song_rotation_with_separator(song_list, pack_name .. " Songs", true)
end

--- Cast songs with Pianissimo for single target
--- @param buff_songs table Array of main songs to cast
--- @param dummy_songs table Array of dummy songs to cast
--- @param total_songs number Total number of songs to cast
--- @param use_marcato boolean Whether to use Marcato for first song
--- @param pack_name string Name of the song pack for display
local function cast_songs_with_pianissimo(buff_songs, dummy_songs, total_songs, use_marcato, pack_name)
    local song_delay = BRDUtils.get_song_delay() + BRD_CONFIG.TIMINGS.pianissimo_delay
    local delay = 0

    -- Use Marcato if requested and available
    local marcato_used = false
    if use_marcato and buff_songs[1] == 'Honor March' and BRDAbilities.is_marcato_available() then
        send_command('input /ja "Marcato" <me>')
        marcato_used = true
    end

    if total_songs >= 5 then
        -- 5+ song rotation with Clarion Call
        -- Use unified message system instead of old job_message
        local messages = { {
            type = 'action',
            name = pack_name .. " Piano Clarion",
            message = total_songs .. " songs rotation"
        } }
        MessageUtils.unified_status_message(messages, nil, true)

        -- Phase 1: First 3 real songs with Pianissimo
        BRDUtils.set_song_mode('Party')
        for i = 1, 3 do
            if buff_songs[i] then
                local current_delay = delay
                if marcato_used and i == 1 then
                    current_delay = current_delay + BRD_CONFIG.TIMINGS.marcato_delay
                end
                send_command('wait ' .. current_delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (current_delay + 2) ..
                    '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. buff_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end

        -- Adjust delay for Marcato if used
        if marcato_used then
            delay = delay + BRD_CONFIG.TIMINGS.marcato_delay
        end

        -- Phase 2: 2 dummy songs with Pianissimo
        BRDUtils.set_song_mode('Dummy')
        for i = 1, 2 do
            if dummy_songs[i] then
                send_command('wait ' .. delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (delay + 2) .. '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. dummy_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end

        -- Phase 3: Last 2 real songs with Pianissimo
        BRDUtils.set_song_mode('Party')
        for i = 4, math.min(5, #buff_songs) do
            if buff_songs[i] then
                send_command('wait ' .. delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (delay + 2) .. '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. buff_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end
    else
        -- 4 song rotation
        MessageUtils.brd_message("Piano", pack_name .. " Songs", "4 songs rotation")

        -- Phase 1: First 2 real songs with Pianissimo
        BRDUtils.set_song_mode('Party')
        for i = 1, 2 do
            if buff_songs[i] then
                local current_delay = delay
                if marcato_used and i == 1 then
                    current_delay = current_delay + BRD_CONFIG.TIMINGS.marcato_delay
                end
                send_command('wait ' .. current_delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (current_delay + 2) ..
                    '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. buff_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end

        -- Adjust delay for Marcato if used
        if marcato_used then
            delay = delay + BRD_CONFIG.TIMINGS.marcato_delay
        end

        -- Phase 2: 2 dummy songs with Pianissimo
        BRDUtils.set_song_mode('Dummy')
        for i = 1, 2 do
            if dummy_songs[i] then
                send_command('wait ' .. delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (delay + 2) .. '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. dummy_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end

        -- Phase 3: Last 2 real songs with Pianissimo
        BRDUtils.set_song_mode('Party')
        for i = 3, 4 do
            if buff_songs[i] then
                send_command('wait ' .. delay .. '; input /ja "Pianissimo" <me>')
                send_command('wait ' ..
                    (delay + 2) .. '; send ' .. BRD_CONFIG.CHARACTER.name .. ' /ma "' .. buff_songs[i] .. '" <laststid>')
                delay = delay + song_delay
            end
        end
    end

    -- Display song list
    local song_list = {}
    for i = 1, total_songs do
        if buff_songs[i] then
            table.insert(song_list, BRDUtils.shorten_song_name(buff_songs[i]))
        end
    end
    MessageUtils.brd_song_rotation_with_separator(song_list, pack_name .. " Piano Songs", true)
end

---============================================================================
--- PUBLIC CASTING FUNCTIONS
---============================================================================

--- Cast melee songs (full rotation with dummies - party buffs)
function BRDSongCaster.cast_melee_songs()
    -- Use current BRDRotation
    local set_name = (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local buff_songs = BRDUtils.get_song_pack(set_name)
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for Clarion Call capability
    local has_clarion_call = buffactive['Clarion Call'] or false
    local total_songs = has_clarion_call and 7 or 4

    cast_songs_with_phases(buff_songs, dummy_songs, total_songs, true, set_name)
end

--- Cast tank songs (full rotation with dummies - party buffs using Tank pack)
function BRDSongCaster.cast_tank_songs()
    MessageUtils.brd_message("BRD", "Tank Songs", "Starting...")

    local buff_songs = BRDUtils.get_song_pack('Tank')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for 5th song
    local fifth_song = BRD_CONFIG.FIFTH_SONG_BUFFS['Tank']
    local has_fifth_song = fifth_song and buffactive[fifth_song] or false
    local has_clarion_call = buffactive['Clarion Call'] or has_fifth_song
    local total_songs = has_clarion_call and 5 or 4

    cast_songs_with_phases(buff_songs, dummy_songs, total_songs, false, "Tank")
end

--- Cast healer songs (full rotation with dummies - party buffs using Healer pack)
function BRDSongCaster.cast_healer_songs()
    MessageUtils.brd_message("BRD", "Healer Songs", "Starting...")

    local buff_songs = BRDUtils.get_song_pack('Healer')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for 5th song
    local fifth_song = BRD_CONFIG.FIFTH_SONG_BUFFS['Healer']
    local has_fifth_song = fifth_song and buffactive[fifth_song] or false
    local has_clarion_call = buffactive['Clarion Call'] or has_fifth_song
    local total_songs = has_clarion_call and 5 or 4

    cast_songs_with_phases(buff_songs, dummy_songs, total_songs, false, "Healer")
end

--- Cast melee songs with Pianissimo (single target full rotation using current pack)
function BRDSongCaster.cast_melee_pianissimo()
    -- Use current BRDRotation
    local set_name = (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local buff_songs = BRDUtils.get_song_pack(set_name)
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for fifth song
    local fifth_song = BRD_CONFIG.FIFTH_SONG_BUFFS[set_name]
    local has_fifth_song = fifth_song and buffactive[fifth_song] or false
    local has_clarion_call = buffactive['Clarion Call'] or has_fifth_song
    local total_songs = has_clarion_call and 5 or 4

    cast_songs_with_pianissimo(buff_songs, dummy_songs, total_songs, true, set_name)
end

--- Cast tank songs with Pianissimo (single target full rotation)
function BRDSongCaster.cast_tank_pianissimo()
    MessageUtils.brd_message("Piano", "Tank Songs", "Starting...")

    local buff_songs = BRDUtils.get_song_pack('Tank')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for 5th song
    local fifth_song = BRD_CONFIG.FIFTH_SONG_BUFFS['Tank']
    local has_fifth_song = fifth_song and buffactive[fifth_song] or false
    local has_clarion_call = buffactive['Clarion Call'] or has_fifth_song
    local total_songs = has_clarion_call and 5 or 4

    cast_songs_with_pianissimo(buff_songs, dummy_songs, total_songs, false, "Tank")
end

--- Cast healer songs with Pianissimo (single target full rotation)
function BRDSongCaster.cast_healer_pianissimo()
    local buff_songs = BRDUtils.get_song_pack('Healer')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for 5th song
    local fifth_song = BRD_CONFIG.FIFTH_SONG_BUFFS['Healer']
    local has_fifth_song = fifth_song and buffactive[fifth_song] or false
    local has_clarion_call = buffactive['Clarion Call'] or has_fifth_song
    local total_songs = has_clarion_call and 5 or 4

    cast_songs_with_pianissimo(buff_songs, dummy_songs, total_songs, false, "Healer")
end

--- Cast Carol songs (full rotation with dummies - party buffs using Carol pack)
function BRDSongCaster.cast_carol_songs()
    -- Use Carol pack from configuration
    local buff_songs = BRDUtils.get_song_pack('Carol')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for Clarion Call capability
    local has_clarion_call = buffactive['Clarion Call'] or false
    local total_songs = has_clarion_call and 7 or 4

    cast_songs_with_phases(buff_songs, dummy_songs, total_songs, true, "Carol")
end

--- Cast Scherzo songs (full rotation with dummies - party buffs using Scherzo pack)
function BRDSongCaster.cast_scherzo_songs()
    -- Use Scherzo pack from configuration
    local buff_songs = BRDUtils.get_song_pack('Scherzo')
    local dummy_songs = BRDUtils.get_dummy_pack('Trash')

    -- Check for Clarion Call capability
    local has_clarion_call = buffactive['Clarion Call'] or false
    local total_songs = has_clarion_call and 7 or 4

    cast_songs_with_phases(buff_songs, dummy_songs, total_songs, true, "Scherzo")
end

--- Cast dummy songs to prepare slots (4 or 5 depending on Clarion Call)
function BRDSongCaster.cast_dummy_songs()
    -- Check if we can cast 5 songs
    local has_clarion_call = buffactive['Clarion Call']
    local total_songs = has_clarion_call and 5 or 4

    local messages = { { type = 'info', name = 'Dummy Songs', message = 'Casting ' .. total_songs .. ' songs' } }
    MessageUtils.unified_status_message(messages, nil, true)

    -- Get dummy songs from configuration
    local dummy_songs = BRD_CONFIG.DUMMY_SONGS.standard

    if has_clarion_call then
        local messages = { { type = 'active', name = 'Clarion Call', message = '5 dummy songs' } }
        MessageUtils.unified_status_message(messages, nil, true)
    end

    -- Set to Dummy mode
    BRDUtils.set_song_mode('Dummy')

    -- Get dynamic song delay
    local song_delay = BRDUtils.get_song_delay()

    -- Cast dummy songs with delays
    for i = 1, total_songs do
        if dummy_songs[i] then
            send_command('wait ' .. ((i - 1) * song_delay) .. '; input /ma "' .. dummy_songs[i] .. '" <me>')
        end
    end

    -- Return to Party mode after casting (silent)
    local total_time = total_songs * song_delay
    coroutine.schedule(function()
        BRDUtils.set_song_mode('Party')
    end, total_time)

    local dummy_list = {}
    for i = 1, total_songs do
        table.insert(dummy_list, {
            name = dummy_songs[i],
            active = false,
            recast = 0
        })
    end
    MessageUtils.brd_song_list_message(dummy_list, "Dummy Rotation")
end

--- Cast dummy1 song (Gold Capriccio) with intelligent targeting
function BRDSongCaster.cast_dummy1_song()
    local dummy_song = "Gold Capriccio"
    
    -- Set to Dummy mode
    BRDUtils.set_song_mode('Dummy')
    
    -- TARGET DETECTION: Check if targeting self or others
    local target_cmd = "<me>"  -- Default to self
    local needs_pianissimo = false
    
    -- Check if we have a valid target that's not ourselves
    if player.target and player.target.id and player.target.id ~= player.id then
        -- Check if target is a player (spawn_type 13 = PC)
        if player.target.spawn_type == 13 then
            target_cmd = "<stpc>"  -- Sub-target PC
            needs_pianissimo = true
            MessageUtils.brd_message("Dummy1", "Targeting " .. (player.target.name or "Unknown"), dummy_song)
        else
            -- Not a player, target self instead
            target_cmd = "<me>"
            needs_pianissimo = false
            MessageUtils.brd_message("Dummy1", "Invalid target - casting on self", dummy_song)
        end
    else
        -- No target or targeting self
        target_cmd = "<me>"
        needs_pianissimo = false
        MessageUtils.brd_message("Dummy1", "Casting on self", dummy_song)
    end
    
    -- Cast with appropriate targeting
    if needs_pianissimo then
        send_command('input /ja "Pianissimo" <me>')
        send_command('wait 1.5; input /ma "' .. dummy_song .. '" ' .. target_cmd)
    else
        send_command('input /ma "' .. dummy_song .. '" ' .. target_cmd)
    end
    
    -- Return to Party mode after casting
    coroutine.schedule(function()
        BRDUtils.set_song_mode('Party')
    end, 4)
end

--- Cast dummy2 song (Goblin Gavotte) with intelligent targeting
function BRDSongCaster.cast_dummy2_song()
    local dummy_song = "Goblin Gavotte"
    
    -- Set to Dummy mode
    BRDUtils.set_song_mode('Dummy')
    
    -- TARGET DETECTION: Check if targeting self or others
    local target_cmd = "<me>"  -- Default to self
    local needs_pianissimo = false
    
    -- Check if we have a valid target that's not ourselves
    if player.target and player.target.id and player.target.id ~= player.id then
        -- Check if target is a player (spawn_type 13 = PC)
        if player.target.spawn_type == 13 then
            target_cmd = "<stpc>"  -- Sub-target PC
            needs_pianissimo = true
            MessageUtils.brd_message("Dummy2", "Targeting " .. (player.target.name or "Unknown"), dummy_song)
        else
            -- Not a player, target self instead
            target_cmd = "<me>"
            needs_pianissimo = false
            MessageUtils.brd_message("Dummy2", "Invalid target - casting on self", dummy_song)
        end
    else
        -- No target or targeting self
        target_cmd = "<me>"
        needs_pianissimo = false
        MessageUtils.brd_message("Dummy2", "Casting on self", dummy_song)
    end
    
    -- Cast with appropriate targeting
    if needs_pianissimo then
        send_command('input /ja "Pianissimo" <me>')
        send_command('wait 1.5; input /ma "' .. dummy_song .. '" ' .. target_cmd)
    else
        send_command('input /ma "' .. dummy_song .. '" ' .. target_cmd)
    end
    
    -- Return to Party mode after casting
    coroutine.schedule(function()
        BRDUtils.set_song_mode('Party')
    end, 4)
end

---============================================================================
--- INDIVIDUAL SONG SLOT CASTING
---============================================================================

--- Cast a single song from the current pack based on slot number
--- @param slot_number number The slot to cast (1-5)
function BRDSongCaster.cast_single_song(slot_number)
    -- Validate slot number
    if not slot_number or slot_number < 1 or slot_number > 5 then
        MessageUtils.error("BRD", "Invalid song slot: " .. tostring(slot_number))
        return
    end
    
    -- Get current pack
    local pack_name = (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local pack = BRD_CONFIG.SONG_PACKS[pack_name]
    
    if not pack or not pack.songs then
        MessageUtils.error("BRD", "Pack not found: " .. pack_name)
        return
    end
    
    -- Get the song for this slot
    local song = pack.songs[slot_number]
    
    -- Special handling for slot 5 (Victory March replacement)
    if slot_number == 5 then
        -- Check if Haste is active and get replacement
        if buffactive['Haste'] or buffactive['Haste II'] then
            local replacement = state.VictoryMarchReplace and state.VictoryMarchReplace.value
            
            -- Map replacement to actual song name
            local replacement_songs = {
                Madrigal = 'Blade Madrigal',
                Minne = 'Knight\'s Minne V',
                Scherzo = 'Sentinel\'s Scherzo'
            }
            
            if replacement and replacement_songs[replacement] then
                -- Check if replacement would be duplicate of slot 4
                if pack.songs[4] == replacement_songs[replacement] then
                    song = 'Adventurer\'s Dirge'  -- Use Dirge if duplicate
                else
                    song = replacement_songs[replacement]
                end
            end
        end
    end
    
    if not song then
        MessageUtils.error("BRD", "No song in slot " .. slot_number)
        return
    end
    
    -- INTELLIGENT DUMMY HANDLING for slots 3 and 4
    if slot_number == 3 or slot_number == 4 then
        local active_songs
        local target_info = ""
        local target_cmd = "<stpc>"  -- Default for other players
        
        -- Define dummy songs for each slot
        local dummy_songs = {
            [3] = "Gold Capriccio",
            [4] = "Goblin Gavotte"
        }
        
        -- Check if we're targeting someone else - check THEIR songs
        if player.target and player.target.id and player.target.id ~= player.id then
            local target_song_count, found = BRDSongCounter.count_target_songs()
            
            if target_song_count == -1 then
                -- Can't check buffs on other players - skip dummy logic and cast directly
                -- This is normal behavior for targeting other players
                -- Skip the dummy handling entirely - just cast the song directly
            elseif not found then
                MessageUtils.error("BRD", "Unable to target: " .. (player.target and player.target.name or "Unknown"))
                return
            else
                active_songs = target_song_count
                target_info = " on " .. (player.target.name or "target")
                
                -- Intelligent dummy handling for target based on their song count
                if active_songs < 2 then
                    MessageUtils.error("BRD", "Target needs 2 songs before slot " .. slot_number)
                    MessageUtils.brd_message("Tip", "Cast song1 and song2" .. target_info .. " first", "Then use song" .. slot_number)
                    return
                elseif active_songs < slot_number then
                    -- Need to fill target's slots with dummies up to the target slot
                    local dummies_needed = slot_number - active_songs
                    MessageUtils.brd_message("Info", "Target has " .. active_songs .. " songs - need " .. dummies_needed .. " dummies", "")
                    
                    if slot_number == 3 and active_songs == 2 then
                        -- Need dummy for slot 3
                        local dummy_song = dummy_songs[3]  -- Gold Capriccio
                        send_command('input /ja "Pianissimo" <me>')
                        send_command('wait 1.5; input /ma "' .. dummy_song .. '" ' .. target_cmd)
                        send_command('wait 8; input /ja "Pianissimo" <me>')
                        send_command('wait 9.5; input /ma "' .. song .. '" ' .. target_cmd)
                        MessageUtils.brd_message("BRD", "Casting dummy then real song", song)
                        return
                        
                    elseif slot_number == 4 and active_songs == 2 then
                        -- Need dummy for slot 3 AND slot 4
                        local dummy3 = dummy_songs[3]  -- Gold Capriccio
                        local dummy4 = dummy_songs[4]  -- Goblin Gavotte
                        send_command('input /ja "Pianissimo" <me>')
                        send_command('wait 1.5; input /ma "' .. dummy3 .. '" ' .. target_cmd)
                        send_command('wait 8; input /ja "Pianissimo" <me>')
                        send_command('wait 9.5; input /ma "' .. dummy4 .. '" ' .. target_cmd)
                        send_command('wait 16.5; input /ja "Pianissimo" <me>')
                        send_command('wait 18; input /ma "' .. song .. '" ' .. target_cmd)
                        MessageUtils.brd_message("BRD", "Casting 2 dummies then real song", song)
                        return
                        
                    elseif slot_number == 4 and active_songs == 3 then
                        -- Need dummy for slot 4 only
                        local dummy_song = dummy_songs[4]  -- Goblin Gavotte
                        send_command('input /ja "Pianissimo" <me>')
                        send_command('wait 1.5; input /ma "' .. dummy_song .. '" ' .. target_cmd)
                        send_command('wait 8; input /ja "Pianissimo" <me>')
                        send_command('wait 9.5; input /ma "' .. song .. '" ' .. target_cmd)
                        MessageUtils.brd_message("BRD", "Casting dummy then real song", song)
                        return
                    end
                else
                    -- active_songs >= slot_number, target has enough songs - cast directly
                    MessageUtils.brd_message("Info", "Target has " .. active_songs .. " songs - casting directly", song)
                    -- Continue to normal casting below (no return)
                end
            end
        else
            -- Targeting self or no target - check MY songs (this works normally)
            active_songs = BRDSongCounter.count_active_songs()
            target_info = " on self"
            
            -- Intelligent dummy handling based on current song count and target slot
            if active_songs < 2 then
                MessageUtils.error("BRD", "You need 2 songs before slot " .. slot_number)
                MessageUtils.brd_message("Tip", "Cast song1 and song2 first", "Then use song" .. slot_number)
                return
            elseif active_songs < slot_number then
                -- Need to fill slots with dummies up to the target slot
                local dummies_needed = slot_number - active_songs
                MessageUtils.brd_message("Info", "You have " .. active_songs .. " songs - need " .. dummies_needed .. " dummies", "")
                
                if slot_number == 3 and active_songs == 2 then
                    -- Need dummy for slot 3
                    local dummy_song = dummy_songs[3]  -- Gold Capriccio
                    send_command('input /ma "' .. dummy_song .. '" <me>')
                    send_command('wait 6; input /ma "' .. song .. '" <me>')
                    MessageUtils.brd_message("BRD", "Casting dummy then real song", song)
                    return
                    
                elseif slot_number == 4 and active_songs == 2 then
                    -- Need dummy for slot 3 AND slot 4
                    local dummy3 = dummy_songs[3]  -- Gold Capriccio
                    local dummy4 = dummy_songs[4]  -- Goblin Gavotte
                    send_command('input /ma "' .. dummy3 .. '" <me>')
                    send_command('wait 6; input /ma "' .. dummy4 .. '" <me>')
                    send_command('wait 12; input /ma "' .. song .. '" <me>')
                    MessageUtils.brd_message("BRD", "Casting 2 dummies then real song", song)
                    return
                    
                elseif slot_number == 4 and active_songs == 3 then
                    -- Need dummy for slot 4 only
                    local dummy_song = dummy_songs[4]  -- Goblin Gavotte
                    send_command('input /ma "' .. dummy_song .. '" <me>')
                    send_command('wait 6; input /ma "' .. song .. '" <me>')
                    MessageUtils.brd_message("BRD", "Casting dummy then real song", song)
                    return
                end
            else
                -- active_songs >= slot_number, we can cast directly
                MessageUtils.brd_message("Info", "You have " .. active_songs .. " songs - casting directly", song)
                -- Continue to normal casting below (no return)
            end
        end
    end
    
    -- Set appropriate mode for real songs
    BRDUtils.set_song_mode('Party')
    
    -- TARGET DETECTION: Check if targeting self or others with song counting
    local target_cmd = "<stnpc>"  -- Default to sub-target NPC
    local needs_pianissimo = false
    
    if player.target and player.target.id and player.target.id ~= 0 then
        if player.target.id == player.id then
            -- Targeting self, cast on self
            target_cmd = "<me>"
            needs_pianissimo = false
            MessageUtils.brd_message("Self-target", song, "Direct cast")
        else
            -- Targeting someone else, need Pianissimo
            target_cmd = "<stpc>"  -- Sub-target PC (the person you're targeting)
            needs_pianissimo = true
            
            -- Count songs on target if they're in party
            local target_song_count, target_name = BRDSongCounter.get_target_song_count()
            if target_song_count > 0 then
                MessageUtils.brd_message("Pianissimo", song, target_name .. " (" .. target_song_count .. " songs)")
            else
                MessageUtils.brd_message("Pianissimo", song, target_name)
            end
        end
    else
        -- No valid target, cast on self
        target_cmd = "<me>"
        needs_pianissimo = false  -- Explicitly set to false
        MessageUtils.brd_message("No target", "Casting on self", song)
    end
    
    -- Special handling for slot 1 (Honor March with Marcato)
    if slot_number == 1 and song == 'Honor March' then
        -- Check if Marcato is available and use it
        if BRDAbilities.is_marcato_available() then
            MessageUtils.brd_message("Marcato", "Honor March", "Enhanced duration")
            
            if needs_pianissimo then
                send_command('input /ja "Pianissimo" <me>')
                send_command('wait 1.5; input /ja "Marcato" <me>')
                send_command('wait 3; input /ma "' .. song .. '" ' .. target_cmd)
            else
                send_command('input /ja "Marcato" <me>')
                send_command('wait 1.5; input /ma "' .. song .. '" ' .. target_cmd)
            end
        else
            if needs_pianissimo then
                send_command('input /ja "Pianissimo" <me>')
                send_command('wait 1.5; input /ma "' .. song .. '" ' .. target_cmd)
            else
                MessageUtils.brd_message("Song " .. slot_number, song, pack_name .. " pack")
                send_command('input /ma "' .. song .. '" ' .. target_cmd)
            end
        end
    else
        -- Normal song casting with target detection
        
        
        if needs_pianissimo then
            send_command('input /ja "Pianissimo" <me>')
            send_command('wait 1.5; input /ma "' .. song .. '" ' .. target_cmd)
        else
            MessageUtils.brd_message("Song " .. slot_number, song, pack_name .. " pack")
            send_command('input /ma "' .. song .. '" ' .. target_cmd)
        end
    end
end

--- Internal function to cast song 3 or 4 after dummies (called by delayed command)
--- @param slot_number number The slot to cast (3 or 4)
function BRDSongCaster.cast_single_song_real(slot_number)
    -- This is called after dummies are cast, so just cast the real song
    BRDUtils.set_song_mode('Party')
    
    local pack_name = (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local pack = BRD_CONFIG.SONG_PACKS[pack_name]
    
    if pack and pack.songs and pack.songs[slot_number] then
        local song = pack.songs[slot_number]
        
        -- Same target detection as main function
        local target_cmd = "<stnpc>"
        local needs_pianissimo = false
        
        if player.target then
            if player.target.id == player.id then
                target_cmd = "<me>"
            else
                target_cmd = "<stpc>"  -- Sub-target PC
                needs_pianissimo = true
            end
        end
        
        if needs_pianissimo then
            send_command('input /ja "Pianissimo" <me>')
            send_command('wait 1.5; input /ma "' .. song .. '" ' .. target_cmd)
        else
            MessageUtils.brd_message("Song " .. slot_number, song, "Replacing dummy")
            send_command('input /ma "' .. song .. '" ' .. target_cmd)
        end
    end
end

--- Get the current song for a specific slot
--- @param slot_number number The slot number (1-5)
--- @return string The song name for that slot
function BRDSongCaster.get_song_for_slot(slot_number)
    if not slot_number or slot_number < 1 or slot_number > 5 then
        return "Invalid Slot"
    end
    
    -- Get current pack
    local pack_name = (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
    local pack = BRD_CONFIG.SONG_PACKS[pack_name]
    
    if not pack or not pack.songs then
        return "No Pack"
    end
    
    local song = pack.songs[slot_number]
    
    -- Handle Victory March replacement for slot 5
    if slot_number == 5 and (buffactive['Haste'] or buffactive['Haste II']) then
        local replacement = state.VictoryMarchReplace and state.VictoryMarchReplace.value
        local replacement_songs = {
            Madrigal = 'Blade Madrigal',
            Minne = 'Knight\'s Minne V',
            Scherzo = 'Sentinel\'s Scherzo'
        }
        
        if replacement and replacement_songs[replacement] then
            if pack.songs[4] == replacement_songs[replacement] then
                song = 'Adventurer\'s Dirge'
            else
                song = replacement_songs[replacement]
            end
        end
    end
    
    return song or "Empty"
end

--- Cast threnody of the current element state
function BRDSongCaster.cast_threnody_element()
    if not state or not state.ThrenodyElement then
        MessageUtils.error("BRD", "Threnody Element state not initialized")
        return
    end

    local element = state.ThrenodyElement.value
    local spell_name = element .. ' Threnody II'

    MessageUtils.brd_spell_message(spell_name, "Casting", "Element: " .. element)
    send_command('input /ma "' .. spell_name .. '" <stnpc>')
end

--- Cast carol of current element from CarolElement state
function BRDSongCaster.cast_carol_element()
    if not state or not state.CarolElement then
        MessageUtils.error("BRD", "Carol Element state not initialized")
        return
    end

    local element = state.CarolElement.value
    local spell_name = element .. ' Carol'

    MessageUtils.brd_spell_message(spell_name, "Casting", "Element: " .. element)
    send_command('input /ma "' .. spell_name .. '" <me>')
end

--- Cast etude of current type from EtudeType state
function BRDSongCaster.cast_etude_type()
    if not state or not state.EtudeType then
        MessageUtils.error("BRD", "Etude Type state not initialized")
        return
    end

    local etude_stat = state.EtudeType.value

    -- Map stat abbreviations to actual Etude spell names (using tier II for max effect)
    local etude_mapping = {
        STR = 'Herculean Etude', -- STR +15 à +24
        DEX = 'Uncanny Etude',   -- DEX +15 à +24
        VIT = 'Vital Etude',     -- VIT +15 à +24
        AGI = 'Swift Etude',     -- AGI +15 à +24
        INT = 'Sage Etude',      -- INT +15 à +24
        MND = 'Logical Etude',   -- MND +15 à +24
        CHR = 'Bewitching Etude' -- CHR +15 à +24
    }

    local spell_name = etude_mapping[etude_stat]
    if not spell_name then
        MessageUtils.error("BRD", "Unknown Etude type: " .. etude_stat)
        return
    end

    MessageUtils.brd_spell_message(spell_name, "Casting", "Stat: " .. etude_stat)
    send_command('input /ma "' .. spell_name .. '" <me>')
end

return BRDSongCaster
