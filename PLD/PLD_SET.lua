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
    tank = createEquipment("Rudianos's Mantle", 1, nil,
        { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', }),
    FCSIRD = createEquipment("Rudianos's Mantle", 12, nil,
        { 'HP+60', 'HP+20', '"Fast Cast"+10', 'Spell interruption rate down-10%' }),
    STP = createEquipment("Rudianos's Mantle", 0, nil,
        { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Occ. inc. resist. to stat. ailments+10' }),
    WS = createEquipment("Rudianos's Mantle", 0, nil,
        { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' }),
    cure = createEquipment("Rudianos's Mantle", 0, nil,
        { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Phys. dmg. taken-10%' })
}

JumalikHead = createEquipment('Jumalik Helm', 0, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = createEquipment('Jumalik Mail', 0, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

ChirichRing1 = createEquipment('Chirich Ring +1', 0, 'wardrobe 1')
ChirichRing2 = createEquipment('Chirich Ring +1', 0, 'wardrobe 2')
StikiRing1 = createEquipment('Stikini Ring +1', 0, 'wardrobe 6')
StikiRing2 = createEquipment('Stikini Ring +1', 0, 'wardrobe 7')
Moonlight1 = createEquipment('MoonLight Ring', 13, 'Wardrobe 2')
Moonlight2 = createEquipment('MoonLight Ring', 12, 'Wardrobe 4')

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Burtgang'] = { main = createEquipment('Burtgang') }
sets['Shining One'] = { main = createEquipment('Shining One'), sub = createEquipment('Alber Strap') }
sets['Naegling'] = { main = createEquipment('Naegling') }
sets['Malevo'] = {
    main = createEquipment("Malevolence", 0, nil,
        { 'INT+10', 'Mag. Acc.+10', '"Mag.Atk.Bns."+8', '"Fast Cast"+5' })
}
-- =========================================================================================================
sets['Ochain'] = { sub = createEquipment('Ochain') }
sets['Alber'] = { sub = createEquipment('Alber Strap') }
sets['Aegis'] = { sub = createEquipment('Aegis') }
sets['Duban'] = { sub = createEquipment('Duban') }
sets['Blurred'] = { sub = createEquipment('Blurred Shield +1') }

sets['Staunch'] = { ammo = createEquipment('Staunch Tathlum +1') }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    ammo = createEquipment('Staunch Tathlum +1', 0),        -- DT -3%, Status resistance +11, Spell interruption rate -11%
    head = createEquipment('Chev. Armet +3', 12),           -- HP+145, DT -11%, Converts 8% of physical damage to MP
    body = createEquipment("Adamantite Armor", 13),         -- HP+182, DT -20%, Very high DEF
    hands = createEquipment("Chev. Gauntlets +3", 8),       -- HP+64, DT -11%, Shield block bonus
    legs = createEquipment('Chev. Cuisses +3', 10),         -- HP+127, DT -13%, Enmity+14
    feet = createEquipment('Chev. Sabatons +3', 6),         -- HP+52, Completes set bonus for damage absorption
    neck = createEquipment('Kgt. beads +2', 7),             -- HP+60, DT -7%, Enmity+10
    waist = createEquipment('Null Belt', 0),                -- Magic defense bonus, no HP gain
    left_ear = createEquipment('Odnowa Earring +1', 9),     -- HP+110, DT -3%, MDT -2%
    right_ear = createEquipment('Chev. Earring +1', 0),     -- DT -4%, Cure potency +11%
    left_ring = createEquipment('Fortified Ring', 5),       -- MDT -5%, Reduces enemy critical hit rate
    right_ring = createEquipment('Gelatinous Ring +1', 11), -- HP+100, PDT -7%, VIT+15
    back = Rudianos.tank                                    -- PDT -10%, VIT+20, Enmity+10
}

sets.idle_After_Cure = {
    ammo = createEquipment('Staunch Tathlum +1', 0),        -- DT -3%, Status resistance +11, Spell interruption rate -11%
    head = createEquipment('Chev. Armet +3', 12),           -- HP+145, DT -11%, Converts 8% of physical damage to MP
    body = createEquipment("Adamantite Armor", 13),         -- HP+182, DT -20%, Very high DEF
    hands = createEquipment("Chev. Gauntlets +3", 8),       -- HP+64, DT -11%, Shield block bonus
    legs = createEquipment('Chev. Cuisses +3', 10),         -- HP+127, DT -13%, Enmity+14
    feet = createEquipment('Chev. Sabatons +3', 6),         -- HP+52, Completes set bonus for damage absorption
    neck = createEquipment('Kgt. beads +2', 7),             -- HP+60, DT -7%, Enmity+10
    waist = createEquipment('Asklepian Belt', 0),           -- Magic defense bonus, no HP gain
    left_ear = createEquipment('Odnowa Earring +1', 9),     -- HP+110, DT -3%, MDT -2%
    right_ear = createEquipment('Chev. Earring +1', 0),     -- DT -4%, Cure potency +11%
    left_ring = createEquipment('Fortified Ring', 5),       -- MDT -5%, Reduces enemy critical hit rate
    right_ring = createEquipment('Gelatinous Ring +1', 11), -- HP+100, PDT -7%, VIT+15
    back = Rudianos.tank                                    -- PDT -10%, VIT+20, Enmity+10
}


sets.idle.PDT = sets.idle

sets.idle.MDT = {
    sub = createEquipment('Aegis'),
    ammo = "Staunch Tathlum +1",
    head = { name = "Sakpata's Helm", augments = { 'Path: A', } },
    body = { name = "Sakpata's Plate", augments = { 'Path: A', } },
    hands = { name = "Sakpata's Gauntlets", augments = { 'Path: A', } },
    legs = { name = "Sakpata's Cuisses", augments = { 'Path: A', } },
    feet = { name = "Sakpata's Leggings", augments = { 'Path: A', } },
    neck = "Moonlight Necklace",
    waist = "Carrier's Sash",
    left_ear = "Tuisto Earring",
    right_ear = "Eabani Earring",
    left_ring = "Purity Ring",
    right_ring = { name = "Gelatinous Ring +1", augments = { 'Path: A', } },
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
}

sets.idleNormal = set_combine(sets.idle, {
    head = createEquipment('Chev. Armet +3', 14),
    body = createEquipment("Adamantite Armor", 15),
    legs = createEquipment('Chev. Cuisses +3', 16),
    neck = createEquipment("Kgt. beads +2", 17),
    waist = createEquipment("Creed Baudrier", 18),
    Left_ring = Moonlight1,
    right_ring = Moonlight2,
})

sets.idleXp = set_combine(sets.idle, {
    main = "Burtgang",
    sub = "Duban",
    body = createEquipment('Chev. Cuirass +3', 16),
})

sets.idle.Town = {
    ammo = createEquipment("Staunch Tathlum +1", 0),
    head = createEquipment("Chev. Armet +3", 0),
    body = createEquipment("Jumalik Mail", 0),
    hands = createEquipment("Regal Gauntlets", 13),
    legs = createEquipment("Carmine Cuisses +1", 12),
    feet = createEquipment("Chev. Sabatons +3", 1),
    neck = createEquipment("Coatl Gorget +1", 0),
    waist = createEquipment("Plat. Mog. Belt", 8),
    left_ear = createEquipment("Etiolation Earring", 0),
    right_ear = createEquipment("Chev. Earring +1", 0),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = Rudianos.tank,
}

sets.latent_refresh = {
    ammo = "Staunch Tathlum +1",
    head = "Chev. Armet +3",
    body = { name = "Jumalik Mail", augments = { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2', } },
    hands = "Regal Gauntlets",
    legs = { name = "Carmine Cuisses +1", augments = { 'HP+80', 'STR+12', 'INT+12', } },
    feet = "Chev. Sabatons +3",
    neck = "Coatl Gorget +1",
    waist = "Plat. Mog. Belt",
    left_ear = "Etiolation Earring",
    right_ear = { name = "Chev. Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Damage taken-4%', } },
    left_ring = "Stikini Ring +1",
    right_ring = "Stikini Ring +1",
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
    -- Total Refresh 5
}

-- =========================================================================================================
--                                           Equipments - FullEnmity Sets
-- =========================================================================================================
sets.FullEnmity = {
    --[[ sub = createEquipment('Srivatsa', 14), ]]       -- Optionnel : Bouclier avec DT élevé
    ammo = createEquipment('Sapience Orb', 3),           -- Enmity+2, Fast Cast+2%
    head = createEquipment('Loess Barbuta +1', 10),      -- HP+105, Enmity+14, DT-10%
    neck = createEquipment('Moonlight Necklace', 2),     -- Enmity+15, SIRD+15%
    left_ear = createEquipment("Trux Earring", 6),       -- Enmity+5
    right_ear = createEquipment('Cryptic Earring', 8),   -- HP+40, Enmity+4
    body = createEquipment('Souv. Cuirass +1', 11),      -- HP+66, Enmity+11, DT-10%
    hands = createEquipment('Souv. Handsch. +1', 13),    -- HP+134, Enmity+9, MDT-5%
    left_ring = createEquipment('Apeile Ring +1', 5),    -- Enmity+9, Regen+4
    right_ring = createEquipment('Apeile Ring', 4),      -- Enmity+9, Regen+3
    back = Rudianos.tank,                                -- VIT+20, Enmity+10, PDT-10%
    waist = createEquipment('Creed Baudrier', 7),        -- HP+40, Enmity+5
    legs = createEquipment('Souv. Diechlings +1', 12),   -- HP+57, Enmity+9, DT-4%
    feet = createEquipment("Chevalier's Sabatons +3", 9) -- HP+52, Enmity+15, Fast Cast+13%
    -- Gear Enmity 159
    -- Crusade Enmity 189
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity, { feet = createEquipment("Chevalier's Sabatons +3") })
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
    ammo = createEquipment('Sapience Orb', 5),               -- Fast Cast +2%, Enmity+2
    head = createEquipment('Carmine Mask +1', 8),            -- HP+38, Fast Cast +14%
    neck = createEquipment("Orunmila's Torque", 6),          -- MP+30, Fast Cast +5%
    left_ear = createEquipment("Enchanter's Earring +1", 1), -- Fast Cast +2%
    right_ear = createEquipment('Loquac. Earring', 2),       -- MP+30, Fast Cast +2%
    body = createEquipment('Reverence Surcoat +3', 13),      -- **HP+254**, Fast Cast +10%, DT -11%
    hands = createEquipment('Leyline Gloves', 7),            -- **HP+25**, Fast Cast +8%
    left_ring = createEquipment('Kishar Ring', 4),           -- Fast Cast +4%
    right_ring = createEquipment('Prolix Ring', 3),          -- Fast Cast +2%
    back = Rudianos.FCSIRD,                                  -- **HP+80**, Fast Cast +10%, SIRD -10%
    waist = createEquipment('Platinum Moogle Belt', 11),     -- **HP+10%**, DT -3%
    legs = createEquipment('Enif Cosciales', 9),             -- **HP+40**, Fast Cast +8%
    feet = createEquipment("Chevalier's Sabatons +3", 10)    -- **HP+52**, Fast Cast +13%
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
    head = createEquipment('Loess barbuta +1', 12),
    body = createEquipment("Souv. Cuirass +1", 13),
    hands = createEquipment('Regal Gauntlets', 15),
    legs = createEquipment("Founder's Hose", 1),
    feet = createEquipment('Odyssean greaves', 9),
    neck = createEquipment('Moonlight Necklace', 8),
    waist = createEquipment("Creed Baudrier", 10),
    left_ear = createEquipment('Tuisto Earring', 14),
    right_ear = createEquipment("Knightly Earring"),
    left_ring = createEquipment("Apeile ring +1"),
    right_ring = createEquipment('Gelatinous Ring +1', 11),
    back = Rudianos.tank
}
-- Gear Enmity 115
-- Crusade Enmity 145

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================

-- ================================================ Phalanx Sets ===========================================
sets.midcast.PhalanxPotency = {
    --[[ main = cereateEquipment("Sakpata's Sword"), ]]
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Odyssean helm', 13),
    neck = createEquipment("Colossus's Torque"),
    left_ear = createEquipment('Tuisto Earring', 12),
    right_ear = createEquipment('Chev. Earring +1'),
    body = createEquipment('Odyssean Chestplate'),
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
    head = createEquipment("Odyssean Helm"),
    body = createEquipment("Odyssean Chestplate"),
    hands = createEquipment("Souv. Handsch. +1"),
    legs = createEquipment("Founder's Hose"),
    feet = createEquipment("Odyssean Greaves", 0, nil,
        { 'Pet: "Mag.Atk.Bns."+20', 'Pet: Mag. Acc.+7', 'Phalanx +4', 'Accuracy+18 Attack+18' }),
    neck = createEquipment("Moonlight Necklace"),
    waist = createEquipment("Audumbla Sash"),
    left_ear = createEquipment("Knightly Earring"),
    right_ear = createEquipment("Odnowa Earring +1"),
    left_ring = createEquipment("Defending Ring"),
    right_ring = createEquipment("Gelatinous Ring +1"),
    back = createEquipment("Weard Mantle", 0, nil, { 'VIT+4', 'Phalanx +5' })
}

-- ================================================ Enlight Sets ==========================================
sets.midcast['Enlight'] = set_combine(sets.midcast.SIRDEnmity, {
    head = JumalikHead, --Refresh 1
    body = createEquipment('Reverence surcoat +3'),
    hands = createEquipment('Eschite Gauntlets'),
    waist = createEquipment('Asklepian belt'),
    back = createEquipment("Moonlight Cape", 16),
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
    head = createEquipment('Souv. Schaller +1', 8),
    left_ear = createEquipment('tuisto Earring', 10),
    right_ear = createEquipment('Chev. Earring +1', 0),
    hands = createEquipment('Regal Gauntlets', 7),
    back = createEquipment('Moonlight Cape', 12),
    legs = createEquipment("Founder's Hose", 0),
    feet = createEquipment('Odyssean Greaves', 5)
}

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Breastplate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sulevia's Leggings +2",
    neck = "Knight's bead Necklace +2",
    waist = createEquipment("Sailfi Belt +1", 3),
    left_ear = "Ishvara Earring",
    right_ear = "Thrud Earring",
    left_ring = "Cornelia's Ring",
    right_ring = "Sroda Ring",
    back = Rudianos.WS
}

sets.precast.WS.Acc = set_combine(sets.precast.WS, {})
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Atonement'] = sets.FullEnmity

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Crepuscular pebble"),
    head = createEquipment("Sakpata's Helm"),
    body = createEquipment("Sakpata's Plate"),
    hands = createEquipment("Sakpata's Gauntlets"),
    legs = createEquipment("Sakpata's Cuisses"),
    feet = createEquipment("Sulev. Leggings +2"),
    neck = createEquipment("Kgt. Beads +2"),
    waist = createEquipment("Sailfi Belt +1"),
    left_ear = createEquipment("Tuisto Earring"),
    right_ear = createEquipment("Thrud Earring"),
    left_ring = createEquipment("Cornelia's ring"),
    right_ring = createEquipment("Gelatinous ring +1"),
    back = Rudianos.WS
})

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
    ammo = createEquipment("Oshasha's treatise"),
    head = createEquipment("Nyame Helm"),
    body = createEquipment("Nyame Mail"),
    hands = createEquipment("Nyame Gauntlets"),
    legs = createEquipment("Nyame Flanchard"),
    feet = createEquipment("Nyame Sollerets"),
    neck = createEquipment("Baetyl Pendant"),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment("Crematio Earring"),
    right_ear = createEquipment("Friomisi Earring"),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment("Defending ring"),
    back = createEquipment("Moonlight Cape")
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
    right_ear = createEquipment("Chev. Earring +1"),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment("Regal Ring"),
    back = createEquipment("Toro Cape")
})

-- =========================================================================================================
--                                           Equipments - Magic Defense Sets
-- =========================================================================================================
sets.defense.MDT = {
    sub = createEquipment('Aegis'),
    ammo = "Staunch Tathlum +1",
    head = { name = "Sakpata's Helm", augments = { 'Path: A', } },
    body = { name = "Sakpata's Plate", augments = { 'Path: A', } },
    hands = { name = "Sakpata's Gauntlets", augments = { 'Path: A', } },
    legs = { name = "Sakpata's Cuisses", augments = { 'Path: A', } },
    feet = { name = "Sakpata's Leggings", augments = { 'Path: A', } },
    neck = "Moonlight Necklace",
    waist = "Carrier's Sash",
    left_ear = "Tuisto Earring",
    right_ear = "Eabani Earring",
    left_ring = "Purity Ring",
    right_ring = { name = "Gelatinous Ring +1", augments = { 'Path: A', } },
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = set_combine(sets.idleNormal, {
    ammo = createEquipment('Aurgelmir Orb +1', 2),      -- Pas de bonus HP
    head = createEquipment('Hjarrandi Helm', 0),        -- HP+114
    body = createEquipment('Crepuscular Mail', 13),     -- HP+228
    hands = createEquipment("Sakpata's Gauntlets", 11), -- HP+91
    legs = createEquipment('Chev. Cuisses +3', 11),     -- HP+127
    feet = createEquipment("Sakpata's Leggings", 0),    -- HP+68
    neck = createEquipment('Unmoving Collar +1', 12),   -- Pas de bonus HP
    waist = createEquipment('Sailfi Belt +1', 6),       -- Pas de bonus HP
    left_ear = createEquipment('Crep. Earring', 0),     -- Pas de bonus HP
    right_ear = createEquipment('Chev. Earring +1', 4), -- Pas de bonus HP
    left_ring = createEquipment('Moonlight Ring', 12),  -- HP+110
    right_ring = createEquipment('Chirich Ring +1', 0), -- Pas de bonus HP
    back = Rudianos.STP                                 -- Pas de bonus HP
})

sets.engaged.PDT = sets.engaged

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
}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace"), -- Reduces Doom effects
    left_ring = createEquipment("Purity Ring"),    -- Additional Doom resistance
    waist = createEquipment("Gishdubar Sash"),     -- Enhances Doom recovery effects
}
