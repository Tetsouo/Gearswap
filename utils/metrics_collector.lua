--[[
    Metrics Collector - Systeme de collecte de metriques en temps reel
    Collecte, analyse et exporte les metriques de performance avec alertes
    
    Fonctionnalites:
    - Collecte en temps reel des metriques
    - Systeme d'alertes configurable
    - Dashboard integre
    - Export JSON/CSV
    - Analyse statistique
--]]

local Metrics = {}

-- Configuration par defaut
local config = {
    enable_collection = false, -- Desactive par defaut
    enable_alerts = true,
    enable_export = true,
    export_interval = 300, -- 5 minutes
    max_history_size = 1000,
    alert_cooldown = 30, -- secondes
    dashboard_update_interval = 5 -- secondes
}

-- Etat interne
local metrics = {
    -- Metriques de performance
    spell_casts = 0,
    spell_successes = 0,
    spell_failures = 0,
    equipment_swaps = 0,
    equipment_swap_times = {},
    equipment_swap_errors = 0,
    equipment_error_details = {},  -- {set_name = {slot = item, ...}, ...}
    memory_usage = {},
    
    -- Compteurs d'actions
    job_abilities = 0,
    weaponskills = 0,
    magic_bursts = 0,
    skillchains = 0,
    items_used = 0,
    
    -- Metriques temporelles
    session_start = os.time(),
    uptime = 0,
    last_export = 0,
    last_dashboard_update = 0,
    
    -- Metriques d'erreurs
    lua_errors = 0,
    timeout_errors = 0,
    cache_misses = 0,
    cache_hits = 0,
    
    -- Historique pour les tendances
    history = {
        spell_cast_rate = {},
        swap_time_trend = {},
        memory_trend = {},
        error_rate = {}
    }
}

-- Alertes actives
local alerts = {}
local alert_last_triggered = {}

-- Statistiques calculees
local stats_cache = {}
local stats_cache_time = 0

--[[
    Met a jour l'uptime et nettoie l'historique
--]]
local function update_uptime()
    metrics.uptime = os.time() - metrics.session_start
    
    -- Nettoyer l'historique si trop grand
    for category, history in pairs(metrics.history) do
        if #history > config.max_history_size then
            table.remove(history, 1)
        end
    end
end

--[[
    Calcule les statistiques avancées avec mise en cache
--]]
local function calculate_statistics()
    local current_time = os.time()
    
    -- Utiliser le cache si récent (< 5 secondes)
    if stats_cache_time > 0 and (current_time - stats_cache_time) < 5 then
        return stats_cache
    end
    
    local stats = {
        -- Taux de succès des sorts
        spell_success_rate = 0,
        spell_failure_rate = 0,
        
        -- Performances d'équipement
        avg_swap_time = 0,
        min_swap_time = 0,
        max_swap_time = 0,
        
        -- Cache
        cache_hit_rate = 0,
        
        -- Erreurs
        error_rate = 0,
        
        -- Tendances (dernières 10 minutes)
        recent_spell_rate = 0,
        recent_error_rate = 0
    }
    
    -- Calcul du taux de succès des sorts
    local total_spells = metrics.spell_casts
    if total_spells > 0 then
        stats.spell_success_rate = (metrics.spell_successes / total_spells) * 100
        stats.spell_failure_rate = (metrics.spell_failures / total_spells) * 100
    end
    
    -- Statistiques des temps de swap
    if #metrics.equipment_swap_times > 0 then
        local total_time = 0
        local min_time = math.huge
        local max_time = 0
        
        for _, time in ipairs(metrics.equipment_swap_times) do
            total_time = total_time + time
            min_time = math.min(min_time, time)
            max_time = math.max(max_time, time)
        end
        
        stats.avg_swap_time = total_time / #metrics.equipment_swap_times
        stats.min_swap_time = min_time
        stats.max_swap_time = max_time
    end
    
    -- Taux de cache hit
    local total_cache_ops = metrics.cache_hits + metrics.cache_misses
    if total_cache_ops > 0 then
        stats.cache_hit_rate = (metrics.cache_hits / total_cache_ops) * 100
    end
    
    -- Taux d'erreur global
    local total_operations = total_spells + metrics.equipment_swaps
    if total_operations > 0 then
        local total_errors = metrics.lua_errors + metrics.timeout_errors
        stats.error_rate = (total_errors / total_operations) * 100
    end
    
    -- Tendances récentes (10 dernières minutes)
    local recent_threshold = current_time - 600 -- 10 minutes
    local recent_spells = 0
    local recent_errors = 0
    
    for _, entry in ipairs(metrics.history.spell_cast_rate) do
        if entry.timestamp > recent_threshold then
            recent_spells = recent_spells + (entry.value or 0)
        end
    end
    
    for _, entry in ipairs(metrics.history.error_rate) do
        if entry.timestamp > recent_threshold then
            recent_errors = recent_errors + (entry.value or 0)
        end
    end
    
    stats.recent_spell_rate = recent_spells / 10 -- par minute
    stats.recent_error_rate = recent_errors / 10
    
    -- Mettre en cache
    stats_cache = stats
    stats_cache_time = current_time
    
    return stats
end

--[[
    Ajoute une entrée à l'historique
--]]
local function add_to_history(category, value)
    if not metrics.history[category] then
        metrics.history[category] = {}
    end
    
    table.insert(metrics.history[category], {
        timestamp = os.time(),
        value = value
    })
end

--[[
    Vérifie et déclenche les alertes si nécessaire
--]]
local function check_alerts()
    if not config.enable_alerts then
        return
    end
    
    local current_time = os.time()
    local stats = calculate_statistics()
    
    for alert_name, alert_config in pairs(alerts) do
        local last_trigger = alert_last_triggered[alert_name] or 0
        
        -- Vérifier le cooldown
        if (current_time - last_trigger) >= config.alert_cooldown then
            local metric_value = stats[alert_config.metric]
            if not metric_value then
                metric_value = metrics[alert_config.metric]
            end
            
            if metric_value then
                local should_trigger = false
                
                if alert_config.threshold then
                    if alert_config.operator == ">" or not alert_config.operator then
                        should_trigger = metric_value > alert_config.threshold
                    elseif alert_config.operator == "<" then
                        should_trigger = metric_value < alert_config.threshold
                    elseif alert_config.operator == "==" then
                        should_trigger = metric_value == alert_config.threshold
                    elseif alert_config.operator == ">=" then
                        should_trigger = metric_value >= alert_config.threshold
                    elseif alert_config.operator == "<=" then
                        should_trigger = metric_value <= alert_config.threshold
                    end
                end
                
                if should_trigger then
                    alert_last_triggered[alert_name] = current_time
                    
                    if alert_config.callback then
                        pcall(alert_config.callback, metric_value, alert_config)
                    end
                    
                    -- Notification par défaut
                    if not alert_config.silent then
                        local message = string.format("Alert '%s': %s = %.2f (threshold: %.2f)", 
                            alert_name, alert_config.metric, metric_value, alert_config.threshold)
                        
                        if package.loaded['utils/notifications'] then
                            local Notify = require('utils/notifications')
                            Notify.show(message, "warning", 5)
                        else
                            print("⚠️ " .. message)
                        end
                    end
                end
            end
        end
    end
end

--[[
    Collecte les métriques système
--]]
local function collect_system_metrics()
    -- Utilisation mémoire (si disponible via collectgarbage)
    local memory_kb = 0
    if collectgarbage then
        memory_kb = collectgarbage("count")
    else
        -- Fallback: estimation basique basée sur le temps
        memory_kb = math.random(1500, 2500) -- Simulation pour FFXI
    end
    table.insert(metrics.memory_usage, {
        timestamp = os.time(),
        memory_kb = memory_kb
    })
    
    -- Garder seulement les 100 dernières mesures
    if #metrics.memory_usage > 100 then
        table.remove(metrics.memory_usage, 1)
    end
    
    add_to_history("memory_trend", memory_kb)
end

--[[
    Exporte les metriques vers un fichier
--]]
local function export_metrics()
    if not config.enable_export then
        return
    end
    
    local current_time = os.time()
    if (current_time - metrics.last_export) < config.export_interval then
        return
    end
    
    metrics.last_export = current_time
    
    -- Préparer les données d'export
    local export_data = {
        timestamp = current_time,
        session_info = {
            start_time = metrics.session_start,
            uptime = metrics.uptime
        },
        metrics = {
            spell_casts = metrics.spell_casts,
            spell_successes = metrics.spell_successes,
            spell_failures = metrics.spell_failures,
            equipment_swaps = metrics.equipment_swaps,
            lua_errors = metrics.lua_errors,
            timeout_errors = metrics.timeout_errors,
            cache_hits = metrics.cache_hits,
            cache_misses = metrics.cache_misses
        },
        statistics = calculate_statistics(),
        recent_memory = metrics.memory_usage
    }
    
    -- Tentative d'écriture (silencieuse si échec)
    pcall(function()
        local json_str = Metrics.serialize_json(export_data)
        local filename = string.format("metrics_export_%s.json", os.date("%Y%m%d_%H%M%S"))
        
        local file = io.open(filename, "w")
        if file then
            file:write(json_str)
            file:close()
        end
    end)
end

--[[
    API Publique
--]]

--[[
    Configure le collecteur de métriques
--]]
function Metrics.configure(new_config)
    for key, value in pairs(new_config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

--[[
    Suit le lancement d'un sort
--]]
function Metrics.track_spell_cast(spell_name, success, cast_time)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    metrics.spell_casts = metrics.spell_casts + 1
    
    if success then
        metrics.spell_successes = metrics.spell_successes + 1
    else
        metrics.spell_failures = metrics.spell_failures + 1
    end
    
    -- Ajouter à l'historique
    add_to_history("spell_cast_rate", 1)
    
    check_alerts()
    export_metrics()
end

--[[
    Suit un changement d'équipement
--]]
function Metrics.track_equipment_swap(set_name, swap_time, verification_result)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    metrics.equipment_swaps = metrics.equipment_swaps + 1
    table.insert(metrics.equipment_swap_times, swap_time)
    
    -- Garder seulement les 100 derniers temps
    if #metrics.equipment_swap_times > 100 then
        table.remove(metrics.equipment_swap_times, 1)
    end
    
    -- Vérifier les erreurs d'équipement si fourni
    if verification_result and verification_result.has_errors then
        metrics.equipment_swap_errors = metrics.equipment_swap_errors + 1
        
        -- Enregistrer les détails de l'erreur
        if not metrics.equipment_error_details[set_name] then
            metrics.equipment_error_details[set_name] = {}
        end
        
        for slot, item in pairs(verification_result.failed_items or {}) do
            metrics.equipment_error_details[set_name][slot] = item
        end
    end
    
    add_to_history("swap_time_trend", swap_time)
    
    check_alerts()
    collect_system_metrics()
end

--[[
    Suit une erreur d'équipement spécifique
--]]
function Metrics.track_equipment_error(set_name, slot, item_name, reason)
    if not config.enable_collection then
        return
    end
    
    metrics.equipment_swap_errors = metrics.equipment_swap_errors + 1
    
    -- Initialiser la table si nécessaire
    if not metrics.equipment_error_details[set_name] then
        metrics.equipment_error_details[set_name] = {
            errors = {},
            count = 0
        }
    end
    
    -- Enregistrer l'erreur
    local error_entry = {
        slot = slot,
        item = item_name,
        reason = reason or "Item non disponible",
        timestamp = os.time()
    }
    
    table.insert(metrics.equipment_error_details[set_name].errors, error_entry)
    metrics.equipment_error_details[set_name].count = metrics.equipment_error_details[set_name].count + 1
    
    -- Limiter à 50 erreurs par set pour éviter la surcharge mémoire
    if #metrics.equipment_error_details[set_name].errors > 50 then
        table.remove(metrics.equipment_error_details[set_name].errors, 1)
    end
end

--[[
    Suit un weapon skill
--]]
function Metrics.track_weapon_skill(ws_name, success)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    -- Utiliser le compteur weaponskills défini au début
    metrics.weaponskills = metrics.weaponskills + 1
    
    if success then
        metrics.weapon_skill_successes = metrics.weapon_skill_successes or 0
        metrics.weapon_skill_successes = metrics.weapon_skill_successes + 1
    else
        metrics.weapon_skill_failures = metrics.weapon_skill_failures or 0
        metrics.weapon_skill_failures = metrics.weapon_skill_failures + 1
    end
    
    add_to_history("weapon_skill_rate", 1)
    check_alerts()
end

--[[
    Suit une job ability
--]]
function Metrics.track_job_ability(ja_name, success)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    -- Utiliser le compteur job_abilities défini au début
    metrics.job_abilities = metrics.job_abilities + 1
    
    if success then
        metrics.job_ability_successes = metrics.job_ability_successes or 0
        metrics.job_ability_successes = metrics.job_ability_successes + 1
    else
        metrics.job_ability_failures = metrics.job_ability_failures or 0
        metrics.job_ability_failures = metrics.job_ability_failures + 1
    end
    
    add_to_history("job_ability_rate", 1)
    check_alerts()
end

--[[
    Suit l'utilisation d'un item
--]]
function Metrics.track_item_use(item_name)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    metrics.items_used = metrics.items_used + 1
    
    add_to_history("item_use_rate", 1)
    check_alerts()
end

--[[
    Démarre le suivi des métriques
--]]
function Metrics.start_tracking()
    config.enable_collection = true
    
    -- Initialiser les métriques manquantes
    metrics.weapon_skills = metrics.weapon_skills or 0
    metrics.weapon_skill_successes = metrics.weapon_skill_successes or 0
    metrics.weapon_skill_failures = metrics.weapon_skill_failures or 0
    metrics.job_abilities = metrics.job_abilities or 0
    metrics.job_ability_successes = metrics.job_ability_successes or 0
    metrics.job_ability_failures = metrics.job_ability_failures or 0
    
    -- Message d'activation géré par universal_commands.lua
    -- Plus de message ici pour éviter les doublons
end

--[[
    Arrête le suivi des métriques
--]]
function Metrics.stop_tracking()
    config.enable_collection = false
    
    -- Message de désactivation géré par universal_commands.lua
    -- Plus de message ici pour éviter les doublons
end

--[[
    Vérifie si le système est actif
--]]
function Metrics.is_active()
    return config.enable_collection
end

--[[
    Toggle le système de métriques
--]]
function Metrics.toggle()
    if config.enable_collection then
        Metrics.stop_tracking()
    else
        Metrics.start_tracking()
    end
    return config.enable_collection
end

--[[
    Suit une erreur Lua
--]]
function Metrics.track_error(error_type, error_message)
    if not config.enable_collection then
        return
    end
    
    update_uptime()
    
    if error_type == "lua" then
        metrics.lua_errors = metrics.lua_errors + 1
    elseif error_type == "timeout" then
        metrics.timeout_errors = metrics.timeout_errors + 1
    end
    
    add_to_history("error_rate", 1)
    check_alerts()
end

--[[
    Suit les accès au cache
--]]
function Metrics.track_cache_access(hit)
    if not config.enable_collection then
        return
    end
    
    if hit then
        metrics.cache_hits = metrics.cache_hits + 1
    else
        metrics.cache_misses = metrics.cache_misses + 1
    end
end

--[[
    Ajoute une alerte personnalisée
--]]
function Metrics.add_alert(alert_name, alert_config)
    alerts[alert_name] = {
        metric = alert_config.metric,
        threshold = alert_config.threshold,
        operator = alert_config.operator or ">",
        callback = alert_config.callback,
        silent = alert_config.silent or false,
        description = alert_config.description or ""
    }
end

--[[
    Supprime une alerte
--]]
function Metrics.remove_alert(alert_name)
    alerts[alert_name] = nil
    alert_last_triggered[alert_name] = nil
end

--[[
    Liste toutes les alertes
--]]
function Metrics.list_alerts()
    local result = {}
    
    for name, config in pairs(alerts) do
        table.insert(result, {
            name = name,
            metric = config.metric,
            threshold = config.threshold,
            operator = config.operator,
            last_triggered = alert_last_triggered[name],
            description = config.description
        })
    end
    
    return result
end

--[[
    Génère un rapport complet
--]]
function Metrics.generate_report()
    update_uptime()
    collect_system_metrics()
    
    -- Debug: afficher les valeurs actuelles des métriques
    
    local stats = calculate_statistics()
    local current_memory = collectgarbage and collectgarbage("count") or 2000
    
    return {
        session_info = {
            start_time = metrics.session_start,
            uptime_seconds = metrics.uptime,
            uptime_formatted = Metrics.format_duration(metrics.uptime)
        },
        
        performance = {
            spell_casts = metrics.spell_casts,
            spell_success_rate = stats.spell_success_rate,
            spell_failure_rate = stats.spell_failure_rate,
            weapon_skills = metrics.weapon_skills or 0,
            weapon_skill_successes = metrics.weapon_skill_successes or 0,
            weapon_skill_failures = metrics.weapon_skill_failures or 0,
            job_abilities = metrics.job_abilities or 0,
            job_ability_successes = metrics.job_ability_successes or 0,
            job_ability_failures = metrics.job_ability_failures or 0,
            equipment_swaps = metrics.equipment_swaps,
            avg_swap_time = stats.avg_swap_time,
            min_swap_time = stats.min_swap_time,
            max_swap_time = stats.max_swap_time
        },
        
        system = {
            current_memory_kb = current_memory,
            cache_hit_rate = stats.cache_hit_rate,
            error_rate = stats.error_rate,
            lua_errors = metrics.lua_errors,
            timeout_errors = metrics.timeout_errors
        },
        
        trends = {
            recent_spell_rate = stats.recent_spell_rate,
            recent_error_rate = stats.recent_error_rate
        }
    }
end

--[[
    Affiche le dashboard dans le chat
--]]
function Metrics.show_dashboard()
    local current_time = os.time()
    
    -- Throttling des mises à jour
    if (current_time - metrics.last_dashboard_update) < config.dashboard_update_interval then
        return
    end
    
    metrics.last_dashboard_update = current_time
    
    local report = Metrics.generate_report()
    
    -- Utiliser les couleurs FFXI pour l'affichage (ASCII seulement)
    if windower and windower.add_to_chat then
        -- Couleurs FFXI par type d'action (codes exacts du jeu)
        local COLORS = {
            -- Titre et bordures
            HEADER = 160,        -- Gris-violet (#9d9cd2) - gris fonce pour cadre
            BORDER = 160,        -- Gris-violet (#9d9cd2) - gris fonce pour bordures
            SEPARATOR = 160,     -- Gris-violet (#9d9cd2) - gris fonce pour separateurs
            
            -- Types d'actions (couleurs FFXI authentiques)
            MAGIC = 005,         -- Cyan vif (#63ffff) - comme la magie FFXI
            WEAPONSKILL = 167,   -- Rouge-rose (#ff6096) - comme les WS FFXI
            JOBABILITY = 050,    -- Jaune vif (#ffff77) - comme les JA FFXI
            EQUIPMENT = 160,     -- Gris-violet (#9d9cd2) - pour equipement
            
            -- Etats de performance (codes FFXI exacts)
            EXCELLENT = 030,     -- Vert vif (#25ff59) - excellent
            GOOD = 050,         -- Jaune vif (#ffff77) - bon
            AVERAGE = 057,      -- Orange vif (#ff7f5a) - moyen
            POOR = 167,         -- Rouge-rose (#ff6096) - mauvais
            BAD = 028,          -- Rose vif (#ff69a6) - tres mauvais
            
            -- Systeme
            SYSTEM_GOOD = 030,   -- Vert vif (systeme OK)
            SYSTEM_WARNING = 057, -- Orange vif (attention)
            SYSTEM_ERROR = 167,  -- Rouge-rose (erreurs)
            
            -- Infos generales
            INFO = 001,         -- Blanc (#ffffff) - informations neutres
            SUCCESS = 030,      -- Vert vif (#25ff59) - succes
            ERROR = 167         -- Rouge-rose (#ff6096) - echec
        }
        
        -- Fonctions d'aide pour les couleurs selon performance
        local function get_performance_color(rate)
            if rate >= 95 then return COLORS.EXCELLENT
            elseif rate >= 80 then return COLORS.GOOD
            elseif rate >= 60 then return COLORS.AVERAGE
            elseif rate >= 40 then return COLORS.POOR
            else return COLORS.BAD end
        end
        
        local function get_timing_color(ms)
            if ms <= 3 then return COLORS.EXCELLENT      -- Excellent: <=3ms
            elseif ms <= 5 then return COLORS.GOOD       -- Bon: 3-5ms
            elseif ms <= 8 then return COLORS.AVERAGE    -- Moyen: 5-8ms
            elseif ms <= 12 then return COLORS.POOR      -- Mauvais: 8-12ms
            else return COLORS.BAD end                   -- Tres mauvais: >12ms
        end
        
        local function get_memory_color(mb)
            if mb <= 2 then return COLORS.SYSTEM_GOOD        -- Excellent: <=2MB
            elseif mb <= 4 then return COLORS.SYSTEM_WARNING -- Attention: 2-4MB
            else return COLORS.SYSTEM_ERROR end              -- Probleme: >4MB
        end
        
        -- Titre du dashboard
        windower.add_to_chat(COLORS.HEADER, "==================================================================")
        windower.add_to_chat(COLORS.HEADER, "                    METRIQUES DE PERFORMANCE                     ")
        windower.add_to_chat(COLORS.HEADER, "==================================================================")
        
        -- Session info
        windower.add_to_chat(COLORS.INFO, string.format(" Session      | %s", report.session_info.uptime_formatted))
        
        -- Actions avec couleurs par type FFXI
        -- Sorts (couleur magique bleue)
        local spell_color = report.performance.spell_casts > 0 and 
                           get_performance_color(report.performance.spell_success_rate) or COLORS.MAGIC
        windower.add_to_chat(spell_color, string.format(" Sorts        | %d lances (%.1f%% succes)",
            report.performance.spell_casts, report.performance.spell_success_rate))
        
        -- Techniques d'armes (couleur rouge-orange)
        local ws_color = report.performance.weapon_skills > 0 and
                        get_performance_color((report.performance.weapon_skill_successes / math.max(1, report.performance.weapon_skills)) * 100) or COLORS.WEAPONSKILL
        windower.add_to_chat(ws_color, string.format(" Techniques   | %d utilisees (%d OK %d KO)",
            report.performance.weapon_skills, report.performance.weapon_skill_successes, report.performance.weapon_skill_failures))
        
        -- Capacites de job (couleur rouge-violet)
        local ja_color = report.performance.job_abilities > 0 and
                        get_performance_color((report.performance.job_ability_successes / math.max(1, report.performance.job_abilities)) * 100) or COLORS.JOBABILITY
        windower.add_to_chat(ja_color, string.format(" Capacites    | %d utilisees (%d OK %d KO)",
            report.performance.job_abilities, report.performance.job_ability_successes, report.performance.job_ability_failures))
        
        -- Equipement (couleur selon vitesse)
        local swap_color = get_timing_color(report.performance.avg_swap_time)
        windower.add_to_chat(swap_color, string.format(" Equipement   | %d changements (moy: %.1fms)",
            report.performance.equipment_swaps, report.performance.avg_swap_time))
        
        windower.add_to_chat(COLORS.SEPARATOR, "------------------------------------------------------------------")
        
        -- Systeme avec couleurs appropriees
        local memory_mb = report.system.current_memory_kb / 1024
        local memory_color = get_memory_color(memory_mb)
        windower.add_to_chat(memory_color, string.format(" Memoire      | %.1f MB utilises", memory_mb))
        
        local cache_color = report.system.cache_hit_rate >= 80 and COLORS.SYSTEM_GOOD or 
                           (report.system.cache_hit_rate >= 50 and COLORS.SYSTEM_WARNING or COLORS.SYSTEM_ERROR)
        windower.add_to_chat(cache_color, string.format(" Cache        | %.1f%% de reussite", report.system.cache_hit_rate))
        
        -- Erreurs
        if report.system.error_rate > 0 then
            windower.add_to_chat(COLORS.ERROR, string.format(" Erreurs      | %.1f%% (%d erreurs)",
                report.system.error_rate, report.system.lua_errors + report.system.timeout_errors))
        else
            windower.add_to_chat(COLORS.SUCCESS, " Erreurs      | Aucune erreur detectee")
        end
        
        windower.add_to_chat(COLORS.HEADER, "==================================================================")
    else
        -- Fallback sans couleurs pour les environnements sans windower
        print("═══ Performance Dashboard ═══")
        print(string.format("Uptime: %s", report.session_info.uptime_formatted))
        print(string.format("Spell Casts: %d (%.1f%% success)", 
            report.performance.spell_casts, report.performance.spell_success_rate))
        print(string.format("Weapon Skills: %d (%d success, %d fails)", 
            report.performance.weapon_skills, report.performance.weapon_skill_successes, report.performance.weapon_skill_failures))
        print(string.format("Job Abilities: %d (%d success, %d fails)", 
            report.performance.job_abilities, report.performance.job_ability_successes, report.performance.job_ability_failures))
        print(string.format("Equipment Swaps: %d (avg: %.1fms)", 
            report.performance.equipment_swaps, report.performance.avg_swap_time))
        print(string.format("Memory: %.1fMB", report.system.current_memory_kb / 1024))
        print(string.format("Cache Hit Rate: %.1f%%", report.system.cache_hit_rate))
        
        if report.system.error_rate > 0 then
            print(string.format("⚠️ Error Rate: %.1f%% (%d errors)", 
                report.system.error_rate, report.system.lua_errors + report.system.timeout_errors))
        end
        
        print("═══════════════════════════════")
    end
end

--[[
    Formate l'historique avec timestamps lisibles
--]]
local function format_history_for_export(history)
    local formatted_history = {}
    
    for category, entries in pairs(history) do
        formatted_history[category] = {}
        
        for _, entry in ipairs(entries) do
            table.insert(formatted_history[category], {
                timestamp = entry.timestamp,
                timestamp_formatted = Metrics.format_timestamp(entry.timestamp),
                time_short = Metrics.format_timestamp_short(entry.timestamp),
                value = entry.value
            })
        end
    end
    
    return formatted_history
end

--[[
    Exporte les metriques vers un fichier JSON
--]]
function Metrics.export_to_file(filename)
    local report = Metrics.generate_report()
    
    -- Ajouter l'historique complet avec timestamps formattés
    report.history = format_history_for_export(metrics.history)
    
    -- Ajouter métadonnées utiles
    report.export_info = {
        export_timestamp = os.time(),
        export_date = Metrics.format_timestamp(os.time()),
        metrics_enabled = config.enable_collection,
        session_duration_formatted = report.session_info.uptime_formatted
    }
    
    local json_str = Metrics.serialize_json(report)
    
    -- Créer le répertoire de métriques s'il n'existe pas
    local DirectoryHelper = require('utils/directory_helper')
    local metrics_dir, dir_message = DirectoryHelper.get_metrics_directory()
    
    if not metrics_dir then
        return false, "Impossible de créer le répertoire de métriques: " .. (dir_message or "erreur inconnue")
    end
    
    -- Définir le chemin complet du fichier
    local full_filename
    if filename then
        if filename:match("^[/\\]") or filename:match("^%w:") then
            -- Chemin absolu fourni
            full_filename = filename
        else
            -- Nom de fichier relatif - le mettre dans le dossier metrics
            full_filename = metrics_dir .. filename
        end
    else
        -- Nom par défaut dans le dossier metrics
        full_filename = metrics_dir .. "metrics_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
    end
    
    -- Utiliser les fonctions Windower si disponibles
    if windower and windower.write_file then
        local success, error_msg = pcall(windower.write_file, full_filename, json_str)
        if success then
            return true, "Export successful: " .. full_filename
        else
            return false, "Windower write failed: " .. tostring(error_msg)
        end
    end
    
    -- Fallback vers io.open standard
    local file = io.open(full_filename, "w")
    if file then
        file:write(json_str)
        file:close()
        return true, "Export successful: " .. full_filename
    else
        return false, "Failed to open file: " .. full_filename
    end
end

--[[
    Sérialiseur JSON simple
--]]
function Metrics.serialize_json(obj, indent_level)
    indent_level = indent_level or 0
    local indent = string.rep("  ", indent_level)
    local next_indent = string.rep("  ", indent_level + 1)
    
    local function serialize_value(val, current_indent)
        local val_type = type(val)
        
        if val_type == "string" then
            return '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
        elseif val_type == "number" then
            if val == math.floor(val) then
                return string.format("%d", val)
            else
                return string.format("%.6g", val)
            end
        elseif val_type == "boolean" then
            return tostring(val)
        elseif val_type == "nil" then
            return "null"
        elseif val_type == "table" then
            local is_array = true
            local max_index = 0
            local count = 0
            
            -- Déterminer si c'est un array et compter les éléments
            for k, v in pairs(val) do
                count = count + 1
                if type(k) ~= "number" or k ~= math.floor(k) or k < 1 then
                    is_array = false
                else
                    max_index = math.max(max_index, k)
                end
            end
            
            -- Array vide ou objet vide
            if count == 0 then
                return is_array and "[]" or "{}"
            end
            
            if is_array then
                -- Formatage array avec indentation
                if count <= 3 and max_index <= 3 then
                    -- Petit array sur une ligne
                    local parts = {}
                    for i = 1, max_index do
                        if val[i] ~= nil then
                            parts[#parts + 1] = serialize_value(val[i], current_indent + 1)
                        else
                            parts[#parts + 1] = "null"
                        end
                    end
                    return "[" .. table.concat(parts, ", ") .. "]"
                else
                    -- Grand array sur plusieurs lignes
                    local parts = {}
                    for i = 1, max_index do
                        if val[i] ~= nil then
                            parts[#parts + 1] = string.rep("  ", current_indent + 1) .. serialize_value(val[i], current_indent + 1)
                        else
                            parts[#parts + 1] = string.rep("  ", current_indent + 1) .. "null"
                        end
                    end
                    return "[\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", current_indent) .. "]"
                end
            else
                -- Formatage objet avec indentation et tri des clés
                local keys = {}
                for k in pairs(val) do
                    table.insert(keys, tostring(k))
                end
                table.sort(keys)
                
                local parts = {}
                for _, k in ipairs(keys) do
                    local v = val[k]
                    local key_str = serialize_value(k, current_indent + 1)
                    local value_str = serialize_value(v, current_indent + 1)
                    parts[#parts + 1] = string.rep("  ", current_indent + 1) .. key_str .. ": " .. value_str
                end
                return "{\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", current_indent) .. "}"
            end
        else
            return '"' .. tostring(val) .. '"'
        end
    end
    
    return serialize_value(obj, indent_level)
end

--[[
    Formate une durée en texte lisible
--]]
function Metrics.format_duration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

--[[
    Formate un timestamp Unix en date/heure lisible
--]]
function Metrics.format_timestamp(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

--[[
    Formate un timestamp Unix en format court (HH:MM:SS)
--]]
function Metrics.format_timestamp_short(timestamp)
    return os.date("%H:%M:%S", timestamp)
end

--[[
    Remet à zéro toutes les métriques
--]]
function Metrics.reset()
    metrics = {
        spell_casts = 0,
        spell_successes = 0,
        spell_failures = 0,
        equipment_swaps = 0,
        equipment_swap_times = {},
        equipment_swap_errors = 0,
        equipment_error_details = {},
        memory_usage = {},
        -- Compteurs d'actions
        job_abilities = 0,
        weaponskills = 0,
        magic_bursts = 0,
        skillchains = 0,
        items_used = 0,
        session_start = os.time(),
        uptime = 0,
        last_export = 0,
        last_dashboard_update = 0,
        lua_errors = 0,
        timeout_errors = 0,
        cache_misses = 0,
        cache_hits = 0,
        history = {
            spell_cast_rate = {},
            swap_time_trend = {},
            memory_trend = {},
            error_rate = {}
        }
    }
    
    -- Vider le cache des statistiques
    stats_cache = {}
    stats_cache_time = 0
end

--[[
    Obtient les métriques brutes (pour debug)
--]]
function Metrics.get_raw_metrics()
    return {
        metrics = metrics,
        config = config,
        alerts = alerts,
        alert_triggers = alert_last_triggered
    }
end

-- Initialiser la collecte périodique des métriques système
local function start_background_collection()
    -- Cette fonction devrait être appelée périodiquement par le système principal
    -- Pour l'instant, elle sera déclenchée lors des appels aux fonctions de tracking
end

-- Demarrer la collecte
start_background_collection()

return Metrics