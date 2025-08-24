---============================================================================
--- FFXI GearSwap Configuration - Bard (BRD) - Clean Version
---============================================================================
--- Streamlined BRD configuration focused on essential functionality:
---
--- • **Song Refine System** - Automatic tier downgrading for debuff songs
--- • **Simplified Commands** - refresh, allsongs, and element cycling
--- • **Nightingale/Troubadour** - Automated ability combo system
--- • **Weapon Management** - Subjob-based weapon selection
--- • **Clean F-key Bindings** - Only essential functions
---
--- @file Tetsouo_BRD.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2025-08-10 | Modified: 2025-08-16
--- @requires Windower FFXI, GearSwap addon, Mote-Include v2.0+
---
--- Key Bindings (Simplified):
---   F1   : Cycle BRD Song Packs (Madrigal <-> Minne <-> Etude <-> Carol <-> Dirge <-> Scherzo)
---   F2   : Cycle VictoryMarchReplace (Madrigal <-> Minne <-> Scherzo)
---   F3   : Cycle EtudeType (STR/DEX/VIT/AGI/INT/MND/CHR)
---   F4   : Cycle CarolElement (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
---   F5   : Cycle ThrenodyElement (Fire/Ice/Wind/Earth/Lightning/Water/Light/Dark)
---   F6   : Cycle MainWeapon (Naegling <-> Twashtar)
---   F7   : Cycle SubWeapon (Shield <-> DualWield)
---   F9   : Cycle HybridMode (PDT <-> Normal <-> MDT)
---
--- Song Packs (Victory March is dynamically replaced when Haste buff is active):
---   Dirge: Honor March + Minuet V/IV + Victory March + Adventurer's Dirge
---   Madrigal: Honor March + Minuet V/IV + Victory March + Blade Madrigal
---   Minne: Honor March + Minuet V/IV + Victory March + Knight's Minne V
---   Etude: Honor March + Minuet V/IV + Victory March + Herculean Etude
---
--- Single Target Packs (Command only - not in cycle):
---   Tank: Victory March + Knight's Minne V + Mage's Ballad III/II + Sentinel's Scherzo
---   Healer: Victory March + Knight's Minne V + Mage's Ballad III/II + Sentinel's Scherzo
---
--- Victory March Replacement (F5):
---   Madrigal: Replace Victory March with Blade Madrigal when Haste/Haste II active (default)
---   Minne: Replace Victory March with Knight's Minne V when Haste/Haste II active
---   Scherzo: Replace Victory March with Sentinel's Scherzo when Haste/Haste II active
---
--- Smart Conflict Resolution:
---   If replacement song already exists in pack (e.g., Madrigal pack + Madrigal mode),
---   the duplicate 5th song is automatically replaced with Adventurer's Dirge
---
--- Essential Commands:
---   Melee/DPS songs (uses current pack from F3):
---   //gs c meleesong    : Full rotation with dummies (party buffs)
---   //gs c meleerefresh : Refresh melee songs only
---   
---   Tank songs (Victory March + Minne V + Ballad III/II + Sirvente):
---   //gs c tanksong     : Full rotation with dummies (party buffs)
---   //gs c tankrefresh  : Refresh tank songs only
---   
---   Healer songs (Victory March + Minne V + Ballad III/II + Scherzo):
---   //gs c healersong   : Full rotation with dummies (party buffs)
---   //gs c healerrefresh: Refresh healer songs only
---   
---   Pianissimo (single target):
---   //gs c meleepiano  : Full melee rotation with Pianissimo (single target)
---   //gs c tankpiano   : Full tank rotation with Pianissimo (single target)
---   //gs c healerpiano : Full healer rotation with Pianissimo (single target)
---   
---   Utility:
---   //gs c dummy      : Cast dummy songs (4 songs, or 5 with Clarion Call)
---   //gs c dummy1     : Cast dummy1 song (Gold Capriccio) with smart targeting
---   //gs c dummy2     : Cast dummy2 song (Goblin Gavotte) with smart targeting
---   
---   Legacy/Other:
---   //gs c refresh    : Same as meleerefresh
---   //gs c allsongs   : Same as meleesong
---   //gs c threnody   : Cast threnody of current element
---   //gs c carol      : Cast carol of current element
---   //gs c etude      : Cast etude of current type
---   //gs c elegy      : Cast Carnage Elegy (auto-refines to Battlefield)
---   //gs c lullaby    : Cast Horde Lullaby II (auto-refines)
---   //gs c requiem    : Cast Foe Requiem VII (auto-refines to VI)
---   //gs c nt         : Nightingale + Troubadour combo
---============================================================================

---============================================================================
--- CORE INITIALIZATION
---============================================================================
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    
    -- Macro and lockstyle management is now handled by the centralized MACRO_LOCKSTYLE_MANAGER.lua system
    -- No need for job-specific macro code here
    
    -- Initialize Keybind UI automatically (toggle with //gs c kb)
    local KeybindUI = require('ui/KEYBIND_UI')
    KeybindUI.init()
    
    include('core/GLOBALS.lua')
    include('features/DUALBOX.lua')          -- Dual-boxing utilities for alt job detection
    include('monitoring/SIMPLE_JOB_MONITOR.lua') -- Kaories job monitoring
    include('macros/MACRO_MANAGER.lua')    -- Centralized macro book management
    include('modules/AUTOMOVE.lua')
    include('modules/SHARED.lua')
    include('jobs/brd/BRD_CONFIG.lua')
    include('jobs/brd/BRD_SET.lua')
    include('jobs/brd/BRD_FUNCTION.lua')
    include('equipment/EQUIPMENT.lua')
end

function init_gear_sets()
end

function user_setup()
    -- Clear any existing binds first
    send_command('unbind F1')
    send_command('unbind F2') 
    send_command('unbind F3')
    send_command('unbind F4')
    send_command('unbind F5')
    send_command('unbind F6')
    send_command('unbind F7')
    send_command('unbind F9')
    
    -- Use coroutine.schedule to ensure all dependencies are loaded before binding
    coroutine.schedule(function()
        send_command('bind F1 gs c cycle BRDRotation')
        send_command('bind F2 gs c cycle VictoryMarchReplace')
        send_command('bind F3 gs c cycle EtudeType')
        send_command('bind F4 gs c cycle CarolElement')
        send_command('bind F5 gs c cycle ThrenodyElement')
        send_command('bind F6 gs c cycle MainWeapon')
        send_command('bind F7 gs c cycle SubWeapon')
        send_command('bind F9 gs c cycle HybridMode')
    end, 1.0)
    
    -- Setup macro book and lockstyle
    select_default_macro_book()
end

---============================================================================
--- JOB SETUP
---============================================================================

function job_setup()
    state.HybridMode:options('PDT', 'Normal', 'MDT')
    state.OffenseMode:options('Normal', 'Acc')
    state.CastingMode:options('Normal', 'Resistant')
    
    -- BRD-specific states (internal use only, no display)
    state.SongMode = M { ['description'] = 'Song Mode', 'Party', 'Dummy' }
    state.SongMode.silent = true  -- Prevent automatic state change messages
    state.EtudeType = M { ['description'] = 'Etude Type', 
        'STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR' }
    state.CarolElement = M { ['description'] = 'Carol Element', 
        'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark' }
    state.ThrenodyElement = M { ['description'] = 'Threnody Element', 
        'Fire', 'Ice', 'Wind', 'Earth', 'Lightning', 'Water', 'Light', 'Dark' }
    
    -- Create completely new state with unique name
    state.BRDRotation = M { ['description'] = 'BRD Rotation', 'Madrigal', 'Minne', 'Etude', 'Carol', 'Dirge', 'Scherzo' }
    
    -- New state for Victory March replacement when Haste is active
    state.VictoryMarchReplace = M { ['description'] = 'Victory March Replacement', 'Madrigal', 'Minne', 'Scherzo' }
    
    -- Custom display function
    state.BRDRotation.display = function(self)
        local descriptions = {
            Madrigal = 'Madrigal (Honor+Min5+4+Victory+Madrigal)', 
            Minne = 'Minne (Honor+Min5+4+Victory+Minne)',
            Etude = 'Etude (Honor+Min5+4+Victory+Etude)',
            Carol = 'Carol (Honor+Min5+4+Victory+Carol)',
            Dirge = 'Dirge (Honor+Min5+4+Victory+Dirge)',
            Scherzo = 'Scherzo (Honor+Min5+4+Victory+Scherzo)'
        }
        return descriptions[self.value] or self.value
    end
    
    -- Custom display function for Victory March replacement
    state.VictoryMarchReplace.display = function(self)
        local descriptions = {
            Madrigal = 'Blade Madrigal (When Haste active)',
            Minne = 'Knight\'s Minne V (When Haste active)',
            Scherzo = 'Sentinel\'s Scherzo (When Haste active)'
        }
        return descriptions[self.value] or self.value
    end
    
    -- Weapon management states (required by Mote-Include)
    state.WeaponSet = M { ['description'] = 'Main Weapon', 'Naegling', 'Carnwenhan', 'Tauret' }
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Genmei Shield', 'Demers. Degen +1' }
    
    -- Main weapon state for F4 cycling (Naegling vs Twashtar)
    state.MainWeapon = M { ['description'] = 'Main Weapon', 'Naegling', 'Twashtar' }
    
    for i = 1, 12 do
        send_command('unbind F' .. i)
    end
end

---============================================================================
--- COMMAND HANDLERS
---============================================================================

function job_self_command(cmdParams, eventArgs)
    local command = cmdParams[1] and cmdParams[1]:lower() or ''
    -- MessageUtils now available globally via shared.lua
    
    -- First, try universal commands (equiptest, validate_all, etc.)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if success_UniversalCommands and UniversalCommands then
        if UniversalCommands.handle_command(cmdParams, eventArgs) then
            return
        end
    end
    
    -- MacroCommands now available globally via shared.lua
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'BRD') then
        return
    end

    -- Handle Kaories dual-box commands (debuff, bufftank, etc.)
    if handle_kaories_command and cmdParams[1] then
        local command = cmdParams[1]:lower()
        if handle_kaories_command(command) then
            eventArgs.handled = true
            return
        end
    end
    
    if command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'etudetype' then
        state.EtudeType:cycle()
        MessageUtils.brd_message("Setting", "Etude Type", state.EtudeType.value)
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'carolelement' then
        state.CarolElement:cycle()
        MessageUtils.brd_message("Setting", "Carol Element", state.CarolElement.value)
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'threnodyelement' then
        state.ThrenodyElement:cycle()
        MessageUtils.brd_message("Setting", "Threnody Element", state.ThrenodyElement.value)
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'brdrotation' then
        state.BRDRotation:cycle()
        local current_value = state.BRDRotation.value
        local descriptions = {
            Madrigal = 'Madrigal Pack (Honor+Min5+4+Victory+Madrigal)',
            Minne = 'Minne Pack (Honor+Min5+4+Victory+Minne)',
            Etude = 'Etude Pack (Honor+Min5+4+Victory+Etude)',
            Carol = 'Carol Pack (Honor+Min5+4+Victory+Carol)',
            Dirge = 'Dirge Pack (Honor+Min5+4+Victory+Dirge)',
            Scherzo = 'Scherzo Pack (Honor+Min5+4+Victory+Scherzo)'
        }
        local display_name = descriptions[current_value] or current_value
        MessageUtils.brd_message("Setting", "Song Pack", current_value)
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'mainweapon' then
        state.MainWeapon:cycle()
        MessageUtils.brd_message("Weapon", "Main Weapon", state.MainWeapon.value)
        -- Force weapon equip immediately
        -- WeaponUtils now available globally via shared.lua
        WeaponUtils.check_weaponset('main')
        WeaponUtils.check_weaponset('sub')
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'subweapon' then
        state.SubSet:cycle()
        MessageUtils.brd_message("Weapon", "Sub Weapon", state.SubSet.value)
        -- Force equip correct sub weapon immediately
        if state.SubSet.value == 'Genmei Shield' and sets.Shield then
            equip(sets.Shield)
        elseif state.SubSet.value == 'Demers. Degen +1' and sets.DualWield then
            equip(sets.DualWield)
        end
        eventArgs.handled = true
        return
    elseif command == 'cycle' and cmdParams[2] and cmdParams[2]:lower() == 'victorymarchreplace' then
        state.VictoryMarchReplace:cycle()
        local current_value = state.VictoryMarchReplace.value
        local descriptions = {
            Madrigal = 'Blade Madrigal (on Haste)',
            Minne = 'Knight\'s Minne V (on Haste)',
            Scherzo = 'Sentinel\'s Scherzo (on Haste)'
        }
        local display_name = descriptions[current_value] or current_value
        MessageUtils.brd_message("Setting", "Victory March Mode", current_value)
        eventArgs.handled = true
        return
    end
    
    if command == 'lullaby' then
        send_command('input /ma "Horde Lullaby" <stnpc>')
        eventArgs.handled = true
        return
    elseif command == 'lullaby2' or command == 'foe' then
        send_command('input /ma "Foe Lullaby II" <stnpc>')
        eventArgs.handled = true
        return
    elseif command == 'elegy' then
        send_command('input /ma "Carnage Elegy" <stnpc>')
        eventArgs.handled = true
        return
    elseif command == 'requiem' then
        send_command('input /ma "Foe Requiem VII" <stnpc>')
        eventArgs.handled = true
        return
    elseif command == 'threnody' then
        cast_threnody_element()
        eventArgs.handled = true
        return
    elseif command == 'carol' then
        cast_carol_element()
        eventArgs.handled = true
        return
    elseif command == 'etude' then
        cast_etude_type()
        eventArgs.handled = true
        return
    elseif command == 'nt' or command == 'combo' then
        cast_nightingale_troubadour()
        eventArgs.handled = true
        return
    -- Melee commands (party buffs)
    elseif command == 'meleesong' or command == 'melee' then
        cast_melee_songs()
        eventArgs.handled = true
        return
    elseif command == 'meleerefresh' then
        refresh_melee_songs()
        eventArgs.handled = true
        return
    -- Tank commands (single target with pianissimo)
    elseif command == 'tanksong' or command == 'tank' then
        cast_tank_songs()
        eventArgs.handled = true
        return
    elseif command == 'tankrefresh' then
        refresh_tank_songs()
        eventArgs.handled = true
        return
    -- Healer commands (single target with pianissimo)
    elseif command == 'healersong' or command == 'healer' then
        cast_healer_songs()
        eventArgs.handled = true
        return
    elseif command == 'healerrefresh' then
        refresh_healer_songs()
        eventArgs.handled = true
        return
    -- Legacy commands for compatibility
    elseif command == 'refresh' then
        refresh_melee_songs()
        eventArgs.handled = true
        return
    elseif command == 'allsongs' then
        cast_melee_songs()
        eventArgs.handled = true
        return
    -- Dummy songs command
    elseif command == 'dummy' or command == 'dummysongs' then
        cast_dummy_songs()
        eventArgs.handled = true
        return
    -- Individual dummy songs commands
    elseif command == 'dummy1' then
        cast_dummy1_song()
        eventArgs.handled = true
        return
    elseif command == 'dummy2' then
        cast_dummy2_song()
        eventArgs.handled = true
        return
    -- Individual song slot commands
    elseif command == 'song1' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song(1)
        end
        eventArgs.handled = true
        return
    elseif command == 'song2' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song(2)
        end
        eventArgs.handled = true
        return
    elseif command == 'song3' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song(3)
        end
        eventArgs.handled = true
        return
    elseif command == 'song4' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song(4)
        end
        eventArgs.handled = true
        return
    elseif command == 'song5' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song(5)
        end
        eventArgs.handled = true
        return
    -- Internal commands for song3/4 after dummies
    elseif command == 'song3_real' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song_real(3)
        end
        eventArgs.handled = true
        return
    elseif command == 'song4_real' then
        local success_BRDSongCaster, BRDSongCaster = pcall(require, 'jobs/brd/modules/BRD_SONG_CASTER')
        if success_BRDSongCaster then
            BRDSongCaster.cast_single_song_real(4)
        end
        eventArgs.handled = true
        return
    -- Debug command to check target's songs
    elseif command == 'checksongs' or command == 'targetsongs' then
        local success_BRDSongCounter, BRDSongCounter = pcall(require, 'jobs/brd/modules/BRD_SONG_COUNTER')
        if success_BRDSongCounter then
            local count, name = BRDSongCounter.get_target_song_count()
            windower.add_to_chat(220, '[BRD] Target: ' .. name .. ' - Songs: ' .. count)
            
            -- Detailed debug info
            local debug_info = BRDSongCounter.debug_party_info()
        end
            
    elseif command == 'testbuffs' then
        local success_BRDSongCounter, BRDSongCounter = pcall(require, 'jobs/brd/modules/BRD_SONG_COUNTER')
        if success_BRDSongCounter then
            -- Stop any packet monitoring
            BRDSongCounter.stop_buff_monitoring()
            windower.add_to_chat(167, '[DEBUG] Packet monitoring stopped to prevent lag')
        end
        eventArgs.handled = true
        return
    -- Pianissimo commands for single target
    elseif command == 'meleepiano' or command == 'meleeP' then
        cast_melee_pianissimo()
        eventArgs.handled = true
        return
    elseif command == 'tankpiano' or command == 'tankp' then
        cast_tank_pianissimo()
        eventArgs.handled = true
        return
    elseif command == 'healerpiano' or command == 'healerp' then
        cast_healer_pianissimo()
        eventArgs.handled = true
        return
    -- Debug commands for packet analysis
    elseif command == 'toggle_packet_debug' or command == 'packetdebug' then
        toggle_packet_debug()
        eventArgs.handled = true
        return
    elseif command == 'show_packet_song_status' or command == 'packetstatus' then
        show_packet_song_status()
        eventArgs.handled = true
        return
    elseif command == 'debug_all_packets' or command == 'debugpackets' then
        debug_all_packets()
        eventArgs.handled = true
        return
    elseif command == 'songstatus' or command == 'songs' then
        get_current_song_status()
        eventArgs.handled = true
        return
    elseif command == 'canrefresh' then
        local fifth_song_family = cmdParams[2] or 'MINNE' -- Default à MINNE
        can_refresh_fifth_song(fifth_song_family:upper())
        eventArgs.handled = true
        return
    elseif command == 'debugbuffs' or command == 'showbuffs' then
        debug_active_buffs()
        eventArgs.handled = true
        return
    elseif command == 'abilities' or command == 'ja' then
        local success_BRDAbilities, BRDAbilities = pcall(require, 'jobs/brd/brd_abilities')
        if not success_BRDAbilities then
            error("Failed to load jobs/brd/brd_abilities: " .. tostring(BRDAbilities))
        end
        BRDAbilities.display_abilities_status()
        eventArgs.handled = true
        return
    end
end

---============================================================================
--- STATE CHANGE HANDLING
---============================================================================

-- DISABLED: job_state_change was causing stack overflow
-- UI updates are now manual only via //gs c forceupdate

---============================================================================
--- MACRO MANAGEMENT
---============================================================================
-- Macro management is now handled in get_sets() for better reliability
-- especially after //lua unload/load gearswap

---============================================================================
--- EQUIPMENT HANDLING
---============================================================================

function job_handle_equipping_gear(playerStatus, eventArgs)
    -- CRITICAL: Protect Honor March casting - maintain Marsyas
    if _G.casting_honor_march then
        -- Force Marsyas to stay equipped during Honor March cast
        equip({ range = "Marsyas" })
    end
    
    -- WeaponUtils now available globally via shared.lua
    WeaponUtils.check_weaponset('main')
    WeaponUtils.check_weaponset('sub')
end

---============================================================================
--- STATUS CHANGES
---============================================================================

function job_status_change(new_status, old_status)
    if handle_brd_status_change then
        handle_brd_status_change(new_status, old_status)
    end
end


---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT  
---============================================================================

--- Configure macro book using the centralized macro manager
--- @usage Called automatically during user_setup
function select_default_macro_book()
    -- Load macro manager safely
    -- MacroManager now available globally via shared.lua
    -- Check if module is loaded, fallback to direct require if needed
    local macro_manager = MacroManager
    if not macro_manager then
        local success, result = pcall(require, 'macros/macro_manager')
        if success then
            macro_manager = result
        else
            windower.add_to_chat(167, '[BRD] MacroManager module not available')
            return
        end
    end
    
    -- Unload dressup first
    send_command('lua unload dressup')
    
    -- Use centralized system with message display
    macro_manager.setup_job_macro_lockstyle('BRD', player.sub_job, true) -- true = show message
    
    -- Reload dressup after delay
    send_command('wait 20; lua load dressup')
end

---============================================================================
--- CLEANUP
---============================================================================

function file_unload()
    -- CRITICAL: Stop all pending macro/lockstyle operations to prevent conflicts
    if stop_all_macro_lockstyle_operations then
        stop_all_macro_lockstyle_operations()
    end
    
    send_command('unbind F1')
    send_command('unbind F2')
    send_command('unbind F3')
    send_command('unbind F4')
    send_command('unbind F5')
    send_command('unbind F6')
    send_command('unbind F7')
    send_command('unbind F9')
end