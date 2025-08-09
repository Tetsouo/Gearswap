--[[
    Notifications - Système de notifications visuelles pour FFXI
    Notifications riches dans le chat avec couleurs FFXI, sons et templates
    
    Fonctionnalités:
    - Types de notifications avec couleurs FFXI
    - Templates personnalisables
    - File d'attente avec throttling
    - Support des sons
    - Configuration utilisateur
--]]

local Notify = {}

-- Configuration par défaut
local config = {
    enable_notifications = true,
    enable_sounds = false,
    chat_channel = 207, -- Canal de chat par défaut (écho)
    throttle_duplicates = true,
    throttle_timeout = 3, -- secondes
    max_queue_size = 10,
    auto_clear_queue = true,
    show_timestamps = false,
    enable_colors = true
}

-- État interne
local notification_queue = {}
local recent_notifications = {}
local notification_history = {}
local active_templates = {}

-- Couleurs FFXI pour le chat
local colors = {
    -- Couleurs de base FFXI
    white = 1,
    red = 167,
    green = 158,
    blue = 204,
    yellow = 36,
    cyan = 200,
    magenta = 200,
    orange = 208,
    
    -- Types de notifications
    success = 158,    -- Vert
    info = 204,       -- Bleu
    warning = 208,    -- Orange
    error = 167,      -- Rouge
    critical = 167    -- Rouge (avec clignotement)
}

-- Sons FFXI (si disponibles)
local sounds = {
    success = "sound_ready",
    info = "sound_item",
    warning = "sound_error", 
    error = "sound_buzzer",
    critical = "sound_buzzer"
}

-- Templates prédéfinis
local default_templates = {
    spell_ready = {
        message = "✓ {spell} prêt (recast: {recast}s)",
        type = "success",
        duration = 2,
        sound = true
    },
    
    buff_gained = {
        message = "↑ {buff} activé",
        type = "info", 
        duration = 3,
        sound = false
    },
    
    buff_lost = {
        message = "↓ {buff} perdu",
        type = "warning",
        duration = 3,
        sound = false
    },
    
    mp_low = {
        message = "⚠️ MP bas: {mp}% ({current}/{max})",
        type = "warning",
        duration = 5,
        sound = true
    },
    
    hp_critical = {
        message = "💀 HP CRITIQUE: {hp}%",
        type = "critical",
        duration = 8,
        sound = true,
        flash = true
    },
    
    equipment_broken = {
        message = "🔧 Équipement endommagé: {item}",
        type = "error",
        duration = 6,
        sound = true
    },
    
    job_change = {
        message = "🔄 Changement: {old_job} → {new_job}",
        type = "info",
        duration = 4,
        sound = false
    },
    
    zone_change = {
        message = "🗺️ Zone: {zone}",
        type = "info",
        duration = 3,
        sound = false
    },
    
    party_invite = {
        message = "👥 Invitation de {player}",
        type = "info",
        duration = 10,
        sound = true
    },
    
    craft_success = {
        message = "🔨 Craft réussi: {item} (HQ: {hq})",
        type = "success",
        duration = 4,
        sound = true
    },
    
    auction_sold = {
        message = "💰 Vendu: {item} ({price}g)",
        type = "success", 
        duration = 5,
        sound = false
    }
}

--[[
    Formate un message avec des variables
--]]
local function format_message(template, variables)
    local message = template
    
    if variables then
        for key, value in pairs(variables) do
            local placeholder = "{" .. key .. "}"
            message = message:gsub(placeholder, tostring(value))
        end
    end
    
    return message
end

--[[
    Génère l'horodatage si activé
--]]
local function get_timestamp()
    if config.show_timestamps then
        return "[" .. os.date("%H:%M:%S") .. "] "
    end
    return ""
end

--[[
    Vérifie si une notification est en throttle
--]]
local function is_throttled(message)
    if not config.throttle_duplicates then
        return false
    end
    
    local current_time = os.time()
    local message_hash = tostring(message):gsub("%d+", "#") -- Remplacer les nombres par # pour grouper
    
    local recent = recent_notifications[message_hash]
    if recent and (current_time - recent) < config.throttle_timeout then
        return true
    end
    
    recent_notifications[message_hash] = current_time
    return false
end

--[[
    Nettoie les notifications récentes expirées
--]]
local function cleanup_recent_notifications()
    local current_time = os.time()
    local cutoff = current_time - config.throttle_timeout
    
    for hash, time in pairs(recent_notifications) do
        if time < cutoff then
            recent_notifications[hash] = nil
        end
    end
end

--[[
    Affiche une notification dans le chat
--]]
local function display_notification(notification)
    if not config.enable_notifications then
        return
    end
    
    local message = notification.message
    local color_code = colors[notification.type] or colors.info
    local timestamp = get_timestamp()
    
    -- Construire le message final
    local full_message = timestamp .. message
    
    -- Effet de clignotement pour les notifications critiques
    if notification.type == "critical" and notification.flash then
        -- Simuler le clignotement avec des répétitions
        for i = 1, 3 do
            if config.enable_colors then
                windower.add_to_chat(color_code, full_message)
            else
                windower.add_to_chat(config.chat_channel, full_message)
            end
            
            -- Petite pause (simulation)
            coroutine.yield()
        end
    else
        -- Affichage normal
        if config.enable_colors then
            windower.add_to_chat(color_code, full_message)
        else
            windower.add_to_chat(config.chat_channel, full_message)
        end
    end
    
    -- Jouer le son si activé
    if config.enable_sounds and notification.sound then
        local sound_name = sounds[notification.type]
        if sound_name and windower.play_sound then
            windower.play_sound(sound_name)
        end
    end
    
    -- Ajouter à l'historique
    table.insert(notification_history, {
        timestamp = os.time(),
        message = message,
        type = notification.type,
        duration = notification.duration
    })
    
    -- Limiter l'historique
    if #notification_history > 100 then
        table.remove(notification_history, 1)
    end
end

--[[
    Traite la file d'attente des notifications
--]]
local function process_queue()
    if #notification_queue == 0 then
        return
    end
    
    local notification = table.remove(notification_queue, 1)
    
    -- Vérifier le throttling
    if not is_throttled(notification.message) then
        display_notification(notification)
    end
    
    -- Nettoyer périodiquement
    cleanup_recent_notifications()
end

--[[
    Ajoute une notification à la file d'attente
--]]
local function enqueue_notification(notification)
    -- Vérifier la taille de la file
    if #notification_queue >= config.max_queue_size then
        if config.auto_clear_queue then
            -- Supprimer les anciennes notifications
            table.remove(notification_queue, 1)
        else
            -- Ignorer la nouvelle notification
            return false
        end
    end
    
    table.insert(notification_queue, notification)
    return true
end

--[[
    API Publique
--]]

--[[
    Configure le système de notifications
--]]
function Notify.configure(new_config)
    for key, value in pairs(new_config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

--[[
    Affiche une notification simple
--]]
function Notify.show(message, notification_type, duration)
    if not message then
        return false
    end
    
    local notification = {
        message = tostring(message),
        type = notification_type or "info",
        duration = duration or 3,
        sound = true,
        timestamp = os.time()
    }
    
    return enqueue_notification(notification)
end

--[[
    Affiche une notification avec template
--]]
function Notify.show_template(template_name, variables)
    local template = active_templates[template_name] or default_templates[template_name]
    
    if not template then
        return false, "Template not found: " .. template_name
    end
    
    local message = format_message(template.message, variables)
    
    local notification = {
        message = message,
        type = template.type or "info",
        duration = template.duration or 3,
        sound = template.sound ~= false, -- Par défaut true sauf si explicitement false
        flash = template.flash or false,
        timestamp = os.time()
    }
    
    return enqueue_notification(notification)
end

--[[
    Crée ou modifie un template personnalisé
--]]
function Notify.create_template(name, template_config)
    active_templates[name] = {
        message = template_config.message,
        type = template_config.type or "info",
        duration = template_config.duration or 3,
        sound = template_config.sound ~= false,
        flash = template_config.flash or false
    }
    
    return true
end

--[[
    Supprime un template personnalisé
--]]
function Notify.remove_template(name)
    if active_templates[name] then
        active_templates[name] = nil
        return true
    end
    return false
end

--[[
    Liste tous les templates disponibles
--]]
function Notify.list_templates()
    local templates = {}
    
    -- Templates par défaut
    for name, template in pairs(default_templates) do
        templates[name] = {
            message = template.message,
            type = template.type,
            duration = template.duration,
            sound = template.sound,
            source = "default"
        }
    end
    
    -- Templates personnalisés
    for name, template in pairs(active_templates) do
        templates[name] = {
            message = template.message,
            type = template.type,
            duration = template.duration,
            sound = template.sound,
            source = "custom"
        }
    end
    
    return templates
end

--[[
    Affiche une notification de succès
--]]
function Notify.success(message, duration)
    return Notify.show(message, "success", duration)
end

--[[
    Affiche une notification d'information
--]]
function Notify.info(message, duration)
    return Notify.show(message, "info", duration)
end

--[[
    Affiche un avertissement
--]]
function Notify.warning(message, duration)
    return Notify.show(message, "warning", duration)
end

--[[
    Affiche une erreur
--]]
function Notify.error(message, duration)
    return Notify.show(message, "error", duration)
end

--[[
    Affiche une erreur critique
--]]
function Notify.critical(message, duration)
    local notification = {
        message = tostring(message),
        type = "critical",
        duration = duration or 8,
        sound = true,
        flash = true,
        timestamp = os.time()
    }
    
    return enqueue_notification(notification)
end

--[[
    Vide la file d'attente des notifications
--]]
function Notify.clear_queue()
    notification_queue = {}
    return true
end

--[[
    Obtient l'état de la file d'attente
--]]
function Notify.get_queue_status()
    return {
        queue_size = #notification_queue,
        max_size = config.max_queue_size,
        recent_count = table.length(recent_notifications),
        history_count = #notification_history
    }
end

--[[
    Obtient l'historique des notifications
--]]
function Notify.get_history(limit)
    local count = limit or #notification_history
    local history = {}
    
    local start = math.max(1, #notification_history - count + 1)
    for i = start, #notification_history do
        table.insert(history, notification_history[i])
    end
    
    return history
end

--[[
    Teste toutes les types de notifications
--]]
function Notify.test_all()
    Notify.success("Test de notification de succès")
    Notify.info("Test de notification d'information") 
    Notify.warning("Test d'avertissement")
    Notify.error("Test de notification d'erreur")
    Notify.critical("Test de notification critique")
    
    -- Test des templates
    Notify.show_template("spell_ready", {spell = "Fire IV", recast = 0})
    Notify.show_template("mp_low", {mp = 15, current = 150, max = 1000})
    
    return "Tests de notifications envoyés"
end

--[[
    Active/désactive temporairement les notifications
--]]
function Notify.toggle(enabled)
    if enabled ~= nil then
        config.enable_notifications = enabled
    else
        config.enable_notifications = not config.enable_notifications
    end
    
    return config.enable_notifications
end

--[[
    Obtient la configuration actuelle
--]]
function Notify.get_config()
    return table.copy(config)
end

--[[
    Obtient les statistiques du système
--]]
function Notify.get_statistics()
    return {
        total_sent = #notification_history,
        queue_size = #notification_queue,
        recent_throttled = table.length(recent_notifications),
        templates_active = table.length(active_templates),
        templates_default = table.length(default_templates),
        colors_available = table.length(colors),
        sounds_available = table.length(sounds)
    }
end

-- Fonctions utilitaires
function table.length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Démarrer le traitement périodique de la file d'attente
-- Cette fonction devrait être appelée régulièrement par le système principal
function Notify.process_queue()
    process_queue()
end

-- Initialisation
do
    -- S'assurer que windower est disponible
    if not windower or not windower.add_to_chat then
        config.enable_notifications = false
        print("Warning: Windower chat functions not available")
    end
    
    -- Initialiser les templates par défaut comme actifs
    for name, template in pairs(default_templates) do
        active_templates[name] = table.copy(template)
    end
end

-- Commandes console intégrées (si utilisées avec GearSwap)
if windower and windower.register_event then
    windower.register_event('addon command', function(command, ...)
        local args = {...}
        
        if command == 'notify' then
            if args[1] == 'test' then
                return Notify.test_all()
            elseif args[1] == 'clear' then
                Notify.clear_queue()
                return "Queue cleared"
            elseif args[1] == 'status' then
                local status = Notify.get_queue_status()
                return string.format("Queue: %d/%d, Recent: %d, History: %d", 
                    status.queue_size, status.max_size, status.recent_count, status.history_count)
            elseif args[1] == 'toggle' then
                local enabled = Notify.toggle()
                return "Notifications " .. (enabled and "enabled" or "disabled")
            end
        end
    end)
end

return Notify