---============================================================================
--- FFXI GearSwap Job Module - Bard Advanced Functions (Clean Version)
---============================================================================
--- Professional Bard job-specific functionality providing:
---
--- • **Song Refine System** - Automatic tier downgrading for debuff songs
--- • **Song Rotation Management** - Refresh and full rotation systems
--- • **Nightingale/Troubadour Combo** - Automated ability chaining
--- • **Threnody Element Cycling** - Dynamic element selection
--- • **Precast Integration** - Automatic song optimization
---
--- @file jobs/brd/BRD_FUNCTION.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2025-08-10 | Modified: 2025-08-16
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---============================================================================

-- Load Windower resources for spell data
local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end

-- Load BRD configuration
local success_BRD_CONFIG, BRD_CONFIG = pcall(require, 'jobs/brd/BRD_CONFIG')
if not success_BRD_CONFIG then
    error("Failed to load jobs/brd/BRD_CONFIG: " .. tostring(BRD_CONFIG))
end

-- Load message utilities for consistent formatting
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

-- Load BRD buff ID system
local success_BRD_BUFF_IDS, BRD_BUFF_IDS = pcall(require, 'jobs/brd/modules/BRD_BUFF_IDS')
if not success_BRD_BUFF_IDS then
    error("Failed to load jobs/brd/modules/BRD_BUFF_IDS: " .. tostring(BRD_BUFF_IDS))
end

-- Load BRD song counter module
local success_BRDSongCounter, BRDSongCounter = pcall(require, 'jobs/brd/modules/BRD_SONG_COUNTER')
if not success_BRDSongCounter then
    error("Failed to load jobs/brd/modules/brd_song_counter: " .. tostring(BRDSongCounter))
end

-- Load BRD abilities module
local success_BRDAbilities, BRDAbilities = pcall(require, 'jobs/brd/modules/BRD_ABILITIES')
if not success_BRDAbilities then
    error("Failed to load jobs/brd/modules/brd_abilities: " .. tostring(BRDAbilities))
end

-- Load BRD debug module
local success_BRDDebug, BRDDebug = pcall(require, 'jobs/brd/modules/brd_debug')
if not success_BRDDebug then
    error("Failed to load jobs/brd/modules/brd_debug: " .. tostring(BRDDebug))
end

-- Load BRD song caster module
local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/brd_song_caster')
if not success_BRDSongCaster then
    error("Failed to load jobs/brd/modules/brd_song_caster: " .. tostring(BRDSongCaster))
end

-- Load BRD refresh module
local success_BRDRefresh, BRDRefresh = pcall(require, 'jobs/brd/modules/brd_refresh')
if not success_BRDRefresh then
    error("Failed to load jobs/brd/modules/brd_refresh: " .. tostring(BRDRefresh))
end

---============================================================================
--- HELPER FUNCTIONS FOR CONFIGURATION ACCESS
---============================================================================


---============================================================================
--- SONG REFINE SYSTEM
---============================================================================

--- Get song correspondences from configuration
local song_correspondences = BRD_CONFIG.SONG_REFINE

--- Refine songs based on recast and MP availability
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments for cancellation
function refine_brd_songs(spell, eventArgs)
    if not spell or spell.type ~= 'BardSong' then
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp

    -- Parse spell name to get category and tier
    local spellCategory, spellLevel = spell.name:match('(%a+%s?%a+)%s*(%a*)')

    -- Special handling for compound names
    if spell.name:find('Horde Lullaby') then
        spellCategory = 'Horde Lullaby'
        spellLevel = spell.name:match('II') and 'II' or ''
    elseif spell.name:find('Foe Lullaby') then
        spellCategory = 'Foe Lullaby'
        spellLevel = spell.name:match('II') and 'II' or ''
    elseif spell.name:find('Carnage Elegy') then
        spellCategory = 'Carnage Elegy'
        spellLevel = ''
    elseif spell.name:find('Battlefield Elegy') then
        spellCategory = 'Battlefield Elegy'
        spellLevel = ''
    elseif spell.name:find('Foe Requiem') then
        spellCategory = 'Foe Requiem'
        spellLevel = spell.name:match('VII') or spell.name:match('VI') or ''
    elseif spell.name:find('Threnody') then
        -- Extract element and tier for threnodies
        local element = spell.name:match('(%a+)%s+Threnody')
        if element then
            spellCategory = element .. ' Threnody'
            spellLevel = spell.name:match('II') or ''
        end
    end

    -- Skip refine for Elegy and Requiem but show recast if not ready
    if spellCategory == 'Carnage Elegy' or spellCategory == 'Battlefield Elegy' or spellCategory == 'Foe Requiem' then
        local spell_data = res.spells:with('en', spell.english)
        if spell_data then
            local recast_time = spell_recasts[spell_data.recast_id]
            if recast_time and recast_time > 0 then
                -- Convert from centiseconds to seconds (FFXI recast times are in centiseconds)
                local recast_seconds = recast_time / 100
                MessageUtils.brd_song_cooldown_message(spell.english, recast_seconds)
                eventArgs.cancel = true
                return
            elseif player_mp < spell.mp_cost then
                MessageUtils.insufficient_mp_message(spell.english, spell.mp_cost, player_mp)
                eventArgs.cancel = true
                return
            end
        end
        return -- Ready to cast normally
    end

    local correspondence = song_correspondences[spellCategory]
    if not correspondence then
        return -- No tier system for this song
    end

    -- Check if spell is on cooldown
    local spell_data = res.spells:with('en', spell.english)
    if not spell_data then
        return
    end

    local recast_time = spell_recasts[spell_data.recast_id]

    -- If spell is not on cooldown and we have enough MP, cast it
    if (not recast_time or recast_time == 0) and player_mp >= spell.mp_cost then
        return
    end

    -- Try to find a lower tier that's available
    local currentLevel = spellLevel
    local newSpell = nil

    while currentLevel and correspondence and correspondence[currentLevel] do
        local replacement = correspondence[currentLevel]
        local replacementSpell = replacement.name

        -- Check if replacement spell exists and is available
        local replacementData = res.spells:with('en', replacementSpell)
        if replacementData then
            local replacementRecast = spell_recasts[replacementData.recast_id]

            -- Check if replacement is available and we have MP for it
            if (not replacementRecast or replacementRecast == 0) and player_mp >= replacementData.mp_cost then
                newSpell = replacementSpell
                break
            end
        end

        -- Move to next lower tier
        currentLevel = replacement.replace
    end

    -- If we found a replacement, use it
    if newSpell and newSpell ~= spell.english then
        -- Validate spell name for command injection prevention
        local safe_spell = newSpell:match("^[%w%s%-':.]+$") and newSpell or spell.english
        if safe_spell ~= newSpell then
            log.warning("[BRD] Invalid spell name detected, using original: %s", spell.english)
            safe_spell = spell.english
        end
        
        -- Custom message with both spell names in cyan
        local cyan_code = string.char(0x1F, 005)
        local white_code = string.char(0x1F, 001)  
        local formatted_message = cyan_code .. spell.english .. white_code .. " -> " .. cyan_code .. safe_spell .. white_code
        MessageUtils.brd_message("Song Refine", formatted_message, "Auto upgrade")
        send_command('wait ' ..
            BRD_CONFIG.TIMINGS.fast_cast_delay .. '; input /ma "' .. safe_spell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true
    elseif recast_time and recast_time > 0 then
        -- Show recast time if no replacement found
        local recast_seconds = recast_time / 100
        MessageUtils.brd_song_cooldown_message(spell.english, recast_seconds)
        eventArgs.cancel = true
    elseif player_mp < spell.mp_cost then
        -- Not enough MP
        MessageUtils.insufficient_mp_message(spell.english, spell.mp_cost, player_mp)
        eventArgs.cancel = true
    end
end

---============================================================================
--- SONG MANAGEMENT FUNCTIONS
---============================================================================

--- Use BRDSongCaster module for threnody casting
function cast_threnody_element()
    BRDSongCaster.cast_threnody_element()
end

--- Use BRDSongCaster module for carol casting
function cast_carol_element()
    BRDSongCaster.cast_carol_element()
end

--- Use BRDSongCaster module for etude casting
function cast_etude_type()
    BRDSongCaster.cast_etude_type()
end

---============================================================================
--- GLOBAL FUNCTIONS FOR EXTERNAL COMMANDS
---============================================================================
--- These functions are kept as global for backward compatibility with
--- user commands like: //gs c cast_melee_songs
--- They delegate to the appropriate modules

--- Use BRDRefresh module for song refreshing
function refresh_songs()
    BRDRefresh.refresh_songs()
end

--- Use BRDSongCaster module for all songs casting
function cast_all_songs()
    BRDSongCaster.cast_melee_songs()
end

--- Cast melee songs (full rotation with dummies - party buffs)
function cast_melee_songs()
    BRDSongCaster.cast_melee_songs()
end

--- Refresh melee songs (party buffs) with intelligent counting
function refresh_melee_songs()
    BRDRefresh.refresh_melee_songs()
end

--- Cast tank songs (full rotation with dummies - party buffs using Tank pack)
function cast_tank_songs()
    BRDSongCaster.cast_tank_songs()
end

--- Refresh tank songs (party buffs using Tank pack) with intelligent counting
function refresh_tank_songs()
    BRDRefresh.refresh_tank_songs()
end

--- Cast healer songs (full rotation with dummies - party buffs using Healer pack)
function cast_healer_songs()
    BRDSongCaster.cast_healer_songs()
end

--- Refresh healer songs (party buffs using Healer pack) with intelligent counting
function refresh_healer_songs()
    BRDRefresh.refresh_healer_songs()
end

--- Cast dummy songs to prepare slots (4 or 5 depending on Clarion Call)
function cast_dummy_songs()
    BRDSongCaster.cast_dummy_songs()
end

--- Cast tank songs with Pianissimo (single target full rotation)
function cast_tank_pianissimo()
    BRDSongCaster.cast_tank_pianissimo()
end

--- Cast healer songs with Pianissimo (single target full rotation)
function cast_healer_pianissimo()
    BRDSongCaster.cast_healer_pianissimo()
end

--- Cast melee songs with Pianissimo (single target full rotation using current pack)
function cast_melee_pianissimo()
    BRDSongCaster.cast_melee_pianissimo()
end

--- Cast Carol songs (full rotation with dummies - party buffs using Carol pack)
function cast_carol_songs()
    BRDSongCaster.cast_carol_songs()
end

--- Refresh Carol songs (party buffs using Carol pack) with intelligent counting
function refresh_carol_songs()
    BRDRefresh.refresh_carol_songs()
end

--- Cast Scherzo songs (full rotation with dummies - party buffs using Scherzo pack)
function cast_scherzo_songs()
    BRDSongCaster.cast_scherzo_songs()
end

--- Refresh Scherzo songs (party buffs using Scherzo pack) with intelligent counting
function refresh_scherzo_songs()
    BRDRefresh.refresh_scherzo_songs()
end

---============================================================================
--- ABILITY COMBO FUNCTIONS
---============================================================================

--- Use BRDAbilities module for Nightingale + Troubadour combo
function cast_nightingale_troubadour()
    BRDAbilities.cast_nightingale_troubadour()
end

--- Show current song status (for //gs c songs command)
function songs()
    BRDDebug.get_current_song_status()
end

--- Show detailed buff analysis (for //gs c debugbuffs command)
function debugbuffs()
    BRDDebug.debug_active_buffs()
end

---============================================================================
--- PRECAST INTEGRATION
---============================================================================

--- Handle precast gear for songs with refine integration
--- @param spell table Spell object from GearSwap
--- @param action table Action data
--- @param spellMap string Spell mapping category
--- @param eventArgs table Event arguments for cancellation
function job_precast(spell, action, spellMap, eventArgs)
    -- Check weapon skill range FIRST (before any other WS processing)
    if spell.type == 'WeaponSkill' then
        if not Ws_range(spell) then
            eventArgs.cancel = true
            return -- WS cancelled if too far
        end
    end

    -- Handle WeaponSkill TP bonus logic (like WAR)
    if spell.type == 'WeaponSkill' then
        local success_WeaponUtils, WeaponUtils = pcall(require, 'equipment/WEAPONS')
        if not success_WeaponUtils then
            error("Failed to load core/weapons: " .. tostring(WeaponUtils))
        end

        -- Get weapon-specific TP bonus
        local weapon_tp_bonus = WeaponUtils.get_weapon_tp_bonus(player.equipment.main)

        -- BRD weapon skills info (no gear TP bonuses like WAR's Boii Cuisses)
        local ws_info = {
            ["Savage Blade"] = { tp_bonus_gear_always = 0 },
            ["Rudra's Storm"] = { tp_bonus_gear_always = 0 },
            ["Evisceration"] = { tp_bonus_gear_always = 0 },
            ["Mordant Rime"] = { tp_bonus_gear_always = 0 },
        }

        local ws = ws_info[spell.name]
        local tp_bonus_mode = WeaponUtils.get_tp_bonus_mode(spell, ws, weapon_tp_bonus)

        local ws_name = spell.name
        local ws_set = sets.precast.WS[ws_name] or sets.precast.WS

        if tp_bonus_mode == 'TPBonus' and ws_set.TPBonus then
            MessageUtils.brd_ws_message(ws_name, "Moonshade")
            equip(ws_set.TPBonus)
        else
            equip(ws_set)
        end

        eventArgs.handled = true
        return
    elseif spell.type == 'BardSong' then
        -- Honor March instrument requirement handled in sets

        -- Check for song refine (debuff songs with tier system)
        if spell.name:find('Lullaby') or spell.name:find('Elegy') or
            spell.name:find('Requiem') or spell.name:find('Threnody') then
            refine_brd_songs(spell, eventArgs)
            if eventArgs.cancel then
                return
            end
        else
            -- For all other songs (including Mazurka), check recast
            local spell_recasts = windower.ffxi.get_spell_recasts()
            local spell_data = res.spells:with('en', spell.english)

            if spell_data then
                local recast_time = spell_recasts[spell_data.recast_id]
                if recast_time and recast_time > 0 then
                    local recast_seconds = recast_time / 100
                    MessageUtils.brd_song_cooldown_message(spell.english, recast_seconds)
                    eventArgs.cancel = true
                    return
                elseif player.mp < spell.mp_cost then
                    MessageUtils.insufficient_mp_message(spell.english, spell.mp_cost, player.mp)
                    eventArgs.cancel = true
                    return
                end
            end
        end

        -- Start with Fast Cast set
        equip(sets.precast.FC)

        -- Special instrument requirements for specific songs
        if spell.name == 'Honor March' then
            -- CRITICAL: Honor March MUST have Marsyas equipped to cast
            equip({ range = "Marsyas" })
            -- Store that we're casting Honor March for later protection
            _G.casting_honor_march = true
        elseif spell.name == 'Aria of Passion' then
            equip({ range = "Loughnashade" }) -- Aria requires Loughnashade
        end
    end
end

---============================================================================
--- HONOR MARCH PROTECTION (SIMPLIFIED)
---============================================================================

--- Simple Honor March protection - only during casting
--- Override midcast sets to use correct sub weapon based on subjob
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- For song casting, use Genmei Shield if subjob can't dual wield
    if spell.type == 'BardSong' and (player.sub_job ~= 'DNC' and player.sub_job ~= 'NIN') then
        equip({sub = "Genmei Shield"})
    end
end

function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.name == 'Honor March' then
        _G.casting_honor_march = false
    end
    
    -- Force correct sub weapon after any spell (respects F7 SubSet choice)
    if state and state.SubSet then
        if state.SubSet.value == 'Genmei Shield' and sets.Shield then
            windower.send_command('gs equip sets.Shield')
        elseif state.SubSet.value == 'Demers. Degen +1' and sets.DualWield then
            windower.send_command('gs equip sets.DualWield')
        end
    end
end

--- Customize idle set for standard BRD functionality
function job_customize_idle_set(idleSet)
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    local finalSet = EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for BRD
        nil,            -- No PDT set for BRD idle
        nil             -- No MDT set for BRD idle
    )
    
    -- Override sub weapon based on SubSet state (respects F7 manual choice)
    if state and state.SubSet then
        if state.SubSet.value == 'Genmei Shield' and sets.Shield then
            finalSet.sub = sets.Shield.sub
        elseif state.SubSet.value == 'Demers. Degen +1' and sets.DualWield then
            finalSet.sub = sets.DualWield.sub
        end
    end
    
    return finalSet
end

---============================================================================
--- DEBUG INTEGRATION (using BRDDebug module)
---============================================================================

--- Use BRDDebug module for packet monitoring
function toggle_packet_debug()
    BRDDebug.toggle_packet_debug()
end

--- Use BRDDebug module for packet song status
function show_packet_song_status()
    BRDDebug.show_packet_song_status()
end

--- Use BRDDebug module for debug buffs display
function debug_active_buffs()
    BRDDebug.debug_active_buffs()
end

--- Use BRDDebug module for current song status
function get_current_song_status()
    BRDDebug.get_current_song_status()
end

--- Use BRDDebug module for fifth song refresh check
function can_refresh_fifth_song(fifth_song_family)
    return BRDDebug.can_refresh_fifth_song(fifth_song_family)
end

---============================================================================
--- GLOBAL FUNCTION EXPORTS
---============================================================================

-- Export functions for command system access
_G.refine_brd_songs = refine_brd_songs
_G.cast_threnody_element = cast_threnody_element
_G.cast_carol_element = cast_carol_element
_G.cast_etude_type = cast_etude_type
_G.cast_nightingale_troubadour = cast_nightingale_troubadour
_G.refresh_songs = refresh_songs
_G.cast_all_songs = cast_all_songs
_G.cast_melee_songs = cast_melee_songs
_G.refresh_melee_songs = refresh_melee_songs
_G.cast_tank_songs = cast_tank_songs
_G.refresh_tank_songs = refresh_tank_songs
_G.cast_healer_songs = cast_healer_songs
_G.refresh_healer_songs = refresh_healer_songs
_G.cast_dummy_songs = cast_dummy_songs
_G.count_active_songs = count_active_songs
_G.debug_active_buffs = debug_active_buffs
_G.toggle_packet_debug = toggle_packet_debug
_G.show_packet_song_status = show_packet_song_status
_G.get_current_song_status = get_current_song_status
_G.can_refresh_fifth_song = can_refresh_fifth_song
