--============================================================--
--=                      WAR_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
SouvHead = createEquipment('Souv. Schaller +1', 24, nil,
    { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' })
SouvBody = createEquipment('Souv. Cuirass +1', 3, nil,
    { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' })
SouvHands = createEquipment('Souv. Handsch. +1', 23, nil,
    { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' })
SouvLegs = createEquipment('Souv. Diechlings +1', 16, nil,
    { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' })
SouvFeets = createEquipment('Souveran Schuhs +1', 22, nil,
    { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%' })

ValorousHose = createEquipment('Valorous Hose', nil, nil,
    { 'Store TP +2', 'Accuracy+17', 'Weapon skill damage +7%', 'Accuracy+18 Attack+18', 'Mag. Acc.+9 "Mag.Atk.Bns."+9' })

Cichol = {}
Cichol.stp = createEquipment("Cichol's Mantle", nil, nil,
    { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%' })
Cichol.ws1 = createEquipment("Cichol's Mantle", nil, nil,
    { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' })

JumalikHead = createEquipment('Jumalik Helm', nil, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = createEquipment('Jumalik Mail', nil, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

MoonlightRing1 = createEquipment('Moonlight Ring', nil, "wardrobe 2")
MoonlightRing2 = createEquipment('Moonlight Ring', nil, "wardrobe 3")
ChirichRing1 = createEquipment('Chirich Ring +1', nil, "wardrobe 1")
ChirichRing2 = createEquipment('Chirich Ring +1', nil, "wardrobe 2")

sets['Lycurgos'] = { main = createEquipment('Lycurgos'), sub = createEquipment('Utu Grip') }
sets['Ukonvasara'] = { main = createEquipment('Ukonvasara'), sub = createEquipment('Utu Grip') }
sets['Chango'] = { main = createEquipment('Chango'), sub = createEquipment('Utu Grip') }
sets['Shining'] = { main = createEquipment('Shining one'), sub = createEquipment('Utu Grip') }
sets['Naegling'] = { main = createEquipment('Naegling'), sub = createEquipment('Blurred Shield +1') }
sets['Loxotic'] = { main = createEquipment('Loxotic Mace +1'), sub = createEquipment('Blurred Shield +1') }
sets['Utu Grip'] = { sub = createEquipment('Utu Grip') }
sets['Blurred Shield +1'] = { sub = createEquipment('Blurred Shield +1') }
sets['Aurgelmir Orb +1'] = { ammo = createEquipment('Aurgelmir Orb +1') }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
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

sets.idle.PDT = set_combine(
    sets.idle,
    {
        ammo = createEquipment('Coiste Bodhar'),
        head = createEquipment('Hjarrandi Helm'),
        body = createEquipment('Hjarrandi Breast.'),
        hands = createEquipment("Sakpata's Gauntlets"),
        legs = createEquipment("Sakpata's Cuisses"),
        feet = createEquipment("Sakpata's Leggings"),
        neck = createEquipment('War. Beads +2'),
        waist = createEquipment('Ioskeha Belt +1'),
        left_ear = createEquipment('Schere Earring'),
        right_ear = createEquipment('Boii Earring +1'),
        left_ring = ChirichRing1,
        right_ring = ChirichRing2,
        back = Cichol.stp
    }
)

sets.idle.Town = set_combine(
    sets.idle,
    {
        neck = createEquipment('Elite royal collar'),
        feet = createEquipment("Hermes' Sandals")
    }
)

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = "Ioskeha Belt +1",
    left_ear = "Brutal Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

sets.engaged.Normal = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = "Ioskeha Belt +1",
    left_ear = "Brutal Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

sets.engaged.PDT = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = "Ioskeha Belt +1",
    left_ear = "Brutal Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

sets.engaged.PDTTP = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = "Ioskeha Belt +1",
    left_ear = "Brutal Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

sets.engaged.PDTAFM3 = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = "Ioskeha Belt +1",
    left_ear = "Brutal Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}
-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = createEquipment("Hermes' Sandals")
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.FullEnmity = {
    ammo = createEquipment('Sapience Orb'),
    head = SouvHead,
    body = SouvBody,
    hands = SouvHands,
    legs = SouvLegs,
    feet = SouvFeets,
    neck = createEquipment('Moonlight Necklace'),
    waist = createEquipment('Trance Belt'),
    left_ear = createEquipment('Cryptic Earring'),
    right_ear = createEquipment('Friomisi Earring'),
    left_ring = createEquipment('Provocare Ring'),
    right_ring = createEquipment('Supershear Ring'),
    back = createEquipment('Earthcry Mantle')
}

sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Jump'] = set_combine(sets.engaged)
sets.precast.JA['High Jump'] = set_combine(sets.engaged)

sets.precast.JA['Berserk'] = set_combine(
    sets.engaged,
    {
        body = createEquipment('Pumm. Lorica +3'),
        feet = createEquipment('Agoge Calligae +3')
    }
)

sets.precast.JA['Defender'] = set_combine(
    sets.engaged,
    {
        hands = createEquipment('Agoge Mufflers +3')
    }
)

sets.precast.JA['Warcry'] = set_combine(
    sets.engaged,
    {
        head = createEquipment('Agoge Mask +3')
    }
)

sets.precast.JA['Aggressor'] = set_combine(
    sets.engaged,
    {
        head = createEquipment("Pummeler's Mask +3"),
        body = createEquipment('Agoge Lorica +3')
    }
)

sets.precast.JA['Blood Rage'] = set_combine(
    sets.engaged,
    {
        body = createEquipment('Boii Lorica +3')
    }
)

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
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

sets.precast.WS["Ukko's Fury"] = {
    ammo = "Yetshila +1",
    head = "Blistering Sallet +1",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
    left_ear = "Schere Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Cornelia's Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%', } },
}

sets.precast.WS["Upheaval"] = {
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

sets.precast.WS["Fell Cleave"] = {
    ammo = "Knobkierrie",
    head = { name = "Agoge Mask +3", augments = { 'Enhances "Savagery" effect', } },
    body = "Sakpata's Plate",
    hands = "Boii Mufflers +3",
    legs = "Boii Cuisses +3",
    feet = "Sakpata's Leggings",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    left_ear = "Schere Earring",
    right_ear = "Thrud Earring",
    left_ring = "Cornelia's Ring",
    right_ring = "Epaminondas's Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%', } },
}

sets.precast.WS["King's Justice"] = {
    ammo = "Knobkierrie",
    head = { name = "Agoge Mask +3", augments = { 'Enhances "Savagery" effect', } },
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Sakpata's Leggings",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
    right_ear = "Schere Earring",
    left_ear = "Thrud Earring",
    left_ring = "Cornelia's Ring",
    right_ring = "Epaminondas's Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%', } },
}

sets.precast.WS["Impulse Drive"] = {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    neck = { name = "War. Beads +2", augments = { 'Path: A', } },
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A', } },
    left_ear = "Thrud Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Cornelia's Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

sets.precast.WS["Savage Blade"] = {
    ammo = "Knobkierrie",
    head = "Agoge Mask +3",
    body = "Sakpata's Plate",
    hands = "Boii Mufflers +3",
    legs = "Boii Cuisses +3",
    feet = "Sulev. Leggings +2",
    neck = "War. Beads +2",
    waist = "Sailfi Belt +1",
    left_ear = "Thrud Earring",
    right_ear = "Ishvara Earring",
    left_ring = "Cornelia's Ring",
    right_ring = "Epaminondas's Ring",
    back = "Cichol's Mantle",
}

sets.precast.WS["Stardiver"] = {
    ammo = "Crepuscular Pebble",
    head = "Boii Mask +3",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Boii Cuisses +3",
    feet = "Boii Calligae +3",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    left_ear = "Thrud Earring",
    right_ear = { name = "Boii Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4', } },
    left_ring = "Sroda Ring",
    right_ring = "Niqmaddu Ring",
    back = { name = "Cichol's Mantle", augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%', } },
}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace")
}
