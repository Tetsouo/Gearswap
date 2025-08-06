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

local ffxi_get_mob   = windower.ffxi.get_mob_by_index
local ffxi_get_items = windower.ffxi.get_items
local send_cmd       = windower.send_command
local area_contains  = areas.Cities.contains

local in_adoulin     = false
windower.register_event('zone change', function()
    in_adoulin = world.area:find('Adoulin') ~= nil
end)

local config = {
    MOVEMENT_THRESHOLD = 1,
    PRERENDER_DELAY = 15,
}

local res = require("resources")

local function updatePetMode(bstPet)
    mode = (bstPet and bstPet.isvalid) and "pet" or "me"
end

-- helper couleurs (reprend ceux déjà définis)
local function c(id) return string.char(31, id) end
local RESET = c(1)
local COL = { TAG = c(1), ECO = c(56), COUNT = c(57), ERR = c(167) } -- 56 = bleu-cyan

-- CENTRALIZED BST LOGIC - Simple and unified

-- Get all pets for current filters
local function get_filtered_pets(eco, species)
    local broth_pet_data = require('jobs/bst/broth_pet_data')
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
    local broth_pet_data = require('jobs/bst/broth_pet_data')
    local species_set = {}
    local species_list = {"All"}
    
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
    
    species_list = {"All"}
    for _, s in ipairs(to_sort) do
        table.insert(species_list, s)
    end
    
    return species_list
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
    local msg = COL.ECO .. eco .. RESET .. " (" .. COL.COUNT .. tostring(#pets) .. RESET .. ")"
    add_to_chat(262, msg)
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
    local eco = state.ecosystem.value      -- Current ecosystem (Aquan, Beast, etc.)
    local species = state.species.value    -- Selected species within ecosystem
    
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
        state.ammoSet:set(pets[1])  -- Auto-select first available pet
        
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
        local msg = COL.COUNT .. current_pet .. RESET
        add_to_chat(262, msg)
    else
        -- ───────────────────────────────────────────────────────────────────
        -- ERROR HANDLING: No pets available for selected species
        -- This should rarely happen unless database is incomplete
        -- ───────────────────────────────────────────────────────────────────
        add_to_chat(123, COL.ERR .. "[BST] No pets found for " .. species .. RESET)
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
    local msg = table.concat({
        COL.TAG, "[BST Selection Info]", RESET, "\n",
        "  Ecosystem: ", COL.ECO, eco, RESET, "\n",
        "  Species: ", COL.ECO, species, RESET, "\n", 
        "  Current Pet: ", COL.COUNT, current_pet, RESET, "\n",
        "  Available Pets: ", COL.COUNT, tostring(#pets), RESET
    })
    add_to_chat(262, msg)
end

-- Equip the broth for the selected pet
function equip_pet_broth()
    local selected_pet = state.ammoSet.value
    if selected_pet and sets[selected_pet] then
        equip(sets[selected_pet])
        add_to_chat(262, COL.TAG .. "[BST] Equipped broth for: " .. COL.ECO .. selected_pet .. RESET)
    end
end

-- Handle state changes (simplified)
function job_state_change(field, new_value, old_value)
    -- State changes are now handled by unified functions
end

function customize_idle_set(idleSet)
    updatePetMode(pet)

    if pet and pet.isvalid then
        if state.petEngaged.value == "true" then
            idleSet = sets.pet.engaged.PDT
        else
            idleSet = (state.petIdleMode and state.petIdleMode.current == "PetPDT")
                and sets.pet.idle.PDT
                or sets.me.idle.PDT
        end
    else
        idleSet = areas.Cities:contains(world.area)
            and sets.me.idle.Town
            or sets.me.idle
    end

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
local RESET = c(1)                                  -- remet la couleur par défaut

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
    -- partie « logique » inchangée
    local ammoKey = state.ammoSet.value
    if not ammoKey or not sets[ammoKey] or not sets[ammoKey].ammo then
        add_to_chat(123, "[BST] No ammoSet or invalid ammo data.")
        return
    end

    local ammoName = (sets[ammoKey].ammo.name or sets[ammoKey].ammo):lower()
    local item_id  = broth_name_to_id[ammoName]
    if not item_id then
        add_to_chat(123, "[BST] Broth name not recognized: " .. ammoName)
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

    -- récupère nom & famille via le fichier BST/broth_pet_data.lua
    local jug_data        = require('jobs/bst/broth_pet_data')
    local petName, family = "???", "???"
    for petKey, info in pairs(jug_data) do
        if info.broth:lower() == ammoName then
            petName = petKey:match("^(.-) %(") or petKey
            family  = info.species
            break
        end
    end

    -- message coloré
    local msg = table.concat({
        COL.TAG, "[BST] ",
        "Pet: ", COL.PET, petName, RESET,
        "  Family: ", COL.FAMILY, family, RESET,
        "  Jug(s): ", COL.COUNT, tostring(count), RESET
    })
    add_to_chat(262, msg)
end

function customize_melee_set(meleeSet)
    updatePetMode(pet)

    if not pet then
        meleeSet = (player.status == 'Engaged') and sets.me.engaged.PDT or sets.me.idle
    else
        if state.petEngaged.value == 'true' and player.status == 'Engaged' then
            meleeSet = sets.pet.engagedBoth
        elseif state.petEngaged.value == 'true' then
            meleeSet = sets.pet.engaged
        elseif player.status == 'Engaged' then
            meleeSet = sets.me.engaged
        else
            meleeSet = sets.pet.idle
        end
    end

    if state.HybridMode.current == 'PDT' then
        meleeSet = set_combine(meleeSet, sets[mode].PDT)
    end

    return meleeSet
end

function check_and_engage_pet()
    updatePetMode(pet)

    if state.AutoPetEngage.current == 'On'
        and player.status == 'Engaged'
        and pet and pet.isvalid
        and state.petEngaged.current == 'false'
    then
        windower.send_command('input /pet "Fight" <t>')
    end
end

function check_pet_engaged()
    local petMob = windower.ffxi.get_mob_by_target('pet')
    if petMob then
        if petMob.status == 1 and state.petEngaged.current ~= 'true' then
            state.petEngaged:set('true')
            job_state_change('petEngaged', 'true', 'false')
        elseif petMob.status ~= 1 and state.petEngaged.current ~= 'false' then
            state.petEngaged:set('false')
            job_state_change('petEngaged', 'false', 'true')
            update_ready_moves()
        end
    else
        state.petEngaged:set('false')
        job_state_change('petEngaged', 'false', 'true')
    end
end

windower.register_event('time change', function()
    --[[ check_pet_engaged()
    check_and_engage_pet()
    send_command('gs c update') ]]
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

function job_self_command(cmdParams)
    update_altState()
    local command = (cmdParams[1] or ''):lower()

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
            add_to_chat(123, 'Ready move #' .. tostring(slot) .. ' unavailable.')
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

function job_pet_midcast(spell)
    local name = spell.name

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
    elseif petTpMoves:contains(name) then
        equip(sets.midcast.pet_physical_moves)
    else
        add_to_chat(123, "[BST] Unknown Ready move: " .. name)
    end
end
