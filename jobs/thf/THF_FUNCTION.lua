---============================================================================
--- FFXI GearSwap Job Module - Thief Advanced Functions
---============================================================================

-- Load critical dependencies
-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
--- Professional Thief job-specific functionality providing intelligent
--- Treasure Hunter management, Sneak/Trick Attack optimization, stealth
--- mechanics, and advanced rogue combat automation. Core features include:
---
--- • **Intelligent Treasure Hunter Management** - Dynamic TH gear swapping
--- • **SA/TA Preservation System** - Movement-aware gear retention
--- • **Stealth Ability Optimization** - Hide, Sneak Attack, Trick Attack timing
--- • **Ranged TH Integration** - Treasure Hunter on ranged attacks
--- • **Multi-Mode TH Support** - None, Tag, SATA, Fulltime modes
--- • **Ability Recast Management** - Feint, Bully, Conspirator automation
--- • **Weapon Skill Coordination** - SA/TA integration with weapon skills
--- • **Error Recovery Systems** - Robust handling of stealth failures
---
--- This module implements the advanced rogue mechanics that make THF
--- automation intelligent and efficient, handling complex TH coordination
--- and stealth ability management with comprehensive error handling.
---
--- @file jobs/thf/THF_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires Mote-TreasureHunter.lua for TH automation
---
--- @usage
---   buffSelf('thfBuff') -- Self-buff with Feint, Bully, Conspirator
---   update_TH_set_for_buffs() -- Dynamic TH set updating based on SA/TA
---   check_range_lock() -- Range validation for abilities
---
--- @see jobs/thf/THF_SET.lua for TH and SA/TA equipment sets
--- @see Tetsouo_THF.lua for job configuration and TH mode management
---============================================================================

---============================================================================
--- JOB ABILITY AUTOMATION SYSTEM
---============================================================================

--- Automatic abilities mapping table for THF-specific ability automation
--- Stores ability mappings and timing data for intelligent ability usage
--- @type table<string, any> Auto-ability configuration and state data
local auto_abilities = {}

---============================================================================
--- UTSUSEMI SHADOW MANAGEMENT SYSTEM
---============================================================================

--- Refines Utsusemi spell based on recast availability
--- Automatically downgrades Ni to Ichi if Ni is on cooldown
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments for spell handling
function refine_utsusemi(spell, eventArgs)
    -- Only handle for NIN subjob
    if player.sub_job ~= 'NIN' then
        return
    end

    -- Only handle Utsusemi spells
    if not spell.english or not (spell.english == 'Utsusemi: Ni' or spell.english == 'Utsusemi: Ichi') then
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end

    -- Check if trying to cast Ni but it's on recast
    -- Get spell IDs dynamically from resources
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local ni_spell = res.spells:with('en', 'Utsusemi: Ni')
    local ichi_spell = res.spells:with('en', 'Utsusemi: Ichi')
    local ni_id = ni_spell and ni_spell.id or 339
    local ichi_id = ichi_spell and ichi_spell.id or 338

    if spell.english == 'Utsusemi: Ni' then
        -- Convert from centiseconds to seconds (spell recasts are in centiseconds)
        local ni_recast = (spell_recasts[ni_id] or 0) / 100
        if ni_recast > 0 then
            -- Check if Ichi is available (also convert from centiseconds)
            local ichi_recast = (spell_recasts[ichi_id] or 0) / 100
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end

            if ichi_recast == 0 then
                cancel_spell()
                send_command('input /ma "Utsusemi: Ichi" <me>')

                -- Silent fallback - no message per user request
                eventArgs.cancel = true
            else
                -- Both on recast - let central system handle the message
                eventArgs.cancel = true
            end
        end
    elseif spell.english == 'Utsusemi: Ichi' then
        -- Check if Ni is available (prefer Ni over Ichi) - convert from centiseconds
        local ni_recast = (spell_recasts[ni_id] or 0) / 100
        if ni_recast == 0 and not buffactive['Copy Image'] and not buffactive['Copy Image (2)'] then
            cancel_spell()
            send_command('input /ma "Utsusemi: Ni" <me>')

            -- Silent upgrade - no message per user request
            eventArgs.cancel = true
        end
    end
end

--- Handles automatic shadow cancellation for Utsusemi: Ni and Ichi
--- Requires Cancel addon to be installed and loaded
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments for spell handling
function handle_utsusemi_shadows(spell, eventArgs)
    -- Only handle for NIN subjob
    if player.sub_job ~= 'NIN' then
        return
    end

    -- Check if spell is Utsusemi
    if spell.english == 'Utsusemi: Ni' then
        -- Ni automatically overwrites existing shadows - no cancel needed
        return
    elseif spell.english == 'Utsusemi: Ichi' then
        -- Only cancel if we have 3+ shadows (Ni shadows), let Ichi overwrite naturally if 1-2 shadows
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
            -- Ichi has ~3-3.5 sec cast time, cancel at 2 seconds
            send_command(
            '@wait 2.0;cancel copy image;cancel copy image (2);cancel copy image (3);cancel copy image (4+)')
        end
    elseif spell.english == 'Utsusemi: San' then
        -- San automatically overwrites - no cancel needed
        return
    end
end

--- Cancel conflicting buffs for various spells
--- Inspired by Mote-Utility but specific to THF needs
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments for spell handling
function cancel_conflicting_buffs(spell, eventArgs)
    -- Skip check for Cancel addon (just try to use it)
    -- The cancel commands will simply fail silently if addon not loaded

    -- Validate parameters
    if not spell or type(spell) ~= 'table' then
        return
    end

    if not eventArgs or type(eventArgs) ~= 'table' then
        eventArgs = {} -- Create empty table if not provided
    end

    -- Central system now handles ALL recast/buff checks - only handle conflict resolution here

    -- Handle Spectral Jig (cancels sneak to reapply both)
    if spell.english == 'Spectral Jig' and buffactive.sneak then
        send_command('cancel sneak')
        -- Handle Sneak spell on self
    elseif spell.english == 'Sneak' and spell.target and spell.target.type == 'SELF' and buffactive.sneak then
        send_command('cancel sneak')
        -- Handle Monomi (NIN sneak)
    elseif spell.english and spell.english:startswith('Monomi') then
        send_command('@wait 1.7;cancel sneak')
    end

    -- Handle Utsusemi shadows
    handle_utsusemi_shadows(spell, eventArgs)
end

-- Buffs the player with specific abilities if the provided parameter is 'thfBuff'.
-- Uses WAR-style combined status display for consistency.
-- @param {string} param - The parameter to determine if the function should run.
function buffSelf(param)
    -- Get the current ability recast times.
    local AbilityRecasts = windower.ffxi.get_ability_recasts()
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end

    -- Get ability IDs dynamically
    local feint_data = res.job_abilities:with('en', 'Feint')
    local bully_data = res.job_abilities:with('en', 'Bully')
    local conspirator_data = res.job_abilities:with('en', 'Conspirator')

    -- Define the abilities to use and their corresponding recast times.
    local abilities = {
        { name = 'Feint',       recast = AbilityRecasts[feint_data and feint_data.recast_id or 68] },
        { name = 'Bully',       recast = AbilityRecasts[bully_data and bully_data.recast_id or 240] },
        { name = 'Conspirator', recast = AbilityRecasts[conspirator_data and conspirator_data.recast_id or 40] }
    }

    -- Initialize variables for WAR-style display.
    local delay = 1                -- The delay in seconds between each ability usage.
    local readyAbility = nil       -- The next ability to be used.
    local delayedAbilities = {}    -- The list of abilities to be used after the delay.
    local messages_to_display = {} -- Messages for WAR-style display

    -- Iterate over the abilities to collect status info.
    for _, ability in ipairs(abilities) do
        -- Check if the ability is ready to use, not active, and the param is 'thfBuff'.
        if not buffactive[ability.name] and param == 'thfBuff' then
            if ability.recast < 1 then
                -- If no ability is ready, set the current ability as the ready ability.
                if not readyAbility then
                    readyAbility = ability
                else
                    -- If an ability is already ready, add the current ability to the delayed abilities list.
                    table.insert(delayedAbilities, ability)
                end
            else
                -- Add recast message for WAR-style display
                table.insert(messages_to_display, { type = 'recast', name = ability.name, time = ability.recast })
            end
        elseif buffactive[ability.name] and param == 'thfBuff' then
            -- Show active buffs in WAR-style display
            table.insert(messages_to_display, { type = 'active', name = ability.name })
        end
    end

    -- Display status messages using WAR-style format
    if #messages_to_display > 0 and param == 'thfBuff' then
        MessageUtils.unified_status_message(messages_to_display, 'THF', true)
    end

    -- Use the ready ability immediately.
    if readyAbility then
        send_command('input /ja "' .. readyAbility.name .. '" ' .. (readyAbility.name == 'Bully' and '<t>' or '<me>'))
        delay = delay + 1
    end

    -- Use delayed abilities with a delay between each usage.
    for _, ability in ipairs(delayedAbilities) do
        send_command(
            'wait ' .. delay .. '; input /ja "' .. ability.name .. '" ' .. (ability.name == 'Bully' and '<t>' or '<me>')
        )
        delay = delay + 2
    end
end

-- Determines the custom weapon skill mode based on active buffs.
-- @param {table} spell - The spell being cast.
-- @param {string} spellMap - The map of the spell.
-- @param {string} default_wsmode - The default weapon skill mode.
-- @return {string} The custom weapon skill mode if 'Sneak Attack' or 'Trick Attack' buffs are active.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode

    -- Check if 'Sneak Attack' buff is active. If so, set the weapon skill mode to 'SA'.
    if state.Buff['Sneak Attack'] then
        wsmode = (wsmode or '') .. 'SA'
    end

    -- Check if 'Trick Attack' buff is active. If so, append 'TA' to the weapon skill mode.
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    -- Return the custom weapon skill mode. If no buffs are active, this will be nil.
    return wsmode
end

--- Helper function to apply SA/TA sets to a given set
-- @param baseSet table: The base set to apply SA/TA to
-- @param thf_config table: THF configuration settings
-- @return table: The set with SA/TA applied
local function apply_sa_ta_to_set(baseSet, thf_config)
    local resultSet = baseSet

    -- Priority: SA > TA if both are active
    if buffactive['sneak attack'] and sets.buff['Sneak Attack'] then
        resultSet = set_combine(resultSet, sets.buff['Sneak Attack'])
    elseif buffactive['trick attack'] and sets.buff['Trick Attack'] then
        -- Only apply TA if SA is not active (or SA priority is disabled)
        if not (thf_config.sa_priority_over_ta and buffactive['sneak attack']) then
            resultSet = set_combine(resultSet, sets.buff['Trick Attack'])
        end
    end

    return resultSet
end

-- Customizes the idle set based on current state, using modular system.
-- @param {table} idleSet - The base idle set.
-- @return {table} The customized idle set.
function customize_idle_set(idleSet)
    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    local standardSet = EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for THF
        sets.idle.PDT,  -- PDT set
        nil             -- No MDT set for THF
    )

    -- THF-specific: HP critical threshold for Regen gear
    if player.hp < 2000 then
        standardSet = set_combine(standardSet, sets.idle.Regen)
    end

    -- CHANGED: SA/TA buffs no longer change equipment in idle - maintain normal behavior
    -- Only change feet for movement (completely neutral, no SA/TA interference)
    if state.Moving and state.Moving.value == 'true' and sets.MoveSpeed then
        standardSet = set_combine(standardSet, sets.MoveSpeed)
    end

    return standardSet
end

--- Customizes the melee gear set for THF based on current states and conditions.
--
-- NEW FEATURE: Advanced TH + SA/TA Management with Engaged Sets
--
-- Priority System:
--   1. Check for engaged.TH sets when TH tagging is active (for better combat performance)
--   2. Use specialized TreasureHunter sets for initial tagging
--   3. Automatic combination as fallback
--
-- @param meleeSet table: The base melee set defined in gear sets.
-- @return table: The final, conditionally customized melee set.
function customize_melee_set(meleeSet)
    -- Initialize with base melee set and load configuration
    local finalSet = meleeSet
    local success_config, config = pcall(require, 'config/config')
    if not success_config then
        error("Failed to load config/config: " .. tostring(config))
    end
    local thf_config = config.get_job_config('THF')

    -- ═══════════════════════════════════════════════════════════════════════════
    -- TREASURE HUNTER PRIORITY SYSTEM
    -- ═══════════════════════════════════════════════════════════════════════════
    -- Priority 1: Specialized engaged.TH sets (best performance)
    -- Priority 2: Combined TreasureHunter + SA/TA sets (compatibility)
    -- Priority 3: Base SA/TA application (fallback)

    if state.TreasureMode.value ~= 'None' then
        -- Determine if we should actively use TH gear
        -- True for: Fulltime mode OR currently tagging a mob
        local should_use_th_sets = (state.TreasureMode.value == 'Fulltime' or state.th_gear_is_locked)

        if should_use_th_sets then
            -- ───────────────────────────────────────────────────────────────────────
            -- ENGAGED.TH SETS: Pre-optimized sets for best combat+TH performance
            -- These sets are manually optimized for max DPS while maintaining TH
            -- ───────────────────────────────────────────────────────────────────────

            -- Check for SA+TA combo first (highest damage potential)
            if (buffactive['sneak attack'] and buffactive['trick attack']) and sets.engaged.TH and sets.engaged.TH.SATA then
                finalSet = sets.engaged.TH.SATA
                -- Then SA only (moderate damage boost)
            elseif buffactive['sneak attack'] and sets.engaged.TH and sets.engaged.TH.SA then
                finalSet = sets.engaged.TH.SA
                -- Then TA only (accuracy/crit boost)
            elseif buffactive['trick attack'] and sets.engaged.TH and sets.engaged.TH.TA then
                finalSet = sets.engaged.TH.TA
                -- Finally base TH engaged set
            elseif sets.engaged.TH then
                finalSet = sets.engaged.TH
            else
                -- ───────────────────────────────────────────────────────────────────
                -- FALLBACK: Legacy TreasureHunter set combination method
                -- Used when engaged.TH sets are not available
                -- ───────────────────────────────────────────────────────────────────
                if thf_config and thf_config.prefer_specialized_th_sets then
                    -- Use pre-defined specialized TH+SA/TA combination sets
                    if (buffactive['sneak attack'] and buffactive['trick attack']) and sets.TreasureHunter.SATA then
                        finalSet = set_combine(finalSet, sets.TreasureHunter.SATA)
                    elseif buffactive['sneak attack'] and sets.TreasureHunter.SA then
                        finalSet = set_combine(finalSet, sets.TreasureHunter.SA)
                    elseif buffactive['trick attack'] and sets.TreasureHunter.TA then
                        finalSet = set_combine(finalSet, sets.TreasureHunter.TA)
                    else
                        -- Combine base TH set with dynamic SA/TA application
                        finalSet = set_combine(finalSet, sets.TreasureHunter)
                        finalSet = apply_sa_ta_to_set(finalSet, thf_config)
                    end
                else
                    -- Simple combination: TH + dynamic SA/TA
                    finalSet = set_combine(finalSet, sets.TreasureHunter)
                    finalSet = apply_sa_ta_to_set(finalSet, thf_config)
                end
            end
        else
            -- ───────────────────────────────────────────────────────────────────────
            -- NO ACTIVE TH: Pure combat optimization
            -- Apply SA/TA gear without TH considerations
            -- ───────────────────────────────────────────────────────────────────────
            if thf_config and thf_config.auto_sa_ta_combat then
                finalSet = apply_sa_ta_to_set(finalSet, thf_config)
            end
        end
    else
        -- ═══════════════════════════════════════════════════════════════════════════
        -- NO TREASURE HUNTER MODE: Pure damage optimization
        -- ═══════════════════════════════════════════════════════════════════════════
        if thf_config and thf_config.auto_sa_ta_combat then
            finalSet = apply_sa_ta_to_set(finalSet, thf_config)
        end
    end

    -- PRIORITY 3: Accuracy if in Accuracy mode
    if state.OffenseMode.current == 'Acc' and sets.engaged.Acc then
        finalSet = set_combine(finalSet, sets.engaged.Acc)
    end

    -- Critical HP → prioritize full PDT
    if player.hp <= 2000 and sets.engaged.PDT then
        finalSet = set_combine(finalSet, sets.engaged.PDT)
    end

    -- Add dynamic conditional sets (PDT, Acc.PDT, etc.)
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(
        nil,
        sets.engaged.PDT,
        sets.engaged.Acc and sets.engaged.Acc.PDT or nil,
        nil
    )
    finalSet = EquipmentUtils.customize_set(finalSet, conditions, setTable)

    -- Final override if AM3 + Vajra + PDT: priority set
    local isAM3Active = (
        state.HybridMode and state.HybridMode.value == 'PDT'
        and player.equipment.main == 'Vajra'
        and buffactive["Aftermath: Lv.3"]
    )
    if isAM3Active and sets.engaged.PDTAFM3 then
        finalSet = set_combine(finalSet, sets.engaged.PDTAFM3)
    end

    return finalSet
end

--- Handles job updates by refreshing the Treasure Hunter status.
-- @param {table} cmdParams - The parameters of the command triggering the job update.
-- @param {table} eventArgs - Additional arguments associated with the event.
function job_update(cmdParams, eventArgs)
    -- Delegate the update to the Treasure Hunter specific function.
    th_update(cmdParams, eventArgs)
end

-- Store the original TH set to restore it when needed
local base_TH_set = {
    feet = EquipmentFactory.create("Skulker's Poulaines +3")
}

-- Function to dynamically modify sets.TreasureHunter based on active buffs
local function update_TH_set_for_buffs()
    -- Modify sets.TreasureHunter dynamically based on buffs
    if buffactive['sneak attack'] and buffactive['trick attack'] then
        if sets.TreasureHunter.SATA then
            sets.TreasureHunter = sets.TreasureHunter.SATA
        else
            sets.TreasureHunter = set_combine(base_TH_set, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])
        end
    elseif buffactive['sneak attack'] then
        if sets.TreasureHunter.SA then
            sets.TreasureHunter = sets.TreasureHunter.SA
        else
            sets.TreasureHunter = set_combine(base_TH_set, sets.buff['Sneak Attack'])
        end
    elseif buffactive['trick attack'] then
        if sets.TreasureHunter.TA then
            sets.TreasureHunter = sets.TreasureHunter.TA
        else
            sets.TreasureHunter = set_combine(base_TH_set, sets.buff['Trick Attack'])
        end
    else
        sets.TreasureHunter = base_TH_set
    end
end

-- Function called when status changes to update TH sets (movement sets no longer affected by buffs)
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Update TH set when engaging
    if playerStatus == 'Engaged' then
        update_TH_set_for_buffs()
    end
end

-- Function called when buffs change (SA/TA gained/lost)
function job_buff_change(buff, gain)
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        -- Update only TH sets when SA/TA changes (movement sets remain neutral)
        update_TH_set_for_buffs()
    end
end

-- Simple movement set - no SA/TA interference
local function ensure_base_movement_set()
    if not sets.MoveSpeed then
        sets.MoveSpeed = {
            feet = EquipmentFactory.create('Pill. Poulaines +3'),
            ring1 = EquipmentFactory.create('Defending Ring')
        }
    end
end

-- Initialize neutral movement set
ensure_base_movement_set()

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
--- Executes custom job-specific commands.
-- @param {table} cmdParams - The command parameters, with the command name expected as the first element.
-- @param {table} eventArgs - Additional event arguments.
-- @param {table} spell - The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the alternate state.
    update_altState()
    local command = cmdParams[1]:lower()

    -- Try universal commands first (test, modules, cache, metrics, help)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end

    -- If the command is predefined, execute it.
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- If the command is not predefined, handle it as a Thief-specific command.
        handle_thf_commands(cmdParams)

        -- If the subjob is Scholar, handle it as a Scholar-specific command.
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end
