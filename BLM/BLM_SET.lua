--============================================================--
--=                      BLM_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

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
    main={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+8','"Fast Cast"+5',}},
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

sets.precast.FC.Death = set_combine(sets.precast.FC, {})

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

sets.precast.FC.Death.MagicBurst = sets.precast.FC.Death

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
    back = "Taranus's Cape",
}

-- Specific weaponskill sets. Uses the base set if an appropriate WSMod version isn't found.
sets.precast.WS['Myrkr'] = {}

sets.precast.WS['Vidohunir'] = {}

sets.precast.WS['Cataclysm'] = {}

sets.precast.WS['Spiral Hell'] = {}

---- Midcast Sets ----
sets.midcast.FastRecast = sets.precast.FC

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
    back = "Taranus's Cape",
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
        ammo="Impatiens",
        head={ name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10',}},
        body={ name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10',}},
        hands={ name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10',}},
        legs={ name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10',}},
        neck="Nodens Gorget",
        waist="Siegel Sash",
        left_ear="Ethereal Earring",
        right_ear="Lugalbanda Earring",
        left_ring="Stikini Ring +1",
        right_ring="Stikini Ring +1",
        back={ name="Fi Follet Cape +1", augments={'Path: A',}},
    }
)

sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

sets.midcast.Aquaveil = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo="Impatiens",
    head="Amalric Coif +1",
    body={ name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +10',}},
    hands={ name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +10',}},
    legs={ name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10',}},
    feet={ name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +10',}},
    neck={ name="Loricate Torque +1", augments={'Path: A',}},
    waist="Olympus Sash",
    left_ear="Andoaa Earring",
    right_ear="Lugalbanda Earring",
    left_ring="Stikini Ring +1",
    right_ring="Evanescence Ring",
    back={ name="Fi Follet Cape +1", augments={'Path: A',}},
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
    back = 'Fi Follet Cape +1',
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
    main="Bunzi's Rod",
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck={ name="Src. Stole +2", augments={'Path: A',}},
    waist={ name="Acuity Belt +1", augments={'Path: A',}},
    left_ear="Malignance Earring",
    right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
    left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    right_ring="Stikini Ring +1",
    back = "Taranus's cape" 
}

sets.midcast.Break = sets.midcast.Breakga

sets.midcast.Sleep = {
    main="Bunzi's Rod",
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck={ name="Src. Stole +2", augments={'Path: A',}},
    waist={ name="Acuity Belt +1", augments={'Path: A',}},
    left_ear="Malignance Earring",
    right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
    left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    right_ring="Stikini Ring +1",
    back = "Taranus's cape" 
}

sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep

sets.midcast.Blind = {
    main="Bunzi's Rod",
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck={ name="Src. Stole +2", augments={'Path: A',}},
    waist={ name="Acuity Belt +1", augments={'Path: A',}},
    left_ear="Malignance Earring",
    right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
    left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    right_ring="Stikini Ring +1",
    back = "Taranus's cape" 
}

sets.midcast['Dark Magic'] = {
    main={ name="Rubicundity", augments={'Mag. Acc.+6','"Mag.Atk.Bns."+7','Dark magic skill +7',}},
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head={ name="Merlinic Hood", augments={'Mag. Acc.+6','"Drain" and "Aspir" potency +10','INT+6','"Mag.Atk.Bns."+2',}},
    body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+30','"Drain" and "Aspir" potency +11','INT+3','Mag. Acc.+4',}},
    hands={ name="Merlinic Dastanas", augments={'"Drain" and "Aspir" potency +10','"Mag.Atk.Bns."+14',}},
    legs="Wicce Chausses +3",
    feet="Agwu's Pigaches",
    neck="Erra Pendant",
    waist="Fucho-no-Obi",
    left_ear="Malignance Earring",
    right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
    left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    right_ring="Evanescence Ring",
    back = "Taranus's cape" 
    }

sets.midcast.Drain = {
    main={ name="Rubicundity", augments={'Mag. Acc.+6','"Mag.Atk.Bns."+7','Dark magic skill +7',}},
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head={ name="Merlinic Hood", augments={'Mag. Acc.+6','"Drain" and "Aspir" potency +10','INT+6','"Mag.Atk.Bns."+2',}},
    body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+30','"Drain" and "Aspir" potency +11','INT+3','Mag. Acc.+4',}},
    hands={ name="Merlinic Dastanas", augments={'"Drain" and "Aspir" potency +10','"Mag.Atk.Bns."+14',}},
    legs="Wicce Chausses +3",
    feet="Agwu's Pigaches",
    neck="Erra Pendant",
    waist="Fucho-no-Obi",
    left_ear="Malignance Earring",
    right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
    left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    right_ring="Evanescence Ring",
    back = "Taranus's cape" 
}

sets.midcast.Aspir = {
main={ name="Rubicundity", augments={'Mag. Acc.+6','"Mag.Atk.Bns."+7','Dark magic skill +7',}},
sub="Ammurapi Shield",
ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
head={ name="Merlinic Hood", augments={'Mag. Acc.+6','"Drain" and "Aspir" potency +10','INT+6','"Mag.Atk.Bns."+2',}},
body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+30','"Drain" and "Aspir" potency +11','INT+3','Mag. Acc.+4',}},
hands={ name="Merlinic Dastanas", augments={'"Drain" and "Aspir" potency +10','"Mag.Atk.Bns."+14',}},
legs="Wicce Chausses +3",
feet="Agwu's Pigaches",
neck="Erra Pendant",
waist="Fucho-no-Obi",
left_ear="Malignance Earring",
right_ear={ name="Wicce Earring +1", augments={'System: 1 ID: 1676 Val: 0','Mag. Acc.+14','Enmity-4',}},
left_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
right_ring="Evanescence Ring",
back = "Taranus's cape" 
}

sets.midcast.Raise = {}

-- Elemental Magic sets are default for handling low-tier nukes.
sets.midcast['Elemental Magic'] = {
    main="Bunzi's Rod",
    sub="Ammurapi Shield",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck={ name="Src. Stole +2", augments={'Path: A',}},
    waist={ name="Acuity Belt +1", augments={'Path: A',}},
    left_ear="Malignance Earring",
    right_ear= "Regal Earring",
    left_ring="Freke Ring",
    right_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    back = "Taranus's cape" 
}

sets.midcast['Elemental Magic'].MagicBurst = {
    main = "Bunzi's rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly tathlum',
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet = "Wicce sabots +3",
    neck="Src. Stole +2",
    waist = "Hachirin-no-obi",
    left_ear="Malignance Earring",
    right_ear= "Regal Earring",
    left_ring="Freke Ring",
    right_ring="Metamor. Ring +1",
    back="Taranus's Cape",
}

sets.midcast['Burn'] = {
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Spaekona's Coat +3",
    hands="Wicce Gloves +3",
    legs={ name="Arch. Tonban +3", augments={'Increases Elemental Magic debuff time and potency',}},
    feet={ name="Arch. Sabots +3", augments={'Increases Aspir absorption amount',}},
    neck={ name="Src. Stole +2", augments={'Path: A',}},
    waist={ name="Acuity Belt +1", augments={'Path: A',}},
    left_ear="Malignance Earring",
    right_ear="Regal Earring",
    left_ring="Stikini Ring +1",
    right_ring={ name="Metamor. Ring +1", augments={'Path: A',}},
    back={ name="Taranus's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10','Spell interruption rate down-10%',}},
}

sets.midcast['Rasp'] = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

sets.midcast['Impact'] =
    set_combine(
    sets.midcast['Elemental Magic'],
    {
        head = empty,
        body = 'Twilight Cloak'
    }
)

sets.midcast['Impact'].MagicBurst =
    set_combine(
    sets.midcast['Elemental Magic'].MagicBurst,
    {
        head = empty,
        body = 'Twilight Cloak'
    }
)

sets.midcast['Meteor'] = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast['Comet'] = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast['Comet'].MagicBurst = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

sets.midcast['Death'] = set_combine(sets.midcast['Elemental Magic'], {})

sets.midcast['Death'].MagicBurst = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {})

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
    back = "Taranus's Cape",
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
    back= "Taranus's Cape",
}

-- Resting sets
sets.resting = set_combine(sets.idle, {})

-- Engaged sets

-- Variations for TP weapon and (optional) offense/defense modes. Code will fall back on previous
-- sets if more refined versions aren't defined.
-- If you create a set with both offense and defense modes, the offense mode should be first.
-- EG: sets.engaged.Dagger.Accuracy.Evasion
sets.engaged = {
    main="Malignance Pole",
    sub="Enki Strap",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck="Sanctity Necklace",
    waist="Windbuffet Belt +1",
    left_ear="Crep. Earring",
    right_ear="Telos Earring",
    left_ring="Chirich Ring +1",
    right_ring="Chirich Ring +1",
    back= "Taranus's Cape",
}

sets.engaged.PDT = {
    main="Malignance Pole",
    sub="Enki Strap",
    ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
    head="Wicce Petasos +3",
    body="Wicce Coat +3",
    hands="Wicce Gloves +3",
    legs="Wicce Chausses +3",
    feet="Wicce Sabots +3",
    neck="Sanctity Necklace",
    waist="Windbuffet Belt +1",
    left_ear="Crep. Earring",
    right_ear="Telos Earring",
    left_ring="Chirich Ring +1",
    right_ring="Chirich Ring +1",
    back = "Taranus's cape" 
}

sets.MoveSpeed = {feet = "Herald's Gaiters"}
sets.Adoulin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})