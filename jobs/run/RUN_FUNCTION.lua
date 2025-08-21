---============================================================================
--- FFXI GearSwap Job Module - Rune Fencer Advanced Functions
---============================================================================

-- Load critical dependencies
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
--- Professional Rune Fencer job-specific functionality providing intelligent
--- rune management, spell enhancement automation, defensive coordination, and
--- advanced tank-mage combat mechanics. Core features include:
---
--- • **Intelligent Rune Management** - Automatic rune cycling and optimization
--- • **Spell Enhancement Automation** - Vallation/Embolden for spell boosting
--- • **Defensive Coordination** - PDT/MDT switching based on encounter type
--- • **Phalanx Optimization** - Enhanced potency vs SIRD set selection
--- • **Foil Accuracy Boosting** - Embolden integration for accuracy spells
--- • **Hybrid Tank-Mage Modes** - Seamless switching between roles
--- • **Subjob Integration** - SCH/WHM specific command handling
--- • **Error Recovery Systems** - Robust handling of spell/ability failures
---
--- This module implements the advanced rune fencer mechanics that make RUN
--- automation intelligent and versatile, handling complex spell enhancement
--- and defensive coordination with comprehensive error handling.
---
--- @file jobs/run/RUN_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires core/equipment.lua for modular equipment management
---
--- @usage
---   manage_runes() -- Automated rune management and cycling
---   handle_phalanx_while_xp(spell, eventArgs) -- XP-aware Phalanx optimization
---   customize_idle_set(idleSet) -- Dynamic idle set customization
---   customize_melee_set(meleeSet) -- Melee set optimization
---
--- @see jobs/run/RUN_SET.lua for rune and defensive equipment sets
--- @see Tetsouo_RUN.lua for job configuration and rune mode management
---============================================================================

-- Constants used throughout the script
local constants = {
    ACTION_TYPE_MAGIC = 'Magic',               -- Action type for magic spells
    SKILL_ENHANCING_MAGIC = 'Enhancing Magic', -- Skill type for enhancing spells
    SKILL_DARK_MAGIC = 'Dark Magic',           -- Skill type for dark spells
    SPELL_NAMES = {
        -- Names of specific spells
        FLASH = 'Flash',         -- Name of the "Flash" spell
        PHALANX = 'Phalanx',     -- Name of the "Phalanx" spell
        STONESKIN = 'Stoneskin', -- Name of the "Stoneskin" spell
        FOIL = 'Foil'            -- Name of the "Foil" spell
    }
}

local success_H, H = pcall(require, 'utils/ABILITY_HELPER')
if not success_H then
    error("Failed to load utils/ability_helper: " .. tostring(H))
end

auto_abilities = {
    [constants.SPELL_NAMES.PHALANX] = function(spell, eventArgs)
        H.try_ability(spell, eventArgs, 'Vallation', 1)
    end,
    [constants.SPELL_NAMES.FOIL] = function(spell, eventArgs)
        H.try_ability(spell, eventArgs, 'Embolden', 1)
    end
}

-- This function customizes the idle set based on the current state.
-- It uses EquipmentUtils to select the appropriate set based on XP mode and defense modes.
-- @param idleSet The base idle set. It should be a table.
-- @return The customized idle set.
function customize_idle_set(idleSet)
    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    return EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        sets.idleXp,    -- XP set
        sets.idle.PDT,  -- PDT set
        sets.idle.MDT   -- MDT set
    )
end

-- This function customizes the melee set based on the current state.
-- It uses EquipmentUtils to select the appropriate set based on XP mode and defense modes.
-- @param meleeSet The base melee set. It should be a table.
-- @return The customized melee set.
function customize_melee_set(meleeSet)
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    local conditions, setTable = EquipmentUtils.get_conditions_and_sets(sets.meleeXp, sets.engaged.PDT, nil,
        sets.engaged.MDT)
    return EquipmentUtils.customize_set(meleeSet, conditions, setTable)
end

-- RUN-specific function to handle rune management
-- Intelligent rune cycling and optimization for RUN's defensive capabilities
-- Automatically maintains rune buffs and optimizes elemental resistance based on encounter
function manage_runes()
    -- ───────────────────────────────────────────────────────────────────────
    -- RUNE BUFF TRACKING AND MANAGEMENT
    -- Monitors current rune buffs and determines optimal cycling strategy
    -- ───────────────────────────────────────────────────────────────────────

    local rune_buffs = {
        ignis = 523,   -- Fire resistance rune
        gelus = 524,   -- Ice resistance rune
        flabra = 525,  -- Wind resistance rune
        tellus = 526,  -- Earth resistance rune
        sulpor = 527,  -- Thunder resistance rune
        unda = 528,    -- Water resistance rune
        lux = 529,     -- Light resistance rune
        tenebrae = 530 -- Dark resistance rune
    }

    -- Check current rune buff status
    local active_runes = {}
    for rune_name, buff_id in pairs(rune_buffs) do
        if buffactive[buff_id] then
            active_runes[rune_name] = true
        end
    end

    -- Determine optimal rune strategy based on current situation
    -- Priority: Maintain 3 runes for maximum potency
    local rune_count = 0
    for _ in pairs(active_runes) do
        rune_count = rune_count + 1
    end

    -- If less than 3 runes active, cycle through defensive priorities
    if rune_count < 3 then
        local priority_runes = { 'ignis', 'gelus', 'tellus' } -- Fire, Ice, Earth for common damage types

        for _, rune in ipairs(priority_runes) do
            if not active_runes[rune] and player.tp >= 100 then
                -- Cast the appropriate rune spell
                local spell_name = string.upper(string.sub(rune, 1, 1)) .. string.sub(rune, 2)
                if spell_name and windower.ffxi.get_spells()[windower.ffxi.get_spell_id(spell_name)] then
                    windower.chat.input('/ma "' .. spell_name .. '" <me>')
                    break
                end
            end
        end
    end
end

-- This function manages the casting of the 'Phalanx' spell for RUN.
-- RUN gets enhanced Phalanx potency, so we optimize the midcast set accordingly.
-- @param spell The spell to be cast.
-- @param eventArgs The event arguments.
-- @return A boolean indicating whether the spell was cast successfully.
function handle_phalanx_while_xp(spell, eventArgs)
    -- If the spell is Phalanx and we're in XP mode, use SIRD set
    -- Otherwise use potency set
    if state.Xp and state.Xp.value then
        sets.midcast['Phalanx'] = state.Xp.value == 'True' and sets.midcast.SIRDPhalanx or sets.midcast.PhalanxPotency
    end

    return true
end

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
-- Handles custom commands specific to RUN.
-- @param cmdParams (table): The command parameters. The first element is expected to be the command name.
-- @param eventArgs (table): Additional event arguments.
-- @param spell (table): The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the altState object for dual-boxing
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

    -- Debug commands for troubleshooting
    if command == 'debug' then
        local success_DebugSets, DebugSets = pcall(require, 'debug_sets')
        if not success_DebugSets then
            error("Failed to load debug_sets: " .. tostring(DebugSets))
        end
        if cmdParams[2] then
            DebugSets.debug_command(cmdParams[2])
        else
            DebugSets.test_common_sets()
        end
        return
    end

    -- If the command is defined in shared command functions, execute it
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- Handle RUN-specific commands
        if command == 'runes' then
            manage_runes()
        end

        -- Handle subjob-specific commands
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        elseif player.sub_job == 'WHM' then
            -- Handle WHM subjob commands if needed
        end
    end
end
