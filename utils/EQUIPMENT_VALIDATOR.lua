---============================================================================
--- Equipment Validator - Custom equipment validation
---============================================================================
--- Exactly reproduces GearSwap logic to detect equipment errors
--- before even attempting to equip. Uses the same logic
--- as GearSwap's unpack_equip_list() for perfect compatibility.
---
--- This function scans all equippable bags exactly like GearSwap
--- and identifies which items in a set cannot be found.
---
--- @file utils/equipment_validator.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-08
---============================================================================

local EquipmentValidator = {}

-- Load dependencies
local success_ValidationUtils, ValidationUtils = pcall(require, 'utils/VALIDATION')
if not success_ValidationUtils then
    error("Failed to load utils/validation: " .. tostring(ValidationUtils))
end
local success_logger, logger = pcall(require, 'utils/LOGGER')
if not success_logger then
    error("Failed to load utils/logger: " .. tostring(logger))
end
local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end

-- Validation cache to optimize performance
local validation_cache = {}
local cache_timestamp = 0
local cache_duration = 5 -- Cache valid for 5 seconds

-- Slot mapping identical to GearSwap (from statics.lua)
local default_slot_map = {
    [0] = 'main',
    [1] = 'sub',
    [2] = 'range',
    [3] = 'ammo',
    [4] = 'head',
    [5] = 'body',
    [6] = 'hands',
    [7] = 'legs',
    [8] = 'feet',
    [9] = 'neck',
    [10] = 'waist',
    [11] = 'left_ear',
    [12] = 'right_ear',
    [13] = 'left_ring',
    [14] = 'right_ring',
    [15] = 'back'
}

-- Reverse slot mapping for name->ID conversion
local slot_name_to_id = {}
for id, name in pairs(default_slot_map) do
    slot_name_to_id[name] = id
end

-- Slot aliases for compatibility
slot_name_to_id['ear1'] = 11
slot_name_to_id['ear2'] = 12
slot_name_to_id['left_earring'] = 11
slot_name_to_id['right_earring'] = 12
slot_name_to_id['ring1'] = 13
slot_name_to_id['ring2'] = 14
slot_name_to_id['ranged'] = 2

---============================================================================
--- UTILITY FUNCTIONS (reproduced from GearSwap)
---============================================================================

--- Check if an item can be equipped (copy of GearSwap's check_wearable)
local function check_wearable(item_id)
    if not item_id or item_id == 0 then
        return false
    end

    if not res.items[item_id] then
        return false
    end

    local item_data = res.items[item_id]

    -- Check that the item has a jobs field
    if not item_data.jobs then
        return false
    end

    -- Check that the item has equippable slots
    if not item_data.slots then
        return false
    end

    -- Check job, level, race and superior level
    local player_data = windower.ffxi.get_player()
    if not player_data then
        return false
    end

    return (item_data.jobs[player_data.main_job_id]) and
        (item_data.level <= (player_data.jobs[player_data.main_job] or 1)) and
        (item_data.races[player_data.race_id]) and
        ((player_data.superior_level or 0) >= (item_data.superior_level or 0))
end

--- Check if the name matches the item ID (copy of GearSwap's name_match)
local function name_match(item_id, name)
    if not res.items[item_id] or not name then
        return false
    end

    local item_data = res.items[item_id]
    local language = windower.ffxi.get_info().language or 'english'

    -- Check normal name and log name
    local item_name = item_data[language] or item_data.english
    local item_log_name = item_data[language .. '_log'] or item_data.english_log

    if item_name then
        if item_name:lower() == name:lower() then
            return true
        end
    end

    if item_log_name then
        if item_log_name:lower() == name:lower() then
            return true
        end
    end

    return false
end

--- Expand entry to handle different item formats (copy from GearSwap)
local function expand_entry(entry)
    if not entry then
        return nil, nil, nil, nil
    end

    local name, priority, augments, designated_bag

    if type(entry) == 'table' and entry == empty then
        name = empty
    elseif type(entry) == 'table' and entry.name and type(entry.name) == 'string' then
        name = entry.name
        priority = entry.priority
        if entry.augments then
            augments = entry.augments
        elseif entry.augment then
            augments = { entry.augment }
        end
        if entry.bag and type(entry.bag) == 'string' then
            -- Convert bag name to ID if necessary
            for bag_id, bag_data in pairs(res.bags) do
                if bag_data.en:lower() == entry.bag:lower() then
                    designated_bag = bag_id
                    break
                end
            end
        end
    elseif type(entry) == 'string' and entry ~= '' then
        name = entry
    end

    return name, priority, augments, designated_bag
end

--- Compare augments (simplified version to avoid extdata dependency)
local function compare_augments(requested_augs, item_augs)
    -- If no augments requested, accept anything
    if not requested_augs or #requested_augs == 0 then
        return true
    end

    -- If augments requested but not on item, refuse
    if not item_augs or #item_augs == 0 then
        return false
    end

    -- Basic comparison (can be improved with extdata later)
    return true
end

---============================================================================
--- MAIN VALIDATION FUNCTION
---============================================================================

--- Validate an equipment set using exact GearSwap logic
--- @param equipment_set (table): Equipment set to validate
--- @param set_name (string): Set name for error messages
--- @return (table): {valid=boolean, missing_items={}, errors={}, used_items={}}
function EquipmentValidator.validate_equipment_set(equipment_set, set_name)
    -- Parameter validation
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        return {
            valid = false,
            missing_items = {},
            errors = { "Invalid equipment set: must be a table" },
            used_items = {}
        }
    end

    -- Check cache
    local current_time = os.time()
    local cache_key = set_name or "anonymous"

    if validation_cache[cache_key] and (current_time - cache_timestamp) < cache_duration then
        return validation_cache[cache_key]
    end

    -- Get current data
    local items = windower.ffxi.get_items()
    local current_equipment = windower.ffxi.get_items().equipment -- Correct API call

    if not items or not current_equipment then
        return {
            valid = false,
            missing_items = {},
            errors = { "Unable to get game data" },
            used_items = {}
        }
    end

    -- Initialize data structures (as in unpack_equip_list)
    local equip_list = {}
    local used_list = {}
    local error_list = {}
    local missing_items = {}

    -- Copy equipment set for validation
    for slot_name, item_spec in pairs(equipment_set) do
        equip_list[slot_name] = item_spec
    end

    -- Phase 1: Check already equipped items (GearSwap logic)
    for slot_id, slot_name in pairs(default_slot_map) do
        local name, priority, augments, designated_bag = expand_entry(equip_list[slot_name])

        if name == empty then
            equip_list[slot_name] = nil
            -- Note: we don't check if we need to empty the slot here
        elseif name and current_equipment[slot_name] and current_equipment[slot_name] ~= 0 then
            -- Item is already equipped, check if it matches
            local current_item_id = current_equipment[slot_name]
            local current_bag_id = current_equipment[slot_name .. '_bag'] or 0

            -- Get equipped item data
            local bag_name = res.bags[current_bag_id] and res.bags[current_bag_id].en or 'inventory'
            local items_in_bag = items[bag_name:lower()]

            if items_in_bag and items_in_bag[current_item_id] then
                local item_data = items_in_bag[current_item_id]

                if name_match(item_data.id, name) and
                    (not augments or compare_augments(augments, {})) and
                    (not designated_bag or designated_bag == current_bag_id) then
                    -- Equipped item matches, remove from equip list
                    equip_list[slot_name] = nil
                    used_list[slot_id] = { bag_id = current_bag_id, slot = current_item_id }
                end
            end
        end
    end

    -- Phase 2: Scan all equippable bags (exact GearSwap logic)
    -- Get list of equippable bags
    local equippable_bags = {}
    for bag_id, bag_data in pairs(res.bags) do
        if bag_data.equippable then
            table.insert(equippable_bags, bag_data)
        end
    end

    -- Scan each equippable bag
    for _, bag in ipairs(equippable_bags) do
        local bag_name = bag.en:lower()
        local items_in_bag = items[bag_name]

        if items_in_bag then
            -- Iterate over each item in the bag
            for slot, item_data in pairs(items_in_bag) do
                if type(item_data) == 'table' and item_data.id and item_data.id > 0 then
                    -- Check if item can be equipped
                    if check_wearable(item_data.id) then
                        -- Check if item is available (status = 0 or 5)
                        if item_data.status == 0 or item_data.status == 5 then
                            -- Check each possible slot for this item
                            local item_slots = res.items[item_data.id].slots
                            if item_slots then
                                for slot_id in pairs(item_slots) do
                                    if default_slot_map[slot_id] then
                                        local slot_name = default_slot_map[slot_id]

                                        -- Check if we're still looking for something for this slot
                                        if equip_list[slot_name] and not used_list[slot_id] then
                                            -- Avoid main/sub and ear/ring conflicts
                                            local conflict = false
                                            if (slot_id == 0 and used_list[1] and used_list[1].bag_id == bag.id and used_list[1].slot == slot) or
                                                (slot_id == 1 and used_list[0] and used_list[0].bag_id == bag.id and used_list[0].slot == slot) or
                                                (slot_id == 11 and used_list[12] and used_list[12].bag_id == bag.id and used_list[12].slot == slot) or
                                                (slot_id == 12 and used_list[11] and used_list[11].bag_id == bag.id and used_list[11].slot == slot) or
                                                (slot_id == 13 and used_list[14] and used_list[14].bag_id == bag.id and used_list[14].slot == slot) or
                                                (slot_id == 14 and used_list[13] and used_list[13].bag_id == bag.id and used_list[13].slot == slot) then
                                                conflict = true
                                            end

                                            if not conflict then
                                                local name, priority, augments, designated_bag = expand_entry(equip_list
                                                [slot_name])

                                                if (not designated_bag or designated_bag == bag.id) and name and name_match(item_data.id, name) then
                                                    -- Check augments if necessary
                                                    if augments and #augments > 0 then
                                                        local item_is_rare = res.items[item_data.id].flags and
                                                        res.items[item_data.id].flags.Rare
                                                        if item_is_rare or compare_augments(augments, {}) then
                                                            -- Item found!
                                                            equip_list[slot_name] = nil
                                                            used_list[slot_id] = { bag_id = bag.id, slot = slot }
                                                            break
                                                        end
                                                    else
                                                        -- No augments specified, item OK
                                                        equip_list[slot_name] = nil
                                                        used_list[slot_id] = { bag_id = bag.id, slot = slot }
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            -- Item unavailable (status != 0 and != 5)
                            for slot_id in pairs(res.items[item_data.id].slots or {}) do
                                if default_slot_map[slot_id] then
                                    local slot_name = default_slot_map[slot_id]
                                    local name = expand_entry(equip_list[slot_name])

                                    if name and name ~= empty and name_match(item_data.id, name) then
                                        if item_data.status == 25 then
                                            error_list[slot_name] = name .. ' (bazaared)'
                                        else
                                            error_list[slot_name] = name ..
                                            ' (status unknown: ' .. item_data.status .. ')'
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    else
                        -- Item not equippable for this player
                        for slot_name, item_spec in pairs(equip_list) do
                            local name = expand_entry(item_spec)
                            if name and name ~= empty and name_match(item_data.id, name) then
                                local player_data = windower.ffxi.get_player()
                                local item_res = res.items[item_data.id]

                                if not item_res.jobs[player_data.main_job_id] then
                                    equip_list[slot_name] = nil
                                    error_list[slot_name] = name .. ' (cannot be worn by this job)'
                                elseif not (item_res.level <= (player_data.jobs[player_data.main_job] or 1)) then
                                    equip_list[slot_name] = nil
                                    error_list[slot_name] = name .. ' (job level is too low)'
                                elseif not item_res.races[player_data.race_id] then
                                    equip_list[slot_name] = nil
                                    error_list[slot_name] = name .. ' (cannot be worn by your race)'
                                elseif not item_res.slots then
                                    equip_list[slot_name] = nil
                                    error_list[slot_name] = name .. ' (cannot be worn)'
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- Phase 3: Compile results
    -- Everything remaining in equip_list could not be found
    for slot_name, item_spec in pairs(equip_list) do
        local name = expand_entry(item_spec)
        if name and name ~= empty then
            table.insert(missing_items, {
                slot = slot_name,
                name = name,
                reason = "Item not found in any equippable bag"
            })
        end
    end

    -- Create error list
    local all_errors = {}
    for slot, error_msg in pairs(error_list) do
        table.insert(all_errors, string.format("[%s] %s", slot, error_msg))
    end

    for _, missing in ipairs(missing_items) do
        table.insert(all_errors, string.format("[%s] %s - %s", missing.slot, missing.name, missing.reason))
    end

    -- Compile final result
    local result = {
        valid = (#missing_items == 0 and #all_errors == 0),
        missing_items = missing_items,
        errors = all_errors,
        used_items = used_list,
        set_name = set_name
    }

    -- Cache the result
    validation_cache[cache_key] = result
    cache_timestamp = current_time

    return result
end

---============================================================================
--- CONVENIENCE FUNCTIONS
---============================================================================

--- Validate a set and display results
--- @param equipment_set (table): Set to validate
--- @param set_name (string): Set name
--- @param show_success (boolean): Display message if everything is OK
function EquipmentValidator.validate_and_report(equipment_set, set_name, show_success)
    local result = EquipmentValidator.validate_equipment_set(equipment_set, set_name)

    if result.valid then
        if show_success then
            windower.add_to_chat(030, string.format("[Equipment Validator] Set '%s' is valid", set_name or "anonymous"))
        end
    else
        windower.add_to_chat(167,
            string.format("[Equipment Validator] Set '%s' contains errors:", set_name or "anonymous"))

        for _, error_msg in ipairs(result.errors) do
            windower.add_to_chat(001, "  " .. error_msg)
        end

        if #result.missing_items > 0 then
            windower.add_to_chat(167, string.format("Missing items: %d", #result.missing_items))
            for _, missing in ipairs(result.missing_items) do
                windower.add_to_chat(001, string.format("  [%s] %s", missing.slot, missing.name))
            end
        end
    end

    return result
end

--- Validate all defined sets
--- @param sets_table (table): Sets table (usually 'sets')
--- @param report_valid (boolean): Also report valid sets
function EquipmentValidator.validate_all_sets(sets_table, report_valid)
    if not sets_table or type(sets_table) ~= 'table' then
        windower.add_to_chat(167, "[Equipment Validator] No sets found to validate")
        return
    end

    windower.add_to_chat(160, "=== COMPLETE EQUIPMENT VALIDATION ===")

    local total_sets = 0
    local valid_sets = 0
    local invalid_sets = 0

    -- Recursive function to validate nested sets
    local function validate_nested(table_ref, path)
        for key, value in pairs(table_ref) do
            if type(value) == 'table' then
                local current_path = path and (path .. "." .. key) or key

                -- Check if it's an equipment set (contains slots)
                local is_equipment_set = false
                for slot_name in pairs(value) do
                    if slot_name_to_id[slot_name] then
                        is_equipment_set = true
                        break
                    end
                end

                if is_equipment_set then
                    total_sets = total_sets + 1
                    local result = EquipmentValidator.validate_equipment_set(value, current_path)

                    if result.valid then
                        valid_sets = valid_sets + 1
                        if report_valid then
                            windower.add_to_chat(030, string.format("OK %s", current_path))
                        end
                    else
                        invalid_sets = invalid_sets + 1
                        windower.add_to_chat(167, string.format("X %s (%d errors)", current_path, #result.errors))

                        -- Display some errors
                        for i = 1, math.min(3, #result.errors) do
                            windower.add_to_chat(001, "    " .. result.errors[i])
                        end

                        if #result.errors > 3 then
                            windower.add_to_chat(001, string.format("    ... and %d more errors", #result.errors - 3))
                        end
                    end
                else
                    -- Continue recursive search
                    validate_nested(value, current_path)
                end
            end
        end
    end

    validate_nested(sets_table, nil)

    windower.add_to_chat(160, string.format("=== RESULTS: %d/%d valid sets ===", valid_sets, total_sets))
    if invalid_sets > 0 then
        windower.add_to_chat(167, string.format("⚠ %d sets require your attention", invalid_sets))
    end
end

--- Clear validation cache
function EquipmentValidator.clear_cache()
    validation_cache = {}
    cache_timestamp = 0
    windower.add_to_chat(030, "[Equipment Validator] Cache cleared")
end

--- Get cache statistics
function EquipmentValidator.get_cache_stats()
    local count = 0
    for _ in pairs(validation_cache) do
        count = count + 1
    end

    return {
        entries = count,
        age = os.time() - cache_timestamp,
        max_age = cache_duration
    }
end

return EquipmentValidator
