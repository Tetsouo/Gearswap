---============================================================================
--- FFXI GearSwap Messages - Dynamic Message Router
---============================================================================
--- Dynamic message routing system that loads appropriate message modules
--- on-demand based on current job or request type. Provides backward
--- compatibility while enabling modular message organization.
---
--- @file utils/MESSAGES.lua
--- @author Tetsouo
--- @version 3.0
--- @date Created: 2025-01-05 | Refactored: 2025-08-20
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING, messages/MESSAGE_JOBS
---============================================================================

local MessageRouter = {}

-- Cache for loaded modules to improve performance
local module_cache = {
    core = nil,
    formatting = nil,
    jobs = nil
}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

--- Loads a message module with caching
-- @param module_name (string): Name of the module to load
-- @return (table): Loaded module or nil if failed
local function load_message_module(module_name)
    if module_cache[module_name] then
        return module_cache[module_name]
    end
    
    local module_path = 'messages/MESSAGE_' .. module_name:upper()
    local success, module = pcall(require, module_path)
    
    if success then
        module_cache[module_name] = module
        log.debug("[MessageRouter] Loaded %s module", module_name)
        return module
    else
        log.error("[MessageRouter] Failed to load %s: %s", module_name, tostring(module))
        return nil
    end
end

--- Gets the core message module
-- @return (table): Core message module
local function get_core_module()
    return load_message_module('core')
end

--- Gets the formatting module
-- @return (table): Formatting module
local function get_formatting_module()
    return load_message_module('formatting')
end

--- Gets the job-specific message module
-- @return (table): Job message module
local function get_jobs_module()
    return load_message_module('jobs')
end

-- ===========================================================================================================
--                                     Dynamic Function Routing
-- ===========================================================================================================

--- Creates a router function that delegates to the appropriate module
-- @param module_getter (function): Function that returns the target module
-- @param function_name (string): Name of the function to call
-- @return (function): Router function
local function create_router_function(module_getter, function_name)
    return function(...)
        local module = module_getter()
        if module and module[function_name] then
            return module[function_name](...)
        else
            log.error("[MessageRouter] Function %s not found in module", function_name)
            return nil
        end
    end
end

-- ===========================================================================================================
--                                     Core Message Functions
-- ===========================================================================================================

-- Universal message system
MessageRouter.universal_message = create_router_function(get_core_module, 'universal_message')
MessageRouter.unified_status_message = create_router_function(get_core_module, 'unified_status_message')
MessageRouter.status_message = create_router_function(get_core_module, 'status_message')
MessageRouter.success = create_router_function(get_core_module, 'success')
MessageRouter.error = create_router_function(get_core_module, 'error')
MessageRouter.warning = create_router_function(get_core_module, 'warning')
MessageRouter.info = create_router_function(get_core_module, 'info')
MessageRouter.magic = create_router_function(get_core_module, 'magic')

-- Utility functions
MessageRouter.show_separator = create_router_function(get_core_module, 'show_separator')
MessageRouter.grouped_message = create_router_function(get_core_module, 'grouped_message')
MessageRouter.add_to_chat_formatted = create_router_function(get_core_module, 'add_to_chat_formatted')
MessageRouter.multiline = create_router_function(get_core_module, 'multiline')
MessageRouter.job_message = create_router_function(get_core_module, 'job_message')
MessageRouter.timing = create_router_function(get_core_module, 'timing')
MessageRouter.state_change = create_router_function(get_core_module, 'state_change')
MessageRouter.buff_status = create_router_function(get_core_module, 'buff_status')
MessageRouter.insufficient_mp_message = create_router_function(get_core_module, 'insufficient_mp_message')
MessageRouter.cooldown_message = create_router_function(get_core_module, 'cooldown_message')
MessageRouter.incapacitated_message = create_router_function(get_core_module, 'incapacitated_message')
MessageRouter.spell_interrupted_message = create_router_function(get_core_module, 'spell_interrupted_message')

-- Legacy support
MessageRouter.create_formatted_message = create_router_function(get_core_module, 'create_formatted_message')

-- ===========================================================================================================
--                                     Formatting Functions
-- ===========================================================================================================

MessageRouter.format_recast_duration = create_router_function(get_formatting_module, 'format_recast_duration')
MessageRouter.format_time_value = create_router_function(get_formatting_module, 'format_time_value')
MessageRouter.create_color_code = create_router_function(get_formatting_module, 'create_color_code')
MessageRouter.create_separator = create_router_function(get_formatting_module, 'create_separator')
MessageRouter.format_job_name = create_router_function(get_formatting_module, 'format_job_name')
MessageRouter.format_ability_name = create_router_function(get_formatting_module, 'format_ability_name')
MessageRouter.format_status_message = create_router_function(get_formatting_module, 'format_status_message')
MessageRouter.format_colored_recast = create_router_function(get_formatting_module, 'format_colored_recast')

-- ===========================================================================================================
--                                     Job-Specific Message Functions
-- ===========================================================================================================

-- BRD functions
MessageRouter.brd_song_list_message = create_router_function(get_jobs_module, 'brd_song_list_message')
MessageRouter.brd_singing_message = create_router_function(get_jobs_module, 'brd_singing_message')
MessageRouter.brd_rotation_complete_message = create_router_function(get_jobs_module, 'brd_rotation_complete_message')
MessageRouter.brd_colored_message = create_router_function(get_jobs_module, 'brd_colored_message')
MessageRouter.brd_message = create_router_function(get_jobs_module, 'brd_message')
MessageRouter.brd_spell_message = create_router_function(get_jobs_module, 'brd_spell_message')
MessageRouter.brd_ja_message = create_router_function(get_jobs_module, 'brd_ja_message')
MessageRouter.brd_debug_message = create_router_function(get_jobs_module, 'brd_debug_message')
MessageRouter.brd_cooldown_message = create_router_function(get_jobs_module, 'brd_cooldown_message')
MessageRouter.brd_song_cooldown_message = create_router_function(get_jobs_module, 'brd_song_cooldown_message')
MessageRouter.brd_ws_message = create_router_function(get_jobs_module, 'brd_ws_message')
MessageRouter.brd_song_rotation_with_separator = create_router_function(get_jobs_module, 'brd_song_rotation_with_separator')

-- WAR functions
MessageRouter.war_smartbuff_detection_message = create_router_function(get_jobs_module, 'war_smartbuff_detection_message')
MessageRouter.war_buff_execution_message = create_router_function(get_jobs_module, 'war_buff_execution_message')
MessageRouter.war_buff_active_message = create_router_function(get_jobs_module, 'war_buff_active_message')
MessageRouter.war_compact_status_message = create_router_function(get_jobs_module, 'war_compact_status_message')
MessageRouter.war_tp_message = create_router_function(get_jobs_module, 'war_tp_message')
MessageRouter.war_shadows_message = create_router_function(get_jobs_module, 'war_shadows_message')

-- THF functions
MessageRouter.thf_theft_attempt_message = create_router_function(get_jobs_module, 'thf_theft_attempt_message')
MessageRouter.thf_treasure_hunter_message = create_router_function(get_jobs_module, 'thf_treasure_hunter_message')
MessageRouter.thf_sync_message = create_router_function(get_jobs_module, 'thf_sync_message')
MessageRouter.thf_spell_abort_message = create_router_function(get_jobs_module, 'thf_spell_abort_message')
MessageRouter.thf_combined_status_message = create_router_function(get_jobs_module, 'thf_combined_status_message')

-- DNC functions
MessageRouter.dnc_smartbuff_detection_message = create_router_function(get_jobs_module, 'dnc_smartbuff_detection_message')
MessageRouter.dnc_smartbuff_subjob_message = create_router_function(get_jobs_module, 'dnc_smartbuff_subjob_message')
MessageRouter.dnc_buff_execution_message = create_router_function(get_jobs_module, 'dnc_buff_execution_message')

-- PLD functions
MessageRouter.pld_message = create_router_function(get_jobs_module, 'pld_message')
MessageRouter.pld_rune_message = create_router_function(get_jobs_module, 'pld_rune_message')

-- BLM functions
MessageRouter.blm_resource_error_message = create_router_function(get_jobs_module, 'blm_resource_error_message')
MessageRouter.blm_spell_cooldown_message = create_router_function(get_jobs_module, 'blm_spell_cooldown_message')
MessageRouter.blm_buff_status_message = create_router_function(get_jobs_module, 'blm_buff_status_message')
MessageRouter.blm_sync_message = create_router_function(get_jobs_module, 'blm_sync_message')
MessageRouter.blm_alt_cast_message = create_router_function(get_jobs_module, 'blm_alt_cast_message')
MessageRouter.blm_element_message = create_router_function(get_jobs_module, 'blm_element_message')

-- BST functions
MessageRouter.bst_resource_error_message = create_router_function(get_jobs_module, 'bst_resource_error_message')
MessageRouter.bst_ecosystem_message = create_router_function(get_jobs_module, 'bst_ecosystem_message')
MessageRouter.bst_pet_selection_message = create_router_function(get_jobs_module, 'bst_pet_selection_message')
MessageRouter.bst_pet_not_found_message = create_router_function(get_jobs_module, 'bst_pet_not_found_message')
MessageRouter.bst_broth_equipped_message = create_router_function(get_jobs_module, 'bst_broth_equipped_message')
MessageRouter.bst_ammo_error_message = create_router_function(get_jobs_module, 'bst_ammo_error_message')
MessageRouter.bst_pet_info_message = create_router_function(get_jobs_module, 'bst_pet_info_message')
MessageRouter.bst_ready_move_error_message = create_router_function(get_jobs_module, 'bst_ready_move_error_message')
MessageRouter.bst_selection_info_message = create_router_function(get_jobs_module, 'bst_selection_info_message')

-- DRG functions
MessageRouter.drg_wyvern_status_message = create_router_function(get_jobs_module, 'drg_wyvern_status_message')
MessageRouter.drg_jump_message = create_router_function(get_jobs_module, 'drg_jump_message')

-- RUN functions
MessageRouter.run_rune_status_message = create_router_function(get_jobs_module, 'run_rune_status_message')
MessageRouter.run_ward_message = create_router_function(get_jobs_module, 'run_ward_message')

-- ===========================================================================================================
--                                     Legacy Compatibility Functions
-- ===========================================================================================================

--- Legacy function aliases for backward compatibility
MessageRouter.war_combined_status_message = MessageRouter.unified_status_message
MessageRouter.bst_combined_status_message = MessageRouter.unified_status_message
MessageRouter.createFormattedMessage = MessageRouter.create_formatted_message

--- Legacy BST cooldown message (specific implementation)
-- @param ability_name (string): Name of the ability
-- @param cooldown_time (number): Cooldown in seconds
function MessageRouter.bst_cooldown_message(ability_name, cooldown_time)
    return MessageRouter.cooldown_message(ability_name, cooldown_time)
end

--- Legacy DRG TP message
function MessageRouter.drg_tp_sufficient_message()
    MessageRouter.success("DRG", "You have enough TP after jumps!")
end

--- Legacy standardized job name function
function MessageRouter.get_standardized_job_name(override_job_name)
    local core = get_core_module()
    if core and core.get_standardized_job_name then
        return core.get_standardized_job_name(override_job_name)
    else
        -- Fallback implementation
        if override_job_name then
            return override_job_name
        end
        local main_job = player and player.main_job or 'JOB'
        local sub_job = player and player.sub_job
        if sub_job and sub_job ~= 'NON' and sub_job ~= '' then
            return main_job .. '/' .. sub_job
        else
            return main_job
        end
    end
end

-- ===========================================================================================================
--                                     Color Constants Access
-- ===========================================================================================================

--- Provides access to color constants from formatting module
function MessageRouter.get_colors()
    local formatting = get_formatting_module()
    if formatting and formatting.STANDARD_COLORS then
        return formatting.STANDARD_COLORS
    else
        return {}
    end
end

-- Export colors for compatibility
local formatting_module = get_formatting_module()
if formatting_module and formatting_module.STANDARD_COLORS then
    MessageRouter.STANDARD_COLORS = formatting_module.STANDARD_COLORS
    MessageRouter.colors = formatting_module.colors or {}
end

-- ===========================================================================================================
--                                     Global Exports for Backward Compatibility
-- ===========================================================================================================

-- Export all functions globally for backward compatibility
_G.universal_message = MessageRouter.universal_message
_G.unified_status_message = MessageRouter.unified_status_message
_G.status_message = MessageRouter.status_message
_G.add_to_chat_formatted = MessageRouter.add_to_chat_formatted
_G.format_recast_duration = MessageRouter.format_recast_duration
_G.create_color_code = MessageRouter.create_color_code
_G.createFormattedMessage = MessageRouter.createFormattedMessage
_G.get_standardized_job_name = MessageRouter.get_standardized_job_name
_G.spell_interrupted_message = MessageRouter.spell_interrupted_message
_G.multiline = MessageRouter.multiline

-- Export job-specific functions
_G.brd_song_list_message = MessageRouter.brd_song_list_message
_G.brd_colored_message = MessageRouter.brd_colored_message
_G.brd_message = MessageRouter.brd_message
_G.brd_spell_message = MessageRouter.brd_spell_message
_G.brd_ja_message = MessageRouter.brd_ja_message
_G.brd_debug_message = MessageRouter.brd_debug_message
_G.brd_cooldown_message = MessageRouter.brd_cooldown_message
_G.brd_song_cooldown_message = MessageRouter.brd_song_cooldown_message
_G.brd_ws_message = MessageRouter.brd_ws_message
_G.brd_song_rotation_with_separator = MessageRouter.brd_song_rotation_with_separator
_G.war_smartbuff_detection_message = MessageRouter.war_smartbuff_detection_message
_G.war_buff_execution_message = MessageRouter.war_buff_execution_message
_G.war_buff_active_message = MessageRouter.war_buff_active_message
_G.war_compact_status_message = MessageRouter.war_compact_status_message
_G.war_tp_message = MessageRouter.war_tp_message
_G.thf_theft_attempt_message = MessageRouter.thf_theft_attempt_message
_G.thf_spell_abort_message = MessageRouter.thf_spell_abort_message
_G.thf_combined_status_message = MessageRouter.thf_combined_status_message
_G.dnc_smartbuff_detection_message = MessageRouter.dnc_smartbuff_detection_message
_G.dnc_smartbuff_subjob_message = MessageRouter.dnc_smartbuff_subjob_message
_G.dnc_buff_execution_message = MessageRouter.dnc_buff_execution_message
_G.pld_message = MessageRouter.pld_message
_G.pld_rune_message = MessageRouter.pld_rune_message
_G.blm_resource_error_message = MessageRouter.blm_resource_error_message
_G.blm_spell_cooldown_message = MessageRouter.blm_spell_cooldown_message
_G.blm_sync_message = MessageRouter.blm_sync_message
_G.blm_alt_cast_message = MessageRouter.blm_alt_cast_message
_G.blm_element_message = MessageRouter.blm_element_message
_G.bst_resource_error_message = MessageRouter.bst_resource_error_message
_G.bst_ecosystem_message = MessageRouter.bst_ecosystem_message
_G.bst_pet_selection_message = MessageRouter.bst_pet_selection_message
_G.bst_cooldown_message = MessageRouter.bst_cooldown_message
_G.drg_tp_sufficient_message = MessageRouter.drg_tp_sufficient_message

log.info("[MessageRouter] Dynamic message routing system initialized")

return MessageRouter