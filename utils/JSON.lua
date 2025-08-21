---============================================================================
--- FFXI GearSwap JSON Serialization Utilities
---============================================================================
--- Centralized JSON serialization and deserialization utilities for the
--- GearSwap modular system. Provides safe, efficient JSON handling for
--- configuration files, data export, and inter-module communication.
---
--- @file utils/json.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-09
--- @requires utils/logger.lua
---
--- Features:
---   - Safe JSON serialization with error handling
---   - Pretty-printing with configurable indentation
---   - Type validation and sanitization
---   - Circular reference detection
---   - Large object handling with depth limits
---   - FFXI-compatible string escaping
---
--- Usage:
---   local json = require('utils/JSON')
---   local json_string = json.serialize(data, {pretty = true})
---   local data = json.deserialize(json_string)
---============================================================================

local JsonUtils = {}

-- Load dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

---============================================================================
--- CONFIGURATION
---============================================================================

-- Default serialization options
local DEFAULT_OPTIONS = {
    pretty = false,
    indent = 2,
    max_depth = 20,
    sort_keys = false
}

---============================================================================
--- INTERNAL UTILITIES
---============================================================================

--- Escape special characters in strings for JSON compatibility
--- @param str string String to escape
--- @return string Escaped string
local function escape_string(str)
    if type(str) ~= "string" then
        return tostring(str)
    end

    return str:gsub('\\', '\\\\')
        :gsub('"', '\\"')
        :gsub('\n', '\\n')
        :gsub('\r', '\\r')
        :gsub('\t', '\\t')
        :gsub('\b', '\\b')
        :gsub('\f', '\\f')
end

--- Check if a table is an array (sequential numeric keys starting from 1)
--- @param tbl table Table to check
--- @return boolean True if table is an array
local function is_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    for k, v in pairs(tbl) do
        count = count + 1
        if type(k) ~= "number" or k ~= count then
            return false
        end
    end

    return count > 0
end

--- Generate indentation string
--- @param level number Indentation level
--- @param options table Serialization options
--- @return string Indentation string
local function get_indent(level, options)
    if not options.pretty then
        return ""
    end
    return string.rep(" ", level * options.indent)
end

--- Generate newline for pretty printing
--- @param options table Serialization options
--- @return string Newline or empty string
local function get_newline(options)
    return options.pretty and "\n" or ""
end

---============================================================================
--- SERIALIZATION FUNCTIONS
---============================================================================

--- Serialize a value to JSON string (internal recursive function)
--- @param value any Value to serialize
--- @param options table Serialization options
--- @param depth number Current recursion depth
--- @param visited table Table tracking visited objects
--- @return string JSON representation
local function serialize_value(value, options, depth, visited)
    -- Depth limit protection
    if depth > options.max_depth then
        log.warn("JSON serialization depth limit exceeded, truncating")
        return '"<MAX_DEPTH_EXCEEDED>"'
    end

    local value_type = type(value)

    -- Handle primitives
    if value_type == "string" then
        return '"' .. escape_string(value) .. '"'
    elseif value_type == "number" then
        -- Handle special number values
        if value ~= value then -- NaN check
            return "null"
        elseif value == math.huge then
            return "null"
        elseif value == -math.huge then
            return "null"
        else
            return tostring(value)
        end
    elseif value_type == "boolean" then
        return tostring(value)
    elseif value == nil then
        return "null"
    elseif value_type == "table" then
        -- Circular reference detection
        if visited[value] then
            log.warn("Circular reference detected in JSON serialization")
            return '"<CIRCULAR_REFERENCE>"'
        end
        visited[value] = true

        local result
        local current_indent = get_indent(depth, options)
        local next_indent = get_indent(depth + 1, options)
        local newline = get_newline(options)

        if is_array(value) then
            -- Serialize as JSON array
            result = "[" .. newline
            local first = true
            for i = 1, #value do
                if not first then
                    result = result .. "," .. newline
                end
                result = result .. next_indent .. serialize_value(value[i], options, depth + 1, visited)
                first = false
            end
            result = result .. newline .. current_indent .. "]"
        else
            -- Serialize as JSON object
            result = "{" .. newline
            local first = true
            local keys = {}

            -- Collect and optionally sort keys
            for k in pairs(value) do
                table.insert(keys, k)
            end

            if options.sort_keys then
                table.sort(keys, function(a, b)
                    return tostring(a) < tostring(b)
                end)
            end

            -- Serialize key-value pairs
            for _, k in ipairs(keys) do
                local v = value[k]
                if not first then
                    result = result .. "," .. newline
                end

                local key_str = tostring(k)
                result = result .. next_indent .. '"' .. escape_string(key_str) .. '": '
                result = result .. serialize_value(v, options, depth + 1, visited)
                first = false
            end

            result = result .. newline .. current_indent .. "}"
        end

        visited[value] = nil -- Clean up visited table
        return result
    else
        -- Handle functions, userdata, etc.
        log.warn("Unsupported type for JSON serialization: " .. value_type)
        return '"<' .. value_type:upper() .. '>"'
    end
end

--- Serialize a Lua value to JSON string
--- @param value any Value to serialize
--- @param user_options table|nil Optional serialization options
--- @return string JSON string representation
--- @return string|nil Error message if serialization failed
function JsonUtils.serialize(value, user_options)
    -- Merge options with defaults
    local options = {}
    for k, v in pairs(DEFAULT_OPTIONS) do
        options[k] = v
    end
    if user_options then
        for k, v in pairs(user_options) do
            options[k] = v
        end
    end

    -- Perform serialization with error handling
    local success, result = pcall(function()
        return serialize_value(value, options, 0, {})
    end)

    if success then
        return result, nil
    else
        local error_msg = "JSON serialization failed: " .. tostring(result)
        log.error(error_msg)
        return nil, error_msg
    end
end

---============================================================================
--- DESERIALIZATION FUNCTIONS (BASIC)
---============================================================================

--- Basic JSON deserialization (limited implementation)
--- @param json_string string JSON string to deserialize
--- @return any|nil Deserialized value or nil on error
--- @return string|nil Error message if deserialization failed
function JsonUtils.deserialize(json_string)
    if type(json_string) ~= "string" then
        return nil, "Input must be a string"
    end

    -- Very basic JSON deserialization - can be extended
    local success, result = pcall(function()
        -- This is a simplified implementation
        -- For full JSON support, consider using external JSON library
        if json_string == "null" then
            return nil
        elseif json_string == "true" then
            return true
        elseif json_string == "false" then
            return false
        elseif json_string:match("^%d+$") then
            return tonumber(json_string)
        elseif json_string:match("^%d*%.%d+$") then
            return tonumber(json_string)
        elseif json_string:match('^".*"$') then
            return json_string:sub(2, -2):gsub('\\"', '"'):gsub('\\\\', '\\')
        else
            return nil, "Unsupported JSON format"
        end
    end)

    if success then
        return result, nil
    else
        local error_msg = "JSON deserialization failed: " .. tostring(result)
        log.error(error_msg)
        return nil, error_msg
    end
end

---============================================================================
--- CONVENIENCE FUNCTIONS
---============================================================================

--- Serialize data and write to file
--- @param data any Data to serialize
--- @param file_path string Path to output file
--- @param options table|nil Serialization options
--- @return boolean Success status
function JsonUtils.write_file(data, file_path, options)
    local json_string, error_msg = JsonUtils.serialize(data, options)
    if not json_string then
        log.error("Failed to serialize data for file: " .. error_msg)
        return false
    end

    local file = io.open(file_path, 'w')
    if not file then
        log.error("Failed to open file for writing: " .. file_path)
        return false
    end

    file:write(json_string)
    file:close()

    log.info("JSON data written to file: " .. file_path)
    return true
end

--- Pretty print JSON to console
--- @param data any Data to print
--- @param title string|nil Optional title for the output
function JsonUtils.pretty_print(data, title)
    if title then
        windower.add_to_chat(050, "=== " .. title .. " ===")
    end

    local json_string, error_msg = JsonUtils.serialize(data, { pretty = true, sort_keys = true })
    if json_string then
        -- Split into lines and print with color
        for line in json_string:gmatch("[^\r\n]+") do
            windower.add_to_chat(001, line)
        end
    else
        windower.add_to_chat(167, "JSON serialization error: " .. error_msg)
    end

    if title then
        windower.add_to_chat(050, "=== End " .. title .. " ===")
    end
end

--- Validate JSON structure (basic validation)
--- @param data any Data to validate
--- @return boolean Valid status
--- @return string|nil Error message if invalid
function JsonUtils.validate(data)
    local json_string, error_msg = JsonUtils.serialize(data)
    if json_string then
        return true, nil
    else
        return false, error_msg
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return JsonUtils
