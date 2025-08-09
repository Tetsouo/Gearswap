---============================================================================
--- Universal Command Help System - Compatible with All Jobs
---============================================================================
--- Système d'aide universel qui s'adapte automatiquement à n'importe quel job.
--- Détecte automatiquement le job actuel et affiche les commandes appropriées.
---
--- @file utils/command_help.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

local CommandHelp = {}

-- Détection automatique du job actuel
local function get_current_job()
    if player and player.main_job then
        return player.main_job:upper()
    end
    -- Fallback: détecter depuis le nom du fichier LUA chargé
    if _addon and _addon.name then
        local job_pattern = "Tetsouo_(%w+)"
        local job = _addon.name:match(job_pattern)
        return job and job:upper() or "UNKNOWN"
    end
    return "UNKNOWN"
end

-- Configuration des raccourcis par job
local job_keybinds = {
    WAR = { F5 = "HybridMode", F6 = "WeaponSet" },
    BLM = { F5 = "MagicBurst", F6 = "DeathMode" },
    BST = { F5 = "PetMode", F6 = "JugPet" },
    DNC = { F5 = "StepMode", F6 = "FlourishMode" },
    DRG = { F5 = "DrakeMode", F6 = "WyvernMode" },
    PLD = { F5 = "TankMode", F6 = "CureMode" },
    RUN = { F5 = "RuneMode", F6 = "TankMode" },
    THF = { F5 = "TreasureHunter", F6 = "StealthMode" }
}

-- Commandes communes à tous les jobs
local universal_commands = {
    {
        category = "METRIQUES",
        note = "(desactivees par defaut)",
        commands = {
            { cmd = "metrics toggle", desc = "Activer/desactiver" },
            { cmd = "metrics show", desc = "Dashboard performance" },
            { cmd = "metrics export", desc = "Exporter vers JSON" },
            { cmd = "metrics status", desc = "Voir etat actuel" }
        }
    },
    {
        category = "SYSTEME",
        commands = {
            { cmd = "cache stats", desc = "Stats cache" },
            { cmd = "test", desc = "Tests unitaires" },
            { cmd = "cmd full", desc = "Aide complete" }
        }
    }
}

-- Commandes spécifiques par job (optionnel)
local job_specific_commands = {
    WAR = {
        { cmd = "berserk auto", desc = "Toggle Berserk automatique" },
        { cmd = "defender auto", desc = "Toggle Defender automatique" }
    },
    BLM = {
        { cmd = "nukemode cycle", desc = "Changer mode nuke" },
        { cmd = "manawall auto", desc = "Toggle Manawall auto" }
    }
    -- Ajouter d'autres jobs au besoin
}

--- Affiche l'aide dans le chat avec pagination
function CommandHelp.show_help_in_chat(page)
    page = page or 1
    local current_job = get_current_job()
    local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }
    
    if page == 1 then
        -- Page 1: Commandes JOB (général)
        windower.add_to_chat(160, "========= COMMANDES " .. current_job .. " [Page 1/3] =========")
        windower.add_to_chat(030, "RACCOURCIS CLAVIER:")
        windower.add_to_chat(050, "  F5 = Cycle " .. keybinds.F5)
        windower.add_to_chat(050, "  F6 = Cycle " .. keybinds.F6)
        windower.add_to_chat(030, "COMMANDES JOB:")
        windower.add_to_chat(050, "  //gs c cycle " .. keybinds.F5)
        windower.add_to_chat(050, "  //gs c cycle " .. keybinds.F6)
        windower.add_to_chat(050, "  //gs r                 - Recharger config")
        windower.add_to_chat(160, "Page suivante: //gs c info 2")
        windower.add_to_chat(160, "==========================================")
        
    elseif page == 2 then
        -- Page 2: Métriques et Performance
        windower.add_to_chat(160, "========= METRIQUES [Page 2/3] =========")
        windower.add_to_chat(030, "METRIQUES (desactivees par defaut):")
        windower.add_to_chat(050, "  //gs c metrics toggle  - Activer/desactiver")
        windower.add_to_chat(050, "  //gs c metrics show    - Dashboard")
        windower.add_to_chat(050, "  //gs c metrics export  - Sauver JSON")
        windower.add_to_chat(050, "  //gs c metrics reset   - Remise a zero")
        windower.add_to_chat(050, "  //gs c metrics status  - Voir statut")
        windower.add_to_chat(160, "Page suivante: //gs c info 3")
        windower.add_to_chat(160, "==========================================")
        
    elseif page == 3 then
        -- Page 3: Système et Debug
        windower.add_to_chat(160, "========= SYSTEME [Page 3/3] =========")
        windower.add_to_chat(030, "CACHE & MODULES:")
        windower.add_to_chat(050, "  //gs c cache stats     - Stats cache")
        windower.add_to_chat(050, "  //gs c cache clear     - Vider cache")
        windower.add_to_chat(050, "  //gs c modules stats   - Info modules")
        windower.add_to_chat(030, "DEBUG:")
        windower.add_to_chat(050, "  //gs c test            - Tests unitaires")
        windower.add_to_chat(050, "  //gs c help            - Categories d'aide")
        windower.add_to_chat(160, "Retour debut: //gs c info 1")
        windower.add_to_chat(160, "==========================================")
    else
        windower.add_to_chat(167, "Page invalide. Utilisez: //gs c info [1-3]")
    end
end

--- Affiche l'aide courte dans la console (version épurée)
function CommandHelp.show_brief()
    local current_job = get_current_job()
    print("===== COMMANDES " .. current_job .. " =====")
    print("//gs c info        - Aide dans le chat")
    print("//gs c metrics     - Systeme metriques")
    print("//gs c cache       - Gestion cache")
    print("F5/F6              - Modes speciaux")
    print("========================")
end

--- Affiche l'aide complète avec toutes les commandes
function CommandHelp.show_full()
    local current_job = get_current_job()
    local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }
    
    print("================== AIDE COMPLETE " .. current_job .. " ==================")
    print("")
    
    -- Raccourcis clavier
    print("RACCOURCIS CLAVIER:")
    print("  F5 = Cycle " .. keybinds.F5)
    print("  F6 = Cycle " .. keybinds.F6)
    print("")
    
    -- Toutes les commandes universelles
    for _, category in ipairs(universal_commands) do
        print(category.category .. ":")
        for _, cmd in ipairs(category.commands) do
            print("  //gs c " .. cmd.cmd .. string.rep(" ", 18 - #cmd.cmd) .. "| " .. cmd.desc)
        end
        print("")
    end
    
    -- Commandes spécifiques au job (si elles existent)
    local job_cmds = job_specific_commands[current_job]
    if job_cmds and #job_cmds > 0 then
        print("SPECIFIQUE " .. current_job .. ":")
        for _, cmd in ipairs(job_cmds) do
            print("  //gs c " .. cmd.cmd .. string.rep(" ", 18 - #cmd.cmd) .. "| " .. cmd.desc)
        end
        print("")
    end
    
    -- GearSwap standard
    print("GEARSWAP STANDARD:")
    print("  //gs r                  | Recharger configuration")
    print("  //gs c cycle " .. keybinds.F5 .. string.rep(" ", 11 - #keybinds.F5) .. "| Toggle " .. keybinds.F5)
    print("  //gs c cycle " .. keybinds.F6 .. string.rep(" ", 11 - #keybinds.F6) .. "| Toggle " .. keybinds.F6)
    print("")
    print("=========================================================")
end

--- Gère les commandes d'aide (à appeler depuis job_self_command)
function CommandHelp.handle_help_command(cmdParams)
    if not cmdParams or #cmdParams == 0 then
        return false
    end
    
    local command = cmdParams[1]:lower()
    
    -- Nouvelle commande info avec pagination
    if command == 'info' then
        local page = tonumber(cmdParams[2]) or 1
        CommandHelp.show_help_in_chat(page)
        return true
    end
    
    -- Aide par catégories spécifiques
    if command == 'help' then
        local category = cmdParams[2] and cmdParams[2]:lower() or 'general'
        
        if category == 'metrics' or category == 'metriques' then
            windower.add_to_chat(160, "========= AIDE METRIQUES =========")
            windower.add_to_chat(050, "//gs c metrics toggle    - Activer/desactiver")
            windower.add_to_chat(050, "//gs c metrics show      - Dashboard coloré")
            windower.add_to_chat(050, "//gs c metrics export    - Sauver en JSON")
            windower.add_to_chat(050, "//gs c metrics reset     - Remise à zéro")
            windower.add_to_chat(050, "//gs c metrics status    - Voir statut")
            windower.add_to_chat(160, "==================================")
            
        elseif category == 'cache' then
            windower.add_to_chat(160, "========= AIDE CACHE =========")
            windower.add_to_chat(050, "//gs c cache stats       - Statistiques")
            windower.add_to_chat(050, "//gs c cache clear       - Vider cache")
            windower.add_to_chat(050, "//gs c cache cleanup     - Nettoyer ancien")
            windower.add_to_chat(160, "==============================")
            
        elseif category == 'keybinds' or category == 'keys' then
            local current_job = get_current_job()
            local keybinds = job_keybinds[current_job] or { F5 = "Mode1", F6 = "Mode2" }
            windower.add_to_chat(160, "========= RACCOURCIS " .. current_job .. " =========")
            windower.add_to_chat(030, "F5 = " .. keybinds.F5)
            windower.add_to_chat(030, "F6 = " .. keybinds.F6)
            windower.add_to_chat(030, "//gs r = Recharger config")
            windower.add_to_chat(160, "=====================================")
            
        else
            -- Aide générale
            windower.add_to_chat(160, "========= CATEGORIES D'AIDE =========")
            windower.add_to_chat(050, "//gs c help metrics      - Aide métriques")
            windower.add_to_chat(050, "//gs c help cache        - Aide cache")
            windower.add_to_chat(050, "//gs c help keys         - Raccourcis clavier")
            windower.add_to_chat(050, "//gs c info              - Aide paginée complète")
            windower.add_to_chat(160, "====================================")
        end
        
        return true
    end
    
    return false -- Pas une commande d'aide
end

--- Affiche la liste des commandes testables
function CommandHelp.show_test_commands()
    local current_job = get_current_job()
    print("========== COMMANDES TESTABLES (" .. current_job .. ") ==========")
    print("//gs c cmd           - Aide courte adaptee au job")
    print("//gs c cmd full      - Aide complete avec details")
    print("//gs c metrics status - Statut systeme metriques")
    print("//gs c cache stats   - Statistiques du cache")
    print("//gs c test          - Tests unitaires modules")
    print("====================================================")
end

return CommandHelp