--============================================================--
--=                      PLD_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

--=========================================================================================================
--                                              EQUIPMENT                                                 =
--=========================================================================================================
SouvHead = {
    name = 'Souv. Schaller +1',
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'},
    priority = 24
}

SouvBody = {
    name = 'Souv. Cuirass +1',
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'},
    priority = 3
}

SouvHands = {
    name = 'Souv. Handsch. +1',
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'},
    priority = 23
}

SouvLegs = {
    name = 'Souv. Diechlings +1',
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'},
    priority = 16
}

SouvFeets = {
    name = 'Souveran Schuhs +1',
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'},
    priority = 22
}

Rudianos = {}

Rudianos.tank = {
    name = "Rudianos's Mantle",
    augments = {'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Damage taken-5%'},
    priority = 8
}

Rudianos.FCSIRD = {
    name = "Rudianos's Mantle",
    augments = {'HP+60', 'HP+18', '"Fast Cast"+10', 'Spell interruption rate down-10%'},
    priority = 8
}
Rudianos.STP = {
    name="Rudianos's Mantle", 
    augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Occ. inc. resist. to stat. ailments+10',},
    priority = 0
}
Rudianos.WS = {
    name="Rudianos's Mantle", 
    augments={'STR+20','Accuracy+20 Attack+20','STR+5','Weapon skill damage +10%',},
    priority = 0
}
Rudianos.cure = {
    name="Rudianos's Mantle", 
    augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+5','"Cure" potency +10%','Damage taken-5%',},
    priority = 0
}

JumalikHead = {
    name = 'Jumalik Helm',
    augments = {'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1'}
}
JumalikBody = {
    name = 'Jumalik Mail',
    augments = {'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2'}
}

ChirichRing1 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 1'
}

ChirichRing2 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 2'
}

-- Equipment sets for different weapons and shields
sets['Burtgang'] = {main = 'Burtgang'}
sets['Naegling'] = {main = 'Naegling'}
sets['Ochain'] = {sub = 'Ochain'}
sets['Aegis'] = {sub = 'Aegis'}
sets['Duban'] = {sub = 'Duban'}
sets['Blurred'] = {sub = 'Blurred Shield +1'}
--====================================================================================================
--                                              IDLE                                                 =
--====================================================================================================
sets.idle = {
    ammo="Staunch Tathlum +1",
    head = {name = 'Chev. Armet +3', priority = 16},
    body = {name = "Sakpata's Plate", priority = 0},
    hands = {name = "Chev. Gauntlets +3", priority = 0},
    legs = {name = 'Chev. Cuisses +3', priority = 15},
    feet = {name = 'Chev. Sabatons +3', priority = 14},
    neck = {name = 'Unmoving Collar +1', priority = 12},
    waist = {name = 'Kentarch Belt +1', priority = 0},
    left_ear = {name = 'Odnowa Earring +1', priority =  17},
    right_ear = {name = 'Chev. Earring +1', priority = 0},
    left_ring={name = "Supershear Ring", priority = 11},
    right_ring="Provocare Ring",
    back = Rudianos.tank,
}
--=======================================================================================================
--                                              REFRESH                                                 =
--=======================================================================================================
sets.latent_refresh = {
    ammo = {name = 'staunch Tathlum +1', priority = 0},
    head = JumalikHead, --Refresh 1
    neck = 'Coatl gorget +1', --Refresh 1
    left_ear = {name = 'Odnowa earring +1', priority = 15},
    right_ear = {name = 'Tuisto earring', priority = 16},
    body = JumalikBody, --Refresh 2
    hands = 'Regal Gauntlets', --Refresh 1
    left_ring = {name = 'Stikini Ring +1', wardrobe = 5},
    right_ring = {name = 'Stikini Ring +1', wardrobe = 6},
    back = Rudianos.tank,
    waist = {name = 'Platinum Moogle belt', priority = 17},
    legs = {name = 'Chev. Cuisses +3', priority = 13},
    feet = {name = 'Chev. Sabatons +3', priority = 14}
    --Total Refresh 5
}
--=========================================================================================================
--                                              PRECAST                                                   =
--                                            JOB ABILITY                                                 =
--=========================================================================================================
sets.FullEnmity = {
    -- main={name="Burtgang", priority=2},                                             --Enmity  23
    -- sub={name="Ajax +1", priority=15},                                              --Enmity  11
    ammo = {name = 'Sapience Orb', priority = 0},                                      --Enmity  02
    head = {name = 'Loess Barbuta +1', augments = {'Path: A'}, priority = 12},         --Enmity  24
    neck = {name = 'Moonlight Necklace', priority = 1},                                --Enmity  15
    left_ear = {name = 'Friomisi earring', priority = 0},                             --Enmity  02
    right_ear = {name = 'Cryptic Earring', priority = 2},                             --Enmity  04
    body = {name =  'Souv. Cuirass +1', priority = 3},                                 --Enmity  20
    hands = {name =  'Souv. Handsch. +1', priority = 11},                                --Enmity  09
    left_ring = {name = 'Apeile ring', priority = 0},                                  --Enmity  09
    right_ring = {name = 'Apeile ring +1', priority = 0},                              --Enmity  09
    back = Rudianos.tank,                                                              --Enmity  10
    waist = {name = 'Platinum Moogle Belt', priority = 13},                            --Enmity  05
    legs = {name =  'Souv. Diechlings +1', priority = 10},                              --Enmity  09
    feet = {name = "Chevalier's Sabatons +3", priority = 0}                            --Enmity  15
    --                                                                                Gear Enmity 156
    --                                                                               Crusade Enmity 186
}

sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, {body = 'Cab. Surcoat'})
sets.precast.JA['Invincible'] = set_combine(sets.FullEnmity, {legs = 'Caballarius Breeches +3'})
sets.precast.JA['Holy Circle'] = set_combine(sets.FullEnmity, {feet = 'Rev. Leggings'})
sets.precast.JA['Shield Bash'] = set_combine(sets.FullEnmity, {hands = {name = 'Cab. Gauntlets +3', priority = 0}})
sets.precast.JA['Sentinel'] = set_combine(sets.FullEnmity, {feet = 'Cab. Leggings +3'})
sets.precast.JA['Rampart'] = set_combine(sets.FullEnmity, {head = 'Cab. Coronet'})
--=========================================================================================================
--                                              SETS PRECAST                                              =
--                                               FAST CAST                                                =
--=========================================================================================================
sets.precast.FC = {
    --[[ main={name="Sakpata's Sword", priority=15},
    sub={name="Priwen", priority=14}, ]]
    ammo = {name = 'Sapience Orb', priority = 5},
    head = {name = 'Carmine Mask +1', priority = 0},
    neck = {name = 'Voltsurge Torque', priority = 11},
    left_ear = {name = "Enchanter's earring +1", priority = 3},
    right_ear = {name = 'Loquac. Earring', priority = 4},
    body = {name = 'Reverence surcoat +3', priority = 13},
    hands = {name = 'Leyline Gloves', priority = 1},
    left_ring = {name = 'Gelatinous Ring +1', priority = 10},
    right_ring = {name = 'Moonbeam Ring', priority = 9, bag = 'wardrobe 3'},
    back = Rudianos.FCSIRD,
    waist = {name = 'Platinum Moogle Belt', priority = 12},
    legs = {name = 'Odyssean Cuisses', priority = 2},
    feet = {name = "Chevalier's Sabatons +3", priority = 0}
}

sets.precast.FC['Healing Magic'] = sets.precast.FC
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Phalanx'] = sets.precast.FC
sets.precast.FC['Crusade'] = sets.precast.FC
sets.precast.FC['Cocoon'] = sets.precast.FC
sets.precast.FC['Flash'] = sets.precast.FC
sets.precast.FC['Banish'] = sets.precast.FC
sets.precast.FC['Blank Gaze'] = sets.precast.FC
sets.precast.FC['Jettatura'] = sets.precast.FC
sets.precast.FC['Sheep Song'] = sets.precast.FC
sets.precast.FC['Geist Wall'] = sets.precast.FC
sets.precast.FC['Sandspin'] = sets.precast.FC
--=========================================================================================================
--                                              ENMITY                                                    =
--=========================================================================================================
sets.midcast.Enmity = sets.FullEnmity
--=========================================================================================================
--                                              PHALANX                                                   =
--=========================================================================================================
sets.midcast.Phalanx = {
    --[[ main={name="Sakpata's Sword", priority=0},
    sub={ name="Priwen", priority=15}, ]]
    ammo = {name = 'Sapience Orb', priority = 0},
    head = {name = 'Yorium Barbuta', priority = 13},
    neck = {name = 'Loricate Torque +1', priority = 0},
    right_ear = {name = 'Cryptic Earring', priority = 12},
    left_ear = {name = 'Andoaa earring', priority = 0},
    body = {name = 'Yorium Cuirass', priority = 0},
    hands = {name = 'Souv. Handsch. +1', priority = 14},
    left_ring = {name = 'Gelatinous Ring +1', priority = 0},
    right_ring = {name = 'Moonbeam Ring', priority = 0, bag = 'wardrobe 3'},
    back = {name = 'Weard Mantle', priority = 1},
    waist = {name = 'Olympus sash', priority = 0},
    legs = {name = "Sakpata's Cuisses", priority = 1},
    feet = {name = 'Souveran Schuhs +1', priority = 0}
}
--=========================================================================================================
--                                              SIRD                                                      =
--=========================================================================================================
sets.midcast.SIRD = {
    --[[ main={name="Burtgang", priority=0},
    sub={name="Ajax +1", priority=16}, ]]
    ammo = {name = 'staunch Tathlum +1', priority = 0},
    head = {name = 'Loess barbuta +1', priority = 0},
    neck = {name = 'Moonlight Necklace', priority = 8},
    left_ear = {name = 'Etiolation Earring', priority = 10},
    right_ear = {name = 'Cryptic Earring', priority = 11},
    body = {name = 'Reverence surcoat +3', priority = 14},
    hands = {name = 'Regal Gauntlets', priority = 15},
    left_ring = {name = 'Gelatinous Ring +1', priority = 13},
    right_ring = {name = 'Moonbeam Ring', priority = 12, bag = 'wardrobe 3'},
    back = Rudianos.tank,
    waist = {name = 'Audumbla Sash', priority = 4},
    legs = {name = "Founder's Hose", priority = 1},
    feet = {name = 'Odyssean greaves', priority = 2}
}
--=========================================================================================================
--                                              SETS CURE                                                 =
--=========================================================================================================
sets.midcast.Cure = {
    --[[ main={name="Burtgang", priority=0},
    sub={ name="Ajax +1" , priority=13}, ]]
    ammo = {name = 'staunch Tathlum +1', priority = 1},
    head = SouvHead,
    neck = {name = 'Unmoving Collar +1', priority = 16},
    left_ear = {name = 'tuisto Earring', priority = 15},
    right_ear = {name = 'Chev. Earring +1', priority = 0},
    body = {name = 'Rev. Surcoat +3', priority = 2},
    hands = {name = 'Regal Gauntlets', priority = 14},
    left_ring = {name = 'Supershear Ring', priority = 5},
    right_ring = {name = 'Defending Ring', priority = 6},
    back = Rudianos.cure,
    waist = {name = 'Plat. Mog. Belt', priority = 4},
    legs = {name = "Founder's Hose", priority = 8},
    feet = {name = 'Odyssean Greaves', priority = 9}
}
--=========================================================================================================
--                                              ENLIGHT                                                   =
--=========================================================================================================
sets.midcast['Enlight'] =
    set_combine(
        sets.midcast.SIRD,
    {
        head = JumalikHead,
        body = 'Reverence surcoat +3',
        hands = 'Eschite Gauntlets',
        waist = 'Asklepian belt',
        back = {name = "Moonbeam Cape", priority = 16},
        left_ear = "Knight's Earring",
    }
)
--=========================================================================================================
--                                              OTHERS                                                    =
--=========================================================================================================
sets.midcast.FastRecast = {}

sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Phalanx'] = sets.midcast.Phalanx
sets.midcast['Cocoon'] = set_combine(sets.FullEnmity, sets.midcast.SIRD)
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Geist Wall'] = set_combine(sets.FullEnmity, sets.midcast.SIRD)
sets.midcast['Sheep Song'] = set_combine(sets.FullEnmity, sets.midcast.SIRD)
sets.midcast['Blank Gaze'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.FullEnmity

sets.midcast['Enhancing Magic'] =
    set_combine(
    sets.midcast.SIRD,
    {
        body = {name = 'Shabti Cuirass', priority = 0},
        hands = {name = 'Regal Gauntlets', priority = 20}
    }
)

sets.midcast['Crusade'] =
    set_combine(
    sets.midcast.SIRD,
    {
        head = SouvHead,
        body = {name = 'Shabti Cuirass', priority = 0}
    }
)

sets.midcast['Reprisal'] =
    set_combine(
    sets.midcast.SIRD,
    {
        body = {name = 'Shabti Cuirass', priority = 0},
        hands = {name = 'Regal Gauntlets', priority = 20}
    }
)

sets.midcast.Protect = sets.midcast['Enhancing Magic']
sets.midcast.Shell = sets.midcast['Enhancing Magic']
--=========================================================================================================
--                                              PRECAST                                                   =
--                                            WEAPON SKILL                                                =
--=========================================================================================================
sets.precast.WS = {
    ammo={name = "Aurgelmir Orb +1", priority = 1},
    head={name = "Hjarrandi Helm", priority = 10},
    body={name = "Rev. Surcoat +3", priority = 13},
    hands={ name="Odyssean Gauntlets", priority = 9},
    legs={name = "Chev. Cuisses +3", priority = 2},
    feet={name = "Sulev. Leggings +2", priority = 8},
    neck={name = "Fotia Gorget", priority = 0},
    waist={name = "Sailfi Belt +1", priority = 3},
    left_ear={ name="Odnowa Earring +1", priority = 12},
    right_ear={name = "Thrud Earring", priority = 4},
    left_ring={name = "Cornelia's Ring", priority = 5},
    right_ring={name = "Regal Ring", priority = 11},
    back= Rudianos.WS,
}

sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS.Acc, {})

sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Chant du Cygne'].Acc = set_combine(sets.precast.WS.Acc, {})

sets.precast.WS['Sanguine Blade'] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Nyame Helm',
        body = 'Nyame Mail',
        hands = 'Nyame Gauntlets',
        legs = 'Nyame Flanchard',
        feet = 'Nyame Sollerets',
        neck = 'Sanctity Necklace',
        waist = 'Skrymir Cord',
        left_ear = 'Friomisi Earring',
        right_ring = 'Regal Ring',
        back = 'Toro Cape'
    }
)

sets.precast.WS['Atonement'] = set_combine(sets.precast.WS, sets.FullEnmity)

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
--=========================================================================================================
--                                              DEFENSE                                                   =
--=========================================================================================================
sets.defense.MDT = {
    main = 'Burtgang',
    sub = 'Aegis',
    ammo = 'staunch Tathlum +1',
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sakpata's Leggings",
    neck = {name = 'Unmoving Collar +1', augments = {'Path: A'}},
    waist = 'Asklepian Belt',
    left_ear = 'Eabani Earring',
    right_ear = {
        name = 'Chev. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Damage taken-4%'}
    },
    left_ring = {name = 'Moonbeam Ring', bag = 'wardrobe 2'},
    right_ring = {name = 'Moonbeam Ring', bag = 'wardrobe 3'},
    back = {
        name = "Rudianos's Mantle",
        augments = {'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Damage taken-5%'}
    }
}
--=========================================================================================================
--                                              ENGAGED                                                   =
--=========================================================================================================
sets.engaged =
    set_combine(
    sets.idle,
    {
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Rudianos.STP,
    })

sets.engaged.PDT =
    set_combine(
    sets.idle,
    {
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Rudianos.STP,
    })
--=========================================================================================================
--                                              MOVESPEED                                                 =
--=========================================================================================================
sets.MoveSpeed = {
    legs = {name = 'Carmine Cuisses +1', priority = 2},
    waist = {name = "Audumbla sash", priority = 3},
    right_ring = {name = "Defending Ring", priority = 1}
}
--=========================================================================================================
--                                              CUSTOM BUFF                                               =
--=========================================================================================================
sets.buff.Doom = {
    neck = "Nicander's Necklace"
}