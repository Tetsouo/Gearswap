---============================================================================
--- FFXI Monster Correlation System - BST Ecosystem Combat Reference
---============================================================================
--- Complete Monster Correlation database for Beastmaster tactical combat
--- optimization. Provides ecosystem-based strengths and weaknesses for
--- strategic pet selection and tactical advantage planning.
---
--- @file jobs/bst/monster_correlation.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-20
--- @requires jobs/bst/broth_pet_data.lua for ecosystem classification
---============================================================================

local MonsterCorrelation = {}

-- Ecosystem Classification Mapping
local ECOSYSTEM_CLASSIFICATION = {
    -- First Ecosystem Cycle
    ["Aquan"] = "aquan",
    ["Amorph"] = "amorph",
    ["Bird"] = "bird",

    -- Second Ecosystem Cycle
    ["Beast"] = "beast",
    ["Lizard"] = "lizard",
    ["Vermin"] = "vermin",
    ["Plantoid"] = "plantoid",

    -- Third Ecosystem (Reciprocal)
    ["Undead"] = "undead",
    ["Arcana"] = "arcana",

    -- Fourth Ecosystem (Reciprocal)
    ["Dragon"] = "dragon",
    ["Demon"] = "demon",

    -- Fifth Ecosystem (Reciprocal)
    ["Lumorian"] = "lumorian",
    ["Luminion"] = "luminion"
}

-- Monster Correlation Matrix
-- Each ecosystem shows what it's strong against and what it's weak to
local CORRELATION_MATRIX = {
    ---========================================================================
    --- FIRST ECOSYSTEM GROUP (Circular)
    ---========================================================================
    ["aquan"] = {
        strong_against = { "amorph" },
        weak_to = { "bird" },
        cycle_type = "circular",
        group = 1
    },
    ["amorph"] = {
        strong_against = { "bird" },
        weak_to = { "aquan" },
        cycle_type = "circular",
        group = 1
    },
    ["bird"] = {
        strong_against = { "aquan" },
        weak_to = { "amorph" },
        cycle_type = "circular",
        group = 1
    },

    ---========================================================================
    --- SECOND ECOSYSTEM GROUP (Circular)
    ---========================================================================
    ["beast"] = {
        strong_against = { "lizard" },
        weak_to = { "plantoid" },
        cycle_type = "circular",
        group = 2
    },
    ["lizard"] = {
        strong_against = { "vermin" },
        weak_to = { "beast" },
        cycle_type = "circular",
        group = 2
    },
    ["vermin"] = {
        strong_against = { "plantoid" },
        weak_to = { "lizard" },
        cycle_type = "circular",
        group = 2
    },
    ["plantoid"] = {
        strong_against = { "beast" },
        weak_to = { "vermin" },
        cycle_type = "circular",
        group = 2
    },

    ---========================================================================
    --- THIRD ECOSYSTEM GROUP (Reciprocal)
    ---========================================================================
    ["undead"] = {
        strong_against = { "arcana" },
        weak_to = { "arcana" },
        cycle_type = "reciprocal",
        group = 3
    },
    ["arcana"] = {
        strong_against = { "undead" },
        weak_to = { "undead" },
        cycle_type = "reciprocal",
        group = 3
    },

    ---========================================================================
    --- FOURTH ECOSYSTEM GROUP (Reciprocal)
    ---========================================================================
    ["dragon"] = {
        strong_against = { "demon" },
        weak_to = { "demon" },
        cycle_type = "reciprocal",
        group = 4
    },
    ["demon"] = {
        strong_against = { "dragon" },
        weak_to = { "dragon" },
        cycle_type = "reciprocal",
        group = 4
    },

    ---========================================================================
    --- FIFTH ECOSYSTEM GROUP (Reciprocal)
    ---========================================================================
    ["lumorian"] = {
        strong_against = { "luminion" },
        weak_to = { "luminion" },
        cycle_type = "reciprocal",
        group = 5
    },
    ["luminion"] = {
        strong_against = { "lumorian" },
        weak_to = { "lumorian" },
        cycle_type = "reciprocal",
        group = 5
    }
}

-- Ecosystem display names for user-friendly output
local ECOSYSTEM_DISPLAY_NAMES = {
    ["aquan"] = "Aquan",
    ["amorph"] = "Amorph",
    ["bird"] = "Bird",
    ["beast"] = "Beast",
    ["lizard"] = "Lizard",
    ["vermin"] = "Vermin",
    ["plantoid"] = "Plantoid",
    ["undead"] = "Undead",
    ["arcana"] = "Arcana",
    ["dragon"] = "Dragon",
    ["demon"] = "Demon",
    ["lumorian"] = "Lumorian",
    ["luminion"] = "Luminion"
}

---============================================================================
--- CORRELATION LOOKUP FUNCTIONS
---============================================================================

--- Get correlation data for a given ecosystem
--- @param ecosystem string The ecosystem name (case insensitive)
--- @return table|nil Correlation data or nil if not found
function MonsterCorrelation.get_ecosystem_correlation(ecosystem)
    if not ecosystem then return nil end

    local normalized = ecosystem:lower()
    return CORRELATION_MATRIX[normalized]
end

--- Get what an ecosystem is strong against
--- @param ecosystem string The ecosystem name
--- @return table List of ecosystem names this is strong against
function MonsterCorrelation.get_strengths(ecosystem)
    local correlation = MonsterCorrelation.get_ecosystem_correlation(ecosystem)
    if not correlation then return {} end

    local strengths = {}
    for _, target in ipairs(correlation.strong_against) do
        table.insert(strengths, ECOSYSTEM_DISPLAY_NAMES[target] or target)
    end

    return strengths
end

--- Get what an ecosystem is weak to
--- @param ecosystem string The ecosystem name
--- @return table List of ecosystem names this is weak to
function MonsterCorrelation.get_weaknesses(ecosystem)
    local correlation = MonsterCorrelation.get_ecosystem_correlation(ecosystem)
    if not correlation then return {} end

    local weaknesses = {}
    for _, threat in ipairs(correlation.weak_to) do
        table.insert(weaknesses, ECOSYSTEM_DISPLAY_NAMES[threat] or threat)
    end

    return weaknesses
end

--- Get correlation summary for display
--- @param ecosystem string The ecosystem name
--- @return string Formatted correlation summary
function MonsterCorrelation.get_correlation_summary(ecosystem)
    local strengths = MonsterCorrelation.get_strengths(ecosystem)
    local weaknesses = MonsterCorrelation.get_weaknesses(ecosystem)

    if #strengths == 0 and #weaknesses == 0 then
        return "No correlation data available"
    end

    local summary = {}

    if #strengths > 0 then
        table.insert(summary, "Strong vs: " .. table.concat(strengths, ", "))
    end

    if #weaknesses > 0 then
        table.insert(summary, "Weak to: " .. table.concat(weaknesses, ", "))
    end

    return table.concat(summary, " | ")
end

--- Get correlation summary with color formatting for BST messages
--- @param ecosystem string The ecosystem name
--- @return string Formatted correlation summary with colors
function MonsterCorrelation.get_correlation_summary_colored(ecosystem)
    local strengths = MonsterCorrelation.get_strengths(ecosystem)
    local weaknesses = MonsterCorrelation.get_weaknesses(ecosystem)

    if #strengths == 0 and #weaknesses == 0 then
        return "No correlation data available"
    end

    -- Color codes for BST messages
    local colorGray = string.char(0x1F, 160)   -- Gray for separators
    local colorStrong = string.char(0x1F, 030) -- Green for strengths
    local colorWeak = string.char(0x1F, 167)   -- Red for weaknesses
    local colorTarget = string.char(0x1F, 050) -- Yellow for target names

    local summary = {}

    if #strengths > 0 then
        table.insert(summary, colorStrong .. "Strong vs: " .. colorTarget .. table.concat(strengths, ", "))
    end

    if #weaknesses > 0 then
        table.insert(summary, colorWeak .. "Weak to: " .. colorTarget .. table.concat(weaknesses, ", "))
    end

    return table.concat(summary, colorGray .. " | ")
end

--- Check if two ecosystems are in the same correlation group
--- @param ecosystem1 string First ecosystem
--- @param ecosystem2 string Second ecosystem
--- @return boolean true if they're in the same group
function MonsterCorrelation.same_correlation_group(ecosystem1, ecosystem2)
    local corr1 = MonsterCorrelation.get_ecosystem_correlation(ecosystem1)
    local corr2 = MonsterCorrelation.get_ecosystem_correlation(ecosystem2)

    if not corr1 or not corr2 then return false end

    return corr1.group == corr2.group
end

--- Get all ecosystems in the same correlation group
--- @param ecosystem string The ecosystem name
--- @return table List of ecosystems in the same group
function MonsterCorrelation.get_group_ecosystems(ecosystem)
    local correlation = MonsterCorrelation.get_ecosystem_correlation(ecosystem)
    if not correlation then return {} end

    local group_ecosystems = {}
    for eco_name, eco_data in pairs(CORRELATION_MATRIX) do
        if eco_data.group == correlation.group then
            table.insert(group_ecosystems, ECOSYSTEM_DISPLAY_NAMES[eco_name] or eco_name)
        end
    end

    table.sort(group_ecosystems)
    return group_ecosystems
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Get all available ecosystems
--- @return table List of all ecosystem names
function MonsterCorrelation.get_all_ecosystems()
    local ecosystems = {}
    for ecosystem, _ in pairs(CORRELATION_MATRIX) do
        table.insert(ecosystems, ECOSYSTEM_DISPLAY_NAMES[ecosystem] or ecosystem)
    end
    table.sort(ecosystems)
    return ecosystems
end

--- Validate ecosystem name
--- @param ecosystem string The ecosystem name to validate
--- @return boolean true if valid ecosystem
function MonsterCorrelation.is_valid_ecosystem(ecosystem)
    if not ecosystem then return false end
    local normalized = ecosystem:lower()
    return CORRELATION_MATRIX[normalized] ~= nil
end

return MonsterCorrelation
