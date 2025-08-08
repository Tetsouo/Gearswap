---============================================================================
--- Test de l'Equipment Validator
---============================================================================
--- Script de test pour valider le bon fonctionnement de l'equipment validator
--- Peut être exécuté avec //lua l test_equipment_validator
---
--- @file test_equipment_validator.lua  
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-08
---============================================================================

-- Charger l'Equipment Validator
local EquipmentValidator = require('utils/equipment_validator')

-- Fonction principale de test
local function run_tests()
    windower.add_to_chat(160, "=== TEST EQUIPMENT VALIDATOR ===")
    
    -- Test 1: Vérifier si le module se charge correctement
    windower.add_to_chat(030, "Test 1: Chargement du module...")
    if EquipmentValidator then
        windower.add_to_chat(030, "✓ Module chargé avec succès")
    else
        windower.add_to_chat(167, "✗ Échec du chargement du module")
        return
    end
    
    -- Test 2: Tester avec un set simple connu pour être valide
    windower.add_to_chat(030, "Test 2: Validation d'un set simple...")
    local simple_set = {
        head = "Sulevia's Mask +2",
        body = "Sulevia's Platemail +2"
    }
    
    local result = EquipmentValidator.validate_equipment_set(simple_set, "test_simple")
    if result then
        windower.add_to_chat(030, string.format("✓ Validation terminée - Valide: %s, Erreurs: %d", 
            tostring(result.valid), #result.errors))
        
        if #result.errors > 0 then
            windower.add_to_chat(001, "Erreurs détectées:")
            for _, error in ipairs(result.errors) do
                windower.add_to_chat(001, "  " .. error)
            end
        end
    else
        windower.add_to_chat(167, "✗ Échec de la validation")
    end
    
    -- Test 3: Tester avec un set contenant des items inexistants
    windower.add_to_chat(030, "Test 3: Validation avec items inexistants...")
    local invalid_set = {
        head = "Casque_Inexistant_12345",
        body = "Armure_Bidon_98765",
        hands = "Sulevia's Gauntlets +2"  -- Celui-ci devrait être valide
    }
    
    local result2 = EquipmentValidator.validate_equipment_set(invalid_set, "test_invalid")
    if result2 then
        windower.add_to_chat(030, string.format("✓ Test invalid terminé - Valide: %s, Items manquants: %d", 
            tostring(result2.valid), #result2.missing_items))
        
        if #result2.missing_items > 0 then
            windower.add_to_chat(001, "Items manquants détectés:")
            for _, missing in ipairs(result2.missing_items) do
                windower.add_to_chat(001, string.format("  [%s] %s", missing.slot, missing.name))
            end
        end
    else
        windower.add_to_chat(167, "✗ Échec du test invalid")
    end
    
    -- Test 4: Tester les fonctions de commodité
    windower.add_to_chat(030, "Test 4: Fonctions de commodité...")
    
    -- Stats du cache
    local cache_stats = EquipmentValidator.get_cache_stats()
    if cache_stats then
        windower.add_to_chat(030, string.format("✓ Cache: %d entrées, âge: %d secondes", 
            cache_stats.entries, cache_stats.age))
    end
    
    -- Test 5: Valider avec rapport détaillé
    windower.add_to_chat(030, "Test 5: Rapport détaillé...")
    EquipmentValidator.validate_and_report(simple_set, "rapport_test", true)
    
    -- Test 6: Tester avec les vrais sets si disponibles
    windower.add_to_chat(030, "Test 6: Validation des sets existants...")
    if sets then
        windower.add_to_chat(030, "Sets détectés, lancement de la validation complète...")
        EquipmentValidator.validate_all_sets(sets, false) -- Ne pas rapporter les sets valides pour éviter le spam
    else
        windower.add_to_chat(167, "Aucun set détecté (variable 'sets' non trouvée)")
    end
    
    windower.add_to_chat(160, "=== FIN DES TESTS ===")
end

-- Fonction pour tester un set spécifique
local function test_specific_set(set_name)
    if not sets then
        windower.add_to_chat(167, "Variable 'sets' non disponible")
        return
    end
    
    -- Trouver le set par son nom (recherche récursive)
    local function find_set(table_ref, path, target_name)
        for key, value in pairs(table_ref) do
            local current_path = path and (path .. "." .. key) or key
            
            if current_path:lower() == target_name:lower() then
                return value, current_path
            end
            
            if type(value) == 'table' then
                local found_set, found_path = find_set(value, current_path, target_name)
                if found_set then
                    return found_set, found_path
                end
            end
        end
        return nil, nil
    end
    
    local found_set, full_path = find_set(sets, nil, set_name)
    
    if found_set then
        windower.add_to_chat(030, string.format("Test du set: %s", full_path))
        EquipmentValidator.validate_and_report(found_set, full_path, true)
    else
        windower.add_to_chat(167, string.format("Set '%s' non trouvé", set_name))
    end
end

-- Fonction d'aide
local function show_help()
    windower.add_to_chat(160, "=== EQUIPMENT VALIDATOR TEST ===")
    windower.add_to_chat(030, "Commandes disponibles:")
    windower.add_to_chat(001, "  //lua l test_equipment_validator test - Lance tous les tests")
    windower.add_to_chat(001, "  //lua l test_equipment_validator set <nom> - Teste un set spécifique")
    windower.add_to_chat(001, "  //lua l test_equipment_validator validate - Valide tous les sets")
    windower.add_to_chat(001, "  //lua l test_equipment_validator clear - Efface le cache")
    windower.add_to_chat(001, "  //lua l test_equipment_validator help - Affiche cette aide")
end

-- Interface de commande
if arg and arg[1] then
    local command = arg[1]:lower()
    
    if command == "test" then
        run_tests()
    elseif command == "set" and arg[2] then
        test_specific_set(arg[2])
    elseif command == "validate" then
        if sets then
            EquipmentValidator.validate_all_sets(sets, false)
        else
            windower.add_to_chat(167, "Variable 'sets' non disponible")
        end
    elseif command == "clear" then
        EquipmentValidator.clear_cache()
    elseif command == "help" then
        show_help()
    else
        windower.add_to_chat(167, "Commande inconnue: " .. command)
        show_help()
    end
else
    -- Exécution par défaut
    windower.add_to_chat(030, "Equipment Validator Test chargé. Utilisez 'help' pour voir les commandes.")
    show_help()
end