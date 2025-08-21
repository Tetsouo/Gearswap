---============================================================================
--- FFXI GearSwap Core Module - Unified Macro & Lockstyle Manager
---============================================================================
--- Centralized and robust macro book and lockstyle management system.
--- Prevents spam, manages timing, and provides unified interface for all jobs.
---
--- @file core/macro_lockstyle_manager.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-19
---============================================================================

local MacroLockstyleManager = {}

-- State tracking to prevent spam and conflicts
local state = {
    last_job_change = 0,
    last_message = "",
    last_message_time = 0,
    dressup_state = "unknown", -- "loaded", "unloaded", "loading", "unknown"
    pending_changes = {},
    change_timer = nil,
    initialized = false,
    -- NEW: Debouncing system for multiple rapid changes
    pending_job_change = nil,
    job_change_timer = nil,
    scheduled_commands = {},  -- Track scheduled commands to cancel them
    last_processed_job = nil, -- Track last processed job to prevent spam
    -- NEW: Lockstyle tracking to prevent unnecessary applications
    last_lockstyle_applied = nil,
    last_lockstyle_time = 0,
    lockstyle_cooldown = 8,      -- FFXI lockstyle cooldown in seconds (increased from 5)
    lockstyle_executing = false, -- Execution lock to prevent simultaneous applications
    cancelled_timers = {},       -- Track cancelled timers to prevent their execution

    -- NEW SYSTEM - Intelligent job change sequence management
    job_sequence = {
        active = false,       -- Séquence en cours
        start_time = 0,       -- Début de séquence
        changes = {},         -- Historique des changements [{main_job, sub_job, timestamp}]
        final_main_job = nil, -- Job final détecté
        final_sub_job = nil,  -- Subjob final détecté
        debounce_timer = nil, -- Timer pour attendre fin de séquence
        timeout = 6,          -- Délai d'attente maximum (secondes)
        min_wait = 2          -- Attente minimum entre changements (secondes)
    }
}

-- Load configuration
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

---============================================================================
--- GESTION INTELLIGENTE DES SÉQUENCES DE CHANGEMENTS
---============================================================================

--- Get current timestamp
--- @return number Current timestamp
local function get_time()
    return os.time()
end

--- Debug logging (can be disabled by setting DEBUG to false)
--- @param message string Message to log
local function debug_log(message)
    -- Uncomment the line below to enable debug logging
    -- windower.add_to_chat(160, "[MacroManager Debug] " .. tostring(message))
end

--- Forward declarations
local execute_final_job_sequence
local execute_atomic_job_change
local manage_dressup
local apply_macro
local apply_lockstyle
local show_message
local get_job_configuration
local get_kaories_job

--- Démarre ou met à jour une séquence de changements de job
--- @param main_job string Job principal
--- @param sub_job string Subjob
--- @param silent boolean Afficher messages ou non
local function start_or_update_job_sequence(main_job, sub_job, silent)
    local current_time = get_time()

    -- Ajouter ce changement à l'historique
    table.insert(state.job_sequence.changes, {
        main_job = main_job,
        sub_job = sub_job,
        timestamp = current_time,
        silent = silent
    })

    -- Si c'est le premier changement, démarrer la séquence
    if not state.job_sequence.active then
        state.job_sequence.active = true
        state.job_sequence.start_time = current_time
        debug_log(string.format("SEQUENCE START: %s/%s", main_job, sub_job))
    else
        debug_log(string.format("SEQUENCE UPDATE: %s/%s", main_job, sub_job))
    end

    -- Mettre à jour les jobs finaux
    state.job_sequence.final_main_job = main_job
    state.job_sequence.final_sub_job = sub_job

    -- Annuler le timer précédent s'il existe
    if state.job_sequence.debounce_timer then
        coroutine.close(state.job_sequence.debounce_timer)
        state.job_sequence.debounce_timer = nil
    end

    -- Programmer l'exécution après le délai d'attente
    state.job_sequence.debounce_timer = coroutine.schedule(function()
        execute_final_job_sequence()
    end, state.job_sequence.min_wait)

    debug_log(string.format("SEQUENCE DEBOUNCE: Will execute %s/%s in %ds",
        main_job, sub_job, state.job_sequence.min_wait))
end

--- Exécute la séquence finale après que tous les changements sont terminés
execute_final_job_sequence = function()
    if not state.job_sequence.active then
        debug_log("SEQUENCE EXECUTE: No active sequence")
        return
    end

    local final_main = state.job_sequence.final_main_job
    local final_sub = state.job_sequence.final_sub_job
    local silent = false

    -- Determine if we should be silent (take the last silent parameter)
    if #state.job_sequence.changes > 0 then
        silent = state.job_sequence.changes[#state.job_sequence.changes].silent or false
    end

    debug_log(string.format("SEQUENCE EXECUTE: Final job %s/%s (silent: %s, changes: %d)",
        final_main, final_sub, tostring(silent), #state.job_sequence.changes))

    -- Nettoyer l'état de la séquence
    state.job_sequence.active = false
    state.job_sequence.changes = {}
    state.job_sequence.debounce_timer = nil
    state.job_sequence.final_main_job = nil
    state.job_sequence.final_sub_job = nil

    -- Exécuter le changement final ATOMIQUEMENT
    execute_atomic_job_change(final_main, final_sub, silent)
end

--- Exécute un changement de job de manière atomique (tout en une fois)
--- @param main_job string Job principal final
--- @param sub_job string Subjob final
--- @param silent boolean Afficher les messages
execute_atomic_job_change = function(main_job, sub_job, silent)
    debug_log(string.format("ATOMIC EXECUTE: Starting %s/%s", main_job, sub_job))

    -- ÉTAPE 1: Unload dressup immédiatement
    manage_dressup("unload")

    -- ÉTAPE 2: Attendre un peu puis appliquer macro + lockstyle
    coroutine.schedule(function()
        -- Get configuration
        local macro_book, macro_page, lockstyle = get_job_configuration(main_job, sub_job)

        if macro_book and macro_page then
            apply_macro(macro_book, macro_page)
            debug_log(string.format("ATOMIC: Applied macro %s/%s", macro_book, macro_page))
        end

        if lockstyle then
            apply_lockstyle(lockstyle)
            debug_log(string.format("ATOMIC: Applied lockstyle %s", lockstyle))
        end

        -- ÉTAPE 3: Message de confirmation
        if not silent then
            local selection_reason = string.format("%s/%s", main_job, sub_job)
            local kaories_job = get_kaories_job()
            if kaories_job then
                selection_reason = selection_reason .. " + " .. kaories_job
            end

            show_message(string.format('[Job Change] %s -> Macro Book %s%s',
                selection_reason,
                macro_book or 'N/A',
                lockstyle and (' + Lockstyle ' .. lockstyle) or ''))
        end

        -- ÉTAPE 4: Reload dressup après délai
        coroutine.schedule(function()
            manage_dressup("load")
            debug_log("ATOMIC: Reloaded dressup")
        end, 15) -- 15 secondes pour laisser le temps au lockstyle
    end, 2)      -- 2 secondes après unload dressup
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Lecture du job de Kaories depuis le fichier
--- @return string|nil Job de Kaories ou nil
get_kaories_job = function()
    local file = io.open('kaories_job.txt', 'r')
    if file then
        local job = file:read('*all')
        file:close()
        if job and job ~= '' then
            return job:gsub('%s+', '') -- Supprimer espaces
        end
    end
    return nil
end

--- Obtient la configuration (macro book/page + lockstyle) pour une combinaison de jobs
--- @param main_job string Job principal
--- @param sub_job string Subjob
--- @return number|nil, number|nil, number|nil macro_book, macro_page, lockstyle
get_job_configuration = function(main_job, sub_job)
    local kaories_job = get_kaories_job()

    -- Essayer d'abord la configuration dual-box
    local dual_config = config.get_dual_box_macro(main_job, sub_job, kaories_job)
    if dual_config then
        local lockstyle = config.get_lockstyle(main_job) or dual_config.lockstyle
        return dual_config.book, dual_config.page, lockstyle
    end

    -- Sinon configuration solo
    local solo_config = config.get_solo_macro(main_job, sub_job)
    if solo_config then
        local lockstyle = config.get_lockstyle(main_job) or solo_config.lockstyle
        return solo_config.book, solo_config.page, lockstyle
    end

    -- Fallback
    return 1, 1, config.get_lockstyle(main_job)
end

--- Check if enough time has passed since last action
--- @param min_delay number Minimum delay in seconds
--- @return boolean True if enough time passed
local function can_execute(min_delay)
    min_delay = min_delay or 5
    return (get_time() - state.last_job_change) >= min_delay
end

-- debug_log function already defined above

--- Cancel all pending scheduled commands
local function cancel_pending_commands()
    -- Note: Windower doesn't allow canceling scheduled commands, but we track them
    -- The best we can do is track and ignore old commands when they execute
    for i, cmd_id in ipairs(state.scheduled_commands) do
        debug_log("Marking command " .. cmd_id .. " as cancelled")
    end
    state.scheduled_commands = {}

    -- Cancel job change timer if it exists
    if state.job_change_timer then
        debug_log("Cancelling job change timer: " .. tostring(state.job_change_timer))
        -- Mark this timer as cancelled so it won't execute
        if state.cancelled_timers then
            state.cancelled_timers[state.job_change_timer] = true
        else
            state.cancelled_timers = {}
            state.cancelled_timers[state.job_change_timer] = true
        end
        state.job_change_timer = nil
    end
end

--- Schedule a command with cancellation tracking
--- @param func function Function to execute
--- @param delay number Delay in seconds
--- @return string Command ID for tracking
local function schedule_cancellable(func, delay)
    local cmd_id = "cmd_" .. os.time() .. "_" .. math.random(1000, 9999)
    table.insert(state.scheduled_commands, cmd_id)

    coroutine.schedule(function()
        -- Check if this command was cancelled
        local is_cancelled = true
        for _, active_id in ipairs(state.scheduled_commands) do
            if active_id == cmd_id then
                is_cancelled = false
                break
            end
        end

        if not is_cancelled then
            debug_log("Executing scheduled command: " .. cmd_id)
            func()
            -- Remove from tracking after execution
            for i, active_id in ipairs(state.scheduled_commands) do
                if active_id == cmd_id then
                    table.remove(state.scheduled_commands, i)
                    break
                end
            end
        else
            debug_log("Skipping cancelled command: " .. cmd_id)
        end
    end, delay)

    return cmd_id
end

--- Read Kaories job from file
--- @return string|nil The job name or nil if not found
local function read_kaories_job()
    local file = io.open('kaories_job.txt', 'r')
    if file then
        local job = file:read('*all')
        file:close()
        if job and job ~= '' then
            return job:gsub('%s+', '') -- Remove whitespace
        end
    end
    return nil
end

--- Get alt job from various sources
--- @return string|nil The detected alt job or nil
local function get_alt_job()
    local alt_name = config.get_alt_player():lower()
    local job_from_file = read_kaories_job()
    if job_from_file then
        return job_from_file
    end

    if _G.kaories_current_job then
        return _G.kaories_current_job
    end

    if DualBoxUtils and DualBoxUtils.alt_player_job then
        return DualBoxUtils.alt_player_job
    end

    return nil
end

---============================================================================
--- DRESSUP MANAGEMENT
---============================================================================

--- Manage dressup addon safely
--- @param action string "unload" or "load"
manage_dressup = function(action)
    if action == "unload" then
        state.dressup_state = "unloading"
        send_command('lua unload dressup')
        debug_log("Dressup unloaded")
    elseif action == "load" then
        state.dressup_state = "loading"
        send_command('lua load dressup')
        debug_log("Dressup loaded")
        -- Give time for dressup to load
        coroutine.schedule(function()
            state.dressup_state = "loaded"
        end, 3)
    end
end

---============================================================================
--- MACRO AND LOCKSTYLE APPLICATION
---============================================================================

--- Apply macro book and page
--- @param book number Macro book number
--- @param page number Macro page number
apply_macro = function(book, page)
    debug_log(string.format("Applying macro: book %d, page %d", book, page))
    send_command('input /macro book ' .. book)
    send_command('wait 1; input /macro set ' .. page)
end

--- Apply lockstyle with spam protection and cooldown respect
--- @param lockstyle_id number Lockstyle set ID
apply_lockstyle = function(lockstyle_id)
    if not lockstyle_id then
        debug_log("No lockstyle ID provided, skipping")
        return
    end

    -- CRITICAL: Execution lock to prevent simultaneous applications
    if state.lockstyle_executing then
        debug_log(string.format("Lockstyle execution already in progress, skipping %d", lockstyle_id))
        return
    end

    local current_time = get_time()

    -- Check if we already applied this lockstyle recently
    if state.last_lockstyle_applied == lockstyle_id then
        debug_log(string.format("Lockstyle %d already applied, skipping", lockstyle_id))
        return
    end

    -- Check FFXI cooldown
    if (current_time - state.last_lockstyle_time) < state.lockstyle_cooldown then
        local remaining = state.lockstyle_cooldown - (current_time - state.last_lockstyle_time)
        debug_log(string.format("Lockstyle cooldown active, waiting %.1f seconds", remaining))

        -- Schedule the lockstyle application after cooldown expires
        schedule_cancellable(function()
            apply_lockstyle(lockstyle_id)
        end, remaining + 0.5) -- Add small buffer
        return
    end

    -- Set execution lock
    state.lockstyle_executing = true
    debug_log(string.format("LOCKSTYLE EXECUTION LOCKED - Applying set %d", lockstyle_id))

    -- Apply the lockstyle
    send_command('input /lockstyleset ' .. lockstyle_id)

    -- Update tracking
    state.last_lockstyle_applied = lockstyle_id
    state.last_lockstyle_time = current_time

    -- Release execution lock after a safe delay
    schedule_cancellable(function()
        state.lockstyle_executing = false
        debug_log("LOCKSTYLE EXECUTION UNLOCKED")
    end, 5) -- 5 seconds should be enough for the command to process (increased from 2)
end

--- Display status message with spam prevention
--- @param message string Message to display
show_message = function(message)
    local current_time = get_time()

    -- Prevent duplicate messages within 5 seconds
    if message ~= state.last_message or (current_time - state.last_message_time) >= 5 then
        windower.add_to_chat(050, message)
        state.last_message = message
        state.last_message_time = current_time
        debug_log("Status message: " .. message)
    else
        debug_log("Message suppressed (duplicate): " .. message)
    end
end

---============================================================================
--- MAIN FUNCTIONS
---============================================================================

--- Update job settings with debouncing for multiple rapid changes
--- @param main_job string|nil Override main job (optional, defaults to player.main_job)
--- @param sub_job string|nil Override sub job (optional, defaults to player.sub_job)
--- @param silent boolean If true, suppress the status message
function MacroLockstyleManager.update_job_settings(main_job, sub_job, silent)
    -- Get job information
    main_job = main_job or (player and player.main_job) or 'THF'
    sub_job = sub_job or (player and player.sub_job) or 'WAR'

    debug_log(string.format("JOB CHANGE REQUEST: %s/%s (silent: %s)", main_job, sub_job, tostring(silent)))

    -- NEW SYSTEM: Handle via intelligent sequences
    -- Instead of blocking, add to sequence which will handle debouncing
    start_or_update_job_sequence(main_job, sub_job, silent)

    -- Return immediately - the sequence will handle the rest
    return 1, 1
end

--- DEPRECATED FUNCTION - Used only for backward compatibility
--- Execution is now handled via the sequence system
function MacroLockstyleManager.execute_job_change()
    if not state.pending_job_change then
        debug_log("No pending job change to execute")
        return
    end

    local job_data = state.pending_job_change
    local main_job = job_data.main_job
    local sub_job = job_data.sub_job
    local silent = job_data.silent

    debug_log(string.format("Executing job change: %s/%s", main_job, sub_job))

    -- Record job change timestamp
    state.last_job_change = get_time()

    -- IMPORTANT: Reset lockstyle tracking for job changes
    -- We want to apply the new job's lockstyle even if it's the same ID
    if state.last_processed_job and
        (state.last_processed_job.main_job ~= main_job or state.last_processed_job.sub_job ~= sub_job) then
        debug_log("Job changed, resetting lockstyle tracking")
        state.last_lockstyle_applied = nil
    end

    -- Get alt job
    local kaories_job = get_alt_job()

    -- Determine macro book and page
    local macro_book = 1
    local macro_page = 1
    local selection_reason = ""

    -- Check for dual-box configuration first
    local dual_config = config.get_dual_box_macro(main_job, sub_job, kaories_job)
    if dual_config then
        macro_book = dual_config.book
        macro_page = dual_config.page
        selection_reason = main_job .. "/" .. sub_job .. " + " .. kaories_job
    else
        -- Fall back to solo configurations
        local solo_config = config.get_solo_macro(main_job, sub_job)
        if solo_config then
            macro_book = solo_config.book
            macro_page = solo_config.page
            selection_reason = main_job ..
            "/" .. sub_job .. (kaories_job and " (Alt: " .. kaories_job .. " not configured)" or " (Solo)")
        else
            -- Ultimate fallback
            selection_reason = main_job .. "/" .. sub_job .. " (No configuration)"
        end
    end

    -- Get lockstyle
    local lockstyle = config.get_lockstyle(main_job)

    -- Manage dressup and apply changes with proper timing
    if not state.initialized then
        -- First time initialization
        manage_dressup("unload")

        -- Apply macro after dressup unload
        schedule_cancellable(function()
            apply_macro(macro_book, macro_page)
        end, 2)

        -- Apply lockstyle
        schedule_cancellable(function()
            apply_lockstyle(lockstyle)
        end, 3)

        -- Show message
        if not silent then
            schedule_cancellable(function()
                show_message('[Job Setup] ' ..
                selection_reason .. ' -> Macro Book ' .. macro_book .. (lockstyle and ' + Lockstyle ' .. lockstyle or ''))
            end, 4)
        end

        -- Reload dressup
        schedule_cancellable(function()
            manage_dressup("load")
        end, 20)

        state.initialized = true
    else
        -- Subsequent job changes - IMPROVED TIMING
        debug_log("Applying job change settings")

        -- STEP 1: Unload dressup first to prevent conflicts
        manage_dressup("unload")

        -- STEP 2: Apply macro after dressup unload
        schedule_cancellable(function()
            apply_macro(macro_book, macro_page)
        end, 1)

        -- STEP 3: Apply lockstyle BEFORE dressup reload (critical timing)
        schedule_cancellable(function()
            apply_lockstyle(lockstyle)
        end, 2)

        -- STEP 4: Show message
        if not silent then
            schedule_cancellable(function()
                show_message('[Job Change] ' ..
                selection_reason .. ' -> Macro Book ' .. macro_book .. (lockstyle and ' + Lockstyle ' .. lockstyle or ''))
            end, 3)
        end

        -- STEP 5: Reload dressup MUCH LATER to ensure lockstyle takes priority
        schedule_cancellable(function()
            manage_dressup("load")
        end, 10) -- Increased from immediate to 10 seconds
    end

    -- Track this job as processed to prevent immediate repeats
    state.last_processed_job = {
        main_job = main_job,
        sub_job = sub_job,
        timestamp = get_time()
    }

    -- Clear pending change
    state.pending_job_change = nil

    return macro_book, macro_page
end

--- Initialize the manager (called once on job load)
function MacroLockstyleManager.initialize()
    debug_log("Manager initializing...")
    state.initialized = false
    MacroLockstyleManager.update_job_settings(nil, nil, false)
end

--- Handle delayed macro commands
--- @param cmdParams table Command parameters [delayed_macro, page, book]
--- @return boolean True if command was handled
function MacroLockstyleManager.handle_delayed_macro(cmdParams)
    if cmdParams and cmdParams[1] == 'delayed_macro' then
        local macro_page = tonumber(cmdParams[2])
        local macro_book = tonumber(cmdParams[3])

        if macro_page and macro_book then
            apply_macro(macro_book, macro_page)
            return true
        end
    end
    return false
end

--- Stop all pending operations immediately (called from file_unload)
function MacroLockstyleManager.stop_all()
    debug_log("EMERGENCY STOP: Cancelling all pending operations")

    -- Cancel all scheduled commands
    cancel_pending_commands()

    -- Clear all pending changes
    state.pending_job_change = nil
    state.job_change_timer = nil

    -- Release any locks
    state.lockstyle_executing = false

    -- Clear execution state but keep tracking for next job
    state.initialized = false

    debug_log("All operations stopped successfully")
end

--- Reset manager state (for debugging)
function MacroLockstyleManager.reset()
    -- Cancel any pending operations first
    cancel_pending_commands()

    state = {
        last_job_change = 0,
        last_message = "",
        last_message_time = 0,
        dressup_state = "unknown",
        pending_changes = {},
        change_timer = nil,
        initialized = false,
        pending_job_change = nil,
        job_change_timer = nil,
        scheduled_commands = {},
        last_processed_job = nil,
        last_lockstyle_applied = nil,
        last_lockstyle_time = 0,
        lockstyle_cooldown = 8,
        lockstyle_executing = false,
        cancelled_timers = {}
    }
    debug_log("Manager state reset")
end

---============================================================================
--- EXPORTS
---============================================================================

return MacroLockstyleManager
