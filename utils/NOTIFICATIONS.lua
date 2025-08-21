---============================================================================
--- FFXI GearSwap Utility Module - Rich Notification System
---============================================================================
--- Professional notification system providing visual alerts, chat messages,
--- and sound notifications with FFXI color coding and template support.
--- Includes intelligent throttling, queue management, and user customization.
---
--- @file utils/notifications.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-19
--- @requires Windower FFXI
---
--- Features:
---   - Rich chat notifications with FFXI color schemes
---   - Notification types (success, warning, error, info)
---   - Customizable message templates with variable substitution
---   - Intelligent queue management with throttling
---   - Sound notification support with configurable alerts
---   - Duplicate message prevention with timeout handling
---   - User configuration for all notification aspects
---   - Timestamp support for chronological tracking
---
--- @usage
---   local Notify = require('utils/notifications')
---   Notify.success('Equipment swap completed')
---   Notify.error('Failed to cast %s', spell_name)
---   Notify.configure({enable_sounds = true, throttle_timeout = 5})
---============================================================================

--- @class Notify Professional notification system
local Notify = {}

-- Default configuration
local config = {
    enable_notifications = true,
    enable_sounds = false,
    chat_channel = 207,   -- Default chat channel (echo)
    throttle_duplicates = true,
    throttle_timeout = 3, -- seconds
    max_queue_size = 10,
    auto_clear_queue = true,
    show_timestamps = false,
    enable_colors = true
}

-- Internal state
local notification_queue = {}
local recent_notifications = {}
local notification_history = {}
local active_templates = {}

-- FFXI colors for chat
local colors = {
    -- FFXI base colors
    white = 1,
    red = 167,
    green = 158,
    blue = 204,
    yellow = 36,
    cyan = 200,
    magenta = 200,
    orange = 208,

    -- Notification types
    success = 158, -- Green
    info = 204,    -- Blue
    warning = 208, -- Orange
    error = 167,   -- Red
    critical = 167 -- Red (with flashing)
}

-- FFXI sounds (if available)
local sounds = {
    success = "sound_ready",
    info = "sound_item",
    warning = "sound_error",
    error = "sound_buzzer",
    critical = "sound_buzzer"
}

-- Predefined templates
local default_templates = {
    spell_ready = {
        message = "✓ {spell} ready (recast: {recast}s)",
        type = "success",
        duration = 2,
        sound = true
    },

    buff_gained = {
        message = "↑ {buff} activated",
        type = "info",
        duration = 3,
        sound = false
    },

    buff_lost = {
        message = "↓ {buff} lost",
        type = "warning",
        duration = 3,
        sound = false
    },

    mp_low = {
        message = "⚠️ MP low: {mp}% ({current}/{max})",
        type = "warning",
        duration = 5,
        sound = true
    },

    hp_critical = {
        message = "💀 HP CRITICAL: {hp}%",
        type = "critical",
        duration = 8,
        sound = true,
        flash = true
    },

    equipment_broken = {
        message = "🔧 Equipment damaged: {item}",
        type = "error",
        duration = 6,
        sound = true
    },

    job_change = {
        message = "🔄 Change: {old_job} → {new_job}",
        type = "info",
        duration = 4,
        sound = false
    },

    zone_change = {
        message = "🗺️ Zone: {zone}",
        type = "info",
        duration = 3,
        sound = false
    },

    party_invite = {
        message = "👥 Invitation from {player}",
        type = "info",
        duration = 10,
        sound = true
    },

    craft_success = {
        message = "🔨 Craft success: {item} (HQ: {hq})",
        type = "success",
        duration = 4,
        sound = true
    },

    auction_sold = {
        message = "💰 Sold: {item} ({price}g)",
        type = "success",
        duration = 5,
        sound = false
    }
}

--[[
    Format a message with variables
--]]
local function format_message(template, variables)
    local message = template

    if variables then
        for key, value in pairs(variables) do
            local placeholder = "{" .. key .. "}"
            message = message:gsub(placeholder, tostring(value))
        end
    end

    return message
end

--[[
    Generate timestamp if enabled
--]]
local function get_timestamp()
    if config.show_timestamps then
        return "[" .. os.date("%H:%M:%S") .. "] "
    end
    return ""
end

--[[
    Check if a notification is throttled
--]]
local function is_throttled(message)
    if not config.throttle_duplicates then
        return false
    end

    local current_time = os.time()
    local message_hash = tostring(message):gsub("%d+", "#") -- Replace numbers with # for grouping

    local recent = recent_notifications[message_hash]
    if recent and (current_time - recent) < config.throttle_timeout then
        return true
    end

    recent_notifications[message_hash] = current_time
    return false
end

--[[
    Clean up expired recent notifications
--]]
local function cleanup_recent_notifications()
    local current_time = os.time()
    local cutoff = current_time - config.throttle_timeout

    for hash, time in pairs(recent_notifications) do
        if time < cutoff then
            recent_notifications[hash] = nil
        end
    end
end

--[[
    Display a notification in chat
--]]
local function display_notification(notification)
    if not config.enable_notifications then
        return
    end

    local message = notification.message
    local color_code = colors[notification.type] or colors.info
    local timestamp = get_timestamp()

    -- Construire le message final
    local full_message = timestamp .. message

    -- Flashing effect for critical notifications
    if notification.type == "critical" and notification.flash then
        -- Simulate flashing with repetitions
        for i = 1, 3 do
            if config.enable_colors then
                windower.add_to_chat(color_code, full_message)
            else
                windower.add_to_chat(config.chat_channel, full_message)
            end

            -- Small pause (simulation)
            coroutine.yield()
        end
    else
        -- Normal display
        if config.enable_colors then
            windower.add_to_chat(color_code, full_message)
        else
            windower.add_to_chat(config.chat_channel, full_message)
        end
    end

    -- Play sound if enabled
    if config.enable_sounds and notification.sound then
        local sound_name = sounds[notification.type]
        if sound_name and windower.play_sound then
            windower.play_sound(sound_name)
        end
    end

    -- Add to history
    table.insert(notification_history, {
        timestamp = os.time(),
        message = message,
        type = notification.type,
        duration = notification.duration
    })

    -- Limit history
    if #notification_history > 100 then
        table.remove(notification_history, 1)
    end
end

--[[
    Process the notification queue
--]]
local function process_queue()
    if #notification_queue == 0 then
        return
    end

    local notification = table.remove(notification_queue, 1)

    -- Check throttling
    if not is_throttled(notification.message) then
        display_notification(notification)
    end

    -- Clean up periodically
    cleanup_recent_notifications()
end

--[[
    Add a notification to the queue
--]]
local function enqueue_notification(notification)
    -- Check queue size
    if #notification_queue >= config.max_queue_size then
        if config.auto_clear_queue then
            -- Remove old notifications
            table.remove(notification_queue, 1)
        else
            -- Ignore new notification
            return false
        end
    end

    table.insert(notification_queue, notification)
    return true
end

--[[
    Public API
--]]

--[[
    Configure the notification system
--]]
function Notify.configure(new_config)
    for key, value in pairs(new_config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

--[[
    Display a simple notification
--]]
function Notify.show(message, notification_type, duration)
    if not message then
        return false
    end

    local notification = {
        message = tostring(message),
        type = notification_type or "info",
        duration = duration or 3,
        sound = true,
        timestamp = os.time()
    }

    return enqueue_notification(notification)
end

--[[
    Display a notification with template
--]]
function Notify.show_template(template_name, variables)
    local template = active_templates[template_name] or default_templates[template_name]

    if not template then
        return false, "Template not found: " .. template_name
    end

    local message = format_message(template.message, variables)

    local notification = {
        message = message,
        type = template.type or "info",
        duration = template.duration or 3,
        sound = template.sound ~= false, -- Default true unless explicitly false
        flash = template.flash or false,
        timestamp = os.time()
    }

    return enqueue_notification(notification)
end

--[[
    Create or modify a custom template
--]]
function Notify.create_template(name, template_config)
    active_templates[name] = {
        message = template_config.message,
        type = template_config.type or "info",
        duration = template_config.duration or 3,
        sound = template_config.sound ~= false,
        flash = template_config.flash or false
    }

    return true
end

--[[
    Remove a custom template
--]]
function Notify.remove_template(name)
    if active_templates[name] then
        active_templates[name] = nil
        return true
    end
    return false
end

--[[
    List all available templates
--]]
function Notify.list_templates()
    local templates = {}

    -- Default templates
    for name, template in pairs(default_templates) do
        templates[name] = {
            message = template.message,
            type = template.type,
            duration = template.duration,
            sound = template.sound,
            source = "default"
        }
    end

    -- Custom templates
    for name, template in pairs(active_templates) do
        templates[name] = {
            message = template.message,
            type = template.type,
            duration = template.duration,
            sound = template.sound,
            source = "custom"
        }
    end

    return templates
end

--[[
    Display a success notification
--]]
function Notify.success(message, duration)
    return Notify.show(message, "success", duration)
end

--[[
    Display an information notification
--]]
function Notify.info(message, duration)
    return Notify.show(message, "info", duration)
end

--[[
    Display a warning
--]]
function Notify.warning(message, duration)
    return Notify.show(message, "warning", duration)
end

--[[
    Display an error
--]]
function Notify.error(message, duration)
    return Notify.show(message, "error", duration)
end

--[[
    Display a critical error
--]]
function Notify.critical(message, duration)
    local notification = {
        message = tostring(message),
        type = "critical",
        duration = duration or 8,
        sound = true,
        flash = true,
        timestamp = os.time()
    }

    return enqueue_notification(notification)
end

--[[
    Clear the notification queue
--]]
function Notify.clear_queue()
    notification_queue = {}
    return true
end

--[[
    Get the queue status
--]]
function Notify.get_queue_status()
    return {
        queue_size = #notification_queue,
        max_size = config.max_queue_size,
        recent_count = table.length(recent_notifications),
        history_count = #notification_history
    }
end

--[[
    Get the notification history
--]]
function Notify.get_history(limit)
    local count = limit or #notification_history
    local history = {}

    local start = math.max(1, #notification_history - count + 1)
    for i = start, #notification_history do
        table.insert(history, notification_history[i])
    end

    return history
end

--[[
    Test all notification types
--]]
function Notify.test_all()
    Notify.success("Success notification test")
    Notify.info("Information notification test")
    Notify.warning("Warning test")
    Notify.error("Error notification test")
    Notify.critical("Critical notification test")

    -- Template tests
    Notify.show_template("spell_ready", { spell = "Fire IV", recast = 0 })
    Notify.show_template("mp_low", { mp = 15, current = 150, max = 1000 })

    return "Notification tests sent"
end

--[[
    Temporarily enable/disable notifications
--]]
function Notify.toggle(enabled)
    if enabled ~= nil then
        config.enable_notifications = enabled
    else
        config.enable_notifications = not config.enable_notifications
    end

    return config.enable_notifications
end

--[[
    Get the current configuration
--]]
function Notify.get_config()
    return table.copy(config)
end

--[[
    Get system statistics
--]]
function Notify.get_statistics()
    return {
        total_sent = #notification_history,
        queue_size = #notification_queue,
        recent_throttled = table.length(recent_notifications),
        templates_active = table.length(active_templates),
        templates_default = table.length(default_templates),
        colors_available = table.length(colors),
        sounds_available = table.length(sounds)
    }
end

-- Fonctions utilitaires
function table.length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Start periodic processing of the queue
-- This function should be called regularly by the main system
function Notify.process_queue()
    process_queue()
end

-- Initialisation
do
    -- Ensure windower is available
    if not windower or not windower.add_to_chat then
        config.enable_notifications = false
        print("Warning: Windower chat functions not available")
    end

    -- Initialize default templates as active
    for name, template in pairs(default_templates) do
        active_templates[name] = table.copy(template)
    end
end

-- Built-in console commands (if used with GearSwap)
if windower and windower.register_event then
    windower.register_event('addon command', function(command, ...)
        local args = { ... }

        if command == 'notify' then
            if args[1] == 'test' then
                return Notify.test_all()
            elseif args[1] == 'clear' then
                Notify.clear_queue()
                return "Queue cleared"
            elseif args[1] == 'status' then
                local status = Notify.get_queue_status()
                return string.format("Queue: %d/%d, Recent: %d, History: %d",
                    status.queue_size, status.max_size, status.recent_count, status.history_count)
            elseif args[1] == 'toggle' then
                local enabled = Notify.toggle()
                return "Notifications " .. (enabled and "enabled" or "disabled")
            end
        end
    end)
end

return Notify
