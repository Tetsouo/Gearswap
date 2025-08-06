---============================================================================
--- FFXI GearSwap Configuration - Thief (THF)
---============================================================================
--- Professional GearSwap configuration for Thief job in FFXI.
--- Provides advanced automation for gear swapping, Treasure Hunter optimization,
--- stealth ability management, and dual-boxing functionality.
---
--- @file Tetsouo_THF.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10
--- @date Modified: 2025-08-05
--- @requires Mote-Include v2.0+
--- @requires Mote-TreasureHunter.lua
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- Dependencies:
---   - modules/automove.lua        : Automatic movement detection and gear swapping
---   - modules/shared.lua          : Shared utility functions across jobs
---   - jobs/thf/THF_SET.lua       : THF-specific equipment sets
---   - jobs/thf/THF_FUNCTION.lua  : THF-specific advanced functions
---   - Mote-TreasureHunter.lua    : Treasure Hunter automation framework
---
--- Features:
---   - Intelligent Treasure Hunter gear management with multiple modes
---   - Sneak Attack and Trick Attack buff tracking and optimization
---   - Abyssea proc mode for weakening procedures
---   - Dynamic weapon set switching for different combat scenarios
---   - Ranged attack treasure hunter support (RATH)
---   - Aeolian Edge treasure hunter optimization
---   - Sub-job specific macro book and lockstyle management
---   - Dual-boxing support for mage coordination
---   - TP-based weapon skill gear selection
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load Tetsouo_THF
---   Unload with: //gs unload
---
--- Treasure Hunter Modes:
---   - None: No TH gear swapping
---   - Tag: TH gear on mob tagging only
---   - SATA: TH gear on Sneak/Trick Attack usage
---   - Fulltime: TH gear maintained constantly
---
--- Console Commands:
---   //gs c cycle TreasureMode : Toggle treasure hunter mode
---   //gs c cycle HybridMode  : Toggle defense mode (PDT/Normal/MDT)
---   //gs c cycle OffenseMode : Toggle accuracy mode (Normal/Acc)
---   //gs c cycle AbysseaProc : Toggle Abyssea proc mode
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary THF-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. THF equipment sets
---   5. THF advanced functions
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2             -- Specifies the version of the Mote library to use
    include('Mote-Include.lua')          -- Mote library for GearSwap
    include('modules/automove.lua')      -- Module for movement speed gear management
    include('modules/shared.lua') -- Shared functions across jobs
    include('jobs/thf/THF_SET.lua')           -- Thief specific gear sets
    include('jobs/thf/THF_FUNCTION.lua')     -- Advanced functions specific to Thief
end

--- Initialize gear sets for Thief.
--- This function is intentionally minimal as gear sets are externally defined
--- in the THF_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/thf/THF_SET.lua For complete equipment set definitions
function init_gear_sets()
end

--- Configure user-specific settings and preferences.
--- Called after job_setup to handle user customizations and macro setup.
--- Primarily handles macro book selection based on subjob.
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance configuration
function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and Treasure Hunter integration.
--- Initializes all THF-specific mechanics including buff tracking,
--- treasure hunter modes, weapon configurations, and dual-boxing states.
---
--- Key Features Configured:
---   - Treasure Hunter automation via Mote-TreasureHunter.lua
---   - Sneak Attack, Trick Attack, and Feint buff state tracking
---   - Hybrid and offense mode options for different combat scenarios
---   - Abyssea proc mode for endgame content
---   - Dynamic weapon set configurations
---   - Job ability ID mappings for TH automation
---   - Dual-boxing mage coordination states
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see Mote-TreasureHunter.lua For TH automation framework
function job_setup()
    include('Mote-TreasureHunter.lua') -- Includes the file for handling Treasure Hunter.
    -- Initializes the treasureHunter state variable from TreasureMode and sets default treasure mode
    treasureHunter = state.TreasureMode.value
    state.TreasureMode:set('tag')
    -- Sets up state variables for buffs
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    -- Configures hybrid and offense mode options
    state.HybridMode:options('PDT', 'Normal', 'MDT')
    state.OffenseMode:options('Normal', 'Acc')
    -- Define options for AbysseaProc mode
    state.AbysseaProc = M(false, 'Abyssea Proc')
    -- Configures gear sets for main and sub weapons
    state.WeaponSet1 = M { ['description'] = 'Main Weapon', 'Vajra', 'Malevolence', 'Dagger' }
    state.WeaponSet2 = M { ['description'] = 'Main Weapon', 'Dagger', 'Sword', 'Great Sword', 'Polearm', 'Club', 'Staff', 'Scythe' }
    state.SubSet = M { ['description'] = 'Sub Weapon', 'Centovente', 'Tanmogayi', "Dagger2" }
    -- Sets up default job ability IDs for actions that always have Treasure Hunter
    info.default_ja_ids = S { 35, 204 }
    info.default_u_ja_ids = S { 201, 202, 203, 205, 207 }
    -- Defines options for alternative player state
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    state.altPlayerGeo = M('Geo-Fury', 'Geo-Frailty', 'Geo-Malaise', 'Geo-Languor', 'Geo-Slow', 'Geo-Torpor')
    state.altPlayerIndi =
        M('Indi-Frailty', 'Indi-Refresh', 'Indi-Barrier', 'Indi-Fend', 'Indi-Fury', 'Indi-Acumen', 'Indi-Precision',
            'Indi-Haste')
    state.altPlayerEntrust = M('Indi-Haste', 'Indi-Refresh', 'Indi-INT', 'Indi-STR', 'Indi-VIT')
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle post-precast gear adjustments for Treasure Hunter optimization.
--- Applies specialized gear sets based on ability usage and TH mode settings.
--- Critical for maximizing treasure hunter effectiveness on key abilities.
---
--- Special Handling:
---   - Aeolian Edge: Equips TH-optimized nuke gear when TH is active
---   - Sneak/Trick Attack: Equips TH gear based on TreasureMode settings
---   - Range lock validation for distance-dependent abilities
---
--- @param spell table The spell or ability being used
--- @param action table The action being performed  
--- @param spellMap string The type/classification of the spell or ability
--- @param eventArgs table Additional event arguments
--- @usage Automatically called by GearSwap after precast gear selection
--- @see check_range_lock For distance validation
function job_post_precast(spell, action, spellMap, eventArgs)
    -- Equip AeolianTH gear set if 'Aeolian Edge' is being used and Treasure Hunter is active.
    if spell.english == 'Aeolian Edge' and treasureHunter ~= 'None' then
        -- Equip TreasureHunter gear set if 'Sneak Attack' or 'Trick Attack' is being used and Treasure Mode is 'SATA' or 'Fulltime'.
        equip(sets.AeolianTH)
    elseif spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
    check_range_lock()
end

--- Handle pre-casting logic with comprehensive ability management.
--- Performs multiple validation and optimization steps before ability execution:
--- - Spell handling and auto-ability coordination
--- - Cooldown checking and display
--- - Utsusemi shadow management
--- - TP-based weapon skill gear optimization
--- - Buff state tracking and updates
--- - Range validation for distance-dependent abilities
---
--- @param spell table The spell or ability being cast  
--- @param action table The action object containing execution details
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell/ability execution
--- @see handle_spell For comprehensive spell processing
--- @see adjust_Gear_Based_On_TP_For_WeaponSkill For WS optimization
function job_precast(spell, action, spellMap, eventArgs)
    handle_spell(spell, eventArgs, auto_abilities) -- Handles the spell based on its type and the current state.
    checkDisplayCooldown(spell, eventArgs)         -- Checks and displays the cooldown for the spell.
    refine_Utsusemi(spell, eventArgs)              -- Refines the Utsusemi spell if it's being cast.
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell) -- Selects the earrings based on the weapon and TP.
    -- Sets the state for the buff corresponding to the spell being cast to true, if it exists.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
    
    
    Ws_range(spell)
end

--- Handle mid-casting gear adjustments for ranged Treasure Hunter.
--- Applies specialized RATH (Ranged Attack Treasure Hunter) gear when
--- performing ranged attacks while Treasure Hunter mode is active.
---
--- Implementation:
---   Only activates when TreasureMode is not 'None' and action type
---   is 'Ranged Attack', ensuring optimal TH proc chances on ranged hits.
---
--- @param spell table The spell or ability being cast
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap during spell casting
--- @see sets.precast.RATH For ranged TH gear configuration
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- If Treasure Mode is active and a ranged attack is being performed, equip the RATH gear set.
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.precast.RATH)
    end
end

--- Handle post-casting cleanup and buff state management.
--- Manages buff state transitions after ability execution and handles
--- special cases like weapon skill buff consumption.
---
--- Buff State Management:
---   - Updates buff states based on spell interruption status
---   - Automatically resets Sneak Attack, Trick Attack, and Feint
---     states after successful weapon skill usage
---   - Maintains accurate buff tracking for gear optimization
---
--- @param spell table The spell or ability that was executed
--- @param action table The action object that was performed
--- @param spellMap string Mote's spell classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap after spell/ability completion
--- @see handleSpellAftercast For shared aftercast processing
function job_aftercast(spell, action, spellMap, eventArgs)
    -- If a buff corresponding to the spell exists, update its state based on whether the spell was interrupted or the buff is active.
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = not spell.interrupted or buffactive[spell.english]
    end

    -- If a WeaponSkill was successfully used, reset the state of 'Sneak Attack', 'Trick Attack', and 'Feint' buffs.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end

    -- Perform additional actions after the spell is cast.
    handleSpellAftercast(spell, eventArgs)
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Configure macro book and visual appearance for Thief.
--- Automatically selects appropriate macro page based on subjob synergy
--- and applies the configured lockstyle set. Includes safe loading/unloading
--- of the dressup addon to prevent macro conflicts.
---
--- Macro Page Selection:
---   - DNC subjob: Page 1, Book 1 (Evasion and TP management)
---   - WAR subjob: Page 1, Book 2 (Physical damage focus) 
---   - NIN subjob: Page 1, Book 3 (Dual wield and shadows)
---   - Default:    Page 1, Book 1 (General thief abilities)
---   - Lockstyle set 1 applied with timing delay
---
--- Safety Features:
---   - Dressup addon safely unloaded/reloaded to prevent macro loss
---   - Timing delays prevent addon conflicts
---
--- @usage Called automatically during user_setup
--- @see user_setup For initialization context
function select_default_macro_book()
    send_command('lua unload dressup')
    
    -- THF macro pages based on subjob
    local macro_page = ({ DNC = 1, WAR = 2, NIN = 3 })[player.sub_job] or 1
    set_macro_page(1, macro_page)
    
    -- THF lockstyle
    send_command('wait 3; input /lockstyleset 1')
    
    -- Reload dressup with delay to avoid macro loss
    send_command('wait 20; lua load dressup')
end
