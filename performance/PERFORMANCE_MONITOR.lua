---============================================================================
--- FFXI GearSwap Core Module - Performance Monitoring System
---============================================================================
--- Production performance monitoring system with globally shared state
--- management. Provides real-time performance tracking, bottleneck detection,
--- and optimization recommendations for GearSwap operations.
---
--- @file core/performance_monitor.lua
--- @author Tetsouo
--- @version 2.1.2
--- @date Created: 2025-01-05 | Modified: 2025-08-09
--- @requires Windower FFXI
---
--- Features:
---   - Real-time operation timing and performance tracking
---   - Configurable warning and critical thresholds
---   - Comprehensive metrics collection and reporting
---   - Global state management for cross-module consistency
---   - Verbose logging for detailed performance analysis
---
--- @usage
---   local perf = require('core/PERFORMANCE_MONITOR')
---   perf.enable()
---   perf.track_operation('spell_cast', function() ... end)
---============================================================================

-- Use global variables to maintain state across requires
if not _G.PERF_MONITOR_STATE then
    _G.PERF_MONITOR_STATE = {
        enabled = false,
        verbose = false,
        warning_threshold = 50,
        critical_threshold = 100,
        metrics = {
            total_operations = 0,
            slow_operations = 0,
            critical_operations = 0,
            operations = {},
            session_start = os.time()
        }
    }
end

local PerformanceMonitor = {}

-- FFXI colors
local colors = {
    good = 030,     -- Green
    warning = 057,  -- Orange
    critical = 167, -- Red
    info = 050,     -- Yellow
    system = 160    -- Gray
}

---============================================================================
--- CORE FUNCTIONS
---============================================================================

--- Enable monitoring
function PerformanceMonitor.enable()
    _G.PERF_MONITOR_STATE.enabled = true
    _G.PERF_MONITOR_STATE.metrics.session_start = os.time()

    -- Clean professional header (ASCII only)
    windower.add_to_chat(050, "====================================")
    windower.add_to_chat(050, "    PERFORMANCE MONITORING")
    windower.add_to_chat(050, "====================================")
    windower.add_to_chat(030, "[ACTIVE] Monitoring now tracking:")
    windower.add_to_chat(001, "  - Equipment change times")
    windower.add_to_chat(001, "  - Spell and JA performance")
    windower.add_to_chat(001, "  - System response times")
    windower.add_to_chat(001, "")
    windower.add_to_chat(160, "Use '//gs c perf report' to view report")
    windower.add_to_chat(050, "====================================")
end

--- Disable monitoring
function PerformanceMonitor.disable()
    _G.PERF_MONITOR_STATE.enabled = false
    windower.add_to_chat(050, "====================================")
    windower.add_to_chat(050, "    PERFORMANCE MONITORING")
    windower.add_to_chat(050, "====================================")
    windower.add_to_chat(167, "[DISABLED] Monitoring stopped")
    windower.add_to_chat(160, "Collected data is preserved")
    windower.add_to_chat(160, "Use '//gs c perf report' to view final report")
    windower.add_to_chat(050, "====================================")
end

--- Toggle monitoring
function PerformanceMonitor.toggle()
    if _G.PERF_MONITOR_STATE.enabled then
        PerformanceMonitor.disable()
    else
        PerformanceMonitor.enable()
    end
    return _G.PERF_MONITOR_STATE.enabled
end

--- Reset metrics
function PerformanceMonitor.reset()
    _G.PERF_MONITOR_STATE.metrics = {
        total_operations = 0,
        slow_operations = 0,
        critical_operations = 0,
        operations = {},
        session_start = os.time()
    }
    windower.add_to_chat(colors.info, "[PERF] Metrics reset")
end

--- Start tracking an operation
function PerformanceMonitor.start_operation(operation_name)
    if not _G.PERF_MONITOR_STATE.enabled then
        return os.clock()
    end

    -- Initialize operation metrics if needed
    if not _G.PERF_MONITOR_STATE.metrics.operations[operation_name] then
        _G.PERF_MONITOR_STATE.metrics.operations[operation_name] = {
            count = 0,
            total_time = 0,
            max_time = 0,
            avg_time = 0
        }
    end

    return os.clock()
end

--- End tracking an operation
function PerformanceMonitor.end_operation(operation_name, start_time)
    if not _G.PERF_MONITOR_STATE.enabled or not start_time then
        return 0
    end

    local duration_ms = (os.clock() - start_time) * 1000
    local op = _G.PERF_MONITOR_STATE.metrics.operations[operation_name]

    if op then
        -- Update metrics
        op.count = op.count + 1
        op.total_time = op.total_time + duration_ms
        op.max_time = math.max(op.max_time, duration_ms)
        op.avg_time = op.total_time / op.count

        _G.PERF_MONITOR_STATE.metrics.total_operations = _G.PERF_MONITOR_STATE.metrics.total_operations + 1

        -- Check thresholds
        if duration_ms > _G.PERF_MONITOR_STATE.critical_threshold then
            _G.PERF_MONITOR_STATE.metrics.critical_operations = _G.PERF_MONITOR_STATE.metrics.critical_operations + 1
            if _G.PERF_MONITOR_STATE.verbose then
                windower.add_to_chat(colors.critical,
                    string.format("[PERF] CRITICAL: %s took %.1fms", operation_name, duration_ms))
            end
        elseif duration_ms > _G.PERF_MONITOR_STATE.warning_threshold then
            _G.PERF_MONITOR_STATE.metrics.slow_operations = _G.PERF_MONITOR_STATE.metrics.slow_operations + 1
            if _G.PERF_MONITOR_STATE.verbose then
                windower.add_to_chat(colors.warning,
                    string.format("[PERF] WARNING: %s took %.1fms", operation_name, duration_ms))
            end
        end
    end

    return duration_ms
end

--- Show performance report
function PerformanceMonitor.show_report()
    windower.add_to_chat(050, "=====================================")
    windower.add_to_chat(050, "     PERFORMANCE REPORT")
    windower.add_to_chat(050, "=====================================")

    if not _G.PERF_MONITOR_STATE.enabled then
        windower.add_to_chat(167, "[STOPPED] Monitoring is not active")
        windower.add_to_chat(160, "Use '//gs c perf enable' to activate it")
        windower.add_to_chat(050, "=====================================")
        return
    end

    local session_time = os.time() - _G.PERF_MONITOR_STATE.metrics.session_start
    local minutes = math.floor(session_time / 60)
    local seconds = session_time % 60

    windower.add_to_chat(030, "[ACTIVE] Session: " .. string.format("%dm %ds", minutes, seconds))
    windower.add_to_chat(001, "")

    -- General statistics
    windower.add_to_chat(050, "[STATISTICS]")
    windower.add_to_chat(001, "  Total operations: " .. _G.PERF_MONITOR_STATE.metrics.total_operations)
    windower.add_to_chat(160, "  (Each spell = precast + midcast + aftercast)")

    if _G.PERF_MONITOR_STATE.metrics.slow_operations > 0 then
        windower.add_to_chat(057,
            "  Slow operations: " ..
            _G.PERF_MONITOR_STATE.metrics.slow_operations .. " (>" .. _G.PERF_MONITOR_STATE.warning_threshold .. "ms)")
    else
        windower.add_to_chat(030, "  Slow operations: 0 (Excellent!)")
    end

    if _G.PERF_MONITOR_STATE.metrics.critical_operations > 0 then
        windower.add_to_chat(167,
            "  Critical operations: " ..
            _G.PERF_MONITOR_STATE.metrics.critical_operations ..
            " (>" .. _G.PERF_MONITOR_STATE.critical_threshold .. "ms)")
    else
        windower.add_to_chat(030, "  Critical operations: 0 (Perfect!)")
    end

    windower.add_to_chat(001, "")

    -- Operation details
    if _G.PERF_MONITOR_STATE.metrics.total_operations > 0 then
        windower.add_to_chat(050, "[SLOWEST OPERATIONS]")

        local sorted_ops = {}
        for name, data in pairs(_G.PERF_MONITOR_STATE.metrics.operations) do
            if data.count > 0 then
                table.insert(sorted_ops, { name = name, data = data })
            end
        end

        if #sorted_ops > 0 then
            table.sort(sorted_ops, function(a, b)
                return a.data.avg_time > b.data.avg_time
            end)

            for i = 1, math.min(5, #sorted_ops) do
                local op = sorted_ops[i]
                local color = 030 -- Green default
                local status = "OK"

                if op.data.avg_time > _G.PERF_MONITOR_STATE.critical_threshold then
                    color = 167 -- Red critical
                    status = "SLOW"
                elseif op.data.avg_time > _G.PERF_MONITOR_STATE.warning_threshold then
                    color = 057 -- Orange warning
                    status = "WARNING"
                end

                windower.add_to_chat(color, string.format("  %s [%s]: %.1fms avg (max %.1fms, %dx)",
                    op.name, status, op.data.avg_time, op.data.max_time, op.data.count))
            end
        else
            windower.add_to_chat(160, "  No operations recorded")
        end
    else
        windower.add_to_chat(050, "[TIPS]")
        windower.add_to_chat(160, "  - Test with: //gs c perf test")
        windower.add_to_chat(160, "  - Cast some spells/JAs")
        windower.add_to_chat(160, "  - Change equipment several times")
    end

    windower.add_to_chat(050, "=====================================")
end

--- Set verbose mode
function PerformanceMonitor.set_verbose(verbose)
    _G.PERF_MONITOR_STATE.verbose = verbose
    windower.add_to_chat(colors.info, string.format("[PERF] Verbose mode: %s",
        verbose and "ON" or "OFF"))
end

--- Get current status
function PerformanceMonitor.get_status()
    return {
        enabled = _G.PERF_MONITOR_STATE.enabled,
        verbose = _G.PERF_MONITOR_STATE.verbose,
        total_operations = _G.PERF_MONITOR_STATE.metrics.total_operations,
        slow_operations = _G.PERF_MONITOR_STATE.metrics.slow_operations,
        critical_operations = _G.PERF_MONITOR_STATE.metrics.critical_operations
    }
end

--- Debug function to check state
function PerformanceMonitor.debug_state()
    windower.add_to_chat(colors.info, "=== DEBUG STATE ===")
    windower.add_to_chat(colors.info, string.format("Global state exists: %s",
        tostring(_G.PERF_MONITOR_STATE ~= nil)))
    if _G.PERF_MONITOR_STATE then
        windower.add_to_chat(colors.info, string.format("Enabled: %s",
            tostring(_G.PERF_MONITOR_STATE.enabled)))
        windower.add_to_chat(colors.info, string.format("Verbose: %s",
            tostring(_G.PERF_MONITOR_STATE.verbose)))
        windower.add_to_chat(colors.info, string.format("Total ops: %d",
            _G.PERF_MONITOR_STATE.metrics.total_operations))
    end
    windower.add_to_chat(colors.info, "==================")
end

--- Monitor a function call
function PerformanceMonitor.monitor(operation_name, func, ...)
    local start = PerformanceMonitor.start_operation(operation_name)
    local result = { pcall(func, ...) }
    PerformanceMonitor.end_operation(operation_name, start)

    if result[1] then
        -- Success, return results (skip the success flag)
        return select(2, unpack(result))
    else
        -- Error, re-throw it
        error(result[2])
    end
end

return PerformanceMonitor
