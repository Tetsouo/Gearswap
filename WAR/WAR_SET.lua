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

Cichol = {}
Cichol.stp = createEquipment("Cichol's Mantle", nil, nil,
    { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Damage taken-5%' })
Cichol.ws1 = createEquipment("Cichol's Mantle", nil, nil,
    { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' })

JumalikHead = createEquipment('Jumalik Helm', nil, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = createEquipment('Jumalik Mail', nil, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

MoonbeamRing1 = createEquipment('Moonbeam Ring', nil, "wardrobe 2")
MoonbeamRing2 = createEquipment('Moonbeam Ring', nil, "wardrobe 3")
ChirichRing1 = createEquipment('Chirich Ring +1', nil, "wardrobe 1")
ChirichRing2 = createEquipment('Chirich Ring +1', nil, "wardrobe 2")

sets['Lycurgos'] = { main = createEquipment('Lycurgos'), sub = createEquipment('Utu Grip') }
sets['Ukonvasara'] = { main = createEquipment('Ukonvasara'), sub = createEquipment('Utu Grip') }
sets['Shining'] = { main = createEquipment('Shining one'), sub = createEquipment('Utu Grip') }
sets['Naegling'] = { main = createEquipment('Naegling'), sub = createEquipment('Blurred Shield +1') }
sets['Loxotic'] = { main = createEquipment('Loxotic Mace +1'), sub = createEquipment('Blurred Shield +1') }

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
    left_ring = createEquipment('Chirich Ring +1'),
    right_ring = createEquipment('Niqmaddu Ring'),
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
        left_ring = createEquipment('Chirich Ring +1'),
        right_ring = createEquipment('Defending Ring'),
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
    ammo = createEquipment('Coiste Bodhar'),
    head = createEquipment('Boii Mask +3'),
    body = createEquipment('Boii lorica +3'),
    hands = createEquipment("Sakpata's Gauntlets"),
    legs = createEquipment('Agoge Cuisses +3'),
    feet = createEquipment('Pumm. Calligae +3'),
    neck = createEquipment('War. Beads +2'),
    waist = createEquipment('Ioskeha Belt +1'),
    left_ear = createEquipment('Schere Earring'),
    right_ear = createEquipment('Boii Earring +1'),
    left_ring = createEquipment('Chirich Ring +1'),
    right_ring = createEquipment('Niqmaddu Ring'),
    back = Cichol.stp
}

sets.engaged.Restraint = set_combine(sets.engaged, {
    hands = createEquipment('Boii Mufflers +3'),
})

sets.engaged.DW = {}
sets.engaged.DW.Acc = {}

sets.engaged.PDT = set_combine(
    sets.idle,
    {
        ammo = createEquipment("Coiste Bodhar"),
        head = createEquipment("Boii Mask +3"),
        body = createEquipment("Boii Lorica +3"),
        hands = createEquipment("Sakpata's Gauntlets"),
        legs = createEquipment("Sakpata's Cuisses"),
        feet = createEquipment("Boii Calligae +3"),
        neck = createEquipment("War. Beads +2"),
        waist = createEquipment("Ioskeha Belt +1"),
        left_ear = createEquipment("Telos Earring"),
        right_ear = createEquipment("Boii Earring +1"),
        left_ring = createEquipment("Chirich Ring +1"),
        right_ring = createEquipment("Chirich Ring +1"),
        back = Cichol.stp
    }
)

sets.engaged.PDT.Restraint = set_combine(sets.engaged.PDT, {
    hands = createEquipment('Boii Mufflers +3'),
})
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
    head = createEquipment('Agoge Mask +3'),
    body = createEquipment('Pumm. Lorica +3'),
    hands = createEquipment('Boii Mufflers +3'),
    legs = createEquipment('Valorous Hose'),
    feet = createEquipment('Sulev. Leggings +2'),
    neck = createEquipment('War. Beads +2'),
    waist = createEquipment('Sailfi Belt +1'),
    left_ear = createEquipment('Thrud Earring'),
    right_ear = createEquipment('Boii Earring +1'),
    left_ring = createEquipment('Regal Ring'),
    right_ring = createEquipment("Cornelia's Ring"),
    back = Cichol.ws1
}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace")
}
