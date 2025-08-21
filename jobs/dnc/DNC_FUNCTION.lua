---============================================================================
--- FFXI GearSwap Job Module - Dancer Advanced Functions
---============================================================================
--- Professional Dancer job-specific functionality providing intelligent
--- step/flourish management, TP conservation, support ability coordination,
--- and advanced dance combat automation. Core features include:
---
--- • **Intelligent Step Management** - Box Step, Quickstep, Stutter Step timing
--- • **Flourish Optimization** - Climactic, Building, Ternary flourish coordination
--- • **TP Conservation Strategies** - Efficient ability usage and TP management
--- • **Divine Waltz Integration** - Party healing and support timing
--- • **Contradance/Presto Management** - Advanced job ability coordination
--- • **Target Selection Logic** - Intelligent step targeting for maximum effect
--- • **Support Role Coordination** - Party member buff and healing assistance
--- • **Error Recovery Systems** - Robust handling of step/flourish failures
---
--- This module implements the advanced dance mechanics that make DNC
--- automation intelligent and supportive, handling complex step coordination
--- and support ability management with comprehensive error handling.
---
--- @file jobs/dnc/DNC_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires Mote-TreasureHunter.lua for TH support
---
--- @usage
---   handle_presto_and_step(spell, eventArgs) -- Presto and step coordination
---   auto_WS_flourish(spell) -- Automatic flourish application for weapon skills
---
--- @see jobs/dnc/DNC_SET.lua for step, flourish, and support equipment sets
--- @see Tetsouo_DNC.lua for job configuration and dance mode management
---============================================================================

-- Constants used throughout the script
local constants = {
    SPELL_NAMES = {
        -- Name of the "Divine Waltz II" spell
        DIVINE_WALTZ_II = "Divine Waltz II",
    }
}

---============================================================================
--- DNC BUFF SELF SYSTEM
---============================================================================

--- Buffs the player with DNC abilities if the provided parameter is 'dncBuff'.
--- Uses the same WAR-style combined status display for consistency.
--- @param {string} param - The parameter to determine if the function should run.
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
    local haste_samba_data = res.job_abilities:with('en', 'Haste Samba')
    local contradance_data = res.job_abilities:with('en', 'Contradance')
    local presto_data = res.job_abilities:with('en', 'Presto')

    -- Define the abilities to use and their corresponding recast times.
    local abilities = {
        { name = 'Haste Samba', recast = AbilityRecasts[haste_samba_data and haste_samba_data.recast_id or 83] },
        { name = 'Contradance', recast = AbilityRecasts[contradance_data and contradance_data.recast_id or 229] },
        { name = 'Presto',      recast = AbilityRecasts[presto_data and presto_data.recast_id or 236] }
    }

    -- Initialize variables for WAR-style display.
    local delay = 1                -- The delay in seconds between each ability usage.
    local readyAbility = nil       -- The next ability to be used.
    local delayedAbilities = {}    -- The list of abilities to be used after the delay.
    local messages_to_display = {} -- Messages for WAR-style display

    -- Iterate over the abilities to collect status info.
    for _, ability in ipairs(abilities) do
        -- Check if the ability is ready to use, not active, and the param is 'dncBuff'.
        if not buffactive[ability.name] and param == 'dncBuff' then
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
        elseif buffactive[ability.name] and param == 'dncBuff' then
            -- Show active buffs in WAR-style display
            table.insert(messages_to_display, { type = 'active', name = ability.name })
        end
    end

    -- Display status messages using WAR-style format
    if #messages_to_display > 0 and param == 'dncBuff' then
        MessageUtils.unified_status_message(messages_to_display, nil, true)
    end

    -- Use the ready ability immediately.
    if readyAbility then
        send_command('input /ja "' .. readyAbility.name .. '" <me>')
        delay = delay + 1
    end

    -- Use delayed abilities with a delay between each usage.
    for _, ability in ipairs(delayedAbilities) do
        send_command(
            'wait ' .. delay .. '; input /ja "' .. ability.name .. '" <me>'
        )
        delay = delay + 2
    end
end

--- Automatically uses the 'Presto' ability for 'Step' type spells when the main job level is 77 or above and 'Presto' is not on cooldown.
-- @param {table} spell - The spell object to attempt to cast. It must be a table with a 'type' field.
-- @param {table} eventArgs - The event arguments object. It must have a 'handled' field.
function handle_presto_and_step(spell, eventArgs)
    -- Attempt to cast the spell
    if try_cast_spell(spell, eventArgs) then
        -- If the spell type is 'Step'
        if spell.type == 'Step' then
            local success_H, H = pcall(require, 'utils/ABILITY_HELPER')
            if not success_H then
                error("Failed to load utils/ability_helper: " .. tostring(H))
            end
            H.try_ability(spell, eventArgs, 'Presto', 2)
        end
    end
end

--- Maps spells to their corresponding automatic abilities.
-- @table auto_abilities
auto_abilities = {
    -- Uses 'Contradance' ability for 'Divine Waltz II' spell.
    [constants.SPELL_NAMES.DIVINE_WALTZ_II] = function(spell, eventArgs)
        -- If the player has less than 800 TP, cancel the spell and display a message.
        if player.tp < 800 then
            eventArgs.handled = true
            cancel_spell()
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.dnc_tp_insufficient_message(player.tp)
        else
            local success_H, H = pcall(require, 'utils/ABILITY_HELPER')
            if not success_H then
                error("Failed to load utils/ability_helper: " .. tostring(H))
            end
            H.try_ability(spell, eventArgs, 'Contradance', 1)
        end
    end
}

-- Determines the custom weapon skill mode based on active buffs.
-- @param {table} spell - The spell being cast.
-- @param {string} spellMap - The map of the spell.
-- @param {string} default_wsmode - The default weapon skill mode.
-- @return {string} The custom weapon skill mode if 'Climactic Flourish' or TpBonus buffs are active.
function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode

    -- Check if 'Climactic Flourish' buff is active. If so, set the weapon skill mode to 'Clim'.
    if state.Buff['Climactic Flourish'] then
        wsmode = (wsmode or '') .. 'Clim'
    end

    -- Check if 'TpBonus' state is active. If so, add 'Tpbonus' to the mode.
    if state.TpBonus then
        wsmode = (wsmode or '') .. 'Tpbonus'
    end

    -- Return the custom weapon skill mode. If no buffs are active, this will be nil.
    return wsmode
end

--- Automatically triggers 'Climactic Flourish' when executing 'Rudra's Storm' or 'Shark Bite'.
-- @param {table} spell - The spell object to attempt to cast.
function auto_WS_flourish(spell)
    -- Retrieve the recast times for all abilities.
    local allRecasts = windower.ffxi.get_ability_recasts()

    -- Get the recast times for 'Climactic Flourish' and 'Building Flourish'.
    -- Get ability IDs dynamically
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local clim_data = res.job_abilities:with('en', 'Climactic Flourish')
    local build_data = res.job_abilities:with('en', 'Building Flourish')

    local ClimCD = allRecasts[clim_data and clim_data.recast_id or 226]
    local BuilCD = allRecasts[build_data and build_data.recast_id or 222]

    -- Check if the spell is 'Rudra's Storm' or 'Shark Bite', the player has more than 1000 TP, the target has more than 25% HP, and the player has at least 3 Finishing Moves.
    if (spell.name == "Rudra's Storm" or spell.name == 'Shark Bite') and player.tp > 1000 and player.target.hpp > 25 and (buffactive['Finishing Move (3+)'] or buffactive['Finishing Move (6+)']) then
        -- If 'Climactic Flourish' is off cooldown and not active, cancel the current spell, use 'Climactic Flourish', wait 2 seconds, then execute the original spell.
        if ClimCD < 1 and not climactic then
            cancel_spell()
            send_command('input /ja "Climactic Flourish" <me>; wait 2; input /ws "' ..
                spell.name .. '"' .. spell.target.id)
        end
    end
end

-- Add this new state at the beginning of your script
-- This state determines whether to use the alternate step.
state.UseAltStep = M(false, 'Use Alt Step')

--- Handles custom commands specific to the job.
-- It updates the altState object, handles a set of predefined commands, and handles job-specific and subjob-specific commands.
-- @param {table} cmdParams - The command parameters. The first element is expected to be the command name.
-- @param {table} eventArgs - Additional event arguments.
-- @param {table} spell - The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Handle macro commands using centralized system
    local success_MacroCommands, MacroCommands = pcall(require, 'macros/MACRO_COMMANDS')
    if not success_MacroCommands then
        error("Failed to load core/macro_commands: " .. tostring(MacroCommands))
    end
    if MacroCommands.handle_macro_command(cmdParams, eventArgs, 'DNC') then
        return
    end

    -- Update the altState object
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

    -- Smart buff command for DNC - activates subjob-appropriate buffs
    -- Use centralized smartbuff system from core/commands.lua
    if command == 'smartbuff' then
        local success_CommandUtils, CommandUtils = pcall(require, 'core/COMMANDS')
        if success_CommandUtils then
            -- Call the smartbuff function directly from the command table
            return CommandUtils.handle_thf_commands({ 'smartbuff' })
        else
            error("Failed to load core/COMMANDS: " .. tostring(CommandUtils))
        end
    end

    -- OLD SYSTEM (to remove later)
    if command == 'smartbuff_old' then
        local sub_job = player.sub_job

        if not sub_job then
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.dnc_smartbuff_subjob_message(nil)
            return
        end

        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        MessageUtils.dnc_smartbuff_subjob_message(sub_job)

        if sub_job == 'WAR' then
            local buffs_to_use = {}

            -- Check Berserk
            if not buffactive['Berserk'] then
                table.insert(buffs_to_use, 'Berserk')
            end

            -- Check Aggressor
            if not buffactive['Aggressor'] then
                table.insert(buffs_to_use, 'Aggressor')
            end

            -- Check Warcry
            if not buffactive['Warcry'] then
                table.insert(buffs_to_use, 'Warcry')
            end

            -- Cancel Defender if active (conflicts with Berserk)
            if buffactive['Defender'] and #buffs_to_use > 0 then
                send_command('cancel defender')
            end

            -- Execute available buffs
            if #buffs_to_use > 0 then
                for i, buff in ipairs(buffs_to_use) do
                    local delay = (i - 1) * 2
                    send_command('wait ' .. delay .. '; input /ja "' .. buff .. '" <me>')
                end
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end
                MessageUtils.dnc_buff_execution_message(buffs_to_use, 'buffs')
            else
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end
                MessageUtils.dnc_buff_execution_message(nil, 'all_active')
            end
        elseif sub_job == 'NIN' then
            -- Check current shadows and cast appropriate Utsusemi
            if not buffactive['Copy Image'] and not buffactive['Copy Image (2)'] and not buffactive['Copy Image (3)'] then
                send_command('input /ma "Utsusemi: Ni" <me>')
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end
                MessageUtils.dnc_buff_execution_message(nil, 'shadows_new')
            else
                send_command('input /ma "Utsusemi: Ni" <me>')
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end
                MessageUtils.dnc_buff_execution_message(nil, 'shadows_refresh')
            end
        else
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.dnc_buff_execution_message(nil, 'no_buffs', sub_job)
        end
        return
    end


    -- If the command is defined, execute it
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- If the player's main job is 'DNC' and the command is 'step'
        if player.main_job == 'DNC' and command == 'step' then
            if cmdParams[2] == 't' then
                -- Use the value of state.MainStep or state.AltStep as the spell name to cast
                local step = state.UseAltStep.value and state.AltStep.value or state.MainStep.value
                send_command('input /ja "' .. step .. '" <t>')
                -- Toggle the state for the next call
                state.UseAltStep:toggle()
            end
        end
    end
end

---============================================================================
--- IDLE SET CUSTOMIZATION
---============================================================================

--- Customize idle set with standardized Town/Dynamis logic.
--- Provides unified idle set management with automatic city detection
--- and Dynamis exclusion for consistent behavior across all jobs.
---
--- @param idleSet table The base idle set to customize
--- @return table The customized idle set
function customize_idle_set(idleSet)
    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    return EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for DNC
        nil,            -- No PDT set for DNC idle
        nil             -- No MDT set for DNC idle
    )
end
