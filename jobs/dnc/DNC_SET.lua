---============================================================================
--- FFXI GearSwap Equipment Sets - Dancer Comprehensive Gear Collection
---============================================================================
--- Professional Dancer equipment set definitions providing optimized
--- gear configurations for step coordination, flourish management, support
--- abilities, and advanced dance combat strategies. Features:
---
--- • **Step Mastery Systems** - Box Step, Quickstep, and Stutter Step sets
--- • **Flourish Optimization** - Climactic, Building, and Ternary flourish gear
--- • **TP Conservation Logic** - Efficient TP usage for weapon skills and steps
--- • **Divine Waltz Coordination** - Party healing and support equipment
--- • **Dual Wield Integration** - Seamless weapon combination optimization
--- • **Accuracy Step Sets** - Precision gear for step landing reliability
--- • **Support Role Equipment** - Party member assistance and buff coordination
--- • **Movement Speed Systems** - Mobility for optimal positioning and support
---
--- This comprehensive equipment database enables DNC to excel in both
--- damage dealing and support roles while maintaining versatility across
--- diverse encounter types with intelligent step and flourish coordination.
---
--- @file jobs/dnc/DNC_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by DNC_FUNCTION.lua for step and flourish management
---
--- @see jobs/dnc/DNC_FUNCTION.lua for dance logic and step coordination
--- @see Tetsouo_DNC.lua for job configuration and dance mode management
---============================================================================

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
AdhemarBonnet = createEquipment('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
AdhemarWrist = createEquipment('Adhemar Wrist. +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
SamnuhaTights = createEquipment('Samnuha Tights', nil, nil, { 'STR+8', 'DEX+9', '"Dbl.Atk."+3', '"Triple Atk."+2' })
LustraLeggings = createEquipment('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' })
MoonShadeEarring = createEquipment('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
HerculeanHelm = createEquipment('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' })
HerculeanBody = createEquipment('Herculean Vest', nil, nil, { '"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9' })
HerculeanLegs = createEquipment('Herculean Trousers', nil, nil,
    { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
ChirichRing1 = createEquipment('Chirich Ring +1', nil, 'wardrobe 1')
ChirichRing2 = createEquipment('Chirich Ring +1', nil, 'wardrobe 2')
ShivaRing1 = createEquipment('Shiva Ring', nil, 'wardrobe 1')
ShivaRing2 = createEquipment('Shiva Ring', nil, 'wardrobe 2')
HercAeoHead = createEquipment('Herculean Helm', nil, nil,
    { '"Mag.Atk.Bns."+20', 'Weapon skill damage +5%', 'INT+8', 'Mag. Acc.+1' })
HercAeoBody = createEquipment('Herculean Vest', nil, nil,
    { '"Mag.Atk.Bns."+29', 'CHR+4', 'Accuracy+13 Attack+13', 'Mag. Acc.+16 "Mag.Atk.Bns."+16' })
HercAeoHands = createEquipment('Herculean Gloves', nil, nil,
    { 'Rng.Acc.+25', 'Pet: Mag. Acc.+18', 'Weapon skill damage +7%', 'Mag. Acc.+20 "Mag.Atk.Bns."+20' })
HercAeoLegs = createEquipment('Herculean Trousers', nil, nil,
    { '"Mag.Atk.Bns."+14', 'Weapon skill damage +2%', 'Accuracy+5 Attack+5', 'Mag. Acc.+17 "Mag.Atk.Bns."+17' })
HercAeoFeet = createEquipment('Herculean Boots', nil, nil, { '"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9' })
Senuna = {}
Senuna.STP = createEquipment("Senuna's Mantle", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%' })
Senuna.WS1 = createEquipment("Senuna's Mantle", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%' })

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Twashtar'] = { main = createEquipment('Twashtar') }
sets['Mpu Gandring'] = { main = createEquipment('Mpu Gandring') }
sets['Demersal'] = { main = createEquipment('Demers. Degen +1') }
sets['Tauret'] = { main = createEquipment('Tauret') }
sets['Aern Dagger II'] = { main = createEquipment('Aern Dagger II') }
sets['Centovente'] = { sub = createEquipment('Centovente') }
sets['Blurred'] = { sub = createEquipment('Blurred Knife +1') }
sets['Gleti'] = { sub = createEquipment("Gleti's Knife") }
sets['Aurgelmir'] = { ammo = createEquipment("Aurgelmir Orb +1") }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    ammo = createEquipment('Aurgelmir Orb +1'),
    head = createEquipment("Gleti's Mask"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Gleti's Gauntlets"),
    legs = createEquipment("Gleti's Breeches"),
    feet = createEquipment("Gleti's Boots"),
    neck = createEquipment('Elite Royal Collar'),
    waist = createEquipment('Svelt. Gouriz +1'),
    left_ear = createEquipment('Sherida Earring'),
    right_ear = createEquipment('Macu. Earring +1'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Senuna.STP
}

sets.idle.Town = set_combine(sets['idle'], {})
sets.idle.Weak = sets['idle']

sets.ExtraRegen = {
    head = createEquipment('Meghanada Visor +2'),
    body = createEquipment('Meg. Cuirie +2'),
    hands = createEquipment('Meg. Gloves +2'),
    legs = createEquipment('Meg. Chausses +2'),
    feet = createEquipment('Meg. Jam. +2'),
    left_ear = createEquipment('Dawn Earring'),
    right_ear = createEquipment('Infused Earring'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = {
    ammo = "Aurgelmir Orb +1",
    head = "Maculele Tiara +3",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Macu. Toe Sh. +3",
    neck = "Etoile Gorget +2",
    waist = "Kentarch Belt +1",
    left_ear = "Sherida Earring",
    right_ear = "Crep. Earring",
    left_ring = "Gere Ring",
    right_ring = "Defending Ring",
    back = Senuna.STP
}

sets.engaged.Acc = set_combine(sets.engaged, {
    ammo = createEquipment('Aurgelmir Orb +1'),
    neck = createEquipment('Etoile Gorget +2'),
    waist = createEquipment('Kentarch Belt +1'),
    left_ear = createEquipment('Sherida Earring'),
    right_ear = createEquipment('Crep. Earring'),
    left_ring = createEquipment('Chirich Ring +1'),
    right_ring = createEquipment('Chirich Ring +1')
})

sets.engaged.Evasion =
    set_combine(sets.engaged, {
        head = createEquipment('Maculele Tiara +3'),
        body = createEquipment('Macu. casaque +3'),
        hands = createEquipment('Macu. Bangles +3'),
        legs = createEquipment('Maculele Tights +3'),
        feet = createEquipment('Macu. Toe Sh. +3')
    })

sets.engaged.PDT = set_combine(sets.engaged, {
    ammo = "Coiste Bodhar",
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Samnuha Tights",
    feet = "Macu. Toe Sh. +3",
    neck = "Etoile Gorget +2",
    waist = "Windbuffet Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Macu. Earring +1",
    ring1 = "Epona's Ring",
    ring2 = "Gere Ring",
    back = "Senuna's Mantle",
})

sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, {
    ammo = createEquipment('Aurgelmir Orb +1'),
    head = createEquipment('Maculele Tiara +3'),
    legs = createEquipment('Maculele Tights +3'),
    neck = createEquipment('Etoile Gorget +2'),
    waist = createEquipment('Kentarch Belt +1'),
    left_ear = createEquipment('Sherida Earring'),
    right_ear = createEquipment('Crep. Earring'),
    left_ring = createEquipment('Chirich Ring +1'),
    right_ring = createEquipment('Defending Ring'),
    back = Senuna.STP
})

sets.engaged.Acc.Evasion = set_combine(sets.engaged.Acc, sets.engaged.Evasion)

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA['No Foot Rise'] = {
    body = createEquipment('Horos Casaque +3')
}

sets.precast.JA['Trance'] = {
    head = createEquipment('Horos Tiara +3')
}

sets.buff['Saber Dance'] = {
    legs = createEquipment('horos tights +3')
}

sets.buff['Fan Dance'] = {
    hands = createEquipment('horos bangles +3')
}

sets.buff['Climactic Flourish'] = {
    head = createEquipment('Maculele Tiara +3')
}

sets.precast.JA['Provoke'] = {
    ammo = createEquipment('Sapience Orb'),
    body = createEquipment('Emet Harness +1'),
    hands = createEquipment('Horos Bangles +3'),
    neck = createEquipment('Unmoving Collar +1'),
    waist = createEquipment('Trance Belt'),
    left_ear = createEquipment('Friomisi Earring'),
    left_ring = createEquipment('Provocare Ring'),
    right_ring = createEquipment('Supershear Ring'),
    back = createEquipment('Earthcry Mantle')
}

sets.precast.JA['Fan Dance'] = {
    hands = createEquipment('Horos Bangles +3')
}

sets.precast.Waltz = {
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Anwig Salade'),
    body = createEquipment('Maxixi Casaque +3'),
    hands = createEquipment('Macu. Bangles +3'),
    legs = createEquipment('Dashing Subligar'),
    feet = createEquipment('Macu. Toe Sh. +3'),
    neck = createEquipment('Loricate Torque +1'),
    waist = createEquipment('Plat. Mog. Belt'),
    left_ear = createEquipment('Cryptic Earring'),
    right_ear = createEquipment('Enchntr. Earring +1'),
    left_ring = createEquipment('Asklepian Ring'),
    right_ring = createEquipment('Defending Ring'),
    back = createEquipment('Toetapper Mantle')
}

sets.precast.Waltz['Healing Waltz'] = set_combine(sets.precast.Waltz, {})

sets.precast.Samba = {
    head = createEquipment('Maxixi Tiara +3'),
    back = Senuna.STP
}

sets.precast.Jig = {
    legs = createEquipment('horos tights +3'),
    feet = createEquipment('Maxixi Toe Shoes +3')
}

sets.precast.Step = {
    ammo = createEquipment('Ginsen'),
    head = createEquipment('Maxixi Tiara +3'),
    body = createEquipment('Macu. casaque +3'),
    hands = createEquipment('maxixi bangles +3'),
    legs = createEquipment('Maculele Tights +3'),
    feet = createEquipment('Horos T. Shoes +3'),
    neck = createEquipment('Sanctity Necklace'),
    waist = createEquipment('Kentarch belt +1'),
    left_ear = createEquipment('Mache Earring +1'),
    right_ear = createEquipment('Crep. Earring'),
    left_ring = createEquipment('Asklepian Ring'),
    right_ring = createEquipment("Valseur's Ring"),
    back = createEquipment('Toetapper Mantle')
}

sets.precast.Step['Feather Step'] = { feet = createEquipment('Maculele toe shoes +3') }

sets.precast.Flourish1 = {}

sets.precast.Flourish1['Violent Flourish'] = {
    head = createEquipment('Maculele Tiara +3'),
    body = createEquipment('Horos Casaque +3'),
    hands = createEquipment('Macu. Bangles +3'),
    legs = createEquipment('Maculele Tights +3'),
    feet = createEquipment('Macu. Toe Sh. +3'),
    neck = createEquipment('Voltsurge Torque'),
    waist = createEquipment('Skrymir Cord'),
    left_ear = createEquipment('Enchntr. Earring +1'),
    right_ear = createEquipment('Macu. Earring +1'),
    left_ring = createEquipment('Mummu Ring'),
    right_ring = createEquipment('Crepuscular Ring')
}

sets.precast.Flourish1['Animated Flourish'] = {
    ammo = createEquipment('Sapience Orb'),
    body = createEquipment('Emet Harness +1'),
    hands = createEquipment('Horos Bangles +3'),
    neck = createEquipment('Unmoving Collar +1'),
    waist = createEquipment('Trance Belt'),
    left_ear = createEquipment('Friomisi Earring'),
    left_ring = createEquipment('Provocare Ring'),
    right_ring = createEquipment('Supershear Ring'),
    back = createEquipment('Earthcry Mantle')
}

sets.precast.Flourish1['Desperate Flourish'] = {
    head = createEquipment('Maculele Tiara +3'),
    body = createEquipment('Macu. casaque +3'),
    hands = createEquipment('Macu. Bangles +3'),
    legs = createEquipment('Maculele Tights +3'),
    feet = createEquipment('Macu. Toe Sh. +3'),
    neck = createEquipment('Sanctity Necklace'),
    waist = createEquipment('Kentarch belt +1'),
    left_ear = createEquipment('Mache Earring +1'),
    right_ear = createEquipment('Crep. Earring'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = createEquipment('Toetapper Mantle')
}

sets.precast.Flourish2 = {}

sets.precast.Flourish2['Reverse Flourish'] = {
    hands = createEquipment('Maculele Bangles +3'),
    back = createEquipment('Toetapper Mantle')
}

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    ammo = createEquipment('Sapience Orb'),
    head = HerculeanHelm,
    body = createEquipment('Macu. Casaque +3'),
    hands = createEquipment('Leyline Gloves'),
    legs = createEquipment('Limbo Trousers'),
    feet = createEquipment('Macu. Toe Sh. +3'),
    neck = createEquipment('Voltsurge Torque'),
    waist = createEquipment('Svelt. Gouriz +1'),
    left_ear = createEquipment('Loquac. Earring'),
    right_ear = createEquipment('Enchntr. Earring +1'),
    left_ring = createEquipment('Prolix Ring'),
    right_ring = createEquipment('Defending Ring'),
    back = Senuna.STP,
}

sets.precast.FC.Utsusemi = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================
sets.midcast.FastRecast = {}
sets.midcast.Utsusemi = set_combine(sets.precast.FC, {})

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = createEquipment("Oshasha's Treatise"),
    head = createEquipment('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' }),
    body = createEquipment('Meg. Cuirie +2'),
    hands = createEquipment('Meg. Gloves +2'),
    legs = createEquipment('horos tights +3'),
    feet = createEquipment('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' }),
    neck = createEquipment('Fotia Gorget'),
    waist = createEquipment('Fotia Belt'),
    left_ear = createEquipment('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' }),
    right_ear = createEquipment('Odr Earring'),
    left_ring = createEquipment('Regal Ring'),
    right_ring = createEquipment("Cornelia's Ring"),
    back = Senuna.WS1
}

sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Crepuscular Pebble"),
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Macu. Bangles +3"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Macu. Toe Sh. +3"),
    neck = createEquipment("Fotia Gorget"),
    waist = createEquipment("Fotia Belt"),
    ear1 = createEquipment("Sherida Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Gere Ring"),
    ring2 = createEquipment("Defending Ring"),
    back = Senuna.WS1,
})

sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Charis Feather"),
    head = createEquipment("Adhemar Bonnet +1"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Adhemar Wrist. +1"),
    legs = createEquipment("Gleti's Breeches"),
    feet = createEquipment("Gleti's Boots"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Fotia Belt"),
    ear1 = createEquipment("Odr Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Regal Ring"),
    ring2 = createEquipment("Gere Ring"),
    back = Senuna.WS1,
})

sets.precast.WS["Rudra's Storm"] = {
    ammo = createEquipment("Crepuscular Pebble"),
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Maxixi Bangles +3"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Lustra. Leggings +1"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Kentarch Belt +1"),
    ear1 = createEquipment("Moonshade Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Epaminondas's Ring"),
    ring2 = createEquipment("Cornelia's ring"),
    back = createEquipment("Senuna's Mantle"),
}

sets.precast.WS["Rudra's Storm"].Clim = {
    ammo = createEquipment("Charis Feather"),
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Meg. Cuirie +2"),
    hands = createEquipment("Maxixi Bangles +3"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Lustra. Leggings +1"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Kentarch Belt +1"),
    ear1 = createEquipment("Moonshade Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Epaminondas's Ring"),
    ring2 = createEquipment("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS["Ruthless Stroke"] = {
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Maxixi Bangles +3"),
    legs = createEquipment("Gleti's Breeches"),
    feet = createEquipment("Macu. Toe Sh. +3"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Kentarch Belt +1"),
    ear1 = createEquipment("Moonshade Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Defending Ring"),
    ring2 = createEquipment("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Shark Bite'] = {
    ammo = createEquipment("Crepuscular Pebble"),
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Maxixi Bangles +3"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Gleti's Boots"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Sailfi Belt +1"),
    ear1 = createEquipment("Moonshade Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Epaminondas's Ring"),
    ring2 = createEquipment("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Shark Bite'].Clim = {
    ammo = createEquipment("Charis Feather"),
    head = createEquipment("Maculele Tiara +3"),
    body = createEquipment("Meg. Cuirie +2"),
    hands = createEquipment("Maxixi Bangles +3"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Gleti's Boots"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Kentarch Belt +1"),
    ear1 = createEquipment("Moonshade Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Epaminondas's Ring"),
    ring2 = createEquipment("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Pyrrhic Kleos'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Crepuscular Pebble"),
    head = createEquipment("Gleti's Mask"),
    body = createEquipment("Gleti's Cuirass"),
    hands = createEquipment("Gleti's Gauntlets"),
    legs = createEquipment("Maculele Tights +3"),
    feet = createEquipment("Lustra. Leggings +1"),
    neck = createEquipment("Etoile Gorget +2"),
    waist = createEquipment("Fotia Belt"),
    ear1 = createEquipment("Sherida Earring"),
    ear2 = createEquipment("Macu. Earring +1"),
    ring1 = createEquipment("Epona's Ring"),
    ring2 = createEquipment("Gere Ring"),
    back = Senuna.WS1,

})

sets.precast.WS['Aeolian Edge'] = {
    ammo = createEquipment("Oshasha's Treatise"),
    head = createEquipment('Nyame Helm'),
    body = createEquipment('Nyame Mail'),
    hands = createEquipment('Nyame Gauntlets'),
    legs = createEquipment('Nyame Flanchard'),
    feet = createEquipment('Nyame Sollerets'),
    neck = createEquipment('Sibyl Scarf'),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment('Sortiarius Earring'),
    right_ear = createEquipment('Friomisi Earring'),
    left_ring = createEquipment('Metamor. Ring +1'),
    right_ring = createEquipment("Cornelia's Ring"),
    back = Senuna.WS1
}

sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {
    head = createEquipment('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' }),
    legs = createEquipment('Herculean Trousers', nil, nil,
        { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
})

sets.precast.Skillchain = set_combine(sets.precast.WS["Rudra's Storm"], {
    hands = createEquipment('Maculele Bangles +3'),
    legs = createEquipment('maxixi tights +2'),
    right_ear = createEquipment('Macu. Earring +1'),
})

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = createEquipment("Skadi's Jambeaux +1"),
    right_ring = createEquipment('Defending Ring')
}

-- =========================================================================================================
--                                           Equipments - TreasureHunter Sets
-- =========================================================================================================
sets.TreasureHunter = {
    head = HerculeanHelm,
    legs = HerculeanLegs
}
