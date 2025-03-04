--============================================================--
--=                      BLM_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024-02-15                  =--
--============================================================--

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
StikiRing1 = createEquipment('Stikini Ring +1', nil, 'wardrobe 6')
StikiRing2 = createEquipment('Stikini Ring +1', nil, 'wardrobe 7')

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    main = createEquipment('Malignance Pole'),
    sub = createEquipment('Enki Strap'),
    ammo = createEquipment('Ghastly Tathlum +1'),
    head = createEquipment('Wicce Petasos +3'),
    body = createEquipment('Wicce Coat +3'),
    hands = createEquipment('Wicce Gloves +3'),
    legs = createEquipment('Wicce Chausses +3'),
    feet = createEquipment('Wicce Sabots +3'),
    neck = createEquipment('Loricate Torque +1'),
    waist = createEquipment('Acuity Belt +1'),
    left_ear = createEquipment('Ethereal Earring'),
    right_ear = createEquipment('Infused Earring'),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = createEquipment("Taranus's Cape"),
}
sets.idle.PDT = set_combine(sets.idle, {})
sets.idle.Town = set_combine(sets.idle, {})
sets.defense.PDT = {}
sets.defense.MDT = {}
sets.resting = set_combine(sets.idle, {})

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = {
    main = createEquipment("Malignance Pole"),
    sub = createEquipment("Enki Strap"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Wicce Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Wicce Sabots +3"),
    neck = createEquipment("Sanctity Necklace"),
    waist = createEquipment("Windbuffet Belt +1"),
    left_ear = createEquipment("Crep. Earring"),
    right_ear = createEquipment("Telos Earring"),
    left_ring = createEquipment("Chirich Ring +1"),
    right_ring = createEquipment("Chirich Ring +1"),
    back = createEquipment("Taranus's Cape"),
}
sets.engaged.PDT = {
    main = createEquipment("Malignance Pole"),
    sub = createEquipment("Enki Strap"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Wicce Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Wicce Sabots +3"),
    neck = createEquipment("Sanctity Necklace"),
    waist = createEquipment("Windbuffet Belt +1"),
    left_ear = createEquipment("Crep. Earring"),
    right_ear = createEquipment("Telos Earring"),
    left_ring = createEquipment("Chirich Ring +1"),
    right_ring = createEquipment("Chirich Ring +1"),
    back = createEquipment("Taranus's cape"),
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA['Mana Wall'] = {
    feet = createEquipment('Wicce Sabots +3'),
    back = createEquipment("Taranus's Cape")
}
sets.precast.JA.Manafont = { body = createEquipment("Archmage's Coat +1") }

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    main = { name = "Grioavolr", augments = { '"Fast Cast"+6', '"Mag.Atk.Bns."+6', } },
    sub = "Enki Strap",
    ammo = "Impatiens",
    head = { name = "Merlinic Hood", augments = { 'Attack+14', '"Fast Cast"+7', 'MND+3', } },
    body = { name = "Merlinic Jubbah", augments = { 'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3', } },
    hands = { name = "Merlinic Dastanas", augments = { '"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4', } },
    legs = { name = "Merlinic Shalwar", augments = { '"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11', } },
    feet = { name = "Merlinic Crackows", augments = { '"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10', } },
    neck = "Orunmila's Torque",
    waist = "Witful Belt",
    left_ear = "Malignance Earring",
    right_ear = "Loquac. Earring",
    left_ring = "Kishar Ring",
    right_ring = "Lebeche Ring",
    back = "Perimede Cape",
}
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Elemental Magic'] = sets.precast.FC
sets.precast.FC.Death = set_combine(sets.precast.FC, {})
sets.precast.FC.Cure = sets.precast.FC
sets.precast.FC.Curaga = sets.precast.FC.Cure
sets.precast.FC.Impact = set_combine(sets.precast.FC, {
    head = empty,
    body = createEquipment('Twilight Cloak')
})

sets.precast.FC.Death.MagicBurst = sets.precast.FC.Death
sets.precast.FC.Stoneskin = set_combine(sets.precast.FC, {
    head = createEquipment('Umuthi Hat'),
    legs = createEquipment('Doyen Pants'),
    waist = createEquipment('Siegel Sash')
})

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================
sets.midcast.FastRecast = sets.precast.FC

-- ================================================ Cure Sets ==============================================
sets.midcast.Cure = {
    main = createEquipment('Daybreak'),
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Wicce Petasos +3'),
    body = createEquipment('Nyame Mail'),
    hands = createEquipment('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = createEquipment('Wicce Chausses +3'),
    feet = createEquipment('Wicce Sabots +3'),
    neck = createEquipment('Nodens Gorget'),
    waist = createEquipment('Plat. Mog. Belt'),
    left_ear = createEquipment("Handler's Earring"),
    right_ear = createEquipment('Wicce Earring +1', nil, nil, { 'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4' }),
    left_ring = createEquipment('Defending Ring'),
    right_ring = StikiRing2,
    back = createEquipment('Solemnity Cape'),
}

sets.self_healing = set_combine(sets.midcast.Cure, {})
sets.midcast.Curaga = sets.midcast.Cure

-- ================================================ Enhancing Sets ========================================
sets.midcast['Enhancing Magic'] = {
    main = createEquipment('Daybreak'),
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment('Impatiens'),
    head = createEquipment('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = createEquipment('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = createEquipment('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = createEquipment('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = createEquipment('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = createEquipment('Loricate Torque +1'),
    waist = createEquipment('Olympus Sash'),
    left_ear = createEquipment('Andoaa Earring'),
    right_ear = createEquipment('Regal Earring'),
    left_ring = StikiRing1,
    right_ring = createEquipment('Evanescence ring'),
    back = createEquipment('Fi Follet Cape +1')
}
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
    ammo = createEquipment("Impatiens"),
    head = createEquipment('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = createEquipment('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = createEquipment('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = createEquipment('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = createEquipment('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = createEquipment("Nodens Gorget"),
    waist = createEquipment("Siegel Sash"),
    left_ear = createEquipment("Ethereal Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = createEquipment("Fi Follet Cape +1"),
})

sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Aquaveil = {
    main = createEquipment('Daybreak'),
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment("Impatiens"),
    head = createEquipment("Amalric Coif +1"),
    body = createEquipment("Telchine Chas.", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = createEquipment("Telchine Gloves", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = createEquipment("Telchine Braconi", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = createEquipment("Telchine Pigaches", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = createEquipment("Loricate Torque +1"),
    waist = createEquipment("Olympus Sash"),
    left_ear = createEquipment("Andoaa Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = createEquipment("Evanescence Ring"),
    back = createEquipment("Fi Follet Cape +1"),
}
sets.midcast.Refresh = set_combine(sets.midcast.Aquaveil,
    {
        main = createEquipment('Daybreak'),
        sub = createEquipment('Ammurapi Shield'),
        ammo = createEquipment('Impatiens'),
        head = createEquipment('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        body = createEquipment('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        hands = createEquipment('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        legs = createEquipment('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        feet = createEquipment('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        neck = createEquipment('Loricate Torque +1'),
        waist = createEquipment('Olympus Sash'),
        left_ear = createEquipment('Andoaa Earring'),
        right_ear = createEquipment('Regal Earring'),
        right_ring = createEquipment('Evanescence Ring'),
        left_ring = StikiRing1,
        back = createEquipment('Fi Follet Cape +1')
    })
    
sets.midcast.Haste = {
    main = createEquipment('Daybreak'),
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment('Impatiens'),
    head = createEquipment('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = createEquipment('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = createEquipment('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = createEquipment('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = createEquipment('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = createEquipment('Loricate Torque +1'),
    waist = createEquipment('Olympus Sash'),
    left_ear = createEquipment('Andoaa Earring'),
    right_ear = createEquipment('Regal Earring'),
    right_ring = createEquipment('Evanescence Ring'),
    left_ring = StikiRing1,
    back = createEquipment('Fi Follet Cape +1'),
}

-- ================================================ Debuffs Sets ========================================
sets.midcast.MndEnfeebles = {
    main = createEquipment('Daybreak'),
    sub = createEquipment('Ammurapi Shield'),
    head = createEquipment('Wicce Petasos +3'),
    neck = createEquipment("Src. Stole +2"),
    ear1 = createEquipment('Malignance Earring'),
    ear2 = createEquipment('Regal Earring'),
    body = createEquipment("Wicce Coat +3"),
    hands = createEquipment('Wicce Gloves +3'),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = createEquipment("Aurist's Cape +1"),
    waist = createEquipment('Sacro Cord'),
    legs = createEquipment('Wicce Chausses +3'),
    feet = createEquipment('Wicce Sabots +3')
}
sets.midcast.IntEnfeebles = {
    main = createEquipment("Bunzi's Rod"),
    sub = createEquipment("Ammurapi Shield"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Wicce Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Wicce Sabots +3"),
    neck = createEquipment("Src. Stole +2"),
    waist = createEquipment("Acuity Belt +1"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Wicce Earring +1"),
    left_ring = createEquipment("Metamor. Ring +1"),
    right_ring = StikiRing2,
    back = createEquipment("Taranus's cape")
}
sets.midcast.Breakga = sets.midcast.IntEnfeebles
sets.midcast.Break = sets.midcast.Breakga
sets.midcast.Sleep = sets.midcast.IntEnfeebles
sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep
sets.midcast.Blind = sets.midcast.IntEnfeebles

sets.midcast['Dark Magic'] = {
    main = createEquipment("Rubicundity", nil, nil, { 'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7' }),
    sub = createEquipment("Ammurapi Shield"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Merlinic Hood", nil, nil,
        { 'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2' }),
    body = createEquipment("Merlinic Jubbah", nil, nil,
        { '"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4' }),
    hands = createEquipment("Merlinic Dastanas", nil, nil, { '"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14' }),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Agwu's Pigaches"),
    neck = createEquipment("Erra Pendant"),
    waist = createEquipment("Fucho-no-Obi"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Wicce Earring +1"),
    left_ring = createEquipment("Metamor. Ring +1"),
    right_ring = createEquipment("Evanescence Ring"),
    back = createEquipment("Taranus's cape")
}
sets.midcast.Drain = sets.midcast['Dark Magic']
sets.midcast.Aspir = sets.midcast['Dark Magic']
sets.midcast.Raise = {}

-- ================================================ Elemental Sets ========================================
sets.midcast['Elemental Magic'] = {
    main = createEquipment("Bunzi's Rod"),
    sub = createEquipment("Ammurapi Shield"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Spaekona's Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Wicce Sabots +3"),
    neck = createEquipment("Src. Stole +2"),
    waist = createEquipment("Acuity Belt +1"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = createEquipment("Freke Ring"),
    right_ring = createEquipment("Metamor. Ring +1"),
    back = createEquipment("Taranus's cape")
}
sets.midcast['Elemental Magic'].MagicBurst = {
    main = createEquipment("Bunzi's rod"),
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment('Ghastly tathlum +1'),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Wicce Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Agwu's Pigaches"),
    neck = createEquipment("Src. Stole +2"),
    waist = createEquipment("Hachirin-no-obi"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = createEquipment("Freke Ring"),
    right_ring = createEquipment("Metamor. Ring +1"),
    back = createEquipment("Taranus's Cape"),
}
sets.midcast['Impact'] = {
    main = createEquipment("Bunzi's Rod"),
    sub = createEquipment("Ammurapi Shield"),
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = empty,
    body = createEquipment("Twilight Cloak"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Wicce Chausses +3"),
    feet = createEquipment("Wicce Sabots +3"),
    neck = createEquipment("Src. Stole +2"),
    waist = createEquipment("Acuity Belt +1"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = createEquipment("Metamor. Ring +1"),
    back = createEquipment("Taranus's Cape", nil, nil,
        { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Spell interruption rate down-10%' }),
}
sets.midcast['Impact'].MagicBurst = sets.midcast['Impact']
sets.midcast['Meteor'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst
sets.midcast['Death'] = sets.midcast['Elemental Magic']
sets.midcast['Death'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- ================================================ Dot Sets ========================================
sets.midcast['Burn'] = {
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Wicce Petasos +3"),
    body = createEquipment("Spaekona's Coat +3"),
    hands = createEquipment("Wicce Gloves +3"),
    legs = createEquipment("Arch. Tonban +3", nil, nil, { 'Increases Elemental Magic debuff time and potency' }),
    feet = createEquipment("Arch. Sabots +3", nil, nil, { 'Increases Aspir absorption amount' }),
    neck = createEquipment("Src. Stole +2"),
    waist = createEquipment("Acuity Belt +1"),
    left_ear = createEquipment("Malignance Earring"),
    right_ear = createEquipment("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = createEquipment("Metamor. Ring +1"),
    back = createEquipment("Taranus's Cape", nil, nil,
        { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Spell interruption rate down-10%' }),
}
sets.midcast['Rasp'] = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    sub = createEquipment('Ammurapi Shield'),
    ammo = createEquipment("Oshasha's Treatise"),
    head = createEquipment('Nyame Helm'),
    body = createEquipment('Nyame Mail'),
    hands = createEquipment('Nyame Gauntlets'),
    legs = createEquipment('Nyame Flanchard'),
    feet = createEquipment('Nyame Sollerets'),
    neck = createEquipment('Fotia Gorget'),
    waist = createEquipment('Fotia Belt'),
    left_ear = createEquipment('Moonshade Earring'),
    right_ear = createEquipment('Mache Earring +1'),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment('Chirich Ring +1'),
    back = createEquipment("Taranus's Cape"),
}

sets.test = {
    main = "Bunzi's Rod",
    sub = "Ammurapi Shield",
    ammo = { name = "Ghastly Tathlum +1", augments = { 'Path: A', } },
    head = "Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands = "Wicce Gloves +3",
    legs = "Wicce Chausses +3",
    feet = "Wicce Sabots +3",
    neck = { name = "Src. Stole +2", augments = { 'Path: A', } },
    waist = { name = "Acuity Belt +1", augments = { 'Path: A', } },
    left_ear = "Malignance Earring",
    right_ear = "Regal Earring",
    left_ring = "Freke Ring",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = "Taranus's cape"
}

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = { feet = createEquipment("Herald's Gaiters") }
sets.Adoulin = set_combine(sets.MoveSpeed, { body = createEquipment("Councilor's Garb") })

-- =========================================================================================================
--                                           ManaWall Sets
-- =========================================================================================================
sets.buff['Mana Wall'] = {
    feet = createEquipment('Wicce Sabots +3'),
    back = createEquipment("Taranus's Cape"),
}
