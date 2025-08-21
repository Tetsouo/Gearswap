---============================================================================
--- FFXI GearSwap Utility Module - Professional Logging System
---============================================================================
--- Advanced logging framework providing structured, configurable logging
--- with multiple severity levels, color coding, and performance monitoring.
--- Designed for development, debugging, and production monitoring.
---
--- @file utils/logger.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05
--- @date Modified: 2025-08-05
--- @requires config/config.lua
--- @requires Windower FFXI
---
--- Features:
---   - Four logging levels: ERROR, WARN, INFO, DEBUG
---   - Configurable color-coded output for different severity levels
---   - Optional timestamp display for chronological debugging
---   - Table introspection and recursive structure logging
---   - Function execution timing and performance monitoring
---   - Safe function execution with automatic error logging
---   - Instance-based loggers with individual configurations
---   - Default logger for immediate use
---   - printf-style formatted string support
---
--- Usage:
---   local log = require('utils/LOGGER')
---
---   -- Using default logger
---   log.info('Player health: %d%%', player.hp/player.max_hp*100)
---   log.error('Failed to cast %s', spell.name)
---   log.table(equipment, 'Current Equipment')
---
---   -- Creating custom logger
---   local custom_log = log.Logger.new('MyModule')
---   custom_log:debug('Module initialized')
---
---   -- Performance monitoring
---   local result = log.timed('spell_cast', cast_spell, spell_name)
---
---   -- Safe execution
---   log.safe_call('equip_gear', equip, gear_set)
---
--- Thread Safety:
---   Logger instances are thread-safe for read operations.
---   Configuration changes require reloading the module.
---============================================================================

---============================================================================
--- LOGGER CLASS DEFINITION
---============================================================================

--- @class Logger Professional logging class with configurable output
--- @field name string Logger instance name for identification
--- @field level number Current logging level threshold
--- @field enabled boolean Whether logging is enabled
--- @field show_timestamps boolean Whether to include timestamps in output
--- @field colors table Color mapping for different log levels
local Logger = {}
Logger.__index = Logger

--- @type table Configuration module for logger settings
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

--- Numeric log level definitions for severity comparison
--- @type table<string, number> Mapping of level names to numeric values
Logger.levels = {
    ERROR = 1, -- Critical errors that may break functionality
    WARN = 2,  -- Warning conditions that should be addressed
    INFO = 3,  -- General informational messages
    DEBUG = 4  -- Detailed debugging information
}

---============================================================================
--- LOGGER INSTANCE MANAGEMENT
---============================================================================

--- Create a new logger instance with custom configuration.
--- Each logger can have independent settings while sharing the
--- same underlying logging infrastructure.
---
--- @param name string|nil Optional logger name for identification (default: 'GearSwap')
--- @return Logger New logger instance
--- @usage
---   local module_log = Logger.new('Weaponskill')
---   module_log:info('Module loaded successfully')
function Logger.new(name)
    local self = setmetatable({}, Logger)
    self.name = name or 'GearSwap'
    self.level = config.get_debug_level() or Logger.levels.INFO
    self.enabled = config.is_debug_enabled()
    self.show_timestamps = config.get('ui.messages.show_timestamps') or false

    -- Color mapping from config
    self.colors = {
        ERROR = config.get_color('error'),
        WARN = config.get_color('warning'),
        INFO = config.get_color('info'),
        DEBUG = config.get_color('debug')
    }

    return self
end

---============================================================================
--- MESSAGE FORMATTING METHODS
---============================================================================

--- Generate timestamp string for log messages.
--- Timestamp format is configurable via settings and only included
--- when explicitly enabled.
---
--- @return string Formatted timestamp string or empty string
function Logger:get_timestamp()
    if self.show_timestamps then
        return os.date("[%H:%M:%S] ")
    end
    return ""
end

--- Format a log message with appropriate color and prefix.
--- Creates a consistent message format across all log levels
--- with configurable color coding.
---
--- @param level string Log level name (ERROR, WARN, INFO, DEBUG)
--- @param message string The message content to format
--- @return string Fully formatted message ready for output
function Logger:format_message(level, message)
    local color = self.colors[level] or 050
    local prefix = string.format("[%s][%s]", self.name, level)
    local timestamp = self:get_timestamp()

    return string.format("%s%s %s", timestamp, prefix, message)
end

---============================================================================
--- CORE LOGGING FUNCTIONALITY
---============================================================================

--- Core logging method that handles level filtering and message output.
--- Performs all necessary checks, formatting, and output operations
--- with robust error handling for format string issues.
---
--- @param level string Log level name (ERROR, WARN, INFO, DEBUG)
--- @param message string Message template (supports printf-style formatting)
--- @param ... any Additional arguments for string formatting
function Logger:log(level, message, ...)
    -- Check if logging is enabled and level is appropriate
    if not self.enabled and Logger.levels[level] > Logger.levels.ERROR then
        return
    end

    if self.level < Logger.levels[level] then
        return
    end

    -- Format message with any additional arguments
    if select('#', ...) > 0 then
        local success, formatted = pcall(string.format, message, ...)
        if success then
            message = formatted
        else
            message = message .. " (format error)"
        end
    end

    -- Output to chat
    local formatted_msg = self:format_message(level, message)
    local color = self.colors[level] or 050

    windower.add_to_chat(color, formatted_msg)

    -- For errors, also print to console
    if level == 'ERROR' then
        print(formatted_msg)
    end
end

---============================================================================
--- CONVENIENCE LOGGING METHODS
---============================================================================

--- Log an error message.
--- Error messages are always output regardless of debug settings
--- and are additionally printed to the console.
---
--- @param message string Error message template
--- @param ... any Arguments for string formatting
function Logger:error(message, ...)
    self:log('ERROR', message, ...)
end

--- Log a warning message.
--- Warning messages indicate potential issues that should be addressed.
---
--- @param message string Warning message template
--- @param ... any Arguments for string formatting
function Logger:warn(message, ...)
    self:log('WARN', message, ...)
end

--- Log an informational message.
--- Informational messages provide general status and operational updates.
---
--- @param message string Info message template
--- @param ... any Arguments for string formatting
function Logger:info(message, ...)
    self:log('INFO', message, ...)
end

--- Log a debug message.
--- Debug messages provide detailed information for troubleshooting
--- and are only output when debug mode is enabled.
---
--- @param message string Debug message template
--- @param ... any Arguments for string formatting
function Logger:debug(message, ...)
    self:log('DEBUG', message, ...)
end

---============================================================================
--- ADVANCED LOGGING UTILITIES
---============================================================================

--- Log the complete structure of a table with recursive descent.
--- Provides detailed inspection of complex data structures with
--- configurable depth limiting to prevent infinite recursion.
---
--- @param tbl table The table to inspect and log
--- @param name string|nil Optional name for the table (default: 'table')
--- @param max_depth number|nil Maximum recursion depth (default: 3)
function Logger:table(tbl, name, max_depth)
    if type(tbl) ~= 'table' then
        self:debug("%s is not a table (type: %s)", name or 'value', type(tbl))
        return
    end

    max_depth = max_depth or 3
    local function log_table_recursive(t, depth, prefix)
        if depth > max_depth then
            self:debug("%s... (max depth reached)", prefix)
            return
        end

        for k, v in pairs(t) do
            local key_str = tostring(k)
            if type(v) == 'table' then
                self:debug("%s%s: {", prefix, key_str)
                log_table_recursive(v, depth + 1, prefix .. "  ")
                self:debug("%s}", prefix)
            else
                self:debug("%s%s: %s", prefix, key_str, tostring(v))
            end
        end
    end

    self:debug("%s = {", name or 'table')
    log_table_recursive(tbl, 1, "  ")
    self:debug("}")
end

--- Execute a function with automatic timing and error logging.
--- Measures execution time and logs both successful completion
--- and any errors that occur during execution.
---
--- @param func_name string Descriptive name for the function being executed
--- @param func function The function to execute with timing
--- @param ... any Arguments to pass to the function
--- @return any... Function return values, or nil if execution failed
function Logger:timed(func_name, func, ...)
    local start_time = os.clock()
    self:debug("Starting %s", func_name)

    local results = { pcall(func, ...) }
    local success = table.remove(results, 1)

    local elapsed = (os.clock() - start_time) * 1000

    if success then
        self:debug("%s completed in %.2fms", func_name, elapsed)
        return unpack(results)
    else
        self:error("%s failed after %.2fms: %s", func_name, elapsed, results[1] or "unknown error")
        return nil
    end
end

--- Execute a function safely with automatic error logging.
--- Provides a protective wrapper that logs errors without crashing
--- the calling code, useful for non-critical operations.
---
--- @param func_name string Descriptive name for the function being executed
--- @param func function The function to execute safely
--- @param ... any Arguments to pass to the function
--- @return any... Function return values, or nil if execution failed
function Logger:safe_call(func_name, func, ...)
    local results = { pcall(func, ...) }
    local success = table.remove(results, 1)

    if success then
        return unpack(results)
    else
        self:error("%s failed: %s", func_name, results[1] or "unknown error")
        return nil
    end
end

---============================================================================
--- MODULE INITIALIZATION AND EXPORTS
---============================================================================

--- @type Logger Default logger instance for immediate use
local default_logger = Logger.new()

--- Export comprehensive logging interface.
--- Provides both the Logger class for custom instances and
--- convenient functions using the default logger for immediate use.
---
--- @return table Module exports with Logger class and convenience functions
return {
    --- Logger class for creating custom logger instances
    Logger = Logger,

    --- Default logger instance for immediate use
    default = default_logger,

    --- Convenience functions using the default logger for quick access
    error = function(...) default_logger:error(...) end,
    warn = function(...) default_logger:warn(...) end,
    info = function(...) default_logger:info(...) end,
    debug = function(...) default_logger:debug(...) end,
    table = function(...) default_logger:table(...) end,
    timed = function(...) default_logger:timed(...) end,
    safe_call = function(...) default_logger:safe_call(...) end,
}
