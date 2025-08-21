---============================================================================
--- Job Loader - Centralized Job Loading Messages System
---============================================================================
--- Centralized system for displaying job loading messages with keybinds.
--- Provides consistent, clean loading notifications across all jobs.
---
--- @file utils/job_loader.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-10
---============================================================================

local JobLoader = {}

-- Keybind definitions for each job based on actual states
-- F1-F7: Job-specific binds, F8: Reserved FFXI, F9-F12: GearSwap standard
local JOB_KEYBINDS = {
    WAR = {
        -- WAR F1-F2,F5 binds - focused and efficient
        "F1: WeaponSet",
        "F2: ammoSet",
        "F5: HybridMode",
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    BLM = {
        -- BLM F1-F7 dans l'ordre demandé
        "F1: MainLightSpell",
        "F2: MainDarkSpell",
        "F3: SubLightSpell",
        "F4: SubDarkSpell",
        "F5: Aja",
        "F6: TierSpell",
        "F7: Storm",
        -- BLM spéciaux (évite F10-F12 GearSwap)
        "F9: CastingMode",
        -- Standard GearSwap F10-F12 libres
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    PLD = {
        -- PLD F1-F3 keybinds
        "F1: HybridMode",
        "F2: WeaponSet",
        "F3: SubSet",
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    BST = {
        -- BST F1-F7 binds with HybridMode last
        "F1: AutoPetEngage",
        "F2: WeaponSet",
        "F3: SubSet",
        "F4: Ecosystem",
        "F5: Species",
        "F6: PetIdleMode",
        "F7: HybridMode",
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    DRG = {
        -- DRG keybinds will be updated when checked
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    RUN = {
        -- RUN keybinds will be updated when checked
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    DNC = {
        -- DNC keybinds will be updated when checked
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    THF = {
        -- THF F1-F6 binds for treasure hunter and combat optimization
        "F1: WeaponSet1",
        "F2: SubSet",
        "F3: AbysseaProc",
        "F4: WeaponSet2",
        "F5: HybridMode",
        "F6: TreasureMode",
        -- Standard GearSwap F9-F12
        "F9: OffenseMode",
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    },
    BRD = {
        -- BRD F1-F7,F9 binds selon les nouvelles spécifications
        "F1: BRD Song Packs",
        "F2: Victory March Mode",
        "F3: Etude Type",
        "F4: Carol Element",
        "F5: Threnody Element",
        "F6: MainWeapon",
        "F7: SubWeapon",
        "F9: HybridMode",
        -- Standard GearSwap F10-F12
        "F10: DefenseMode Physical",
        "F11: DefenseMode Magical",
        "F12: State Summary"
    }
}

-- Color codes
local COLORS = {
    success = 158,     -- Green success message
    warning = 167,     -- Red warning message
    keybind_key = 050, -- Yellow for key combinations (F1, Alt+F1, etc.)
    keybind_text = 001 -- White for description text
}

---============================================================================
--- MAIN LOADING FUNCTION
---============================================================================

--- Display job loading message with keybinds
--- @param job_name string The job name (e.g., "WAR", "BLM")
--- @param success boolean Whether the job loaded successfully (default: true)
function JobLoader.show_loaded_message(job_name, success)
    success = success == nil and true or success -- Default to true if not specified

    -- Show main loading message
    if success then
        windower.add_to_chat(COLORS.success, job_name .. " loaded successfully")
    else
        windower.add_to_chat(COLORS.warning, job_name .. " loaded with warnings")
    end

    -- Show keybinds for this job with formatted colors
    local keybinds = JOB_KEYBINDS[job_name]
    if keybinds then
        for _, keybind in ipairs(keybinds) do
            -- Split keybind into key and description (format: "F1: Description")
            local key, description = keybind:match("^([^:]+):%s*(.+)$")
            if key and description then
                -- Create color codes like in messages.lua
                local yellowColor = string.char(0x1F, COLORS.keybind_key)
                local whiteColor = string.char(0x1F, COLORS.keybind_text)

                -- Align all keys to same width for perfect alignment
                local formatted_key = key
                -- Add space after single-digit F keys (F1-F9) to align with F10-F12
                if key:match("^F[1-9]$") then
                    formatted_key = key .. " " -- F1 becomes "F1 "
                end
                local aligned_key = string.format("%-4s", formatted_key)
                local formatted_text = yellowColor .. "- " .. aligned_key .. ": " .. whiteColor .. description
                windower.add_to_chat(207, formatted_text)
            else
                -- Fallback for malformed keybinds
                windower.add_to_chat(COLORS.keybind_key, "- " .. keybind)
            end
        end
    end
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Add keybinds for a job (useful for dynamic jobs or testing)
--- @param job_name string The job name
--- @param keybinds table Array of keybind strings
function JobLoader.add_job_keybinds(job_name, keybinds)
    JOB_KEYBINDS[job_name] = keybinds
end

--- Get keybinds for a specific job
--- @param job_name string The job name
--- @return table Array of keybind strings or nil if not found
function JobLoader.get_job_keybinds(job_name)
    return JOB_KEYBINDS[job_name]
end

--- Show keybinds only (without loading message)
--- @param job_name string The job name
function JobLoader.show_keybinds_only(job_name)
    local keybinds = JOB_KEYBINDS[job_name]
    if keybinds then
        for _, keybind in ipairs(keybinds) do
            -- Split keybind into key and description (format: "F1: Description")
            local key, description = keybind:match("^([^:]+):%s*(.+)$")
            if key and description then
                -- Create color codes like in messages.lua
                local yellowColor = string.char(0x1F, COLORS.keybind_key)
                local whiteColor = string.char(0x1F, COLORS.keybind_text)

                -- Align all keys to same width for perfect alignment
                local formatted_key = key
                -- Add space after single-digit F keys (F1-F9) to align with F10-F12
                if key:match("^F[1-9]$") then
                    formatted_key = key .. " " -- F1 becomes "F1 "
                end
                local aligned_key = string.format("%-4s", formatted_key)
                local formatted_text = yellowColor .. "- " .. aligned_key .. ": " .. whiteColor .. description
                windower.add_to_chat(207, formatted_text)
            else
                -- Fallback for malformed keybinds
                windower.add_to_chat(COLORS.keybind_key, "- " .. keybind)
            end
        end
    else
        windower.add_to_chat(COLORS.keybind_key, "- No specific keybinds configured")
    end
end

--- Update color scheme
--- @param color_table table Table with success, warning, keybind color codes
function JobLoader.set_colors(color_table)
    for key, value in pairs(color_table) do
        if COLORS[key] then
            COLORS[key] = value
        end
    end
end

return JobLoader
