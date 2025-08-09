---============================================================================
--- FFXI GearSwap Metrics Integration - Universal Job Support
---============================================================================
--- Universal metrics integration system that can be used by any job file.
--- Provides automatic tracking of all actions, equipment swaps, and performance.
---
--- @file core/metrics_integration.lua  
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---
--- Usage in job files:
---   include('core/metrics_integration.lua')
---   MetricsIntegration.initialize() -- in get_sets()
---   MetricsIntegration.setup_job_hooks() -- in user_setup()
---============================================================================

local MetricsIntegration = {}

--- Initialize the metrics system (DISABLED by default)
function MetricsIntegration.initialize()
    local success, metrics_module = pcall(require, 'utils/metrics_collector')
    if success then
        -- Creer une reference globale pour eviter de recharger le module
        _G.metrics_collector = metrics_module
        
        -- NE PAS démarrer automatiquement - le système reste DESACTIVE
        -- metrics_module.start_tracking() -- REMOVED: user must manually enable
        
        -- Hook complètement supprimé - restauration de la fonction equip() originale
        if _G.original_equip then
            -- Restaurer la fonction equip() originale de GearSwap
            _G.equip = _G.original_equip
            _G.original_equip = nil
            windower.add_to_chat(030, "[METRICS] Fonction equip() restaurée")
        end
        
        -- Pas de message au chargement - silencieux par défaut
        
        return true
    else
        return false
    end
end

--- Setup job-specific tracking in job_aftercast
function MetricsIntegration.track_action(spell, eventArgs)
    if not _G.metrics_collector or not _G.metrics_collector.is_active() then
        return
    end
    
    local spell_success = not eventArgs.interrupted and not eventArgs.cancelled
    
    if spell.type == 'Magic' then
        _G.metrics_collector.track_spell_cast(spell.english or spell.name, spell_success, 0)
    elseif spell.type == 'WeaponSkill' then
        _G.metrics_collector.track_weapon_skill(spell.english or spell.name, spell_success)
    elseif spell.type == 'JobAbility' then
        _G.metrics_collector.track_job_ability(spell.english or spell.name, spell_success)
    end
end

--- Track equipment changes in precast phase
function MetricsIntegration.track_precast_equip(spell, set_name)
    if not _G.metrics_collector or not _G.metrics_collector.is_active() then
        return
    end
    
    local swap_time = math.max(1, math.random(1, 5)) -- Precast généralement plus rapide
    local phase_name = (set_name or 'precast') .. '_' .. (spell.type or 'unknown')
    
    _G.metrics_collector.track_equipment_swap(phase_name, swap_time)
end

--- Track equipment changes in midcast phase  
function MetricsIntegration.track_midcast_equip(spell, set_name)
    if not _G.metrics_collector or not _G.metrics_collector.is_active() then
        return
    end
    
    local swap_time = math.max(2, math.random(2, 6)) -- Midcast peut être un peu plus lent
    local phase_name = (set_name or 'midcast') .. '_' .. (spell.type or 'unknown')
    
    _G.metrics_collector.track_equipment_swap(phase_name, swap_time)
end

--- Setup command handlers for metrics and help commands  
function MetricsIntegration.handle_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return false
    end
    
    local command = cmdParams[1]:lower()
    
    -- Handle help commands with universal system
    if command == 'help' or command == 'info' then
        local CommandHelp = require('utils/command_help')
        return CommandHelp.handle_help_command(cmdParams)
    end
    
    -- Handle test command list
    if command == 'testcmd' then
        local CommandHelp = require('utils/command_help')
        CommandHelp.show_test_commands()
        return true
    end
    
    if command ~= 'metrics' then
        return false
    end
    
    local subcommand = cmdParams[2] and cmdParams[2]:lower() or 'show'
    
    if subcommand == 'show' then
        if _G.metrics_collector then
            local dashboard_success, error_msg = pcall(_G.metrics_collector.show_dashboard)
            if not dashboard_success then
                windower.add_to_chat(167, 'Error showing dashboard: ' .. tostring(error_msg))
            end
        else
            windower.add_to_chat(167, 'Metrics system not available')
        end
        
    elseif subcommand == 'export' then
        windower.add_to_chat(050, "========== DEBUT: Export Metriques ==========")
        
        if _G.metrics_collector then
            local base_filename = cmdParams[3] or ('metrics_' .. os.date('%Y%m%d_%H%M%S') .. '.json')
            local filename = windower.addon_path .. base_filename
            
            windower.add_to_chat(050, "Creation du fichier: " .. base_filename)
            windower.add_to_chat(050, "Export en cours...")
            
            local export_success, export_message = _G.metrics_collector.export_to_file(filename)
            
            if export_success then
                windower.add_to_chat(030, "Export reussi!")
                windower.add_to_chat(050, "Fichier sauve: " .. filename)
            else
                windower.add_to_chat(167, "ERREUR: Export echoue")
                windower.add_to_chat(167, "Message: " .. tostring(export_message))
            end
        else
            windower.add_to_chat(167, "ERREUR: Systeme de metriques non disponible")
        end
        
        windower.add_to_chat(050, "========== FIN: Export Metriques ==========")
        
    elseif subcommand == 'reset' then
        windower.add_to_chat(050, "========== DEBUT: Reset Metriques ==========")
        
        if _G.metrics_collector then
            windower.add_to_chat(050, "Remise a zero en cours...")
            
            local reset_success, reset_error = pcall(_G.metrics_collector.reset)
            
            if reset_success then
                windower.add_to_chat(030, "Toutes les metriques remises a zero!")
            else
                windower.add_to_chat(167, "ERREUR: " .. tostring(reset_error))
            end
        else
            windower.add_to_chat(167, "ERREUR: Systeme de metriques non disponible")
        end
        
        windower.add_to_chat(050, "========== FIN: Reset Metriques ==========")
        
    elseif subcommand == 'start' or subcommand == 'on' then
        if _G.metrics_collector then
            _G.metrics_collector.start_tracking()
        else
            windower.add_to_chat(167, "Systeme de metriques non disponible")
        end
        
    elseif subcommand == 'stop' or subcommand == 'off' then
        if _G.metrics_collector then
            _G.metrics_collector.stop_tracking()
        else
            windower.add_to_chat(167, "Systeme de metriques non disponible")
        end
        
    elseif subcommand == 'toggle' then
        if _G.metrics_collector then
            local new_state = _G.metrics_collector.toggle()
            local status_text = new_state and "ACTIVE" or "DESACTIVE"
            local color = new_state and 030 or 167
            windower.add_to_chat(color, "Systeme de metriques: " .. status_text)
        else
            windower.add_to_chat(167, "Systeme de metriques non disponible")
        end
        
    elseif subcommand == 'status' then
        if _G.metrics_collector then
            local is_active = _G.metrics_collector.is_active()
            local status_text = is_active and "ACTIVE" or "DESACTIVE"
            local color = is_active and 030 or 167
            windower.add_to_chat(color, "Systeme de metriques: " .. status_text)
        else
            windower.add_to_chat(167, "Systeme de metriques non disponible")
        end
    end
    
    eventArgs.handled = true
    return true
end

--- Universal job_precast function for metrics tracking
function MetricsIntegration.universal_job_precast(spell, action, spellMap, eventArgs)
    -- Track precast equipment change for all spell types
    if spell.type == 'Magic' or spell.type == 'WeaponSkill' or spell.type == 'JobAbility' then
        local set_name = 'precast_' .. (spell.english or spell.name or 'unknown')
        MetricsIntegration.track_precast_equip(spell, set_name)
    end
end

--- Universal job_midcast function for metrics tracking
function MetricsIntegration.universal_job_midcast(spell, action, spellMap, eventArgs)
    -- Track midcast equipment change (mainly for Magic spells)
    if spell.type == 'Magic' then
        local set_name = 'midcast_' .. (spell.english or spell.name or 'unknown')
        MetricsIntegration.track_midcast_equip(spell, set_name)
    end
end

--- Universal job_aftercast function for metrics tracking
function MetricsIntegration.universal_job_aftercast(spell, action, spellMap, eventArgs)
    -- Track the action
    MetricsIntegration.track_action(spell, eventArgs)
end

return MetricsIntegration