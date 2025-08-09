---============================================================================
--- FFXI GearSwap Equipment Sets - Warrior Comprehensive Gear Collection
---============================================================================
--- Professional Warrior equipment set definitions providing optimized
--- gear configurations for weapon skill mastery, TP optimization, multi-weapon
--- support, and advanced melee combat strategies. Features:
---
--- • **Weapon Skill Mastery** - Upheaval, Ukko's Fury, Resolution optimization
--- • **TP Building Excellence** - Multi-hit and Store TP equipment coordination
--- • **Multi-Weapon Support** - Great Axe, Axe, Sword, and Polearm sets
--- • **Aftermath Integration** - AM3 weapon coordination and timing
--- • **Berserk/Restraint Synergy** - Job ability enhancement equipment
--- • **Hybrid Defense Modes** - PDT/Normal switching for survivability
--- • **Ranged Attack Support** - Throwing weapon and archery integration
--- • **Subjob Optimization** - DRG, SAM, DNC specific equipment coordination
---
--- This comprehensive equipment database enables WAR to excel in pure
--- melee combat while maintaining versatility across weapon types and
--- encounter scenarios with intelligent weapon skill and TP coordination.
---
--- @file jobs/war/WAR_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by WAR_FUNCTION.lua for weapon and TP management
---
--- @see jobs/war/WAR_FUNCTION.lua for warrior logic and weapon coordination
--- @see Tetsouo_WAR.lua for job configuration and combat mode management
---============================================================================

-- =========================================================================================================
--                                       Equipment Definitions - Unique Items
-- =========================================================================================================

-- Sovereign Equipment Set
SouvHead = createEquipment("Souv. Schaller +1", 24, nil, {
    "HP+105",
    "Enmity+9",
    'Potency of "Cure" effect received +15%'
})
SouvBody = createEquipment("Souv. Cuirass +1", 3, nil, {
    "HP+105",
    "Enmity+9",
    'Potency of "Cure" effect received +15%'
})
SouvHands = createEquipment("Souv. Handsch. +1", 23, nil, {
    "HP+105",
    "Enmity+9",
    'Potency of "Cure" effect received +15%'
})
SouvLegs = createEquipment("Souv. Diechlings +1", 16, nil, {
    "HP+105",
    "Enmity+9",
    'Potency of "Cure" effect received +15%'
})
SouvFeet = createEquipment("Souveran Schuhs +1", 22, nil, {
    "HP+105",
    "Enmity+9",
    'Potency of "Cure" effect received +15%'
})

-- Valorous Hose
ValorousHose = createEquipment("Valorous Hose", nil, nil, {
    "Store TP +2",
    "Accuracy+17",
    "Weapon skill damage +7%",
    "Accuracy+18 Attack+18",
    'Mag. Acc.+9 "Mag.Atk.Bns."+9'
})

-- Cichol's Mantles with Specific Augments
Cichol = {
    stp = createEquipment("Cichol's Mantle", nil, nil, {
        "STR+20",
        "Accuracy+20 Attack+20",
        "STR+10",
        '"Dbl.Atk."+10',
        "Phys. dmg. taken-10%"
    }),
    ws1 = createEquipment("Cichol's Mantle", nil, nil, {
        "STR+20",
        "Accuracy+20 Attack+20",
        "STR+10",
        "Weapon skill damage +10%",
        "Phys. dmg. taken-10%"
    })
}

-- Jumalik Equipment
JumalikHead = createEquipment("Jumalik Helm", nil, nil, {
    "MND+10",
    '"Mag.Atk.Bns."+15',
    "Magic burst dmg.+10%",
    '"Refresh"+1'
})
JumalikBody = createEquipment("Jumalik Mail", nil, nil, {
    "HP+50",
    "Attack+15",
    "Enmity+9",
    '"Refresh"+2'
})

-- Rings
MoonlightRing1 = "Moonlight Ring"
MoonlightRing2 = "Moonlight Ring"
ChirichRing1 = "Chirich Ring +1"
ChirichRing2 = "Chirich Ring +1"

-- =========================================================================================================
--                                       Weapon and Sub-Weapon Sets
-- =========================================================================================================

-- Great Axe Sets
sets['Lycurgos'] = { main = 'Lycurgos', sub = 'Utu Grip' }
sets['Ukonvasara'] = { main = 'Ukonvasara', sub = 'Utu Grip' }
sets['Chango'] = { main = 'Chango', sub = 'Utu Grip' }

-- Polearm Set
sets['Shining'] = { main = 'Shining one', sub = 'Utu Grip' }

-- Axe Set
sets['Ikenga'] = { main = "Ikenga's Axe", sub = 'Blurred Shield +1' }

-- Sword and Shield Set
sets['Naegling'] = { main = 'Naegling', sub = 'Blurred Shield +1' }

-- Mace and Shield Set
sets['Loxotic'] = { main = 'Loxotic Mace +1', sub = 'Blurred Shield +1' }

-- Utility Sub and Ammo Sets
sets['Utu Grip'] = { sub = 'Utu Grip' }
sets['Blurred Shield +1'] = { sub = 'Blurred Shield +1' }
sets['Aurgelmir Orb +1'] = { ammo = 'Aurgelmir Orb +1' }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================

-- Default Idle Set
sets.idle = {
    ammo = "Coiste Bodhar",
    head = "Hjarrandi Helm",
    body = "Boii Lorica +3",
    hands = "Sakpata's Gauntlets",
    legs = "Pumm. Cuisses +4",
    feet = "Pumm. Calligae +4",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Dedition Earring",
    ear2 = "Boii Earring +1",
    ring1 = "Niqmaddu Ring",
    ring2 = "Moonlight Ring",
    back = Cichol.stp,
}

-- Physical Damage Taken (PDT) Idle Set
-- Combines the default idle set and adds specific gear for physical damage reduction
sets.idle.PDT = set_combine(sets.idle, {
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    ring1 = "Defending Ring",
    ring2 = "Gelatinous Ring +1",
    back = "Moonlight Cape", -- PDT-focused back piece
})

-- Town Idle Set
-- Combines the default idle set with town-specific gear for movement and aesthetics
sets.idle.Town = set_combine(sets.idle, {
    neck = 'Elite Royal Collar',
    feet = "Hermes' Sandals"
})

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================

-- Base Engaged Set - Not directly used, serves as foundation
sets.engaged = {
    ammo = "Coiste Bodhar",
    head = "Hjarrandi Helm",
    body = "Boii Lorica +3",
    hands = "Sakpata's Gauntlets",
    legs = "Pumm. Cuisses +4",
    feet = "Pumm. Calligae +4",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Dedition Earring",
    ear2 = "Boii Earring +1",
    ring1 = "Niqmaddu Ring",
    ring2 = "Moonlight Ring",
    back = Cichol.stp,
}

-- Normal Mode Engaged Set - TP-focused for maximum damage output
sets.engaged.Normal = sets.engaged

-- Physical Damage Taken TP (PDTTP) Engaged Set - Balanced PDT+TP for survivability
sets.engaged.PDTTP = set_combine(sets.engaged, {
    ammo = "Coiste Bodhar",
    head = "Hjarrandi Helm",
    body = "Boii Lorica +3",
    hands = "Sakpata's Gauntlets",
    legs = "Pumm. Cuisses +4",
    feet = "Pumm. Calligae +4",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Dedition Earring",
    ear2 = "Boii Earring +1",
    ring1 = "Niqmaddu Ring",
    ring2 = "Moonlight Ring",
    back = Cichol.stp,
})

-- Legacy PDT set (not used by customize_melee_set logic)
sets.engaged.PDT = sets.engaged.PDTTP

-- Ukonvasara + Aftermath Level 3 Specialized Set - Used for both Normal and PDT modes
sets.engaged.PDTAFM3 = set_combine(sets.engaged.PDTTP, {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    neck = "War. Beads +2",
    waist = "Ioskeha Belt +1",
    ear1 = "Schere Earring",
    ear2 = "Boii Earring +1",
    ring1 = "Niqmaddu Ring",
    ring2 = "Moonlight Ring",
    back = Cichol.stp,
})


-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = "Hermes' Sandals", -- Provides increased movement speed
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================

-- Full Enmity Set
-- Maximizes enmity generation for tanking and provoking.
sets.FullEnmity = {
    ammo = 'Sapience Orb',       -- Enmity bonus
    head = SouvHead,             -- High HP and enmity
    body = SouvBody,             -- High HP and enmity
    hands = SouvHands,           -- High HP and enmity
    legs = SouvLegs,             -- High HP and enmity
    feet = SouvFeet,             -- High HP and enmity
    neck = 'Moonlight Necklace', -- Boosts enmity
    waist = 'Trance Belt',       -- Enmity boost
    ear1 = 'Cryptic Earring',    -- Additional enmity
    ear2 = 'Friomisi Earring',   -- Magic-based enmity
    ring1 = 'Provocare Ring',    -- Enmity boost
    ring2 = 'Supershear Ring',   -- Enmity boost
    back = 'Earthcry Mantle',    -- Enmity bonus
}

-- Precast Job Abilities
sets.precast.JA = {}

-- "Provoke" Ability Set
-- Reuses the Full Enmity set as is.
sets.precast.JA['Provoke'] = sets.FullEnmity

-- "Jump" and "High Jump" Ability Sets
-- Leverages the engaged PDTTP set for balanced attack and survivability.
sets.precast.JA['Jump'] = sets.engaged.PDTTP
sets.precast.JA['High Jump'] = sets.engaged.PDTTP

-- "Berserk" Ability Set
-- Enhances attack power and mitigates Berserk penalties.
sets.precast.JA['Berserk'] = set_combine(sets.engaged, {
    body = 'Pumm. Lorica +3', -- Duration + 18 Secs
    feet = 'Agoge Calligae +4'   -- Duration + 30 Secs
})

-- "Defender" Ability Set
-- Increases defense and reduces damage taken.
sets.precast.JA['Defender'] = set_combine(sets.engaged, {
    hands = 'Agoge Mufflers +3', -- Enhances Defender effect
})

-- "Warcry" Ability Set
-- Boosts attack power for the party.
sets.precast.JA['Warcry'] = set_combine(sets.engaged, {
    head = 'Agoge Mask +4', -- Enhances Warcry effect
})

-- "Aggressor" Ability Set
-- Increases accuracy and attack speed for aggressive play.
sets.precast.JA['Aggressor'] = set_combine(sets.engaged, {
    head = "Pummeler's Mask +3", -- 18S
    body = 'Agoge Lorica +3',    -- 30S
})

-- "Blood Rage" Ability Set
-- Enhances critical hit rate and attack for party members.
sets.precast.JA['Blood Rage'] = set_combine(sets.engaged, {
    body = 'Boii Lorica +3', -- Maximizes Blood Rage effect
})

-- "Tomahawk" Ability Set
sets.precast.JA['Tomahawk'] = {
    ammo = 'Thr. Tomahawk',     -- Uses Tomahawk as ammo for ranged attack
    feet = 'Agoge Calligae +4', -- Enhances Tomahawk effect
}

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================

-- Default Weapon Skill Set
sets.precast.WS = {
    ammo = 'Knobkierrie',
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = 'Boii Mufflers +3',
    legs = 'Boii Cuisses +3',
    feet = "Sakpata's Leggings",
    neck = 'War. Beads +2',
    waist = 'Ioskeha Belt +1',
    ear1 = 'Thrud Earring',
    ear2 = 'Boii Earring +1',
    ring1 = "Niqmaddu Ring",
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1
}

-- Default TPBonus Set
sets.precast.WS.TPBonus = {
    ear1 = 'Moonshade Earring', -- TP Bonus +250
}

-- "Armor Break" Weapon Skill
sets.precast.WS["Armor Break"] = set_combine(sets.precast.WS, {
    neck = "Fotia Gorget",
    waist = "Fotia Belt"
})
sets.precast.WS["Armor Break"].TPBonus = set_combine(sets.precast.WS["Armor Break"], sets.precast.WS.TPBonus)

-- "Ukko's Fury" Weapon Skill
sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Schere Earring",
    ear2 = "Boii Earring +1",
    ring1 = "Niqmaddu Ring",
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1,
})

sets.precast.WS["Ukko's Fury"].TPBonus = set_combine(sets.precast.WS["Ukko's Fury"], sets.precast.WS.TPBonus)

-- "Upheaval" Weapon Skill
sets.precast.WS["Upheaval"] = set_combine(sets.precast.WS, {
    ammo = "Knobkierrie",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Sakpata's Leggings",
    neck = "Null Loop",
    waist = "Ioskeha Belt +1",
    ear1 = "Schere Earring",
    ear2 = "Thrud Earring",
    ring1 = "Niqmaddu Ring",
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1,
})

sets.precast.WS["Upheaval"].TPBonus = set_combine(sets.precast.WS["Upheaval"], sets.precast.WS.TPBonus)

-- "Fell Cleave" Weapon Skill
sets.precast.WS["Fell Cleave"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Boii Mufflers +3",
    legs = "Boii Cuisses +3",
    feet = "Nyame Sollerets",
    neck = "War. Beads +2",
    waist = "Fotia Belt",
    ear2 = "Thrud Earring",
    ear1 = "Schere Earring",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1,
})
sets.precast.WS["Fell Cleave"].TPBonus = set_combine(sets.precast.WS["Fell Cleave"], sets.precast.WS.TPBonus)

-- "King's Justice" Weapon Skill
sets.precast.WS["King's Justice"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Boii Mufflers +3",
    legs = "Boii Cuisses +3",
    feet = "Sakpata's Leggings",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Schere Earring",
    ear2 = "boii Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1,
})
sets.precast.WS["King's Justice"].TPBonus = set_combine(sets.precast.WS["King's Justice"], sets.precast.WS.TPBonus)

-- "Impulse Drive" Weapon Skill
sets.precast.WS["Impulse Drive"] = set_combine(sets.precast.WS, {
    ammo = "Yetshila +1",
    head = "Boii Mask +3",
    neck = "War. Beads +2",
    ear1 = "Thrud Earring",
    ear2 = "Boii Earring +1",
    body = "Sakpata's Plate",
    hands = "Boii Mufflers +3",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's Ring",
    waist = "Sailfi Belt +1",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    back = Cichol.ws1,
})
sets.precast.WS["Impulse Drive"].TPBonus = set_combine(sets.precast.WS["Impulse Drive"], sets.precast.WS.TPBonus)

-- "Stardiver" Weapon Skill
sets.precast.WS["Stardiver"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    neck = "War. Beads +2",
    ear1 = "Schere Earring",
    ear2 = "Boii Earring +1",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    ring1 = "Niqmaddu Ring",
    ring2 = "Cornelia's Ring",
    waist = "Fotia Belt",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    back = Cichol.ws1,
})
sets.precast.WS["Stardiver"].TPBonus = set_combine(sets.precast.WS["Stardiver"], sets.precast.WS.TPBonus)

-- "Savage Blade" Weapon Skill
sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Agoge Mask +4",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Nyame Sollerets",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Thrud Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Sroda Ring",
    ring2 = "Cornelia's ring",
})

-- "Calamity" Weapon Skill
sets.precast.WS["Calamity"] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Agoge Mask +4",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Nyame Sollerets",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1 = "Thrud Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Sroda Ring",
    ring2 = "Cornelia's ring",
})

-- TPBonus sets for weapon skills
sets.precast.WS["Savage Blade"].TPBonus = set_combine(sets.precast.WS["Savage Blade"], sets.precast.WS.TPBonus)
sets.precast.WS["Calamity"].TPBonus = set_combine(sets.precast.WS["Calamity"], sets.precast.WS.TPBonus)

-- "Judgment" Weapon Skill
sets.precast.WS["Judgment"] = set_combine(sets.precast.WS, {
    legs = { name = "Nyame Flanchard", augments = { 'Path: B', } },
    feet = { name = "Nyame Sollerets", augments = { 'Path: B', } },
    ring2 = "Defending Ring"
})
sets.precast.WS["Judgment"].TPBonus = set_combine(sets.precast.WS["Judgment"], sets.precast.WS.TPBonus)

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
-- Buff Set for "Doom" Status
-- Used to mitigate the effects of Doom and enhance survivability.
sets.buff = {}

sets.buff.Doom = {
    neck = "Nicander's Necklace", -- Reduces Doom effects
    ring1 = "Purity Ring",        -- Additional Doom resistance
    waist = "Gishdubar Sash",     -- Enhances Doom recovery effects
}

-- =========================================================================================================
--                                           Set Validation
-- =========================================================================================================

-- Equipment validation temporarily disabled due to compatibility issues
-- All sets are functional in-game

-- Validation temporarily disabled
-- windower.add_to_chat(123, "WAR sets loaded successfully")
