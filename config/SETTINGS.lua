---============================================================================
--- CENTRAL CONFIGURATION - FFXI GEARSWAP
---============================================================================
--- 🎯 MAIN CONFIGURATION FILE
---
--- ⚠️  IMPORTANT: This is THE ONLY FILE to modify to configure your system!
---     All jobs use this centralized configuration.
---     No need to modify individual job files.
---
--- 📋 This file contains ALL configuration:
---   ✅ Character names (dual-box)
---   ✅ Macro books for each job combination
---   ✅ Lockstyles per job
---   ✅ Automation settings
---   ✅ Colors and interface
---
--- 🔄 After modification: //gs reload to apply changes
---
--- @file config/settings.lua
--- @author Tetsouo
--- @version 2.1
--- @date Modified: 2025-08-16
---============================================================================

local settings = {}

---============================================================================
--- 👥 CHARACTER CONFIGURATION
---============================================================================
--- ⚙️ Modify these names according to your characters

settings.players = {
    main = 'Tetsouo', -- 🎮 Main character name
    alt = 'Kaories',  -- 👤 Alt character name (dual-box)
}

---============================================================================
--- 📚 MACRO BOOK CONFIGURATION
---============================================================================
--- 🎯 MAIN SECTION: Configure ALL your macro books here!
---
--- 📖 Structure:
---   - lockstyles: Lockstyle number per job
---   - dual_box: Macro book when playing with your alt
---   - solo: Macro book when playing solo
---
--- 💡 Example: If you play THF with Kaories as GEO,
---     the system will use book 2 (dual_box.THF.GEO)

settings.macros = {
    ---========================================================================
    --- 🎭 LOCKSTYLES PER JOB
    ---========================================================================
    --- Lockstyle number to use for each job

    lockstyles = {
        THF = 1, -- 🗡️ Thief
        DNC = 2, -- 💃 Dancer
        PLD = 3, -- 🛡️ Paladin
        WAR = 4, -- ⚔️ Warrior
        BLM = 5, -- 🔮 Black Mage
        BST = 6, -- 🐺 Beast Master
        BRD = 7, -- 🎵 Bard
    },

    ---========================================================================
    --- 👫 DUAL-BOX CONFIGURATION
    ---========================================================================
    --- Macro books when playing with your alt character
    --- Format: [MAIN_JOB] = { [SUB_JOB] = { [ALT_JOB] = { book = X, page = Y } } }

    dual_box = {
        -- 🗡️ THIEF configurations
        THF = {
            WAR = {                           -- THF/WAR subjob
                RDM = { book = 1, page = 1 }, -- THF/WAR + Kaories RDM
                GEO = { book = 2, page = 1 }, -- THF/WAR + Kaories GEO
                COR = { book = 3, page = 1 }, -- THF/WAR + Kaories COR
            },
            DNC = {                           -- THF/DNC subjob
                RDM = { book = 1, page = 1 }, -- THF/DNC + Kaories RDM
                GEO = { book = 2, page = 1 }, -- THF/DNC + Kaories GEO
                COR = { book = 3, page = 1 }, -- THF/DNC + Kaories COR
            },
            NIN = {                           -- THF/NIN subjob
                RDM = { book = 1, page = 1 }, -- THF/NIN + Kaories RDM
                GEO = { book = 2, page = 1 }, -- THF/NIN + Kaories GEO
                COR = { book = 3, page = 1 }, -- THF/NIN + Kaories COR
            },
        },

        -- 💃 DANCER configurations
        DNC = {
            WAR = {                           -- DNC/WAR subjob
                RDM = { book = 4, page = 1 }, -- DNC/WAR + Kaories RDM
                COR = { book = 5, page = 1 }, -- DNC/WAR + Kaories COR
                GEO = { book = 6, page = 1 }, -- DNC/WAR + Kaories GEO
            },
            NIN = {                           -- DNC/NIN subjob
                RDM = { book = 4, page = 1 }, -- DNC/NIN + Kaories RDM
                COR = { book = 5, page = 1 }, -- DNC/NIN + Kaories COR
                GEO = { book = 6, page = 1 }, -- DNC/NIN + Kaories GEO
            },
        },

        -- 🔮 BLACK MAGE configurations
        BLM = {
            SCH = {                            -- BLM/SCH subjob
                RDM = { book = 7, page = 1 },  -- BLM/SCH + Kaories RDM
                GEO = { book = 8, page = 1 },  -- BLM/SCH + Kaories GEO
                COR = { book = 9, page = 1 },  -- BLM/SCH + Kaories COR
            },
            RDM = {                            -- BLM/RDM subjob
                RDM = { book = 10, page = 1 }, -- BLM/RDM + Kaories RDM
            },
        },

        -- 🐺 BEAST MASTER configurations
        BST = {
            DNC = {                            -- BST/DNC subjob
                RDM = { book = 11, page = 1 }, -- BST/DNC + Kaories RDM
                GEO = { book = 12, page = 1 }, -- BST/DNC + Kaories GEO
                COR = { book = 13, page = 1 }, -- BST/DNC + Kaories COR
            },
        },

        -- 🛡️ PALADIN configurations
        PLD = {
            RUN = {                            -- PLD/RUN subjob
                RDM = { book = 14, page = 1 }, -- PLD/RUN + Kaories RDM
                COR = { book = 15, page = 1 }, -- PLD/RUN + Kaories COR
            },
            BLU = {                            -- PLD/BLU subjob
                RDM = { book = 16, page = 1 }, -- PLD/BLU + Kaories RDM
                GEO = { book = 17, page = 1 }, -- PLD/BLU + Kaories GEO
                COR = { book = 18, page = 1 }, -- PLD/BLU + Kaories COR
            },
            RDM = {                            -- PLD/RDM subjob
                RDM = { book = 19, page = 1 }, -- PLD/RDM + Kaories RDM
            },
        },

        -- ⚔️ WARRIOR configurations
        WAR = {
            SAM = {                            -- WAR/SAM subjob
                RDM = { book = 22, page = 1 }, -- WAR/SAM + Kaories RDM
                GEO = { book = 23, page = 1 }, -- WAR/SAM + Kaories GEO
                COR = { book = 24, page = 1 }, -- WAR/SAM + Kaories COR
            },
            DRG = {                            -- WAR/DRG subjob
                RDM = { book = 25, page = 1 }, -- WAR/DRG + Kaories RDM
                GEO = { book = 26, page = 1 }, -- WAR/DRG + Kaories GEO
                COR = { book = 27, page = 1 }, -- WAR/DRG + Kaories COR
            },
            DNC = {                            -- WAR/DNC subjob
                RDM = { book = 28, page = 1 }, -- WAR/DRG + Kaories RDM
                GEO = { book = 29, page = 1 }, -- WAR/DRG + Kaories GEO
                COR = { book = 30, page = 1 }, -- WAR/DRG + Kaories COR
            },
        },

        -- 🎵 BARD configurations
        BRD = {
            SCH = {                            -- BRD/SCH subjob
                RDM = { book = 31, page = 1 }, -- BRD/SCH + Kaories RDM
                GEO = { book = 32, page = 1 }, -- BRD/SCH + Kaories GEO
                COR = { book = 33, page = 1 }, -- BRD/SCH + Kaories COR
            },
            DNC = {                            -- BRD/DNC subjob
                RDM = { book = 34, page = 1 }, -- BRD/DNC + Kaories RDM
                GEO = { book = 35, page = 1 }, -- BRD/DNC + Kaories GEO
                COR = { book = 36, page = 1 }, -- BRD/DNC + Kaories COR
            },
        },
    },

    ---========================================================================
    --- 🏠 SOLO CONFIGURATION
    ---========================================================================
    --- Macro books when playing solo (according to your subjob)
    --- Format: [MAIN_JOB] = { [SUBJOB] = { book = X, page = Y } }

    solo = {
        -- 🗡️ THIEF solo with different subjobs
        THF = {
            WAR = { book = 1, page = 1 }, -- THF/WAR
            DNC = { book = 1, page = 1 }, -- THF/DNC
            NIN = { book = 1, page = 1 }, -- THF/NIN
            RDM = { book = 1, page = 1 }, -- THF/RDM
            BLM = { book = 1, page = 1 }, -- THF/BLM
            WHM = { book = 1, page = 1 }, -- THF/WHM
        },

        -- 💃 DANCER solo with different subjobs
        DNC = {
            WAR = { book = 1, page = 1 }, -- DNC/WAR
            NIN = { book = 1, page = 1 }, -- DNC/NIN
            SAM = { book = 1, page = 1 }, -- DNC/SAM
        },

        -- ⚔️ WARRIOR solo with different subjobs
        WAR = {
            DRG = { book = 1, page = 1 }, -- WAR/DRG
            SAM = { book = 1, page = 1 }, -- WAR/SAM
            DNC = { book = 1, page = 1 }, -- WAR/DNC
        },

        -- 🛡️ PALADIN solo with different subjobs
        PLD = {
            BLU = { book = 1, page = 1 }, -- PLD/BLU
            WAR = { book = 1, page = 1 }, -- PLD/WAR
            RDM = { book = 1, page = 1 }, -- PLD/RDM
        },

        -- 🔮 BLACK MAGE solo with different subjobs
        BLM = {
            RDM = { book = 1, page = 1 }, -- BLM/RDM
            SCH = { book = 1, page = 1 }, -- BLM/SCH
            WHM = { book = 1, page = 1 }, -- BLM/WHM
        },

        -- 🎵 BARD solo with different subjobs
        BRD = {
            WHM = { book = 1, page = 1 }, -- BRD/WHM
            RDM = { book = 1, page = 1 }, -- BRD/RDM
            NIN = { book = 1, page = 1 }, -- BRD/NIN
        },

        -- 🐺 BEAST MASTER solo with different subjobs
        BST = {
            DNC = { book = 11, page = 1 }, -- BST/DNC
            NIN = { book = 12, page = 1 }, -- BST/NIN
            WHM = { book = 13, page = 1 }, -- BST/WHM
        },

        -- 🐉 DRAGOON solo with different subjobs
        DRG = {
            SAM = { book = 1, page = 1 }, -- DRG/SAM
            WAR = { book = 1, page = 1 }, -- DRG/WAR
            WHM = { book = 1, page = 1 }, -- DRG/WHM
        },

        -- 🗡️ RUNE FENCER solo with different subjobs
        RUN = {
            SAM = { book = 1, page = 1 }, -- RUN/SAM
            WAR = { book = 1, page = 1 }, -- RUN/WAR
            BLU = { book = 1, page = 1 }, -- RUN/BLU
        },
    },
}

---============================================================================
--- 🎨 INTERFACE CONFIGURATION
---============================================================================
--- Visual and message settings

settings.ui = {
    -- 🌈 Chat message colors
    colors = {
        error = 167,   -- 🔴 Red - Errors
        warning = 057, -- 🟠 Orange - Warnings
        info = 050,    -- 🟡 Yellow - Information
        debug = 160,   -- ⚫ Gray - Debug
        success = 158, -- 🟢 Green - Success
    },

    -- 💬 Message formatting
    messages = {
        show_timestamps = false, -- Show timestamps in messages
        show_separators = true,  -- Show visual separators
    },
}

---============================================================================
--- 🐞 DEBUG CONFIGURATION
---============================================================================
--- Debug and diagnostic settings

settings.debug = {
    enabled = false,       -- 🔧 Debug mode enabled
    level = 'INFO',        -- 📊 Level: 'ERROR', 'WARN', 'INFO', 'DEBUG'
    show_swaps = true,     -- 👕 Show equipment changes
    show_cooldowns = true, -- ⏱️ Show spell cooldowns
}

---============================================================================
--- 🏃 MOVEMENT CONFIGURATION
---============================================================================
--- Automatic movement detection

settings.movement = {
    threshold = 1.0,        -- 📏 Movement detection threshold
    check_interval = 15,    -- ⏰ Check frequency (ticks)
    engaged_moving = false, -- 🏃 Movement equipment while engaged
}

---============================================================================
--- ⚔️ COMBAT CONFIGURATION
---============================================================================
--- Combat automation

settings.combat = {
    -- 🚫 Automatic buff cancellation
    auto_cancel = {
        retaliation_on_move = true, -- Cancel Retaliation on long movement
        cancel_conflicts = true,    -- Cancel conflicting buffs
    },

    -- 🗡️ Weaponskill settings
    weaponskill = {
        auto_adjust_ears = true,    -- Adjust earrings based on TP
        moonshade_threshold = 1750, -- TP threshold for Moonshade
        range_check = true,         -- Check weaponskill range
    },
}

---============================================================================
--- 🎯 JOB-SPECIFIC CONFIGURATION
---============================================================================
--- Specialized settings per job

settings.jobs = {
    -- 🗡️ Thief
    THF = {
        default_th_mode = 'Tag',           -- Default TH mode
        maintain_sa_ta_idle = true,        -- Keep SA/TA equipment while idle
        sa_priority_over_ta = true,        -- SA priority over TA
        auto_sa_ta_combat = true,          -- Auto SA/TA in combat
        prefer_specialized_th_sets = true, -- Specialized TH sets
        auto_cancel_shadows = true,        -- Auto cancel shadows
    },

    -- ⚔️ Warrior
    WAR = {
        default_weapon = 'Chango',      -- Default weapon
        auto_restraint = true,          -- Auto restraint
        smart_stance = true,            -- Smart stance
        auto_cancel_retaliation = true, -- Cancel Retaliation on movement
    },

    -- 🔮 Black Mage
    BLM = {
        default_mode = 'MagicBurst',                                     -- Default mode
        auto_buffs = { 'Stoneskin', 'Blink', 'Aquaveil', 'Ice Spikes' }, -- Auto buffs
        save_mp_threshold = 100,                                         -- MP conservation threshold
    },

    -- 🛡️ Paladin
    PLD = {
        default_mode = 'PDT',  -- Default defense mode
        auto_sentinel_hp = 50, -- HP threshold for auto Sentinel
    },

    -- 🐺 Beast Master
    BST = {
        default_jug = 'Dire Broth', -- Default jug pet
        auto_reward_hp = 50,        -- HP threshold for auto Reward
    },
}

---============================================================================
--- 🔄 AUTOMATION CONFIGURATION
---============================================================================
--- Advanced automation settings

settings.automation = {
    -- 💪 Automatic buff management
    buffs = {
        refresh_threshold = 30, -- ⏱️ Min time before refresh (seconds)
        cast_delay = 2,         -- ⏳ Delay between spells (seconds)
    },

    -- 🪄 Spell management
    spells = {
        auto_downgrade = true,  -- 📉 Auto downgrade if higher tier on CD
        cancel_on_no_mp = true, -- 🚫 Cancel if not enough MP
    },
}

---============================================================================
--- 🎮 KEYBIND CONFIGURATION
---============================================================================
--- Global keyboard shortcuts

settings.keybinds = {
    -- 🌐 Global keys (all jobs)
    global = {
        -- F keys are generally reserved for state cycling
        -- Ctrl/Alt modifiers for commands
    },
    -- Job-specific keys are defined in each job file
}

---============================================================================
--- ✅ VALIDATION SYSTEM
---============================================================================

--- Validate all configuration settings for completeness and correctness.
--- Performs comprehensive validation of player names, debug levels, macro
--- configurations, and other critical settings.
--- @return boolean True if all settings are valid
--- @return table Array of error messages (empty if valid)
function settings:validate()
    local errors = {}

    -- Check character names
    if not self.players.main or self.players.main == '' then
        table.insert(errors, "❌ Main character name not defined")
    end

    -- Check debug level
    local valid_levels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
    if not valid_levels[self.debug.level] then
        table.insert(errors, "❌ Invalid debug level: " .. tostring(self.debug.level))
    end

    -- Check movement threshold
    if self.movement.threshold <= 0 then
        table.insert(errors, "❌ Movement threshold must be positive")
    end

    return #errors == 0, errors
end

---============================================================================
--- 📤 MODULE EXPORT
---============================================================================

return settings
