---============================================================================
--- FFXI GearSwap Messages - Job-Specific Message Loader
---============================================================================
--- Centralized loader for all job-specific message modules.
--- Replaces the monolithic MESSAGE_JOBS.lua with modular approach.
---
--- @file messages/MESSAGE_JOBS_LOADER.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/jobs/MESSAGE_*.lua
---============================================================================

local MessageJobsLoader = {}

-- Job modules mapping
local job_modules = {
    BRD = 'messages/jobs/MESSAGE_BRD',
    WAR = 'messages/jobs/MESSAGE_WAR',
    THF = 'messages/jobs/MESSAGE_THF',
    DNC = 'messages/jobs/MESSAGE_DNC',
    PLD = 'messages/jobs/MESSAGE_PLD',
    BLM = 'messages/jobs/MESSAGE_BLM',
    BST = 'messages/jobs/MESSAGE_BST',
    DRG = 'messages/jobs/MESSAGE_DRG',
    RUN = 'messages/jobs/MESSAGE_RUN'
}

-- Cache for loaded modules
local loaded_modules = {}

--- Load and cache a job-specific message module
-- @param job_code (string): 3-letter job code (BRD, WAR, etc.)
-- @return table|nil: Job message module or nil if failed
local function load_job_module(job_code)
    if not job_code then return nil end
    
    -- Return cached module if already loaded
    if loaded_modules[job_code] then
        return loaded_modules[job_code]
    end
    
    -- Get module path
    local module_path = job_modules[job_code:upper()]
    if not module_path then
        return nil
    end
    
    -- Load module with error handling
    local success, module = pcall(require, module_path)
    if success then
        loaded_modules[job_code] = module
        return module
    else
        windower.add_to_chat(167, '[MESSAGE_JOBS] Failed to load ' .. job_code .. ' messages: ' .. tostring(module))
        return nil
    end
end

--- Get a specific message function from a job module
-- @param job_code (string): 3-letter job code
-- @param function_name (string): Name of the message function
-- @return function|nil: Message function or nil if not found
function MessageJobsLoader.get_job_function(job_code, function_name)
    local module = load_job_module(job_code)
    if module and module[function_name] then
        return module[function_name]
    end
    return nil
end

--- Create a universal function that routes to job-specific implementations
-- @param function_name (string): Name of the function to route
-- @return function: Router function
function MessageJobsLoader.create_router(function_name)
    return function(...)
        local job_code = player and player.main_job or 'WAR'
        local job_function = MessageJobsLoader.get_job_function(job_code, function_name)
        
        if job_function then
            return job_function(...)
        else
            -- Fallback: try to find function in any loaded module
            for _, module in pairs(loaded_modules) do
                if module[function_name] then
                    return module[function_name](...)
                end
            end
            
            -- If no function found, silently fail (some functions are job-specific)
            return nil
        end
    end
end

--- Export all functions as direct module functions
-- This maintains compatibility with the MESSAGES.lua router system
function MessageJobsLoader.export_all_functions()
    -- List of all job-specific functions that need export
    local function_exports = {
        -- BRD functions
        'brd_song_list_message',
        'brd_singing_message', 
        'brd_rotation_complete_message',
        'brd_colored_message',
        'brd_message',
        'brd_spell_message',
        'brd_ja_message',
        'brd_debug_message',
        'brd_cooldown_message',
        'brd_song_cooldown_message',
        'brd_ws_message',
        'brd_song_rotation_with_separator',
        
        -- WAR functions
        'war_smartbuff_detection_message',
        'war_buff_execution_message',
        'war_shadows_message',
        'war_buff_active_message',
        'war_compact_status_message',
        'war_tp_message',
        
        -- THF functions
        'thf_theft_attempt_message',
        'thf_treasure_hunter_message',
        'thf_sync_message',
        'thf_spell_abort_message',
        'thf_combined_status_message',
        
        -- DNC functions
        'dnc_smartbuff_detection_message',
        'dnc_smartbuff_subjob_message',
        'dnc_buff_execution_message',
        
        -- PLD functions
        'pld_message',
        'pld_rune_message',
        
        -- BLM functions
        'blm_resource_error_message',
        'blm_spell_cooldown_message',
        'blm_buff_status_message',
        'blm_sync_message',
        'blm_alt_cast_message',
        'blm_element_message',
        
        -- BST functions
        'bst_resource_error_message',
        'bst_ecosystem_message',
        'bst_pet_selection_message',
        'bst_pet_not_found_message',
        'bst_broth_equipped_message',
        'bst_ammo_error_message',
        'bst_pet_info_message',
        'bst_ready_move_error_message',
        'bst_selection_info_message',
        
        -- DRG functions
        'drg_wyvern_status_message',
        'drg_jump_message',
        
        -- RUN functions
        'run_rune_status_message',
        'run_ward_message'
    }
    
    -- Create direct module functions for each export
    for _, func_name in ipairs(function_exports) do
        MessageJobsLoader[func_name] = MessageJobsLoader.create_router(func_name)
        -- Also export to global for backward compatibility
        _G[func_name] = MessageJobsLoader[func_name]
    end
end

--- Initialize the job message system
function MessageJobsLoader.initialize()
    -- Pre-load current job module if available
    if player and player.main_job then
        load_job_module(player.main_job)
    end
    
    -- Export all functions for both module access and global backward compatibility
    MessageJobsLoader.export_all_functions()
    
    windower.add_to_chat(030, '[MESSAGE_JOBS] Modular job message system initialized')
end

-- Auto-initialize when module is loaded
MessageJobsLoader.initialize()

return MessageJobsLoader