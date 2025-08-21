---============================================================================
--- FFXI GearSwap Bard Configuration - User Settings
---============================================================================
--- Centralized configuration for BRD job. All user-customizable settings are here.
--- Edit this file to adjust song rotations, timings, and behavior.
--- Provides comprehensive configuration for song management, timing optimization,
--- and automation preferences with extensive customization options.
---
--- @file jobs/brd/BRD_CONFIG.lua
--- @author Tetsouo
--- @version 3.0
--- @date Modified: 2025-08-17
---
--- Features:
---   - Song timing configuration for network latency
---   - Rotational automation settings and preferences
---   - Party composition and song priority management
---   - Display customization and short name mappings
---   - Advanced automation controls and safety settings
---
--- @usage
---   local BRD_CONFIG = require('jobs/brd/BRD_CONFIG')
---   local delay = BRD_CONFIG.TIMINGS.song_delay
---============================================================================

local BRD_CONFIG = {}

---============================================================================
--- TIMING CONFIGURATION
---============================================================================
--- Adjust these values to match your network latency and preferences

BRD_CONFIG.TIMINGS = {
    -- Basic song casting delays (in seconds)
    song_delay = 6,       -- Normal delay between songs (adjust for your latency)
    song_delay_nitro = 4, -- Delay with Nightingale+Troubadour active (-2s faster)

    -- Ability delays
    marcato_delay = 3,    -- Extra wait after using Marcato
    pianissimo_delay = 1, -- Extra delay for Pianissimo targeting
    ability_delay = 1.5,  -- General ability usage delay

    -- System delays
    fast_cast_delay = 0.1,  -- Quick cast for song refine system
    mode_switch_delay = 0.5 -- Delay when switching between Party/Dummy modes
}

---============================================================================
--- CHARACTER CONFIGURATION
---============================================================================
--- Settings specific to your character

BRD_CONFIG.CHARACTER = {
    -- Your character name (used for Pianissimo commands)
    name = "Tetsouo",

    -- Default song mode on load
    default_mode = "Party", -- Options: "Party", "Dummy"

    -- Enable auto-targeting for pianissimo
    auto_target = true
}

---============================================================================
--- SONG ROTATION PACKS
---============================================================================
--- Define your preferred song combinations for different situations
--- Each pack should have exactly 5 songs (for Clarion Call scenarios)
---
--- IMPORTANT INSTRUMENT REQUIREMENTS:
--- - Honor March: MUST have Marsyas equipped (cannot be cast with other instruments)
--- - Aria of Passion: MUST have Loughnashade equipped (cannot be cast with other instruments)
--- - These songs will interrupt if the instrument changes during cast!

BRD_CONFIG.SONG_PACKS = {
    -------------------------------------------
    -- MELEE DPS PACKS (Party-wide buffs)
    -------------------------------------------

    -- Standard offensive setup with survivability
    Dirge = {
        name = "Dirge Pack",
        description = "Balanced offense with EXP protection",
        songs = {
            'Honor March',         -- [1] Haste + Attack + Accuracy (REQUIRES Marsyas!)
            'Valor Minuet V',      -- [2] Attack +112
            'Valor Minuet IV',     -- [3] Attack +96
            'Adventurer\'s Dirge', -- [4] Reduces EXP loss on death
            'Victory March',       -- [5] Haste + Attack (can be replaced when Haste active)
        }
    },

    -- High accuracy for evasive enemies
    Madrigal = {
        name = "Madrigal Pack",
        description = "Maximum accuracy for high-evasion targets",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Blade Madrigal',  -- [4] Accuracy +60
            'Victory March',   -- [5] Haste + Attack
        }
    },

    -- Defensive melee setup
    Minne = {
        name = "Minne Pack",
        description = "Offensive power with defensive buffer",
        songs = {
            'Honor March',       -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',    -- [2] Attack +112
            'Valor Minuet IV',   -- [3] Attack +96
            'Knight\'s Minne V', -- [4] Defense +200
            'Victory March',     -- [5] Haste + Attack
        }
    },

    -- STR boost for weapon skills
    Etude = {
        name = "Etude Pack",
        description = "STR enhancement for heavy WS damage",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Herculean Etude', -- [4] STR +13
            'Victory March',   -- [5] Haste + Attack
        }
    },

    -------------------------------------------
    -- SUPPORT PACKS (Single-target via Pianissimo)
    -------------------------------------------

    -- Tank support setup
    Tank = {
        name = "Tank Pack",
        description = "Defense and MP recovery for tanks",
        songs = {
            'Victory March',      -- [1] Haste + Attack for enmity generation
            'Knight\'s Minne V',  -- [2] Defense +200
            'Mage\'s Ballad III', -- [3] MP Recovery +10/tick
            'Mage\'s Ballad II',  -- [4] MP Recovery +7/tick
            'Sentinel\'s Scherzo' -- [5] Critical hit evasion +75%
        }
    },

    -- Healer support setup
    Healer = {
        name = "Healer Pack",
        description = "MP recovery and protection for healers",
        songs = {
            'Victory March',      -- [1] Haste for faster casting
            'Knight\'s Minne V',  -- [2] Defense +200
            'Mage\'s Ballad III', -- [3] MP Recovery +10/tick
            'Mage\'s Ballad II',  -- [4] MP Recovery +7/tick
            'Sentinel\'s Scherzo' -- [5] Critical hit evasion +75%
        }
    },

    -- Carol resistance setup
    Carol = {
        name = "Carol Pack",
        description = "Elemental resistance and defensive buffs",
        songs = {
            'Honor March',     -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',  -- [2] Attack +112
            'Valor Minuet IV', -- [3] Attack +96
            'Fire Carol',      -- [4] Fire resistance +50%
            'Victory March',   -- [5] Haste + Attack
        }
    },

    -- Scherzo evasion setup
    Scherzo = {
        name = "Scherzo Pack",
        description = "Critical hit evasion and defensive buffs",
        songs = {
            'Honor March',         -- [1] Haste + Attack + Accuracy
            'Valor Minuet V',      -- [2] Attack +112
            'Valor Minuet IV',     -- [3] Attack +96
            'Sentinel\'s Scherzo', -- [4] Critical hit evasion +75%
            'Victory March',       -- [5] Haste + Attack
        }
    }
}

---============================================================================
--- DUMMY SONG CONFIGURATION
---============================================================================
--- Songs used to maintain song slots without useful effects
--- These are cast first, then overwritten with real songs

BRD_CONFIG.DUMMY_SONGS = {
    -- Standard dummy songs for slot preparation
    standard = {
        'Gold Capriccio',  -- [1] Enmity -50 (useless in most content)
        'Goblin Gavotte',  -- [2] Bind resistance +20 (rarely needed)
        'Fowl Aubade',     -- [3] Sleep resistance +20 (situational)
        'Herb Pastoral',   -- [4] Poison resistance +20 (minimal use)
        'Shining Fantasia' -- [5] Blind resistance +20 (for 5th slot)
    },

    -- Alternative dummy songs if needed
    alternative = {
        'Scop\'s Operetta',   -- Silence resistance
        'Puppet\'s Operetta', -- Slow resistance
        'Warding Round',      -- Curse resistance
        'Gold Capriccio',     -- Enmity reduction
        'Goblin Gavotte'      -- Bind resistance
    }
}

-- Legacy support for old dummy pack system
BRD_CONFIG.DUMMY_PACKS = {
    Trash = {
        name = "Trash Pack",
        songs = BRD_CONFIG.DUMMY_SONGS.standard
    },
    Garbage = {
        name = "Garbage Pack",
        songs = BRD_CONFIG.DUMMY_SONGS.alternative
    }
}

---============================================================================
--- VICTORY MARCH REPLACEMENT
---============================================================================
--- When you have Haste/Haste II from a mage, Victory March becomes redundant
--- These settings control what to replace it with

BRD_CONFIG.VICTORY_MARCH_REPLACE = {
    -- Enable automatic Victory March replacement when Haste is detected
    enabled = true,

    -- Default replacement song when Haste is active
    default = "Madrigal", -- Options: "Madrigal", "Minne", "Scherzo"

    -- Specific replacements per pack
    replacements = {
        Madrigal = 'Blade Madrigal',    -- +60 Accuracy
        Minne = 'Knight\'s Minne V',    -- +200 Defense
        Scherzo = 'Sentinel\'s Scherzo' -- Critical hit evasion
    }
}

---============================================================================
--- BUFF DETECTION NAMES
---============================================================================
--- Exact buff names as they appear in FFXI (for detection)

BRD_CONFIG.FIFTH_SONG_BUFFS = {
    Dirge = "Adventurer's Dirge",
    Madrigal = "Madrigal",
    Minne = "Minne",
    Etude = "Etude",
    Carol = "Carol",
    Scherzo = "Scherzo",
    Tank = "Scherzo",
    Healer = "Scherzo"
}

---============================================================================
--- DISPLAY SETTINGS
---============================================================================
--- How information is shown in chat

BRD_CONFIG.SHORT_NAMES = {
    -- March songs
    ['Honor March'] = 'Honor',
    ['Victory March'] = 'Victory',

    -- Minuet songs
    ['Valor Minuet V'] = 'Min5',
    ['Valor Minuet IV'] = 'Min4',
    ['Valor Minuet III'] = 'Min3',

    -- Madrigal songs
    ['Blade Madrigal'] = 'Madrigal',
    ['Sword Madrigal'] = 'Sword Mad',

    -- Minne songs
    ['Knight\'s Minne V'] = 'Minne5',
    ['Knight\'s Minne IV'] = 'Minne4',

    -- Ballad songs
    ['Mage\'s Ballad III'] = 'Ballad3',
    ['Mage\'s Ballad II'] = 'Ballad2',
    ['Mage\'s Ballad'] = 'Ballad1',

    -- Other songs
    ['Adventurer\'s Dirge'] = 'Dirge',
    ['Herculean Etude'] = 'STR',  -- STR Etude
    ['Uncanny Etude'] = 'DEX',    -- DEX Etude
    ['Vital Etude'] = 'VIT',      -- VIT Etude
    ['Swift Etude'] = 'AGI',      -- AGI Etude
    ['Sage Etude'] = 'INT',       -- INT Etude
    ['Logical Etude'] = 'MND',    -- MND Etude
    ['Bewitching Etude'] = 'CHR', -- CHR Etude
    ['Sentinel\'s Scherzo'] = 'Scherzo',
    ['Fire Carol'] = 'Carol',
    ['Ice Carol'] = 'Carol',
    ['Wind Carol'] = 'Carol',
    ['Earth Carol'] = 'Carol',
    ['Lightning Carol'] = 'Carol',
    ['Water Carol'] = 'Carol',
    ['Light Carol'] = 'Carol',
    ['Dark Carol'] = 'Carol',
    ['Foe Sirvente'] = 'Sirvente',

    -- Dummy songs
    ['Gold Capriccio'] = 'GoldCap',
    ['Goblin Gavotte'] = 'Gavotte',
    ['Fowl Aubade'] = 'Aubade',
    ['Herb Pastoral'] = 'Pastoral',
    ['Shining Fantasia'] = 'Fantasia'
}

---============================================================================
--- ABILITY AUTOMATION
---============================================================================
--- Control automatic ability usage

BRD_CONFIG.AUTO_ABILITIES = {
    -- Use Marcato automatically for Honor March
    marcato_for_honor_march = true,

    -- Enable Nightingale + Troubadour combo command
    nightingale_troubadour = true,

    -- Use Clarion Call automatically when available for 5+ songs
    auto_clarion_call = false, -- Set to true to auto-use

    -- Note: Marcato is automatically disabled when Soul Voice is active
    -- (they don't stack - Soul Voice overrides Marcato)
}

---============================================================================
--- SONG REFINE SYSTEM
---============================================================================
--- Automatically downgrades songs to lower tiers if higher tier is on cooldown
--- Useful for Lullaby and Threnody where tier II has longer recast

BRD_CONFIG.SONG_REFINE = {
    -- Enable/disable the refine system
    enabled = true,

    -- Song tier replacements
    tiers = {
        -- Lullaby tiers
        ['Horde Lullaby'] = {
            ['II'] = { replace = '', name = 'Horde Lullaby' }
        },
        ['Foe Lullaby'] = {
            ['II'] = { replace = '', name = 'Foe Lullaby' }
        },

        -- Threnody tiers (all elements)
        ['Fire Threnody'] = {
            ['II'] = { replace = '', name = 'Fire Threnody' }
        },
        ['Ice Threnody'] = {
            ['II'] = { replace = '', name = 'Ice Threnody' }
        },
        ['Wind Threnody'] = {
            ['II'] = { replace = '', name = 'Wind Threnody' }
        },
        ['Earth Threnody'] = {
            ['II'] = { replace = '', name = 'Earth Threnody' }
        },
        ['Lightning Threnody'] = {
            ['II'] = { replace = '', name = 'Lightning Threnody' }
        },
        ['Water Threnody'] = {
            ['II'] = { replace = '', name = 'Water Threnody' }
        },
        ['Light Threnody'] = {
            ['II'] = { replace = '', name = 'Light Threnody' }
        },
        ['Dark Threnody'] = {
            ['II'] = { replace = '', name = 'Dark Threnody' }
        }
    }
}

-- Legacy support for old refine system
if BRD_CONFIG.SONG_REFINE.enabled then
    -- Keep the tiers structure for refine system
    BRD_CONFIG.SONG_REFINE = BRD_CONFIG.SONG_REFINE.tiers
else
    -- Disable refine system with empty table
    BRD_CONFIG.SONG_REFINE = {}
end

---============================================================================
--- DEBUG SETTINGS
---============================================================================
--- Enable various debug outputs for troubleshooting

BRD_CONFIG.DEBUG = {
    -- Master debug switch
    enabled = false,

    -- Specific debug categories
    show_song_delays = false,       -- Display delay calculations
    show_marcato_detection = false, -- Show Marcato availability checks
    show_pack_selection = false,    -- Display song pack selection logic
    show_buff_detection = false,    -- Show buff counting/detection
    show_recast_times = false       -- Display ability recast times
}

---============================================================================
--- EXPORT MODULE
---============================================================================

return BRD_CONFIG
