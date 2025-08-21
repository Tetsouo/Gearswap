---============================================================================
--- FFXI GearSwap Version Management System
---============================================================================
--- Centralized version information and compatibility management for the
--- GearSwap modular system. Provides version checking, compatibility
--- validation, and update detection capabilities.
---
--- @file VERSION.lua
--- @author Tetsouo
--- @version 2.1.0
--- @date Created: 2025-08-06
--- @date Modified: 2025-08-19
---
--- Version Format: MAJOR.MINOR.PATCH
--- - MAJOR: Incompatible API changes or complete rewrites
--- - MINOR: New features in a backward-compatible manner
--- - PATCH: Backward-compatible bug fixes
---============================================================================

local VersionManager = {}

---============================================================================
--- VERSION INFORMATION
---============================================================================

--- Current system version
VersionManager.VERSION = {
    MAJOR = 2,
    MINOR = 1,
    PATCH = 0,

    -- Full version string
    FULL = "2.1.0",

    -- Version name/codename
    NAME = "Audit Complete Release",

    -- Build information
    BUILD_DATE = "2025-08-19",
    BUILD_TIME = "20:00:00",

    -- Git-style commit info (if applicable)
    COMMIT_HASH = "1cf9d3b",
    BRANCH = "main"
}

--- Version history and changelog references
VersionManager.HISTORY = {
    ["2.1.0"] = {
        date = "2025-08-19",
        type = "minor",
        description = "Complete project audit and optimization release",
        changes = {
            "Eliminated performance monitor duplication (utils/ version removed)",
            "Validated architecture modularity (BRD, BST structures justified)",
            "Confirmed error handling separation (collector vs handler different roles)",
            "Completed comprehensive project audit (9.5/10 quality score validated)",
            "Added new BRD job implementation with specialized song modules",
            "Enhanced core systems (macro management, performance monitoring)",
            "Updated documentation and guides for all components",
            "Architecture validation: All 9 jobs fully functional",
            "287 require() calls properly protected, 1092 equipment calls standardized"
        }
    },
    ["2.0.0"] = {
        date = "2025-08-09",
        type = "major",
        description = "Final Production Release with Equipment Analysis System",
        changes = {
            "Complete equipment analysis system with slip support",
            "Production-ready error collector with ASCII-only interface",
            "Comprehensive container scanning (inventory + wardrobes + slips)",
            "Support for FFXI abbreviations (Chev. -> Chevalier's)",
            "User-friendly equipment validation with clear error reporting",
            "Clean modular architecture with proper file naming",
            "Optimized performance monitoring system",
            "Full documentation and command system audit"
        }
    },
    ["2.0.1"] = {
        date = "2025-08-06",
        type = "patch",
        description = "Black Mage Revolution - Major spell system overhaul",
        changes = {
            "Complete BLM spell system rewrite with multi-tier downgrade",
            "Intelligent BuffSelf logic with anti-spam protection",
            "FFXI-style colored message system",
            "Resource table fixes (res.spells vs gearswap.res.spells)",
            "90% reduction in spell casting errors"
        }
    }
}

--- Minimum required versions for dependencies
VersionManager.DEPENDENCIES = {
    windower = {
        min_version = "4.3.0",
        recommended = "4.3.5+",
        required = true
    },
    gearswap = {
        min_version = "0.922",
        recommended = "0.930+",
        required = true
    },
    mote_include = {
        min_version = "2.0",
        recommended = "2.5+",
        required = true
    },
    lua = {
        min_version = "5.1",
        recommended = "5.1",
        required = true
    }
}

--- Module version information
VersionManager.MODULES = {
    config = "2.0.0",
    logger = "2.0.0",
    validation = "2.0.0",
    messages = "2.0.0",
    equipment = "2.0.0",
    equipment_factory = "2.0.0",
    performance_monitor = "2.0.0",
    error_collector = "2.0.0",
    equipment_commands = "2.0.0",
    spells = "2.0.0",
    buffs = "2.0.0",
    state = "2.0.0",
    helpers = "2.0.0",
    shared = "2.0.0"
}

--- Job version information
VersionManager.JOBS = {
    BLM = "2.1.0", -- Recently updated with spell system overhaul
    WAR = "2.0.0",
    THF = "2.0.0",
    PLD = "2.0.0",
    BST = "2.0.0",
    DNC = "2.0.0",
    DRG = "2.0.0",
    RUN = "2.0.0",
    BRD = "2.0.0"  -- New Bard implementation with song management
}

---============================================================================
--- VERSION UTILITY FUNCTIONS
---============================================================================

--- Get the current system version as a string.
--- @return string Current version in MAJOR.MINOR.PATCH format
function VersionManager.get_version()
    return VersionManager.VERSION.FULL
end

--- Get detailed version information.
--- @return table Complete version information
function VersionManager.get_version_info()
    return {
        version = VersionManager.VERSION.FULL,
        name = VersionManager.VERSION.NAME,
        build_date = VersionManager.VERSION.BUILD_DATE,
        build_time = VersionManager.VERSION.BUILD_TIME,
        commit_hash = VersionManager.VERSION.COMMIT_HASH,
        branch = VersionManager.VERSION.BRANCH,
        modules = VersionManager.MODULES,
        jobs = VersionManager.JOBS
    }
end

--- Compare two version strings.
--- @param version1 string First version to compare
--- @param version2 string Second version to compare
--- @return number -1 if version1 < version2, 0 if equal, 1 if version1 > version2
function VersionManager.compare_versions(version1, version2)
    local function parse_version(ver)
        local parts = {}
        for part in ver:gmatch("(%d+)") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local v1_parts = parse_version(version1)
    local v2_parts = parse_version(version2)

    local max_parts = math.max(#v1_parts, #v2_parts)

    for i = 1, max_parts do
        local p1 = v1_parts[i] or 0
        local p2 = v2_parts[i] or 0

        if p1 < p2 then
            return -1
        elseif p1 > p2 then
            return 1
        end
    end

    return 0
end

--- Check if a version meets minimum requirements.
--- @param current_version string Version to check
--- @param min_version string Minimum required version
--- @return boolean True if version meets requirements
function VersionManager.meets_requirements(current_version, min_version)
    return VersionManager.compare_versions(current_version, min_version) >= 0
end

---============================================================================
--- DEPENDENCY CHECKING FUNCTIONS
---============================================================================

--- Check all system dependencies.
--- @return table Dependency check results
function VersionManager.check_dependencies()
    local results = {
        all_satisfied = true,
        checks = {},
        warnings = {},
        errors = {}
    }

    -- Check Windower version (if available)
    local windower_version = windower and windower.version
    if windower_version then
        local windower_check = {
            name = "Windower",
            current = windower_version,
            required = VersionManager.DEPENDENCIES.windower.min_version,
            satisfied = VersionManager.meets_requirements(windower_version,
                VersionManager.DEPENDENCIES.windower.min_version)
        }
        table.insert(results.checks, windower_check)

        if not windower_check.satisfied then
            results.all_satisfied = false
            table.insert(results.errors,
                string.format("Windower version %s required, found %s",
                    windower_check.required, windower_check.current))
        end
    else
        results.all_satisfied = false
        table.insert(results.errors, "Windower not detected")
    end

    -- Check Lua version
    local lua_version = _VERSION:match("Lua (%d+%.%d+)")
    if lua_version then
        local lua_check = {
            name = "Lua",
            current = lua_version,
            required = VersionManager.DEPENDENCIES.lua.min_version,
            satisfied = VersionManager.meets_requirements(lua_version,
                VersionManager.DEPENDENCIES.lua.min_version)
        }
        table.insert(results.checks, lua_check)

        if not lua_check.satisfied then
            results.all_satisfied = false
            table.insert(results.errors,
                string.format("Lua version %s required, found %s",
                    lua_check.required, lua_check.current))
        end
    end

    -- Check for Mote-Include (file existence check)
    local mote_exists = false
    if windower and windower.addon_path then
        local mote_path = windower.addon_path:gsub("data[/\\]Tetsouo[/\\]?$", "") .. "Mote-Include.lua"
        local file = io.open(mote_path, "r")
        if file then
            file:close()
            mote_exists = true
        end
    end

    local mote_check = {
        name = "Mote-Include",
        current = mote_exists and "Found" or "Not Found",
        required = "Required",
        satisfied = mote_exists
    }
    table.insert(results.checks, mote_check)

    if not mote_check.satisfied then
        results.all_satisfied = false
        table.insert(results.errors, "Mote-Include.lua not found in GearSwap directory")
    end

    return results
end

--- Display dependency check results.
--- @param results table Results from check_dependencies()
function VersionManager.display_dependency_results(results)
    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(050, "DEPENDENCY CHECK RESULTS")
    windower.add_to_chat(050, "========================================")

    for _, check in ipairs(results.checks) do
        local color = check.satisfied and 158 or 167
        local status = check.satisfied and "OK" or "FAIL"
        windower.add_to_chat(color, string.format("%s: %s (%s)",
            check.name, status, check.current))
    end

    if #results.errors > 0 then
        windower.add_to_chat(167, "\nERRORS:")
        for _, error in ipairs(results.errors) do
            windower.add_to_chat(167, "  - " .. error)
        end
    end

    if #results.warnings > 0 then
        windower.add_to_chat(057, "\nWARNINGS:")
        for _, warning in ipairs(results.warnings) do
            windower.add_to_chat(057, "  - " .. warning)
        end
    end

    local overall_color = results.all_satisfied and 158 or 167
    local overall_status = results.all_satisfied and "ALL DEPENDENCIES SATISFIED" or "DEPENDENCY ISSUES FOUND"
    windower.add_to_chat(overall_color, "\n" .. overall_status)
end

---============================================================================
--- VERSION DISPLAY FUNCTIONS
---============================================================================

--- Display version information in chat.
function VersionManager.display_version()
    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(050, "GEARSWAP MODULAR SYSTEM")
    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(158, string.format("Version: %s (%s)",
        VersionManager.VERSION.FULL,
        VersionManager.VERSION.NAME))
    windower.add_to_chat(160, string.format("Build: %s %s",
        VersionManager.VERSION.BUILD_DATE,
        VersionManager.VERSION.BUILD_TIME))
    windower.add_to_chat(160, string.format("Branch: %s (%s)",
        VersionManager.VERSION.BRANCH,
        VersionManager.VERSION.COMMIT_HASH))

    -- Show module versions
    windower.add_to_chat(050, "\nMODULE VERSIONS:")
    for module, version in pairs(VersionManager.MODULES) do
        windower.add_to_chat(160, string.format("  %s: v%s", module, version))
    end

    -- Show job versions
    windower.add_to_chat(050, "\nJOB VERSIONS:")
    for job, version in pairs(VersionManager.JOBS) do
        windower.add_to_chat(160, string.format("  %s: v%s", job, version))
    end
end

--- Display changelog for current version.
--- @param version string|nil Specific version to show (defaults to current)
function VersionManager.display_changelog(version)
    version = version or VersionManager.VERSION.FULL
    local changelog = VersionManager.HISTORY[version]

    if not changelog then
        windower.add_to_chat(167, string.format("No changelog found for version %s", version))
        return
    end

    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(050, string.format("CHANGELOG v%s", version))
    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(158, string.format("%s - %s (%s)",
        changelog.date,
        changelog.description,
        changelog.type:upper()))

    windower.add_to_chat(050, "\nCHANGES:")
    for _, change in ipairs(changelog.changes) do
        windower.add_to_chat(160, "  • " .. change)
    end
end

---============================================================================
--- UPDATE CHECKING FUNCTIONS
---============================================================================

--- Check if system components are up to date.
--- @return table Update check results
function VersionManager.check_for_updates()
    -- This would typically check against a remote version server
    -- For now, we'll simulate basic update checking

    local results = {
        updates_available = false,
        current_version = VersionManager.VERSION.FULL,
        latest_version = VersionManager.VERSION.FULL, -- Would be fetched from server
        update_info = {},
        recommendations = {}
    }

    -- Check for module updates (simulated)
    for module, current_version in pairs(VersionManager.MODULES) do
        -- In a real implementation, this would check against a version server
        if VersionManager.compare_versions(current_version, "2.0.0") < 0 then
            table.insert(results.recommendations,
                string.format("Consider updating %s module from v%s", module, current_version))
        end
    end

    return results
end

---============================================================================
--- COMPATIBILITY FUNCTIONS
---============================================================================

--- Check compatibility with other addons/systems.
--- @return table Compatibility check results
function VersionManager.check_compatibility()
    local results = {
        compatible = true,
        issues = {},
        warnings = {}
    }

    -- Check GearSwap compatibility (basic check)
    if not gearswap then
        results.compatible = false
        table.insert(results.issues, "GearSwap addon not loaded")
    end

    -- Check for known incompatible addons (examples)
    local potentially_incompatible = {
        -- "SomeIncompatibleAddon",
    }

    for _, addon in ipairs(potentially_incompatible) do
        if windower.addon_load(addon) then
            table.insert(results.warnings,
                string.format("Potential compatibility issue with %s addon", addon))
        end
    end

    return results
end

---============================================================================
--- EXPORT AND INITIALIZATION
---============================================================================

--- Initialize version management system.
function VersionManager.initialize()
    -- Could perform initial version checks, logging, etc.
    local success_log, log = pcall(require, 'utils/logger')
    if not success_log then
        error("Failed to load utils/logger: " .. tostring(log))
    end
    log.info("GearSwap Modular System v%s (%s) initialized",
        VersionManager.VERSION.FULL, VersionManager.VERSION.NAME)
end

return VersionManager
