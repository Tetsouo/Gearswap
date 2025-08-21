---============================================================================
--- FFXI GearSwap Core Module - Windower Event Performance Hooks
---============================================================================
--- Direct Windower event monitoring system that captures comprehensive
--- performance data from all Windower activities. Provides low-level
--- event tracking for detailed performance analysis and bottleneck detection.
---
--- @file core/performance_windower_hooks.lua
--- @author Tetsouo
--- @version 2.1.4
--- @date Created: 2025-01-05 | Modified: 2025-08-09
--- @requires core/performance_monitor.lua
--- @requires Windower FFXI
---
--- Features:
---   - Direct Windower event interception and timing
---   - Comprehensive activity capture and analysis
---   - Low-level performance monitoring capabilities
---   - Event-driven performance metrics collection
---   - Minimal overhead event processing
---
--- @usage
---   local hooks = require('core/PERFORMANCE_WINDOWER_HOOKS')
---   hooks.enable_event_monitoring()
---============================================================================

--- @class WindowerHooks Windower event performance monitoring system
local WindowerHooks = {}

-- Load the monitoring
local success_PerfMon, PerfMon = pcall(require, 'performance/PERFORMANCE_MONITOR')
if not success_PerfMon then
    error("Failed to load performance/performance_monitor: " .. tostring(PerfMon))
end

-- Windower hooks state
local windower_hooks_active = false
local registered_events = {}

-- Store original Windower functions
local original_windower = {}

---============================================================================
--- HOOK WINDOWER EVENTS
---============================================================================

--- Hook basic Windower events
local function hook_windower_events()
    if not windower then
        return false, "Windower not available"
    end

    -- Hook windower.send_command to capture ALL commands
    if not original_windower.send_command then
        original_windower.send_command = windower.send_command
        windower.send_command = function(command)
            local start = PerfMon.start_operation("windower_command")

            -- Log the command for debug
            if command and command:find("gs ") then
                local start_gs = PerfMon.start_operation("gs_command_" .. (command:match("gs c (%w+)") or "unknown"))
                local result = original_windower.send_command(command)
                PerfMon.end_operation("gs_command_" .. (command:match("gs c (%w+)") or "unknown"), start_gs)
                PerfMon.end_operation("windower_command", start)
                return result
            else
                local result = original_windower.send_command(command)
                PerfMon.end_operation("windower_command", start)
                return result
            end
        end
    end

    return true, "Windower hooks installed"
end

--- Hook event registration functions
local function hook_event_registration()
    if not windower or not windower.register_event then
        return false, "Windower events not available"
    end

    -- Hook windower.register_event to intercept all events
    if not original_windower.register_event then
        original_windower.register_event = windower.register_event
        windower.register_event = function(event_name, callback)
            -- Wrap the callback for monitoring
            local wrapped_callback = function(...)
                local start = PerfMon.start_operation("event_" .. tostring(event_name))
                local result = { callback(...) }
                PerfMon.end_operation("event_" .. tostring(event_name), start)
                return unpack(result)
            end

            -- Register the original event with wrapped callback
            return original_windower.register_event(event_name, wrapped_callback)
        end
    end

    return true, "Event registration hooked"
end

---============================================================================
--- DIRECT PACKET MONITORING
---============================================================================

--- Monitor incoming/outgoing packets
local function setup_packet_monitoring()
    -- Monitor outgoing actions (spells, abilities, etc.)
    windower.register_event('outgoing chunk', function(id, data)
        if id == 0x01A then -- Action packet
            local start = PerfMon.start_operation("outgoing_action")
            -- Processing is done by GearSwap, we just measure the time
            coroutine.wrap(function()
                coroutine.yield()
                PerfMon.end_operation("outgoing_action", start)
            end)()
        elseif id == 0x037 then -- Spell cast
            PerfMon.start_operation("spell_cast_packet")
        end
    end)

    -- Monitor incoming actions (server confirmation)
    windower.register_event('incoming chunk', function(id, data)
        if id == 0x028 then -- Action message
            PerfMon.end_operation("spell_cast_packet", os.clock())
        end
    end)
end

--- Monitor equipment changes via packets
local function setup_equipment_monitoring()
    windower.register_event('incoming chunk', function(id, data)
        if id == 0x050 then -- Equipment change packet
            local start = PerfMon.start_operation("equipment_change")
            -- Delay to let GearSwap process
            coroutine.wrap(function()
                coroutine.yield()
                PerfMon.end_operation("equipment_change", start)
            end)()
        end
    end)
end

--- Monitor status changes
local function setup_status_monitoring()
    windower.register_event('status change', function(new_status_id)
        local start = PerfMon.start_operation("status_change_" .. tostring(new_status_id))
        PerfMon.end_operation("status_change_" .. tostring(new_status_id), start)
    end)
end

---============================================================================
--- SIMPLE TIMER-BASED MONITORING
---============================================================================

--- Monitoring by sampling every second
local function setup_sampling_monitoring()
    windower.register_event('prerender', function()
        -- Sample every 60 frames (about 1 second at 60fps)
        if math.random(1, 60) == 1 then
            local start = PerfMon.start_operation("game_frame_sample")
            PerfMon.end_operation("game_frame_sample", start)
        end
    end)
end

---============================================================================
--- AGGRESSIVE MONITORING - FORCE CAPTURE
---============================================================================

--- Force capture by simulating operations based on activity
local function setup_aggressive_monitoring()
    local last_check = os.time()
    local last_zone = world and world.area
    local last_hp = player and player.hp
    local last_mp = player and player.mp
    local last_tp = player and player.tp

    windower.register_event('prerender', function()
        local now = os.time()

        -- Check every 2 seconds
        if now - last_check >= 2 then
            last_check = now

            local start = PerfMon.start_operation("activity_check")

            -- Detect activity changes
            local current_zone = world and world.area
            local current_hp = player and player.hp
            local current_mp = player and player.mp
            local current_tp = player and player.tp

            if current_zone ~= last_zone then
                local zone_start = PerfMon.start_operation("zone_change")
                PerfMon.end_operation("zone_change", zone_start)
                last_zone = current_zone
            end

            if current_hp ~= last_hp then
                local hp_start = PerfMon.start_operation("hp_change")
                PerfMon.end_operation("hp_change", hp_start)
                last_hp = current_hp
            end

            if current_mp ~= last_mp then
                local mp_start = PerfMon.start_operation("mp_change")
                PerfMon.end_operation("mp_change", mp_start)
                last_mp = current_mp
            end

            if current_tp ~= last_tp then
                local tp_start = PerfMon.start_operation("tp_change")
                PerfMon.end_operation("tp_change", tp_start)
                last_tp = current_tp
            end

            PerfMon.end_operation("activity_check", start)
        end
    end)
end

---============================================================================
--- PUBLIC FUNCTIONS
---============================================================================

--- Install aggressive Windower monitoring
function WindowerHooks.install_aggressive_monitoring()
    windower.add_to_chat(050, "[PERF] Installing AGGRESSIVE Windower monitoring...")

    local success_count = 0
    local error_messages = {}

    -- Try all monitoring types
    local success, msg = hook_windower_events()
    if success then success_count = success_count + 1 else table.insert(error_messages, msg) end

    success, msg = hook_event_registration()
    if success then success_count = success_count + 1 else table.insert(error_messages, msg) end

    -- Setup specialized events
    local event_success = pcall(setup_packet_monitoring)
    if event_success then success_count = success_count + 1 else table.insert(error_messages, "Packet monitoring failed") end

    event_success = pcall(setup_equipment_monitoring)
    if event_success then
        success_count = success_count + 1
    else
        table.insert(error_messages,
            "Equipment monitoring failed")
    end

    event_success = pcall(setup_status_monitoring)
    if event_success then success_count = success_count + 1 else table.insert(error_messages, "Status monitoring failed") end

    event_success = pcall(setup_sampling_monitoring)
    if event_success then
        success_count = success_count + 1
    else
        table.insert(error_messages,
            "Sampling monitoring failed")
    end

    event_success = pcall(setup_aggressive_monitoring)
    if event_success then
        success_count = success_count + 1
    else
        table.insert(error_messages,
            "Aggressive monitoring failed")
    end

    windower_hooks_active = true

    windower.add_to_chat(030, string.format("[PERF] %d monitoring systems installed", success_count))

    if #error_messages > 0 then
        windower.add_to_chat(057, "[PERF] Some monitoring failed:")
        for _, err in ipairs(error_messages) do
            windower.add_to_chat(160, "  " .. err)
        end
    end

    windower.add_to_chat(030, "[PERF] Aggressive monitoring active - try playing for 30 seconds then check report")

    return success_count > 0
end

--- Force generation of test operations
function WindowerHooks.force_test_operations()
    windower.add_to_chat(050, "[PERF] Forcing test operations...")

    -- Generate multiple operation types with different timings
    local operations = {
        { "fast_operation",     10 },
        { "medium_operation",   35 },
        { "slow_operation",     75 },
        { "critical_operation", 120 }
    }

    for _, op_data in ipairs(operations) do
        local op_name, duration = op_data[1], op_data[2]
        local start = PerfMon.start_operation(op_name)

        -- Simulate work
        local work_start = os.clock()
        while (os.clock() - work_start) * 1000 < duration do
            -- Busy wait
        end

        PerfMon.end_operation(op_name, start)
    end

    windower.add_to_chat(030, string.format("[PERF] Generated %d test operations", #operations))
end

--- Show monitoring status
function WindowerHooks.show_status()
    windower.add_to_chat(050, "=== WINDOWER MONITORING STATUS ===")
    windower.add_to_chat(001,
        string.format("Aggressive monitoring: %s", windower_hooks_active and "ACTIVE" or "INACTIVE"))
    windower.add_to_chat(001, string.format("Windower hooks: %d", table.getn(original_windower)))

    if windower_hooks_active then
        windower.add_to_chat(030, "OK Packet monitoring")
        windower.add_to_chat(030, "OK Equipment monitoring")
        windower.add_to_chat(030, "OK Status monitoring")
        windower.add_to_chat(030, "OK Sampling monitoring")
        windower.add_to_chat(030, "OK Activity monitoring")
    else
        windower.add_to_chat(160, "Monitoring not active")
        windower.add_to_chat(001, "Use: //gs c perf aggressive")
    end

    windower.add_to_chat(050, "==================================")
end

return WindowerHooks
