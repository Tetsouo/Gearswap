---============================================================================
--- Directory Helper - Utilitaire pour la gestion des répertoires
---============================================================================
--- Fonctions utilitaires pour créer et gérer les répertoires de métriques
---
--- @file utils/directory_helper.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

local DirectoryHelper = {}

--- Crée un répertoire s'il n'existe pas
function DirectoryHelper.create_directory(path)
    if not path then
        return false, "Chemin invalide"
    end
    
    -- Essayer avec windower.create_dir d'abord
    if windower and windower.create_dir then
        local success, error_msg = pcall(windower.create_dir, path)
        if success then
            return true, "Répertoire créé avec windower.create_dir"
        end
    end
    
    -- Fallback avec système de fichiers standard (Windows)
    local success = os.execute('mkdir "' .. path:gsub("/", "\\") .. '" >nul 2>&1')
    if success == 0 then
        return true, "Répertoire créé avec mkdir"
    end
    
    return false, "Impossible de créer le répertoire"
end

--- Obtient le répertoire de métriques pour le joueur actuel
function DirectoryHelper.get_metrics_directory()
    local addon_path = windower.addon_path
    if not addon_path then
        return nil, "windower.addon_path non disponible"
    end
    
    local player_name = player and player.name or "Unknown"
    local metrics_dir = addon_path .. "data/" .. player_name .. "/metrics/"
    
    -- Créer le répertoire s'il n'existe pas
    local success, message = DirectoryHelper.create_directory(metrics_dir)
    
    return metrics_dir, message
end

--- Vérifie si un fichier existe
function DirectoryHelper.file_exists(filepath)
    local file = io.open(filepath, "r")
    if file then
        file:close()
        return true
    end
    return false
end

return DirectoryHelper