---============================================================================
--- FFXI GearSwap Job Module - Beastmaster Advanced Functions
---============================================================================

--- Professional Beastmaster job-specific functionality providing intelligent
--- pet management, ecosystem optimization, broth handling, and automated
--- pet engagement systems. Core features include:
---
--- • **Ecosystem-Based Pet Filtering** - Dynamic species lists by ecosystem type
--- • **Intelligent Broth Management** - Automatic jug pet selection and equipping
--- • **Pet Engagement Automation** - Smart pet attack/disengage based on combat state
--- • **Zone-Aware Configuration** - Adoulin-specific optimizations and restrictions
--- • **HUD Integration** - Real-time pet status and broth count display
--- • **Multi-Pet Strategy Support** - Complex pet rotation and management
--- • **Combat State Integration** - Pet behavior based on player engagement
--- • **Error Recovery Systems** - Robust handling of pet loss and zone changes
---
--- This module implements the advanced pet management algorithms that make
--- BST automation seamless and intelligent, handling the complex coordination
--- between player actions and pet behavior with full error recovery.
---
--- @file jobs/bst/BST_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-11-27 | Modified: 2025-08-05
--- @requires Windower FFXI, resources.lua, areas addon
--- @requires jobs/bst/broth_pet_data.lua
---
--- @usage
---   bst_change_ecosystem()  -- Cycle ecosystem and update species list
---   bst_change_species()    -- Change species and equip appropriate broth
---   update_ready_moves()    -- Refresh pet ability list
---
--- @see jobs/bst/broth_pet_data.lua for ecosystem/species data
--- @see BST-HUD.lua for visual pet management interface
---============================================================================

---@diagnostic disable: lowercase-global

local ffxi_get_mob                           = windower.ffxi.get_mob_by_index
local ffxi_get_items                         = windower.ffxi.get_items
local send_cmd                               = windower.send_command
local area_contains                          = areas.Cities.contains

-- Performance: Load modules once instead of every function call
local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
if not success_EquipmentUtils then
    error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
end
local success_res, res = pcall(require, 'resources')
if not success_res then
    error("Failed to load resources: " .. tostring(res))
end

local in_adoulin = false
windower.register_event('zone change', function()
    in_adoulin = world.area:find('Adoulin') ~= nil
end)

local config = {
    MOVEMENT_THRESHOLD = 1,
    PRERENDER_DELAY = 15,
}

-- Performance: Cache pet mode to avoid recalculation
local cached_pet_mode = { mode = "me", timestamp = 0, pet_valid = false }
local PET_MODE_CACHE_DURATION = 0.05 -- Cache for 0.05 seconds

-- Advanced: Equipment set caching to avoid expensive set_combine operations
local equipment_cache = {
    idle = { set = nil, timestamp = 0, conditions = "" },
    melee = { set = nil, timestamp = 0, conditions = "" }
}
local EQUIPMENT_CACHE_DURATION = 0.2 -- Cache equipment for 0.2 seconds

-- Performance optimized updatePetMode with caching
local function updatePetMode(bstPet)
    local current_time = os.clock()

    -- Use cached value if recent enough
    if current_time - cached_pet_mode.timestamp < PET_MODE_CACHE_DURATION then
        mode = cached_pet_mode.mode
        return
    end

    -- Update cache
    cached_pet_mode.pet_valid = (bstPet and bstPet.isvalid) or false
    cached_pet_mode.mode = cached_pet_mode.pet_valid and "pet" or "me"
    cached_pet_mode.timestamp = current_time
    mode = cached_pet_mode.mode
end

-- Advanced: Generate condition hash for equipment caching (optimized)
local condition_cache = { hash = "", timestamp = 0 }
local CONDITION_CACHE_DURATION = 0.03 -- Very fast cache for conditions

local function get_equipment_conditions()
    local current_time = os.clock()

    -- Use cached hash if very recent (conditions rarely change frame-to-frame)
    if current_time - condition_cache.timestamp < CONDITION_CACHE_DURATION then
        return condition_cache.hash
    end

    -- Optimized concatenation (faster than string.format)
    condition_cache.hash = (cached_pet_mode.pet_valid and "pet" or "me") .. "_" ..
        (state.petEngaged.value or "false") .. "_" ..
        (state.HybridMode.current or "Normal") .. "_" ..
        (state.petIdleMode and state.petIdleMode.current or "MasterPDT") .. "_" ..
        (state.Moving.value or "false")

    condition_cache.timestamp = current_time
    return condition_cache.hash
end

-- color helpers (reuses already defined ones)
local function c(id) return string.char(31, id) end
local RESET = c(1)
local COL = { TAG = c(1), ECO = c(56), COUNT = c(57), ERR = c(167) } -- 56 = bleu-cyan

-- CENTRALIZED BST LOGIC - Simple and unified

-- Get all pets for current filters
local function get_filtered_pets(eco, species)
    local success_broth_pet_data, broth_pet_data = pcall(require, 'jobs/bst/BROTH_PET_DATA')
    if not success_broth_pet_data then
        error("Failed to load jobs/bst/broth_pet_data: " .. tostring(broth_pet_data))
    end
    local pets = {}

    for pet_name, data in pairs(broth_pet_data) do
        local eco_match = (eco == "All" or data.ecosystem == eco)
        local species_match = (species == "All" or data.species == species)
        if eco_match and species_match then
            table.insert(pets, pet_name)
        end
    end

    table.sort(pets)
    return pets
end

-- Get unique species for an ecosystem
local function get_species_for_ecosystem(eco)
    local success_broth_pet_data, broth_pet_data = pcall(require, 'jobs/bst/BROTH_PET_DATA')
    if not success_broth_pet_data then
        error("Failed to load jobs/bst/broth_pet_data: " .. tostring(broth_pet_data))
    end
    local species_set = {}
    local species_list = { "All" }

    for _, data in pairs(broth_pet_data) do
        if eco == "All" or data.ecosystem == eco then
            if not species_set[data.species] then
                species_set[data.species] = true
                table.insert(species_list, data.species)
            end
        end
    end

    -- Sort species (keeping All first)
    local to_sort = {}
    for i = 2, #species_list do
        table.insert(to_sort, species_list[i])
    end
    table.sort(to_sort)

    species_list = { "All" }
    for _, s in ipairs(to_sort) do
        table.insert(species_list, s)
    end

    return species_list
end

-- Initialize species list at startup for ecosystem "All"
local function initialize_species()
    if state and state.ecosystem then
        local eco = state.ecosystem.value or "All"
        local species_list = get_species_for_ecosystem(eco)
        state.species = M { description = "Species", unpack(species_list) }
        state.species:set("All")
    end
end

-- MAIN FUNCTION 1: Change ecosystem
function bst_change_ecosystem()
    -- Cycle ecosystem
    state.ecosystem:cycle()
    local eco = state.ecosystem.value

    -- Update species list for this ecosystem
    local species_list = get_species_for_ecosystem(eco)
    state.species = M { description = "Species", unpack(species_list) }
    state.species:set("All")

    -- Get pets for this ecosystem + All species
    local pets = get_filtered_pets(eco, "All")

    -- Update ammoSet
    if #pets > 0 then
        state.ammoSet = M { description = "ammo", unpack(pets) }
        state.ammoSet:set(pets[1])
        -- Equip broth
        coroutine.schedule(function() equip_pet_broth() end, 0.1)
    end

    -- Show simple ecosystem message
    -- Don't use createFormattedMessage for ecosystem changes as it adds "Due to:" incorrectly
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    MessageUtils.bst_ecosystem_message(eco, #pets)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN FUNCTION 2: Species Selection and Pet Filtering
-- ═══════════════════════════════════════════════════════════════════════════
-- Cycles through available species within the current ecosystem and automatically
-- updates the pet selection list. This function provides the secondary filtering
-- layer after ecosystem selection, allowing precise pet selection.
function bst_change_species()
    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 1: Advance to next species in current ecosystem
    -- ───────────────────────────────────────────────────────────────────────
    state.species:cycle()
    local eco = state.ecosystem.value   -- Current ecosystem (Aquan, Beast, etc.)
    local species = state.species.value -- Selected species within ecosystem

    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 2: Filter pets by ecosystem + species combination
    -- This creates a focused list of pets matching both criteria
    -- ───────────────────────────────────────────────────────────────────────
    local pets = get_filtered_pets(eco, species)

    -- ───────────────────────────────────────────────────────────────────────
    -- STEP 3: Update pet selection system
    -- Replace ammoSet with filtered pet list and auto-select first pet
    -- ───────────────────────────────────────────────────────────────────────
    if #pets > 0 then
        -- Create new ammoSet state with filtered pets
        state.ammoSet = M { description = "ammo", unpack(pets) }
        state.ammoSet:set(pets[1]) -- Auto-select first available pet

        -- ───────────────────────────────────────────────────────────────────
        -- STEP 4: Auto-equip appropriate broth for selected pet
        -- Use coroutine to prevent equipment conflicts during state changes
        -- ───────────────────────────────────────────────────────────────────
        coroutine.schedule(function() equip_pet_broth() end, 0.1)

        -- ───────────────────────────────────────────────────────────────────
        -- STEP 5: User feedback - show selected pet name
        -- Simple, clean display of the current pet selection
        -- ───────────────────────────────────────────────────────────────────
        local current_pet = pets[1]
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        MessageUtils.bst_pet_selection_message(current_pet, true)
    else
        -- ───────────────────────────────────────────────────────────────────
        -- ERROR HANDLING: No pets available for selected species
        -- This should rarely happen unless database is incomplete
        -- ───────────────────────────────────────────────────────────────────
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        MessageUtils.bst_pet_not_found_message(species)
    end
end

-- Display current selection info
function display_selection_info()
    local eco = state.ecosystem.value
    local species = state.species.value
    local current_pet = state.ammoSet.value

    -- Get filtered pets
    local pets = get_filtered_pets(eco, species)

    -- Display info
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    MessageUtils.bst_selection_info_message(eco, species, current_pet, #pets)
end

-- Equip the broth for the selected pet
function equip_pet_broth()
    local selected_pet = state.ammoSet.value
    if selected_pet and sets[selected_pet] then
        equip(sets[selected_pet])
        -- No message needed - silent equipment change for better UX
    end
end

-- Handle state changes (simplified)
function job_state_change(field, new_value, old_value)
    -- State changes are now handled by unified functions
end

function customize_idle_set(idleSet)
    updatePetMode(pet)

    -- Simplified but fast logic (Level 1 optimizations only)
    if cached_pet_mode.pet_valid then
        idleSet = (state.petEngaged.value == "true") and sets.pet.engaged.PDT
            or ((state.petIdleMode and state.petIdleMode.current == "PetPDT")
                and sets.pet.idle.PDT or sets.me.idle.PDT)
    else
        -- Use pre-loaded EquipmentUtils (no require() overhead)
        idleSet = EquipmentUtils.customize_idle_set_standard(
            sets.me.idle,      -- Base idle set
            sets.me.idle.Town, -- Town set (used in cities, excluded in Dynamis)
            nil,               -- No XP set for BST
            nil,               -- No PDT set here (handled separately)
            nil                -- No MDT set here (handled separately)
        )
    end

    -- Simple conditional combining (original logic, just optimized)
    if state.HybridMode.current == "PDT" then
        idleSet = set_combine(idleSet, sets[mode].PDT)
    end

    if state.Moving.value == "true" then
        idleSet = set_combine(idleSet, sets.MoveSpeed)
    end

    return idleSet
end

local broth_name_to_id = {}
for id, item in pairs(res.items) do
    if item and item.en then
        broth_name_to_id[item.en:lower()] = id
    end
end

-----------------------------------------------------------------
-- Helpers couleur Windower  (0x1F = 31)
local function c(id) return string.char(31, id) end -- change couleur
local RESET = c(1)                                  -- reset to default color

-- palette perso (cf. ton Color.png)
local COL = {
    TAG    = c(1),  -- blanc/gris clair
    PET    = c(30), -- vert
    FAMILY = c(50), -- jaune
    COUNT  = c(57), -- orange
}

-----------------------------------------------------------------
function display_broth_count()
    ----------------------------------------------------------------
    -- logic part unchanged
    local ammoKey = state.ammoSet.value
    if not ammoKey or not sets[ammoKey] or not sets[ammoKey].ammo then
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        MessageUtils.bst_ammo_error_message('no_ammo_set')
        return
    end

    local ammoName = (sets[ammoKey].ammo.name or sets[ammoKey].ammo):lower()
    local item_id  = broth_name_to_id[ammoName]
    if not item_id then
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end
        MessageUtils.bst_ammo_error_message('broth_not_recognized', ammoName)
        return
    end

    local count = 0
    for bag = 0, 16 do
        local bag_data = windower.ffxi.get_items(bag)
        if bag_data and bag_data.max ~= 0 then
            for i = 1, bag_data.max do
                local item = bag_data[i]
                if item and item.id == item_id then
                    count = count + item.count
                end
            end
        end
    end
    ----------------------------------------------------------------

    -- get name & family via BST/broth_pet_data.lua file
    local success_jug_data, jug_data = pcall(require, 'jobs/bst/BROTH_PET_DATA')
    if not success_jug_data then
        error("Failed to load jobs/bst/broth_pet_data: " .. tostring(jug_data))
    end
    local petName, family = "???", "???"
    for petKey, info in pairs(jug_data) do
        if info.broth:lower() == ammoName then
            petName = petKey:match("^(.-) %(") or petKey
            family  = info.species
            break
        end
    end

    -- colored message
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    MessageUtils.bst_pet_info_message(petName, family, count)
end

function customize_melee_set(meleeSet)
    updatePetMode(pet)

    -- Simplified logic (Level 1 optimizations only)
    if not cached_pet_mode.pet_valid then
        meleeSet = (player.status == 'Engaged') and sets.me.engaged.PDT or sets.me.idle
    else
        local petEngaged = (state.petEngaged.value == 'true')
        local playerEngaged = (player.status == 'Engaged')

        meleeSet = (petEngaged and playerEngaged) and sets.pet.engagedBoth
            or petEngaged and sets.pet.engaged
            or playerEngaged and sets.me.engaged
            or sets.pet.idle
    end

    -- Simple conditional combining
    if state.HybridMode.current == 'PDT' then
        meleeSet = set_combine(meleeSet, sets[mode].PDT)
    end

    return meleeSet
end

function check_and_engage_pet()
    -- Only call updatePetMode if AutoPetEngage is On (early exit optimization)
    if state.AutoPetEngage.current ~= 'On' then
        return
    end

    updatePetMode(pet)

    -- Optimized condition checking
    if player.status == 'Engaged'
        and cached_pet_mode.pet_valid
        and state.petEngaged.current == 'false'
    then
        windower.send_command('input /pet "Fight" <t>')
    end
end

-- Performance optimized pet status tracking
local pet_status_cache = { status = nil, timestamp = 0, pet_id = nil }
local CACHE_DURATION = 0.1 -- Cache for 0.1 seconds to reduce API calls

function check_pet_engaged()
    local current_time = os.clock()
    local petMob = nil

    -- Use cached pet info if recent enough
    if current_time - pet_status_cache.timestamp < CACHE_DURATION then
        if pet_status_cache.status then
            petMob = { status = pet_status_cache.status, id = pet_status_cache.pet_id }
        end
    else
        -- Refresh cache with new API call
        petMob = windower.ffxi.get_mob_by_target('pet')
        pet_status_cache.timestamp = current_time
        if petMob then
            pet_status_cache.status = petMob.status
            pet_status_cache.pet_id = petMob.id
        else
            pet_status_cache.status = nil
            pet_status_cache.pet_id = nil
        end
    end

    -- Simplified state logic (removed useless job_state_change calls)
    if petMob then
        if petMob.status == 1 and state.petEngaged.current ~= 'true' then
            state.petEngaged:set('true')
            return true -- State changed
        elseif petMob.status ~= 1 and state.petEngaged.current ~= 'false' then
            state.petEngaged:set('false')
            update_ready_moves()
            return true -- State changed
        end
    else
        if state.petEngaged.current ~= 'false' then
            state.petEngaged:set('false')
            return true -- State changed
        end
    end

    return false -- No state change
end

-- BST Pet Monitoring - Performance Optimized
windower.register_event('time change', function()
    -- Only trigger equipment update if pet status actually changed
    local state_changed = check_pet_engaged()

    -- Always try auto-engage (lightweight check)
    check_and_engage_pet()

    -- Only force equipment update when pet state changes
    -- This dramatically reduces the gs c update frequency
    if state_changed then
        send_command('gs c update')
    end
end)

ready_moves = {}

function update_ready_moves()
    local abilities = windower.ffxi.get_abilities()
    local ja_list   = abilities and abilities.job_abilities or {}
    local moves     = {}

    for _, ability_id in pairs(ja_list) do
        local ability = res.job_abilities[ability_id]
        if ability and ability.type == 'Monster' and ability.targets and ability.targets.Self then
            table.insert(moves, ability.en)
        end
    end
    ready_moves = moves
end

function job_self_command(cmdParams, eventArgs)
    update_altState()
    local command = (cmdParams[1] or ''):lower()

    -- Try universal commands first (test, modules, cache, metrics, help)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end

    -- Handle BST unified commands
    if command == 'bst_ecosystem' then
        bst_change_ecosystem()
        return
    end

    if command == 'bst_species' then
        bst_change_species()
        return
    end

    if command == 'rdymove' and cmdParams[2] then
        local slot = tonumber(cmdParams[2])
        if slot and ready_moves[slot] then
            send_command('input /pet "' .. ready_moves[slot] .. '" <me>')
        else
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.bst_ready_move_error_message(slot)
        end
        return
    end

    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        handle_thf_commands(cmdParams)
        if player.sub_job == 'SCH' then
            handle_sch_subjob_commands(cmdParams)
        end
    end
end

function job_pet_change(_, gain)
    if gain then
        update_ready_moves()
    else
        ready_moves = {}
    end
end

function job_pet_precast(spell)
    local name = spell.name
    local set

    if name == 'Call Beast' or name == 'Bestial Loyalty' then
        set = sets.precast.JA['Call Beast']
        if state.ammoSet.value and sets[state.ammoSet.value] then
            set = set_combine(set, sets[state.ammoSet.value])
        end
    elseif name == 'Reward' then
        set = sets.precast.JA['Reward']
        -- Force immediate equipment of Pet Food Theta to override jug system
        if set then
            -- Immediately equip the full Reward set to ensure Pet Food Theta is equipped
            equip(set)
            -- Log for debugging
            local success_log, log = pcall(require, 'utils/LOGGER')
            if not success_log then
                error("Failed to load utils/logger: " .. tostring(log))
            end
            log.debug("BST: Force equipped Reward set with Pet Food Theta")
        end
    elseif name == 'Killer Instinct' then
        set = sets.precast.JA['Killer Instinct']
    elseif name == 'Spur' then
        set = sets.precast.JA['Spur']
    elseif player.status ~= 'Engaged' then
        set = sets.precast.JA['Misc Idle']
    else
        set = sets.precast.JA['Default']
    end

    if set then equip(set) end
end

-- Helper function to determine Ready move type from element
local function get_ready_move_type_from_element(element)
    -- Physical damage elements: 0 (non-elemental), 5 (blunt), 6 (piercing), 7 (slashing)
    if element == 0 or element == 5 or element == 6 or element == 7 then
        return "physical"
        -- Magical elements: 1 (fire), 2 (ice), 3 (wind), 4 (earth), 8 (thunder), 9 (water), 15 (light), 16 (dark)
    elseif element >= 1 and element <= 4 or element == 8 or element == 9 or element == 15 or element == 16 then
        return "magical"
    else
        -- Default to physical for unknown elements
        return "physical"
    end
end

function job_pet_midcast(spell)
    local name = spell.name

    -- Debug: Log the exact spell name received
    local success_log, log = pcall(require, 'utils/LOGGER')
    if not success_log then
        error("Failed to load utils/logger: " .. tostring(log))
    end
    log.debug("[BST] Pet midcast spell name: '%s', element: %s", name, tostring(spell.element))

    -- First check our manually categorized lists
    if petPhysicalMoves:contains(name) then
        equip(sets.midcast.pet_physical_moves)
    elseif petPhysicalMultiMoves:contains(name) then
        equip(sets.midcast.pet_physicalMulti_moves)
    elseif petMagicAtkMoves:contains(name) then
        local set = (player.status == "Engaged")
            and sets.midcast.pet_magicAtk_moves_ww
            or sets.midcast.pet_magicAtk_moves
        equip(set)
    elseif petMagicAccMoves:contains(name) then
        local set = (player.status == "Engaged")
            and sets.midcast.pet_magicAcc_moves_ww
            or sets.midcast.pet_magicAcc_moves
        equip(set)
    else
        -- For unknown moves, try to use Windower resources to determine type
        local success_res, res = pcall(require, 'resources')
        if not success_res then
            error("Failed to load resources: " .. tostring(res))
        end
        local ability = nil

        -- Search for the ability in job_abilities
        if res and res.job_abilities then
            for _, ja in pairs(res.job_abilities) do
                if ja.en == name and ja.type == "Monster" then
                    ability = ja
                    break
                end
            end
        end

        if ability then
            -- Found the ability, use element to determine type
            local move_type = get_ready_move_type_from_element(ability.element or spell.element)

            log.debug("[BST] Auto-detected Ready move '%s' as %s (element: %s)",
                name, move_type, tostring(ability.element or spell.element))

            if move_type == "magical" then
                local set = (player.status == "Engaged")
                    and sets.midcast.pet_magicAtk_moves_ww
                    or sets.midcast.pet_magicAtk_moves
                equip(set)
            else
                equip(sets.midcast.pet_physical_moves)
            end
        else
            -- Ability not found in resources, use default
            log.debug("[BST] Ready move '%s' not found in resources, using default physical set", name)
            equip(sets.midcast.pet_physical_moves)
        end
    end
end

-- Export functions for external use
return {
    initialize_species = initialize_species
}
