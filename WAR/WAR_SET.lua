--============================================================--
--=                      WAR_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

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
SouvFeets = createEquipment("Souveran Schuhs +1", 22, nil, {
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
        "Damage taken-5%"
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
MoonlightRing1 = createEquipment("Moonlight Ring", nil, "wardrobe 2")
MoonlightRing2 = createEquipment("Moonlight Ring", nil, "wardrobe 3")
ChirichRing1 = createEquipment("Chirich Ring +1", nil, "wardrobe 1")
ChirichRing2 = createEquipment("Chirich Ring +1", nil, "wardrobe 2")

-- =========================================================================================================
--                                       Weapon and Sub-Weapon Sets
-- =========================================================================================================

-- Great Axe Sets
sets['Lycurgos'] = { main = createEquipment('Lycurgos'), sub = createEquipment('Utu Grip') }
sets['Ukonvasara'] = { main = createEquipment('Ukonvasara'), sub = createEquipment('Utu Grip') }
sets['Chango'] = { main = createEquipment('Chango'), sub = createEquipment('Utu Grip') }

-- Polearm Set
sets['Shining'] = { main = createEquipment('Shining one'), sub = createEquipment('Utu Grip') }

-- Sword and Shield Set
sets['Naegling'] = { main = createEquipment('Naegling'), sub = createEquipment('Blurred Shield +1') }

-- Mace and Shield Set
sets['Loxotic'] = { main = createEquipment('Loxotic Mace +1'), sub = createEquipment('Blurred Shield +1') }

-- Utility Sub and Ammo Sets
sets['Utu Grip'] = { sub = createEquipment('Utu Grip') }
sets['Blurred Shield +1'] = { sub = createEquipment('Blurred Shield +1') }
sets['Aurgelmir Orb +1'] = { ammo = createEquipment('Aurgelmir Orb +1') }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================

-- Default Idle Set
sets.idle = {
    ammo = createEquipment('Coiste Bodhar'),
    head = createEquipment('Hjarrandi Helm'),
    body = createEquipment('Hjarrandi Breast.'),
    hands = createEquipment("Sakpata's Gauntlets"),
    legs = createEquipment("Sakpata's Cuisses"),
    feet = createEquipment('Boii Calligae +3'),
    neck = createEquipment('War. Beads +2'),
    waist = createEquipment('Ioskeha Belt +1'),
    left_ear = createEquipment('Schere Earring'),
    right_ear = createEquipment('Boii Earring +1'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Cichol.stp
}

-- Physical Damage Taken (PDT) Idle Set
-- Combines the default idle set and adds specific gear for physical damage reduction
sets.idle.PDT = set_combine(sets.idle, {
    feet = createEquipment("Sakpata's Leggings")
})

-- Town Idle Set
-- Combines the default idle set with town-specific gear for movement and aesthetics
sets.idle.Town = set_combine(sets.idle, {
    neck = createEquipment('Elite royal collar'),
    feet = createEquipment("Hermes' Sandals")
})

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================

-- Base Engaged Set
sets.engaged = set_combine(sets.idle, {
    body = createEquipment("Boii Lorica +3"),
    legs = createEquipment("Pumm. Cuisses +3"),
    feet = createEquipment("Pumm. Calligae +3"),
    waist = createEquipment("Sailfi Belt +1"),
    left_ear = createEquipment("Dedition Earring"),
    right_ring = createEquipment("Niqmaddu Ring"),
})

-- Normal Mode Engaged Set
sets.engaged.Normal = sets.engaged -- Reuse the base engaged set as normal mode is identical.

-- Physical Damage Taken (PDT) Engaged Set
sets.engaged.PDT = set_combine(sets.engaged, {
    left_ring = createEquipment("Moonlight Ring"),
})

-- Physical Damage Taken TP (PDTTP) Engaged Set
sets.engaged.PDTTP = set_combine(sets.engaged.PDT, {
    ammo = createEquipment("Coiste Bodhar"),
    head = createEquipment("Hjarrandi Helm"),
    neck = createEquipment('War. Beads +2'),
    left_ear = createEquipment("Dedition Earring"),
    right_ear = createEquipment("Boii Earring +1"),
    body = createEquipment("Boii Lorica +3"),
    hands = createEquipment("Sakpata's Gauntlets"),
    left_ring = createEquipment("Moonlight Ring"),
    right_ring = createEquipment("Niqmaddu Ring"),
    back = Cichol.stp,
    legs = createEquipment("Pumm. Cuisses +3"),
    feet = createEquipment("Pumm. Calligae +3"),
    waist = createEquipment("Sailfi Belt +1"),
})

-- Physical Damage Taken with Aftermath Level 3 (PDTAFM3) Set
sets.engaged.PDTAFM3 = set_combine(sets.engaged.PDT, {
    ammo = createEquipment("Yetshila +1"),
    head = createEquipment("Sakpata's Helm"),
    neck = createEquipment('War. Beads +2'),
    left_ear = createEquipment("Schere Earring"),
    right_ear = createEquipment("Boii Earring +1"),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment("Sakpata's Gauntlets"),
    left_ring = createEquipment("Moonlight Ring"),
    right_ring = createEquipment("Niqmaddu Ring"),
    back = Cichol.stp,
    legs = createEquipment("Boii Cuisses +3"),
    feet = createEquipment("Boii Calligae +3"),
    waist = createEquipment("Ioskeha Belt +1"),
})

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = createEquipment("Hermes' Sandals"), -- Provides increased movement speed
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================

-- Full Enmity Set
-- Maximizes enmity generation for tanking and provoking.
sets.FullEnmity = {
    ammo = createEquipment('Sapience Orb'),          -- Enmity bonus
    head = SouvHead,                                 -- High HP and enmity
    body = SouvBody,                                 -- High HP and enmity
    hands = SouvHands,                               -- High HP and enmity
    legs = SouvLegs,                                 -- High HP and enmity
    feet = SouvFeets,                                -- High HP and enmity
    neck = createEquipment('Moonlight Necklace'),    -- Boosts enmity
    waist = createEquipment('Trance Belt'),          -- Enmity boost
    left_ear = createEquipment('Cryptic Earring'),   -- Additional enmity
    right_ear = createEquipment('Friomisi Earring'), -- Magic-based enmity
    left_ring = createEquipment('Provocare Ring'),   -- Enmity boost
    right_ring = createEquipment('Supershear Ring'), -- Enmity boost
    back = createEquipment('Earthcry Mantle'),       -- Enmity bonus
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
    body = createEquipment('Pumm. Lorica +3'),  -- Enhances Berserk effect
    feet = createEquipment('Agoge Calligae +3') -- Reduces Berserk penalties
})

-- "Defender" Ability Set
-- Increases defense and reduces damage taken.
sets.precast.JA['Defender'] = set_combine(sets.engaged, {
    hands = createEquipment('Agoge Mufflers +3'), -- Enhances Defender effect
})

-- "Warcry" Ability Set
-- Boosts attack power for the party.
sets.precast.JA['Warcry'] = set_combine(sets.engaged, {
    head = createEquipment('Agoge Mask +3'), -- Enhances Warcry effect
})

-- "Aggressor" Ability Set
-- Increases accuracy and attack speed for aggressive play.
sets.precast.JA['Aggressor'] = set_combine(sets.engaged, {
    head = createEquipment("Pummeler's Mask +3"), -- Enhances Aggressor effect
    body = createEquipment('Agoge Lorica +3'),    -- Increases attack speed
})

-- "Blood Rage" Ability Set
-- Enhances critical hit rate and attack for party members.
sets.precast.JA['Blood Rage'] = set_combine(sets.engaged, {
    body = createEquipment('Boii Lorica +3'), -- Maximizes Blood Rage effect
})

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================

-- Default Weapon Skill Set
sets.precast.WS = {
    ammo = createEquipment('Knobkierrie'),
    head = createEquipment("Sakpata's Helm"),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment('Boii Mufflers +3'),
    legs = createEquipment('Boii Cuisses +3'),
    feet = createEquipment("Sakpata's Leggings"),
    neck = createEquipment('War. Beads +2'),
    waist = createEquipment('Ioskeha Belt +1'),
    left_ear = createEquipment('Thrud Earring'),
    right_ear = createEquipment('Boii Earring +1'),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment("Niqmaddu Ring"),
    back = Cichol.ws1
}

-- Default TPBonus Set
sets.precast.WS.TPBonus = {
    left_ear = createEquipment('Moonshade Earring'), -- TP Bonus +250
}

-- "Armor Break" Weapon Skill
sets.precast.WS["Armor Break"] = set_combine(sets.precast.WS, {
    neck = "Fotia Gorget",
    waist = "Fotia Belt"
})
sets.precast.WS["Armor Break"].TPBonus = set_combine(sets.precast.WS["Armor Break"], sets.precast.WS.TPBonus)

-- "Ukko's Fury" Weapon Skill
sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {
    ammo = "Yetshila +1", -- Critical hit rate
    head = "Blistering Sallet +1",
    feet = "Boii Calligae +3",
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } }
})
sets.precast.WS["Ukko's Fury"].TPBonus = set_combine(sets.precast.WS["Ukko's Fury"], sets.precast.WS.TPBonus)

-- "Upheaval" Weapon Skill
sets.precast.WS["Upheaval"] = set_combine(sets.precast.WS, {})
sets.precast.WS["Upheaval"].TPBonus = set_combine(sets.precast.WS["Upheaval"], sets.precast.WS.TPBonus)

-- "Fell Cleave" Weapon Skill
sets.precast.WS["Fell Cleave"] = set_combine(sets.precast.WS, {
    head = { name = "Agoge Mask +3", augments = { 'Enhances "Savagery" effect', } },
    neck = "Fotia Gorget",
    waist = "Fotia Belt"
})
sets.precast.WS["Fell Cleave"].TPBonus = set_combine(sets.precast.WS["Fell Cleave"], sets.precast.WS.TPBonus)

-- "King's Justice" Weapon Skill
sets.precast.WS["King's Justice"] = set_combine(sets.precast.WS, {
    head = { name = "Agoge Mask +3", augments = { 'Enhances "Savagery" effect', } },
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } }
})
sets.precast.WS["King's Justice"].TPBonus = set_combine(sets.precast.WS["King's Justice"], sets.precast.WS.TPBonus)

-- "Impulse Drive" Weapon Skill
sets.precast.WS["Impulse Drive"] = set_combine(sets.precast.WS, {
    ammo = "Yetshila +1",
    head = "Blistering Sallet +1",
    feet = "Boii Calligae +3"
})
sets.precast.WS["Impulse Drive"].TPBonus = set_combine(sets.precast.WS["Impulse Drive"], sets.precast.WS.TPBonus)

-- "Savage Blade" Weapon Skill
sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
    feet = "Sulev. Leggings +2",
    right_ear = "Ishvara Earring"
})
sets.precast.WS["Savage Blade"].TPBonus = set_combine(sets.precast.WS["Savage Blade"], sets.precast.WS.TPBonus)

-- "Judgment" Weapon Skill
sets.precast.WS["Judgment"] = set_combine(sets.precast.WS, {
    legs = { name = "Nyame Flanchard", augments = { 'Path: B', } },
    feet = { name = "Nyame Sollerets", augments = { 'Path: B', } },
    right_ring = "Defending Ring"
})
sets.precast.WS["Judgment"].TPBonus = set_combine(sets.precast.WS["Judgment"], sets.precast.WS.TPBonus)

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
-- Buff Set for "Doom" Status
-- Used to mitigate the effects of Doom and enhance survivability.
sets.buff = {}

sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace"), -- Reduces Doom effects
    ring1 = createEquipment("Purity Ring"),        -- Additional Doom resistance
    waist = createEquipment("Gishdubar Sash"),     -- Enhances Doom recovery effects
}
