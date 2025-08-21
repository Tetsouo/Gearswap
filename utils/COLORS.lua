---============================================================================
--- FFXI GearSwap Color System - Consistent Color Management
---============================================================================
--- Uniform color system for all GearSwap commands.
--- Ensures visual consistency across all modules.
---
--- @file utils/colors.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

local Colors = {}

-- ============================================================================
-- STANDARD COLOR PALETTE
-- ============================================================================

Colors.PALETTE = {
    -- Headers and separators
    HEADER = 160,    -- Gray-violet for all headers
    SEPARATOR = 160, -- Same color for separators

    -- Status and results
    SUCCESS = 030, -- Bright green for success
    ERROR = 167,   -- Pink-red for errors
    WARNING = 057, -- Bright orange for warnings
    INFO = 050,    -- Bright yellow for important information

    -- Text and content
    TEXT = 037,  -- Beige for normal text
    LABEL = 050, -- Yellow for labels/categories
    VALUE = 001, -- White for values
    EMPTY = 001, -- White for empty lines

    -- Performance (dynamic colors)
    EXCELLENT = 030, -- Green (>90%)
    GOOD = 050,      -- Yellow (70-90%)
    AVERAGE = 057,   -- Orange (50-70%)
    POOR = 167,      -- Red (<50%)

    -- Special
    HIGHLIGHT = 005, -- Cyan for highlighting
    ACCENT = 201     -- Violet for special accents
}

-- ============================================================================
-- STANDARDIZED DISPLAY FUNCTIONS
-- ============================================================================

--- Display a standardized header with consistent formatting.
--- @param title string The header title to display in uppercase
function Colors.show_header(title)
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
    windower.add_to_chat(Colors.PALETTE.HEADER, "      " .. title:upper())
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
end

--- Display an end separator for closing output sections.
function Colors.show_footer()
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
end

--- Display an empty line for visual spacing.
function Colors.show_empty_line()
    windower.add_to_chat(Colors.PALETTE.EMPTY, "")
end

--- Display a category label with consistent formatting.
--- @param category_name string The category name to display
function Colors.show_category(category_name)
    windower.add_to_chat(Colors.PALETTE.LABEL, category_name .. ":")
end

--- Display a labeled entry with optional color override.
--- @param label string The entry label
--- @param value any The entry value (converted to string)
--- @param color_override number|nil Optional color code override
function Colors.show_entry(label, value, color_override)
    local color = color_override or Colors.PALETTE.VALUE
    windower.add_to_chat(color, string.format("  %s: %s", label, tostring(value)))
end

--- Display a status message (success/error/warning)
function Colors.show_status(message, status_type)
    local color = Colors.PALETTE.INFO
    local prefix = ""

    if status_type == "success" then
        color = Colors.PALETTE.SUCCESS
        prefix = "[SUCCESS] "
    elseif status_type == "error" then
        color = Colors.PALETTE.ERROR
        prefix = "[ERROR] "
    elseif status_type == "warning" then
        color = Colors.PALETTE.WARNING
        prefix = "[WARNING] "
    end

    windower.add_to_chat(color, prefix .. message)
end

--- Returns a color based on performance percentage
function Colors.get_performance_color(percentage)
    if percentage >= 90 then
        return Colors.PALETTE.EXCELLENT
    elseif percentage >= 70 then
        return Colors.PALETTE.GOOD
    elseif percentage >= 50 then
        return Colors.PALETTE.AVERAGE
    else
        return Colors.PALETTE.POOR
    end
end

--- Returns a color based on response time (in ms)
function Colors.get_time_color(time_ms)
    if time_ms <= 5 then
        return Colors.PALETTE.EXCELLENT
    elseif time_ms <= 15 then
        return Colors.PALETTE.GOOD
    elseif time_ms <= 30 then
        return Colors.PALETTE.AVERAGE
    else
        return Colors.PALETTE.POOR
    end
end

--- Returns a color based on memory usage (in MB)
function Colors.get_memory_color(memory_mb)
    if memory_mb <= 2 then
        return Colors.PALETTE.EXCELLENT -- Excellent: <= 2MB
    elseif memory_mb <= 4 then
        return Colors.PALETTE.WARNING   -- Warning: 2-4MB
    else
        return Colors.PALETTE.ERROR     -- Problem: > 4MB
    end
end

--- Display formatted statistics
function Colors.show_stats_section(title, stats)
    Colors.show_category(title)
    for label, value in pairs(stats) do
        if type(value) == "table" and value.value and value.color then
            Colors.show_entry(label, value.value, value.color)
        else
            Colors.show_entry(label, value)
        end
    end
end

--- Display an action in progress message
function Colors.show_action(message)
    windower.add_to_chat(Colors.PALETTE.INFO, message)
end

--- Display a progress message
function Colors.show_progress(step, total, message)
    if total then
        local progress = string.format("[%d/%d] %s", step, total, message)
        windower.add_to_chat(Colors.PALETTE.HIGHLIGHT, progress)
    else
        windower.add_to_chat(Colors.PALETTE.HIGHLIGHT, message)
    end
end

-- ============================================================================
-- TEMPLATES FOR SPECIFIC COMMANDS
-- ============================================================================

--- Template for test commands
function Colors.test_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        test_number_color = Colors.PALETTE.HIGHLIGHT,
        success_color = Colors.PALETTE.SUCCESS,
        error_color = Colors.PALETTE.ERROR,
        summary_color = Colors.PALETTE.HEADER
    }
end

--- Template for statistics
function Colors.stats_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        category_color = Colors.PALETTE.LABEL,
        value_color = Colors.PALETTE.VALUE,
        footer_color = Colors.PALETTE.HEADER
    }
end

--- Template for maintenance actions
function Colors.maintenance_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        action_color = Colors.PALETTE.INFO,
        success_color = Colors.PALETTE.SUCCESS,
        warning_color = Colors.PALETTE.WARNING,
        footer_color = Colors.PALETTE.HEADER
    }
end

return Colors
