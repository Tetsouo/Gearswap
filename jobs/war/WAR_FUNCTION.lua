---============================================================================
--- FFXI GearSwap Job Module - Warrior Advanced Functions
---============================================================================
--- Professional Warrior job-specific functionality providing intelligent
--- weapon skill optimization, retaliation management, TP-based gear selection,
--- and advanced melee combat automation. Core features include:
---
--- • **TP-Based Weapon Skill Optimization** - Dynamic gear selection by TP level
--- • **Automatic Retaliation Management** - Smart cancellation on movement
--- • **Multi-Weapon Set Support** - Seamless switching between weapon configs
--- • **Subjob Integration** - DRG, SAM, DNC specific optimizations
--- • **Range Attack Coordination** - Throwing weapon and archery support
--- • **Hybrid Defense Modes** - PDT/Normal switching for survivability
--- • **Berserk/Aggressor Timing** - JA usage optimization for maximum uptime
--- • **Error Recovery Systems** - Robust handling of weapon swap failures
---
--- This module implements the advanced melee combat algorithms that make WAR
--- automation efficient and intelligent, handling complex weapon skill timing
--- and gear optimization with comprehensive error handling.
---
--- @file jobs/war/WAR_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires core/weapons.lua, utils/logger.lua
--- @requires Windower FFXI, GearSwap addon
---
--- @usage
---   equip_weapons() -- Equip current weapon set with error handling
---   removeRetaliationOnLongMovement() -- Setup movement-based retaliation cancellation
---   get_custom_wsmode(spell, spellMap) -- Get TP-based weapon skill mode
---
--- @see jobs/war/WAR_SET.lua for weapon and weapon skill equipment sets
--- @see Tetsouo_WAR.lua for job configuration and state management
---============================================================================

-----------------------------------------------------------------------------------------------
-- equip_weapons()
--
-- WAR-specific weapon equipping function that leverages the centralized weapon system.
-- WAR weapon sets contain both main and sub weapons (no separate sub sets).
-----------------------------------------------------------------------------------------------
function equip_weapons()
    local WeaponUtils = require('core/weapons')
    local log = require('utils/logger')
    
    -- WAR uses complete weapon sets (main + sub together)
    if state.WeaponSet and sets[state.WeaponSet.value] then
        local start_time = os.clock()
        local success, error_msg = pcall(equip, sets[state.WeaponSet.value])
        local swap_time = (os.clock() - start_time) * 1000 -- en millisecondes
        
        if not success then
            log.error("Failed to equip WAR weapon set '%s': %s", state.WeaponSet.value, error_msg or "unknown error")
        else
            log.debug("WAR weapon set equipped: %s", state.WeaponSet.value)
            
            -- Track equipment swap metrics (only if enabled)
            if _G.metrics_collector and _G.metrics_collector.is_active() then
                _G.metrics_collector.track_equipment_swap(state.WeaponSet.value, swap_time)
            end
        end
    end
    
    -- Equip ammo set if available
    if state.ammoSet and sets[state.ammoSet.value] then
        local start_time = os.clock()
        local success, error_msg = pcall(equip, sets[state.ammoSet.value])
        local swap_time = (os.clock() - start_time) * 1000 -- en millisecondes
        
        if not success then
            log.error("Failed to equip WAR ammo set '%s': %s", state.ammoSet.value, error_msg or "unknown error")
        else
            log.debug("WAR ammo set equipped: %s", state.ammoSet.value)
            
            -- Track equipment swap metrics (only if enabled)
            if _G.metrics_collector and _G.metrics_collector.is_active() then
                _G.metrics_collector.track_equipment_swap('ammo_' .. state.ammoSet.value, swap_time)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------
-- buffSelf(param)
--
-- Buffs the player with key WAR job abilities automatically.
-- Takes into account recast timers, current active buffs, and optionally excludes conflicting
-- abilities (e.g., Berserk vs. Defender).
--
-- param (string, optional):
--     If 'Berserk' is passed, 'Defender' will be excluded. If 'Defender' is passed,
--     'Berserk' will be excluded. Any other value has no exclusion effect.
-----------------------------------------------------------------------------------------------
function buffSelf(param)
    local log = require('utils/logger')
    log.debug("WAR buffSelf called with param: %s", param or "none")
    
    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive
    local delay = 0
    local firstUsed = false

    -- Ability definitions: name, recast ID, and buff name
    local abilities = {
        { name = 'Berserk',     id = 1, buff = 'Berserk' },
        { name = 'Defender',    id = 3, buff = 'Defender' },
        { name = 'Aggressor',   id = 4, buff = 'Aggressor' },
        { name = 'Retaliation', id = 8, buff = 'Retaliation' },
        { name = 'Restraint',   id = 9, buff = 'Restraint' },
    }

    -- Conditional Warcry / Blood Rage logic
    if not buffs['Warcry'] then
        if (recasts[2] or 0) == 0 then
            table.insert(abilities, { name = 'Warcry', id = 2, buff = 'Warcry' })
        elseif (recasts[11] or 0) == 0 then
            table.insert(abilities, { name = 'Blood Rage', id = 11, buff = 'Warcry' })
        end
    end

    -- Handle mutually exclusive abilities
    local exclude = {}
    if param == 'Berserk' then
        exclude['Defender'] = true
    elseif param == 'Defender' then
        exclude['Berserk'] = true
    end

    -- Cast abilities sequentially with incremental delays
    for _, ability in ipairs(abilities) do
        local isReady = (recasts[ability.id] or 0) == 0
        local isActive = buffs[ability.buff]
        local isExcluded = exclude[ability.name]

        if isReady and not isActive and not isExcluded then
            local command = 'input /ja "' .. ability.name .. '" <me>'
            if not firstUsed then
                log.debug("WAR buffSelf: Using %s immediately", ability.name)
                send_command(command)
                firstUsed = true
                delay = delay + 1
            else
                log.debug("WAR buffSelf: Queuing %s with %ds delay", ability.name, delay)
                send_command('wait ' .. delay .. '; ' .. command)
                delay = delay + 2
            end
        end
    end
end

-----------------------------------------------------------------------------------------------
-- ThirdEye()
--
-- Activates Samurai subjob abilities: Seigan, Hasso, and Third Eye.
-- Automatically chooses between Seigan and Hasso depending on the active 'Defender' buff,
-- and attempts to use Third Eye afterwards if available.
--
-- Requirements:
--     - Player must have Samurai as sub-job
--     - Buff and recast data are pulled from Windower API
--     - If 'Third Eye' is on cooldown, displays a formatted cooldown message
-----------------------------------------------------------------------------------------------
function ThirdEye()
    -- Abort if SAM is not sub-job
    if player.sub_job ~= 'SAM' then return end

    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive

    -- Define ability data
    local abilities = {
        Seigan = {
            id     = 139,
            active = buffs['Seigan'],
            recast = recasts[139] or 0,
        },
        Hasso = {
            id     = 138,
            active = buffs['Hasso'],
            recast = recasts[138] or 0,
        },
        ThirdEye = {
            id     = 133,
            active = buffs['Third Eye'],
            recast = recasts[133] or 0,
        },
    }

    local thirdEye = abilities.ThirdEye
    local usingDefender = buffs['Defender'] ~= nil
    local preferredName = usingDefender and 'Seigan' or 'Hasso'
    local preferred = abilities[preferredName]

    -- Helper: show cooldown info in chat
    local function displayCooldownMessage(name, cooldown)
        local msg = createFormattedMessage(nil, name, cooldown, nil, true)
        add_to_chat(123, msg)
    end

    -- Attempt to activate the preferred JA, followed by Third Eye
    if not preferred.active and preferred.recast == 0 then
        send_command('input /ja "' .. preferredName .. '" <me>')
        if not thirdEye.active and thirdEye.recast == 0 then
            send_command('wait 1; input /ja "Third Eye" <me>')
        elseif thirdEye.recast > 0 then
            displayCooldownMessage('Third Eye', thirdEye.recast)
        end
    else
        -- If preferred ability is unavailable, attempt Third Eye directly
        if not thirdEye.active and thirdEye.recast == 0 then
            send_command('input /ja "Third Eye" <me>')
        elseif thirdEye.recast > 0 then
            displayCooldownMessage('Third Eye', thirdEye.recast)
        end
    end
end

-----------------------------------------------------------------------------------------------
-- jump()
--
-- Uses 'Jump' and/or 'High Jump' abilities to build TP efficiently based on current TP level.
-- Automatically selects the appropriate jump based on cooldowns and remaining TP needed.
--
-- Logic:
--     - If TP ≥ 1000, nothing is used (message shown).
--     - If TP < 500 and both jumps are ready → uses both (with delay).
--     - If only one is ready → uses that one.
--     - If none are ready → shows recast times.
-----------------------------------------------------------------------------------------------
function jump()
    -- Define ability names and IDs
    local jumpName = 'Jump'
    local highJumpName = 'High Jump'
    local jumpId = 158
    local highJumpId = 159

    -- Get recast timers for Jump abilities
    local recasts = windower.ffxi.get_ability_recasts()
    local jumpRecast = recasts[jumpId] or 0
    local highJumpRecast = recasts[highJumpId] or 0

    -- Check current TP
    local tp = player.tp
    if tp >= 1000 then
        add_to_chat(057, 'You have enough TP!')
        return
    end

    local jumpReady = jumpRecast == 0
    local highJumpReady = highJumpRecast == 0

    -- Use both Jumps if TP is very low
    if jumpReady and highJumpReady then
        if tp < 500 then
            send_command('input /ja "' .. jumpName .. '" <t>; wait 1; input /ja "' .. highJumpName .. '" <t>')
        else
            send_command('input /ja "' .. jumpName .. '" <t>')
        end

        -- Use one if only one is available
    elseif jumpReady then
        send_command('input /ja "' .. jumpName .. '" <t>')
    elseif highJumpReady then
        send_command('input /ja "' .. highJumpName .. '" <t>')

        -- Show cooldowns if neither are available
    else
        add_to_chat(057, createFormattedMessage(nil, jumpName, jumpRecast, nil))
        add_to_chat(057, createFormattedMessage(nil, highJumpName, highJumpRecast, nil))
    end
end

-----------------------------------------------------------------------------------------------
-- customize_idle_set(idleSet)
--
-- Determines which idle gear set to use based on current zone and HybridMode state.
-- This allows automatic switching between city, PDT, and default idle sets.
--
-- Logic:
--     - If in a city area (excluding Dynamis), use the Town idle set.
--     - If HybridMode is 'PDT', use the Physical Damage Taken set.
--     - Otherwise, fallback to the default idle set.
--
-- Parameters:
--     idleSet (table): The base idle set passed in by GearSwap framework.
--
-- Returns:
--     table: The modified idle set to be used.
-----------------------------------------------------------------------------------------------
function customize_idle_set(idleSet)
    -- Use the new modular system for consistency with PLD/RUN
    local EquipmentUtils = require('core/equipment')
    
    -- Special case: City idle (WAR-specific logic preserved)
    if areas.Cities:contains(world.area) and not world.area:contains('Dynamis') then
        return sets.idle.Town
    end
    
    -- Use standard modular approach for PDT/normal idle
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(
        nil,             -- sets.idleXp (not used for WAR)
        sets.idle.PDT,   -- PDT set
        nil,             -- Acc PDT (not used for WAR)
        nil              -- MDT (not used for WAR)
    )
    
    return EquipmentUtils.customize_set(idleSet, conditions, setTable)
end

-----------------------------------------------------------------------------------------------
-- customize_melee_set(meleeSet)
--
-- Determines the melee gear set to use based on HybridMode, weapon, and buff status.
-- Uses the modular equipment system for consistency.
--
-- Parameters:
--     meleeSet (table): The current engaged/melee set passed by GearSwap.
--
-- Returns:
--     table: The adjusted melee set based on player state and gear.
-----------------------------------------------------------------------------------------------
function customize_melee_set(meleeSet)
    local hybrid_mode = state.HybridMode.value
    local current_weapon = player.equipment.main
    local has_am3 = buffactive["Aftermath: Lv.3"]
    
    -- Priority logic: Ukonvasara + AM3 ALWAYS uses PDTAFM3 regardless of mode
    if current_weapon == 'Ukonvasara' and has_am3 then
        return sets.engaged.PDTAFM3
    end
    
    -- Standard mode-based selection for other weapons
    if hybrid_mode == 'PDT' then
        return sets.engaged.PDTTP  -- Balanced PDT+TP set
    else
        return sets.engaged.Normal  -- TP-focused set
    end
end

-----------------------------------------------------------------------------------------------
-- ws_info
--
-- Defines passive TP bonuses for Weapon Skills, typically from always-equipped gear.
-- Example: Boii Cuisses +3 provide a constant +100 TP bonus for specific WS.
--
-- Notes:
--     - Weapon-based TP bonuses (e.g., Chango) are handled elsewhere, not here.
--     - This table only covers static gear bonuses tied to WS usage.
-----------------------------------------------------------------------------------------------
local ws_info = {
    ["Upheaval"]       = { tp_bonus_gear_always = 100 },
    ["Ukko's Fury"]    = { tp_bonus_gear_always = 100 },
    ["King's Justice"] = { tp_bonus_gear_always = 100 },
    ["Armor Break"]    = { tp_bonus_gear_always = 100 },
    ["Fell Cleave"]    = { tp_bonus_gear_always = 100 },
    ["Impulse Drive"]  = { tp_bonus_gear_always = 100 },
    ["Stardiver"]  = { tp_bonus_gear_always = 100 },
    ["Savage Blade"]   = { tp_bonus_gear_always = 100 },
    ["Judgment"]       = { tp_bonus_gear_always = 0 },
    -- Add additional Weapon Skills as needed
}

-- get_tp_threshold() function removed - now uses WeaponUtils.get_tp_threshold()

-----------------------------------------------------------------------------------------------
-- get_custom_wsmode(spell, spellMap, default_wsmode)
--
-- Determines the appropriate Weapon Skill gear mode based on current TP and bonus conditions.
-- Uses the centralized WeaponUtils module for consistent TP calculations across jobs.
--
-- Parameters:
--     spell           (table): The Weapon Skill spell data (from GearSwap).
--     spellMap        (string): Not used in this context.
--     default_wsmode  (string): Default WS mode (not modified here).
--
-- Returns:
--     string or nil: 'TPBonus' if Moonshade improves scaling, otherwise nil.
-----------------------------------------------------------------------------------------------
function get_custom_wsmode(spell, spellMap, default_wsmode)
    -- ═══════════════════════════════════════════════════════════════════════════
    -- INTELLIGENT TP BONUS WEAPON SKILL MODE SELECTION
    -- ═══════════════════════════════════════════════════════════════════════════
    -- This function determines if Moonshade Earring should be equipped based on:
    -- 1. Current TP level (if < 1000+gear_bonus, Moonshade helps)
    -- 2. Weapon-specific TP bonuses (Chango +100, etc.)
    -- 3. Gear-specific TP bonuses (Boii Cuisses +3, etc.)
    
    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 1: Load centralized weapon utility system
    -- This ensures consistent TP calculations across all jobs
    -- ───────────────────────────────────────────────────────────────────────
    local WeaponUtils = require('core/weapons')
    
    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 2: Get weapon-specific TP bonus
    -- Examples: Chango (+100 TP), Ukonvasara (varies), Dolichenus (+100 TP)
    -- ───────────────────────────────────────────────────────────────────────
    local weapon_tp_bonus = WeaponUtils.get_weapon_tp_bonus(player.equipment.main)
    
    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 3: Get weapon skill specific gear TP bonus
    -- Examples: Boii Cuisses +3 (+100 TP for many WAR weapon skills)
    -- ───────────────────────────────────────────────────────────────────────
    local ws = ws_info[spell.english]
    
    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 4: Calculate if Moonshade Earring improves damage
    -- Returns 'TPBonus' mode if current TP + bonuses < optimal threshold
    -- This triggers the specialized TPBonus weapon skill set
    -- ───────────────────────────────────────────────────────────────────────
    return WeaponUtils.get_tp_bonus_mode(spell, ws, weapon_tp_bonus)
end

-----------------------------------------------------------------------------------------------
-- job_self_command(cmdParams, eventArgs, spell)
--
-- Handles custom self-issued commands for the current job.
-- Dispatches to predefined commands (via commandFunctions), or handles job-specific logic
-- including subjob-specific behavior (e.g., Scholar support commands).
--
-- Logic:
--     - Updates the alternate state tracking object (altState)
--     - Runs commandFunctions[command] if it exists
--     - Falls back to job-specific logic (handle_war_commands)
--     - Adds support for SCH subjob-specific commands if needed
--
-- Parameters:
--     cmdParams (table): Command parameters. First value is the command name.
--     eventArgs (table): Optional GearSwap event arguments (can be modified).
--     spell     (table): The currently cast spell, if any.
-----------------------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs, spell)
    -- Update custom alternate state object
    update_altState()

    local command = cmdParams[1]:lower()

    -- Debug output
    
    -- Try universal commands first (test, modules, cache, metrics, help)
    local UniversalCommands = require('core/universal_commands')
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end
    

    
    -- Module loader commands
    if command == 'modules' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'
        
        if subcommand == 'stats' then
            local Colors = require('utils/colors')
            
            Colors.show_header("STATISTIQUES MODULES")
            
            local success, ModuleLoader = pcall(require, 'utils/module_loader')
            if success then
                local stats = ModuleLoader.get_statistics()
                
                Colors.show_empty_line()
                
                -- Section Cache & Performance
                local cache_stats = {
                    ["Modules charges"] = stats.cached_modules or 0,
                    ["Memoire utilisee"] = string.format("%.2f KB", stats.total_memory_kb or 0),
                    ["Taux de reussite"] = {
                        value = string.format("%.1f%%", stats.hit_rate or 0),
                        color = Colors.get_performance_color(stats.hit_rate or 0)
                    },
                    ["Temps moyen"] = {
                        value = string.format("%.2f ms", stats.avg_load_time_ms or 0),
                        color = Colors.get_time_color(stats.avg_load_time_ms or 0)
                    }
                }
                Colors.show_stats_section("CACHE & PERFORMANCE", cache_stats)
                
                Colors.show_empty_line()
                
                -- Section Accès & Utilisation
                local access_stats = {
                    ["Total acces"] = (stats.cache_hits or 0) + (stats.cache_misses or 0),
                    ["Cache hits"] = stats.cache_hits or 0,
                    ["Cache misses"] = stats.cache_misses or 0
                }
                Colors.show_stats_section("ACCES & UTILISATION", access_stats)
                
            else
                Colors.show_status('Module loader non disponible', 'error')
            end
            
            Colors.show_footer()
            
        elseif subcommand == 'cleanup' then
            local Colors = require('utils/colors')
            
            Colors.show_header("NETTOYAGE MODULES")
            
            local success, ModuleLoader = pcall(require, 'utils/module_loader')
            if success then
                Colors.show_action("Nettoyage des modules inutilises...")
                ModuleLoader.cleanup_unused_modules()
                Colors.show_status('Nettoyage termine avec succes!', 'success')
            else
                Colors.show_status('Module loader non disponible', 'error')
            end
            
            Colors.show_footer()
        end
        return
    end
    
    -- Cache management commands
    if command == 'cache' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'
        
        if subcommand == 'stats' then
            local Colors = require('utils/colors')
            
            Colors.show_header("STATISTIQUES CACHE")
            
            local success, EquipmentCache = pcall(require, 'core/equipment_cache')
            if success then
                local stats = EquipmentCache.get_statistics()
                
                Colors.show_empty_line()
                
                -- Section Capacité & Utilisation
                local entries = stats.entries or 0
                local max_entries = stats.max_entries or 1
                local usage_percent = math.floor((entries / max_entries) * 100)
                
                local capacity_stats = {
                    ["Entrees"] = {
                        value = string.format("%d/%d (%d%%)", entries, max_entries, usage_percent),
                        color = Colors.get_performance_color(100 - usage_percent)  -- Inversé car plein = mauvais
                    },
                    ["Taux de reussite"] = {
                        value = string.format("%.1f%%", stats.hit_rate or 0),
                        color = Colors.get_performance_color(stats.hit_rate or 0)
                    }
                }
                Colors.show_stats_section("CAPACITE & UTILISATION", capacity_stats)
                
                Colors.show_empty_line()
                
                -- Section Performance & Accès
                local perf_stats = {
                    ["Cache hits"] = stats.hits or 0,
                    ["Cache misses"] = stats.misses or 0,
                    ["Temps moyen"] = {
                        value = string.format("%.2f ms", stats.avg_access_time_ms or 0),
                        color = Colors.get_time_color(stats.avg_access_time_ms or 0)
                    }
                }
                Colors.show_stats_section("PERFORMANCE & ACCES", perf_stats)
                
            else
                Colors.show_status('Cache non disponible', 'error')
            end
            
            Colors.show_footer()
            
        elseif subcommand == 'cleanup' then
            local Colors = require('utils/colors')
            
            Colors.show_header("NETTOYAGE CACHE")
            
            local success, EquipmentCache = pcall(require, 'core/equipment_cache')
            if success then
                Colors.show_action("Nettoyage des entrees anciennes...")
                Colors.show_action("Suppression des entrees obsoletes...")
                EquipmentCache.cleanup()
                Colors.show_status('Nettoyage termine avec succes!', 'success')
            else
                Colors.show_status('Cache non disponible', 'error')
            end
            
            Colors.show_footer()
            
        elseif subcommand == 'clear' then
            local Colors = require('utils/colors')
            
            Colors.show_header("VIDAGE CACHE")
            
            local success, EquipmentCache = pcall(require, 'core/equipment_cache')
            if success then
                Colors.show_status("ATTENTION: Suppression de toutes les entrees...", "warning")
                Colors.show_action("Vidage en cours...")
                EquipmentCache.clear()
                Colors.show_status('Cache completement vide!', 'success')
                Colors.show_action('Redemarrage du cache en cours...')
            else
                Colors.show_status('Cache non disponible', 'error')
            end
            
            Colors.show_footer()
        end
        return
    end
    
    -- Predefined command handler
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)

        -- Fallback: job-specific + subjob-specific logic
    else
        if handle_war_commands then
            handle_war_commands(cmdParams)
        end

        if player.sub_job == 'SCH' then
            if handle_sch_subjob_commands then
                handle_sch_subjob_commands(cmdParams)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------
-- removeRetaliationOnLongMovement()
--
-- Monitors player movement and cancels the 'Retaliation' buff if the player moves continuously
-- (distance > 1.0) for a given duration while not engaged in combat.
-----------------------------------------------------------------------------------------------
function removeRetaliationOnLongMovement()
    local checkInterval = 0.5    -- Time (in seconds) between checks
    local moveDurationNeeded = 5 -- Total duration (in seconds) of movement to trigger cancel
    local timeMoving = 0
    local lastPos = { x = 0, y = 0, z = 0, frameCount = 0 }

    windower.raw_register_event('prerender', function()
        -- Frame-based timing (~60 FPS)
        lastPos.frameCount = lastPos.frameCount + 1
        local framesNeeded = math.floor(checkInterval * 60 + 0.5)
        if lastPos.frameCount < framesNeeded then return end
        lastPos.frameCount = 0

        -- Get current player position
        local pl = windower.ffxi.get_mob_by_index(player.index)
        if not pl or not pl.x then return end

        -- Calculate distance moved since last check
        local dx = pl.x - lastPos.x
        local dy = pl.y - lastPos.y
        local dz = pl.z - lastPos.z
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

        -- Only cancel if moving, not engaged, and Retaliation active
        if dist > 1 and player.status ~= 'Engaged' and buffactive['Retaliation'] then
            timeMoving = timeMoving + checkInterval
            if timeMoving >= moveDurationNeeded then
                send_command('cancel Retaliation')
            end
        else
            timeMoving = 0
        end

        -- Save current position
        lastPos.x = pl.x
        lastPos.y = pl.y
        lastPos.z = pl.z
    end)
end
