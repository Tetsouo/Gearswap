--============================================================--
--=                      PLD_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
-- Define Rudianos set with different augments for different situations
Rudianos = {
    tank = createEquipment("Rudianos's Mantle", 8, nil,
        { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Damage taken-5%' }),
    FCSIRD = createEquipment("Rudianos's Mantle", 8, nil,
        { 'HP+60', 'HP+20', '"Fast Cast"+10', 'Spell interruption rate down-10%' }),
    STP = createEquipment("Rudianos's Mantle", 0, nil,
        { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Occ. inc. resist. to stat. ailments+10' }),
    WS = createEquipment("Rudianos's Mantle", 0, nil,
        { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%' }),
    cure = createEquipment("Rudianos's Mantle", 0, nil,
        { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%' })
}

JumalikHead = createEquipment('Jumalik Helm', 0, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = createEquipment('Jumalik Mail', 0, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

ChirichRing1 = createEquipment('Chirich Ring +1', 0, 'wardrobe 1')
ChirichRing2 = createEquipment('Chirich Ring +1', 0, 'wardrobe 2')
StikiRing1 = createEquipment('Stikini Ring +1', nil, 'wardrobe 6')
StikiRing2 = createEquipment('Stikini Ring +1', nil, 'wardrobe 7')

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Burtgang'] = { main = createEquipment('Burtgang') }
sets['Naegling'] = { main = createEquipment('Naegling') }
sets['Malevo'] = {
    main = createEquipment("Malevolence", 0, nil,
        { 'INT+10', 'Mag. Acc.+10', '"Mag.Atk.Bns."+8', '"Fast Cast"+5' })
}
-- =========================================================================================================
sets['Ochain'] = { sub = createEquipment('Ochain') }
sets['Aegis'] = { sub = createEquipment('Aegis') }
sets['Duban'] = { sub = createEquipment('Duban') }
sets['Blurred'] = { sub = createEquipment('Blurred Shield +1') }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Chev. Armet +3', 10),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment("Chev. Gauntlets +3"),
    legs = createEquipment('Chev. Cuisses +3', 15),
    feet = createEquipment('Chev. Sabatons +3', 14),
    neck = createEquipment('Kgt. beads +2'),
    waist = createEquipment("Creed Baudrier"),
    left_ear = createEquipment('Odnowa Earring +1', 17),
    right_ear = createEquipment('Chev. Earring +1'),
    left_ring = createEquipment("Moonbeam Ring", 11, 'wardrobe 2'),
    right_ring = createEquipment("Moonbeam Ring", 11, 'wardrobe 3'),
    back = Rudianos.tank
}

sets.idle.PDT = sets.idle
sets.idle.MDT = {
    sub = createEquipment('Aegis'),
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment("Sakpata's Helm"),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment("Sakpata's Gauntlets"),
    legs = createEquipment("Sakpata's Cuisses"),
    feet = createEquipment("Sakpata's Leggings"),
    neck = createEquipment('Unmoving Collar +1', 0),
    waist = createEquipment('Asklepian Belt'),
    left_ear = createEquipment('Eabani Earring'),
    right_ear = createEquipment('Chev. Earring +1', 0, nil,
        { 'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Damage taken-4%' }),
    left_ring = createEquipment("Moonbeam Ring", 19, 'wardrobe 2'),
    right_ring = createEquipment("Moonbeam Ring", 20, 'wardrobe 3'),
    back = createEquipment("Solemnity Cape")
}

sets.idleNormal = set_combine(sets.idle, {
    head = createEquipment('Chev. Armet +3', 14),
    body = createEquipment("Sakpata's Plate", 15),
    legs = createEquipment('Chev. Cuisses +3', 16),
    neck = createEquipment("Kgt. beads +2", 17),
    waist = createEquipment("Creed Baudrier", 18),
    left_ring = createEquipment("Moonbeam Ring", 19, 'wardrobe 2'),
    right_ring = createEquipment("Moonbeam Ring", 20, 'wardrobe 3')
})

sets.idleXp = set_combine(sets.idle, {
    main = "Burtgang",
    sub = "Duban",
    body = createEquipment('Chev. Cuirass +3', 16),
    waist = createEquipment('Kentarch Belt +1'),
    left_ring = createEquipment("Supershear Ring", 11),
    right_ring = createEquipment("Defending Ring")
})

sets.idle.Town = set_combine(sets.idle, {
    neck = createEquipment('Elite Royal Collar'),
    waist = createEquipment('Kentarch Belt +1'),
    left_ring = createEquipment("Supershear Ring", 11),
    right_ring = createEquipment("Provocare Ring")
})

sets.resting = set_combine(sets.idleNormal, {
    sub = createEquipment("Aegis")
})

sets.latent_refresh = {
    ammo = createEquipment('Staunch Tathlum +1'),
    head = JumalikHead,                        -- Refresh 1
    neck = createEquipment('Coatl Gorget +1'), -- Refresh 1
    left_ear = createEquipment('Odnowa Earring +1', 15),
    right_ear = createEquipment('Tuisto Earring', 16),
    body = JumalikBody,                         -- Refresh 2
    hands = createEquipment('Regal Gauntlets'), -- Refresh 1
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = Rudianos.tank,
    waist = createEquipment('Platinum Moogle Belt', 17),
    legs = createEquipment('Chev. Cuisses +3', 13),
    feet = createEquipment('Chev. Sabatons +3', 14)
    -- Total Refresh 5
}

-- =========================================================================================================
--                                           Equipments - FullEnmity Sets
-- =========================================================================================================
sets.FullEnmity = {
    --[[ sub = createEquipment('Srivatsa', 14), ]]
    ammo = createEquipment('Sapience Orb'),
    head = createEquipment('Loess Barbuta +1', 13),
    neck = createEquipment('Moonlight Necklace', 1),
    left_ear = createEquipment("Trux Earring"),
    right_ear = createEquipment('Cryptic Earring', 12),
    body = createEquipment('Souv. Cuirass +1', 16),
    hands = createEquipment('Souv. Handsch. +1', 15),
    left_ring = createEquipment('Apeile Ring +1'),
    right_ring = createEquipment('Apeile Ring'),
    back = Rudianos.tank,
    waist = createEquipment('Creed Baudrier', 11),
    legs = createEquipment('Souv. Diechlings +1', 14),
    feet = createEquipment("Chevalier's Sabatons +3", 13)
    -- Gear Enmity 159
    -- Crusade Enmity 189
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, { body = createEquipment('Cab. Surcoat') })
sets.precast.JA['Invincible'] = set_combine(sets.FullEnmity, { legs = createEquipment('Caballarius Breeches +3') })
sets.precast.JA['Holy Circle'] = set_combine(sets.FullEnmity, { feet = createEquipment('Rev. Leggings') })
sets.precast.JA['Shield Bash'] = set_combine(sets.FullEnmity, { hands = createEquipment('Cab. Gauntlets +3') })
sets.precast.JA['Sentinel'] = set_combine(sets.FullEnmity, { feet = createEquipment('Cab. Leggings +3') })
sets.precast.JA['Rampart'] = set_combine(sets.FullEnmity, { head = createEquipment('Cab. Coronet +3') })

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    ammo = createEquipment('Sapience Orb', 5),
    head = createEquipment('Carmine Mask +1'),
    neck = createEquipment("Orunmila's Torque", 11),
    left_ear = createEquipment("Enchanter's earring +1", 3),
    right_ear = createEquipment('Loquac. Earring', 4),
    body = createEquipment('Reverence surcoat +3', 13),
    hands = createEquipment('Leyline Gloves', 1),
    left_ring = createEquipment('Kishar Ring', 9),
    right_ring = createEquipment('Prolix Ring', 10),
    back = Rudianos.FCSIRD,
    waist = createEquipment('Platinum Moogle Belt', 12),
    legs = createEquipment('Enif cosciales', 2),
    feet = createEquipment("Chevalier's Sabatons +3")
}

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
sets.precast.FC['Frightful Roar'] = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Enmity Sets
-- =========================================================================================================
sets.midcast.Enmity = sets.FullEnmity

sets.midcast.SIRDEnmity = {
    --[[ sub = createEquipment('Srivatsa', 14), ]]
    ammo = createEquipment('staunch Tathlum +1'),
    head = createEquipment('Loess barbuta +1'),
    body = createEquipment("Souv. Cuirass +1", 17),
    hands = createEquipment('Regal Gauntlets', 15),
    legs = createEquipment("Founder's Hose", 1),
    feet = createEquipment('Odyssean greaves', 2),
    neck = createEquipment('Moonlight Necklace', 8),
    waist = createEquipment("Audumbla Sash"),
    left_ear = createEquipment("Trux Earring"),
    right_ear = createEquipment('Tuisto Earring', 16),
    left_ring = createEquipment("Apeile ring +1"),
    right_ring = createEquipment('Apeile ring'),
    back = Rudianos.tank
}
    -- Gear Enmity 115
    -- Crusade Enmity 145

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================

-- ================================================ Phalanx Sets ===========================================
sets.midcast.PhalanxPotency = {
    --[[ main = createEquipment("Sakpata's Sword"), ]]
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Yorium Barbuta', 13),
    neck = createEquipment("Colossus's Torque"),
    right_ear = createEquipment('Chev. Earring +1'),
    left_ear = createEquipment('Tuisto Earring', 12),
    body = createEquipment('Yorium Cuirass'),
    hands = createEquipment('Souv. Handsch. +1', 14),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = createEquipment('Weard Mantle', 1),
    waist = createEquipment("Audumbla Sash"),
    legs = createEquipment("Sakpata's Cuisses", 1),
    feet = createEquipment('Souveran Schuhs +1')
}

sets.midcast.SIRDPhalanx = {
    main = createEquipment("Sakpata's Sword"),
    sub = createEquipment("Priwen", 0, nil, { 'HP+50', 'Mag. Evasion+50', 'Damage Taken -3%' }),
    ammo = createEquipment("Staunch Tathlum +1"),
    head = createEquipment("Yorium Barbuta", 0, nil, { 'Spell interruption rate down -9%', 'Phalanx +3' }),
    body = createEquipment("Yorium Cuirass", 0, nil, { 'Spell interruption rate down -10%', 'Phalanx +3' }),
    hands = createEquipment("Souv. Handsch. +1"),
    legs = createEquipment("Founder's Hose"),
    feet = createEquipment("Odyssean Greaves"),
    neck = createEquipment("Moonlight Necklace"),
    waist = createEquipment("Audumbla Sash"),
    left_ear = createEquipment("Odnowa Earring +1"),
    right_ear = createEquipment("Chev. Earring +1"),
    left_ring = createEquipment("Gelatinous Ring +1"),
    right_ring = createEquipment("Defending Ring"),
    back = createEquipment("Weard Mantle", 0, nil, { 'VIT+4', 'Phalanx +5' })
}

-- ================================================ Enlight Sets ==========================================
sets.midcast['Enlight'] = set_combine(sets.midcast.SIRDEnmity, {
    head = JumalikHead, --Refresh 1
    body = createEquipment('Reverence surcoat +3'),
    hands = createEquipment('Eschite Gauntlets'),
    waist = createEquipment('Asklepian belt'),
    back = createEquipment("Moonbeam Cape", 16),
    left_ear = createEquipment("Knight's Earring")
})

-- ================================================ Enhancing Sets ========================================
sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.SIRDEnmity, {
    body = createEquipment('Shabti Cuirass')
})

-- ================================================ Enmity Sets ===========================================
sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
sets.midcast['Cocoon'] = sets.midcast.SIRDEnmity
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.midcast.SIRDEnmity
sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity
sets.midcast['Sheep Song'] = sets.midcast.SIRDEnmity
sets.midcast['Frightful Roar'] = sets.midcast.SIRDEnmity
sets.midcast['Blank Gaze'] = sets.midcast.SIRDEnmity
sets.midcast['Crusade'] = sets.midcast['Enhancing Magic']
sets.midcast['Reprisal'] = sets.midcast['Enhancing Magic']
sets.midcast['Protect'] = sets.midcast['Enhancing Magic']
sets.midcast['Shell'] = sets.midcast['Enhancing Magic']
sets.midcast['Refresh'] = sets.midcast.SIRDEnmity
sets.midcast['Haste'] = sets.midcast.SIRDEnmity

-- ================================================ Cure Sets ==============================================
sets.Cure = {
    ammo = createEquipment('staunch Tathlum +1', 1),
    head = createEquipment('Souv. Schaller +1', 2),
    left_ear = createEquipment('tuisto Earring', 15),
    right_ear = createEquipment('Chev. Earring +1'),
    hands = createEquipment('Regal Gauntlets', 14),
    back = Rudianos.cure,
    legs = createEquipment("Founder's Hose", 8),
    feet = createEquipment('Odyssean Greaves', 9)
}

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = createEquipment("Aurgelmir Orb +1", 1),
    head = createEquipment("Hjarrandi Helm", 10),
    body = createEquipment("Rev. Surcoat +3", 13),
    hands = createEquipment("Odyssean Gauntlets", 9),
    legs = createEquipment("Chev. Cuisses +3", 2),
    feet = createEquipment("Sulev. Leggings +2", 8),
    neck = createEquipment("Fotia Gorget"),
    waist = createEquipment("Sailfi Belt +1", 3),
    left_ear = createEquipment("Odnowa Earring +1", 12),
    right_ear = createEquipment("Thrud Earring", 4),
    left_ring = createEquipment("Cornelia's Ring", 5),
    right_ring = createEquipment("Regal Ring", 11),
    back = Rudianos.WS
}

sets.precast.WS.Acc = set_combine(sets.precast.WS, {})
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Atonement'] = set_combine(sets.precast.WS, {
    ammo = createEquipment('Sapience Orb'),
    head = createEquipment('Loess Barbuta +1', 13),
    neck = createEquipment('Moonlight Necklace', 1),
    left_ear = createEquipment('Friomisi Earring'),
    right_ear = createEquipment('Cryptic Earring', 12),
    body = createEquipment('Souv. Cuirass +1', 16),
    hands = createEquipment('Souv. Handsch. +1', 15),
    left_ring = createEquipment('Apeile Ring +1'),
    right_ring = createEquipment('Apeile Ring'),
    back = Rudianos.tank,
    waist = createEquipment('Creed Baudrier', 11),
    legs = createEquipment('Souv. Diechlings +1', 14),
    feet = createEquipment("Chevalier's Sabatons +3", 13)
})
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})

sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {
    head = createEquipment('Nyame Helm'),
    body = createEquipment('Nyame Mail'),
    hands = createEquipment('Nyame Gauntlets'),
    legs = createEquipment('Nyame Flanchard'),
    feet = createEquipment('Nyame Sollerets'),
    neck = createEquipment('Sanctity Necklace'),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment('Friomisi Earring'),
    right_ring = createEquipment('Regal Ring'),
    back = createEquipment('Toro Cape')
})

sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Staunch Tathlum +1"),
    head = createEquipment("Nyame Helm"),
    body = createEquipment("Nyame Mail"),
    hands = createEquipment("Nyame Gauntlets"),
    legs = createEquipment("Nyame Flanchard"),
    feet = createEquipment("Nyame Sollerets"),
    neck = createEquipment("Sibyl Scarf"),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment("Sortiarius Earring"),
    right_ear = createEquipment("Friomisi Earring"),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment("Defending Ring"),
    back = createEquipment("Toro Cape")
})

sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Staunch Tathlum +1"),
    head = createEquipment("Nyame Helm"),
    body = createEquipment("Nyame Mail"),
    hands = createEquipment("Nyame Gauntlets"),
    legs = createEquipment("Nyame Flanchard"),
    feet = createEquipment("Nyame Sollerets"),
    neck = createEquipment("Sibyl Scarf"),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment("Sortiarius Earring"),
    right_ear = createEquipment("Chev. Earring +1", 0, nil,
        { 'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Damage taken-4%' }),
    left_ring = createEquipment("Regal Ring"),
    right_ring = createEquipment("Cornelia's Ring"),
    back = createEquipment("Toro Cape")
})

-- =========================================================================================================
--                                           Equipments - Magic Defense Sets
-- =========================================================================================================
sets.defense.MDT = {
    sub = createEquipment('Aegis'),
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment("Sakpata's Helm"),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment("Sakpata's Gauntlets"),
    legs = createEquipment("Sakpata's Cuisses"),
    feet = createEquipment("Sakpata's Leggings"),
    neck = createEquipment('Unmoving Collar +1', 0, { 'Path: A' }),
    waist = createEquipment('Asklepian Belt'),
    left_ear = createEquipment('Eabani Earring'),
    right_ear = createEquipment('Chev. Earring +1', 0, nil,
        { 'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Damage taken-4%' }),
    left_ring = createEquipment("Moonbeam Ring", 19, 'wardrobe 2'),
    right_ring = createEquipment("Moonbeam Ring", 20, 'wardrobe 3'),
    back = createEquipment("Solemnity Cape")
}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = set_combine(sets.idleNormal, {
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Rudianos.STP
})

sets.engaged.PDT = set_combine(sets.idleNormal, {
    left_ring = ChirichRing1,
    right_ring = createEquipment('Defending Ring'),
    back = Rudianos.STP
})

sets.engaged.MDT = sets.idle.MDT

sets.meleeXp = set_combine(sets.idleXp, {
    main = createEquipment('Malevolence', nil, nil,
        { 'INT+10', 'Mag. Acc.+10', '"Mag.Atk.Bns."+8', '"Fast Cast"+5' }),
})


-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    legs = createEquipment('Carmine Cuisses +1', 2),
    waist = createEquipment('Audumbla sash', 3),
    right_ring = createEquipment('Defending Ring', 1)
}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace")
}
