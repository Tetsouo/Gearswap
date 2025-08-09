---============================================================================
--- Equipment Validator - Validation personnalisée des équipements
---============================================================================
--- Reproduit exactement la logique de GearSwap pour détecter les erreurs
--- d'équipement avant même de tenter l'équipement. Utilise la même logique
--- que unpack_equip_list() de GearSwap pour une compatibilité parfaite.
---
--- Cette fonction scanne tous les sacs équipables exactement comme GearSwap
--- et identifie quels items d'un set ne peuvent pas être trouvés.
---
--- @file utils/equipment_validator.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-08
---============================================================================

local EquipmentValidator = {}

-- Load dependencies
local ValidationUtils = require('utils/validation')
local logger = require('utils/logger')
local res = require('resources')

-- Cache des validations pour optimiser les performances
local validation_cache = {}
local cache_timestamp = 0
local cache_duration = 5 -- Cache valide pendant 5 secondes

-- Slot mapping identique à GearSwap (de statics.lua)
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

-- Slot mapping inversé pour conversion nom->ID
local slot_name_to_id = {}
for id, name in pairs(default_slot_map) do
    slot_name_to_id[name] = id
end

-- Aliases de slots pour compatibilité
slot_name_to_id['ear1'] = 11
slot_name_to_id['ear2'] = 12
slot_name_to_id['left_earring'] = 11
slot_name_to_id['right_earring'] = 12
slot_name_to_id['ring1'] = 13
slot_name_to_id['ring2'] = 14
slot_name_to_id['ranged'] = 2

---============================================================================
--- FONCTIONS UTILITAIRES (reproduites de GearSwap)
---============================================================================

--- Vérifie si un item peut être équipé (copie de check_wearable de GearSwap)
local function check_wearable(item_id)
    if not item_id or item_id == 0 then
        return false
    end
    
    if not res.items[item_id] then
        return false
    end
    
    local item_data = res.items[item_id]
    
    -- Vérifier que l'item a un champ jobs
    if not item_data.jobs then
        return false
    end
    
    -- Vérifier que l'item a des slots équipables
    if not item_data.slots then
        return false
    end
    
    -- Vérifier job, level, race et superior level
    local player_data = windower.ffxi.get_player()
    if not player_data then
        return false
    end
    
    return (item_data.jobs[player_data.main_job_id]) and 
           (item_data.level <= (player_data.jobs[player_data.main_job] or 1)) and
           (item_data.races[player_data.race_id]) and
           ((player_data.superior_level or 0) >= (item_data.superior_level or 0))
end

--- Vérifie si le nom correspond à l'item ID (copie de name_match de GearSwap)
local function name_match(item_id, name)
    if not res.items[item_id] or not name then
        return false
    end
    
    local item_data = res.items[item_id]
    local language = windower.ffxi.get_info().language or 'english'
    
    -- Vérifier nom normal et nom de log
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

--- Expand entry pour traiter les différents formats d'items (copie de GearSwap)
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
            augments = {entry.augment}
        end
        if entry.bag and type(entry.bag) == 'string' then
            -- Convertir le nom du sac en ID si nécessaire
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

--- Compare les augments (version simplifiée pour éviter la dépendance extdata)
local function compare_augments(requested_augs, item_augs)
    -- Si pas d'augments demandés, accepter n'importe quoi
    if not requested_augs or #requested_augs == 0 then
        return true
    end
    
    -- Si augments demandés mais pas sur l'item, refuser
    if not item_augs or #item_augs == 0 then
        return false
    end
    
    -- Comparaison basique (peut être améliorée avec extdata plus tard)
    return true
end

---============================================================================
--- FONCTION PRINCIPALE DE VALIDATION
---============================================================================

--- Valide un set d'équipement en utilisant la logique exacte de GearSwap
--- @param equipment_set (table): Set d'équipement à valider
--- @param set_name (string): Nom du set pour les messages d'erreur
--- @return (table): {valid=boolean, missing_items={}, errors={}, used_items={}}
function EquipmentValidator.validate_equipment_set(equipment_set, set_name)
    -- Validation des paramètres
    if not ValidationUtils.validate_type(equipment_set, 'table', 'equipment_set') then
        return {
            valid = false,
            missing_items = {},
            errors = {"Invalid equipment set: must be a table"},
            used_items = {}
        }
    end
    
    -- Vérifier le cache
    local current_time = os.time()
    local cache_key = set_name or "anonymous"
    
    if validation_cache[cache_key] and (current_time - cache_timestamp) < cache_duration then
        return validation_cache[cache_key]
    end
    
    -- Obtenir les données actuelles
    local items = windower.ffxi.get_items()
    local current_equipment = windower.ffxi.get_items().equipment  -- Correct API call
    
    if not items or not current_equipment then
        return {
            valid = false,
            missing_items = {},
            errors = {"Unable to get game data"},
            used_items = {}
        }
    end
    
    -- Initialiser les structures de données (comme dans unpack_equip_list)
    local equip_list = {}
    local used_list = {}
    local error_list = {}
    local missing_items = {}
    
    -- Copier le set d'équipement pour la validation
    for slot_name, item_spec in pairs(equipment_set) do
        equip_list[slot_name] = item_spec
    end
    
    -- Phase 1: Vérifier les items déjà équipés (logique de GearSwap)
    for slot_id, slot_name in pairs(default_slot_map) do
        local name, priority, augments, designated_bag = expand_entry(equip_list[slot_name])
        
        if name == empty then
            equip_list[slot_name] = nil
            -- Note: on vérifie pas si on doit vider le slot ici
        elseif name and current_equipment[slot_name] and current_equipment[slot_name] ~= 0 then
            -- L'item est déjà équipé, vérifier s'il correspond
            local current_item_id = current_equipment[slot_name]
            local current_bag_id = current_equipment[slot_name .. '_bag'] or 0
            
            -- Obtenir les données de l'item équipé
            local bag_name = res.bags[current_bag_id] and res.bags[current_bag_id].en or 'inventory'
            local items_in_bag = items[bag_name:lower()]
            
            if items_in_bag and items_in_bag[current_item_id] then
                local item_data = items_in_bag[current_item_id]
                
                if name_match(item_data.id, name) and
                   (not augments or compare_augments(augments, {})) and
                   (not designated_bag or designated_bag == current_bag_id) then
                    -- L'item équipé correspond, le retirer de la liste à équiper
                    equip_list[slot_name] = nil
                    used_list[slot_id] = {bag_id = current_bag_id, slot = current_item_id}
                end
            end
        end
    end
    
    -- Phase 2: Scanner tous les sacs équipables (logique exacte de GearSwap)
    -- Obtenir la liste des sacs équipables
    local equippable_bags = {}
    for bag_id, bag_data in pairs(res.bags) do
        if bag_data.equippable then
            table.insert(equippable_bags, bag_data)
        end
    end
    
    -- Scanner chaque sac équipable
    for _, bag in ipairs(equippable_bags) do
        local bag_name = bag.en:lower()
        local items_in_bag = items[bag_name]
        
        if items_in_bag then
            -- Itérer sur chaque item du sac
            for slot, item_data in pairs(items_in_bag) do
                if type(item_data) == 'table' and item_data.id and item_data.id > 0 then
                    -- Vérifier si l'item peut être équipé
                    if check_wearable(item_data.id) then
                        -- Vérifier si l'item est disponible (status = 0 ou 5)
                        if item_data.status == 0 or item_data.status == 5 then
                            -- Vérifier chaque slot possible pour cet item
                            local item_slots = res.items[item_data.id].slots
                            if item_slots then
                                for slot_id in pairs(item_slots) do
                                    if default_slot_map[slot_id] then
                                        local slot_name = default_slot_map[slot_id]
                                        
                                        -- Vérifier si on cherche encore quelque chose pour ce slot
                                        if equip_list[slot_name] and not used_list[slot_id] then
                                            -- Éviter les conflits main/sub et ear/ring
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
                                                local name, priority, augments, designated_bag = expand_entry(equip_list[slot_name])
                                                
                                                if (not designated_bag or designated_bag == bag.id) and name and name_match(item_data.id, name) then
                                                    -- Vérifier les augments si nécessaire
                                                    if augments and #augments > 0 then
                                                        local item_is_rare = res.items[item_data.id].flags and res.items[item_data.id].flags.Rare
                                                        if item_is_rare or compare_augments(augments, {}) then
                                                            -- Item trouvé!
                                                            equip_list[slot_name] = nil
                                                            used_list[slot_id] = {bag_id = bag.id, slot = slot}
                                                            break
                                                        end
                                                    else
                                                        -- Pas d'augments spécifiés, item OK
                                                        equip_list[slot_name] = nil
                                                        used_list[slot_id] = {bag_id = bag.id, slot = slot}
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            -- Item indisponible (status != 0 et != 5)
                            for slot_id in pairs(res.items[item_data.id].slots or {}) do
                                if default_slot_map[slot_id] then
                                    local slot_name = default_slot_map[slot_id]
                                    local name = expand_entry(equip_list[slot_name])
                                    
                                    if name and name ~= empty and name_match(item_data.id, name) then
                                        if item_data.status == 25 then
                                            error_list[slot_name] = name .. ' (bazaared)'
                                        else
                                            error_list[slot_name] = name .. ' (status unknown: ' .. item_data.status .. ')'
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    else
                        -- Item non équipable pour ce joueur
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
    
    -- Phase 3: Compiler les résultats
    -- Tout ce qui reste dans equip_list n'a pas pu être trouvé
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
    
    -- Créer la liste des erreurs
    local all_errors = {}
    for slot, error_msg in pairs(error_list) do
        table.insert(all_errors, string.format("[%s] %s", slot, error_msg))
    end
    
    for _, missing in ipairs(missing_items) do
        table.insert(all_errors, string.format("[%s] %s - %s", missing.slot, missing.name, missing.reason))
    end
    
    -- Compiler le résultat final
    local result = {
        valid = (#missing_items == 0 and #all_errors == 0),
        missing_items = missing_items,
        errors = all_errors,
        used_items = used_list,
        set_name = set_name
    }
    
    -- Mettre en cache le résultat
    validation_cache[cache_key] = result
    cache_timestamp = current_time
    
    return result
end

---============================================================================
--- FONCTIONS DE COMMODITÉ
---============================================================================

--- Valide un set et affiche les résultats
--- @param equipment_set (table): Set à valider
--- @param set_name (string): Nom du set
--- @param show_success (boolean): Afficher un message si tout est OK
function EquipmentValidator.validate_and_report(equipment_set, set_name, show_success)
    local result = EquipmentValidator.validate_equipment_set(equipment_set, set_name)
    
    if result.valid then
        if show_success then
            windower.add_to_chat(030, string.format("[Equipment Validator] Set '%s' est valide", set_name or "anonymous"))
        end
    else
        windower.add_to_chat(167, string.format("[Equipment Validator] Set '%s' contient des erreurs:", set_name or "anonymous"))
        
        for _, error_msg in ipairs(result.errors) do
            windower.add_to_chat(001, "  " .. error_msg)
        end
        
        if #result.missing_items > 0 then
            windower.add_to_chat(167, string.format("Items manquants: %d", #result.missing_items))
            for _, missing in ipairs(result.missing_items) do
                windower.add_to_chat(001, string.format("  [%s] %s", missing.slot, missing.name))
            end
        end
    end
    
    return result
end

--- Valide tous les sets définis
--- @param sets_table (table): Table des sets (généralement 'sets')
--- @param report_valid (boolean): Signaler aussi les sets valides
function EquipmentValidator.validate_all_sets(sets_table, report_valid)
    if not sets_table or type(sets_table) ~= 'table' then
        windower.add_to_chat(167, "[Equipment Validator] No sets found to validate")
        return
    end
    
    windower.add_to_chat(160, "=== COMPLETE EQUIPMENT VALIDATION ===")
    
    local total_sets = 0
    local valid_sets = 0
    local invalid_sets = 0
    
    -- Fonction récursive pour valider les sets imbriqués
    local function validate_nested(table_ref, path)
        for key, value in pairs(table_ref) do
            if type(value) == 'table' then
                local current_path = path and (path .. "." .. key) or key
                
                -- Vérifier si c'est un set d'équipement (contient des slots)
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
                        
                        -- Afficher quelques erreurs
                        for i = 1, math.min(3, #result.errors) do
                            windower.add_to_chat(001, "    " .. result.errors[i])
                        end
                        
                        if #result.errors > 3 then
                            windower.add_to_chat(001, string.format("    ... and %d more errors", #result.errors - 3))
                        end
                    end
                else
                    -- Continuer la recherche récursive
                    validate_nested(value, current_path)
                end
            end
        end
    end
    
    validate_nested(sets_table, nil)
    
    windower.add_to_chat(160, string.format("=== RESULTATS: %d/%d sets valides ===", valid_sets, total_sets))
    if invalid_sets > 0 then
        windower.add_to_chat(167, string.format("⚠ %d sets nécessitent votre attention", invalid_sets))
    end
end

--- Efface le cache de validation
function EquipmentValidator.clear_cache()
    validation_cache = {}
    cache_timestamp = 0
    windower.add_to_chat(030, "[Equipment Validator] Cache effacé")
end

--- Obtient les statistiques du cache
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