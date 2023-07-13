--============================================================--
--=                      PALADIN_SET                         =--
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
    Main = "Burtgang",                                                  --Enmity 18       |       PDTII  18
    Sub = "Duban",                                                      --Enmity  0       |        DT     0
    ammo = {name = 'Staunch tathlum', priority = 0},                    --Enmity  0       |        DT     2
    head = {name = 'Loess Barbuta +1', priority = 12},                  --Enmity 24       |        DT    20
    neck = {name = 'Creed Collar', priority = 7},                       --Enmity  0       |        DT     0
    left_ear = {name = 'Tuisto earring', priority = 16},                --Enmity  0       |        DT     0
    right_ear = {name = 'Chev. earring +1', priority = 1},              --Enmity  0       |        DT     3
    body = {name = "Sakpata's breastplate", priority = 2},              --Enmity  0       |        DT    10
    hands = {name = "Sakpata's gauntlets", priority = 1},               --Enmity  0       |        DT     8
    left_ring = {name = 'Supershear Ring', priority = 1},               --Enmity  5       |        DT     0
    right_ring = {name = 'Apeile Ring +1', priority = 1},               --Enmity  9       |        DT     0
    back = Rudianos.tank,                                               --Enmity 10       |        DT     5
    waist = {name = 'Platinum Moogle belt', priority = 17},             --Enmity  0       |        DT     3
    legs = {name = 'Chev. Cuisses +3', priority = 13},                  --Enmity  0       |        DT    13
    feet = {name = 'Chev. Sabatons +3', priority = 14}                  --Enmity 15       |        DT     0
}
--                                                            _____________________________________________________
--                                                             Gear:      Enmity 81             Total PDT   59
--                                                             Crusade:   Enmity 30             Total MDT   64
--                                                             Total:     Enmity 111            Total PDTII 77
--                                                            _____________________________________________________
--=========================================================================================================
--                                              IDLE TOWN                                                 =
--=========================================================================================================
sets.idle.Town =
    set_combine(
    sets.idle,
    {
        neck = 'Elite royal collar'
    }
)

sets.idle.Ody =
    set_combine(
    sets.idle,
    {
        head = 'Chev. Armet +3',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = "Sakpata's Leggings",
        neck = 'Loricate Torque +1',
        waist = 'Plat. Mog. Belt',
        left_ear = 'Ethereal Earring',
        right_ear = {
            name = 'Chev. Earring +1',
            augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Damage taken-4%'}
        },
        left_ring = 'Supershear Ring',
        right_ring = 'Provocare Ring',
        back = {
            name = "Rudianos's Mantle",
            augments = {'HP+60', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Damage taken-5%'}
        }
    }
)
--=======================================================================================================
--                                              REFRESH                                                 =
--=======================================================================================================
sets.latent_refresh = {
    ammo = {name = 'Staunch tathlum', priority = 0},
    head = JumalikHead, --Refresh 1
    neck = 'Coatl gorget +1', --Refresh 1
    left_ear = {name = 'Tuisto earring', priority = 16},
    right_ear = {name = 'Odnowa earring +1', priority = 15},
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
    head = {name = 'Loess Barbuta +1', augments = {'Path: A'}, priority = 14},         --Enmity  24
    neck = {name = 'Moonlight Necklace', priority = 4},                                --Enmity  15
    right_ear = {name = 'Cryptic Earring', priority = 12},                             --Enmity  04
    left_ear = {name = 'Friomisi earring', priority = 5},                              --Enmity  02
    body = SouvBody,                                                                   --Enmity  20
    hands = SouvHands,                                                                 --Enmity  09
    left_ring = {name = 'Apeile ring', priority = 1},                                  --Enmity  09
    right_ring = {name = 'Apeile ring +1', priority = 1},                              --Enmity  09
    back = Rudianos.tank,                                                              --Enmity  10
    waist = {name = 'Creed Baudrier', priority = 1},                                   --Enmity  05
    legs = SouvLegs,                                                                   --Enmity  09
    feet = {name = "Chevalier's Sabatons +3", priority = 0}                            --Enmity  15
    --                                                                                Gear Enmity 156
    --                                                                               Crusade Enmity 186
}

sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, {body = 'Cab. Surcoat'})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Invincible'] = set_combine(sets.FullEnmity, {legs = 'Caballarius Breeches +2'})
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
    ammo = {name = 'Sapience Orb', priority = 0},
    head = {name = 'Carmine Mask +1', priority = 0},
    neck = {name = 'Voltsurge Torque', priority = 6},
    left_ear = {name = "Enchanter's earring +1", priority = 0},
    right_ear = {name = 'Loquac. Earring', priority = 0},
    body = {name = 'Reverence surcoat +3', priority = 0},
    hands = {name = 'Leyline Gloves', priority = 0},
    left_ring = {name = 'Gelatinous Ring +1', priority = 13},
    right_ring = {name = 'Moonbeam Ring', priority = 12, bag = 'wardrobe 3'},
    back = Rudianos.FCSIRD,
    waist = {name = 'Platinum Moogle Belt', priority = 16},
    legs = {name = 'Odyssean Cuisses', priority = 0},
    feet = {name = "Chevalier's Sabatons +3", priority = 0}
}

sets.precast.FC.Cocoon = sets.precast.FC
sets.precast.FC.Crusade = sets.precast.FC
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
sets.midcast.Enmity = set_combine(sets.FullEnmity, {})
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
    ammo = {name = 'Staunch Tathlum', priority = 6},
    head = {name = 'Loess barbuta +1', priority = 0},
    neck = {name = 'Moonlight Necklace', priority = 8},
    left_ear = {name = 'Tuisto earring', priority = 10},
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
    ammo = {name = 'Staunch Tathlum', priority = 1},
    head = {name = 'Loess Barbuta +1', priority = 12},
    neck = {name = 'Moonlight Necklace', priority = 3},
    left_ear = {name = 'Tuisto Earring', priority = 11},
    right_ear = {name = 'Odnowa Earring +1', priority = 10},
    body = {name = 'Rev. Surcoat +3', priority = 2},
    hands = {name = 'Regal Gauntlets', priority = 14},
    left_ring = {name = 'Gelatinous Ring +1', priority = 5},
    right_ring = {name = 'Moonbeam Ring', priority = 6, bag = 'wardrobe 3'},
    back = Rudianos.tank,
    waist = {name = 'Plat. Mog. Belt', priority = 4},
    legs = {name = "Founder's Hose", priority = 8},
    feet = {name = 'Odyssean Greaves', priority = 9}
}
--=========================================================================================================
--                                              ENLIGHT                                                   =
--=========================================================================================================
sets.midcast['Enlight'] =
    set_combine(
    sets.idle,
    {
        --[[ main="Brilliance", ]]
        head = JumalikHead,
        body = 'Shabti Cuirass',
        hands = 'Regal Gauntlets'
    }
)
--=========================================================================================================
--                                              OTHERS                                                    =
--=========================================================================================================
sets.midcast.FastRecast = {}

sets.midcast.Flash = sets.midcast.Enmity
sets.midcast['Phalanx'] = sets.midcast.Phalanx
sets.midcast['Cocoon'] = set_combine(sets.midcast.Enmity, sets.midcast.SIRD)
sets.midcast['Jettatura'] = sets.midcast.Enmity
sets.midcast['Geist Wall'] = set_combine(sets.midcast.Enmity, sets.midcast.SIRD)
sets.midcast['Sheep Song'] = set_combine(sets.midcast.Enmity, sets.midcast.SIRD)
sets.midcast['Blank Gaze'] = sets.midcast.Enmity
sets.midcast['Banishga'] = sets.midcast.Enmity

sets.midcast['Enhancing Magic'] =
    set_combine(
    sets.midcast.SIRD,
    {
        body = {name = 'Shabti Cuirass', priority = 0},
        hands = {name = 'Regal Gauntlets', priority = 20}
        --[[ sub={name="Ajax +1", priority=19}, ]]
    }
)

sets.midcast.Crusade =
    set_combine(
    sets.midcast.SIRD,
    {
        head = SouvHead,
        body = {name = 'Shabti Cuirass', priority = 0}
        --[[ sub={name="Ajax +1", priority=19}, ]]
    }
)

sets.midcast['Reprisal'] =
    set_combine(
    sets.midcast.SIRD,
    {
        body = {name = 'Shabti Cuirass', priority = 0},
        hands = {name = 'Regal Gauntlets', priority = 20}
        --[[ sub={name="Ajax +1", priority=19}, ]]
    }
)

sets.midcast.Protect = sets.midcast['Enhancing Magic']
sets.midcast.Shell = sets.midcast['Enhancing Magic']
--=========================================================================================================
--                                              PRECAST                                                   =
--                                            WEAPON SKILL                                                =
--=========================================================================================================
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sulevia's leggings +2",
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = {name = 'Moonshade Earring', augments = {'Accuracy+4', 'TP Bonus +250'}},
    right_ear = 'Ishvara Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Regal Ring',
    back = Rudianos.tank
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

sets.precast.WS['Atonement'] = set_combine(sets.precast.WS, sets.midcast.Enmity)

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
--=========================================================================================================
--                                              DEFENSE                                                   =
--=========================================================================================================
sets.defense.MDT = {
    main = 'Burtgang',
    sub = 'Aegis',
    ammo = 'Staunch Tathlum',
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
sets.engaged = {
    --Main = 'Burtgang',
    sub = 'Blurred Shield +1',
    ammo = {name = 'Aurgelmir Orb +1', priority = 12},
    head = {name = 'Chev. Armet +3', priority = 16},
    body = {name = "Sakpata's Plate", priority = 0},
    hands = {name = "Sakpata's Gauntlets", priority = 0},
    legs = {name = 'Chev. Cuisses +3', priority = 15},
    feet = {name = 'Chev. Sabatons +3', priority = 14},
    neck = {name = 'Sanctity Necklace', priority = 13},
    waist = {name = 'Plat. Mog. Belt', priority = 17},
    left_ear = {name = 'Crep. Earring', priority = 0},
    right_ear = {name = 'Chev. Earring +1', priority = 0},
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Rudianos.tank
}

sets.engaged.PDT =
    set_combine(
    sets.idle,
    {
        main = 'Burtgang',
        sub = 'Duban'
    }
)
--=========================================================================================================
--                                              MOVESPEED                                                 =
--=========================================================================================================
sets.MoveSpeed = {
    legs = {name = 'Carmine Cuisses +1', priority = 3}
}
--=========================================================================================================
--                                              CUSTOM BUFF                                               =
--=========================================================================================================
sets.buff.Doom = {
    neck = "Nicander's Necklace"
}