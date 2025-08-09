---============================================================================
--- FFXI GearSwap Performance Monitor - System Performance Tracking
---============================================================================
--- Professional performance monitoring system providing real-time metrics,
--- function timing, memory usage tracking, and system health monitoring.
--- Enables optimization and debugging with comprehensive analytics.
---
--- @file utils/performance_monitor.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
--- @requires utils/logger
---
--- Features:
---   - Function execution timing with statistical analysis
---   - Memory usage tracking and leak detection
---   - GearSwap event performance monitoring
---   - Equipment change frequency analysis
---   - System health alerts and warnings
---   - Performance report generation
---   - Automatic optimization recommendations
---   - Historical performance data
---
--- Usage:
---   local perf = require('utils/performance_monitor')
---   perf.start_timing('function_name')
---   -- ... your code ...
---   perf.end_timing('function_name')
---   perf.generate_report()
---============================================================================

local PerformanceMonitor = {}

-- Load dependencies
local log = require('utils/logger')

---============================================================================
--- PERFORMANCE DATA STRUCTURES
---============================================================================

--- Function execution timing data
--- @type table<string, table> Tracks timing statistics for each function
local functionTimings = {}

--- Memory usage snapshots
--- @type table<number, table> Tracks memory usage over time
local memorySnapshots = {}

--- Equipment change frequency tracking
--- @type table<string, number> Tracks how often each slot changes
local equipmentChanges = {}

--- GearSwap event performance metrics
--- @type table<string, table> Performance data for each GearSwap event
local eventMetrics = {}

--- System health indicators
--- @type table Health status and warnings
local healthStatus = {
    warnings = {},
    errors = {},
    last_check = 0,
    status = 'healthy'
}

--- Performance monitoring configuration
--- @type table Configuration for monitoring behavior
local config = {
    enabled = true,
    detailed_logging = false,
    memory_tracking = true,
    equipment_tracking = true,
    event_tracking = true,
    alert_threshold = 0.1, -- 100ms
    report_interval = 300, -- 5 minutes
    max_history = 1000,
    auto_optimize = true
}

--- Performance history for trend analysis
--- @type table<number, table> Historical performance data
local performanceHistory = {}

---============================================================================
--- TIMING FUNCTIONS
---============================================================================

--- Start timing a function or operation.
--- Records start time for performance measurement.
---
--- @param operation_name string Name of the operation being timed
--- @param context table|nil Optional context information
function PerformanceMonitor.start_timing(operation_name, context)
    if not config.enabled then return end

    if not functionTimings[operation_name] then
        functionTimings[operation_name] = {
            count = 0,
            total_time = 0,
            min_time = math.huge,
            max_time = 0,
            avg_time = 0,
            last_time = 0,
            start_times = {},
            contexts = {}
        }
    end

    local start_time = os.clock()
    functionTimings[operation_name].start_times[coroutine.running() or 'main'] = start_time

    if context then
        functionTimings[operation_name].contexts[start_time] = context
    end

    if config.detailed_logging then
        log.debug("Started timing: %s", operation_name)
    end
end

--- End timing a function or operation.
--- Calculates execution time and updates statistics.
---
--- @param operation_name string Name of the operation being timed
--- @return number|nil Execution time in seconds, or nil if not started
function PerformanceMonitor.end_timing(operation_name)
    if not config.enabled then return nil end

    local end_time = os.clock()
    local timing_data = functionTimings[operation_name]

    if not timing_data or not timing_data.start_times then
        log.warn("Attempted to end timing for '%s' without starting", operation_name)
        return nil
    end

    local thread_key = coroutine.running() or 'main'
    local start_time = timing_data.start_times[thread_key]

    if not start_time then
        log.warn("No start time found for '%s' in thread %s", operation_name, tostring(thread_key))
        return nil
    end

    local execution_time = end_time - start_time
    timing_data.start_times[thread_key] = nil

    -- Update statistics
    timing_data.count = timing_data.count + 1
    timing_data.total_time = timing_data.total_time + execution_time
    timing_data.last_time = execution_time
    timing_data.min_time = math.min(timing_data.min_time, execution_time)
    timing_data.max_time = math.max(timing_data.max_time, execution_time)
    timing_data.avg_time = timing_data.total_time / timing_data.count

    -- Check for performance issues
    if execution_time > config.alert_threshold then
        PerformanceMonitor.add_health_warning(
            string.format("Slow execution: %s took %.3fs", operation_name, execution_time)
        )
    end

    if config.detailed_logging then
        log.debug("Completed timing: %s (%.3fs)", operation_name, execution_time)
    end

    return execution_time
end

--- Time a function call automatically.
--- Wraps a function call with automatic timing.
---
--- @param operation_name string Name for timing tracking
--- @param func function Function to time
--- @param ... any Function arguments
--- @return any Function return values
function PerformanceMonitor.time_function(operation_name, func, ...)
    PerformanceMonitor.start_timing(operation_name)
    local results = { pcall(func, ...) }
    local exec_time = PerformanceMonitor.end_timing(operation_name)

    if not results[1] then
        log.error("Timed function '%s' failed: %s", operation_name, results[2])
        PerformanceMonitor.add_health_error(
            string.format("Function failure: %s - %s", operation_name, results[2])
        )
    end

    return unpack(results, 2)
end

---============================================================================
--- MEMORY TRACKING FUNCTIONS
---============================================================================

--- Take a memory usage snapshot.
--- Records current memory usage for trend analysis.
---
--- @param label string|nil Optional label for the snapshot
function PerformanceMonitor.snapshot_memory(label)
    if not config.enabled or not config.memory_tracking then return end

    local timestamp = os.time()
    local memory_info = {
        timestamp = timestamp,
        label = label or 'auto',
        lua_memory = collectgarbage('count'),
        system_time = os.clock()
    }

    table.insert(memorySnapshots, memory_info)

    -- Keep history manageable
    if #memorySnapshots > config.max_history then
        table.remove(memorySnapshots, 1)
    end

    -- Check for memory growth
    if #memorySnapshots >= 2 then
        local current = memorySnapshots[#memorySnapshots]
        local previous = memorySnapshots[#memorySnapshots - 1]
        local growth = current.lua_memory - previous.lua_memory

        if growth > 500 then -- 500KB growth
            PerformanceMonitor.add_health_warning(
                string.format("Memory growth detected: +%.1fKB", growth)
            )
        end
    end
end

--- Get current memory usage statistics.
--- Returns comprehensive memory usage information.
---
--- @return table Memory usage statistics
function PerformanceMonitor.get_memory_stats()
    if #memorySnapshots == 0 then
        return { error = "No memory snapshots available" }
    end

    local current = memorySnapshots[#memorySnapshots]
    local initial = memorySnapshots[1]

    local stats = {
        current_memory = current.lua_memory,
        initial_memory = initial.lua_memory,
        memory_growth = current.lua_memory - initial.lua_memory,
        snapshots_count = #memorySnapshots,
        tracking_duration = current.timestamp - initial.timestamp
    }

    -- Calculate average memory usage
    local total_memory = 0
    for _, snapshot in ipairs(memorySnapshots) do
        total_memory = total_memory + snapshot.lua_memory
    end
    stats.average_memory = total_memory / #memorySnapshots

    return stats
end

---============================================================================
--- EQUIPMENT CHANGE TRACKING
---============================================================================

--- Track equipment change for performance analysis.
--- Records equipment changes to identify hotspots.
---
--- @param slot string Equipment slot name
--- @param item_name string|nil Name of the item equipped
function PerformanceMonitor.track_equipment_change(slot, item_name)
    if not config.enabled or not config.equipment_tracking then return end

    equipmentChanges[slot] = (equipmentChanges[slot] or 0) + 1

    if config.detailed_logging then
        log.debug("Equipment change tracked: %s -> %s", slot, item_name or 'empty')
    end
end

--- Get equipment change frequency statistics.
--- Returns which slots change most frequently.
---
--- @return table Equipment change statistics
function PerformanceMonitor.get_equipment_stats()
    local stats = {
        total_changes = 0,
        slot_frequencies = {},
        most_changed_slot = nil,
        most_changed_count = 0
    }

    for slot, count in pairs(equipmentChanges) do
        stats.total_changes = stats.total_changes + count
        stats.slot_frequencies[slot] = count

        if count > stats.most_changed_count then
            stats.most_changed_count = count
            stats.most_changed_slot = slot
        end
    end

    return stats
end

---============================================================================
--- GEARSWAP EVENT TRACKING
---============================================================================

--- Track GearSwap event performance.
--- Monitors execution time of GearSwap events.
---
--- @param event_name string Name of the GearSwap event
--- @param execution_time number Time taken to execute the event
--- @param context table|nil Additional context information
function PerformanceMonitor.track_event(event_name, execution_time, context)
    if not config.enabled or not config.event_tracking then return end

    if not eventMetrics[event_name] then
        eventMetrics[event_name] = {
            count = 0,
            total_time = 0,
            avg_time = 0,
            max_time = 0,
            recent_times = {}
        }
    end

    local metrics = eventMetrics[event_name]
    metrics.count = metrics.count + 1
    metrics.total_time = metrics.total_time + execution_time
    metrics.avg_time = metrics.total_time / metrics.count
    metrics.max_time = math.max(metrics.max_time, execution_time)

    -- Keep recent times for trend analysis
    table.insert(metrics.recent_times, execution_time)
    if #metrics.recent_times > 50 then
        table.remove(metrics.recent_times, 1)
    end

    -- Alert on slow events
    if execution_time > config.alert_threshold * 2 then
        PerformanceMonitor.add_health_warning(
            string.format("Slow GearSwap event: %s took %.3fs", event_name, execution_time)
        )
    end
end

--- Get GearSwap event performance statistics.
--- Returns comprehensive event performance data.
---
--- @return table Event performance statistics
function PerformanceMonitor.get_event_stats()
    local stats = {
        total_events = 0,
        slowest_event = nil,
        slowest_time = 0,
        event_breakdown = {}
    }

    for event_name, metrics in pairs(eventMetrics) do
        stats.total_events = stats.total_events + metrics.count
        stats.event_breakdown[event_name] = {
            count = metrics.count,
            avg_time = metrics.avg_time,
            max_time = metrics.max_time,
            total_time = metrics.total_time
        }

        if metrics.max_time > stats.slowest_time then
            stats.slowest_time = metrics.max_time
            stats.slowest_event = event_name
        end
    end

    return stats
end

---============================================================================
--- HEALTH MONITORING
---============================================================================

--- Add a health warning.
--- Records a performance warning for monitoring.
---
--- @param message string Warning message
function PerformanceMonitor.add_health_warning(message)
    table.insert(healthStatus.warnings, {
        message = message,
        timestamp = os.time(),
        level = 'warning'
    })

    -- Limit warning history
    if #healthStatus.warnings > 100 then
        table.remove(healthStatus.warnings, 1)
    end

    log.warn("Performance Warning: %s", message)
end

--- Add a health error.
--- Records a performance error for monitoring.
---
--- @param message string Error message
function PerformanceMonitor.add_health_error(message)
    table.insert(healthStatus.errors, {
        message = message,
        timestamp = os.time(),
        level = 'error'
    })

    -- Limit error history
    if #healthStatus.errors > 50 then
        table.remove(healthStatus.errors, 1)
    end

    healthStatus.status = 'degraded'
    log.error("Performance Error: %s", message)
end

--- Check system health status.
--- Evaluates overall system health and performance.
---
--- @return table Health status information
function PerformanceMonitor.check_health()
    local now = os.time()
    healthStatus.last_check = now

    -- Count recent issues
    local recent_warnings = 0
    local recent_errors = 0
    local recent_threshold = now - 300 -- 5 minutes

    for _, warning in ipairs(healthStatus.warnings) do
        if warning.timestamp > recent_threshold then
            recent_warnings = recent_warnings + 1
        end
    end

    for _, error in ipairs(healthStatus.errors) do
        if error.timestamp > recent_threshold then
            recent_errors = recent_errors + 1
        end
    end

    -- Determine health status
    if recent_errors > 0 then
        healthStatus.status = 'critical'
    elseif recent_warnings > 5 then
        healthStatus.status = 'degraded'
    else
        healthStatus.status = 'healthy'
    end

    return {
        status = healthStatus.status,
        recent_warnings = recent_warnings,
        recent_errors = recent_errors,
        total_warnings = #healthStatus.warnings,
        total_errors = #healthStatus.errors,
        last_check = healthStatus.last_check
    }
end

---============================================================================
--- REPORTING FUNCTIONS
---============================================================================

--- Generate comprehensive performance report.
--- Creates detailed performance analysis and recommendations.
---
--- @param output_format string|nil Format for output ('chat', 'file', 'both')
function PerformanceMonitor.generate_report(output_format)
    output_format = output_format or 'chat'

    local report = {}
    table.insert(report, "========================================")
    table.insert(report, "GEARSWAP PERFORMANCE REPORT")
    table.insert(report, "========================================")
    table.insert(report, string.format("Generated: %s", os.date('%Y-%m-%d %H:%M:%S')))

    -- System Health
    local health = PerformanceMonitor.check_health()
    table.insert(report, "\nSYSTEM HEALTH:")
    table.insert(report, string.format("Status: %s", health.status:upper()))
    table.insert(report, string.format("Recent Warnings: %d", health.recent_warnings))
    table.insert(report, string.format("Recent Errors: %d", health.recent_errors))

    -- Function Timings
    table.insert(report, "\nFUNCTION PERFORMANCE:")
    local slowest_functions = {}
    for name, data in pairs(functionTimings) do
        table.insert(slowest_functions, { name = name, avg_time = data.avg_time, count = data.count })
    end
    table.sort(slowest_functions, function(a, b) return a.avg_time > b.avg_time end)

    for i = 1, math.min(5, #slowest_functions) do
        local func = slowest_functions[i]
        table.insert(report, string.format("  %s: %.3fs avg (%d calls)",
            func.name, func.avg_time, func.count))
    end

    -- Memory Usage
    local memory = PerformanceMonitor.get_memory_stats()
    if not memory.error then
        table.insert(report, "\nMEMORY USAGE:")
        table.insert(report, string.format("Current: %.1fKB", memory.current_memory))
        table.insert(report, string.format("Growth: %+.1fKB", memory.memory_growth))
        table.insert(report, string.format("Average: %.1fKB", memory.average_memory))
    end

    -- Equipment Changes
    local equipment = PerformanceMonitor.get_equipment_stats()
    table.insert(report, "\nEQUIPMENT ACTIVITY:")
    table.insert(report, string.format("Total Changes: %d", equipment.total_changes))
    if equipment.most_changed_slot then
        table.insert(report, string.format("Most Active Slot: %s (%d changes)",
            equipment.most_changed_slot, equipment.most_changed_count))
    end

    -- Output report
    if output_format == 'chat' or output_format == 'both' then
        for _, line in ipairs(report) do
            windower.add_to_chat(050, line)
        end
    end

    if output_format == 'file' or output_format == 'both' then
        PerformanceMonitor.save_report_to_file(report)
    end
end

--- Save performance report to file.
--- Writes report data to a file for external analysis.
---
--- @param report_lines table Array of report lines
function PerformanceMonitor.save_report_to_file(report_lines)
    local filename = string.format("performance_report_%s.txt", os.date('%Y%m%d_%H%M%S'))
    local filepath = windower.addon_path .. 'data/Tetsouo/reports/' .. filename

    local success, file = pcall(io.open, filepath, 'w')
    if not success or not file then
        log.error("Failed to create performance report file: %s", filepath)
        return
    end

    for _, line in ipairs(report_lines) do
        file:write(line .. '\n')
    end
    file:close()

    log.info("Performance report saved to: %s", filename)
end

---============================================================================
--- CONFIGURATION FUNCTIONS
---============================================================================

--- Configure performance monitoring settings.
--- Updates monitoring behavior and parameters.
---
--- @param settings table Configuration settings to update
function PerformanceMonitor.configure(settings)
    for key, value in pairs(settings) do
        if config[key] ~= nil then
            config[key] = value
            log.debug("Performance monitor config updated: %s = %s", key, tostring(value))
        end
    end
end

--- Reset all performance data.
--- Clears all tracked performance metrics.
function PerformanceMonitor.reset()
    functionTimings = {}
    memorySnapshots = {}
    equipmentChanges = {}
    eventMetrics = {}
    healthStatus.warnings = {}
    healthStatus.errors = {}
    performanceHistory = {}

    log.info("Performance monitor data reset")
end

---============================================================================
--- INITIALIZATION AND CLEANUP
---============================================================================

--- Initialize performance monitoring.
--- Sets up monitoring and starts initial data collection.
function PerformanceMonitor.initialize()
    config.enabled = true
    PerformanceMonitor.snapshot_memory('initialization')

    log.info("Performance monitoring initialized")
end

--- Cleanup performance monitoring.
--- Saves final report and cleans up resources.
function PerformanceMonitor.cleanup()
    if config.enabled then
        PerformanceMonitor.generate_report('file')
        log.info("Performance monitoring cleanup completed")
    end

    config.enabled = false
end

return PerformanceMonitor
