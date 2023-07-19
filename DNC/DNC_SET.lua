-- ********************************************** PIECES AUGMENTABLES ***************************************
AdhemarBonnet = {
    name = 'Adhemar Bonnet +1',
    augments = {'STR+12', 'DEX+12', 'Attack+20'}
}

AdhemarWrist = {
    name = 'Adhemar Wrist. +1',
    augments = {'STR+12', 'DEX+12', 'Attack+20'}
}

SamnuhaTights = {
    name = 'Samnuha Tights',
    augments = {'STR+8', 'DEX+9', '"Dbl.Atk."+3', '"Triple Atk."+2'}
}

LustraLeggings = {
    name = 'Lustra. Leggings +1',
    augments = {'HP+65', 'STR+15', 'DEX+15'}
}

MoonShadeEarring = {
    name = 'Moonshade Earring',
    augments = {'Accuracy+4', 'TP Bonus +250'}
}

HerculeanHelm = {
    name = 'Herculean Helm',
    augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
}

HerculeanBody = {
    name = 'Herculean Vest',
    augments = {'"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9'}
}

HerculeanLegs = {
    name = 'Herculean Trousers',
    augments = {'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}
}

ChirichRing1 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 1'
}

ChirichRing2 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 2'
}

ShivaRing1 = {
    name = 'Shiva Ring',
    bag = 'wardrobe 1'
}

ShivaRing2 = {
    name = 'Shiva Ring',
    bag = 'wardrobe 2'
}

HercAeoHead = {
    name = 'Herculean Helm',
    augments = {'"Mag.Atk.Bns."+20', 'Weapon skill damage +5%', 'INT+8', 'Mag. Acc.+1'}
}

HercAeoBody = {
    name = 'Herculean Vest',
    augments = {'"Mag.Atk.Bns."+29', 'CHR+4', 'Accuracy+13 Attack+13', 'Mag. Acc.+16 "Mag.Atk.Bns."+16'}
}

HercAeoHands = {
    name = 'Herculean Gloves',
    augments = {'Rng.Acc.+25', 'Pet: Mag. Acc.+18', 'Weapon skill damage +7%', 'Mag. Acc.+20 "Mag.Atk.Bns."+20'}
}

HercAeoLegs = {
    name = 'Herculean Trousers',
    augments = {'"Mag.Atk.Bns."+14', 'Weapon skill damage +2%', 'Accuracy+5 Attack+5', 'Mag. Acc.+17 "Mag.Atk.Bns."+17'}
}

HercAeoFeet = {
    name = 'Herculean Boots',
    augments = {'"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9'}
}

Senuna = {}

Senuna.STP = {
    name = "Senuna's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%'}
}

Senuna.WS1 = {
    name = "Senuna's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%'}
}

-- ********************************************** SETS ******************************************************

--------------------------------------------------------------
-- Déplacement speed +
-- La D.Ring est équipé pour combler la perte de DT des feets.
--------------------------------------------------------------
sets.MoveSpeed = {
    feet = "Skadi's Jambeaux +1",
    right_ring = 'Defending Ring'
}

---------------------
-- Treasure Hunter. -
---------------------
sets.TreasureHunter = {
    head = HerculeanHelm,
    legs = HerculeanLegs
}

--------------------
-- Precast Sets.   -
--------------------
sets.precast.JA['No Foot Rise'] = {
    body = 'Horos Casaque +3'
}

sets.precast.JA['Trance'] = {
    head = 'Horos Tiara +3'
}

sets.precast.JA['Provoke'] = {
    ammo = 'Sapience Orb',
    body = {
        name = 'Emet Harness +1',
        augments = {'Path: A'}
    },
    hands = {
        name = 'Horos Bangles +3',
        augments = {'Enhances "Fan Dance" effect'}
    },
    neck = {
        name = 'Unmoving Collar +1',
        augments = {'Path: A'}
    },
    waist = 'Trance Belt',
    left_ear = 'Friomisi Earring',
    left_ring = 'Provocare Ring',
    right_ring = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

sets.precast.JA['Fan Dance'] = {
    hands = {
        name = 'Horos Bangles +3',
        augments = {'Enhances "Fan Dance" effect'}
    }
}

-- *********
-- * WALTZ *
-- *********
sets.precast.Waltz = {
    ammo = 'Staunch Tathlum',
    head = 'Anwig Salade',
    body = 'Maxixi Casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Dashing Subligar',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Cryptic Earring',
    right_ear = 'Enchntr. Earring +1',
    left_ring = 'Asklepian Ring',
    right_ring = 'Defending Ring',
    back = 'Toetapper Mantle'
}

-- *****************
-- * HEALING WALTZ *
-- *****************
sets.precast.Waltz['Healing Waltz'] = set_combine(sets.precast.Waltz, {})

-- *********
-- * SAMBA *
-- *********
sets.precast.Samba = {
    head = 'Maxixi Tiara +2',
    back = Senuna.STP
}

-- *******
-- * JIG *
-- *******
sets.precast.Jig = {
    legs = 'horos tights +3',
    feet = 'Maxixi Toe Shoes +2'
}

-- ********
-- * STEP *
-- ********
sets.precast.Step = {
    ammo = 'Ginsen',
    head = 'Maxixi Tiara +2',
    body = 'Macu. casaque +3',
    hands = 'maxixi bangles +3',
    legs = 'Maculele Tights +3',
    feet = {
        name = 'Horos T. Shoes +3',
        augments = {'Enhances "Closed Position" effect'}
    },
    neck = 'Sanctity Necklace',
    waist = 'Grunfeld Rope',
    left_ear = 'Mache Earring +1',
    right_ear = 'Crep. Earring',
    left_ring = 'Asklepian Ring',
    right_ring = "Valseur's Ring",
    back = 'Toetapper Mantle'
}

-- ****************
-- * FEATHER STEP *
-- ****************
sets.precast.Step['Feather Step'] = {
    feet = 'Maculele toe shoes +3'
}

sets.precast.Flourish1 = {}

-- ********************
-- * VIOLENT FLOURISH *
-- ********************
sets.precast.Flourish1['Violent Flourish'] = {
    head = 'Maculele Tiara +3',
    body = {
        name = 'Horos Casaque +3',
        augments = {'Enhances "No Foot Rise" effect'}
    },
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Voltsurge Torque',
    waist = 'Skrymir Cord',
    left_ear = 'Enchntr. Earring +1',
    right_ear = {
        name = 'Macu. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Store TP"+4'}
    },
    left_ring = 'Mummu Ring',
    right_ring = 'Crepuscular Ring'
}

-- *********************
-- * ANIMATED FLOURISH *
-- *********************
sets.precast.Flourish1['Animated Flourish'] = {
    ammo = 'Sapience Orb',
    body = {
        name = 'Emet Harness +1',
        augments = {'Path: A'}
    },
    hands = {
        name = 'Horos Bangles +3',
        augments = {'Enhances "Fan Dance" effect'}
    },
    neck = {
        name = 'Unmoving Collar +1',
        augments = {'Path: A'}
    },
    waist = 'Trance Belt',
    left_ear = 'Friomisi Earring',
    left_ring = 'Provocare Ring',
    right_ring = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

-- **********************
-- * DESPERATE FLOURISH *
-- **********************
sets.precast.Flourish1['Desperate Flourish'] = {
    head = 'Maculele Tiara +3',
    body = 'Macu. casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Sanctity Necklace',
    waist = 'Grunfeld Rope',
    left_ear = 'Mache Earring +1',
    right_ear = 'Crep. Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = 'Toetapper Mantle'
}

sets.precast.Flourish2 = {}

-- ********************
-- * REVERSE FLOURISH *
-- ********************
sets.precast.Flourish2['Reverse Flourish'] = {
    hands = 'Maculele Bangles +3',
    back = 'Toetapper Mantle'
}

-- *************
-- * FAST CAST *
-- *************
sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = 'Maculele Tiara +3',
    body = 'Macu. casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Voltsurge Torque',
    left_ear = 'Loquac. Earring',
    right_ear = 'Enchntr. Earring +1'
    -- ring1="Prolix Ring"
}
-- ************
-- * UTSUSEMI *
-- ************
sets.precast.FC.Utsusemi =
    set_combine(
    sets.precast.FC,
    {
        ammo = 'Sapience Orb',
        head = {
            name = 'Herculean Helm',
            augments = {
                'Mag. Acc.+14 "Mag.Atk.Bns."+14',
                'Weapon skill damage +3%',
                'Mag. Acc.+13',
                '"Mag.Atk.Bns."+15'
            }
        },
        body = 'Macu. Casaque +3',
        hands = {
            name = 'Leyline Gloves',
            augments = {'Accuracy+14', 'Mag. Acc.+13', '"Mag.Atk.Bns."+13', '"Fast Cast"+2'}
        },
        legs = 'Limbo Trousers',
        feet = 'Macu. Toe Sh. +3',
        neck = 'Voltsurge Torque',
        waist = 'Svelt. Gouriz +1',
        left_ear = 'Loquac. Earring',
        right_ear = 'Enchntr. Earring +1',
        left_ring = 'Prolix Ring',
        right_ring = 'Defending Ring',
        back = {
            name = "Senuna's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%'}
        }
    }
)

-- ****************
-- * WEAPON SKILL *
-- ****************
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = {
        name = 'Adhemar Bonnet +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    body = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs = {
        name = 'horos tights +3',
        augments = {'Enhances "Saber Dance" effect'}
    },
    feet = {
        name = 'Lustra. Leggings +1',
        augments = {'HP+65', 'STR+15', 'DEX+15'}
    },
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = {
        name = 'Moonshade Earring',
        augments = {'Accuracy+4', 'TP Bonus +250'}
    },
    right_ear = 'Odr Earring',
    left_ring = 'Regal Ring',
    right_ring = "Cornelia's Ring",
    back = Senuna.WS1
}

-- ***************
-- * EXENTERATOR *
-- ***************
sets.precast.WS['Exenterator'] =
    set_combine(
    sets.precast.WS,
    {
        body = 'Mummu Jacket +2',
        hands = 'Mummu Wrists +2',
        legs = 'Mummu Kecks +2',
        feet = 'Mummu Gamash. +2',
        left_ear = 'Sherida Earring',
        left_ring = 'Mummu Ring'
    }
)

-- ****************
-- * EVISCERATION *
-- ****************
sets.precast.WS['Evisceration'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Charis Feather',
        hands = 'Mummu Wrists +2',
        legs = {
            name = 'Samnuha Tights',
            augments = {'STR+10', 'DEX+10', '"Dbl.Atk."+3', '"Triple Atk."+3'}
        },
        left_ear = 'Sherida Earring'
    }
)

-- *****************
-- * RUDRA'S STORM *
-- *****************
sets.precast.WS["Rudra's Storm"] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Maculele Tiara +3',
        neck = 'Etoile Gorget +2',
        body = "Gleti's Cuirass",
        hands = 'maxixi bangles +3',
        waist = 'Kentarch belt +1',
        ammo = 'Charis Feather'
    }
)

-- **************
-- * SHARK BITE *
-- **************
sets.precast.WS['Shark Bite'] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Maculele Tiara +3',
        body = 'Herculean Vest',
        hands = 'maxixi bangles +3',
        waist = 'Kentarch belt +1',
        feet = 'Herculean Boots'
    }
)

-- *****************
-- * PYRRHIC KLEOS *
-- *****************
sets.precast.WS['Pyrrhic Kleos'] =
    set_combine(
    sets.precast.WS,
    {
        head = "Gleti's Mask",
        body = "Gleti's Cuirass",
        hands = "Gleti's Gauntlets",
        legs = "Gleti's Breeches",
        feet = "Gleti's Boots"
    }
)

-- ****************
-- * AEOLIAN EDGE *
-- ****************
sets.precast.WS['Aeolian Edge'] = {
    ammo = "Oshasha's Treatise",
    head = {
        name = 'Herculean Helm',
        augments = {'Mag. Acc.+14 "Mag.Atk.Bns."+14', 'Weapon skill damage +3%', 'Mag. Acc.+13', '"Mag.Atk.Bns."+15'}
    },
    body = {
        name = 'Herculean Vest',
        augments = {'"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9'}
    },
    hands = {
        name = 'Herculean Gloves',
        augments = {'Rng.Acc.+25', 'Pet: Mag. Acc.+18', 'Weapon skill damage +7%', 'Mag. Acc.+20 "Mag.Atk.Bns."+20'}
    },
    legs = {
        name = 'Herculean Trousers',
        augments = {'"Mag.Atk.Bns."+23', 'Weapon skill damage +4%', 'INT+10', 'Mag. Acc.+5'}
    },
    feet = {
        name = 'Herculean Boots',
        augments = {'"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9'}
    },
    neck = 'Sibyl Scarf',
    waist = 'Skrymir Cord',
    left_ear = 'Sortiarius Earring',
    right_ear = 'Friomisi Earring',
    left_ring = 'Crepuscular Ring',
    right_ring = 'Shiva Ring',
    back = Senuna.WS1
}

-- **************
-- * Aeolian TH *
-- **************
sets.AeolianTH =
    set_combine(
    sets.precast.WS['Aeolian Edge'],
    {
        head = {
            name = 'Herculean Helm',
            augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
        },
        legs = {
            name = 'Herculean Trousers',
            augments = {'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}
        }
    }
)

-- ********************
-- * SKILLCHAIN BONUS *
-- ********************
sets.precast.Skillchain =
    set_combine(
    sets.precast.WS["Rudra's Storm"],
    {
        hands = 'Maculele Bangles +3',
        legs = 'maxixi tights + 2',
        right_ear = {
            name = 'Macu. Earring +1',
            augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Store TP"+4'}
        }
    }
)

-- Midcast Sets
sets.midcast.FastRecast = {}

-- Specific spells
sets.midcast.Utsusemi = set_combine(sets.precast.FC, {})

-- Sets to return to when not performing an action.

-- Resting sets
sets.resting = {}

sets.ExtraRegen = {
    head = 'Meghanada Visor +2',
    body = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs = 'Meg. Chausses +2',
    feet = 'Meg. Jam. +2',
    left_ear = 'Dawn Earring',
    right_ear = 'Infused Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2
}

-- Idle sets
sets.idle = {
    ammo = 'Aurgelmir Orb +1',
    head = "Gleti's Mask",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Gleti's Boots",
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    left_ear = 'Sherida Earring',
    right_ear = {
        name = 'Macu. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Store TP"+4'}
    },
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Senuna.STP
}

sets.idle.Town = set_combine(sets.idle, {})

sets.idle.Weak = sets.idle

-- ***********
-- * ENGAGED *
-- ***********
sets.engaged = {
    ammo = 'Aurgelmir Orb +1',
    head = {
        name = 'Adhemar Bonnet +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    body = {
        name = 'Horos Casaque +3',
        augments = {'Enhances "No Foot Rise" effect'}
    },
    hands = {
        name = 'Adhemar Wrist. +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    legs = {
        name = 'Samnuha Tights',
        augments = {'STR+10', 'DEX+10', '"Dbl.Atk."+3', '"Triple Atk."+3'}
    },
    feet = {
        name = 'Horos T. Shoes +3',
        augments = {'Enhances "Closed Position" effect'}
    },
    neck = 'Etoile Gorget +2',
    waist = 'Windbuffet Belt +1',
    left_ear = 'Sherida Earring',
    right_ear = 'Crep. Earring',
    left_ring = 'Hetairoi Ring',
    right_ring = "Epona's Ring",
    back = Senuna.STP
}

-- ********************
-- * ENGAGED ACCURACY *
-- ********************
sets.engaged.Acc =
    set_combine(
    sets.engaged,
    {
        ammo = 'Aurgelmir Orb +1',
        neck = {
            name = 'Etoile Gorget +2',
            augments = {'Path: A'}
        },
        waist = {
            name = 'Kentarch Belt +1',
            augments = {'Path: A'}
        },
        left_ear = 'Sherida Earring',
        right_ear = 'Crep. Earring',
        left_ring = 'Chirich Ring +1',
        right_ring = 'Chirich Ring +1'
    }
)

-- *******************
-- * ENGAGED EVASION *
-- *******************
sets.engaged.Evasion =
    set_combine(
    sets.engaged,
    {
        head = 'Maculele Tiara +3',
        body = 'Macu. casaque +3',
        hands = 'Macu. Bangles +3',
        legs = 'Maculele Tights +3',
        feet = 'Macu. Toe Sh. +3'
    }
)

-- ************************
-- * ENGAGED DAMAGE TAKEN *
-- ************************
sets.engaged.PDT =
    set_combine(
    sets.engaged,
    {
        head = 'Malignance Chapeau',
        body = 'Macu. casaque +3',
        hands = 'Macu. Bangles +3',
        legs = 'Malignance Tights',
        feet = 'Macu. Toe Sh. +3'
    }
)

-- ***********************************
-- * ENGAGED DAMAGE TAKEN + ACCURACY *
-- ***********************************
sets.engaged.Acc.PDT =
    set_combine(
    sets.engaged.PDT,
    {
        ammo = 'Aurgelmir Orb +1',
        head = 'Maculele Tiara +3',
        legs = 'Maculele Tights +3',
        neck = {
            name = 'Etoile Gorget +2',
            augments = {'Path: A'}
        },
        waist = {
            name = 'Kentarch Belt +1',
            augments = {'Path: A'}
        },
        left_ear = 'Sherida Earring',
        right_ear = 'Crep. Earring',
        left_ring = 'Chirich Ring +1',
        right_ring = 'Defending Ring',
        back = {
            name = "Senuna's Mantle",
            augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Damage taken-5%'}
        }
    }
)

-- ******************************
-- * ENGAGED EVASION + ACCURACY *
-- ******************************
sets.engaged.Acc.Evasion = set_combine(sets.engaged.Acc, sets.engaged.Evasion)

-- **************
-- * BUFFS SETS *
-- **************

-- ***************
-- * SABER DANCE *
-- ***************
sets.buff['Saber Dance'] = {
    legs = 'horos tights +3'
}

-- *************
-- * FAN DANCE *
-- *************
sets.buff['Fan Dance'] = {
    legs = 'horos bangles +3'
}

-- *************
-- * CLIMACTIC *
-- *************
sets.buff['Climactic Flourish'] = {
    head = 'Maculele Tiara +3'
}

function check_weaponset()
    if
        state.OffenseMode.value == 'LowAcc' or state.OffenseMode.value == 'MidAcc' or
            state.OffenseMode.value == 'HighAcc'
     then
        equip(sets[state.WeaponSet.current].Acc)
    else
        equip(sets[state.WeaponSet.current])
    end
end

function check_subset()
    equip(sets[state.SubSet.current])
end
