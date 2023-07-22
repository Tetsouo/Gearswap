--============================================================--
--=                      WAR_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
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

Cichol = {}

Cichol.stp = {
    name = "Cichol's Mantle",
    augments = {'STR+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}
}

Cichol.ws1 = {
    name = "Cichol's Mantle",
    augments = {'STR+20', 'Accuracy+20 Attack+20', 'Weapon skill damage +10%'}
}

JumalikHead = {
    name = 'Jumalik Helm',
    augments = {'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1'}
}
JumalikBody = {
    name = 'Jumalik Mail',
    augments = {'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2'}
}

MoonbeamRing1 = {
    name = 'Moonbeam Ring',
    bag = 'wardrobe 2'
}

MoonbeamRing2 = {
    name = 'Moonbeam Ring',
    bag = 'wardrobe 3'
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
sets['Lycurgos'] = {main = 'Lycurgos', sub = 'Utu Grip'}
sets['Shining'] = {main = 'Shining one', sub = 'Utu Grip'}
sets['Naegling'] = {main = 'Naegling', sub = 'Blurred Shield +1'}
sets['Loxotic'] = {main = 'Loxotic Mace +1', sub = 'Blurred Shield +1'}

--====================================================================================================
--                                              IDLE                                                 =
--====================================================================================================
sets.idle = {
    ammo = 'Coiste Bodhar',
    head = 'Hjarrandi Helm',
    body = 'Hjarrandi Breast.',
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = 'Boii Calligae +3',
    neck = 'War. Beads +2',
    waist = 'Ioskeha Belt +1',
    left_ear = 'Schere Earring',
    right_ear = 'Boii Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Niqmaddu Ring',
    back = Cichol.stp
}

sets.idle.PDT =
    set_combine(
    sets.idle,
    {
        ammo = 'Coiste Bodhar',
        head = 'Hjarrandi Helm',
        body = 'Hjarrandi Breast.',
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = "Sakpata's Leggings",
        neck = {name = 'War. Beads +2', augments = {'Path: A'}},
        waist = 'Ioskeha Belt +1',
        left_ear = 'Schere Earring',
        right_ear = {
            name = 'Boii Earring +1',
            augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
        },
        left_ring = 'Chirich Ring +1',
        right_ring = 'Defending Ring',
        back = {name = "Cichol's Mantle", augments = {'STR+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}}
    }
)


sets.idle.Town =
    set_combine(
    sets.idle,
    {
        neck = 'Elite royal collar',
        feet = 'Hermes Sandals'
    }
)

--=========================================================================================================
--                                              PRECAST                                                   =
--                                            JOB ABILITY                                                 =
--=========================================================================================================
sets.FullEnmity = {
    ammo = 'Sapience Orb',
    head = SouvHead,
    body = SouvBody,
    hands = SouvHands,
    legs = SouvLegs,
    feet = SouvFeets,
    neck = 'Moonlight Necklace',
    waist = 'Trance Belt',
    left_ear = 'Cryptic Earring',
    right_ear = 'Friomisi Earring',
    left_ring = 'Provocare Ring',
    right_ring = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Jump'] = set_combine(sets.engaged)
sets.precast.JA['High Jump'] = set_combine(sets.engaged)

sets.precast.JA['Berserk'] =
    set_combine(
    sets.engaged,
    {
        body = 'Pumm. Lorica +3',
        feet = 'Agoge Calligae +3'
    }
)

sets.precast.JA['Defender'] =
    set_combine(
    sets.engaged,
    {
        hands = 'Agoge Mufflers +3'
    }
)

sets.precast.JA['Warcry'] =
    set_combine(
    sets.engaged,
    {
        head = 'Agoge Mask +3'
    }
)

sets.precast.JA['Aggressor'] =
    set_combine(
    sets.engaged,
    {
        body = 'Agoge Lorica +3'
    }
)

sets.precast.JA['Blood Rage'] =
    set_combine(
    sets.engaged,
    {
        body = 'Boii Lorica +3'
    }
)

--=========================================================================================================
--                                              PRECAST                                                   =
--                                            WEAPON SKILL                                                =
--=========================================================================================================
sets.precast.WS = {
    ammo = 'Knobkierrie',
    head = 'Agoge Mask +3',
    body = 'Pumm. Lorica +3',
    hands = 'Boii Mufflers +3',
    legs = 'Valorous Hose',
    feet = 'Sulev. Leggings +2',
    neck = {name = 'War. Beads +2', augments = {'Path: A'}},
    waist = 'Sailfi Belt +1',
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Boii Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
    },
    left_ring = 'Regal Ring',
    right_ring = "Cornelia's Ring",
    back = Cichol.ws1
}

--=========================================================================================================
--                                              DEFENSE                                                   =
--=========================================================================================================
sets.defense.MDT = {}

--=========================================================================================================
--                                              ENGAGED                                                   =
--=========================================================================================================
sets.engaged = {
    ammo = 'Coiste Bodhar',
    head = 'Hjarrandi Helm',
    body = 'Hjarrandi Breast.',
    hands = "Sakpata's Gauntlets",
    legs = {name = 'Agoge Cuisses +3', augments = {"Enhances \"Warrior's Charge\" effect"}},
    feet = 'Pumm. Calligae +3',
    neck = {name = 'War. Beads +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Schere Earring',
    right_ear = {
        name = 'Boii Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
    },
    left_ring = 'Chirich Ring +1',
    right_ring = 'Niqmaddu Ring',
    back = {name = "Cichol's Mantle", augments = {'STR+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}}
}

sets.engaged.DW = {}

sets.engaged.DW.Acc = {}

sets.engaged.PDT =
    set_combine(
    sets.idle,
    {
        ammo = 'Coiste Bodhar',
        head = 'Hjarrandi Helm',
        body = 'Hjarrandi Breast.',
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = "Sakpata's Leggings",
        neck = {name = 'War. Beads +2', augments = {'Path: A'}},
        waist = 'Ioskeha Belt +1',
        left_ear = 'Crep. Earring',
        right_ear = {
            name = 'Boii Earring +1',
            augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Crit.hit rate+4'}
        },
        left_ring = 'Chirich Ring +1',
        right_ring = 'Defending Ring',
        back = {name = "Cichol's Mantle", augments = {'STR+20', 'Accuracy+20 Attack+20', '"Dbl.Atk."+10'}}
    }
)

--=========================================================================================================
--                                              MOVESPEED                                                 =
--=========================================================================================================
sets.MoveSpeed = {
    feet = {name = "Hermes' Sandals", priority = 3}
}

--=========================================================================================================
--                                              CUSTOM BUFF                                               =
--=========================================================================================================
sets.buff.Doom = {
    neck = "Nicander's Necklace"
}