--============================================================--
--=                       THF_SET                            =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

--=========================================================================================================
--                                              EQUIPMENT                                                 =
--=========================================================================================================
AdhemarBonnet = {
    name = 'Adhemar Bonnet +1',
    augments = {'STR+12', 'DEX+12', 'Attack+20'}
}

PlundererVest = {
    name = "Plunderer's Vest +3",
    augments = {'Enhances "Ambush" effect'}
}

AdhemarWrist = {
    name = 'Adhemar Wrist. +1',
    augments = {'STR+12', 'DEX+12', 'Attack+20'}
}

SamnuhaTights = {
    name = 'Samnuha Tights',
    augments = {'STR+10', 'DEX+10', '"Dbl.Atk."+3', '"Triple Atk."+3'}
}

Toutatis = {}

Toutatis.STP = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10'}
}
Toutatis.WS1 = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10'}
}

Toutatis.WS2 = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%'}
}

PlundererCulotte = {
    name = 'Plun. Culottes +3',
    augments = {'Enhances "Feint" effect'}
}

PlundererArmlets = {
    name = 'Plun. Armlets +3',
    augments = {'Enhances "Perfect Dodge" effect'}
}

AssassinGorget = {
    name = "Assassin's Gorget",
    augments = {'Path: A'}
}

CannyCape = {
    name = 'Canny Cape',
    augments = {'DEX+1', 'AGI+2', '"Dual Wield"+3', 'Crit. hit damage +3%'}
}

LustraLeggings = {
    name = 'Lustra. Leggings +1',
    augments = {'HP+65', 'STR+15', 'DEX+15'}
}

MoonShadeEarring = {
    name = 'Moonshade Earring',
    augments = {'Accuracy+4', 'TP Bonus +250'}
}

PlundererPoulaines = {
    name = 'Plun. Poulaines +3',
    augments = {"Enhances \"Assassin's Charge\" effect"}
}

HerculeanHelm = {
    name = 'Herculean Helm',
    augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
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
    augments = {'"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9'}
}

HercAeoHands = {
    name = 'Herculean Gloves',
    augments = {'Rng.Acc.+25', 'Pet: Mag. Acc.+18', 'Weapon skill damage +7%', 'Mag. Acc.+20 "Mag.Atk.Bns."+20'}
}

HercAeoLegs = {
    name = 'Herculean Trousers',
    augments = {'"Mag.Atk.Bns."+23', 'Weapon skill damage +4%', 'INT+10', 'Mag. Acc.+5'}
}

HercAeoFeet = {
    name = 'Herculean Boots',
    augments = {'"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9'}
}


sets.MoveSpeed = {
    feet = 'Pill. Poulaines +3',
    right_ring = 'Defending Ring'
}

-- Equipment sets for different weapons.
sets['TwashtarM'] = {main = 'Twashtar'}
sets['TwashtarS'] = {sub = 'Twashtar'}
sets['Tauret'] = {main = 'Tauret'}
sets['Malevolence'] = {main = 'Malevolence'}
sets['Qutrub'] = {main = 'Qutrub Knife'}
sets['Naegling'] = {main = 'Naegling'}
sets['Excalipoor'] = {main = 'Excalipoor'}
sets['Lament'] = {main = 'Lament'}
sets['Iapetus'] = {main = 'Iapetus'}
sets['Chac'] = {main = 'Chac-Chacs'}
sets['Ram'] = {main = 'Ram staff'}
sets['Crepu'] = {main = 'Crepuscular Knife'}
sets['Centovente'] = {sub = 'Centovente'}
sets['Blurred'] = {sub = 'Blurred Knife +1'}
sets['Gleti'] = {sub = "Gleti's Knife"}
sets['Sickle'] = {main = 'Lost Sickle'}

--=========================================================================================================
--                                           IDLE                                                         =
--=========================================================================================================
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
    right_ear = 'Eabani Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = 'Solemnity Cape'
}

sets.idle.Town =
    set_combine(
    sets.idle,
    {
        feet = 'Pill. Poulaines +3'
    }
)

sets.idle.Regen =
    set_combine(
    sets.idle,
    {
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
)

sets.idle.PDT =
    set_combine(
    sets.idle,
    {
        left_ring = ChirichRing1,
        right_ring = 'Defending Ring',
        left_ear = 'Sherida Earring'
    }
)

sets.idle.Weak = sets.idle

sets.defense.PDT =
    set_combine(
    sets.idle,
    {
        ammo = 'Staunch Tathlum',
        head = 'Nyame Helm',
        body = 'Nyame Mail',
        hands = "Skulker's Armlets +3",
        legs = "Skulker's culottes +3",
        feet = "Skulker's Poulaines +3",
        neck = 'Elite Royal Collar',
        waist = 'Flume Belt',
        left_ear = 'Impreg. Earring',
        right_ear = 'Eabani Earring',
        left_ring = 'Succor Ring',
        right_ring = 'Defending Ring',
        back = 'Solemnity Cape'
    }
)

sets.defense.MDT =
    set_combine(
    sets.idle,
    {
        ammo = 'Staunch Tathlum',
        head = 'Malignance Chapeau',
        body = 'Malignance tabard',
        hands = 'Nyame gauntlets',
        legs = 'Malignance tights',
        feet = 'Malignance boots',
        neck = 'Elite Royal Collar',
        waist = 'Flume Belt',
        left_ear = 'Impreg. Earring',
        right_ear = 'Eabani Earring',
        left_ring = 'Defending Ring',
        right_ring = 'Succor Ring',
        back = 'Solemnity Cape'
    }
)

--=========================================================================================================
--                                           ENGAGED                                                      =
--=========================================================================================================
sets.engaged = {
    ammo="Aurgelmir Orb +1",
    head="Skulker's Bonnet +3",
    body="Pillager's Vest +3",
    hands="Malignance Gloves",
    legs="Pill. Culottes +3",
    feet="Plun. Poulaines +3",
    neck="Asn. Gorget +2",
    waist="Windbuffet Belt +1",
    left_ear="Sherida Earring",
    right_ear="Skulk. Earring +1",
    left_ring="Hetairoi Ring",
    right_ring="Epona's Ring",
    back= Toutatis.STP
}

sets.engaged.Acc =
    set_combine(
    sets.engaged.Mid,
    {
        waist = 'Kentarch belt +1',
        left_ring = ChirichRing1,
        right_ring = ChirichRing2
    }
)

sets.engaged.PDT =
    set_combine(
    sets.engaged,
    {
    ammo="Aurgelmir Orb +1",
    head="Malignance Chapeau",
    body="Malignance Tabard",
    hands="Malignance Gloves",
    legs="Malignance Tights",
    feet="Skulk. Poulaines +3",
    neck="Asn. Gorget +2",
    waist="Kentarch Belt +1",
    left_ring="Chirich Ring +1",
    right_ring="Defending Ring",
    }
)

sets.engaged.Acc.PDT =
    set_combine(
    sets.engaged.PDT,
    {
        ammo = 'Aurgelmir Orb +1',
        head = "Skulker's Bonnet +3",
        body = 'Malignance Tabard',
        hands = 'Skulk. Armlets +3',
        legs = 'Pill. Culottes +3',
        feet = 'Skulk. Poulaines +3',
        neck = {name = "Assassin's Gorget", augments = {'Path: A'}},
        waist = {name = 'Kentarch Belt +1', augments = {'Path: A'}},
        left_ear = 'Crep. Earring',
        right_ear = {
            name = 'Skulk. Earring +1',
            augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', '"Store TP"+3'}
        },
        left_ring = ChirichRing1,
        right_ring = ChirichRing2,
        back = {name = "Toutatis's Cape", augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10'}}
    }
)

--=========================================================================================================
--                                           PRECAST                                                      =
--                                           RANGED                                                       =
--=========================================================================================================
sets.precast.RA = {
    range = 'Exalted Crossbow',
    ammo = 'Acid Bolt',
    head = 'Malignance Chapeau',
    body = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs = 'Malignance Tights',
    feet = 'Meghanada Jambeaux +2',
    neck = 'Iskur gorget',
    waist = 'Kentarch belt +1',
    left_ear = 'Crepuscular Earring',
    right_ear = 'Volley Earring',
    left_ring = 'Cacoethic Ring',
    right_ring = 'Crepuscular Ring',
    back = 'Jaeger Mantle'
}

sets.precast.RATH =
    set_combine(
    sets.precast.RA,
    {
        feet = "Skulker's Poulaines +3"
    }
)

sets.midcast.RA = sets.precast.RA


sets.midcast.RA.Acc = sets.midcast.RA

--=========================================================================================================
--                                           PRECAST                                                      =
--                                         JOB ABILITY                                                    =
--=========================================================================================================
sets.buff['Sneak Attack'] = {
    ammo = 'Yetshila +1',
    head = AdhemarBonnet,
    body = PlundererVest,
    hands = "Skulker's Armlets +3",
    legs = SamnuhaTights,
    feet = LustraLeggings,
    neck = 'Asn. Gorget +2',
    waist = 'Kentarch belt +1',
    left_ear = 'Mache Earring +1',
    right_ear = 'Odr Earring',
    left_ring = 'Regal Ring',
    right_ring = 'Ilabrat Ring',
    back = Toutatis.STP
}

sets.buff['Trick Attack'] = {
    ammo = 'Yetshila +1',
    head = "skulker's Bonnet +3",
    body = PlundererVest,
    hands = 'Pill. armlets +3',
    legs = 'Mummu Kecks +2',
    feet = "Skulker's Poulaines +3",
    neck = 'Asn. Gorget +2',
    waist = 'Svelt. Gouriz +1',
    left_ear = 'Dawn Earring',
    right_ear = 'Infused Earring',
    left_ring = 'Regal Ring',
    right_ring = 'Ilabrat Ring',
    back = CannyCape
}

sets.precast.JA['Collaborator'] = {
    head = "Skulker's bonnet +3",
    body = PlundererVest,
    hands = PlundererArmlets,
    left_ear = 'Friomisi Earring',
    left_ring = 'Cacoethic Ring'
}

sets.precast.JA['Accomplice'] = {
    head = "Skulker's bonnet +3",
    body = PlundererVest,
    hands = PlundererArmlets,
    left_ear = 'Friomisi Earring',
    left_ring = 'Cacoethic Ring'
}

sets.precast.JA['Conspirator'] = {
    body = "skulker's Vest +3"
}

sets.precast.JA['Animated Flourish'] = {
    ammo = 'Sapience Orb',
    head = "Skulker's Bonnet +3",
    body = {name = "Plunderer's Vest +3", augments = {'Enhances "Ambush" effect'}},
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = {name = 'Unmoving Collar +1', augments = {'Path: A'}},
    waist = 'Svelt. Gouriz +1',
    left_ear = 'Friomisi Earring',
    right_ear = 'Eabani Earring',
    left_ring = 'Provocare Ring',
    right_ring = 'Supershear Ring',
    back = 'Solemnity Cape'
}

sets.precast.JA['Flee'] = {
    feet = 'Pill. Poulaines +3'
}

sets.precast.JA['Hide'] = {
    body = 'Pill. Vest +3'
}

sets.precast.JA['Steal'] = {
    neck = 'Pentalagus Charm',
    hands = "Thief's Kote",
    feet = 'Pill. Poulaines +3'
}

sets.precast.JA['Despoil'] = {
    legs = "Skulker's culottes +3",
    feet = "Skulker's poulaines +3"
}

sets.precast.JA['Perfect Dodge'] = {
    hands = PlundererArmlets
}

sets.precast.JA['Feint'] = {
    legs = "Plun. Culottes +3"
}

sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']

sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

sets.precast.Waltz = {
    ammo = 'Staunch Tathlum',
    head = 'Mummu Bonnet +2',
    body = 'Turms Harness',
    hands = 'Slither Gloves +1',
    legs = 'Dashing Subligar',
    feet = 'Meg. Jam. +2',
    neck = 'Elite Royal Collar',
    waist = 'Flume Belt',
    left_ear = 'Delta Earring',
    right_ear = "Handler's Earring",
    left_ring = 'Asklepian Ring',
    right_ring = "Valseur's Ring",
    back = 'Solemnity Cape'
}

sets.precast.Step = {
    ammo = 'Aurgelmir Orb +1',
    head = 'Malignance Chapeau',
    body = "Pillager's Vest +3",
    hands = 'Meg. Gloves +2',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Asn. Gorget +2',
    waist = 'Kentarch belt +1',
    left_ear = 'Crepuscular Earring',
    right_ear = "Skulker's Earring +1",
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Toutatis.STP
}

sets.precast.JA.Provoke = {
    ammo = 'Sapience Orb',
    head = "Skulker's Bonnet +3",
    body = {name = "Plunderer's Vest +3", augments = {'Enhances "Ambush" effect'}},
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = {name = 'Unmoving Collar +1', augments = {'Path: A'}},
    waist = 'Svelt. Gouriz +1',
    left_ear = 'Friomisi Earring',
    right_ear = 'Eabani Earring',
    left_ring = 'Provocare Ring',
    right_ring = 'Supershear Ring',
    back = 'Solemnity Cape'
}

sets.precast.Flourish1 = sets.precast.JA.Provoke

sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = HerculeanHelm,
    body = "skulker's Vest +3",
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = 'Voltsurge Torque',
    left_ear = 'Enchntr. Earring +1',
    right_ear = 'Loquac. Earring'
}

sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

--=========================================================================================================
--                                           PRECAST                                                      =
--                                         WEAPON SKILL                                                   =
--=========================================================================================================
sets.precast.WS = {
    ammo = 'Yetshila +1',
    head = AdhemarBonnet,
    body = PlundererVest,
    hands = AdhemarWrist,
    legs = "Pillager's culottes +3",
    feet = LustraLeggings,
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = MoonShadeEarring,
    right_ear = 'Odr Earring',
    left_ring = 'Regal Ring',
    right_ring = "Cornelia's Ring",
    back = Toutatis.WS1
}

sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

sets.precast.WS['Exenterator'] =
    set_combine(
    sets.precast.WS,
    {
        head = "skulker's Bonnet +3",
        hands = 'Mummu Wrists +2',
        feet = 'Mummu Gamash. +2',
        left_ear = 'Dawn Earring',
        right_ear = 'Infused Earring',
        right_ring = 'Dingir Ring',
        back = Toutatis.WS1
    }
)

sets.precast.WS['Exenterator'].Mid = set_combine(sets.precast.WS['Exenterator'], {})
sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'].Mid, {})
sets.precast.WS['Exenterator'].SA =
    set_combine(
    sets.precast.WS['Exenterator'].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS['Exenterator'].TA =
    set_combine(
    sets.precast.WS['Exenterator'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'].SA, {})

sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Dancing Edge'].Mid = set_combine(sets.precast.WS['Dancing Edge'], {})
sets.precast.WS['Dancing Edge'].Acc = set_combine(sets.precast.WS['Dancing Edge'], {})
sets.precast.WS['Dancing Edge'].SA =
    set_combine(
    sets.precast.WS['Dancing Edge'].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS['Dancing Edge'].TA =
    set_combine(
    sets.precast.WS['Dancing Edge'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS['Dancing Edge'].SATA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {})

sets.precast.WS['Evisceration'] =
    set_combine(
    sets.precast.WS,
    {
        Hands = "Gleti's Gauntlets",
        Feet = "Gleti's boots",
        left_ring = 'Mummu Ring'
    }
)

sets.precast.WS['Evisceration'].Mid = set_combine(sets.precast.WS['Evisceration'], {})
sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})
sets.precast.WS['Evisceration'].SA =
    set_combine(
    sets.precast.WS['Evisceration'].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS['Evisceration'].TA =
    set_combine(
    sets.precast.WS['Evisceration'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS['Evisceration'].SATA =
    set_combine(
    sets.precast.WS['Evisceration'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)

sets.precast.WS['Savage Blade'] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Pill. Bonnet +3',
        body = "skulker's Vest +3",
        hands = 'Meg. Gloves +2',
        legs = "Plun. Culottes +3",
        neck = 'Asn. Gorget +2',
        waist = 'Kentarch belt +1',
        back = Toutatis.WS2,
        ammo = "Oshasha's treatise"
    }
)

sets.precast.WS["Rudra's Storm"] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Pill. Bonnet +3',
        body = "skulker's Vest +3",
        hands = 'Meg. Gloves +2',
        legs = "Plun. Culottes +3",
        neck = 'Asn. Gorget +2',
        waist = 'Kentarch belt +1',
        back = Toutatis.WS2,
        ammo = "Oshasha's treatise"
    }
)

sets.precast.WS["Rudra's Storm"].Mid = set_combine(sets.precast.WS["Rudra's Storm"], {})
sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {})
sets.precast.WS["Rudra's Storm"].SA =
    set_combine(
    sets.precast.WS["Rudra's Storm"].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS["Rudra's Storm"].TA =
    set_combine(
    sets.precast.WS["Rudra's Storm"].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS["Rudra's Storm"].SATA =
    set_combine(
    sets.precast.WS["Rudra's Storm"].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)

sets.precast.WS['Mandalic Stab'] =
    set_combine(
    sets.precast.WS,
    {
        head = 'Pill. Bonnet +3',
        body = "skulker's Vest +3",
        hands = 'Meg. Gloves +2',
        legs = "Plun. Culottes +3",
        neck = 'Asn. Gorget +2',
        waist = 'Kentarch belt +1',
        back = Toutatis.WS2,
        ammo = "Oshasha's treatise"
    }
)

sets.precast.WS['Mandalic Stab'].Mid = set_combine(sets.precast.WS['Mandalic Stab'], {})
sets.precast.WS['Mandalic Stab'].Acc = set_combine(sets.precast.WS['Mandalic Stab'], {})
sets.precast.WS['Mandalic Stab'].SA =
    set_combine(
    sets.precast.WS['Mandalic Stab'].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS['Mandalic Stab'].TA =
    set_combine(
    sets.precast.WS['Mandalic Stab'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS['Mandalic Stab'].SATA =
    set_combine(
    sets.precast.WS['Mandalic Stab'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)

sets.precast.WS['Shark Bite'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Shark Bite'].Acc = set_combine(sets.precast.WS['Shark Bite'], {})
sets.precast.WS['Shark Bite'].Mid = set_combine(sets.precast.WS['Shark Bite'], {})
sets.precast.WS['Shark Bite'].SA =
    set_combine(
    sets.precast.WS['Shark Bite'].Mid,
    {
        hands = "Skulker's Armlets +3"
    }
)
sets.precast.WS['Shark Bite'].TA =
    set_combine(
    sets.precast.WS['Shark Bite'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)
sets.precast.WS['Shark Bite'].SATA =
    set_combine(
    sets.precast.WS['Shark Bite'].Mid,
    {
        hands = 'Pill. Armlets +3'
    }
)

sets.precast.WS['Aeolian Edge'] = {
    ammo = "Oshasha's treatise",
    head = HercAeoHead,
    neck = 'Sibyl Scarf',
    body = HercAeoBody,
    legs = HercAeoLegs,
    hands = HercAeoHands,
    feet = HercAeoFeet,
    left_ear = 'Sortiarius Earring',
    right_ear = 'Friomisi Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Dingir Ring',
    waist = "Orpheus's Sash",
    back = Toutatis.WS2
}

sets.precast.WS['Circle Blade'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = "Oshasha's Treatise",
        head = "skulker's Bonnet +3",
        body = "skulker's Vest +3",
        hands = "Skulker's Armlets +3",
        legs = 'Pill. Culottes +3',
        feet = PlundererPoulaines,
        neck = 'Fotia Gorget',
        waist = 'Fotia Belt',
        left_ear = 'Ishvara Earring',
        right_ear = "Skulker's Earring +1",
        left_ring = 'Ilabrat Ring',
        right_ring = 'Mummu Ring',
        back = Toutatis.WS1
    }
)

--=========================================================================================================
--                                          TREASURE HUNTER                                               =
--=========================================================================================================
sets.TreasureHunter = {
    hands = {name = 'Plun. Armlets +3', augments = {'Enhances "Perfect Dodge" effect'}},
    feet = "Skulker's Poulaines +3"
}

sets.TreasureHunterRA =
set_combine(
    sets.precast.RA,
    {
        feet = "Skulker's Poulaines +3"
    }
)

sets.midcast.RA.TH =
    set_combine(
    sets.precast.RA,
    {
        feet = "Skulker's Poulaines +3"
    }
)

sets.AeolianTH =
    set_combine(
    sets.precast.WS['Aeolian Edge'],
    {
        feet = "Skulker's Poulaines +3"
    }
)

--=========================================================================================================
--                                           MIDCAST                                                      =
--=========================================================================================================
sets.midcast.FastRecast = {
    ammo = 'Aurgelmir Orb +1',
    head = "skulker's Bonnet +3",
    body = 'Nyame Mail',
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    left_ear = 'Sherida Earring',
    right_ear = 'Eabani Earring',
    left_ring = ChirichRing1,
    right_ring = 'Defending Ring',
    back = 'Solemnity Cape'
}

sets.midcast.Utsusemi = sets.midcast.FastRecast