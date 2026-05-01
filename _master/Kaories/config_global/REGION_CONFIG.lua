---============================================================================
--- Region Configuration - Kaories
---============================================================================
--- @file config/REGION_CONFIG.lua
--- @version 1.0
---============================================================================

local RegionConfig = {}

RegionConfig.characters = {
    ["Kaories"] = "EU", -- EU account (BQJS) - No orange (057)
}

RegionConfig.default_region = "EU"

function RegionConfig.get_region(name)
    if not name then return RegionConfig.default_region end
    return RegionConfig.characters[name] or RegionConfig.default_region
end

function RegionConfig.get_orange_code(reg)
    if reg == "EU" then return 002 else return 057 end
end

function RegionConfig.get_orange_for_character(name)
    return RegionConfig.get_orange_code(RegionConfig.get_region(name))
end

return RegionConfig
