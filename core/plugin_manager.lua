--[[
    Plugin Manager - Système de plugins communautaire
    Architecture complète pour créer et gérer des plugins tiers avec sandboxing
    
    Fonctionnalités:
    - Gestion du cycle de vie des plugins
    - Système de hooks et événements
    - Sandboxing sécurisé
    - Gestion des dépendances
    - API standardisée
--]]

local PluginManager = {}

-- Configuration par défaut
local config = {
    plugin_directory = "plugins/",
    enable_sandboxing = true,
    max_hook_execution_time = 100, -- ms
    enable_dependency_checking = true,
    enable_logging = true
}

-- État interne
local plugins = {}
local hooks = {}
local plugin_api = {}
local dependency_graph = {}

-- Métriques
local metrics = {
    plugins_loaded = 0,
    plugins_active = 0,
    hook_executions = 0,
    hook_errors = 0,
    startup_time = 0
}

--[[
    API sécurisée exposée aux plugins
--]]
function create_plugin_api()
    return {
        -- Utilitaires de base
        log = function(level, message, plugin_name)
            if config.enable_logging then
                print(string.format("[%s][%s] %s", plugin_name or "Unknown", level:upper(), message))
            end
        end,
        
        -- Accès aux données du jeu
        get_player = function()
            return windower.ffxi.get_player()
        end,
        
        get_spell_recasts = function()
            return windower.ffxi.get_spell_recasts()
        end,
        
        get_ability_recasts = function()
            return windower.ffxi.get_ability_recasts()
        end,
        
        -- Interaction avec l'équipement
        get_items = function()
            return windower.ffxi.get_items()
        end,
        
        -- Communication sécurisée avec d'autres plugins
        send_event = function(event_name, data, sender)
            PluginManager.broadcast_event(event_name, data, sender)
        end,
        
        -- Accès aux métriques (lecture seule)
        get_metrics = function()
            return table.copy(metrics)
        end,
        
        -- Utilitaires de temps
        get_time = function()
            return os.clock()
        end,
        
        -- Notifications (si disponible)
        notify = function(message, type, duration)
            if package.loaded['utils/notifications'] then
                local Notify = require('utils/notifications')
                Notify.show(message, type or "info", duration or 3)
            end
        end
    }
end

--[[
    Validation et sandboxing d'un plugin
--]]
function validate_plugin(plugin)
    if type(plugin) ~= "table" then
        return false, "Plugin must be a table"
    end
    
    if not plugin.name or type(plugin.name) ~= "string" then
        return false, "Plugin must have a valid name"
    end
    
    if not plugin.version or type(plugin.version) ~= "string" then
        return false, "Plugin must have a valid version"
    end
    
    if plugin.init and type(plugin.init) ~= "function" then
        return false, "Plugin init must be a function"
    end
    
    if plugin.hooks and type(plugin.hooks) ~= "table" then
        return false, "Plugin hooks must be a table"
    end
    
    if plugin.dependencies and type(plugin.dependencies) ~= "table" then
        return false, "Plugin dependencies must be a table"
    end
    
    return true, nil
end

--[[
    Vérifie les dépendances d'un plugin
--]]
function check_dependencies(plugin_name, dependencies)
    if not config.enable_dependency_checking or not dependencies then
        return true, nil
    end
    
    for _, dep in ipairs(dependencies) do
        -- Vérifier les modules système
        local success, _ = pcall(require, dep)
        if not success then
            -- Vérifier les plugins
            if not plugins[dep] or not plugins[dep].active then
                return false, "Missing dependency: " .. dep
            end
        end
    end
    
    return true, nil
end

--[[
    Crée un environnement sandboxé pour un plugin
--]]
function create_sandbox(plugin_name)
    if not config.enable_sandboxing then
        return _G
    end
    
    local sandbox = {
        -- Fonctions sécurisées de base
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        type = type,
        tostring = tostring,
        tonumber = tonumber,
        string = string,
        table = table,
        math = math,
        os = {
            clock = os.clock,
            time = os.time,
            date = os.date
        },
        
        -- API du plugin
        api = plugin_api,
        
        -- Nom du plugin (pour l'identification)
        __plugin_name = plugin_name,
        
        -- Fonctions utilitaires
        print = function(...)
            plugin_api.log("info", table.concat({...}, " "), plugin_name)
        end,
        
        error = function(msg)
            plugin_api.log("error", msg, plugin_name)
            error("[" .. plugin_name .. "] " .. msg)
        end
    }
    
    -- Métatable pour empêcher l'accès aux variables globales dangereuses
    setmetatable(sandbox, {
        __index = function(t, k)
            -- Autoriser l'accès à certaines globales sécurisées
            local safe_globals = {
                windower = true,
                require = true -- Contrôlé ailleurs
            }
            
            if safe_globals[k] then
                return _G[k]
            end
            
            return nil
        end,
        
        __newindex = function(t, k, v)
            -- Empêcher la modification de l'environnement global
            rawset(t, k, v)
        end
    })
    
    return sandbox
end

--[[
    Enregistre un plugin
--]]
function PluginManager.register(plugin_name, plugin)
    local start_time = os.clock()
    
    -- Validation
    local valid, error_msg = validate_plugin(plugin)
    if not valid then
        return false, "Invalid plugin: " .. error_msg
    end
    
    -- Vérifier les dépendances
    local deps_ok, deps_error = check_dependencies(plugin_name, plugin.dependencies)
    if not deps_ok then
        return false, "Dependency error: " .. deps_error
    end
    
    -- Créer l'environnement sandboxé
    local sandbox = create_sandbox(plugin_name)
    
    -- Enregistrer le plugin
    plugins[plugin_name] = {
        instance = plugin,
        sandbox = sandbox,
        active = false,
        loaded_at = os.time(),
        hooks = {},
        dependencies = plugin.dependencies or {},
        author = plugin.author or "Unknown",
        version = plugin.version,
        description = plugin.description or ""
    }
    
    metrics.plugins_loaded = metrics.plugins_loaded + 1
    metrics.startup_time = metrics.startup_time + (os.clock() - start_time)
    
    if config.enable_logging then
        print(string.format("Plugin '%s' v%s registered successfully", plugin_name, plugin.version))
    end
    
    return true, nil
end

--[[
    Active un plugin
--]]
function PluginManager.enable(plugin_name)
    local plugin_data = plugins[plugin_name]
    if not plugin_data then
        return false, "Plugin not found: " .. plugin_name
    end
    
    if plugin_data.active then
        return true, "Plugin already active"
    end
    
    local plugin = plugin_data.instance
    
    -- Initialiser le plugin dans son sandbox
    if plugin.init then
        local old_env = getfenv(plugin.init)
        setfenv(plugin.init, plugin_data.sandbox)
        
        local success, result = pcall(plugin.init, plugin_api)
        setfenv(plugin.init, old_env)
        
        if not success then
            return false, "Plugin initialization failed: " .. tostring(result)
        end
        
        if result == false then
            return false, "Plugin initialization returned false"
        end
    end
    
    -- Enregistrer les hooks
    if plugin.hooks then
        for hook_name, hook_func in pairs(plugin.hooks) do
            if not hooks[hook_name] then
                hooks[hook_name] = {}
            end
            
            table.insert(hooks[hook_name], {
                plugin_name = plugin_name,
                func = hook_func,
                sandbox = plugin_data.sandbox
            })
            
            plugin_data.hooks[hook_name] = hook_func
        end
    end
    
    plugin_data.active = true
    plugin_data.activated_at = os.time()
    metrics.plugins_active = metrics.plugins_active + 1
    
    if config.enable_logging then
        print(string.format("Plugin '%s' enabled", plugin_name))
    end
    
    return true, nil
end

--[[
    Désactive un plugin
--]]
function PluginManager.disable(plugin_name)
    local plugin_data = plugins[plugin_name]
    if not plugin_data then
        return false, "Plugin not found: " .. plugin_name
    end
    
    if not plugin_data.active then
        return true, "Plugin already disabled"
    end
    
    -- Supprimer les hooks
    for hook_name, _ in pairs(plugin_data.hooks) do
        if hooks[hook_name] then
            for i = #hooks[hook_name], 1, -1 do
                if hooks[hook_name][i].plugin_name == plugin_name then
                    table.remove(hooks[hook_name], i)
                end
            end
            
            if #hooks[hook_name] == 0 then
                hooks[hook_name] = nil
            end
        end
    end
    
    -- Appeler la fonction de nettoyage si elle existe
    local plugin = plugin_data.instance
    if plugin.cleanup then
        local old_env = getfenv(plugin.cleanup)
        setfenv(plugin.cleanup, plugin_data.sandbox)
        
        pcall(plugin.cleanup, plugin_api)
        setfenv(plugin.cleanup, old_env)
    end
    
    plugin_data.active = false
    plugin_data.hooks = {}
    metrics.plugins_active = metrics.plugins_active - 1
    
    if config.enable_logging then
        print(string.format("Plugin '%s' disabled", plugin_name))
    end
    
    return true, nil
end

--[[
    Exécute un hook avec gestion d'erreurs et timeout
--]]
function PluginManager.execute_hook(hook_name, ...)
    if not hooks[hook_name] then
        return
    end
    
    local args = {...}
    metrics.hook_executions = metrics.hook_executions + 1
    
    for _, hook_data in ipairs(hooks[hook_name]) do
        local start_time = os.clock()
        
        -- Exécuter dans le sandbox du plugin
        local old_env = getfenv(hook_data.func)
        setfenv(hook_data.func, hook_data.sandbox)
        
        local success, result = pcall(hook_data.func, unpack(args))
        
        setfenv(hook_data.func, old_env)
        
        local execution_time = (os.clock() - start_time) * 1000 -- ms
        
        if not success then
            metrics.hook_errors = metrics.hook_errors + 1
            if config.enable_logging then
                print(string.format("Hook error in plugin '%s': %s", 
                    hook_data.plugin_name, tostring(result)))
            end
        elseif execution_time > config.max_hook_execution_time then
            if config.enable_logging then
                print(string.format("Warning: Hook in plugin '%s' took %.2fms", 
                    hook_data.plugin_name, execution_time))
            end
        end
        
        -- Si le hook retourne false, arrêter la chaîne
        if result == false then
            break
        end
    end
end

--[[
    Diffuse un événement à tous les plugins abonnés
--]]
function PluginManager.broadcast_event(event_name, data, sender)
    PluginManager.execute_hook("on_event", event_name, data, sender)
end

--[[
    Liste tous les plugins avec leur statut
--]]
function PluginManager.list()
    local result = {}
    
    for name, plugin_data in pairs(plugins) do
        table.insert(result, {
            name = name,
            version = plugin_data.version,
            author = plugin_data.author,
            active = plugin_data.active,
            loaded_at = plugin_data.loaded_at,
            activated_at = plugin_data.activated_at,
            hooks_count = table.length(plugin_data.hooks),
            dependencies = plugin_data.dependencies,
            description = plugin_data.description
        })
    end
    
    -- Trier par nom
    table.sort(result, function(a, b) return a.name < b.name end)
    
    return result
end

--[[
    Obtient les informations d'un plugin spécifique
--]]
function PluginManager.get_plugin_info(plugin_name)
    local plugin_data = plugins[plugin_name]
    if not plugin_data then
        return nil
    end
    
    return {
        name = plugin_name,
        version = plugin_data.version,
        author = plugin_data.author,
        active = plugin_data.active,
        loaded_at = plugin_data.loaded_at,
        activated_at = plugin_data.activated_at,
        hooks = table.keys(plugin_data.hooks),
        dependencies = plugin_data.dependencies,
        description = plugin_data.description
    }
end

--[[
    Recharge un plugin
--]]
function PluginManager.reload(plugin_name)
    local plugin_data = plugins[plugin_name]
    if not plugin_data then
        return false, "Plugin not found"
    end
    
    local was_active = plugin_data.active
    
    -- Désactiver d'abord
    if was_active then
        local success, error_msg = PluginManager.disable(plugin_name)
        if not success then
            return false, "Failed to disable plugin: " .. error_msg
        end
    end
    
    -- Réactiver si nécessaire
    if was_active then
        local success, error_msg = PluginManager.enable(plugin_name)
        if not success then
            return false, "Failed to re-enable plugin: " .. error_msg
        end
    end
    
    return true, nil
end

--[[
    Obtient les métriques du gestionnaire de plugins
--]]
function PluginManager.get_metrics()
    local runtime_metrics = {
        uptime = os.time() - (metrics.startup_time or os.time()),
        active_hooks = 0,
        total_hooks = 0
    }
    
    for hook_name, hook_list in pairs(hooks) do
        runtime_metrics.total_hooks = runtime_metrics.total_hooks + #hook_list
        runtime_metrics.active_hooks = runtime_metrics.active_hooks + 1
    end
    
    return table.merge(metrics, runtime_metrics)
end

--[[
    Configure le gestionnaire de plugins
--]]
function PluginManager.configure(new_config)
    for key, value in pairs(new_config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

--[[
    Nettoie tous les plugins inactifs
--]]
function PluginManager.cleanup_inactive()
    local cleaned = 0
    
    for name, plugin_data in pairs(plugins) do
        if not plugin_data.active then
            plugins[name] = nil
            cleaned = cleaned + 1
        end
    end
    
    metrics.plugins_loaded = metrics.plugins_loaded - cleaned
    
    return cleaned
end

--[[
    Hooks prédéfinis pour l'intégration avec GearSwap
--]]

-- Hook pour les changements d'équipement
function PluginManager.on_equipment_change(slot, item)
    PluginManager.execute_hook("on_equipment_change", slot, item)
end

-- Hook pour les sorts lancés
function PluginManager.on_spell_cast(spell)
    PluginManager.execute_hook("on_spell_cast", spell)
end

-- Hook pour les buffs/debuffs
function PluginManager.on_buff_change(buff, gained)
    PluginManager.execute_hook("on_buff_change", buff, gained)
end

-- Hook pour les changements de statut
function PluginManager.on_status_change(new_status, old_status)
    PluginManager.execute_hook("on_status_change", new_status, old_status)
end

-- Hook pour les changements de job
function PluginManager.on_job_change(new_job, old_job)
    PluginManager.execute_hook("on_job_change", new_job, old_job)
end

-- Initialiser l'API
plugin_api = create_plugin_api()

-- Fonction utilitaire pour la compatibilité
function table.length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
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

function table.merge(t1, t2)
    local result = table.copy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

return PluginManager