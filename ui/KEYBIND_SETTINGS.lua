---============================================================================
--- Keybind UI Settings - Position persistence
---============================================================================

local KeybindSettings = {}

-- Default settings
local default_settings = {
    pos = {x = 900, y = 580},
    visible = true
}

-- Settings file path
local settings_file = windower.addon_path..'data/Tetsouo/ui/keybind_position.lua'

--- Load settings from file
function KeybindSettings.load()
    -- Try to load existing settings
    local file = io.open(settings_file, 'r')
    if file then
        file:close()
        local success, settings = pcall(dofile, settings_file)
        if success and settings then
            return settings
        end
    end
    
    -- Return defaults if no file or error
    return default_settings
end

--- Save settings to file
function KeybindSettings.save(settings)
    -- Create the settings lua content
    local content = string.format([[
-- Keybind UI saved position
return {
    pos = {x = %d, y = %d},
    visible = %s
}
]], settings.pos.x, settings.pos.y, tostring(settings.visible or true))
    
    -- Write to file
    local file = io.open(settings_file, 'w')
    if file then
        file:write(content)
        file:close()
        return true
    end
    return false
end

return KeybindSettings