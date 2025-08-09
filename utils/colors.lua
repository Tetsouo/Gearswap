---============================================================================
--- FFXI GearSwap Color System - Consistent Color Management
---============================================================================
--- Système de couleurs uniforme pour toutes les commandes GearSwap.
--- Garantit la cohérence visuelle à travers tous les modules.
---
--- @file utils/colors.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-08-07
---============================================================================

local Colors = {}

-- ============================================================================
-- PALETTE DE COULEURS STANDARD
-- ============================================================================

Colors.PALETTE = {
    -- En-têtes et séparateurs
    HEADER = 160,           -- Gris-violet pour tous les en-têtes
    SEPARATOR = 160,        -- Même couleur pour les séparateurs
    
    -- Status et résultats
    SUCCESS = 030,          -- Vert vif pour succès
    ERROR = 167,            -- Rouge-rose pour erreurs
    WARNING = 057,          -- Orange vif pour avertissements
    INFO = 050,             -- Jaune vif pour informations importantes
    
    -- Texte et contenu
    TEXT = 037,             -- Beige pour texte normal
    LABEL = 050,            -- Jaune pour les labels/catégories
    VALUE = 001,            -- Blanc pour les valeurs
    EMPTY = 001,            -- Blanc pour lignes vides
    
    -- Performance (couleurs dynamiques)
    EXCELLENT = 030,        -- Vert (>90%)
    GOOD = 050,             -- Jaune (70-90%)
    AVERAGE = 057,          -- Orange (50-70%)
    POOR = 167,             -- Rouge (<50%)
    
    -- Spéciaux
    HIGHLIGHT = 005,        -- Cyan pour mise en valeur
    ACCENT = 201            -- Violet pour accents spéciaux
}

-- ============================================================================
-- FONCTIONS D'AFFICHAGE STANDARDISÉES
-- ============================================================================

--- Affiche un en-tête standardisé
function Colors.show_header(title)
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
    windower.add_to_chat(Colors.PALETTE.HEADER, "      " .. title:upper())
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
end

--- Affiche un séparateur de fin
function Colors.show_footer()
    windower.add_to_chat(Colors.PALETTE.HEADER, "======================================")
end

--- Affiche une ligne vide
function Colors.show_empty_line()
    windower.add_to_chat(Colors.PALETTE.EMPTY, "")
end

--- Affiche une catégorie avec label
function Colors.show_category(category_name)
    windower.add_to_chat(Colors.PALETTE.LABEL, category_name .. ":")
end

--- Affiche une entrée avec label et valeur
function Colors.show_entry(label, value, color_override)
    local color = color_override or Colors.PALETTE.VALUE
    windower.add_to_chat(color, string.format("  %s: %s", label, tostring(value)))
end

--- Affiche un message de statut (succès/erreur/warning)
function Colors.show_status(message, status_type)
    local color = Colors.PALETTE.INFO
    local prefix = ""
    
    if status_type == "success" then
        color = Colors.PALETTE.SUCCESS
        prefix = "[SUCCES] "
    elseif status_type == "error" then
        color = Colors.PALETTE.ERROR  
        prefix = "[ERREUR] "
    elseif status_type == "warning" then
        color = Colors.PALETTE.WARNING
        prefix = "[ATTENTION] "
    end
    
    windower.add_to_chat(color, prefix .. message)
end

--- Retourne une couleur basée sur un pourcentage de performance
function Colors.get_performance_color(percentage)
    if percentage >= 90 then
        return Colors.PALETTE.EXCELLENT
    elseif percentage >= 70 then
        return Colors.PALETTE.GOOD
    elseif percentage >= 50 then
        return Colors.PALETTE.AVERAGE
    else
        return Colors.PALETTE.POOR
    end
end

--- Retourne une couleur basée sur un temps de réponse (en ms)
function Colors.get_time_color(time_ms)
    if time_ms <= 5 then
        return Colors.PALETTE.EXCELLENT
    elseif time_ms <= 15 then
        return Colors.PALETTE.GOOD
    elseif time_ms <= 30 then
        return Colors.PALETTE.AVERAGE
    else
        return Colors.PALETTE.POOR
    end
end

--- Retourne une couleur basée sur l'utilisation mémoire (en MB)
function Colors.get_memory_color(memory_mb)
    if memory_mb <= 2 then
        return Colors.PALETTE.EXCELLENT    -- Excellent: <= 2MB
    elseif memory_mb <= 4 then
        return Colors.PALETTE.WARNING      -- Attention: 2-4MB
    else
        return Colors.PALETTE.ERROR        -- Problème: > 4MB
    end
end

--- Affiche des statistiques formatées
function Colors.show_stats_section(title, stats)
    Colors.show_category(title)
    for label, value in pairs(stats) do
        if type(value) == "table" and value.value and value.color then
            Colors.show_entry(label, value.value, value.color)
        else
            Colors.show_entry(label, value)
        end
    end
end

--- Affiche un message d'action en cours
function Colors.show_action(message)
    windower.add_to_chat(Colors.PALETTE.INFO, message)
end

--- Affiche un message de progression
function Colors.show_progress(step, total, message)
    if total then
        local progress = string.format("[%d/%d] %s", step, total, message)
        windower.add_to_chat(Colors.PALETTE.HIGHLIGHT, progress)
    else
        windower.add_to_chat(Colors.PALETTE.HIGHLIGHT, message)
    end
end

-- ============================================================================
-- TEMPLATES POUR COMMANDES SPÉCIFIQUES
-- ============================================================================

--- Template pour commandes de test
function Colors.test_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        test_number_color = Colors.PALETTE.HIGHLIGHT,
        success_color = Colors.PALETTE.SUCCESS,
        error_color = Colors.PALETTE.ERROR,
        summary_color = Colors.PALETTE.HEADER
    }
end

--- Template pour statistiques
function Colors.stats_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        category_color = Colors.PALETTE.LABEL,
        value_color = Colors.PALETTE.VALUE,
        footer_color = Colors.PALETTE.HEADER
    }
end

--- Template pour actions de maintenance
function Colors.maintenance_template()
    return {
        header_color = Colors.PALETTE.HEADER,
        action_color = Colors.PALETTE.INFO,
        success_color = Colors.PALETTE.SUCCESS,
        warning_color = Colors.PALETTE.WARNING,
        footer_color = Colors.PALETTE.HEADER
    }
end

return Colors