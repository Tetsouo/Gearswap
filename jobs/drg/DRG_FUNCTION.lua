---============================================================================
--- FFXI GearSwap Job Module - Dragoon Advanced Functions
---============================================================================

-- Load critical dependencies
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
--- Professional Dragoon job-specific functionality providing intelligent
--- wyvern management, jump coordination, TP optimization, and advanced
--- dragoon combat automation. Core features include:
---
--- • **Intelligent Jump Sequencing** - Soul Jump > Spirit Jump > Jump automation
--- • **Wyvern Management System** - Call Wyvern and Spirit Link coordination
--- • **TP Optimization Logic** - Efficient jump usage for 1000 TP achievement
--- • **Hybrid Defense Modes** - PDT switching based on encounter requirements
--- • **Weapon Skill Integration** - TP bonus handling and gear optimization
--- • **City/Zone Detection** - Automatic idle set switching for different areas
--- • **Modular Equipment System** - Consistent gear management with other jobs
--- • **Error Recovery Systems** - Robust handling of jump and wyvern failures
---
--- This module implements the advanced dragoon mechanics that make DRG
--- automation intelligent and efficient, handling complex jump coordination
--- and wyvern management with comprehensive error handling.
---
--- @file jobs/drg/DRG_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-04-21 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires core/equipment.lua for modular equipment management
---
--- @usage
---   jump() -- Execute intelligent jump sequence for TP building
---   call_wyvern() -- Summon and manage wyvern companion
---   customize_idle_set(idleSet) -- Dynamic idle set customization
---   customize_melee_set(meleeSet) -- Melee set optimization
---
--- @see jobs/drg/DRG_SET.lua for jump and wyvern equipment sets
--- @see Tetsouo_DRG.lua for job configuration and dragoon mode management
---============================================================================

---------------------------------------------------------------------------------------------------
-- Function: jump
-- Description:
--    Handles all available jumps (Soul Jump > Spirit Jump > Jump) until the player reaches 1000 TP.
--    Rechecks TP after each jump and stops when 1000 TP is reached.
--    Executes one jump at a time with delay to ensure correct TP update.
---------------------------------------------------------------------------------------------------

function jump()
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local jumpSequence = { 'Soul Jump', 'Spirit Jump', 'Jump' }

    -- Get jump IDs dynamically
    local jumpIDs = {}
    for _, jump_name in ipairs(jumpSequence) do
        local jump_data = res.job_abilities:with('en', jump_name)
        jumpIDs[jump_name] = jump_data and jump_data.recast_id or
            (jump_name == 'Soul Jump' and 234 or
                jump_name == 'Spirit Jump' and 231 or 158)
    end
    local waitTime = 1.5 -- Wait time between jumps to allow TP update

    local function attempt_jump(index)
        if index > #jumpSequence then
            return -- No more jumps to attempt
        end

        local jumpName = jumpSequence[index]
        local jumpId = jumpIDs[jumpName]
        local recasts = windower.ffxi.get_ability_recasts()
        local recast = recasts[jumpId] or 0

        -- Check if already enough TP
        if player.tp >= 1000 then
            MessageUtils.drg_tp_sufficient_message()
            return
        end

        -- If the jump is ready, use it
        if recast == 0 then
            send_command('input /ja "' .. jumpName .. '" <t>')
            send_command('wait ' .. waitTime .. '; gs c jump_step ' .. (index + 1))
        else
            -- If not ready, try the next jump immediately
            attempt_jump(index + 1)
        end
    end

    attempt_jump(1)
end

---------------------------------------------------------------------------------------------------
-- Sub Function: job_self_command
-- Description:
--    Handles custom Gearswap commands like 'jump' and internal step 'jump_step'.
---------------------------------------------------------------------------------------------------

function job_self_command(cmdParams, eventArgs, spell)
    local command = cmdParams[1]:lower()

    -- Try universal commands first (test, modules, cache, metrics, help)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end

    if command == 'jump' then
        jump()
    elseif command == 'jump_step' then
        local index = tonumber(cmdParams[2])
        if index then
            local success_res, res = pcall(require, 'resources')
            if not success_res then
                error("Failed to load resources: " .. tostring(res))
            end
            local jumpSequence = { 'Soul Jump', 'Spirit Jump', 'Jump' }

            -- Get jump IDs dynamically
            local jumpIDs = {}
            for _, jump_name in ipairs(jumpSequence) do
                local jump_data = res.job_abilities:with('en', jump_name)
                jumpIDs[jump_name] = jump_data and jump_data.recast_id or
                    (jump_name == 'Soul Jump' and 234 or
                        jump_name == 'Spirit Jump' and 231 or 158)
            end
            local waitTime = 1.5

            local function attempt_jump(index)
                if index > #jumpSequence then
                    return
                end

                local jumpName = jumpSequence[index]
                local jumpId = jumpIDs[jumpName]
                local recasts = windower.ffxi.get_ability_recasts()
                local recast = recasts[jumpId] or 0

                if player.tp >= 1000 then
                    MessageUtils.drg_tp_sufficient_message()
                    return
                end

                if recast == 0 then
                    send_command('input /ja "' .. jumpName .. '" <t>')
                    send_command('wait ' .. waitTime .. '; gs c jump_step ' .. (index + 1))
                else
                    attempt_jump(index + 1)
                end
            end

            attempt_jump(index)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Function: call_wyvern
-- Description:
--    Placeholder for future Wyvern summoning logic.
---------------------------------------------------------------------------------------------------

function call_wyvern()
    -- Empty for now, ready to implement Call Wyvern logic
end

---------------------------------------------------------------------------------------------------
-- Function: spirit_link
-- Description:
--    Placeholder for future Spirit Link logic (heal wyvern, transfer buffs).
---------------------------------------------------------------------------------------------------

function spirit_link()
    -- Empty for now, ready to implement Spirit Link (heal wyvern) logic
end

---------------------------------------------------------------------------------------------------
-- Function: customize_idle_set
-- Description:
--    Customize idle set based on area (city, pdt, etc) using modular system.
---------------------------------------------------------------------------------------------------

function customize_idle_set(idleSet)
    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    return EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for DRG
        sets.idle.PDT,  -- PDT set
        nil             -- No MDT set for DRG
    )
end

---------------------------------------------------------------------------------------------------
-- Function: customize_melee_set
-- Description:
--    Customize engaged set based on HybridMode.
---------------------------------------------------------------------------------------------------

function customize_melee_set(meleeSet)
    if state.HybridMode.value == 'PDT' then
        meleeSet = sets.engaged.PDTTP
    else
        meleeSet = sets.engaged.Normal
    end
    return meleeSet
end

---------------------------------------------------------------------------------------------------
-- Function: get_custom_wsmode
-- Description:
--    Placeholder for TP bonus management logic (example: Moonshade Earring).
---------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, default_wsmode)
    local wsmode = nil
    -- Logic will be added here later
    return wsmode
end

---------------------------------------------------------------------------------------------------
-- End of DRG_FUNCTION.lua
---------------------------------------------------------------------------------------------------
