---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Equipment Sets - Ultimate Tanking Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Paladin tank role with optimized
---   defensive and enmity gear across all combat situations.
---   Features:
---     • Ultimate tanking systems (PDT/MDT cap optimization)
---     • Enmity maximization with survivability balance
---     • Weapon-specific configurations (Burtgang, Naegling, Shining One, Malevo)
---     • Shield optimization per situation (Duban PDT, Aegis MDT, Priwen Phalanx)
---     • Cure set automation (CureSelf vs CureOther variants)
---     • Phalanx potency vs SIRD variants (XP mode support)
---     • Blue Magic spell support (SIRD + Enmity for AOE rotation)
---     • Weaponskill optimization (Savage Blade, Sanguine Blade, etc.)
---     • Fast Cast + SIRD hybrid gear for spell safety
---     • Movement speed optimization (Adoulin city support)
---     • Rudianos capes for all situations (5 variants: tank, FCSIRD, STP, WS, cure)
---    Architecture:
---     • Equipment definitions (Rudianos capes, Jumalik augments, wardrobe rings)
---     • Weapon sets (main weapons + shields)
---     • Idle sets (Normal, PDT, MDT, Town, XP)
---     • Engaged sets (Normal, PDT, MDT, Melee XP)
---     • Precast sets (Job abilities, Fast Cast, Weaponskills with TP bonus)
---     • Midcast sets (Enmity, SIRD+Enmity, Phalanx, Cure, Enhancing Magic)
---     • Movement sets (Base speed, Adoulin city boost)
---     • Buff sets (Doom resistance)
---   @file    jobs/pld/sets/pld_sets.lua
---   @author  Tetsouo
---   @version 3.1 - Standardized Organization
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════
sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Rudianos Capes
Rudianos = {
    tank = {
        name = "Rudianos's Mantle",
        priority = 3,
        augments = {
            'VIT+20',
            'Eva.+20 /Mag. Eva.+20',
            'Mag. Evasion+10',
            'Enmity+10',
            'Phys. dmg. taken-10%'
        }
    },
    FCSIRD = {
        name = "Rudianos's Mantle",
        priority = 12, -- Used in precast.FC (delta idle=+80 GAIN, equip early)
        augments = {
            'HP+60',
            'HP+20',
            '"Fast Cast"+10',
            'Spell interruption rate down-10%'
        }
    },
    STP = {
        name = "Rudianos's Mantle",
        priority = 0,
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'Accuracy+10',
            '"Store TP"+10',
            'Occ. inc. resist. to stat. ailments+10'
        }
    },
    WS = {
        name = "Rudianos's Mantle",
        priority = 0,
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+10',
            'Weapon skill damage +10%',
            'Phys. dmg. taken-10%'
        }
    },
    cure = {
        name = "Rudianos's Mantle",
        priority = 3, -- Used in CureOther (delta FC=-80, equip late to delay HP loss)
        augments = {
            'MND+20',
            'Eva.+20 /Mag. Eva.+20',
            'MND+10',
            '"Cure" potency +10%',
            'Phys. dmg. taken-10%'
        }
    },
    EnmitySIRD = {
        name = "Rudianos's Mantle",
        priority = 3, -- Used in SIRDEnmity (delta FC=-80, equip late to delay HP loss)
        augments = {
            'VIT+20',
            'Eva.+20 /Mag. Eva.+20',
            'VIT+10',
            'Enmity+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- • Jumalik Gear
JumalikHead = {
    name = 'Jumalik Helm',
    priority = 0,
    augments = {
        'MND+10',
        '"Mag.Atk.Bns."+15',
        'Magic burst dmg.+10%',
        '"Refresh"+1'
    }
}
JumalikBody = {
    name = 'Jumalik Mail',
    priority = 0,
    augments = {'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2'}
}

-- • Rings (Wardrobe-specific)
ChirichRing1 = {name = 'Chirich Ring +1', priority = 0, bag = 'wardrobe 1'}
ChirichRing2 = {name = 'Chirich Ring +1', priority = 0, bag = 'wardrobe 2'}
StikiRing1 = {name = 'Stikini Ring +1', priority = 0, bag = 'wardrobe 1'}
StikiRing2 = {name = 'Stikini Ring +1', priority = 0, bag = 'wardrobe 2'}
Moonlight1 = {name = 'Moonlight Ring', priority = 13, bag = 'wardrobe 1'}
Moonlight2 = {name = 'Moonlight Ring', priority = 12, bag = 'wardrobe 2'}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Main Weapons
sets.Burtgang = {main = 'Burtgang'}
sets.BurtgangKC = {main = 'Burtgang', sub = 'Kraken Club'} -- PLD/DNC multi-attack build
sets.Shining = {main = 'Shining One'} -- Polearm (uses Alber Strap grip)
sets.Naegling = {main = 'Naegling'}
sets.Malevo = {
    main = {
        name = 'Malevolence',
        augments = {
            'INT+10',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+8',
            '"Fast Cast"+5'
        }
    }
}

-- • Sub Weapons
sets.Duban = {sub = 'Duban'}
sets.Aegis = {sub = 'Aegis'}
sets.Alber = {sub = 'Alber Strap'}
sets['Blurred Shield +1'] = {sub = 'Blurred Shield +1'}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle Set (Foundation for all idle variants)
sets.idle = {
    ammo = {name = 'Staunch Tathlum +1', priority = 8}, -- delta Phx=0
    head = {name = 'Chev. Armet +3', priority = 12}, -- delta Phx=+145
    body = {name = 'Adamantite Armor', priority = 13}, -- delta Phx=+182 (biggest GAIN, equip FIRST)
    hands = {name = 'Chev. Gauntlets +3', priority = 2}, -- delta Phx=-175 (LOSS, equip late)
    legs = {name = 'Chev. Cuisses +3', priority = 9}, -- delta Phx=+13
    feet = {name = 'Chev. Sabatons +3', priority = 1}, -- delta Phx=-175 (biggest LOSS, equip LAST)
    neck = {name = 'Kgt. Beads +2', priority = 10}, -- delta Phx=+60
    waist = {name = 'Flume Belt +1', priority = 7}, -- delta Phx=0
    left_ear = {name = 'Tuisto Earring', priority = 6}, -- delta Phx=0 (same item)
    right_ear = {name = 'Odnowa Earring +1', priority = 11}, -- delta Phx=+110
    left_ring = {name = 'Fortified Ring', priority = 5}, -- delta Phx=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 4}, -- delta Phx=0 (same item)
    back = Rudianos.tank -- delta Phx=0, priority via def (3)
}

-- • PDT Idle (Physical Defense)
sets.idle.PDT =
    set_combine(
    sets.idle,
    {
        sub = 'Duban' -- PDT shield
    }
)

-- • MDT Idle (Magical Defense)
sets.idle.MDT = {
    ammo = 'Staunch Tathlum +1',
    head = {name = "Sakpata's Helm", augments = {'Path: A'}},
    body = {name = "Sakpata's Plate", augments = {'Path: A'}},
    hands = {name = "Sakpata's Gauntlets", augments = {'Path: A'}},
    legs = {name = "Sakpata's Cuisses", augments = {'Path: A'}},
    feet = {name = "Sakpata's Leggings", augments = {'Path: A'}},
    neck = 'Moonlight Necklace',
    waist = "Carrier's Sash",
    left_ear = 'Tuisto Earring',
    right_ear = 'Eabani Earring',
    left_ring = 'Purity Ring',
    right_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    back = {
        name = "Rudianos's Mantle",
        augments = {
            'VIT+20',
            'Eva.+20 /Mag. Eva.+20',
            'Mag. Evasion+10',
            'Enmity+10',
            'Phys. dmg. taken-10%'
        }
    },
    sub = 'Aegis' -- MDT shield
}

-- • Normal Idle (Balanced)
sets.idleNormal =
    set_combine(
    sets.idle,
    {
        head = {name = 'Chev. Armet +3', priority = 14},
        body = {name = 'Adamantite Armor', priority = 15},
        legs = {name = 'Chev. Cuisses +3', priority = 16},
        neck = {name = 'Kgt. Beads +2', priority = 17},
        waist = {name = 'Creed Baudrier', priority = 18},
        left_ring = Moonlight1,
        right_ring = Moonlight2
    }
)

-- • XP Idle (Experience points focus)
sets.idleXp =
    set_combine(
    sets.idle,
    {
        main = 'Burtgang',
        sub = 'Duban',
        body = {name = 'Chev. Cuirass +3', priority = 16}
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged Set
sets.engaged =
    set_combine(
    sets.idleNormal,
    {
        ammo = {name = 'Staunch Tathlum +1', priority = 0}, -- DT -3%, Status resistance +11, Spell interruption rate -11%
        head = {name = 'Chev. Armet +3', priority = 12}, -- HP+145, DT -11%, Converts 8% of physical damage to MP
        body = {name = 'Adamantite Armor', priority = 13}, -- HP+182, DT -20%, Very high DEF
        hands = {name = 'Chev. Gauntlets +3', priority = 8}, -- HP+64, DT -11%, Shield block bonus
        legs = {name = 'Chev. Cuisses +3', priority = 10}, -- HP+127, DT -13%, Enmity+14
        feet = {name = 'Chev. Sabatons +3', priority = 6}, -- HP+52, Completes set bonus for damage absorption
        neck = {name = 'Kgt. Beads +2', priority = 7}, -- HP+60, DT -7%, Enmity+10
        waist = {name = 'Null Belt', priority = 0}, -- Magic defense bonus, no HP gain
        left_ear = {name = 'Odnowa Earring +1', priority = 9}, -- HP+110, DT -3%, MDT -2%
        right_ear = {name = 'Chev. Earring +1', priority = 0}, -- DT -4%, Cure potency +11%
        left_ring = {name = 'Fortified Ring', priority = 5}, -- MDT -5%, Reduces enemy critical hit rate
        right_ring = {name = 'Gelatinous Ring +1', priority = 11}, -- HP+100, PDT -7%, VIT+15
        back = Rudianos.tank -- PDT -10%, VIT+20, Enmity+10
    }
)

-- • PDT Engaged
sets.engaged.PDT =
    set_combine(
    sets.engaged,
    {
        sub = 'Duban' -- PDT shield for engaged
    }
)

-- • MDT Engaged
sets.engaged.MDT = sets.idle.MDT -- Already has Aegis shield

-- • Kraken Club Specialized (PLD/DNC multi-attack build)
-- Used when BurtgangKC weapon set is active
-- Focuses on Store TP reduction to leverage Kraken Club's multi-attack proc rate
sets.engaged.BurtgangKC =
    set_combine(
    sets.engaged,
    {
        ammo = 'Aurgelmir Orb +1',
        head = "Sulevia's Mask +2",
        body = 'Hjarrandi Breast.',
        hands = "Sakpata's Gauntlets",
        legs = 'Chev. Cuisses +3',
        feet = 'Chev. Sabatons +3',
        neck = 'Null Loop',
        waist = 'Null Belt',
        left_ear = 'Crep. Earring',
        right_ear = 'Dedition Earring',
        left_ring = 'Chirich Ring +1',
        right_ring = 'Chirich Ring +1',
        back = Rudianos.STP
    }
)

-- • Melee XP
sets.meleeXp =
    set_combine(
    sets.idleXp,
    {
        main = {
            name = 'Malevolence',
            augments = {
                'INT+10',
                'Mag. Acc.+10',
                '"Mag.Atk.Bns."+8',
                '"Fast Cast"+5'
            }
        }
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}

-- • Full Enmity Set (Base for all enmity JAs)
sets.FullEnmity = {
    ammo = {name = 'Iron Gobbet', priority = 8}, -- delta FC=0
    head = {name = 'Loess Barbuta +1', priority = 11}, -- delta FC=+67
    neck = {name = 'Moonlight Necklace', priority = 7}, -- delta FC=0
    left_ear = {name = 'Trux Earring', priority = 10}, -- delta FC=+40
    right_ear = {name = 'Odnowa Earring +1', priority = 12}, -- delta FC=+110
    body = {name = 'Souv. Cuirass +1', priority = 1}, -- delta FC=-93 (biggest LOSS)
    hands = {name = 'Souv. Handsch. +1', priority = 13}, -- delta FC=+214 (biggest GAIN)
    left_ring = {name = 'Apeile Ring +1', priority = 6}, -- delta FC=0
    right_ring = {name = 'Apeile Ring', priority = 5}, -- delta FC=0
    back = Rudianos.tank, -- delta FC=-80, priority via def (3)
    waist = {name = 'Creed Baudrier', priority = 9}, -- delta FC=+40
    legs = {name = 'Cab. Breeches +4', priority = 2}, -- delta FC=-82
    feet = {name = "Chevalier's Sabatons +3", priority = 4} -- delta FC=0
    -- Gear Enmity 155
    -- Crusade Enmity 185
}

-- • Job Abilities
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] =
    set_combine(
    sets.FullEnmity,
    {
        feet = {name = "Chevalier's Sabatons +3"}
    }
)
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Vallation'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Valiance'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Pflug'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, {body = {name = 'Cab. Surcoat +3'}})
sets.precast.JA['Invincible'] =
    set_combine(
    sets.FullEnmity,
    {
        legs = {name = 'Caballarius Breeches +4'}
    }
)
sets.precast.JA['Holy Circle'] =
    set_combine(
    sets.FullEnmity,
    {
        feet = {name = 'Rev. Leggings +4'}
    }
)
sets.precast.JA['Shield Bash'] =
    set_combine(
    sets.FullEnmity,
    {
        hands = {name = 'Cab. Gauntlets +4'}
    }
)
sets.precast.JA['Sentinel'] = set_combine(sets.FullEnmity, {feet = {name = 'Cab. Leggings +4'}})
sets.precast.JA['Rampart'] = set_combine(sets.FullEnmity, {head = {name = 'Cab. Coronet +4'}})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.FC = {
    ammo = {name = 'Sapience Orb', priority = 10}, -- delta idle=0
    head = {name = 'Carmine Mask +1', priority = 3}, -- delta idle=-107 LOSS
    neck = {name = "Orunmila's Torque", priority = 5}, -- delta idle=-60
    left_ear = {name = "Enchanter's Earring +1", priority = 1}, -- delta idle=-150 (biggest LOSS)
    right_ear = {name = 'Loquac. Earring', priority = 2}, -- delta idle=-110
    body = {name = 'Reverence Surcoat +4', priority = 13}, -- delta idle=+82 (biggest GAIN, equip FIRST)
    hands = {name = 'Leyline Gloves', priority = 6}, -- delta idle=-39
    left_ring = {name = 'Kishar Ring', priority = 7}, -- delta idle=0
    right_ring = {name = 'Prolix Ring', priority = 4}, -- delta idle=-100
    back = Rudianos.FCSIRD, -- delta idle=+80 GAIN, priority via def (12)
    waist = {name = 'Platinum Moogle Belt', priority = 8}, -- delta idle=0
    legs = {name = 'Sworn Brais', priority = 11}, -- delta idle=+37 GAIN
    feet = {name = "Chevalier's Sabatons +3", priority = 9} -- delta idle=0
}

-- • Cure Self FC (Cure III/IV self-target only - low HP to avoid overcure waste)
sets.precast.FC.CureSelf =
    set_combine(
    sets.precast.FC,
    {
        body = {
            name = 'Odyss. Chestplate',
            augments = {'MND+3', '"Fast Cast"+6', 'Mag. Acc.+5 "Mag.Atk.Bns."+5'},
            priority = 13 -- gap idle=182 (biggest, vs Adamantite HP+182)
        },
        legs = {name = 'Enif Cosciales', priority = 9} -- gap idle=87 vs Chev. Cuisses HP+127
    }
)

sets.precast.FC['Healing Magic'] = sets.precast.FC
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Phalanx'] = sets.precast.FC
sets.precast.FC['Crusade'] = sets.precast.FC
sets.precast.FC['Cocoon'] = sets.precast.FC
sets.precast.FC['Flash'] = sets.precast.FC
sets.precast.FC['Banish'] = sets.precast.FC
sets.precast.FC['Banishga'] = sets.precast.FC
sets.precast.FC['Blank Gaze'] = sets.precast.FC
sets.precast.FC['Jettatura'] = sets.precast.FC
sets.precast.FC['Sheep Song'] = sets.precast.FC
sets.precast.FC['Geist Wall'] = sets.precast.FC
sets.precast.FC['Cold Wave'] = sets.precast.FC
sets.precast.FC['Stinking Gas'] = sets.precast.FC
sets.precast.FC['Frightful Roar'] = sets.precast.FC
sets.precast.FC['Metallic Body'] = sets.precast.FC
sets.precast.FC['Foil'] = sets.precast.FC

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- Physical Weaponskills
-- ───────────────────────────────────────────────────────────────────────────

-- • Base Weaponskill Set
sets.precast.WS = {
    ammo = 'Crepuscular Pebble',
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sulevia's Leggings +2",
    neck = "Knight's Bead Necklace +2",
    waist = {name = 'Sailfi Belt +1', priority = 3},
    left_ear = 'Ishvara Earring',
    right_ear = 'Thrud Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Sroda Ring',
    back = Rudianos.WS
}

-- • Requiescat
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})

-- • Chant du Cygne
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})

-- • Atonement (Enmity WS)
sets.precast.WS['Atonement'] = sets.FullEnmity

-- • Savage Blade
sets.precast.WS['Savage Blade'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = {name = "Oshasha's Treatise"},
        head = {name = 'Nyame Helm'},
        body = {name = 'Nyame Mail'},
        hands = {name = 'Nyame Gauntlets'},
        legs = {name = 'Nyame Flanchard'},
        feet = {name = 'Nyame Sollerets'},
        neck = {name = "Knight's Bead Necklace +2"},
        waist = {name = 'Sailfi Belt +1'},
        left_ear = {name = 'Tuisto Earring'},
        right_ear = {name = 'Thrud Earring'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Regal Ring'},
        back = Rudianos.WS
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- Magic Weaponskills
-- ───────────────────────────────────────────────────────────────────────────

-- • Sanguine Blade (Dark Magic WS)
sets.precast.WS['Sanguine Blade'] =
    set_combine(
    sets.precast.WS,
    {
        head = {name = 'Nyame Helm'},
        body = {name = 'Nyame Mail'},
        hands = {name = 'Nyame Gauntlets'},
        legs = {name = 'Nyame Flanchard'},
        feet = {name = 'Nyame Sollerets'},
        neck = {name = 'Sanctity Necklace'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Friomisi Earring'},
        right_ring = {name = 'Regal Ring'},
        back = {name = 'Toro Cape'}
    }
)

-- • Aeolian Edge (Wind Magic WS)
sets.precast.WS['Aeolian Edge'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = {name = "Oshasha's Treatise"},
        head = {name = 'Nyame Helm'},
        body = {name = 'Nyame Mail'},
        hands = {name = 'Nyame Gauntlets'},
        legs = {name = 'Nyame Flanchard'},
        feet = {name = 'Nyame Sollerets'},
        neck = {name = 'Baetyl Pendant'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Crematio Earring'},
        right_ear = {name = 'Friomisi Earring'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Murky Ring'},
        back = {name = 'Moonlight Cape'}
    }
)

-- • Circle Blade (Magic WS)
sets.precast.WS['Circle Blade'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = {name = 'Staunch Tathlum +1'},
        head = {name = 'Nyame Helm'},
        body = {name = 'Nyame Mail'},
        hands = {name = 'Nyame Gauntlets'},
        legs = {name = 'Nyame Flanchard'},
        feet = {name = 'Nyame Sollerets'},
        neck = {name = 'Sibyl Scarf'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Sortiarius Earring'},
        right_ear = {name = 'Chev. Earring +1'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Regal Ring'},
        back = {name = 'Toro Cape'}
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- TP Bonus Adjustments
-- ───────────────────────────────────────────────────────────────────────────

-- • TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = 'Moonshade Earring' -- TP Bonus +250
}

-- • TPBonus Variants
sets.precast.WS['Savage Blade'].TPBonus = set_combine(sets.precast.WS['Savage Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Sanguine Blade'].TPBonus = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Aeolian Edge'].TPBonus = set_combine(sets.precast.WS['Aeolian Edge'], sets.precast.WS.TPBonus)
sets.precast.WS['Circle Blade'].TPBonus = set_combine(sets.precast.WS['Circle Blade'], sets.precast.WS.TPBonus)

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- Enmity Sets
-- ───────────────────────────────────────────────────────────────────────────

sets.midcast = {}

-- • Enmity Midcast
sets.midcast.Enmity = sets.FullEnmity

-- • SIRD + Enmity Midcast (Spell Interruption Rate Down)
sets.midcast.SIRDEnmity = {
    ammo = {name = 'Staunch Tathlum +1', priority = 8}, -- delta FC=0
    head = {name = 'Loess Barbuta +1', augments = {'Path: A'}, priority = 9}, -- delta FC=+67
    body = {name = 'Chev. Cuirass +3', priority = 1}, -- delta FC=-113 (biggest LOSS, equip LAST)
    hands = {
        name = 'Souv. Handsch. +1',
        augments = {
            'HP+105',
            'Enmity+9',
            'Potency of "Cure" effect received +15%'
        },
        priority = 13 -- delta FC=+214 (biggest GAIN, equip FIRST)
    },
    legs = {name = 'Cab. Breeches +4', priority = 2}, -- delta FC=-82
    feet = {
        name = 'Odyssean Greaves',
        augments = {'Attack+19', 'Enmity+8', 'Accuracy+8'},
        priority = 4 -- delta FC=-32
    },
    neck = {name = 'Moonlight Necklace', priority = 7}, -- delta FC=0
    waist = {name = 'Audumbla Sash', priority = 6}, -- delta FC=0
    left_ear = {name = 'Alabaster Earring', priority = 11}, -- delta FC=+100
    right_ear = {name = 'Odnowa Earring +1', priority = 12}, -- delta FC=+110
    left_ring = {name = 'Apeile Ring +1', priority = 5}, -- delta FC=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 10}, -- delta FC=+100
    back = Rudianos.EnmitySIRD -- delta FC=-80, priority via def (3)
}
-- Gear Enmity 123
-- Crusade Enmity 153
-- SIRD 106%

-- ───────────────────────────────────────────────────────────────────────────
-- Phalanx Sets
-- ───────────────────────────────────────────────────────────────────────────

-- • Phalanx Potency Set
sets.midcast.PhalanxPotency = {
    --[[ main = {name = "Sakpata's Sword"},
    sub = 'Priwen', ]]
    ammo = {name = 'Aurgelmir Orb +1', priority = 9}, -- delta FC=0
    head = {
        name = 'Odyssean Helm',
        augments = {
            'AGI+11',
            'Accuracy+18',
            'Phalanx +5',
            'Mag. Acc.+17 "Mag.Atk.Bns."+17'
        },
        priority = 4 -- delta FC=-38
    },
    neck = {name = 'Melic Torque', priority = 8}, -- delta FC=0
    left_ear = {name = 'Tuisto Earring', priority = 11}, -- delta FC=+150
    right_ear = {name = 'Mimir Earring', priority = 6}, -- delta FC=0
    body = {
        name = 'Odyss. Chestplate',
        augments = {
            'Pet: Mag. Acc.+27',
            'Rng.Atk.+3',
            'Phalanx +5',
            'Accuracy+1 Attack+1',
            'Mag. Acc.+4 "Mag.Atk.Bns."+4'
        },
        priority = 1 -- delta FC=-264 (biggest LOSS, equip LAST)
    },
    hands = {name = 'Souv. Handsch. +1', priority = 13}, -- delta FC=+214 (biggest GAIN, equip FIRST)
    left_ring = {name = 'Apeile Ring +1', priority = 5}, -- delta FC=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 10}, -- delta FC=+100
    back = {name = 'Weard Mantle', priority = 2}, -- delta FC=-80
    waist = {name = 'Flume Belt +1', priority = 7}, -- delta FC=0
    legs = {name = "Sakpata's Cuisses", priority = 3}, -- delta FC=-50
    feet = {name = 'Souveran Schuhs +1', priority = 12} -- delta FC=+175 GAIN
}

-- • SIRD Phalanx
sets.midcast.SIRDPhalanx = {
    --[[ main = {name = "Sakpata's Sword"},
    sub = 'Priwen', ]]
    ammo = {name = 'Staunch Tathlum +1'},
    head = {name = 'Souveran Schaller +1'},
    body = {name = "Chevalier's Cuirass +3"},
    hands = {name = 'Souv. Handsch. +1'},
    legs = {name = "Sakpata's Cuisses"},
    feet = {
        name = 'Odyssean Greaves',
        augments = {
            '"Fast Cast"+2',
            'STR+7',
            'Phalanx +5',
            'Accuracy+14 Attack+14',
            'Mag. Acc.+10 "Mag.Atk.Bns."+10'
        }
    },
    neck = {name = 'Moonlight Necklace'},
    waist = {name = 'Audumbla Sash'},
    left_ear = {name = 'Tuisto Earring'},
    right_ear = {name = 'Mimir Earring'},
    left_ring = {name = 'Gelatinous Ring +1'},
    right_ring = StikiRing1,
    back = {
        name = 'Weard Mantle',
        priority = 0,
        augments = {'VIT+4', 'Phalanx +5'}
    }
}

-- ───────────────────────────────────────────────────────────────────────────
-- Enhancing Magic
-- ───────────────────────────────────────────────────────────────────────────

-- • Enlight
sets.midcast['Enlight'] =
    set_combine(
    sets.midcast.SIRDEnmity,
    {
        head = JumalikHead, -- Refresh 1
        body = {name = 'Reverence Surcoat +4'},
        hands = {name = 'Eschite Gauntlets'},
        waist = {name = 'Asklepian Belt'},
        back = {name = 'Moonlight Cape', priority = 16},
        left_ear = {name = "Knight's Earring"}
    }
)

-- • Enhancing Magic
sets.midcast['Enhancing Magic'] =
    set_combine(
    sets.midcast.SIRDEnmity,
    {
        body = {name = 'Shabti Cuirass', priority = 1}
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- Healing Magic (Cure Sets)
-- ───────────────────────────────────────────────────────────────────────────

-- • Cure Base Set
sets.Cure = {
    ammo = {name = 'Staunch Tathlum +1', priority = 1},
    head = {name = 'Souv. Schaller +1', priority = 8},
    left_ear = {name = 'Tuisto Earring', priority = 10},
    right_ear = {name = 'Chev. Earring +1', priority = 0}, -- MUST be right_ear
    hands = {name = 'Regal Gauntlets', priority = 7},
    back = {name = 'Moonlight Cape', priority = 12},
    legs = {name = "Founder's Hose", priority = 0},
    feet = {name = 'Odyssean Greaves', priority = 5}
}

-- • Cure Self (PDT/Survivability focused)
sets.midcast.CureSelf =
    set_combine(
    sets.Cure,
    {
        waist = {name = 'Plat. Mog. Belt', priority = 6}, -- delta FC=0
        head = {name = 'Souv. Schaller +1', priority = 8}, -- delta FC=+40
        back = {name = 'Moonlight Cape', priority = 13}, -- delta FC=+195 (biggest GAIN)
        hands = {name = 'Regal Gauntlets', priority = 4}, -- delta FC=-25
        neck = {name = 'Unmoving Collar +1', priority = 9}, -- delta FC=+65
        body = {name = 'Souveran Cuirass +1', priority = 2}, -- delta FC=-93
        left_ear = {name = 'Tuisto Earring', priority = 12}, -- delta FC=+150
        right_ring = {name = 'Gelatinous Ring +1', priority = 10}, -- delta FC=+100
        left_ring = {name = 'Moonlight Ring', priority = 11}, -- delta FC=+110
        feet = {name = 'Odyssean Greaves', priority = 3}, -- delta FC=-32
        legs = {name = "Founder's Hose", priority = 1}, -- delta FC=-142 (biggest LOSS)
        ammo = {name = 'Staunch Tathlum +1', priority = 7}, -- delta FC=0
        right_ear = {name = 'Chev. Earring +1', priority = 5} -- MUST be right_ear, delta FC=0
    }
)

-- • Cure Other (Cure Potency focused)
sets.midcast.CureOther =
    set_combine(
    sets.Cure,
    {
        head = {name = 'Souv. Schaller +1', priority = 12}, -- delta FC=+40
        body = {name = 'Souveran Cuirass +1', priority = 2}, -- delta FC=-93
        left_ear = {name = 'Tuisto Earring', priority = 13}, -- delta FC=+150 (biggest GAIN)
        hands = {name = "Chevalier's Gauntlets +3", priority = 11}, -- delta FC=+39
        legs = {name = "Founder's Hose", priority = 1}, -- delta FC=-142 (biggest LOSS)
        neck = {name = 'Sacro Gorget', priority = 9}, -- delta FC=0
        feet = {name = 'Odyssean Greaves', priority = 4}, -- delta FC=-32
        waist = {name = 'Audumbla Sash', priority = 8}, -- delta FC=0
        ammo = {name = 'Staunch Tathlum +1', priority = 10}, -- delta FC=0
        right_ear = {name = 'Chev. Earring +1', priority = 7}, -- MUST be right_ear, delta FC=0
        right_ring = {name = 'Apeile Ring +1', priority = 5}, -- delta FC=0
        left_ring = {name = 'Apeile Ring +1', priority = 6}, -- delta FC=0
        back = Rudianos.cure -- delta FC=-80, priority via def (3)
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- Blue Magic (Subjob spells)
-- ───────────────────────────────────────────────────────────────────────────

-- • Blue Magic Spells
sets.midcast['Cocoon'] = sets.midcast.SIRDEnmity
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity
sets.midcast['Sheep Song'] = sets.midcast.SIRDEnmity
sets.midcast['Frightful Roar'] = sets.midcast.SIRDEnmity
sets.midcast['Cold Wave'] = sets.midcast.SIRDEnmity
sets.midcast['Stinking Gas'] = sets.midcast.SIRDEnmity
sets.midcast['Blank Gaze'] = sets.midcast.SIRDEnmity

-- ───────────────────────────────────────────────────────────────────────────
-- PLD Specific Spells (Divine & Enhancing)
-- ───────────────────────────────────────────────────────────────────────────

-- • Divine Magic
sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.midcast.SIRDEnmity

-- • PLD Enhancing Magic
sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
sets.midcast['Crusade'] = sets.FullEnmity
sets.midcast['Reprisal'] = sets.midcast['Enhancing Magic']
sets.midcast['Protect'] = sets.midcast['Enhancing Magic']
sets.midcast['Shell'] = sets.midcast['Enhancing Magic']
sets.midcast['Refresh'] = sets.midcast.SIRDEnmity
sets.midcast['Haste'] = sets.midcast.SIRDEnmity

-- ───────────────────────────────────────────────────────────────────────────
-- RUN Subjob Spells
-- ───────────────────────────────────────────────────────────────────────────

-- • RUN Enhancing Magic
sets.midcast['Foil'] = sets.midcast.SIRDEnmity

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    legs = 'Carmine Cuisses +1' -- Common item for speed
}

-- • Town Idle (Movement speed)
sets.idle.Town = set_combine(sets.idle.PDT, sets.MoveSpeed)

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin =
    set_combine(
    sets.MoveSpeed,
    {
        body = "Councilor's Garb" -- Speed bonus in Adoulin city
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff.Doom = {
    neck = {name = "Nicander's Necklace"}, -- Reduces Doom effects
    left_ring = {name = 'Purity Ring'}, -- Additional Doom resistance
    waist = {name = 'Gishdubar Sash'} -- Enhances Doom recovery effects
}
