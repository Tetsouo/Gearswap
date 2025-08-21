---============================================================================
--- FFXI GearSwap BRD Utilities Module
---============================================================================
--- Common utility functions shared across BRD modules to eliminate code
--- duplication. Provides centralized song pack management, timing calculations,
--- and display formatting for consistent behavior across all BRD modules.
---
--- @file jobs/brd/modules/brd_utils.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires BRD_CONFIG, BRDAbilities
---============================================================================

-- Load dependencies
local success_BRD_CONFIG, BRD_CONFIG = pcall(require, 'jobs/brd/BRD_CONFIG')
if not success_BRD_CONFIG then
    error("Failed to load jobs/brd/BRD_CONFIG: " .. tostring(BRD_CONFIG))
end

local BRDUtils = {}

---============================================================================
--- COMMON HELPER FUNCTIONS
---============================================================================

--- Shorten song names for display using BRD_CONFIG mapping
--- @param song_name string Full song name
--- @return string Shortened song name
function BRDUtils.shorten_song_name(song_name)
    return BRD_CONFIG.SHORT_NAMES[song_name] or song_name
end

-- Cache BRDAbilities to avoid multiple requires
local _BRDAbilities = nil
local function get_brd_abilities()
    if not _BRDAbilities then
        local success_BRDAbilities, BRDAbilities = pcall(require, 'jobs/brd/modules/BRD_ABILITIES')
        if not success_BRDAbilities then
            error("Failed to load jobs/brd/modules/brd_abilities: " .. tostring(BRDAbilities))
        end
        _BRDAbilities = BRDAbilities
    end
    return _BRDAbilities
end

--- Get the appropriate song delay based on Nitro status
--- @return number Song delay in seconds
function BRDUtils.get_song_delay()
    local BRDAbilities = get_brd_abilities()
    return BRDAbilities.is_nitro_active() and BRD_CONFIG.TIMINGS.song_delay_nitro or BRD_CONFIG.TIMINGS.song_delay
end

--- Get dummy pack from configuration
--- @param pack_name string Name of the dummy pack
--- @return table Array of dummy songs
function BRDUtils.get_dummy_pack(pack_name)
    local pack = BRD_CONFIG.DUMMY_PACKS[pack_name]
    return pack and pack.songs or BRD_CONFIG.DUMMY_PACKS.Trash.songs
end

---============================================================================
--- SONG PACK MANAGEMENT
---============================================================================

--- Helper function to get Victory March replacement song
--- @param replacement_mode string Replacement type from config
--- @return string Replacement song name
local function get_victory_march_replacement(replacement_mode)
    local replacements = BRD_CONFIG.VICTORY_MARCH_REPLACE.replacements
    return replacements[replacement_mode] or replacements[BRD_CONFIG.VICTORY_MARCH_REPLACE.default]
end

--- Helper function to check if pack supports Victory March replacement
--- @param pack_name string Song pack name
--- @return boolean true if pack supports replacement
local function is_melee_pack(pack_name)
    local melee_packs = { Dirge = true, Madrigal = true, Minne = true, Etude = true, Carol = true, Scherzo = true }
    return melee_packs[pack_name] == true
end

--- Get song pack from configuration with dynamic Victory March replacement
--- @param pack_name string Name of the song pack
--- @return table Array of songs with potential Victory March replacement
function BRDUtils.get_song_pack(pack_name)
    local pack = BRD_CONFIG.SONG_PACKS[pack_name]
    local songs = pack and pack.songs or BRD_CONFIG.SONG_PACKS.Dirge.songs

    -- Create a copy to avoid modifying the original
    local modified_songs = {}
    for i, song in ipairs(songs) do
        modified_songs[i] = song
    end

    -- Check for Victory March replacement
    if is_melee_pack(pack_name) and
        BRD_CONFIG.VICTORY_MARCH_REPLACE.enabled and
        state and state.VictoryMarchReplace and
        (buffactive['Haste'] or buffactive['Haste II']) then
        local replacement_song = get_victory_march_replacement(state.VictoryMarchReplace.value)

        -- Replace Victory March with the configured replacement
        for i, song in ipairs(modified_songs) do
            if song == 'Victory March' then
                modified_songs[i] = replacement_song
                break
            end
        end

        -- Handle conflicts: if replacement already exists, replace duplicate with Adventurer's Dirge
        local first_occurrence = nil
        for i, song in ipairs(modified_songs) do
            if song == replacement_song then
                if not first_occurrence then
                    first_occurrence = i
                else
                    modified_songs[i] = 'Adventurer\'s Dirge'
                    break
                end
            end
        end
    end

    -- Check for Carol element replacement (for Carol pack)
    if pack_name == 'Carol' and state and state.CarolElement then
        local carol_element = state.CarolElement.value
        local dynamic_carol = carol_element .. ' Carol'

        -- Replace any Carol with the current element
        for i, song in ipairs(modified_songs) do
            if song:find('Carol$') then -- Matches any song ending with "Carol"
                modified_songs[i] = dynamic_carol
                break
            end
        end
    end

    -- Check for Etude type replacement (for Etude pack)
    if pack_name == 'Etude' and state and state.EtudeType then
        local etude_stat = state.EtudeType.value

        -- Map stat abbreviations to actual Etude spell names (same mapping as in song_caster)
        local etude_mapping = {
            STR = 'Herculean Etude', -- STR +15 à +24
            DEX = 'Uncanny Etude',   -- DEX +15 à +24
            VIT = 'Vital Etude',     -- VIT +15 à +24
            AGI = 'Swift Etude',     -- AGI +15 à +24
            INT = 'Sage Etude',      -- INT +15 à +24
            MND = 'Logical Etude',   -- MND +15 à +24
            CHR = 'Bewitching Etude' -- CHR +15 à +24
        }

        local dynamic_etude = etude_mapping[etude_stat]
        if dynamic_etude then
            -- Replace any Etude with the current type
            for i, song in ipairs(modified_songs) do
                if song:find('Etude$') then -- Matches any song ending with "Etude"
                    modified_songs[i] = dynamic_etude
                    break
                end
            end
        end
    end


    return modified_songs
end

---============================================================================
--- TIMING AND PHASE CALCULATIONS
---============================================================================

--- Calculate delays for song casting with Marcato consideration
--- @param song_index number Position of the song in rotation (1-based)
--- @param marcato_used boolean Whether Marcato was used for first song
--- @param song_delay number Base delay between songs
--- @return number Calculated delay for this song
function BRDUtils.calculate_song_delay(song_index, marcato_used, song_delay)
    local delay = (song_index - 1) * song_delay
    if marcato_used and song_index == 1 then
        delay = delay + BRD_CONFIG.TIMINGS.marcato_delay
    end
    return delay
end

--- Calculate phase delays for multi-phase rotations
--- @param phase_songs number Number of songs in current phase
--- @param marcato_used boolean Whether Marcato was used
--- @param song_delay number Base delay between songs
--- @return number Total delay for the phase
function BRDUtils.calculate_phase_delay(phase_songs, marcato_used, song_delay)
    local base_delay = phase_songs * song_delay
    local marcato_offset = marcato_used and BRD_CONFIG.TIMINGS.marcato_delay or 0
    return base_delay + marcato_offset
end

---============================================================================
--- DISPLAY AND FORMATTING
---============================================================================

--- Format song list for display messages
--- @param songs table Array of song names
--- @param max_count number Maximum number of songs to format
--- @return table Array of shortened song names
function BRDUtils.format_song_list(songs, max_count)
    local song_list = {}
    for i = 1, (max_count or #songs) do
        if songs[i] then
            table.insert(song_list, BRDUtils.shorten_song_name(songs[i]))
        end
    end
    return song_list
end

--- Check if Marcato should be used for a song rotation
--- @param songs table Array of songs in the rotation
--- @return boolean true if Marcato should be used
function BRDUtils.should_use_marcato(songs)
    local BRDAbilities = get_brd_abilities()
    return songs[1] == 'Honor March' and BRDAbilities.is_marcato_available()
end

---============================================================================
--- STATE MANAGEMENT HELPERS
---============================================================================

--- Set song mode safely if state exists
--- @param mode string Song mode to set ('Party', 'Dummy', etc.)
function BRDUtils.set_song_mode(mode)
    if state and state.SongMode then
        state.SongMode:set(mode)
    end
end

--- Get current BRD rotation pack name
--- @return string Current rotation pack name (defaults to 'Dirge')
function BRDUtils.get_current_rotation()
    return (state and state.BRDRotation and state.BRDRotation.value) or 'Dirge'
end

return BRDUtils
