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
    local success_WeaponUtils, WeaponUtils = pcall(require, 'equipment/WEAPONS')
    if not success_WeaponUtils then
        error("Failed to load equipment/weapons: " .. tostring(WeaponUtils))
    end
    local success_log, log = pcall(require, 'utils/LOGGER')
    if not success_log then
        error("Failed to load utils/logger: " .. tostring(log))
    end

    -- WAR uses complete weapon sets (main + sub together)
    if state.WeaponSet and sets[state.WeaponSet.value] then
        local start_time = os.clock()
        local success, error_msg = pcall(equip, sets[state.WeaponSet.value])
        local swap_time = (os.clock() - start_time) * 1000 -- in milliseconds

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
        local swap_time = (os.clock() - start_time) * 1000 -- in milliseconds

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
    local success_log, log = pcall(require, 'utils/LOGGER')
    if not success_log then
        error("Failed to load utils/logger: " .. tostring(log))
    end
    log.debug("WAR buffSelf called with param: %s", param or "none")

    local recasts = windower.ffxi.get_ability_recasts()
    local buffs = buffactive
    local delay = 0
    local firstUsed = false
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end

    -- Ability definitions: name and buff name (IDs fetched dynamically)
    local abilities = {
        { name = 'Berserk',     buff = 'Berserk' },
        { name = 'Defender',    buff = 'Defender' },
        { name = 'Aggressor',   buff = 'Aggressor' },
        { name = 'Retaliation', buff = 'Retaliation' },
        { name = 'Restraint',   buff = 'Restraint' },
    }

    -- Dynamically get recast IDs from resources
    for _, ability in ipairs(abilities) do
        local ability_data = res.job_abilities:with('en', ability.name)
        if ability_data then
            ability.id = ability_data.recast_id
        end
    end

    -- Handle mutually exclusive abilities
    local exclude = {}
    if param == 'Berserk' then
        exclude['Defender'] = true
    elseif param == 'Defender' then
        exclude['Berserk'] = true
    end

    -- Track if we want to show active buffs (only for specific param calls)
    local showActiveForParam = (param == 'Berserk' or param == 'Defender')

    -- Collect all messages to display them in order
    local messages_to_display = {}
    local abilities_to_cast = {}

    -- First pass: Check status of all abilities and collect messages
    for _, ability in ipairs(abilities) do
        local recast = recasts[ability.id] or 0
        local isActive = buffs[ability.buff]
        local isExcluded = exclude[ability.name]

        -- When using specific param (Berserk/Defender), show ALL abilities status
        if showActiveForParam then
            -- Skip excluded abilities completely
            if not isExcluded then
                if isActive then
                    -- Show active status for non-excluded abilities
                    table.insert(messages_to_display, { type = 'active', name = ability.name })
                elseif recast > 0 then
                    -- Show recast for abilities in cooldown
                    table.insert(messages_to_display, { type = 'recast', name = ability.name, time = recast })
                else
                    -- Queue for casting if available
                    table.insert(abilities_to_cast, ability)
                end
                -- For excluded abilities, only show recast if they're on cooldown
            elseif recast > 0 then
                table.insert(messages_to_display, { type = 'recast', name = ability.name, time = recast })
            end
        else
            -- Normal buffSelf behavior (no specific param)
            if not isActive and not isExcluded then
                if recast == 0 then
                    -- Queue for casting
                    table.insert(abilities_to_cast, ability)
                else
                    -- Add recast message
                    table.insert(messages_to_display, { type = 'recast', name = ability.name, time = recast })
                end
            end
        end
    end

    -- Handle Warcry / Blood Rage after other abilities
    if not buffs['Warcry'] then
        if (recasts[2] or 0) == 0 then
            table.insert(abilities_to_cast, { name = 'Warcry', id = 2, buff = 'Warcry' })
        elseif (recasts[11] or 0) == 0 then
            table.insert(abilities_to_cast, { name = 'Blood Rage', id = 11, buff = 'Warcry' })
        elseif showActiveForParam or (not showActiveForParam and #abilities_to_cast == 0) then
            -- Show recasts if using specific param OR if no abilities to cast
            if (recasts[2] or 0) > 0 then
                table.insert(messages_to_display, { type = 'recast', name = 'Warcry', time = recasts[2] })
            end
            if (recasts[11] or 0) > 0 then
                table.insert(messages_to_display, { type = 'recast', name = 'Blood Rage', time = recasts[11] })
            end
        end
    elseif showActiveForParam then
        -- Show Warcry as active if using specific param
        table.insert(messages_to_display, { type = 'active', name = 'Warcry' })
    end

    -- Display all messages with separator lines if there are any
    if #messages_to_display > 0 then
        MessageUtils.unified_status_message(messages_to_display, nil, true)
    end

    -- Cast abilities in order with fixed timing
    for i, ability in ipairs(abilities_to_cast) do
        local command = 'input /ja "' .. ability.name .. '" <me>'
        if i == 1 then
            -- First ability: immediate
            log.debug("WAR buffSelf: Using %s immediately", ability.name)
            send_command(command)
        else
            -- Subsequent abilities: 2 seconds apart each
            local wait_time = (i - 1) * 2
            log.debug("WAR buffSelf: Queuing %s with %ds delay", ability.name, wait_time)
            send_command('wait ' .. wait_time .. '; ' .. command)
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
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end

    -- Get ability IDs dynamically
    local seigan_data = res.job_abilities:with('en', 'Seigan')
    local hasso_data = res.job_abilities:with('en', 'Hasso')
    local thirdeye_data = res.job_abilities:with('en', 'Third Eye')

    -- Define ability data with dynamic IDs
    local abilities = {
        Seigan = {
            id     = seigan_data and seigan_data.recast_id or 139,
            active = buffs['Seigan'],
            recast = recasts[seigan_data and seigan_data.recast_id or 139] or 0,
        },
        Hasso = {
            id     = hasso_data and hasso_data.recast_id or 138,
            active = buffs['Hasso'],
            recast = recasts[hasso_data and hasso_data.recast_id or 138] or 0,
        },
        ThirdEye = {
            id     = thirdeye_data and thirdeye_data.recast_id or 133,
            active = buffs['Third Eye'],
            recast = recasts[thirdeye_data and thirdeye_data.recast_id or 133] or 0,
        },
    }

    local thirdEye = abilities.ThirdEye
    local usingDefender = buffs['Defender'] ~= nil
    local preferredName = usingDefender and 'Seigan' or 'Hasso'
    local preferred = abilities[preferredName]

    -- Collect messages for combined display
    local messages = {}

    -- Check status of preferred ability (Hasso/Seigan)
    if preferred.active then
        table.insert(messages, { type = 'active', name = preferredName })
    elseif preferred.recast > 0 then
        table.insert(messages, { type = 'recast', name = preferredName, time = preferred.recast })
    end

    -- Check status of Third Eye
    if thirdEye.active then
        table.insert(messages, { type = 'active', name = 'Third Eye' })
    elseif thirdEye.recast > 0 then
        table.insert(messages, { type = 'recast', name = 'Third Eye', time = thirdEye.recast })
    end

    -- Display combined status message if there are any statuses to report
    if #messages > 0 then
        MessageUtils.unified_status_message(messages, nil, true)
    end

    -- Attempt to activate abilities if available
    if not preferred.active and preferred.recast == 0 then
        send_command('input /ja "' .. preferredName .. '" <me>')
        if not thirdEye.active and thirdEye.recast == 0 then
            send_command('wait 1; input /ja "Third Eye" <me>')
        end
    elseif not thirdEye.active and thirdEye.recast == 0 then
        -- If preferred is unavailable but Third Eye is ready
        send_command('input /ja "Third Eye" <me>')
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
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end

    -- Define ability names
    local jumpName = 'Jump'
    local highJumpName = 'High Jump'

    -- Get IDs dynamically from resources
    local jump_data = res.job_abilities:with('en', jumpName)
    local highjump_data = res.job_abilities:with('en', highJumpName)
    local jumpId = jump_data and jump_data.recast_id or 158
    local highJumpId = highjump_data and highjump_data.recast_id or 159

    -- Get recast timers for Jump abilities
    local recasts = windower.ffxi.get_ability_recasts()
    local jumpRecast = recasts[jumpId] or 0
    local highJumpRecast = recasts[highJumpId] or 0

    -- Check current TP
    local tp = player.tp
    if tp >= 1000 then
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        -- Use unified system
        local messages = { { type = 'info', name = 'TP Check', message = 'Enough TP!' } }
        MessageUtils.unified_status_message(messages, nil, true)
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
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end

        -- Use unified format for jump recasts
        local messages = {}
        if jumpRecast > 0 then
            table.insert(messages, { type = 'recast', name = jumpName, time = jumpRecast })
        end
        if highJumpRecast > 0 then
            table.insert(messages, { type = 'recast', name = highJumpName, time = highJumpRecast })
        end

        if #messages > 0 then
            MessageUtils.unified_status_message(messages, nil, true)
        end
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
    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load equipment/equipment: " .. tostring(EquipmentUtils))
    end
    return EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for WAR
        sets.idle.PDT,  -- PDT set
        nil             -- No MDT set for WAR
    )
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
        return sets.engaged.PDTTP -- Balanced PDT+TP set
    else
        return sets.engaged       -- Base TP set
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
    ["Stardiver"]      = { tp_bonus_gear_always = 100 },
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
    local success_WeaponUtils, WeaponUtils = pcall(require, 'equipment/WEAPONS')
    if not success_WeaponUtils then
        error("Failed to load equipment/weapons: " .. tostring(WeaponUtils))
    end

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
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end



    -- Module loader commands
    if command == 'modules' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'

        if subcommand == 'stats' then
            local success_Colors, Colors = pcall(require, 'utils/COLORS')
            if not success_Colors then
                error("Failed to load utils/colors: " .. tostring(Colors))
            end

            Colors.show_header("MODULE STATISTICS")

            local success, ModuleLoader = pcall(require, 'utils/MODULE_LOADER')
            if success then
                local stats = ModuleLoader.get_statistics()

                Colors.show_empty_line()

                -- Section Cache & Performance
                local cache_stats = {
                    ["Loaded Modules"] = stats.cached_modules or 0,
                    ["Memory Used"] = string.format("%.2f KB", stats.total_memory_kb or 0),
                    ["Success Rate"] = {
                        value = string.format("%.1f%%", stats.hit_rate or 0),
                        color = Colors.get_performance_color(stats.hit_rate or 0)
                    },
                    ["Average Time"] = {
                        value = string.format("%.2f ms", stats.avg_load_time_ms or 0),
                        color = Colors.get_time_color(stats.avg_load_time_ms or 0)
                    }
                }
                Colors.show_stats_section("CACHE & PERFORMANCE", cache_stats)

                Colors.show_empty_line()

                -- Access & Usage Section
                local access_stats = {
                    ["Total Access"] = (stats.cache_hits or 0) + (stats.cache_misses or 0),
                    ["Cache Hits"] = stats.cache_hits or 0,
                    ["Cache Misses"] = stats.cache_misses or 0
                }
                Colors.show_stats_section("ACCESS & USAGE", access_stats)
            else
                Colors.show_status('Module loader not available', 'error')
            end

            Colors.show_footer()
        elseif subcommand == 'cleanup' then
            local success_Colors, Colors = pcall(require, 'utils/COLORS')
            if not success_Colors then
                error("Failed to load utils/colors: " .. tostring(Colors))
            end

            Colors.show_header("MODULE CLEANUP")

            local success, ModuleLoader = pcall(require, 'utils/MODULE_LOADER')
            if success then
                Colors.show_action("Cleaning up unused modules...")
                ModuleLoader.cleanup_unused_modules()
                Colors.show_status('Cleanup completed successfully!', 'success')
            else
                Colors.show_status('Module loader not available', 'error')
            end

            Colors.show_footer()
        end
        return
    end

    -- Cache management commands
    if command == 'cache' then
        local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'stats'

        if subcommand == 'stats' then
            local success_Colors, Colors = pcall(require, 'utils/COLORS')
            if not success_Colors then
                error("Failed to load utils/colors: " .. tostring(Colors))
            end

            Colors.show_header("CACHE STATISTICS")

            local success, EquipmentCache = pcall(require, 'equipment/EQUIPMENT_CACHE')
            if success then
                local stats = EquipmentCache.get_statistics()

                Colors.show_empty_line()

                -- Capacity & Usage Section
                local entries = stats.entries or 0
                local max_entries = stats.max_entries or 1
                local usage_percent = math.floor((entries / max_entries) * 100)

                local capacity_stats = {
                    ["Entries"] = {
                        value = string.format("%d/%d (%d%%)", entries, max_entries, usage_percent),
                        color = Colors.get_performance_color(100 - usage_percent) -- Inverted because full = bad
                    },
                    ["Success Rate"] = {
                        value = string.format("%.1f%%", stats.hit_rate or 0),
                        color = Colors.get_performance_color(stats.hit_rate or 0)
                    }
                }
                Colors.show_stats_section("CAPACITY & USAGE", capacity_stats)

                Colors.show_empty_line()

                -- Performance & Access Section
                local perf_stats = {
                    ["Cache hits"] = stats.hits or 0,
                    ["Cache misses"] = stats.misses or 0,
                    ["Average Time"] = {
                        value = string.format("%.2f ms", stats.avg_access_time_ms or 0),
                        color = Colors.get_time_color(stats.avg_access_time_ms or 0)
                    }
                }
                Colors.show_stats_section("PERFORMANCE & ACCESS", perf_stats)
            else
                Colors.show_status('Cache not available', 'error')
            end

            Colors.show_footer()
        elseif subcommand == 'cleanup' then
            local success_Colors, Colors = pcall(require, 'utils/COLORS')
            if not success_Colors then
                error("Failed to load utils/colors: " .. tostring(Colors))
            end

            Colors.show_header("CACHE CLEANUP")

            local success, EquipmentCache = pcall(require, 'equipment/EQUIPMENT_CACHE')
            if success then
                Colors.show_action("Cleaning up old entries...")
                Colors.show_action("Removing obsolete entries...")
                EquipmentCache.cleanup()
                Colors.show_status('Cleanup completed successfully!', 'success')
            else
                Colors.show_status('Cache not available', 'error')
            end

            Colors.show_footer()
        elseif subcommand == 'clear' then
            local success_Colors, Colors = pcall(require, 'utils/COLORS')
            if not success_Colors then
                error("Failed to load utils/colors: " .. tostring(Colors))
            end

            Colors.show_header("CACHE CLEAR")

            local success, EquipmentCache = pcall(require, 'equipment/EQUIPMENT_CACHE')
            if success then
                Colors.show_status("WARNING: Deleting all entries...", "warning")
                Colors.show_action("Clearing in progress...")
                EquipmentCache.clear()
                Colors.show_status('Cache completely cleared!', 'success')
                Colors.show_action('Restarting cache...')
            else
                Colors.show_status('Cache not available', 'error')
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
