---============================================================================
--- Exemple d'intégration de la validation d'équipement
---============================================================================
--- Ce fichier montre comment intégrer la validation d'équipement dans
--- vos job files existants. Il peut être copié/adapté dans vos vrais jobs.
---
--- @file example_equipment_validation_integration.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-08
---============================================================================

-- Charger les modules de validation
local EquipmentValidator = require('utils/equipment_validator')
local EquipmentValidationCommands = require('utils/equipment_validation_commands')
local UtilityUtils = require('utils/helpers')

---============================================================================
--- INTÉGRATION DANS JOB_SETUP
---============================================================================

-- Exemple à ajouter dans votre fonction job_setup()
local function job_setup_validation_example()
    -- Valider automatiquement tous les sets au chargement
    coroutine.wrap(function()
        -- Attendre un peu que tout soit chargé
        coroutine.sleep(2)
        
        if sets then
            windower.add_to_chat(030, "[Job Setup] Validation des équipements...")
            
            -- Validation rapide sans spam
            local validation_errors = 0
            
            -- Exemple: valider quelques sets critiques
            local critical_sets = {
                "idle.normal",
                "engaged.normal", 
                "precast.ws.resolution",
                "midcast.cure"
            }
            
            for _, set_name in ipairs(critical_sets) do
                -- Navigation dans les sets imbriqués
                local current_set = sets
                local parts = {}
                
                for part in set_name:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Naviguer vers le set
                for _, part in ipairs(parts) do
                    if current_set and current_set[part] then
                        current_set = current_set[part]
                    else
                        current_set = nil
                        break
                    end
                end
                
                -- Valider si trouvé
                if current_set and type(current_set) == 'table' then
                    if not UtilityUtils.is_equipment_set_valid(current_set, set_name) then
                        validation_errors = validation_errors + 1
                        windower.add_to_chat(167, string.format("⚠ Set '%s' contient des erreurs", set_name))
                    end
                end
            end
            
            if validation_errors > 0 then
                windower.add_to_chat(167, string.format("⚠ %d sets critiques nécessitent votre attention", validation_errors))
                windower.add_to_chat(001, "Utilisez '//gs c validate_all' pour voir tous les détails")
            else
                windower.add_to_chat(030, "✓ Tous les sets critiques sont valides")
            end
        end
    end)()
end

---============================================================================
--- INTÉGRATION DANS SELF_COMMAND
---============================================================================

-- Exemple à ajouter dans votre fonction self_command(command, ...)
local function self_command_validation_example(command, ...)
    local args = {...}
    
    -- Gestion des commandes de validation d'équipement
    if command and (command:match("^validate") or command:match("^missing") or 
                   command == "current" or command == "clear_cache" or 
                   command == "cache_stats") then
        
        local full_args = table.concat(args, " ")
        EquipmentValidationCommands.handle_command(command, full_args)
        return
    end
    
    -- Commande spéciale pour valider avant d'équiper
    if command == "safe_equip" and args[1] then
        local set_name = args[1]
        
        -- Trouver le set
        local current_set = sets
        for part in set_name:gmatch("[^%.]+") do
            if current_set and current_set[part] then
                current_set = current_set[part]
            else
                windower.add_to_chat(167, string.format("Set '%s' non trouvé", set_name))
                return
            end
        end
        
        -- Valider avant d'équiper
        if current_set and type(current_set) == 'table' then
            windower.add_to_chat(030, string.format("Validation du set '%s' avant équipement...", set_name))
            
            local result = UtilityUtils.validate_equipment_set(current_set, set_name)
            
            if result.valid then
                windower.add_to_chat(030, "✓ Set valide, équipement en cours...")
                equip(current_set)
            else
                windower.add_to_chat(167, "✗ Set invalide, équipement annulé:")
                for _, error in ipairs(result.errors) do
                    windower.add_to_chat(001, "  " .. error)
                end
                
                -- Proposer d'équiper partiellement
                windower.add_to_chat(001, "Utilisez '//gs c force_equip " .. set_name .. "' pour forcer l'équipement")
            end
        end
        return
    end
    
    -- Forcer l'équipement même avec des erreurs
    if command == "force_equip" and args[1] then
        local set_name = args[1]
        
        local current_set = sets
        for part in set_name:gmatch("[^%.]+") do
            if current_set and current_set[part] then
                current_set = current_set[part]
            else
                windower.add_to_chat(167, string.format("Set '%s' non trouvé", set_name))
                return
            end
        end
        
        if current_set and type(current_set) == 'table' then
            windower.add_to_chat(167, string.format("Équipement forcé du set '%s'...", set_name))
            equip(current_set)
            
            -- Valider après équipement pour voir ce qui n'a pas marché
            coroutine.wrap(function()
                coroutine.sleep(1)
                windower.add_to_chat(001, "Vérification post-équipement:")
                UtilityUtils.validate_and_report_equipment(current_set, set_name, false)
            end)()
        end
        return
    end
    
    -- Autres commandes du job...
end

---============================================================================
--- VALIDATION AUTOMATIQUE AVANT ÉQUIPEMENT
---============================================================================

-- Hook optionnel pour valider avant chaque équipement automatique
local original_equip = equip

-- Fonction de validation avant équipement (OPTIONNEL - peut ralentir)
local function safe_equip_wrapper(equipment_set, set_name)
    -- Ne pas valider si c'est juste un ou deux items
    local item_count = 0
    for _ in pairs(equipment_set) do
        item_count = item_count + 1
        if item_count > 2 then break end
    end
    
    -- Valider seulement les gros changements
    if item_count > 2 then
        local result = UtilityUtils.validate_equipment_set(equipment_set, set_name)
        
        if not result.valid and #result.missing_items > 0 then
            -- Signaler discrètement les items manquants
            windower.add_to_chat(001, string.format("[Equipment] %d items manquants dans le set", #result.missing_items))
        end
    end
    
    -- Équiper normalement
    return original_equip(equipment_set)
end

-- Activer la validation automatique (décommenter si désiré)
-- equip = safe_equip_wrapper

---============================================================================
--- COMMANDES DE DÉBOGAGE INTÉGRÉES
---============================================================================

-- Ajouter des commandes de debug spécialisées
local function debug_equipment_commands(command, ...)
    local args = {...}
    
    if command == "debug_equip" then
        -- Débuggage avancé d'un équipement
        local set_name = args[1] or "current"
        
        if set_name == "current" then
            EquipmentValidationCommands.validate_current_set_command()
        else
            -- Validation très détaillée
            windower.add_to_chat(160, string.format("=== DEBUG ÉQUIPEMENT: %s ===", set_name))
            
            -- Trouver le set
            local current_set = sets
            for part in set_name:gmatch("[^%.]+") do
                if current_set and current_set[part] then
                    current_set = current_set[part]
                else
                    windower.add_to_chat(167, "Set non trouvé")
                    return
                end
            end
            
            if current_set and type(current_set) == 'table' then
                -- Validation détaillée avec toutes les informations
                local result = EquipmentValidator.validate_equipment_set(current_set, set_name)
                
                windower.add_to_chat(030, "Résultat de validation:")
                windower.add_to_chat(001, string.format("  Valide: %s", tostring(result.valid)))
                windower.add_to_chat(001, string.format("  Erreurs: %d", #result.errors))
                windower.add_to_chat(001, string.format("  Items manquants: %d", #result.missing_items))
                windower.add_to_chat(001, string.format("  Items utilisés: %d", result.used_items and #result.used_items or 0))
                
                -- Détail des erreurs
                if #result.errors > 0 then
                    windower.add_to_chat(167, "Erreurs détectées:")
                    for _, error in ipairs(result.errors) do
                        windower.add_to_chat(001, "  " .. error)
                    end
                end
                
                -- Détail des items manquants
                if #result.missing_items > 0 then
                    windower.add_to_chat(167, "Items manquants:")
                    for _, missing in ipairs(result.missing_items) do
                        windower.add_to_chat(001, string.format("  [%s] %s - %s", 
                            missing.slot, missing.name, missing.reason or "Raison inconnue"))
                    end
                end
            end
        end
        
        return true
    end
    
    if command == "validate_help" then
        EquipmentValidationCommands.show_help()
        
        -- Aide supplémentaire pour les commandes intégrées
        windower.add_to_chat(050, "")
        windower.add_to_chat(030, "Commandes spécialisées:")
        windower.add_to_chat(001, "  safe_equip <nom> - Valide avant d'équiper")
        windower.add_to_chat(001, "  force_equip <nom> - Force l'équipement")
        windower.add_to_chat(001, "  debug_equip <nom> - Debug détaillé")
        
        return true
    end
    
    return false
end

---============================================================================
--- FONCTION D'EXEMPLE COMPLÈTE
---============================================================================

-- Exemple complet d'intégration dans un job file
local function complete_integration_example()
    print("=== EXEMPLE D'INTÉGRATION EQUIPMENT VALIDATION ===")
    print("")
    print("Pour intégrer la validation d'équipement dans vos jobs:")
    print("")
    print("1. Dans job_setup():")
    print("   -- Ajouter la validation automatique au chargement")
    print("   job_setup_validation_example()")
    print("")
    print("2. Dans self_command():")
    print("   -- Ajouter le gestionnaire de commandes")
    print("   if debug_equipment_commands(command, ...) then return end")
    print("   self_command_validation_example(command, ...)")
    print("")
    print("3. Commandes disponibles:")
    print("   //gs c validate_all        - Valide tous les sets")
    print("   //gs c validate_set idle   - Valide un set spécifique")
    print("   //gs c safe_equip idle     - Équipe après validation")
    print("   //gs c debug_equip current - Debug l'équipement actuel")
    print("")
    print("Voir les fichiers d'exemple pour plus de détails.")
end

-- Exécuter l'exemple si chargé directement
if arg and arg[1] == "example" then
    complete_integration_example()
end

-- Retourner les fonctions pour utilisation dans d'autres fichiers
return {
    job_setup_validation = job_setup_validation_example,
    self_command_validation = self_command_validation_example,
    debug_equipment_commands = debug_equipment_commands,
    show_integration_help = complete_integration_example
}