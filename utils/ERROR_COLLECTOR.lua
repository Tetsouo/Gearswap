---============================================================================
--- Error Collector - Equipment Analysis System
---============================================================================
--- Production system that analyzes equipment sets and validates item
--- availability across all containers including porter moogle slips.
---
--- @file utils/error_collector.lua
--- @author Tetsouo
--- @version 2.0
--- @date 2025-08-09
---============================================================================

local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end
local success_slips, slips = pcall(require, 'slips')
if not success_slips then
    error("Failed to load slips: " .. tostring(slips))
end
local json = nil

-- Safe JSON loading
local success, json_result = pcall(require, 'utils/JSON')
if success and json_result then
    json = json_result
end

local ErrorCollector = {}

-- ============================================================================
-- VARIABLES AND STATE
-- ============================================================================
local captured_errors = {}
local collecting = false

-- System cache
local item_database_cache = {}
local inventory_cache = {}
local cache_initialized = false

-- Colors for reports (optimized for readability)
local colors = {
    system = 001,   -- White
    success = 030,  -- Bright green
    warning = 220,  -- Orange/Yellow
    error = 167,    -- Bright red
    info = 159,     -- Light blue
    header = 050,   -- Golden yellow
    separator = 160 -- Gray
}

-- ============================================================================
-- ITEM DATABASE INITIALIZATION
-- ============================================================================
--- Initialize the item database cache for efficient lookups.
--- Builds a cached index of all FFXI items for fast equipment validation.
--- @return boolean True if initialization successful, false on error
local function initialize_item_database()
    if cache_initialized then return true end

    if not res or not res.items then
        windower.add_to_chat(colors.error, "[ERROR] Resources/items database not available")
        return false
    end
    item_database_cache = {}
    local count = 0

    -- Build item cache with all name variants
    for id, item in pairs(res.items) do
        if item.en and item.en ~= "" then
            -- Standard English name (priority)
            local en_key = item.en:lower()
            item_database_cache[en_key] = {
                id = id,
                name = item.en,
                name_log = item.enl or item.en
            }
            count = count + 1
        end

        if item.enl and item.enl ~= "" and item.enl:lower() ~= (item.en and item.en:lower()) then
            -- English log name (long version) - ONLY if different
            local enl_key = item.enl:lower()
            if not item_database_cache[enl_key] then -- Avoid overwriting
                item_database_cache[enl_key] = {
                    id = id,
                    name = item.en, -- Keep short name as reference
                    name_log = item.enl
                }
            end
        end
    end

    cache_initialized = true
    return true
end

-- ============================================================================
-- UNIVERSAL ITEM EXTRACTION FROM SETS
-- ============================================================================
local function extract_item_name_universal(item_data)
    if not item_data then return nil end

    -- Special case: if item_data is FFXI's global 'empty' object
    if item_data == empty then return nil end

    local item_type = type(item_data)

    -- Format 1: String simple
    if item_type == 'string' then
        local lower_item = item_data:lower()
        if item_data ~= "" and
            lower_item ~= "empty" and
            lower_item ~= "none" and
            lower_item ~= "nil" and
            lower_item ~= "disable" and
            lower_item ~= "disabled" then
            return item_data
        end
        return nil
    end

    -- Format 2: Table (all possible formats)
    if item_type == 'table' then
        -- Method 1: 'name' field
        if item_data.name and type(item_data.name) == 'string' then
            return item_data.name
        end

        -- Method 2: First element of array
        if item_data[1] and type(item_data[1]) == 'string' then
            return item_data[1]
        end

        -- Method 3: Other possible fields
        for _, field in ipairs({ 'item_name', 'english', 'en' }) do
            if item_data[field] and type(item_data[field]) == 'string' then
                return item_data[field]
            end
        end

        -- Method 4: Loop through all string fields
        for key, value in pairs(item_data) do
            if type(value) == 'string' and value ~= "" then
                local lower_value = value:lower()
                if lower_value ~= "empty" and
                    lower_value ~= "none" and
                    lower_value ~= "nil" and
                    lower_value ~= "disable" and
                    lower_value ~= "disabled" then
                    return value
                end
            end
        end
    end

    return nil
end

-- ============================================================================
-- DIRECT SET ANALYSIS WITHOUT NAVIGATION
-- ============================================================================
local function analyze_sets_directly()
    if not sets or type(sets) ~= 'table' then
        windower.add_to_chat(colors.error, "[ERROR] Sets table not available")
        return {}
    end


    local all_items = {} -- {item_name, set_path, slot}
    local sets_found = 0

    -- Standard equipment slots
    local equipment_slots = {
        'main', 'sub', 'range', 'ammo', 'head', 'neck',
        'ear1', 'ear2', 'left_ear', 'right_ear',
        'body', 'hands', 'ring1', 'ring2', 'left_ring', 'right_ring',
        'back', 'waist', 'legs', 'feet'
    }

    -- Recursive function to scan all sets
    local function scan_table_recursive(table_ref, current_path)
        if type(table_ref) ~= 'table' then return end

        -- IGNORE special sets (naked, empty, disable, etc.)
        local path_lower = current_path:lower()
        local ignore_patterns = {
            'naked', 'empty', 'disable', 'disabled', 'none', 'nil'
        }

        for _, pattern in ipairs(ignore_patterns) do
            if path_lower:find(pattern) then
                return -- Completely ignore this set
            end
        end

        -- Check if this table looks like an equipment set
        local has_equipment_slots = false
        local equipment_found = 0
        local valid_items_found = 0

        for _, slot in ipairs(equipment_slots) do
            if table_ref[slot] then
                equipment_found = equipment_found + 1
                has_equipment_slots = true

                -- Check if it's a valid item (not empty)
                local item_name = extract_item_name_universal(table_ref[slot])
                if item_name then
                    valid_items_found = valid_items_found + 1
                end
            end
        end

        -- If it's an equipment set with at least 1 valid item
        if has_equipment_slots and valid_items_found > 0 then
            sets_found = sets_found + 1

            -- Extract all valid items from this set
            for _, slot in ipairs(equipment_slots) do
                if table_ref[slot] then
                    local item_name = extract_item_name_universal(table_ref[slot])
                    if item_name then -- extract_item_name_universal already filters empty items
                        table.insert(all_items, {
                            item_name = item_name,
                            set_path = current_path,
                            slot = slot
                        })
                    end
                end
            end
        elseif not has_equipment_slots then
            -- Continue scanning in depth
            for key, value in pairs(table_ref) do
                if type(value) == 'table' and type(key) == 'string' then
                    local new_path = current_path .. "." .. key
                    scan_table_recursive(value, new_path)
                end
            end
        end
    end

    -- Scan from root
    scan_table_recursive(sets, "sets")


    return all_items
end

-- ============================================================================
-- COMPLETE ITEM LOCATION SYSTEM
-- ============================================================================
local function build_complete_inventory_map()
    local success, inventory = pcall(windower.ffxi.get_items)
    if not success then
        windower.add_to_chat(colors.error, string.format("[ERROR] Failed to get inventory: %s", tostring(inventory)))
        return {}
    end

    if not inventory then
        windower.add_to_chat(colors.error, "[ERROR] Inventory is nil")
        return {}
    end

    local item_locations = {}

    -- All possible containers
    local containers = {
        -- Equippable (accessible)
        { name = 'inventory', accessible = true },
        { name = 'wardrobe',  accessible = true },
        { name = 'wardrobe2', accessible = true },
        { name = 'wardrobe3', accessible = true },
        { name = 'wardrobe4', accessible = true },
        { name = 'wardrobe5', accessible = true },
        { name = 'wardrobe6', accessible = true },
        { name = 'wardrobe7', accessible = true },
        { name = 'wardrobe8', accessible = true },

        -- Storage (non-equippable)
        { name = 'safe',      accessible = false },
        { name = 'safe2',     accessible = false },
        { name = 'storage',   accessible = false },
        { name = 'locker',    accessible = false },
        { name = 'satchel',   accessible = false },
        { name = 'sack',      accessible = false },
        { name = 'case',      accessible = false },
    }

    -- Add porter slips (according to findAll.lua)
    local slip_storages = slips.get_player_items()
    for _, slip_id in ipairs(slips.storages) do
        local slip_number = slips.get_slip_number_by_id(slip_id)
        if slip_number then
            table.insert(containers, {
                name = string.format('slip%02d', slip_number),
                accessible = false,
                is_slip = true,
                slip_id = slip_id
            })
        end
    end

    local total_items_found = 0

    for _, container in ipairs(containers) do
        local items_in_bag = 0

        -- Special handling for slips
        if container.is_slip and container.slip_id then
            local slip_items = slip_storages[container.slip_id]
            if slip_items then
                for _, item_id in ipairs(slip_items) do
                    local item_info = res.items[item_id]
                    if item_info and item_info.en then
                        local item_key = item_info.en:lower()

                        -- Create location object for slip
                        local location_info = {
                            container = container.name,
                            accessible = container.accessible,
                            item_name = item_info.en,
                            quantity = 1 -- Slips contain 1 of each
                        }

                        -- Store with primary key (item_key = short name in lowercase)
                        if not item_locations[item_key] or container.accessible then
                            item_locations[item_key] = location_info
                        end

                        -- ALSO store with long name (enl) if different
                        if item_info.enl and item_info.enl:lower() ~= item_key then
                            local enl_key = item_info.enl:lower()
                            if not item_locations[enl_key] or container.accessible then
                                item_locations[enl_key] = location_info
                            end
                        end

                        -- ALSO store with expanded versions of common abbreviations
                        local abbreviations = {
                            ["chev%."] = "chevalier's",
                            ["chevs%."] = "chevalier's",
                            ["chev "] = "chevalier's ",
                            ["chevs "] = "chevalier's "
                        }

                        for abbrev, full in pairs(abbreviations) do
                            local expanded_name = item_key:gsub(abbrev, full)
                            if expanded_name ~= item_key then -- Only if different
                                if not item_locations[expanded_name] or container.accessible then
                                    item_locations[expanded_name] = location_info
                                end
                            end
                        end

                        items_in_bag = items_in_bag + 1
                        total_items_found = total_items_found + 1
                    end
                end
            end
        else
            -- Normal container handling (non-slips)
            local bag = inventory[container.name]
            if bag and bag.max and bag.max > 0 then
                for slot = 1, bag.max do
                    local item_slot = bag[slot]
                    if item_slot and item_slot.id and item_slot.id > 0 then
                        local item_info = res.items[item_slot.id]
                        if item_info and item_info.en then
                            local item_key = item_info.en:lower()

                            -- Create location object only once
                            local location_info = {
                                container = container.name,
                                accessible = container.accessible,
                                item_name = item_info.en,
                                quantity = item_slot.count or 1
                            }

                            -- Store with primary key (item_key = short name in lowercase)
                            if not item_locations[item_key] or container.accessible then
                                item_locations[item_key] = location_info
                            end

                            -- ALSO store with long name (enl) if different
                            if item_info.enl and item_info.enl:lower() ~= item_key then
                                local enl_key = item_info.enl:lower()
                                if not item_locations[enl_key] or container.accessible then
                                    item_locations[enl_key] = location_info
                                end
                            end

                            -- ALSO store with expanded versions of common abbreviations
                            local abbreviations = {
                                ["chev%."] = "chevalier's",
                                ["chevs%."] = "chevalier's",
                                ["chev "] = "chevalier's ",
                                ["chevs "] = "chevalier's "
                            }

                            for abbrev, full in pairs(abbreviations) do
                                local expanded_name = item_key:gsub(abbrev, full)
                                if expanded_name ~= item_key then -- Only if different
                                    if not item_locations[expanded_name] or container.accessible then
                                        item_locations[expanded_name] = location_info
                                    end
                                end
                            end

                            items_in_bag = items_in_bag + 1
                            total_items_found = total_items_found + 1
                        end
                    end
                end
            end
        end
    end

    return item_locations
end

-- ============================================================================
-- COMPLETE ITEM VALIDATION - CASE INSENSITIVE
-- ============================================================================
local function validate_item_complete(item_name, set_path, slot)
    local errors = {}

    -- Step 1: Check that item exists in database (case insensitive)
    local original_item_key = item_name:lower()
    local item_db_info = item_database_cache[original_item_key]
    local final_item_key = original_item_key -- Key to use for inventory

    if not item_db_info then
        -- CASE INSENSITIVE SEARCH + FFXI ABBREVIATIONS
        local found_item = nil
        local item_clean = original_item_key:gsub("[%s%+%-%.%'\",%(%)]", ""):lower()

        -- Table of common FFXI abbreviations
        local abbreviations = {
            ["chev"] = "chevalier",
            ["chevs"] = "chevaliers",
            ["sakpatas"] = "sakpata's",
            ["sakpata"] = "sakpata's",
            ["kgt"] = "knight",
            ["knights"] = "knight's",
            ["ambu"] = "ambuscade",
            ["rev"] = "reverence",
            ["revere"] = "reverence",
            ["ody"] = "odyssean",
            ["odyss"] = "odyssean",
            ["mer"] = "merlinic",
            ["meri"] = "merlinic",
            ["herc"] = "herculean"
        }


        -- Step 1: Exact search (cleaning only)
        for db_key, db_info in pairs(item_database_cache) do
            local db_clean = db_key:gsub("[%s%+%-%.%'\",%(%)]", ""):lower()
            if db_clean == item_clean then
                found_item = db_info
                final_item_key = db_key
                break
            end
        end

        -- Step 2: Search with abbreviation expansion
        if not found_item then
            local expanded_item = item_name:lower()

            -- Apply abbreviation replacements
            for abbrev, full in pairs(abbreviations) do
                expanded_item = expanded_item:gsub("^" .. abbrev .. "%.", full .. "s ") -- "Chev." -> "Chevaliers "
                expanded_item = expanded_item:gsub("^" .. abbrev .. " ", full .. " ")   -- "Chev " -> "Chevalier "
                expanded_item = expanded_item:gsub(" " .. abbrev .. "%.", " " .. full .. "s ")
                expanded_item = expanded_item:gsub(" " .. abbrev .. " ", " " .. full .. " ")
            end

            local expanded_clean = expanded_item:gsub("[%s%+%-%.%'\",%(%)]", ""):lower()

            for db_key, db_info in pairs(item_database_cache) do
                local db_clean = db_key:gsub("[%s%+%-%.%'\",%(%)]", ""):lower()
                if db_clean == expanded_clean then
                    found_item = db_info
                    final_item_key = db_key
                    break
                end
            end
        end

        if found_item then
            item_db_info = found_item
        else
            -- Really not found
            table.insert(errors, {
                type = "invalid_item",
                message = string.format("[%s] %s: Item not found in FFXI database", slot, item_name),
                set_path = set_path,
                slot = slot,
                item_name = item_name
            })
            return errors
        end
    end

    -- Step 2: Search for item in inventory with the right key
    local item_location = inventory_cache[final_item_key]

    if not item_location then
        table.insert(errors, {
            type = "missing_item",
            message = string.format("[%s] %s: Not found in any container", slot, item_name),
            set_path = set_path,
            slot = slot,
            item_name = item_name
        })
    elseif not item_location.accessible then
        table.insert(errors, {
            type = "item_in_storage",
            message = string.format("[%s] %s: Found in %s (move to inventory/wardrobe to equip)",
                slot, item_name, item_location.container:upper()),
            set_path = set_path,
            slot = slot,
            item_name = item_name,
            location = item_location.container
        })
    end
    -- If accessible, no error

    return errors
end

-- ============================================================================
-- MAIN FUNCTIONS
-- ============================================================================
function ErrorCollector.start_collecting()
    captured_errors = {}
    collecting = true

    -- Completely reset caches on each startup
    cache_initialized = false
    item_database_cache = {}
    inventory_cache = {}


    -- Silent initialization
    if not initialize_item_database() then
        windower.add_to_chat(colors.error, "Error: FFXI database inaccessible")
        return false
    end

    inventory_cache = build_complete_inventory_map()
    local all_items = analyze_sets_directly()

    if #all_items == 0 then
        windower.add_to_chat(colors.warning, "No items found in your sets")
        return false
    end

    -- Validate each item
    local total_errors = 0
    for _, item_info in ipairs(all_items) do
        local item_errors = validate_item_complete(
            item_info.item_name,
            item_info.set_path,
            item_info.slot
        )

        for _, error in ipairs(item_errors) do
            table.insert(captured_errors, error)
            total_errors = total_errors + 1
        end
    end


    return true
end

function ErrorCollector.show_report()
    windower.add_to_chat(colors.header, "================================")
    windower.add_to_chat(colors.header, "         Equipment Analysis")
    windower.add_to_chat(colors.header, "================================")

    if #captured_errors == 0 then
        windower.add_to_chat(colors.success, "No problems detected")
        return
    end

    -- Count error types (IGNORE case mismatch)
    local counts = { missing = 0, storage = 0, invalid = 0 }

    for _, error in ipairs(captured_errors) do
        if error.type == "missing_item" then
            counts.missing = counts.missing + 1
        elseif error.type == "item_in_storage" then
            counts.storage = counts.storage + 1
        elseif error.type == "invalid_item" then
            counts.invalid = counts.invalid + 1
        end
        -- case_mismatch completely ignored
    end

    windower.add_to_chat(colors.error, string.format("Problems detected: %d Items", #captured_errors))

    -- Display errors in detail
    for _, error in ipairs(captured_errors) do
        local color = colors.error
        if error.type == "item_in_storage" then
            color = colors.warning
        end

        -- Detailed message as requested
        local item_name = error.item_name or "Unknown item"
        local detail = ""

        if error.type == "item_in_storage" then
            local location = error.location or "storage"
            if location:match("^slip") then
                detail = string.format("Found in %s (porter moogle)", location:upper())
            else
                detail = string.format("Found in %s (move to wardrobe)", location:upper())
            end
        elseif error.type == "invalid_item" then
            detail = "Item doesn't exist or misspelled"
        else
            detail = "Not found in any containers"
        end

        windower.add_to_chat(color, string.format("- %s: %s", item_name, detail))
    end
end

function ErrorCollector.stop_collecting()
    collecting = false

    -- Export JSON
    if json and #captured_errors > 0 then
        local timestamp = os.date('%Y%m%d_%H%M%S')
        local filename = windower.addon_path ..
        'data/' .. (player and player.name or 'Unknown') .. '/equipment_errors.json'

        local data = {
            version = "5.0",
            job = player and player.main_job or "Unknown",
            timestamp = timestamp,
            total_errors = #captured_errors,
            errors = captured_errors
        }

        local success, json_content = pcall(json.serialize, data)
        if success then
            local file = io.open(filename, 'w')
            if file then
                file:write(json_content)
                file:close()
                windower.add_to_chat(colors.success, "[JSON] Export: " .. filename)
            end
        end
    end
end

-- Utility functions
function ErrorCollector.get_errors()
    return captured_errors
end

function ErrorCollector.is_active()
    return collecting
end

function ErrorCollector.get_status()
    return {
        collecting = collecting,
        errors_found = #captured_errors,
        version = "5.0"
    }
end

-- Global export
_G.ErrorCollector = ErrorCollector
return ErrorCollector
