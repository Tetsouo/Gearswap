---============================================================================
--- Keybind UI System - Final Optimized Version
--- Displays job-specific keybinds with real-time state updates for FFXI GearSwap
--- Features: Auto-save position, element/stat colors, performance optimizations
--- Commands: //gs c ui (toggle), //gs c uisave (save position manually)
--- Jobs: BRD, THF, WAR, PLD, DNC, BST, BLM, DRG, RUN
---============================================================================

local KeybindUI = {}
local texts = require('texts')

-- Global UI objects to persist across module reloads
if not _G.keybind_ui_display then
    _G.keybind_ui_display = nil
    _G.keybind_ui_visible = true
end

-- Load our settings module
local KeybindSettings = require('ui/KEYBIND_SETTINGS')

-- Load saved settings or use defaults
if not _G.keybind_saved_settings then
    _G.keybind_saved_settings = KeybindSettings.load()
end

-- UI Configuration with saved position
local ui_settings = {
    pos = { x = _G.keybind_saved_settings.pos.x, y = _G.keybind_saved_settings.pos.y },
    text = { size = 12, font = 'Consolas', stroke = { width = 2, alpha = 255, red = 0, green = 0, blue = 0 } },
    bg = { alpha = 150, red = 10, green = 10, blue = 25, visible = true }, -- More transparent
    flags = { draggable = true, bold = true }
}

-- Save position when UI is moved
local function save_position(x, y)
    _G.keybind_saved_settings.pos.x = x
    _G.keybind_saved_settings.pos.y = y
    KeybindSettings.save(_G.keybind_saved_settings)
end

-- Dynamic job keybind detection
local function get_current_job_keybinds()
    local job = player and player.main_job or "UNK"
    local keybinds = {}

    -- Job-specific keybinds only
    if job == "BRD" then
        keybinds = {
            { key = "F1", desc = "BRD Rotation",     state = "BRDRotation" },
            { key = "F2", desc = "Victory March",    state = "VictoryMarchReplace" },
            { key = "F3", desc = "Etude Type",       state = "EtudeType" },
            { key = "F4", desc = "Carol Element",    state = "CarolElement" },
            { key = "F5", desc = "Threnody Element", state = "ThrenodyElement" },
            { key = "F6", desc = "Main Weapon",      state = "MainWeapon" },
            { key = "F7", desc = "Sub Weapon",       state = "SubSet" },
        }
    elseif job == "THF" then
        keybinds = {
            { key = "F1", desc = "Main Weapon",   state = "WeaponSet1" },
            { key = "F2", desc = "Sub Weapon",    state = "SubSet" },
            { key = "F3", desc = "Abyssea Proc",  state = "AbysseaProc" },
            { key = "F4", desc = "Proc Weapon",   state = "WeaponSet2" },
            { key = "F5", desc = "Hybrid Mode",   state = "HybridMode" },
            { key = "F6", desc = "Treasure Mode", state = "TreasureMode" },
        }
    elseif job == "WAR" then
        keybinds = {
            { key = "F1", desc = "Main Weapon", state = "WeaponSet" },
            { key = "F2", desc = "Ammo",        state = "ammoSet" },
            { key = "F9", desc = "Hybrid Mode", state = "HybridMode" },
        }
    elseif job == "PLD" then
        keybinds = {
            { key = "F1", desc = "Hybrid Mode", state = "HybridMode" },
            { key = "F2", desc = "Main Weapon", state = "WeaponSet" },
            { key = "F3", desc = "Sub Weapon",  state = "SubSet" },
        }
        -- Add Rune state if sub job is RUN
        if player and player.sub_job == "RUN" then
            table.insert(keybinds, { key = "F4", desc = "Rune Element", state = "RuneElement" })
        end
    elseif job == "DNC" then
        keybinds = {
            { key = "F1", desc = "Main Weapon",   state = "WeaponSet" },
            { key = "F2", desc = "Sub Weapon",    state = "SubSet" },
            { key = "F3", desc = "Main Step",     state = "MainStep" },
            { key = "F4", desc = "Alt Step",      state = "AltStep" },
            { key = "F5", desc = "Hybrid Mode",   state = "HybridMode" },
            { key = "F6", desc = "Treasure Mode", state = "TreasureMode" },
        }
    elseif job == "BST" then
        keybinds = {
            { key = "F1", desc = "Auto Pet Engage", state = "AutoPetEngage" },
            { key = "F2", desc = "Main Weapon",     state = "WeaponSet" },
            { key = "F3", desc = "Sub Weapon",      state = "SubSet" },
            { key = "F4", desc = "Ecosystem",       state = "ecosystem" },
            { key = "F5", desc = "Species",         state = "species" },
            { key = "F6", desc = "Pet Idle Mode",   state = "petIdleMode" },
            { key = "F7", desc = "Hybrid Mode",     state = "HybridMode" },
        }
    elseif job == "BLM" then
        keybinds = {
            { key = "F1", desc = "Main Light",   state = "MainLightSpell" },
            { key = "F2", desc = "Main Dark",    state = "MainDarkSpell" },
            { key = "F3", desc = "Sub Light",    state = "SubLightSpell" },
            { key = "F4", desc = "Sub Dark",     state = "SubDarkSpell" },
            { key = "F5", desc = "Aja Spell",    state = "Aja" },
            { key = "F6", desc = "Tier Spell",   state = "TierSpell" },
            { key = "F7", desc = "Storm",        state = "Storm" },
            { key = "F9", desc = "Casting Mode", state = "CastingMode" },
        }
    elseif job == "DRG" then
        keybinds = {
            { key = "F9",  desc = "Hybrid Mode", state = "HybridMode" },
            { key = "F10", desc = "Main Weapon", state = "WeaponSet" },
            { key = "F11", desc = "Sub Weapon",  state = "SubSet" },
        }
    elseif job == "RUN" then
        keybinds = {
            { key = "F2", desc = "Hybrid Mode", state = "HybridMode" },
            { key = "F3", desc = "Main Weapon", state = "WeaponSet" },
            { key = "F4", desc = "Sub Weapon",  state = "SubSet" },
        }
    end

    -- Add F9 Hybrid Mode to jobs that don't already have it
    local has_f9 = false
    for _, bind in ipairs(keybinds) do
        if bind.key == "F9" then
            has_f9 = true
            break
        end
    end
    if not has_f9 then
        table.insert(keybinds, { key = "F9", desc = "Hybrid Mode", state = "HybridMode" })
    end

    return keybinds
end

--- Get current value of a state
local function get_state_value(state_name, keybind_key)
    if not _G.state or not _G.state[state_name] then
        return "N/A"
    end

    local state_obj = _G.state[state_name]
    local result = "Unknown"

    -- Handle different types of state objects
    if type(state_obj) == 'table' then
        if state_obj.display then
            local success, display_result = pcall(state_obj.display, state_obj)
            if success and display_result then
                result = tostring(display_result)
            end
        elseif state_obj.value ~= nil then
            -- Handle boolean values properly
            if type(state_obj.value) == 'boolean' then
                result = state_obj.value and "true" or "false"
            else
                result = tostring(state_obj.value)
            end
        end
    elseif type(state_obj) == 'boolean' then
        -- Direct boolean state
        result = state_obj and "true" or "false"
    end

    -- Clean weapon display names (remove parentheses content)
    if keybind_key == "F1" or keybind_key == "F2" then
        result = result:gsub("%s*%([^%)]*%)", "")
    end

    return result
end

-- Color lookup tables (optimized - defined once)
local element_colors = {
    -- Basic FFXI elements
    Fire = "\\cs(255,100,100)",
    Ice = "\\cs(150,200,255)",
    Wind = "\\cs(150,255,150)",
    Earth = "\\cs(200,150,100)",
    Lightning = "\\cs(255,150,255)",
    Water = "\\cs(100,150,255)",
    Light = "\\cs(255,255,255)",
    Dark = "\\cs(150,100,200)",
    
    -- RUN Runes (matching elements)
    Ignis = "\\cs(255,100,100)",     -- Fire rune
    Gelus = "\\cs(150,200,255)",     -- Ice rune
    Flabra = "\\cs(150,255,150)",    -- Wind rune
    Tellus = "\\cs(200,150,100)",    -- Earth rune
    Sulpor = "\\cs(255,150,255)",    -- Lightning rune
    Unda = "\\cs(100,150,255)",      -- Water rune
    Lux = "\\cs(255,255,255)",       -- Light rune
    Tenebrae = "\\cs(150,100,200)",   -- Dark rune

    -- BLM spell names (matching BLM state values)
    Thunder = "\\cs(255,150,255)",  -- Lightning/Purple (same as Lightning)
    Aero = "\\cs(150,255,150)",     -- Wind/Green (same as Wind)
    Stone = "\\cs(200,150,100)",    -- Earth/Brown (same as Earth)
    Blizzard = "\\cs(150,200,255)", -- Ice/Blue (same as Ice)

    -- BLM Aja spells
    Firaja = "\\cs(255,100,100)",   -- Fire/Red
    Thundaja = "\\cs(255,150,255)", -- Lightning/Purple
    Aeroja = "\\cs(150,255,150)",   -- Wind/Green
    Stoneja = "\\cs(200,150,100)",  -- Earth/Brown
    Blizzaja = "\\cs(150,200,255)", -- Ice/Blue
    Waterja = "\\cs(100,150,255)",  -- Water/Blue

    -- BLM Storm spells
    FireStorm = "\\cs(255,100,100)",    -- Fire/Red
    Thunderstorm = "\\cs(255,150,255)", -- Lightning/Purple
    Windstorm = "\\cs(150,255,150)",    -- Wind/Green
    Sandstorm = "\\cs(200,150,100)",    -- Earth/Brown
    HailStorm = "\\cs(150,200,255)",    -- Ice/Blue
    Rainstorm = "\\cs(100,150,255)",    -- Water/Blue
    Voidstorm = "\\cs(150,100,200)",    -- Dark/Purple
    Aurorastorm = "\\cs(255,255,255)"   -- Light/White
}

local stat_colors = {
    STR = "\\cs(255,100,100)",
    DEX = "\\cs(255,150,255)",
    VIT = "\\cs(200,150,100)",
    AGI = "\\cs(150,255,150)",
    INT = "\\cs(150,100,200)",
    MND = "\\cs(150,200,255)",
    CHR = "\\cs(255,255,255)"
}

--- Create a centered section title with consistent alignment
local function create_centered_title(title)
    -- Fixed padding values that work well visually for each title
    local padding_map = {
        ["── Spells ──"] = 18,
        ["── Pet Abilities ──"] = 15,
        ["── JA ──"] = 20,
        ["── Weapons ──"] = 18,
        ["── Modes ──"] = 19
    }
    
    local padding = padding_map[title] or 18 -- Default padding if title not found
    return string.rep(" ", padding) .. title
end

--- Get color for a specific value based on context
local function get_value_color(value, description)
    local value_color = "\\cs(255,255,255)" -- Default white

    -- Apply colors based on context
    if description:find("Element") and element_colors[value] then
        value_color = element_colors[value]
    elseif description:find("Etude") and stat_colors[value] then
        value_color = stat_colors[value]
    elseif description:find("Rune") and element_colors[value] then
        value_color = element_colors[value]
        -- BLM spell elements (Main Light, Main Dark, Aja, Storm, etc.)
    elseif (description:find("Light") or description:find("Dark") or description:find("Aja") or description:find("Storm")) and element_colors[value] then
        value_color = element_colors[value]
        -- BLM Storm spells (FireStorm, Sandstorm, etc.)
    elseif description:find("Storm") then
        if value:find("Fire") then
            value_color = element_colors["Fire"]
        elseif value:find("Sand") or value:find("Stone") then
            value_color = element_colors["Earth"]
        elseif value:find("Thunder") then
            value_color = element_colors["Lightning"]
        elseif value:find("Hail") or value:find("Bliz") then
            value_color = element_colors["Ice"]
        elseif value:find("Rain") or value:find("Water") then
            value_color = element_colors["Water"]
        elseif value:find("Wind") then
            value_color = element_colors["Wind"]
        elseif value:find("Void") then
            value_color = element_colors["Dark"]
        elseif value:find("Aurora") then
            value_color = element_colors["Light"]
        end
    elseif value:find("PDT") then
        value_color = "\\cs(255,200,100)" -- Orange
    elseif value:find("MDT") then
        value_color = "\\cs(150,200,255)" -- Light blue
    elseif value:find("Normal") then
        value_color = "\\cs(150,255,150)" -- Green
    -- True/False coloring (especially for Abyssea Proc)
    elseif value:lower() == "true" then
        value_color = "\\cs(100,255,100)" -- Bright green for True
    elseif value:lower() == "false" then
        value_color = "\\cs(255,100,100)" -- Bright red for False
    elseif value:lower() == "unknown" or value == "N/A" then
        value_color = "\\cs(200,200,100)" -- Yellow for Unknown/N/A
    end

    return value_color
end

--- Optimized display update with better performance
local function update_display()
    if not _G.keybind_ui_display then return end

    local job = player and player.main_job or "UNK"
    local keybinds = get_current_job_keybinds()

    local text = ""

    -- Job titles (icons are handled separately during initialization)
    local job_titles = {
        BRD = "Bard Settings",
        THF = "Thief Settings",
        WAR = "Warrior Settings",
        PLD = "Paladin Settings",
        DNC = "Dancer Settings",
        BST = "Beastmaster Settings",
        BLM = "Black Mage Settings",
        DRG = "Dragoon Settings",
        RUN = "Rune Fencer Settings"
    }

    -- No job icons - clean title
    local job_icon = "" -- No icon

    local title = job_titles[job] or job .. " Settings"

    -- Stylish header
    text = text .. "\\cs(100,200,255)" .. string.rep("─", 50) .. "\\cr\n"
    text = text .. "\\cs(255,255,255)" .. "  " .. title .. "\\cr\n"
    text = text .. "\\cs(100,200,255)" .. string.rep("─", 50) .. "\\cr\n"

    -- Column headers
    text = text .. string.format("\\cs(150,150,200)  %-5s %-22s %s\\cr\n", "Key", "Function", "Current")

    -- Build aligned table with sections and separators
    local spell_keys, weapon_keys, mode_keys, ja_keys

    if job == "BRD" then
        -- For BRD, songs/abilities, weapons, no modes (no hybrid/treasure)
        spell_keys = { "F1", "F2", "F3", "F4", "F5" } -- BRD songs and abilities
        ja_keys = {} -- No JA for BRD
        weapon_keys = { "F6", "F7" } -- Main Weapon and Sub Weapon
        mode_keys = {} -- No modes for BRD
    elseif job == "THF" then
        -- For THF, no spells, weapons and modes only
        spell_keys = {} -- No spells/abilities for THF
        ja_keys = {} -- No JA for THF
        weapon_keys = { "F1", "F2", "F3", "F4" } -- Main Weapon, Sub Weapon, Abyssea Proc, Proc Weapon
        mode_keys = { "F5", "F6" } -- Hybrid Mode and Treasure Mode
    elseif job == "WAR" then
        -- For WAR, no spells, just weapons and modes
        spell_keys = {} -- No spells for WAR
        ja_keys = {} -- No JA for WAR
        weapon_keys = { "F1", "F2" } -- Main Weapon and Ammo
        mode_keys = { "F9" } -- Hybrid Mode
    elseif job == "PLD" then
        -- For PLD, conditional Rune spell if sub RUN, weapons and modes
        spell_keys = {} -- No base spells for PLD
        ja_keys = {} -- No JA for PLD
        weapon_keys = { "F2", "F3" } -- Main Weapon and Sub Weapon
        mode_keys = { "F1" } -- Hybrid Mode
        -- Add Rune to spells section if sub job is RUN
        if player and player.sub_job == "RUN" then
            spell_keys = { "F4" } -- Rune appears in spells section
        end
    elseif job == "DNC" then
        -- For DNC, JA for steps, weapons, and modes
        spell_keys = {} -- No spells for DNC
        ja_keys = { "F3", "F4" } -- Main Step and Alt Step (Job Abilities)
        weapon_keys = { "F1", "F2" } -- Main Weapon and Sub Weapon
        mode_keys = { "F5", "F6" } -- Hybrid Mode and Treasure Mode
    elseif job == "BST" then
        -- For BST, pet abilities instead of spells, weapons, and modes
        spell_keys = { "F1", "F4", "F5", "F6" } -- Pet abilities (will be renamed to "Pet Abilities")
        ja_keys = {} -- No JA for BST
        weapon_keys = { "F2", "F3" } -- Main Weapon and Sub Weapon
        mode_keys = { "F7" } -- Hybrid Mode
    elseif job == "BLM" then
        -- For BLM, spells include F1-F7 (including Storm)
        spell_keys = { "F1", "F2", "F3", "F4", "F5", "F6", "F7" } -- All spells
        ja_keys = {} -- No JA for BLM
        weapon_keys = {} -- No weapon section for BLM
        mode_keys = { "F9" } -- Casting Mode
    elseif job == "DRG" then
        -- For DRG, no spells, just weapons and modes
        spell_keys = {} -- No spells for DRG
        ja_keys = {} -- No JA for DRG
        weapon_keys = { "F10", "F11" } -- Main Weapon and Sub Weapon
        mode_keys = { "F9" } -- Hybrid Mode
    elseif job == "RUN" then
        -- For RUN, no spells, just weapons and modes
        spell_keys = {} -- No spells for RUN (rune state not implemented yet)
        ja_keys = {} -- No JA for RUN
        weapon_keys = { "F3", "F4" } -- Main Weapon and Sub Weapon
        mode_keys = { "F2" } -- Hybrid Mode
    else
        -- For other jobs, normal sections
        spell_keys = { "F1", "F2", "F3", "F4", "F5" }
        ja_keys = {} -- No JA for other jobs
        weapon_keys = { "F6", "F7" }
        mode_keys = { "F9", "F10", "F11" }
    end

    -- Spells Section
    local spell_found = false
    for _, bind in ipairs(keybinds) do
        for _, spell_key in ipairs(spell_keys) do
            if bind.key == spell_key then
                if not spell_found then
                    local section_title = job == "BST" and "── Pet Abilities ──" or "── Spells ──"
                    text = text .. "\n\\cs(100,150,255)" .. create_centered_title(section_title) .. "\\cr\n"
                    spell_found = true
                end
                local value = get_state_value(bind.state, bind.key)
                local key_desc_part = string.format("%-5s %-22s", bind.key, bind.desc)
                local value_color = get_value_color(value, bind.desc)
                text = text .. "\\cs(200,200,200)  " .. key_desc_part .. "\\cr" ..
                    value_color .. " " .. value .. "\\cr\n"
                break
            end
        end
    end

    -- JA Section (Job Abilities)
    local ja_found = false
    for _, bind in ipairs(keybinds) do
        for _, ja_key in ipairs(ja_keys) do
            if bind.key == ja_key then
                if not ja_found then
                    text = text .. "\n\\cs(255,255,100)" .. create_centered_title("── JA ──") .. "\\cr\n"
                    ja_found = true
                end
                local value = get_state_value(bind.state, bind.key)
                local key_desc_part = string.format("%-5s %-22s", bind.key, bind.desc)
                local value_color = get_value_color(value, bind.desc)
                text = text .. "\\cs(200,200,200)  " .. key_desc_part .. "\\cr" ..
                    value_color .. " " .. value .. "\\cr\n"
                break
            end
        end
    end

    -- Weapons Section (F6-F7)
    local weapon_found = false
    for _, bind in ipairs(keybinds) do
        for _, weapon_key in ipairs(weapon_keys) do
            if bind.key == weapon_key then
                if not weapon_found then
                    text = text .. "\n\\cs(255,180,100)" .. create_centered_title("── Weapons ──") .. "\\cr\n"
                    weapon_found = true
                end
                local value = get_state_value(bind.state, bind.key)
                local key_desc_part = string.format("%-5s %-22s", bind.key, bind.desc)
                local value_color = get_value_color(value, bind.desc)
                text = text .. "\\cs(200,200,200)  " .. key_desc_part .. "\\cr" ..
                    value_color .. " " .. value .. "\\cr\n"
                break
            end
        end
    end

    -- Modes Section (F9)
    local mode_found = false
    for _, bind in ipairs(keybinds) do
        for _, mode_key in ipairs(mode_keys) do
            if bind.key == mode_key then
                if not mode_found then
                    text = text .. "\n\\cs(150,255,150)" .. create_centered_title("── Modes ──") .. "\\cr\n"
                    mode_found = true
                end
                local value = get_state_value(bind.state, bind.key)
                local key_desc_part = string.format("%-5s %-22s", bind.key, bind.desc)
                local value_color = get_value_color(value, bind.desc)
                text = text .. "\\cs(200,200,200)  " .. key_desc_part .. "\\cr" ..
                    value_color .. " " .. value .. "\\cr\n"
                break
            end
        end
    end

    -- Stylish footer
    text = text .. "\\cs(100,200,255)" .. string.rep("─", 50) .. "\\cr\n"
    text = text .. "\\cs(120,120,150)  Toggle: //gs c ui\\cr\n"
    text = text .. " " -- Extra line for padding to prevent text cutoff

    _G.keybind_ui_display:text(text)
end

--- Initialize UI (auto-show, single toggle command)
function KeybindUI.init()
    if _G.keybind_ui_display then
        return -- Already exists, silent
    end

    _G.keybind_ui_display = texts.new(ui_settings)
    windower.add_to_chat(207, '[KeybindUI] UI initialized successfully!')

    -- Auto-save position after drag
    local last_x, last_y = _G.keybind_saved_settings.pos.x, _G.keybind_saved_settings.pos.y

    -- Optimized position check (every 2 seconds instead of every time change)
    local check_counter = 0
    windower.register_event('time change', function()
        check_counter = check_counter + 1
        if check_counter >= 4 and _G.keybind_ui_display then -- Check every 4 time changes (~2 seconds)
            check_counter = 0
            local current_x, current_y = _G.keybind_ui_display:pos()
            if current_x and current_y and (current_x ~= last_x or current_y ~= last_y) then
                last_x, last_y = current_x, current_y
                save_position(current_x, current_y)
                windower.add_to_chat(207, '[KeybindUI] Position auto-saved!')
            end
        end
    end)

    update_display()
    _G.keybind_ui_display:visible(true)
    _G.keybind_ui_visible = true
end

--- Save current position (call this manually when needed)
function KeybindUI.save_position()
    if _G.keybind_ui_display then
        local x, y = _G.keybind_ui_display:pos()
        if x and y then
            save_position(x, y)
            windower.add_to_chat(207, '[KeybindUI] Position saved!')
        end
    end
end

--- Toggle UI (main command)
function KeybindUI.toggle()
    if _G.keybind_ui_display then
        _G.keybind_ui_visible = not _G.keybind_ui_visible
        _G.keybind_ui_display:visible(_G.keybind_ui_visible)
        -- No PNG primitives to handle
        windower.add_to_chat(207, '[KeybindUI] ' .. (_G.keybind_ui_visible and 'Shown' or 'Hidden'))
    end
end

--- Show/Hide helpers (for legacy support)
function KeybindUI.show()
    if _G.keybind_ui_display and not _G.keybind_ui_visible then
        KeybindUI.toggle()
    end
end

function KeybindUI.hide()
    if _G.keybind_ui_display and _G.keybind_ui_visible then
        KeybindUI.toggle()
    end
end

--- Update UI when states change
function KeybindUI.update()
    if _G.keybind_ui_display and _G.keybind_ui_visible then
        update_display()
    end
end

--- Alias for compatibility
KeybindUI.auto_update = KeybindUI.update

--- Cleanup
function KeybindUI.destroy()
    if _G.keybind_ui_display then
        _G.keybind_ui_display:destroy()
        _G.keybind_ui_display = nil
    end
    -- No PNG primitives to clean up
    _G.keybind_ui_visible = true
    windower.add_to_chat(207, '[KeybindUI] Destroyed')
end

return KeybindUI
