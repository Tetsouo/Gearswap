---============================================================================
--- Error Collector - Version 2.0 - ULTRA OPTIMISE SANS LAG
---============================================================================

local res = require('resources')
local ErrorCollector = {}

-- Sérialiseur JSON simple (copié depuis metrics_collector.lua)
local function serialize_json(obj, indent_level)
    indent_level = indent_level or 0
    local indent = string.rep("  ", indent_level)
    local next_indent = string.rep("  ", indent_level + 1)
    
    local function serialize_value(val, current_indent)
        local val_type = type(val)
        
        if val_type == "string" then
            return '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
        elseif val_type == "number" then
            return tostring(val)
        elseif val_type == "boolean" then
            return tostring(val)
        elseif val_type == "table" then
            local is_array = true
            local max_index = 0
            
            -- Déterminer si c'est un tableau ou un objet
            for k, v in pairs(val) do
                if type(k) ~= "number" then
                    is_array = false
                    break
                else
                    max_index = math.max(max_index, k)
                end
            end
            
            if is_array and max_index > 0 then
                -- Tableau JSON
                local result = "[\n"
                local first = true
                for i = 1, max_index do
                    if not first then
                        result = result .. ",\n"
                    end
                    result = result .. next_indent .. serialize_value(val[i], current_indent + 1)
                    first = false
                end
                result = result .. "\n" .. indent .. "]"
                return result
            else
                -- Objet JSON
                local result = "{\n"
                local first = true
                for k, v in pairs(val) do
                    if not first then
                        result = result .. ",\n"
                    end
                    result = result .. next_indent .. '"' .. tostring(k) .. '": ' .. serialize_value(v, current_indent + 1)
                    first = false
                end
                result = result .. "\n" .. indent .. "}"
                return result
            end
        else
            return 'null'
        end
    end
    
    return serialize_value(obj, indent_level)
end

-- Variables
local captured_errors = {}
local collecting = false
local current_set_being_tested = nil

-- CACHE GLOBAL pour éviter les recalculs
local item_lookup_cache = {}
local inventory_cache = {}
local cache_initialized = false

-- Couleurs FFXI (codes corrects pour visibilité)
local colors = {
    system = 001,    -- Blanc
    success = 030,   -- Vert vif
    warning = 057,   -- Orange vif (plus visible que 056)  
    error = 167,     -- Rouge-rose (plus visible que 028)
    info = 005,      -- Cyan vif
    header = 050,    -- Jaune vif pour headers
    separator = 160  -- Gris-violet pour séparateurs
}

---============================================================================
--- INITIALISATION DU CACHE (1 seule fois au debut)
---============================================================================

local function init_cache()
    if cache_initialized then return end
    
    if not res or not res.items then 
        windower.add_to_chat(colors.error, "[ERROR] Base de donnees non disponible")
        return 
    end
    
    -- Construire le cache de lookup pour TOUS les items
    item_lookup_cache = {}
    for id, item in pairs(res.items) do
        if item.en then
            -- Indexer par nom EN en minuscules
            local key = item.en:lower()
            item_lookup_cache[key] = item
        end
        if item.enl then
            -- Indexer AUSSI par nom ENL (nom complet)
            local key = item.enl:lower()
            item_lookup_cache[key] = item
        end
    end
    
    cache_initialized = true
    windower.add_to_chat(colors.success, string.format("[CACHE] %d items indexes", 
        table.length(item_lookup_cache)))
    windower.add_to_chat(colors.success, "[OK] Systeme pret")
end

---============================================================================
--- VALIDATION DES ITEMS (avec cache intelligent)
---============================================================================

local function item_exists_check(item_name)
    init_cache()
    
    if not item_name or item_name == "" then
        return false, "Nom d'item vide"
    end
    
    -- Lookup direct dans le cache
    local item_lower = item_name:lower()
    if item_lookup_cache[item_lower] then
        return true, nil
    end
    
    return false, "Item non trouve dans la base de donnees"
end

local function item_in_inventory_check(item_name)
    init_cache()
    
    -- Construire le cache d'inventaire une seule fois
    if not next(inventory_cache) then
        -- Debug désactivé : windower.add_to_chat(001, "[DEBUG] Building inventory cache...")
        
        local inventory = windower.ffxi.get_items()
        if not inventory then 
            windower.add_to_chat(167, "[DEBUG] ERROR: Could not get inventory!")
            return true 
        end
        
        inventory_cache = {}
        -- Vérifier inventory + wardrobes 1-8 + locker/safe/storage pour détection complète
        local bags = {'inventory', 'wardrobe', 'wardrobe2', 'wardrobe3', 'wardrobe4', 
                      'wardrobe5', 'wardrobe6', 'wardrobe7', 'wardrobe8'}
        local storage_bags = {'locker', 'safe', 'storage'}
        
        -- Vérifier les bags principaux (inventory + wardrobes)
        for _, bag_name in ipairs(bags) do
            local bag = inventory[bag_name]
            if bag and bag.max and bag.max > 0 then
                for i = 1, bag.max do
                    local slot = bag[i]
                    if slot and slot.id and slot.id > 0 then
                        -- Récupérer l'item directement par ID depuis res.items
                        if res and res.items and res.items[slot.id] then
                            local item = res.items[slot.id]
                            -- Stocker en minuscules pour comparaison
                            if item.en then
                                inventory_cache[item.en:lower()] = {available = true, location = bag_name}
                            end
                            if item.enl then
                                inventory_cache[item.enl:lower()] = {available = true, location = bag_name}
                            end
                        end
                    end
                end
            end
        end
        
        -- Vérifier aussi les storage bags (locker, safe, storage) 
        for _, bag_name in ipairs(storage_bags) do
            local bag = inventory[bag_name]
            if bag and bag.max and bag.max > 0 then
                for i = 1, bag.max do
                    local slot = bag[i]
                    if slot and slot.id and slot.id > 0 then
                        if res and res.items and res.items[slot.id] then
                            local item = res.items[slot.id]
                            if item.en then
                                -- Marquer comme étant en storage (pas disponible pour équipement)
                                local key = item.en:lower()
                                if not inventory_cache[key] then -- Si pas déjà trouvé dans inventory/wardrobes
                                    inventory_cache[key] = {available = false, location = bag_name}
                                end
                            end
                            if item.enl then
                                local key = item.enl:lower()
                                if not inventory_cache[key] then
                                    inventory_cache[key] = {available = false, location = bag_name}
                                end
                            end
                        end
                    end
                end
            end
        end
        
        local cache_size = 0
        for _ in pairs(inventory_cache) do
            cache_size = cache_size + 1
        end
        -- Debug désactivé : windower.add_to_chat(030, string.format("[DEBUG] Inventory cache built: %d items", cache_size))
    end
    
    -- Lookup direct dans le cache avec détection de location
    local item_lower = item_name:lower()
    local cached_item = inventory_cache[item_lower]
    
    if cached_item then
        if type(cached_item) == 'table' then
            -- Nouveau format avec location
            return cached_item.available, cached_item.location
        else
            -- Format legacy (pour compatibilité)
            return true, 'inventory'
        end
    end
    
    return false, "Not found in any container"
end

---============================================================================
--- ANALYSE DES SETS
---============================================================================

local function analyze_equipment_set(set_table, set_name)
    if type(set_table) ~= 'table' then return {} end
    
    local errors = {}
    local equipment_slots = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 
                             'ear1', 'ear2', 'left_ear', 'right_ear',
                             'body', 'hands', 'ring1', 'ring2', 'left_ring', 'right_ring',
                             'back', 'waist', 'legs', 'feet'}
    
    for _, slot in ipairs(equipment_slots) do
        local item_data = set_table[slot]
        local item_name = nil
        
        -- Extraire le nom de l'item selon le type
        if type(item_data) == 'string' and item_data ~= "" then
            item_name = item_data
        elseif type(item_data) == 'table' then
            -- Gérer les objets createEquipment() ou tables d'équipement
            if item_data.name then
                item_name = item_data.name  -- Format { name = "Ochain", augments = {...} }
            elseif item_data[1] then
                item_name = item_data[1]    -- Format { "Ochain", augments = {...} }
            end
        end
        
        -- Ignorer les slots "empty" (c'est volontaire, pas une erreur)
        if item_name and (item_name:lower() == "empty" or item_name:lower() == "none" or item_name:lower() == "nil") then
            item_name = nil  -- Ignorer
        end
        
        -- Si l'item existe dans le set
        if item_name and type(item_name) == 'string' and item_name ~= "" then
            -- Debug désactivé : windower.add_to_chat(001, string.format("[DEBUG] Testing item: [%s] %s (type: %s)", slot, item_name, type(item_data)))
            -- Vérifier si l'item existe dans la DB de FFXI
            local exists, error_msg = item_exists_check(item_name)
            if not exists then
                -- Item non valide
                table.insert(errors, {
                    slot = slot,
                    item = item_name,
                    error = error_msg,
                    type = "invalid_item"
                })
            else
                -- L'item existe dans la DB, vérifier s'il est dans inventory+wardrobes ou storage
                local in_inv, location = item_in_inventory_check(item_name)
                -- Debug désactivé : windower.add_to_chat(001, string.format("[DEBUG] Item %s: in_inv=%s, location=%s", item_name, tostring(in_inv), tostring(location)))
                
                if not in_inv then
                    local error_msg = location or "Not found in any container"
                    local error_type = "missing_item"
                    
                    -- Vérifier si l'item est en storage (locker/safe/storage)
                    if location and (location == "locker" or location == "safe" or location == "storage") then
                        error_msg = string.format("Item found in %s - move to inventory/wardrobe to equip", location:upper())
                        error_type = "item_in_storage"
                    end
                    
                    table.insert(errors, {
                        slot = slot,
                        item = item_name,
                        error = error_msg,
                        type = error_type,
                        location = location
                    })
                end
            end
        end
    end
    
    return errors
end

---============================================================================
--- FONCTIONS PRINCIPALES
---============================================================================

function ErrorCollector.start_collecting()
    captured_errors = {}
    collecting = true
    inventory_cache = {}  -- Reset du cache d'inventaire à chaque démarrage
    
    -- Initialiser le cache au démarrage
    init_cache()
end

function ErrorCollector.stop_collecting()
    collecting = false
    
    -- Export automatique JSON dans le dossier data de l'utilisateur
    local timestamp = os.date('%Y%m%d_%H%M%S')
    local user_path = windower.addon_path .. 'data/' .. (player and player.name or 'Unknown') .. '/'
    local filename = user_path .. 'equipment_errors.json'
    
    local data = {
        job = player and player.main_job or "Unknown",
        timestamp = timestamp,
        errors = captured_errors
    }
    
    local json_content = serialize_json(data)
    local file = io.open(filename, 'w')
    if file then
        file:write(json_content)
        file:close()
        windower.add_to_chat(colors.success, "[JSON] Export: " .. filename)
    else
        windower.add_to_chat(colors.error, "[ERROR] JSON export failed")
    end
end

function ErrorCollector.set_current_testing_set(set_name)
    current_set_being_tested = set_name
end

function ErrorCollector.analyze_set(set_name)
    if not collecting then return end
    
    -- Sets spéciaux à ignorer (volontairement vides ou spéciaux)
    local ignored_sets = {
        ["sets.naked"] = true,
        ["naked"] = true,
        ["sets.empty"] = true,
        ["empty"] = true,
        ["sets.none"] = true,
        ["none"] = true,
    }
    
    -- Ignorer les sets spéciaux
    if ignored_sets[set_name] or ignored_sets[set_name:lower()] then
        return  -- Ignorer silencieusement
    end
    
    -- Naviguer jusqu'au set demandé
    local current_set = sets
    local path_parts = {}
    
    -- Diviser le path en parties (ex: "sets.midcast.Cure" -> {"sets", "midcast", "Cure"})
    for part in set_name:gmatch("[^%.]+") do
        table.insert(path_parts, part)
    end
    
    -- Si le path commence par "sets", ignorer cette partie car on part déjà de la variable 'sets'
    if path_parts[1] == "sets" then
        table.remove(path_parts, 1)
    end
    
    -- Ignorer aussi si le dernier élément est "naked", "empty", etc.
    local last_part = path_parts[#path_parts]
    if last_part and (last_part:lower() == "naked" or last_part:lower() == "empty" or last_part:lower() == "none") then
        return  -- Ignorer silencieusement
    end
    
    -- Naviguer partie par partie
    for i, part in ipairs(path_parts) do
        if current_set and type(current_set) == 'table' then
            -- Essayer d'accéder à la partie
            if current_set[part] then
                current_set = current_set[part]
            else
                -- Debug: afficher les clés disponibles
                local available_keys = {}
                for k, v in pairs(current_set) do
                    if type(v) == 'table' then
                        table.insert(available_keys, k)
                    end
                end
                
                -- Set non trouvé - essayer avec des espaces ou autres variations
                local found_alt = false
                
                -- Essayer de trouver une clé similaire (avec espaces, etc.)
                for k, v in pairs(current_set) do
                    if type(k) == 'string' and k:lower():gsub(' ', ''):gsub('-', '') == part:lower():gsub(' ', ''):gsub('-', '') then
                        current_set = v
                        found_alt = true
                        break
                    end
                end
                
                if not found_alt then
                    -- Vraiment pas trouvé, mais si c'est le dernier élément, ignorer
                    if i == #path_parts then
                        -- Set non trouvé mais pas critique
                        return
                    else
                        -- Navigation échouée
                        table.insert(captured_errors, {
                            set_name = set_name,
                            error_message = string.format("Path navigation failed at '%s' (step %d/%d)", part, i, #path_parts),
                            timestamp = os.time()
                        })
                        return
                    end
                end
            end
        else
            -- current_set n'est pas une table
            table.insert(captured_errors, {
                set_name = set_name,
                error_message = string.format("Path '%s' leads to non-table value", table.concat(path_parts, ".", 1, i-1)),
                timestamp = os.time()
            })
            return
        end
    end
    
    -- Analyser le set si c'est une table d'équipement
    if type(current_set) == 'table' then
        local errors = analyze_equipment_set(current_set, set_name)
        
        for _, error in ipairs(errors) do
            table.insert(captured_errors, {
                set_name = set_name,
                error_message = string.format("[%s] %s: %s", error.slot, error.item, error.error),
                timestamp = os.time(),
                error_type = error.type or "unknown"
            })
        end
    -- else
        -- Debug désactivé : windower.add_to_chat(001, string.format("[DEBUG] Set %s is not a table: %s", set_name, type(current_set)))
    end
end

function ErrorCollector.show_report()
    -- Le header est déjà affiché par universal_commands.lua
    
    if #captured_errors == 0 then
        windower.add_to_chat(030, "[OK] No errors detected")
        windower.add_to_chat(030, "[OK] All sets are valid!")
    else
        -- Compter les différents types d'erreurs
        local missing_count = 0
        local storage_count = 0
        local other_count = 0
        
        for _, error in ipairs(captured_errors) do
            if error.error_message and error.error_message:find("LOCKER") or 
               error.error_message and error.error_message:find("SAFE") or 
               error.error_message and error.error_message:find("STORAGE") then
                storage_count = storage_count + 1
            elseif error.error_message and error.error_message:find("Not found") then
                missing_count = missing_count + 1
            else
                other_count = other_count + 1
            end
        end
        
        windower.add_to_chat(028, string.format("TOTAL: %d error(s)", #captured_errors))
        if storage_count > 0 then
            windower.add_to_chat(057, string.format("  - %d item(s) found in STORAGE/LOCKER", storage_count))
        end
        if missing_count > 0 then
            windower.add_to_chat(167, string.format("  - %d item(s) completely MISSING", missing_count))
        end
        if other_count > 0 then
            windower.add_to_chat(001, string.format("  - %d other error(s)", other_count))
        end
        windower.add_to_chat(160, "")
        
        local errors_by_set = {}
        for _, error in ipairs(captured_errors) do
            if not errors_by_set[error.set_name] then
                errors_by_set[error.set_name] = {}
            end
            table.insert(errors_by_set[error.set_name], error.error_message)
        end
        
        for set_name, errors in pairs(errors_by_set) do
            windower.add_to_chat(167, "> " .. set_name)
            for _, error_msg in ipairs(errors) do
                -- Utiliser des couleurs différentes selon le type d'erreur
                local color = 167  -- Rouge par défaut pour les erreurs
                if error_msg:find("LOCKER") or error_msg:find("SAFE") or error_msg:find("STORAGE") then
                    color = 057  -- Orange vif pour les items en storage
                elseif error_msg:find("Not found") then
                    color = 167  -- Rouge-rose pour les items manquants
                elseif error_msg:find("move to inventory") then
                    color = 057  -- Orange vif pour les instructions
                end
                windower.add_to_chat(color, "  " .. error_msg)
            end
        end
    end
    
    windower.add_to_chat(205, "============================")
end

function ErrorCollector.get_capture_status()
    return {
        collecting = collecting,
        current_set = current_set_being_tested,
        total_errors = #captured_errors
    }
end

function ErrorCollector.get_errors()
    return captured_errors
end

function ErrorCollector.is_active()
    return collecting
end

function ErrorCollector.toggle()
    if collecting then
        ErrorCollector.stop_collecting()
    else
        ErrorCollector.start_collecting()
    end
    return collecting
end

function ErrorCollector.test_analysis()
    -- Test avec quelques erreurs fictives pour démonstration
    table.insert(captured_errors, {
        set_name = "sets.test.demo",
        error_message = "[main] Excalibur: Not found in any container",
        timestamp = os.time()
    })
    
    table.insert(captured_errors, {
        set_name = "sets.test.storage", 
        error_message = "[sub] Ochain: Item found in LOCKER - move to inventory/wardrobe to equip",
        timestamp = os.time()
    })
end

-- Fonction de test d'inventaire pour debug
function ErrorCollector.test_inventory_search(item_name)
    init_cache()
    local in_inv, location = item_in_inventory_check(item_name)
    windower.add_to_chat(colors.info, string.format("Test item: %s", item_name))
    windower.add_to_chat(in_inv and colors.success or colors.error, 
        string.format("Available: %s, Location: %s", tostring(in_inv), location or "Not found"))
end

return ErrorCollector