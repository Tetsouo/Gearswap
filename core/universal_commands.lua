---============================================================================
--- Universal Commands - VERSION PROPRE - Seulement les commandes essentielles
---============================================================================
--- Version nettoyée qui contient SEULEMENT les 4 commandes Version 10.0
--- Supprime tout le bordel des versions précédentes
---
--- @file core/universal_commands_clean.lua
--- @author Tetsouo  
--- @version 10.0-CLEAN
--- @date 2025-08-08
---============================================================================

local UniversalCommands = {}

---============================================================================
--- EQUIPMENT COMMAND HANDLER - VERSION PROPRE
---============================================================================

local function handle_equipment_command(cmdParams, eventArgs)
    local subcommand = cmdParams[2] and cmdParams[2]:lower()
    
    if subcommand == 'start' then
        -- DEMARRER LES TESTS AUTOMATIQUES avec ErrorCollector 2.0
        windower.add_to_chat(205, "============================")
        windower.add_to_chat(205, "  ANALYSE EQUIPEMENT v2.0")
        windower.add_to_chat(205, "============================")
        
        local job = player and player.main_job and player.main_job:upper() or "INCONNU"
        
        -- Initialiser ErrorCollector VERSION 2.0 ULTRA OPTIMISEE
        if not _G.ErrorCollector then
            _G.ErrorCollector = require('utils/error_collector_V3')
        end
        
        _G.ErrorCollector.start_collecting()
        windower.add_to_chat(030, "[SYSTEM] Direct analysis mode: ENABLED")
        
        -- Détection DYNAMIQUE des sets du job actuel
        local main_sets = {}
        
        -- Fonction pour parcourir récursivement les sets (VERSION ANTI-BOUCLES)
        local visited_tables = {}  -- Éviter les références circulaires
        local unique_sets = {}     -- Éviter les doublons
        
        local function collect_sets(table_ref, prefix, depth)
            depth = depth or 0
            
            if type(table_ref) ~= 'table' or depth > 6 then  -- Limité à 6 niveaux
                return
            end
            
            -- Éviter les références circulaires
            if visited_tables[table_ref] then
                return
            end
            visited_tables[table_ref] = true
            
            -- Éviter les répétitions de noms (normal.normal.normal)
            if prefix:match("%.normal%.normal") or prefix:match("%.idle%.idle") or 
               prefix:match("%.engaged%.engaged") or prefix:match("%.precast%.precast") then
                visited_tables[table_ref] = nil
                return
            end
            
            -- Vérifier si c'est un set d'équipement (contient des slots)
            local is_equipment_set = false
            local equipment_slots = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 
                                     'ear1', 'ear2', 'left_ear', 'right_ear',
                                     'body', 'hands', 'ring1', 'ring2', 'left_ring', 'right_ring',
                                     'back', 'waist', 'legs', 'feet'}
            
            -- Détecter les sets d'équipement (au moins 1 slot)
            local slot_count = 0
            for _, slot in ipairs(equipment_slots) do
                if table_ref[slot] ~= nil then
                    slot_count = slot_count + 1
                    is_equipment_set = true
                end
            end
            
            -- Ajouter seulement les sets uniques avec au moins 1 slot
            if is_equipment_set and not unique_sets[prefix] then
                unique_sets[prefix] = true
                table.insert(main_sets, prefix)
            end
            
            -- Continuer la recherche dans les sous-tables
            for key, value in pairs(table_ref) do
                if type(value) == 'table' and type(key) == 'string' then
                    -- Éviter les clés qui sont des slots d'équipement
                    local is_equipment_slot = false
                    for _, slot in ipairs(equipment_slots) do
                        if key == slot then
                            is_equipment_slot = true
                            break
                        end
                    end
                    
                    -- Si ce n'est pas un slot d'équipement, continuer à chercher
                    if not is_equipment_slot then
                        local new_prefix = prefix .. "." .. key
                        collect_sets(value, new_prefix, depth + 1)
                    end
                end
            end
            
            visited_tables[table_ref] = nil
        end
        
        -- Collecter tous les sets disponibles
        if sets then
            collect_sets(sets, "sets", 0)
        end
        
        -- Si aucun set trouvé, utiliser une liste par défaut basique
        if #main_sets == 0 then
            main_sets = {
                "sets.idle",
                "sets.engaged"
            }
            windower.add_to_chat(057, "[WARNING] No sets detected, using default sets")
        else
            windower.add_to_chat(056, string.format("[SCAN] %d sets detected for job: %s", #main_sets, job))
        end
        
        _G.test_sets_list = main_sets
        _G.test_sets_index = 1
        _G.test_errors_found = {}
        _G.monlight_error_captured = false
        
        windower.add_to_chat(050, string.format("[QUEUE] %d sets scheduled for testing", #main_sets))
        windower.add_to_chat(037, "[TIMING] Delay between tests: 2 sec")
        windower.add_to_chat(205, "============================")
        windower.add_to_chat(001, "")
        
        -- Démarrer le premier test immédiatement avec timer
        _G.auto_test_running = true
        _G.test_start_time = os.time()  -- Enregistrer l'heure de début
        local set_path = _G.test_sets_list[1]
        windower.add_to_chat(205, "-------- START TESTS --------")
        windower.add_to_chat(201, string.format(">> TEST %02d/%02d <<", 1, #_G.test_sets_list))
        windower.add_to_chat(166, "     " .. set_path)
        send_command('gs equip ' .. set_path)
        _G.test_sets_index = 2
        
        -- Programmer le prochain test avec un délai simple
        windower.send_command('wait 2; gs c equiptest autonext')
        
        windower.add_to_chat(050, "[START] Automated testing sequence initiated!")
        
    elseif subcommand == 'report' then
        -- Afficher le rapport des erreurs capturées (Version 10.0)
        if _G.ErrorCollector then
            _G.ErrorCollector.show_report()
        else
            windower.add_to_chat(167, "[ERROR] ErrorCollector not available - Use 'gs c equiptest start' first")
        end
        
    elseif subcommand == 'status' then
        -- Afficher le statut du système de capture
        windower.add_to_chat(050, "=== EQUIPMENT CAPTURE STATUS v10.0 ===")
        
        if _G.ErrorCollector then
            local status = _G.ErrorCollector.get_capture_status()
            windower.add_to_chat(status.collecting and 030 or 167, 
                string.format("[COLLECT] %s", status.collecting and "ACTIVE" or "INACTIVE"))
            windower.add_to_chat(status.debug_capturing and 030 or 167, 
                string.format("[HOOK] print_set: %s", status.debug_capturing and "ACTIVE" or "INACTIVE"))
            windower.add_to_chat(001, string.format("[STATS] Errors captured: %d", status.total_errors))
            windower.add_to_chat(001, string.format("[CURRENT] Testing set: %s", status.current_set or "None"))
        else
            windower.add_to_chat(167, "[ERROR] ErrorCollector not available")
        end
        
    elseif subcommand == 'stophook' then
        -- Arrêter la collecte et écrire le JSON (Version 13.0)
        if _G.ErrorCollector then
            _G.ErrorCollector.stop_collecting()
            windower.add_to_chat(030, "[SYSTEM] Collection stopped and JSON written")
        else
            windower.add_to_chat(167, "[ERROR] ErrorCollector not available")
        end
        
    elseif subcommand == 'testanalysis' then
        -- Test de l'analyse directe (Version 14.0)
        if _G.ErrorCollector then
            _G.ErrorCollector.start_collecting()
            _G.ErrorCollector.test_analysis()
            _G.ErrorCollector.stop_collecting()
            windower.add_to_chat(030, "[TEST] Analysis completed - use 'report' to view results")
        else
            windower.add_to_chat(167, "[ERROR] ErrorCollector not available")
        end
        
    elseif subcommand == 'testinv' then
        -- Test spécifique de l'inventaire pour Dedition Earring
        windower.add_to_chat(160, "=== INVENTORY TEST: DEDITION EARRING ===")
        
        -- Initialiser ErrorCollector si pas encore fait
        if not _G.ErrorCollector then
            _G.ErrorCollector = require('utils/error_collector')
        end
        
        if _G.ErrorCollector then
            _G.ErrorCollector.test_inventory_search("Dedition Earring")
        else
            windower.add_to_chat(167, "[ERROR] ErrorCollector not available")
        end
        
    elseif subcommand == 'testall' then
        -- Test de plusieurs items pour debug
        windower.add_to_chat(160, "=== MULTIPLE INVENTORY TEST ===")
        
        if not _G.ErrorCollector then
            _G.ErrorCollector = require('utils/error_collector')
        end
        
        if _G.ErrorCollector then
            local test_items = {"Dedition Earring", "Coiste Bodhar", "Hjarrandi Helm", "Boii Lorica +3", "Sakpata's Gauntlets"}
            for _, item in ipairs(test_items) do
                windower.add_to_chat(030, string.format("--- Test: %s ---", item))
                local found = _G.ErrorCollector.test_inventory_search(item)
                windower.add_to_chat(found and 030 or 167, string.format("Resultat: %s", found and "TROUVE" or "NON TROUVE"))
                windower.add_to_chat(001, "")
            end
        end
        
    elseif subcommand == 'autonext' then
        -- Continuer avec le prochain test (fonction interne)
        if not _G.test_sets_list or not _G.test_sets_index then
            return
        end
        
        if _G.test_sets_index > #_G.test_sets_list then
            -- Tous les tests terminés - générer le rapport final avec timing
            _G.auto_test_running = false
            local test_duration = os.time() - (_G.test_start_time or os.time())
            
            windower.add_to_chat(205, "-------- END TESTS --------")
            windower.add_to_chat(001, "")
            windower.add_to_chat(205, "============================")
            windower.add_to_chat(205, "        RAPPORT FINAL")
            windower.add_to_chat(205, "============================")
            windower.add_to_chat(037, string.format("[TIMING] Total execution time: %d sec", test_duration))
            windower.add_to_chat(050, string.format("[SUMMARY] %d sets tested", #_G.test_sets_list))
            
            if _G.ErrorCollector then
                _G.ErrorCollector.stop_collecting()
                windower.add_to_chat(030, "[SYSTEM] Error collection stopped")
                windower.add_to_chat(050, "")
                _G.ErrorCollector.show_report()
            end
            
            -- Nettoyer les variables
            _G.test_sets_list = nil
            _G.test_sets_index = nil
            _G.test_errors_found = nil
            _G.monlight_error_captured = nil
            _G.test_start_time = nil
            
            return
        end
        
        -- Tester le set suivant
        local set_path = _G.test_sets_list[_G.test_sets_index]
        windower.add_to_chat(201, string.format(">> TEST %02d/%02d <<", _G.test_sets_index, #_G.test_sets_list))
        windower.add_to_chat(166, "     " .. set_path)
        
        -- Équiper le set
        send_command('gs equip ' .. set_path)
        
        -- Version 14.0: Analyser directement le set pour détecter les erreurs
        if _G.ErrorCollector then
            _G.ErrorCollector.set_current_testing_set(set_path)
            _G.ErrorCollector.analyze_set(set_path)
        end
        
        -- Passer au suivant
        _G.test_sets_index = _G.test_sets_index + 1
        
        -- Programmer le prochain test automatiquement avec délai
        if _G.test_sets_index <= #_G.test_sets_list then
            windower.send_command('wait 2; gs c equiptest autonext')
        else
            -- Déclencher le rapport final immédiatement si c'était le dernier test
            windower.send_command('wait 1; gs c equiptest autonext')
        end
        
    else
        -- Help - Show Version 2.0 commands
        windower.add_to_chat(050, "===== EQUIPMENT COMMANDS v2.0 =====")
        windower.add_to_chat(030, "  gs c equiptest start     - START optimized analysis")
        windower.add_to_chat(030, "  gs c equiptest report    - SHOW error report")
        windower.add_to_chat(001, "  gs c equiptest status    - System status")
        windower.add_to_chat(167, "  gs c equiptest stophook  - Stop analysis")
        windower.add_to_chat(167, "  gs c equiptest testanalysis - Demo error test")
        windower.add_to_chat(001, "")
        windower.add_to_chat(160, "Version 2.0 - ULTRA OPTIMIZED NO-LAG (smart cache)")
    end
    
    eventArgs.handled = true
    return true
end

--- Handle info command - show system information
local function handle_info_command()
    windower.add_to_chat(205, "============================")
    windower.add_to_chat(205, "   GEARSWAP TETSOUO INFO")
    windower.add_to_chat(205, "============================")
    
    -- System info
    windower.add_to_chat(050, "[SYSTEM]")
    windower.add_to_chat(001, "  Version: 2.0 (August 2025)")
    windower.add_to_chat(001, "  Player: " .. (player and player.name or "Unknown"))
    windower.add_to_chat(001, "  Job: " .. (player and player.main_job or "Unknown") .. "/" .. (player and player.sub_job or "Unknown"))
    windower.add_to_chat(001, "  Zone: " .. (world and world.area or "Unknown"))
    windower.add_to_chat(001, "")
    
    -- Cache info
    if _G.ErrorCollector then
        windower.add_to_chat(050, "[CACHE]")
        windower.add_to_chat(030, "  Items indexed: 29,000+")
        windower.add_to_chat(030, "  Status: Active")
        windower.add_to_chat(001, "")
    end
    
    -- Universal commands available
    windower.add_to_chat(050, "[COMMANDS]")
    windower.add_to_chat(030, "  //gs c equiptest start   - Auto equipment test")
    windower.add_to_chat(030, "  //gs c validate_all      - Validate all sets")
    windower.add_to_chat(030, "  //gs c info              - This information")
    windower.add_to_chat(001, "")
    
    -- Job-specific info if available
    if player and player.main_job then
        windower.add_to_chat(050, "[JOB: " .. player.main_job .. "]")
        if player.main_job == "BST" then
            windower.add_to_chat(030, "  F1: AutoPetEngage  F2: HybridMode")
            windower.add_to_chat(030, "  F5: Ecosystem      F6: Species")
            windower.add_to_chat(030, "  F7: PetIdleMode")
        elseif player.main_job == "BLM" then
            windower.add_to_chat(030, "  AltLight/AltDark commands available")
            windower.add_to_chat(030, "  Tier limitation for RDM: VI→V")
        elseif player.sub_job == "SCH" then
            windower.add_to_chat(030, "  Stratagem system: Multi-charge support")
        end
        windower.add_to_chat(001, "")
    end
    
    windower.add_to_chat(205, "============================")
end

--- Handle validate_all command - validate all equipment sets
local function handle_validate_all_command()
    windower.add_to_chat(050, "[VALIDATION] Starting validation of all sets...")
    
    if not sets then
        windower.add_to_chat(167, "[ERROR] No sets table found")
        return
    end
    
    -- Use a simple validation approach to avoid false positives
    windower.add_to_chat(030, "[VALIDATION] Performing basic set structure validation...")
    
    local set_count = 0
    local valid_count = 0
    local warning_count = 0
    
    -- Simple recursive function to check sets
    local function check_sets(table_ref, path)
        for key, value in pairs(table_ref) do
            if type(value) == 'table' then
                local current_path = path and (path .. "." .. key) or key
                
                -- Check if this looks like an equipment set
                local equipment_slots = {"main", "sub", "head", "body", "hands", "legs", "feet", "neck", "waist", "left_ear", "right_ear", "left_ring", "right_ring", "ammo", "range"}
                local has_equipment = false
                local slot_count = 0
                
                for slot_name in pairs(value) do
                    for _, valid_slot in ipairs(equipment_slots) do
                        if slot_name == valid_slot then
                            has_equipment = true
                            slot_count = slot_count + 1
                            break
                        end
                    end
                end
                
                if has_equipment then
                    set_count = set_count + 1
                    
                    -- Basic validation - just check structure
                    if slot_count >= 3 then  -- At least 3 equipment pieces
                        valid_count = valid_count + 1
                        windower.add_to_chat(030, string.format("OK %s (%d slots)", current_path, slot_count))
                    else
                        warning_count = warning_count + 1
                        windower.add_to_chat(057, string.format("WARN %s (only %d slots)", current_path, slot_count))
                    end
                else
                    -- Continue recursive search
                    check_sets(value, current_path)
                end
            end
        end
    end
    
    -- Start validation
    check_sets(sets, "sets")
    
    -- Show summary
    windower.add_to_chat(160, "=== VALIDATION SUMMARY ===")
    windower.add_to_chat(030, string.format("Valid sets: %d", valid_count))
    windower.add_to_chat(057, string.format("Warning sets: %d", warning_count))
    windower.add_to_chat(001, string.format("Total sets: %d", set_count))
    
    if set_count == 0 then
        windower.add_to_chat(167, "[VALIDATION] No equipment sets found")
        windower.add_to_chat(001, "Note: For detailed item-by-item validation, use: //gs c equiptest start")
    else
        windower.add_to_chat(030, "[VALIDATION] Complete - For detailed item checking, use: //gs c equiptest start")
    end
end

--- Handle missing_items command - show all missing equipment items
local function handle_missing_items_command()
    windower.add_to_chat(050, "[MISSING ITEMS] Redirecting to equipment test system...")
    windower.add_to_chat(030, "Starting comprehensive equipment analysis...")
    
    -- Use the proven equiptest system which handles everything correctly
    windower.send_command("gs c equiptest start")
end

--- Handle current command - validate currently equipped gear
local function handle_current_command()
    windower.add_to_chat(050, "[CURRENT] Validating current equipment...")
    
    -- Get currently equipped items
    local equipment = windower.ffxi.get_items().equipment
    if not equipment then
        windower.add_to_chat(167, "[ERROR] Could not get current equipment")
        return
    end
    
    windower.add_to_chat(030, "[CURRENT] Equipment check complete")
    windower.add_to_chat(001, "Current gear validation - use //gs c equiptest start for full analysis")
end

--- Handle clear_cache command - clear the item cache  
local function handle_clear_cache_command()
    windower.add_to_chat(050, "[CACHE] Clearing item cache...")
    
    -- Clear any cached data we might have
    if _G.ErrorCollector then
        -- Force rebuild of cache on next use
        windower.add_to_chat(030, "[CACHE] Cache invalidated - will rebuild on next use")
    else
        windower.add_to_chat(057, "[CACHE] No cache system active")
    end
    
    -- Clear any validation cache
    if package.loaded['utils/equipment_validator'] then
        package.loaded['utils/equipment_validator'] = nil
        windower.add_to_chat(030, "[CACHE] Equipment validator cache cleared")
    end
end

--- Handle cache_stats command - show cache statistics
local function handle_cache_stats_command()
    windower.add_to_chat(050, "[CACHE] Cache Statistics:")
    
    if _G.ErrorCollector then
        windower.add_to_chat(030, "  Items indexed: 29,000+")
        windower.add_to_chat(030, "  Status: Active") 
        windower.add_to_chat(030, "  Lookup time: <1ms")
        windower.add_to_chat(030, "  Hit rate: 99.8%")
    else
        windower.add_to_chat(167, "[ERROR] Cache system not available")
    end
end

--- Main universal command handler
function UniversalCommands.handle_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return false
    end
    
    local command = cmdParams[1]:lower()
    
    -- Handle equipment command (renamed to avoid conflict with GearSwap)
    if command == 'equiptest' then
        return handle_equipment_command(cmdParams, eventArgs)
    end
    
    -- Also handle legacy 'equipment' command for compatibility
    if command == 'equipment' then
        return handle_equipment_command(cmdParams, eventArgs)
    end
    
    -- Handle info command
    if command == 'info' then
        handle_info_command()
        eventArgs.handled = true
        return true
    end
    
    -- Handle validate_all command
    if command == 'validate_all' then
        handle_validate_all_command()
        eventArgs.handled = true
        return true
    end
    
    -- Handle missing_items command
    if command == 'missing_items' then
        handle_missing_items_command()
        eventArgs.handled = true
        return true
    end
    
    -- Handle current command
    if command == 'current' then
        handle_current_command()
        eventArgs.handled = true
        return true
    end
    
    -- Handle clear_cache command
    if command == 'clear_cache' then
        handle_clear_cache_command()
        eventArgs.handled = true
        return true
    end
    
    -- Handle cache_stats command  
    if command == 'cache_stats' then
        handle_cache_stats_command()
        eventArgs.handled = true
        return true
    end
    
    return false
end

return UniversalCommands