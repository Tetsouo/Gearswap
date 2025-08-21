---============================================================================
--- FFXI GearSwap Error Handler - LIGHTWEIGHT VERSION (Post-Performance Fix)
---============================================================================
--- Ultra-lightweight error handling system designed for performance.
--- Minimal overhead, essential features only, no heavy initialization.
---
--- @file utils/error_handler_LIGHTWEIGHT.lua
--- @author Tetsouo
--- @version 2.0 (Lightweight)
--- @date Created: 2025-08-09 (Performance Recovery Version)
---============================================================================

local ErrorHandler = {}

-- Minimal severity levels (no complex tracking)
ErrorHandler.SEVERITY = {
    CRITICAL = "CRITICAL",
    ERROR = "ERROR",
    WARNING = "WARNING",
    INFO = "INFO"
}

-- Minimal categories (essential only)
ErrorHandler.CATEGORY = {
    SYSTEM = "SYSTEM",
    EQUIPMENT = "EQUIPMENT",
    SPELL = "SPELL"
}

-- Lightweight color mapping
local SEVERITY_COLORS = {
    CRITICAL = 167, -- Red
    ERROR = 167,    -- Red
    WARNING = 057,  -- Orange
    INFO = 050      -- Yellow
}

-- Minimal stats (no heavy tracking)
local error_stats = {
    total_errors = 0,
    recent_count = 0,
    max_recent = 10 -- Very limited to avoid overhead
}

---============================================================================
--- LIGHTWEIGHT ERROR HANDLING
---============================================================================

--- Lightweight error handler - minimal processing
--- @param module_name string Module reporting error
--- @param operation string Operation that failed
--- @param details string Error details
--- @param severity string Error severity (optional, defaults to ERROR)
--- @param category string Error category (optional, defaults to SYSTEM)
--- @param show_to_user boolean Show to user (optional, defaults to true)
function ErrorHandler.handle_error(module_name, operation, details, severity, category, show_to_user)
    -- Set defaults with minimal processing
    severity = severity or ErrorHandler.SEVERITY.ERROR
    category = category or ErrorHandler.CATEGORY.SYSTEM
    show_to_user = (show_to_user ~= false) -- Default true unless explicitly false

    -- Minimal stats update (lightweight)
    error_stats.total_errors = error_stats.total_errors + 1
    error_stats.recent_count = math.min(error_stats.recent_count + 1, error_stats.max_recent)

    -- Show to user only if requested and windower available
    if show_to_user and windower and windower.add_to_chat then
        local color = SEVERITY_COLORS[severity] or 167
        local message = string.format("[%s][%s] %s: %s",
            severity, module_name or "UNKNOWN", operation or "ERROR", details or "No details")
        windower.add_to_chat(color, message)
    end

    -- Minimal logging fallback (no external dependencies)
    if not windower then
        print(string.format("[%s] %s: %s - %s",
            severity, module_name or "UNKNOWN", operation or "ERROR", details or "No details"))
    end
end

--- Safe function execution wrapper - lightweight version
--- @param func function Function to execute safely
--- @param ... any Arguments to pass to function
--- @return boolean success, any result_or_error
function ErrorHandler.safe_call(func, ...)
    if type(func) ~= 'function' then
        return false, "Not a function"
    end

    local success, result = pcall(func, ...)

    if not success then
        -- Minimal error handling - don't recurse into heavy error processing
        error_stats.total_errors = error_stats.total_errors + 1
    end

    return success, result
end

--- Lightweight error recovery - minimal fallback strategies
--- @param error_context table Error context (ignored in lightweight version)
--- @param recovery_strategies table Recovery strategies (simplified)
--- @return boolean success
function ErrorHandler.attempt_recovery(error_context, recovery_strategies)
    -- Lightweight recovery - just return false to indicate no recovery attempted
    return false
end

--- Minimal error statistics (no heavy processing)
--- @return table Basic error stats
function ErrorHandler.get_error_statistics()
    return {
        total_errors = error_stats.total_errors,
        recent_count = error_stats.recent_count,
        lightweight_mode = true
    }
end

--- Lightweight error report - minimal output
function ErrorHandler.show_error_report()
    if windower and windower.add_to_chat then
        windower.add_to_chat(050, "=== ERROR REPORT (Lightweight) ===")
        windower.add_to_chat(001, string.format("Total errors: %d", error_stats.total_errors))
        windower.add_to_chat(001, string.format("Recent errors: %d", error_stats.recent_count))
        windower.add_to_chat(160, "Note: Lightweight mode - minimal tracking")
    else
        print("=== ERROR REPORT (Lightweight) ===")
        print(string.format("Total errors: %d", error_stats.total_errors))
        print(string.format("Recent errors: %d", error_stats.recent_count))
    end
end

--- Reset error statistics - lightweight
function ErrorHandler.reset_statistics()
    error_stats.total_errors = 0
    error_stats.recent_count = 0
end

--- Check if error handler is ready (always true for lightweight version)
--- @return boolean Always returns true
function ErrorHandler.is_ready()
    return true
end

--- Lightweight initialization (minimal overhead)
function ErrorHandler.initialize()
    -- Minimal initialization - just reset stats
    ErrorHandler.reset_statistics()
    return true
end

--- Shutdown handler (minimal cleanup)
function ErrorHandler.shutdown()
    -- No cleanup needed in lightweight version
    return true
end

-- Auto-initialize with minimal overhead
ErrorHandler.initialize()

return ErrorHandler
