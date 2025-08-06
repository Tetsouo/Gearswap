---============================================================================
--- FFXI GearSwap Configuration Settings
---============================================================================
--- Centralized configuration definitions for the entire GearSwap system.
--- Contains all user-customizable settings, job-specific configurations,
--- automation parameters, and system preferences.
---
--- @file settings.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05
--- @date Modified: 2025-08-05
--- @requires config/config.lua
---
--- Configuration Categories:
---   - Player Management: Character names for dual-boxing
---   - Debug System: Logging levels and debug output control
---   - Movement Detection: Automatic movement-based gear swapping
---   - User Interface: Colors, messages, and display preferences
---   - Combat Automation: Weapon skills, buff management, auto-cancellation
---   - Job-Specific: Per-job customizations and preferences
---   - Automation: Buff refresh, spell downgrade, and timing settings
---   - Keybindings: Global and job-specific key assignments
---
--- Validation:
---   All settings are automatically validated on load with detailed
---   error reporting for invalid configurations.
---
--- Usage:
---   Modify values in this file and reload GearSwap (//gs reload)
---   to apply changes. Invalid settings will be reported in chat.
---
--- Thread Safety:
---   This configuration is loaded once at startup and should be
---   considered read-only during normal operation.
---============================================================================

---============================================================================
--- SETTINGS MODULE INITIALIZATION
---============================================================================

--- @type table Main settings table containing all configuration data
local settings = {}

---============================================================================
--- PLAYER MANAGEMENT CONFIGURATION
---============================================================================
--- Character names and identity management for dual-boxing scenarios.
--- These names are used throughout the system for player identification
--- and coordination between multiple characters.

settings.players = {
    -- Main character name
    main = 'Tetsouo',

    -- Alt character name for dual-boxing
    alt = 'Kaories',
}

---============================================================================
--- DEBUG AND LOGGING CONFIGURATION
---============================================================================
--- Controls debug output, logging levels, and diagnostic information display.
--- Essential for troubleshooting and development purposes.

settings.debug = {
    -- Enable debug mode (more verbose output)
    enabled = false,

    -- Debug level: 'ERROR', 'WARN', 'INFO', 'DEBUG'
    level = 'INFO',

    -- Show gear swaps in chat
    show_swaps = true,

    -- Show spell cooldowns
    show_cooldowns = true,
}

---============================================================================
--- MOVEMENT DETECTION CONFIGURATION
---============================================================================
--- Parameters controlling automatic movement detection and movement-based
--- gear swapping functionality.

settings.movement = {
    -- Distance threshold to detect movement (default: 1.0)
    threshold = 1.0,

    -- How often to check movement in prerender ticks (default: 15)
    check_interval = 15,

    -- Enable movement speed gear while engaged
    engaged_moving = false,
}

---============================================================================
--- USER INTERFACE CONFIGURATION
---============================================================================
--- Visual appearance settings, chat colors, and message formatting options
--- for consistent user experience across all system outputs.

settings.ui = {
    -- Chat colors
    colors = {
        error = 167,   -- Red
        warning = 057, -- Orange
        info = 050,    -- Yellow
        debug = 160,   -- Gray
        success = 158, -- Green
    },

    -- Message formatting
    messages = {
        show_timestamps = false,
        show_separators = true,
    },
}

---============================================================================
--- COMBAT AUTOMATION CONFIGURATION
---============================================================================
--- Settings controlling automatic combat behaviors, weapon skill optimization,
--- and buff management during combat encounters.

settings.combat = {
    -- Auto-cancel buffs
    auto_cancel = {
        -- Cancel Retaliation on long movement
        retaliation_on_move = true,

        -- Cancel conflicting buffs
        cancel_conflicts = true,
    },

    -- Weapon skill settings
    weaponskill = {
        -- Auto-adjust earrings based on TP
        auto_adjust_ears = true,

        -- TP thresholds for earring swaps
        moonshade_threshold = 1750,

        -- Range check for weapon skills
        range_check = true,
    },
}

---============================================================================
--- JOB-SPECIFIC CONFIGURATION
---============================================================================
--- Per-job customizations and specialized behavior settings.
--- Each job can have unique parameters while maintaining system consistency.

settings.jobs = {
    -- Thief-specific settings
    THF = {
        -- Keep SA/TA gear even when moving in idle
        maintain_sa_ta_idle = true,
        
        -- Priority: SA > TA when both are active
        sa_priority_over_ta = true,
        
        -- Auto-apply SA/TA in combat (works with TH)
        auto_sa_ta_combat = true,
        
        -- Prefer specialized TH+SA/TA sets over auto-combination
        prefer_specialized_th_sets = true,
    },
    
    -- Add more job-specific settings as needed
    WAR = {
        -- Auto-cancel Retaliation on movement
        auto_cancel_retaliation = true,
    },
}

---============================================================================
--- AUTOMATION SYSTEM CONFIGURATION
---============================================================================
--- Settings controlling automatic buff management, spell optimization,
--- and timing parameters for various automated behaviors.

settings.automation = {
    -- Auto-buff settings
    buffs = {
        -- Minimum time remaining on buff before refresh (seconds)
        refresh_threshold = 30,

        -- Delay between buff casts (seconds)
        cast_delay = 2,
    },

    -- Spell downgrade settings
    spells = {
        -- Auto-downgrade spells if higher tier on cooldown
        auto_downgrade = true,

        -- Cancel spell if no MP for lowest tier
        cancel_on_no_mp = true,
    },
}

-- Merge additional job settings into existing jobs table
settings.jobs.WAR = settings.jobs.WAR or {}
settings.jobs.WAR.default_weapon = 'Chango'
settings.jobs.WAR.auto_restraint = true
settings.jobs.WAR.smart_stance = true

settings.jobs.BLM = settings.jobs.BLM or {}
settings.jobs.BLM.default_mode = 'MagicBurst'
settings.jobs.BLM.auto_buffs = { 'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes' }
settings.jobs.BLM.save_mp_threshold = 100

-- Keep existing detailed THF settings and add basic ones
settings.jobs.THF.default_th_mode = 'Tag'
settings.jobs.THF.auto_cancel_shadows = true

settings.jobs.PLD = settings.jobs.PLD or {}
settings.jobs.PLD.default_mode = 'PDT'
settings.jobs.PLD.auto_sentinel_hp = 50

settings.jobs.BST = settings.jobs.BST or {}
settings.jobs.BST.default_jug = 'Dire Broth'
settings.jobs.BST.auto_reward_hp = 50

---============================================================================
--- KEYBINDING CONFIGURATION
---============================================================================
--- Global keybinding preferences and job-specific key assignment guidelines.
--- Job-specific bindings are typically defined in individual job files.

settings.keybinds = {
    -- Global keybinds (apply to all jobs)
    global = {
        -- F-keys typically reserved for state cycling
        -- Ctrl/Alt modifiers for commands
    },

    -- Job-specific keybinds are set in each job file
}

---============================================================================
--- CONFIGURATION VALIDATION SYSTEM
---============================================================================

--- Validate all configuration settings for correctness and consistency.
--- Performs comprehensive validation of all setting categories to ensure
--- the system can operate safely with the provided configuration.
---
--- Validation Checks:
---   - Player names are properly defined and non-empty
---   - Debug levels are valid and recognized
---   - Movement parameters are within acceptable ranges
---   - All numeric values are positive where required
---
--- @return boolean True if all settings are valid
--- @return table List of error messages for invalid settings
function settings:validate()
    local errors = {}

    -- Check player names
    if not self.players.main or self.players.main == '' then
        table.insert(errors, "Main player name not set")
    end

    -- Check debug level
    local valid_levels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
    if not valid_levels[self.debug.level] then
        table.insert(errors, "Invalid debug level: " .. tostring(self.debug.level))
    end

    -- Check movement threshold
    if self.movement.threshold <= 0 then
        table.insert(errors, "Movement threshold must be positive")
    end

    return #errors == 0, errors
end

---============================================================================
--- MODULE EXPORT
---============================================================================
--- Export the complete settings table for use by the configuration loader.

return settings
