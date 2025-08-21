---============================================================================
--- FFXI GearSwap BRD Buff ID Reference System
---============================================================================
--- Complete reference system for all BRD song buff IDs.
--- Enables precise counting of active songs per family by analyzing
--- network packets and counting buff ID occurrences.
---
--- @file jobs/brd/modules/BRD_BUFF_IDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-17
--- @requires Windower FFXI, GearSwap addon
---============================================================================

local BRD_BUFF_IDS = {}

--- Mapping complet des buff IDs par famille de songs
--- Basé sur les données de spells.lua et les tests en jeu
BRD_BUFF_IDS.FAMILIES = {
    -- Status ID 192 - Foe Requiem family
    REQUIEM = {
        status_id = 192,
        songs = {
            "Foe Requiem",
            "Foe Requiem II",
            "Foe Requiem III",
            "Foe Requiem IV",
            "Foe Requiem V",
            "Foe Requiem VI",
            "Foe Requiem VII",
            "Foe Requiem VIII"
        }
    },

    -- Status ID 2 - Lullaby family
    LULLABY = {
        status_id = 2,
        songs = {
            "Foe Lullaby",
            "Foe Lullaby II",
            "Horde Lullaby",
            "Horde Lullaby II"
        }
    },

    -- Status ID 195 - Army's Paeon family
    PAEON = {
        status_id = 195,
        songs = {
            "Army's Paeon",
            "Army's Paeon II",
            "Army's Paeon III",
            "Army's Paeon IV",
            "Army's Paeon V",
            "Army's Paeon VI",
            "Army's Paeon VII",
            "Army's Paeon VIII"
        }
    },

    -- Status ID 196 - Mage's Ballad family
    BALLAD = {
        status_id = 196,
        songs = {
            "Mage's Ballad",
            "Mage's Ballad II",
            "Mage's Ballad III"
        }
    },

    -- Status ID 197 - Knight's Minne family (confirmé par tests)
    MINNE = {
        status_id = 197,
        songs = {
            "Knight's Minne",
            "Knight's Minne II",
            "Knight's Minne III",
            "Knight's Minne IV",
            "Knight's Minne V"
        }
    },

    -- Status ID 198 - Valor Minuet family
    MINUET = {
        status_id = 198,
        songs = {
            "Valor Minuet",
            "Valor Minuet II",
            "Valor Minuet III",
            "Valor Minuet IV",
            "Valor Minuet V"
        }
    },

    -- Status ID 199 - Madrigal family (confirmé par tests)
    MADRIGAL = {
        status_id = 199,
        songs = {
            "Sword Madrigal",
            "Blade Madrigal"
        }
    },

    -- Status ID 200 - Prelude family
    PRELUDE = {
        status_id = 200,
        songs = {
            "Hunter's Prelude",
            "Archer's Prelude"
        }
    },

    -- Status ID 201 - Mambo family
    MAMBO = {
        status_id = 201,
        songs = {
            "Sheepfoe Mambo",
            "Dragonfoe Mambo"
        }
    },

    -- Status ID 202 - Fowl Aubade (unique)
    AUBADE = {
        status_id = 202,
        songs = {
            "Fowl Aubade"
        }
    },

    -- Status ID 203 - Herb Pastoral (unique)
    PASTORAL = {
        status_id = 203,
        songs = {
            "Herb Pastoral"
        }
    },

    -- Status ID 204 - Chocobo Hum (unique)
    CHOCOBO_HUM = {
        status_id = 204,
        songs = {
            "Chocobo Hum"
        }
    },

    -- Status ID 205 - Shining Fantasia (unique)
    FANTASIA = {
        status_id = 205,
        songs = {
            "Shining Fantasia"
        }
    },

    -- Status ID 206 - Operetta family
    OPERETTA = {
        status_id = 206,
        songs = {
            "Scop's Operetta",
            "Puppet's Operetta",
            "Jester's Operetta"
        }
    },

    -- Status ID 207 - Gold Capriccio (unique)
    CAPRICCIO = {
        status_id = 207,
        songs = {
            "Gold Capriccio"
        }
    },

    -- Status ID 208 - Devotee Serenade (unique)
    SERENADE = {
        status_id = 208,
        songs = {
            "Devotee Serenade"
        }
    },

    -- Status ID 209 - Warding Round (unique)
    ROUND = {
        status_id = 209,
        songs = {
            "Warding Round"
        }
    },

    -- Status ID 210 - Goblin Gavotte (unique)
    GAVOTTE = {
        status_id = 210,
        songs = {
            "Goblin Gavotte"
        }
    },

    -- Status ID 211 - Cactuar Fugue (unique)
    FUGUE = {
        status_id = 211,
        songs = {
            "Cactuar Fugue"
        }
    },

    -- Status ID 213 - Aria of Passion (unique)
    ARIA = {
        status_id = 213,
        songs = {
            "Aria of Passion"
        }
    },

    -- Status ID 214 - March family (Honor March, Advancing March, Victory March)
    MARCH = {
        status_id = 214,
        songs = {
            "Honor March",
            "Advancing March",
            "Victory March"
        }
    },

    -- Status ID 194 - Elegy family
    ELEGY = {
        status_id = 194,
        songs = {
            "Battlefield Elegy",
            "Carnage Elegy",
            "Massacre Elegy"
        }
    },

    -- Status ID 215 - Etude family
    ETUDE = {
        status_id = 215,
        songs = {
            "Sinewy Etude",     -- STR
            "Dextrous Etude",   -- DEX
            "Vivacious Etude",  -- VIT
            "Quick Etude",      -- AGI
            "Learned Etude",    -- INT
            "Spirited Etude",   -- MND
            "Enchanting Etude", -- CHR
            "Herculean Etude",  -- STR (higher)
            "Uncanny Etude",    -- DEX (higher)
            "Vital Etude",      -- VIT (higher)
            "Swift Etude",      -- AGI (higher)
            "Sage Etude",       -- INT (higher)
            "Logical Etude",    -- MND (higher)
            "Bewitching Etude"  -- CHR (higher)
        }
    },

    -- Status ID 216 - Carol family
    CAROL = {
        status_id = 216,
        songs = {
            "Fire Carol",
            "Ice Carol",
            "Wind Carol",
            "Earth Carol",
            "Lightning Carol",
            "Water Carol",
            "Light Carol",
            "Dark Carol",
            "Fire Carol II",
            "Ice Carol II",
            "Wind Carol II",
            "Earth Carol II",
            "Lightning Carol II",
            "Water Carol II",
            "Light Carol II",
            "Dark Carol II"
        }
    },

    -- Status ID 217 - Threnody family
    THRENODY = {
        status_id = 217,
        songs = {
            "Fire Threnody",
            "Ice Threnody",
            "Wind Threnody",
            "Earth Threnody",
            "Lightning Threnody",
            "Water Threnody",
            "Light Threnody",
            "Dark Threnody"
        }
    },

    -- Status ID 218 - Goddess's Hymnus (unique)
    HYMNUS = {
        status_id = 218,
        songs = {
            "Goddess's Hymnus"
        }
    },

    -- Status ID 219 - Mazurka family
    MAZURKA = {
        status_id = 219,
        songs = {
            "Chocobo Mazurka",
            "Raptor Mazurka"
        }
    },

    -- Status ID 14 - Maiden's Virelai (unique)
    VIRELAI = {
        status_id = 14,
        songs = {
            "Maiden's Virelai"
        }
    },

    -- Status ID 220 - Foe Sirvente (unique)
    SIRVENTE = {
        status_id = 220,
        songs = {
            "Foe Sirvente"
        }
    },

    -- Status ID 221 - Adventurer's Dirge (unique)
    DIRGE = {
        status_id = 221,
        songs = {
            "Adventurer's Dirge"
        }
    },

    -- Status ID 222 - Sentinel's Scherzo (unique)
    SCHERZO = {
        status_id = 222,
        songs = {
            "Sentinel's Scherzo"
        }
    },

    -- Status ID 223 - Pining Nocturne (unique)
    NOCTURNE = {
        status_id = 223,
        songs = {
            "Pining Nocturne"
        }
    }
}

--- Fonction pour compter les songs actives par famille depuis les buff IDs
--- @param buff_ids table Liste des buff IDs actifs (depuis packets)
--- @return table Compteurs par famille de songs
function BRD_BUFF_IDS.count_active_songs(buff_ids)
    if not buff_ids then return {} end

    local song_counts = {}

    -- Compter les occurrences de chaque buff ID
    local buff_occurrences = {}
    for _, buff_id in pairs(buff_ids) do
        buff_occurrences[buff_id] = (buff_occurrences[buff_id] or 0) + 1
    end

    -- Associer les counts aux familles de songs
    for family_name, family_data in pairs(BRD_BUFF_IDS.FAMILIES) do
        local status_id = family_data.status_id
        song_counts[family_name] = buff_occurrences[status_id] or 0
    end

    return song_counts
end

--- Fonction pour obtenir le nombre total de songs actives
--- @param buff_ids table Liste des buff IDs actifs (depuis packets)
--- @return number Nombre total de songs actives
function BRD_BUFF_IDS.get_total_song_count(buff_ids)
    if not buff_ids then return 0 end

    local song_counts = BRD_BUFF_IDS.count_active_songs(buff_ids)
    local total = 0

    for family_name, count in pairs(song_counts) do
        total = total + count
    end

    return total
end

--- Function to display active songs summary
--- @param buff_ids table List of active buff IDs (from packets)
function BRD_BUFF_IDS.display_song_summary(buff_ids)
    local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
    if not success_MessageUtils then
        error("Failed to load utils/messages: " .. tostring(MessageUtils))
    end
    local song_counts = BRD_BUFF_IDS.count_active_songs(buff_ids)
    local total = BRD_BUFF_IDS.get_total_song_count(buff_ids)

    MessageUtils.brd_message("SONGS", "Active Summary", "Total: " .. total .. " songs")

    -- Display families with active songs
    for family_name, count in pairs(song_counts) do
        if count > 0 then
            MessageUtils.brd_message("SONGS", family_name, count .. " song(s)")
        end
    end
end

--- Fonction pour vérifier si on a besoin de refresh la 5ème song
--- @param buff_ids table Liste des buff IDs actifs (depuis packets)
--- @param expected_fifth_song_family string Famille attendue pour la 5ème song
--- @return boolean true si refresh nécessaire
function BRD_BUFF_IDS.needs_fifth_song_refresh(buff_ids, expected_fifth_song_family)
    local song_counts = BRD_BUFF_IDS.count_active_songs(buff_ids)
    local total = BRD_BUFF_IDS.get_total_song_count(buff_ids)

    -- Si on a moins de 5 songs, on peut refresh
    if total < 5 then
        return true
    end

    -- Si on a 5 songs mais pas de la famille attendue, on peut refresh
    if total == 5 and expected_fifth_song_family then
        local expected_count = song_counts[expected_fifth_song_family:upper()] or 0
        return expected_count == 0
    end

    return false
end

return BRD_BUFF_IDS
