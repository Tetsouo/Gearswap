---============================================================================
--- FFXI GearSwap Simple Job Monitor
---============================================================================
--- Simple monitoring system for Kaories job changes via periodic checking
--- of the kaories_job.txt file
---
--- @file core/simple_job_monitor.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-16
---============================================================================

local SimpleJobMonitor = {}

-- State variables
local last_known_job = nil
local last_check_time = 0

---============================================================================
--- MONITORING FUNCTIONS
---============================================================================

--- Reads Kaories job from file
--- @return string|nil Job or nil
local function read_kaories_job()
    local file = io.open('kaories_job.txt', 'r')
    if not file then
        return nil
    end

    local job = file:read('*all')
    file:close()

    if job then
        job = job:gsub('%s+', '')
        return job ~= '' and job or nil
    end

    return nil
end

--- Checks and updates if necessary
function SimpleJobMonitor.check_and_update()
    local current_time = os.time()

    -- Limit checks (max 1 per second)
    if current_time - last_check_time < 1 then
        return
    end
    last_check_time = current_time

    local current_job = read_kaories_job()

    -- If job changed, trigger update
    if current_job and current_job ~= last_known_job then
        -- Trigger macro update directly (silent to avoid duplicate messages)
        local success_MacroCommands, MacroCommands = pcall(require, 'macros/MACRO_COMMANDS')
        if not success_MacroCommands then
            error("Failed to load macros/macro_commands: " .. tostring(MacroCommands))
        end
        if player and player.main_job then
            MacroCommands.handle_macro_command({ 'macros' }, nil, player.main_job, true)
        end

        last_known_job = current_job
    end
end

--- Initialize monitoring
function SimpleJobMonitor.init()
    -- Read initial state
    last_known_job = read_kaories_job()

    -- Hook into events for automatic checking
    local function hook_check()
        SimpleJobMonitor.check_and_update()
    end

    -- Check during job events
    windower.register_event('job change', hook_check)
    windower.register_event('status change', hook_check)
    windower.register_event('zone change', hook_check)

    -- Check periodically with simple timer
    local check_counter = 0
    windower.register_event('prerender', function()
        check_counter = check_counter + 1
        -- Check approximately every 3 seconds (90 frames at 30fps)
        if check_counter >= 90 then
            hook_check()
            check_counter = 0
        end
    end)
end

---============================================================================
--- AUTO-INITIALIZATION
---============================================================================

SimpleJobMonitor.init()

return SimpleJobMonitor
