---============================================================================
--- Equipment Validation Commands - Commandes pour valider l'équipement
---============================================================================
--- Fournit des commandes pratiques pour utiliser le système de validation
--- d'équipement depuis le jeu. Peut être intégré dans les job files ou
--- utilisé de manière autonome.
---
--- @file utils/equipment_validation_commands.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-08
---============================================================================

local EquipmentValidationCommands = {}

-- Charger les dépendances
local EquipmentValidator = require('utils/equipment_validator')
local UtilityUtils = require('utils/helpers')

---============================================================================
--- COMMANDES DE VALIDATION
---============================================================================

--- Commande pour valider un set spécifique
-- Usage: validate_set <nom_du_set>
function EquipmentValidationCommands.validate_set_command(set_name)
    if not set_name or set_name == "" then
        windower.add_to_chat(167, "Usage: validate_set <nom_du_set>")
        windower.add_to_chat(001, "Exemple: validate_set idle.normal")
        return
    end
    
    -- Chercher le set dans la table sets
    if not sets then
        windower.add_to_chat(167, "Aucun set défini (variable 'sets' non trouvée)")
        return
    end
    
    -- Navigation dans les sets imbriqués
    local current_table = sets
    local path_parts = {}
    
    -- Diviser le nom du set par les points
    for part in set_name:gmatch("[^%.]+") do
        table.insert(path_parts, part)
    end
    
    -- Naviguer dans la hiérarchie
    for _, part in ipairs(path_parts) do
        if current_table[part] then
            current_table = current_table[part]
        else
            windower.add_to_chat(167, string.format("Set '%s' non trouvé (partie manquante: %s)", set_name, part))
            return
        end
    end
    
    -- Vérifier que c'est bien un set d'équipement
    if type(current_table) ~= 'table' then
        windower.add_to_chat(167, string.format("'%s' n'est pas un set d'équipement", set_name))
        return
    end
    
    -- Valider le set
    windower.add_to_chat(030, string.format("Validation du set: %s", set_name))
    UtilityUtils.validate_and_report_equipment(current_table, set_name, true)
end

--- Commande pour valider tous les sets
-- Usage: validate_all_sets [show_valid]
function EquipmentValidationCommands.validate_all_sets_command(show_valid)
    if not sets then
        windower.add_to_chat(167, "Aucun set défini (variable 'sets' non trouvée)")
        return
    end
    
    local show_valid_sets = show_valid and (show_valid:lower() == "true" or show_valid:lower() == "yes")
    
    windower.add_to_chat(030, "Validation de tous les sets...")
    UtilityUtils.validate_all_equipment_sets(sets, show_valid_sets)
end

--- Commande pour lister les items manquants d'un set
-- Usage: missing_items <nom_du_set>
function EquipmentValidationCommands.missing_items_command(set_name)
    if not set_name or set_name == "" then
        windower.add_to_chat(167, "Usage: missing_items <nom_du_set>")
        return
    end
    
    if not sets then
        windower.add_to_chat(167, "Aucun set défini")
        return
    end
    
    -- Même logique de navigation que validate_set_command
    local current_table = sets
    local path_parts = {}
    
    for part in set_name:gmatch("[^%.]+") do
        table.insert(path_parts, part)
    end
    
    for _, part in ipairs(path_parts) do
        if current_table[part] then
            current_table = current_table[part]
        else
            windower.add_to_chat(167, string.format("Set '%s' non trouvé", set_name))
            return
        end
    end
    
    if type(current_table) ~= 'table' then
        windower.add_to_chat(167, string.format("'%s' n'est pas un set d'équipement", set_name))
        return
    end
    
    -- Obtenir les items manquants
    local missing_items = UtilityUtils.get_missing_equipment_items(current_table, set_name)
    
    if #missing_items == 0 then
        windower.add_to_chat(030, string.format("Set '%s': Aucun item manquant", set_name))
    else
        windower.add_to_chat(167, string.format("Set '%s': %d items manquants", set_name, #missing_items))
        for _, missing in ipairs(missing_items) do
            windower.add_to_chat(001, string.format("  [%s] %s", missing.slot, missing.name))
        end
    end
end

--- Commande pour valider le set actuellement équipé
-- Usage: validate_current_set
function EquipmentValidationCommands.validate_current_set_command()
    local current_equipment = windower.ffxi.get_equipment()
    if not current_equipment then
        windower.add_to_chat(167, "Impossible d'obtenir l'équipement actuel")
        return
    end
    
    -- Construire un set à partir de l'équipement actuel
    local current_set = {}
    local items = windower.ffxi.get_items()
    
    if not items then
        windower.add_to_chat(167, "Impossible d'obtenir les données d'inventaire")
        return
    end
    
    -- Convertir l'équipement actuel en format de set
    local slot_names = {
        'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet',
        'neck', 'waist', 'left_ear', 'right_ear', 'left_ring', 'right_ring', 'back'
    }
    
    for _, slot in ipairs(slot_names) do
        local item_id = current_equipment[slot]
        if item_id and item_id > 0 then
            -- Trouver le nom de l'item
            if res.items[item_id] then
                current_set[slot] = res.items[item_id].english or res.items[item_id].name
            end
        end
    end
    
    if next(current_set) then
        windower.add_to_chat(030, "Validation de l'équipement actuellement porté:")
        UtilityUtils.validate_and_report_equipment(current_set, "current_equipment", true)
    else
        windower.add_to_chat(167, "Aucun équipement détecté")
    end
end

--- Commande pour effacer le cache de validation
-- Usage: clear_validation_cache
function EquipmentValidationCommands.clear_validation_cache_command()
    UtilityUtils.clear_equipment_validation_cache()
end

--- Commande pour afficher les statistiques du cache
-- Usage: validation_cache_stats
function EquipmentValidationCommands.validation_cache_stats_command()
    local stats = UtilityUtils.get_equipment_validation_cache_stats()
    if stats then
        windower.add_to_chat(030, string.format("Cache de validation: %d entrées, âge: %d secondes (max: %d)",
            stats.entries, stats.age, stats.max_age))
    else
        windower.add_to_chat(167, "Impossible d'obtenir les statistiques du cache")
    end
end

---============================================================================
--- INTÉGRATION DES COMMANDES
---============================================================================

--- Traite une commande de validation d'équipement
-- @param command (string): Commande à exécuter
-- @param args (string): Arguments de la commande
function EquipmentValidationCommands.handle_command(command, args)
    command = command:lower()
    
    if command == "validate_set" then
        EquipmentValidationCommands.validate_set_command(args)
    elseif command == "validate_all" or command == "validate_all_sets" then
        EquipmentValidationCommands.validate_all_sets_command(args)
    elseif command == "missing_items" or command == "missing" then
        EquipmentValidationCommands.missing_items_command(args)
    elseif command == "validate_current" or command == "current" then
        EquipmentValidationCommands.validate_current_set_command()
    elseif command == "clear_cache" then
        EquipmentValidationCommands.clear_validation_cache_command()
    elseif command == "cache_stats" then
        EquipmentValidationCommands.validation_cache_stats_command()
    elseif command == "help" or command == "?" then
        EquipmentValidationCommands.show_help()
    else
        windower.add_to_chat(167, string.format("Commande inconnue: %s", command))
        EquipmentValidationCommands.show_help()
    end
end

--- Affiche l'aide des commandes de validation
function EquipmentValidationCommands.show_help()
    windower.add_to_chat(160, "=== COMMANDES DE VALIDATION D'EQUIPEMENT ===")
    windower.add_to_chat(030, "Commandes disponibles:")
    windower.add_to_chat(001, "  validate_set <nom> - Valide un set spécifique")
    windower.add_to_chat(001, "  validate_all [true] - Valide tous les sets")
    windower.add_to_chat(001, "  missing_items <nom> - Liste les items manquants d'un set")
    windower.add_to_chat(001, "  validate_current - Valide l'équipement actuellement porté")
    windower.add_to_chat(001, "  clear_cache - Efface le cache de validation")
    windower.add_to_chat(001, "  cache_stats - Affiche les stats du cache")
    windower.add_to_chat(001, "  help - Affiche cette aide")
    windower.add_to_chat(050, "")
    windower.add_to_chat(030, "Exemples d'usage:")
    windower.add_to_chat(001, "  //gs c validate_set idle.normal")
    windower.add_to_chat(001, "  //gs c validate_all")
    windower.add_to_chat(001, "  //gs c missing_items precast.ws.resolution")
    windower.add_to_chat(001, "  //gs c validate_current")
end

---============================================================================
--- ENREGISTREMENT AUTOMATIQUE DES COMMANDES
---============================================================================

--- Enregistre automatiquement les commandes si un système de commandes existe
function EquipmentValidationCommands.register_commands()
    -- Cette fonction peut être appelée depuis les job files pour enregistrer
    -- automatiquement les commandes de validation
    
    -- Si vous avez un système de gestion de commandes, l'enregistrement se ferait ici
    -- Par exemple, avec un gestionnaire de commandes personnalisé:
    -- CommandManager.register('validate_set', EquipmentValidationCommands.validate_set_command)
    -- etc.
    
    windower.add_to_chat(030, "[Equipment Validation] Commandes enregistrées")
end

return EquipmentValidationCommands