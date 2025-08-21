---============================================================================
--- Universal Command Help System - Compatible with All Jobs
---============================================================================
--- Universal help system that automatically adapts to any job.
--- Automatically detects the current job and displays appropriate commands.
---
--- @file utils/command_help.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

local CommandHelp = {}

--- Automatic detection of current job from player object or filename.
--- @return string Current job abbreviation in uppercase (WAR, PLD, etc.)
local function get_current_job()
    if player and player.main_job then
        return player.main_job:upper()
    end
    -- Fallback: detect from loaded LUA file name
    if _addon and _addon.name then
        local job_pattern = "Tetsouo_(%w+)"
        local job = _addon.name:match(job_pattern)
        return job and job:upper() or "UNKNOWN"
    end
    return "UNKNOWN"
end

-- Job keybind configuration - Complete F-key mappings
local job_keybinds = {
    WAR = {
        F1 = "WeaponSet", F2 = "ammoSet", F5 = "HybridMode"
    },
    BLM = {
        F1 = "MainLight",
        F2 = "MainDark",
        F3 = "SubLight",
        F4 = "SubDark",
        F5 = "Aja",
        F6 = "TierSpell",
        F7 = "Storm",
        F8 = "CastingMode"
    },
    BST = {
        F4 = "Ecosystem", F5 = "Species", F1 = "AutoPetEngage", F2 = "WeaponSet", F3 = "SubSet"
    },
    PLD = {
        F1 = "HybridMode", F2 = "WeaponSet", F3 = "SubSet", F10 = "WeaponSet", F11 = "SubSet"
    },
    DNC = {
        -- DNC uses default Mote bindings + job-specific features
        F5 = "HybridMode",
        F6 = "OffenseMode"
    },
    DRG = {
        F9 = "HybridMode", F10 = "WeaponSet", F11 = "SubSet"
    },
    RUN = {
        F2 = "HybridMode", F3 = "WeaponSet", F4 = "SubSet"
    },
    THF = {
        F1 = "WeaponSet1",
        F2 = "SubSet",
        F3 = "AbysseaProc",
        F4 = "WeaponSet2",
        F5 = "HybridMode",
        F6 = "TreasureMode"
    },
    BRD = {
        F1 = "SongMode",
        F2 = "InstrumentSet",
        F3 = "SongTier",
        F4 = "CastingMode",
        F5 = "HybridMode",
        F6 = "OffenseMode"
    }
}

-- Commands common to all jobs
local universal_commands = {
    {
        category = "METRICS",
        note = "(disabled by default)",
        commands = {
            { cmd = "metrics toggle", desc = "Enable/disable" },
            { cmd = "metrics show",   desc = "Performance dashboard" },
            { cmd = "metrics export", desc = "Export to JSON" },
            { cmd = "metrics status", desc = "View current status" }
        }
    },
    {
        category = "SYSTEM",
        commands = {
            { cmd = "cache stats", desc = "Cache stats" },
            { cmd = "test",        desc = "Unit tests" },
            { cmd = "cmd full",    desc = "Complete help" }
        }
    }
}

-- Job-specific commands (optional)
local job_specific_commands = {
    WAR = {
        { cmd = "berserk auto",  desc = "Toggle automatic Berserk" },
        { cmd = "defender auto", desc = "Toggle automatic Defender" }
    },
    BLM = {
        { cmd = "nukemode cycle", desc = "Change nuke mode" },
        { cmd = "manawall auto",  desc = "Toggle auto Manawall" }
    }
    -- Add other jobs as needed
}

--- Display help in chat with pagination
function CommandHelp.show_help_in_chat(page)
    page = page or 1
    local current_job = get_current_job()
    local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }

    if page == 1 then
        -- Page 1: JOB commands (general)
        windower.add_to_chat(160, "========= " .. current_job .. " COMMANDS [Page 1/3] =========")
        windower.add_to_chat(030, "KEYBOARD SHORTCUTS:")

        -- Display all F-keys for the current job
        local f_keys = { "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }
        for _, key in ipairs(f_keys) do
            if keybinds[key] then
                windower.add_to_chat(050, "  " .. key .. " = Cycle " .. keybinds[key])
            end
        end

        windower.add_to_chat(030, "COMMON COMMANDS:")
        windower.add_to_chat(050, "  //gs r                 - Reload config")
        windower.add_to_chat(050, "  //gs c info [1-3]      - Help pages")
        windower.add_to_chat(160, "Next page: //gs c info 2")
        windower.add_to_chat(160, "==========================================")
    elseif page == 2 then
        -- Page 2: Metrics and Performance
        windower.add_to_chat(160, "========= METRICS [Page 2/3] =========")
        windower.add_to_chat(030, "METRICS (disabled by default):")
        windower.add_to_chat(050, "  //gs c metrics toggle  - Enable/disable")
        windower.add_to_chat(050, "  //gs c metrics show    - Dashboard")
        windower.add_to_chat(050, "  //gs c metrics export  - Sauver JSON")
        windower.add_to_chat(050, "  //gs c metrics reset   - Reset to zero")
        windower.add_to_chat(050, "  //gs c metrics status  - View status")
        windower.add_to_chat(160, "Next page: //gs c info 3")
        windower.add_to_chat(160, "==========================================")
    elseif page == 3 then
        -- Page 3: System and Debug
        windower.add_to_chat(160, "========= SYSTEM [Page 3/3] =========")
        windower.add_to_chat(030, "CACHE & MODULES:")
        windower.add_to_chat(050, "  //gs c cache stats     - Cache stats")
        windower.add_to_chat(050, "  //gs c cache clear     - Clear cache")
        windower.add_to_chat(050, "  //gs c modules stats   - Module info")
        windower.add_to_chat(030, "DEBUG:")
        windower.add_to_chat(050, "  //gs c test            - Unit tests")
        windower.add_to_chat(050, "  //gs c help            - Help categories")
        windower.add_to_chat(160, "Back to start: //gs c info 1")
        windower.add_to_chat(160, "==========================================")
    else
        windower.add_to_chat(167, "Invalid page. Use: //gs c info [1-3]")
    end
end

--- Display brief help in console (clean version)
function CommandHelp.show_brief()
    local current_job = get_current_job()
    local keybinds = job_keybinds[current_job] or {}

    print("===== " .. current_job .. " COMMANDS =====")
    print("//gs c info        - Help in chat")
    print("//gs c metrics     - Metrics system")
    print("//gs c cache       - Cache management")

    -- Show actual F-keys for this job
    local has_f_keys = false
    for key, value in pairs(keybinds) do
        if not has_f_keys then
            print("F-KEYS:")
            has_f_keys = true
        end
        print("  " .. key .. " = " .. value)
    end

    print("========================")
end

--- Display complete help with all commands
function CommandHelp.show_full()
    local current_job = get_current_job()
    local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }

    print("================== COMPLETE HELP " .. current_job .. " ==================")
    print("")

    -- Keyboard shortcuts
    print("KEYBOARD SHORTCUTS:")
    local f_keys = { "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }
    for _, key in ipairs(f_keys) do
        if keybinds[key] then
            print("  " .. key .. " = Cycle " .. keybinds[key])
        end
    end
    print("")

    -- All universal commands
    for _, category in ipairs(universal_commands) do
        print(category.category .. ":")
        for _, cmd in ipairs(category.commands) do
            print("  //gs c " .. cmd.cmd .. string.rep(" ", 18 - #cmd.cmd) .. "| " .. cmd.desc)
        end
        print("")
    end

    -- Job-specific commands (if they exist)
    local job_cmds = job_specific_commands[current_job]
    if job_cmds and #job_cmds > 0 then
        print(current_job .. " SPECIFIC:")
        for _, cmd in ipairs(job_cmds) do
            print("  //gs c " .. cmd.cmd .. string.rep(" ", 18 - #cmd.cmd) .. "| " .. cmd.desc)
        end
        print("")
    end

    -- Standard GearSwap
    print("STANDARD GEARSWAP:")
    print("  //gs r                  | Reload configuration")
    print("  //gs c info [1-3]       | Help system")
    print("  //gs c cycle <mode>     | Cycle any state")
    print("")
    print("=========================================================")
end

--- Handle help commands (to be called from job_self_command)
function CommandHelp.handle_help_command(cmdParams)
    if not cmdParams or #cmdParams == 0 then
        return false
    end

    local command = cmdParams[1]:lower()

    -- New info command with pagination
    if command == 'info' then
        local page = tonumber(cmdParams[2]) or 1
        CommandHelp.show_help_in_chat(page)
        return true
    end

    -- Help by specific categories
    if command == 'help' then
        local category = cmdParams[2] and cmdParams[2]:lower() or 'general'

        if category == 'metrics' or category == 'metriques' then
            windower.add_to_chat(160, "========= METRICS HELP =========")
            windower.add_to_chat(050, "//gs c metrics toggle    - Enable/disable")
            windower.add_to_chat(050, "//gs c metrics show      - Colored dashboard")
            windower.add_to_chat(050, "//gs c metrics export    - Save to JSON")
            windower.add_to_chat(050, "//gs c metrics reset     - Reset to zero")
            windower.add_to_chat(050, "//gs c metrics status    - View status")
            windower.add_to_chat(160, "==================================")
        elseif category == 'cache' then
            windower.add_to_chat(160, "========= CACHE HELP =========")
            windower.add_to_chat(050, "//gs c cache stats       - Statistics")
            windower.add_to_chat(050, "//gs c cache clear       - Clear cache")
            windower.add_to_chat(050, "//gs c cache cleanup     - Clean up old")
            windower.add_to_chat(160, "==============================")
        elseif category == 'keybinds' or category == 'keys' then
            local current_job = get_current_job()
            local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }
            windower.add_to_chat(160, "========= " .. current_job .. " SHORTCUTS =========")
            windower.add_to_chat(030, "F5 = " .. keybinds.F5)
            windower.add_to_chat(030, "F6 = " .. keybinds.F6)
            windower.add_to_chat(030, "//gs r = Reload config")
            windower.add_to_chat(160, "=====================================")
        else
            -- General help
            windower.add_to_chat(160, "========= HELP CATEGORIES =========")
            windower.add_to_chat(050, "//gs c help metrics      - Metrics help")
            windower.add_to_chat(050, "//gs c help cache        - Cache help")
            windower.add_to_chat(050, "//gs c help keys         - Keyboard shortcuts")
            windower.add_to_chat(050, "//gs c info              - Complete paginated help")
            windower.add_to_chat(160, "====================================")
        end

        return true
    end

    return false -- Not a help command
end

--- Display the list of testable commands
function CommandHelp.show_test_commands()
    local current_job = get_current_job()
    print("========== TESTABLE COMMANDS (" .. current_job .. ") ==========")
    print("//gs c cmd           - Brief help adapted to job")
    print("//gs c cmd full      - Complete help with details")
    print("//gs c metrics status - Metrics system status")
    print("//gs c cache stats   - Cache statistics")
    print("//gs c test          - Module unit tests")
    print("====================================================")
end

return CommandHelp
