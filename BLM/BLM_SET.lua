StikiRing1 = {
    name = 'Stikini Ring +1',
    bag = 'wardrobe 6'
}

StikiRing2 = {
    name = 'Stikini Ring +1',
    bag = 'wardrobe 7'
}

-- Precast sets to enhance JAs.
sets.precast.JA['Mana Wall'] = {
    feet = 'Wicce Sabots +3',
    back = "Taranus's Cape"
}

sets.precast.JA.Manafont = {body = "Archmage's Coat +1"}

-- equip to maximize HP (for Tarus) and minimize MP loss before using convert.
sets.precast.JA.Convert = {}

-- Fast cast sets for spells.
sets.precast.FC = {
    main = {name = 'Malevolence', augments = {'INT+7', 'Mag. Acc.+3', '"Mag.Atk.Bns."+5', '"Fast Cast"+2'}},
    sub = 'Culminus',
    ammo = 'Sapience Orb',
    head = {name = 'Merlinic Hood', augments = {'Attack+14', '"Fast Cast"+7', 'MND+3'}},
    body = {name = 'Merlinic Jubbah', augments = {'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3'}},
    hands = {name = 'Merlinic Dastanas', augments = {'"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4'}},
    legs = {name = 'Merlinic Shalwar', augments = {'"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11'}},
    feet = {name = 'Merlinic Crackows', augments = {'"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10'}},
    neck = 'Voltsurge Torque',
    waist = 'Witful Belt',
    right_ear = 'Loquac. Earring',
    left_ear = 'Malignance Earring',
    left_ring = 'Kishar Ring',
    right_ring = 'Prolix Ring',
    back = 'Fi Follet Cape +1'
}

sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist = 'Siegel Sash'})

sets.precast.FC['Elemental Magic'] =
    set_combine(
    sets.precast.FC,
    {
        head = 'Wicce Petasos +3',
        body = 'Wicce Coat +3'
    }
)

sets.precast.FC.Death = {
    main = 'Oranyan',
    sub = 'Alber Strap',
    ammo = 'Impatiens',
    head = {
        name = 'Merlinic Hood',
        augments = {
            '"Fast Cast"+5',
            'Mag. Acc.+14 "Mag.Atk.Bns."+14',
            'Accuracy+7 Attack+7'
        }
    },
    body = {
        name = 'Merlinic Jubbah',
        augments = {
            '"Mag.Atk.Bns."+3',
            'Pet: INT+3',
            '"Fast Cast"+3',
            'Accuracy+5 Attack+5'
        }
    },
    hands = "Agwu's Gages",
    legs = "Agwu's Slops",
    feet = {name = 'Amalric Nails +1', augments = {'MP+80', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
    neck = "Orunmila's Torque",
    waist = 'Embla Sash',
    left_ear = 'Loquac. Earring',
    right_ear = 'Malignance Earring',
    left_ring = 'Kishar Ring',
    right_ring = StikiRing2,
    back = 'Moonbeam Cape'
}

sets.precast.FC.Cure =
    set_combine(
    sets.precast.FC,
    {
        legs = 'Doyen Pants'
    }
)

sets.precast.FC.Curaga = sets.precast.FC.Cure

sets.precast.FC.Impact =
    set_combine(
    sets.precast.FC,
    {
        head = empty,
        body = 'Twilight Cloak'
    }
)

sets.precast.FC.Death.MagicBurst = {
    main = 'Oranyan',
    sub = 'Alber Strap',
    ammo = 'Impatiens',
    head = {
        name = 'Merlinic Hood',
        augments = {
            '"Fast Cast"+5',
            'Mag. Acc.+14 "Mag.Atk.Bns."+14',
            'Accuracy+7 Attack+7'
        }
    },
    body = {
        name = 'Merlinic Jubbah',
        augments = {
            '"Mag.Atk.Bns."+3',
            'Pet: INT+3',
            '"Fast Cast"+3',
            'Accuracy+5 Attack+5'
        }
    },
    hands = "Agwu's Gages",
    legs = "Agwu's Slops",
    feet = {name = 'Amalric Nails +1', augments = {'MP+80', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
    neck = "Orunmila's Torque",
    waist = 'Embla Sash',
    right_ear = 'Loquac. Earring',
    left_ear = 'Malignance Earring',
    left_ring = 'Kishar Ring',
    right_ring = StikiRing2,
    back = 'Moonbeam Cape'
}

sets.precast.FC.Stoneskin =
    set_combine(
    sets.precast.FC,
    {
        head = 'Umuthi Hat',
        legs = 'Doyen Pants',
        waist = 'Siegel Sash'
    }
)

-- Weaponskill sets
-- Default set for any weaponskill that isn't any more specifically defined
sets.precast.WS = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = "Oshasha's Treatise",
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = {name = 'Moonshade Earring', augments = {'Accuracy+4', 'TP Bonus +250'}},
    right_ear = 'Mache Earring +1',
    left_ring = "Cornelia's Ring",
    right_ring = 'Chirich Ring +1',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- Specific weaponskill sets. Uses the base set if an appropriate WSMod version isn't found.
sets.precast.WS['Myrkr'] = {
    ammo = 'Strobilus',
    head = 'Amalric Coif +1',
    neck = 'Dualism Collar +1',
    ear1 = 'Moonshade Earring',
    ear2 = 'Evans Earring',
    body = 'Weatherspoon robe +1',
    hands = 'Otomi Gloves',
    left_ring = "Mephitas's Ring +1",
    right_ring = "Mephitas's Ring",
    back = {name = "Taranus's Cape", augments = {'MP+60', 'Eva.+20 /Mag. Eva.+20', 'MP+20', '"Fast Cast"+10'}},
    waist = 'Shinjutsu-no-obi +1',
    legs = 'Amalric Slops +1',
    feet = 'Psycloth Boots'
}

sets.precast.WS['Vidohunir'] = {
    ammo = 'Ghastly Tathlum +1',
    head = 'Pixie Hairpin +1',
    neck = 'Mizukage-no-Kubikazari',
    ear2 = 'Malignance Earring',
    ear1 = 'Regal Earring',
    body = 'Amalric Doublet +1',
    hands = 'Amalric Gages +1',
    left_ring = 'Archon Ring',
    right_ring = 'Freke Ring',
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    },
    waist = "Orpheus's sash",
    legs = {
        name = 'Merlinic Shalwar',
        augments = {
            'Mag. Acc.+25 "Mag.Atk.Bns."+25',
            '"Occult Acumen"+9',
            'MND+14',
            'Mag. Acc.+11',
            '"Mag.Atk.Bns."+12'
        }
    },
    feet = {
        name = 'Merlinic Crackows',
        augments = {'Mag. Acc.+24 "Mag.Atk.Bns."+24', '"Occult Acumen"+3', 'INT+6', 'Mag. Acc.+13', '"Mag.Atk.Bns."+14'}
    }
}

sets.precast.WS['Cataclysm'] = {
    ammo = 'Ghastly Tathlum +1',
    head = 'Pixie Hairpin +1',
    neck = 'Mizukage-no-Kubikazari',
    ear1 = 'Malignance Earring',
    ear2 = 'Regal Earring',
    body = 'Amalric Doublet +1',
    hands = 'Amalric Gages +1',
    left_ring = 'Archon Ring',
    right_ring = 'Freke Ring',
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    },
    waist = "Orpheus's sash",
    legs = {
        name = 'Merlinic Shalwar',
        augments = {
            'Mag. Acc.+25 "Mag.Atk.Bns."+25',
            '"Occult Acumen"+9',
            'MND+14',
            'Mag. Acc.+11',
            '"Mag.Atk.Bns."+12'
        }
    },
    feet = {
        name = 'Merlinic Crackows',
        augments = {'Mag. Acc.+24 "Mag.Atk.Bns."+24', '"Occult Acumen"+3', 'INT+6', 'Mag. Acc.+13', '"Mag.Atk.Bns."+14'}
    }
}

sets.precast.WS['Spiral Hell'] = {
    main = 'Drepanum',
    sub = 'Enki Strap',
    ammo = 'Ghastly Tathlum +1',
    head = 'Nyame Helm',
    body = 'Jhakri Robe +2',
    hands = 'Nyame gauntlets',
    legs = 'Nyame flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = 'Ishvara Earring',
    right_ear = {name = 'Moonshade Earring', augments = {'Accuracy+4', 'TP Bonus +250'}},
    left_ring = 'Freke Ring',
    right_ring = 'Rajas Ring',
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    }
}
---- Midcast Sets ----
sets.midcast.FastRecast = {
    head = 'Amalric Coif +1',
    ammo = 'Impatiens',
    ear1 = 'Malignance Earring',
    ear2 = 'Loquacious Earring',
    body = 'Amalric Doublet +1',
    hands = 'Otomi Gloves',
    left_ring = "Mephitas's Ring",
    right_ring = "Mephitas's Ring +1",
    waist = 'Shinjutsu-no-Obi +1',
    legs = 'Psycloth Lappas',
    feet = 'Merlinic Crackows'
}

sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = 'C. Palug Crown',
    body = 'Nyame Mail',
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = 'Nyame Flanchard',
    feet = {name = "Medium's Sabots", augments = {'MP+50', 'MND+10', '"Conserve MP"+7', '"Cure" potency +5%'}},
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Plat. Mog. Belt',
    left_ear = 'Impreg. Earring',
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = 'Defending Ring',
    right_ring = 'Freke Ring',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

sets.self_healing = set_combine(sets.midcast.Cure, {})

sets.midcast.Curaga = sets.midcast.Cure

sets.midcast['Enhancing Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Lugalbanda Earring',
    ring_ring = 'Evanescence Ring',
    left_ring = StikiRing1,
    back = 'Fi Follet Cape +1'
}

sets.midcast.Stoneskin =
    set_combine(
    sets.midcast['Enhancing Magic'],
    {
        hands = {name = 'Otomi Gloves', priority = 13},
        back = {name = 'Fi Follet Cape +1', priority = 12},
        neck = 'Stone Gorget',
        ear1 = 'Earthcry Earring',
        legs = 'Shedir Seraweels',
        waist = 'Siegel Sash',
        left_ring = {name = "mephitas's ring +1", priority = 15},
        right_ring = {name = "mephitas's ring", priority = 14}
    }
)

sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

sets.midcast.Aquaveil = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Lugalbanda Earring',
    right_ring = 'Evanescence Ring',
    left_ring = StikiRing1,
    back = 'Fi Follet Cape +1'
}

sets.midcast.Refresh =
    set_combine(
    sets.midcast.Aquaveil,
    {
        main = 'Daybreak',
        sub = 'Ammurapi Shield',
        ammo = 'Impatiens',
        head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
        body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
        hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
        legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
        feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
        neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
        waist = 'Olympus Sash',
        left_ear = 'Andoaa Earring',
        right_ear = 'Lugalbanda Earring',
        right_ring = 'Evanescence Ring',
        left_ring = StikiRing1,
        back = 'Fi Follet Cape +1'
    }
)

sets.midcast.Haste = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Lugalbanda Earring',
    right_ring = 'Evanescence Ring',
    left_ring = StikiRing1,
    back = 'Fi Follet Cape +1'
}

sets.midcast.MndEnfeebles = {
    main = 'Contemplator +1',
    sub = 'Khonsu',
    ammo = 'Quartz Tathlum +1',
    head = 'Befouled Crown',
    neck = "Incanter's Torque",
    ear1 = 'Vor Earring',
    ear2 = 'Regal Earring',
    body = "Spaekona's Coat +3",
    hands = 'Regal Cuffs',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = "Aurist's Cape +1",
    waist = 'Rumination sash',
    legs = {name = 'Psycloth Lappas', priority = 15},
    feet = {name = 'Skaoi boots', priority = 14}
}

sets.midcast.IntEnfeebles = sets.midcast.MndEnfeebles

sets.midcast.Breakga = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'C. Palug Crown',
    body = 'Nyame Mail',
    hands = {name = 'Amalric Gages +1', augments = {'INT+12', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
    legs = 'Nyame Flanchard',
    feet = {name = 'Amalric Nails +1', augments = {'Mag. Acc.+20', '"Mag.Atk.Bns."+20', '"Conserve MP"+7'}},
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    right_ring = StikiRing2,
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

sets.midcast.Break = sets.midcast.Breakga

sets.midcast.Sleep = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'C. Palug Crown',
    body = 'Wicce Coat +3',
    legs = 'Wicce Chausses +3',
    hands = {name = 'Amalric Gages +1', augments = {'INT+12', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
    feet = {name = 'Amalric Nails +1', augments = {'Mag. Acc.+20', '"Mag.Atk.Bns."+20', '"Conserve MP"+7'}},
    neck = 'Src. Stole +2',
    waist = 'Acuity belt +1',
    left_ear = 'Malignance Earring',
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    right_ring = StikiRing2,
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep

sets.midcast.Blind = {
    main = 'Contemplator +1',
    sub = 'Khonsu',
    ammo = 'Quartz Tathlum +1',
    head = 'Volte Cap',
    body = "Spaekona's Coat +3",
    hands = 'Regal Cuffs',
    legs = 'Volte Hose',
    feet = 'Volte Boots',
    neck = "Incanter's Torque",
    waist = 'Chaac Belt',
    left_ear = 'Vor Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    }
}

sets.midcast['Dark Magic'] = {
    main = 'Rubicundity',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Amalric Coif +1',
    neck = 'Erra Pendant',
    ear1 = 'Malignance Earring',
    ear2 = 'Mani Earring',
    body = 'Psycloth Vest',
    hands = "Archmage's gloves +3",
    left_ring = 'Archon Ring',
    right_ring = 'Evanescence Ring',
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    },
    waist = 'Windbuffet Belt +1',
    legs = "Spaekona's Tonban +3",
    feet = 'Wicce Sabots +3'
}

sets.midcast.Drain = {
    main = {name = 'Rubicundity', augments = {'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7'}},
    sub = 'Ammurapi Shield',
    ammo = {name = 'Ghastly Tathlum +1', augments = {'Path: A'}},
    head = {
        name = 'Merlinic Hood',
        augments = {'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2'}
    },
    body = {
        name = 'Merlinic Jubbah',
        augments = {'"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4'}
    },
    hands = {name = 'Merlinic Dastanas', augments = {'"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14'}},
    legs = 'Wicce Chausses +3',
    feet = {name = 'Merlinic Crackows', augments = {'"Drain" and "Aspir" potency +10', 'INT+2'}},
    neck = 'Erra Pendant',
    waist = {name = 'Acuity Belt +1', augments = {'Path: A'}},
    left_ear = 'Malignance Earring',
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    right_ring = 'Evanescence Ring',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

sets.midcast.Aspir = sets.midcast.Drain

sets.midcast.Raise = {}

-- Elemental Magic sets are default for handling low-tier nukes.
sets.midcast['Elemental Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'wicce gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = 'Freke Ring',
    right_ring = 'Metamor. Ring +1',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

sets.midcast['Elemental Magic'].MagicBurst =
    set_combine(
    sets.midcast['Elemental Magic'],
    {
        ammo = 'Sroda tathlum',
        head = 'Ea Hat',
        body = 'Ea Houppelande',
        hands = {name = 'Amalric Gages +1', augments = {'INT+12', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
        legs = 'Ea Slops',
        feet = {name = 'Amalric Nails +1', augments = {'Mag. Acc.+20', '"Mag.Atk.Bns."+20', '"Conserve MP"+7'}}
    }
)

sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

sets.midcast['Elemental Magic'].HighTierNuke.TPNuke = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

sets.midcast['Elemental Magic'].HighTierNuke.MagicBurst = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

sets.midcast.Burn = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast.Rasp = sets.midcast.Burn
sets.midcast.Shock = sets.midcast.Burn
sets.midcast.Drown = sets.midcast.Burn
sets.midcast.Choke = sets.midcast.Burn
sets.midcast.Frost = sets.midcast.Burn

sets.midcast.Impact =
    set_combine(
    sets.midcast['Elemental Magic'],
    {
        head = empty,
        body = 'Twilight Cloak'
    }
)

sets.midcast.Impact.MagicBurst =
    set_combine(
    sets.midcast['Elemental Magic'].MagicBurst,
    {
        head = empty,
        body = 'Twilight Cloak'
    }
)

sets.midcast.Meteor = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast.Comet = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast.Comet.MagicBurst = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

sets.midcast.Death = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast.Death.MagicBurst = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

-- Sets to return to when not performing an action.

-- Idle sets

-- Normal refresh idle set
sets.idle = {
    main = 'Malignance Pole',
    sub = 'Enki Strap',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'wicce gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Acuity Belt +1',
    left_ear = 'Ethereal Earring',
    right_ear = 'Lugalbanda Earring',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- Idle mode that keeps PDT gear on, but doesn't prevent normal gear swaps for precast/etc.
sets.idle.PDT = set_combine(sets.idle, {})

-- Idle mode scopes:
-- Town gear.
sets.idle.Town = set_combine(sets.idle, {})

-- Defense sets

sets.defense.PDT = {}

sets.defense.MDT = {}

--sets.Kiting = {feet="Crier's Gaiters"}

-- Buff sets: Gear that needs to be worn to actively enhance a current player buff.

sets.buff['Mana Wall'] = {
    feet = 'Wicce Sabots +3',
    back = {
        name = "Taranus's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    }
}

sets.TPdown = {neck = 'Chrysopoeia torque'}

sets.latent_refresh = {waist = 'Fucho-no-obi'}

-- Resting sets
sets.resting = set_combine(sets.idle, {})

-- Engaged sets

-- Variations for TP weapon and (optional) offense/defense modes. Code will fall back on previous
-- sets if more refined versions aren't defined.
-- If you create a set with both offense and defense modes, the offense mode should be first.
-- EG: sets.engaged.Dagger.Accuracy.Evasion
sets.engaged = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'wicce gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Sanctity Necklace',
    waist = 'Windbuffet Belt +1',
    left_ear = 'Crep. Earring',
    right_ear = 'Mache Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Chirich Ring +1',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- Normal melee group
sets.engaged.Laevateinn = {
    main = 'Laevateinn',
    sub = 'Enki Strap',
    ammo = 'Staunch Tathlum +1',
    head = 'Volte Cap',
    body = 'Jhakri Robe +2',
    hands = 'Gazu Bracelet +1',
    legs = 'Nyame flanchard',
    feet = 'Nyame Sollerets',
    neck = "Combatant's Torque",
    waist = 'Windbuffet Belt +1',
    left_ear = 'Telos Earring',
    right_ear = 'Mache Earring +1',
    left_ring = "K'ayres Ring",
    right_ring = 'Rajas Ring',
    back = {name = "Taranus's Cape", augments = {'MP+60', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10'}}
}

sets.engaged.PDT = {
    main = 'Laevateinn',
    sub = 'Enki strap',
    ammo = 'Staunch Tathlum +1',
    head = 'Nyame Helm',
    body = 'Jhakri Robe +2',
    hands = 'Nyame gauntlets',
    legs = 'Nyame flanchard',
    feet = 'Nyame Sollerets',
    neck = "Combatant's Torque",
    waist = 'Olseni Belt',
    left_ear = 'Telos Earring',
    right_ear = 'Mache Earring +1',
    left_ring = 'Ramuh Ring +1',
    right_ring = 'Ramuh Ring +1',
    back = {name = "Taranus's Cape", augments = {'MP+60', 'Accuracy+20 Attack+20', 'MP+20', '"Dbl.Atk."+10'}}
}

sets.MoveSpeed = {feet = "Herald's Gaiters"}
sets.Adoulin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})
