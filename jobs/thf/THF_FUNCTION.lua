---============================================================================
--- FFXI GearSwap Job Module - Thief Advanced Functions
---============================================================================
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

-- Buffs the player with specific abilities if the provided parameter is 'thfBuff'.
-- @param {string} param - The parameter to determine if the function should run.
function buffSelf(param)
    -- Get the current ability recast times.
    local AbilityRecasts = windower.ffxi.get_ability_recasts()

    -- Define the abilities to use and their corresponding recast times.
    local abilities = {
        { name = 'Feint',       recast = AbilityRecasts[68] },
        { name = 'Bully',       recast = AbilityRecasts[240] },
        { name = 'Conspirator', recast = AbilityRecasts[40] }
    }

    -- Initialize variables.
    local delay = 1             -- The delay in seconds between each ability usage.
    local readyAbility = nil    -- The next ability to be used.
    local delayedAbilities = {} -- The list of abilities to be used after the delay.

    -- Iterate over the abilities.
    for _, ability in ipairs(abilities) do
        -- Check if the ability is ready to use, not active, and the param is 'thfBuff'.
        if not buffactive[ability.name] and ability.recast < 1 and param == 'thfBuff' then
            -- If no ability is ready, set the current ability as the ready ability.
            if not readyAbility then
                readyAbility = ability
            else
                -- If an ability is already ready, add the current ability to the delayed abilities list.
                table.insert(delayedAbilities, ability)
            end
        end
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
    -- THF-specific: HP critical threshold for Regen gear
    if player.hp < 2000 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end

    -- THF-specific: Handle SA/TA buffs in idle (configurable and persistent)
    local config = require('config/config')
    local thf_config = config.get_job_config('THF')
    
    -- Apply SA/TA sets in idle mode (always, including when moving)
    if buffactive['sneak attack'] and sets.buff['Sneak Attack'] then
        idleSet = set_combine(idleSet, sets.buff['Sneak Attack'])
        -- Also add movement speed if moving
        if state.Moving and state.Moving.value == 'true' and sets.MoveSpeed and sets.MoveSpeed.feet then
            idleSet = set_combine(idleSet, {feet = sets.MoveSpeed.feet})
        end
    elseif buffactive['trick attack'] and sets.buff['Trick Attack'] then
        idleSet = set_combine(idleSet, sets.buff['Trick Attack'])
        -- Also add movement speed if moving
        if state.Moving and state.Moving.value == 'true' and sets.MoveSpeed and sets.MoveSpeed.feet then
            idleSet = set_combine(idleSet, {feet = sets.MoveSpeed.feet})
        end
    elseif state.Moving and state.Moving.value == 'true' and sets.MoveSpeed then
        -- No SA/TA active, apply normal movement set
        idleSet = set_combine(idleSet, sets.MoveSpeed)
    end

    -- Use standard modular approach for PDT/normal idle (consistent with WAR/DRG/PLD/RUN)
    local EquipmentUtils = require('core/equipment')
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(
        nil,             -- sets.idleXp (not used for THF)
        sets.idle.PDT,   -- PDT set
        nil,             -- Acc PDT (not used for THF)
        nil              -- MDT (not used for THF)
    )

    return EquipmentUtils.customize_set(idleSet, conditions, setTable)
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
    local config = require('config/config')
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

    -- PRIORITÉ 3: Accuracy si en mode Accuracy
    if state.OffenseMode.current == 'Acc' and sets.engaged.Acc then
        finalSet = set_combine(finalSet, sets.engaged.Acc)
    end

    -- HP critique → priorité au full PDT
    if player.hp <= 2000 and sets.engaged.PDT then
        finalSet = set_combine(finalSet, sets.engaged.PDT)
    end

    -- Ajout de sets conditionnels dynamiques (PDT, Acc.PDT, etc.)
    local EquipmentUtils = require('core/equipment')
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(
        nil,
        sets.engaged.PDT,
        sets.engaged.Acc and sets.engaged.Acc.PDT or nil,
        nil
    )
    finalSet = EquipmentUtils.customize_set(finalSet, conditions, setTable)

    -- Surcharge finale si AM3 + Vajra + PDT : set prioritaire
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
    feet = createEquipment("Skulker's Poulaines +3")
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

-- Function called when status changes to update both TH and movement sets
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Update TH set when engaging
    if playerStatus == 'Engaged' then
        update_TH_set_for_buffs()
    end
    
    -- Always update movement sets based on buffs
    update_movement_set_for_buffs()
end

-- Function called when buffs change (SA/TA gained/lost)
function job_buff_change(buff, gain)
    if buff == 'Sneak Attack' or buff == 'Trick Attack' then
        -- Update both TH and movement sets when SA/TA changes
        update_TH_set_for_buffs()
        update_movement_set_for_buffs()
    end
end

-- Create intelligent movement sets that combine with SA/TA
local function create_intelligent_movement_sets()
    -- Store the original MoveSpeed set
    local base_move_set = {
        feet = createEquipment('Pill. Poulaines +3'),
        ring1 = createEquipment('Defending Ring')
    }
    
    -- Create combined movement sets with SA/TA - but keep SA/TA feet, only add movement speed elsewhere
    sets.MoveSpeed.SA = set_combine(sets.buff['Sneak Attack'], {ring1 = createEquipment('Defending Ring')})
    sets.MoveSpeed.TA = set_combine(sets.buff['Trick Attack'], {ring1 = createEquipment('Defending Ring')}) 
    sets.MoveSpeed.SATA = set_combine(sets.buff['Sneak Attack'], sets.buff['Trick Attack'], {ring1 = createEquipment('Defending Ring')})
    
    -- Store base for restoration
    sets.MoveSpeed.base = base_move_set
    
end

-- Function to update MoveSpeed set based on active buffs
function update_movement_set_for_buffs()
    if not sets.MoveSpeed.base then
        create_intelligent_movement_sets()
    end
    
    if buffactive['sneak attack'] and buffactive['trick attack'] then
        sets.MoveSpeed = sets.MoveSpeed.SATA
    elseif buffactive['sneak attack'] then
        sets.MoveSpeed = sets.MoveSpeed.SA
    elseif buffactive['trick attack'] then
        sets.MoveSpeed = sets.MoveSpeed.TA
    else
        sets.MoveSpeed = sets.MoveSpeed.base
    end
end

-- Initialize systems
create_intelligent_movement_sets()

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


