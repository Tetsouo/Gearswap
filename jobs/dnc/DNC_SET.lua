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
-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

AdhemarBonnet = EquipmentFactory.create('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
AdhemarWrist = EquipmentFactory.create('Adhemar Wrist. +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
SamnuhaTights = EquipmentFactory.create('Samnuha Tights', nil, nil,
    { 'STR+8', 'DEX+9', '"Dbl.Atk."+3', '"Triple Atk."+2' })
LustraLeggings = EquipmentFactory.create('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' })
MoonShadeEarring = EquipmentFactory.create('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
HerculeanHelm = EquipmentFactory.create('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' })
HerculeanBody = EquipmentFactory.create('Herculean Vest', nil, nil,
    { '"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9' })
HerculeanLegs = EquipmentFactory.create('Herculean Trousers', nil, nil,
    { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
ChirichRing1 = EquipmentFactory.create('Chirich Ring +1', nil, 'wardrobe 1')
ChirichRing2 = EquipmentFactory.create('Chirich Ring +1', nil, 'wardrobe 2')
ShivaRing1 = EquipmentFactory.create('Shiva Ring', nil, 'wardrobe 1')
ShivaRing2 = EquipmentFactory.create('Shiva Ring', nil, 'wardrobe 2')
HercAeoHead = EquipmentFactory.create('Herculean Helm', nil, nil,
    { '"Mag.Atk.Bns."+20', 'Weapon skill damage +5%', 'INT+8', 'Mag. Acc.+1' })
HercAeoBody = EquipmentFactory.create('Herculean Vest', nil, nil,
    { '"Mag.Atk.Bns."+29', 'CHR+4', 'Accuracy+13 Attack+13', 'Mag. Acc.+16 "Mag.Atk.Bns."+16' })
HercAeoHands = EquipmentFactory.create('Herculean Gloves', nil, nil,
    { 'Rng.Acc.+25', 'Pet: Mag. Acc.+18', 'Weapon skill damage +7%', 'Mag. Acc.+20 "Mag.Atk.Bns."+20' })
HercAeoLegs = EquipmentFactory.create('Herculean Trousers', nil, nil,
{ '"Mag.Atk.Bns."+14', 'Weapon skill damage +2%', 'Accuracy+5 Attack+5', 'Mag. Acc.+17 "Mag.Atk.Bns."+17' })
HercAeoFeet = EquipmentFactory.create('Herculean Boots', nil, nil,
    { '"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9' })
Senuna = {}
Senuna.STP = EquipmentFactory.create("Senuna's Mantle", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%' })
Senuna.WS1 = EquipmentFactory.create("Senuna's Mantle", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%' })

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Twashtar'] = { main = EquipmentFactory.create('Twashtar') }
sets['Mpu Gandring'] = { main = EquipmentFactory.create('Mpu Gandring') }
sets['Demersal'] = { main = EquipmentFactory.create('Demers. Degen +1') }
sets['Tauret'] = { main = EquipmentFactory.create('Tauret') }
sets['Centovente'] = { sub = EquipmentFactory.create('Centovente') }
sets['Blurred'] = { sub = EquipmentFactory.create('Blurred Knife +1') }
sets['Gleti'] = { sub = EquipmentFactory.create("Gleti's Knife") }
sets['Aurgelmir'] = { ammo = EquipmentFactory.create("Aurgelmir Orb +1") }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    head = EquipmentFactory.create("Gleti's Mask"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Gleti's Gauntlets"),
    legs = EquipmentFactory.create("Gleti's Breeches"),
    feet = EquipmentFactory.create("Gleti's Boots"),
    neck = EquipmentFactory.create('Elite Royal Collar'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    left_ear = EquipmentFactory.create('Sherida Earring'),
    right_ear = EquipmentFactory.create('Macu. Earring +1'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Senuna.STP
}

sets.idle.Town = set_combine(sets['idle'], {})
sets.idle.Weak = sets['idle']

sets.ExtraRegen = {
    head = EquipmentFactory.create('Meghanada Visor +2'),
    body = EquipmentFactory.create('Meg. Cuirie +2'),
    hands = EquipmentFactory.create('Meg. Gloves +2'),
    legs = EquipmentFactory.create('Meg. Chausses +2'),
    feet = EquipmentFactory.create('Meg. Jam. +2'),
    left_ear = EquipmentFactory.create('Dawn Earring'),
    right_ear = EquipmentFactory.create('Infused Earring'),
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
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    neck = EquipmentFactory.create('Etoile Gorget +2'),
    waist = EquipmentFactory.create('Kentarch Belt +1'),
    left_ear = EquipmentFactory.create('Sherida Earring'),
    right_ear = EquipmentFactory.create('Crep. Earring'),
    left_ring = EquipmentFactory.create('Chirich Ring +1'),
    right_ring = EquipmentFactory.create('Chirich Ring +1')
})

sets.engaged.Evasion =
    set_combine(sets.engaged, {
        head = EquipmentFactory.create('Maculele Tiara +3'),
        body = EquipmentFactory.create('Macu. casaque +3'),
        hands = EquipmentFactory.create('Macu. Bangles +3'),
        legs = EquipmentFactory.create('Maculele Tights +3'),
        feet = EquipmentFactory.create('Macu. Toe Sh. +3')
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
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    head = EquipmentFactory.create('Maculele Tiara +3'),
    legs = EquipmentFactory.create('Maculele Tights +3'),
    neck = EquipmentFactory.create('Etoile Gorget +2'),
    waist = EquipmentFactory.create('Kentarch Belt +1'),
    left_ear = EquipmentFactory.create('Sherida Earring'),
    right_ear = EquipmentFactory.create('Crep. Earring'),
    left_ring = EquipmentFactory.create('Chirich Ring +1'),
    right_ring = EquipmentFactory.create('Defending Ring'),
    back = Senuna.STP
})

sets.engaged.Acc.Evasion = set_combine(sets.engaged.Acc, sets.engaged.Evasion)

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA['No Foot Rise'] = {
    body = EquipmentFactory.create('Horos Casaque +3')
}

sets.precast.JA['Trance'] = {
    head = EquipmentFactory.create('Horos Tiara +3')
}

sets.buff['Saber Dance'] = {
    legs = EquipmentFactory.create('horos tights +3')
}

sets.buff['Fan Dance'] = {
    hands = EquipmentFactory.create('horos bangles +3')
}

sets.buff['Climactic Flourish'] = {
    head = EquipmentFactory.create('Maculele Tiara +3')
}

sets.precast.JA['Provoke'] = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    body = EquipmentFactory.create('Emet Harness +1'),
    hands = EquipmentFactory.create('Horos Bangles +3'),
    neck = EquipmentFactory.create('Unmoving Collar +1'),
    waist = EquipmentFactory.create('Trance Belt'),
    left_ear = EquipmentFactory.create('Friomisi Earring'),
    left_ring = EquipmentFactory.create('Provocare Ring'),
    right_ring = EquipmentFactory.create('Supershear Ring'),
    back = EquipmentFactory.create('Earthcry Mantle')
}

sets.precast.JA['Fan Dance'] = {
    hands = EquipmentFactory.create('Horos Bangles +3')
}

sets.precast.Waltz = {
    ammo = EquipmentFactory.create('Staunch Tathlum +1'),
    head = EquipmentFactory.create('Anwig Salade'),
    body = EquipmentFactory.create('Maxixi Casaque +3'),
    hands = EquipmentFactory.create('Macu. Bangles +3'),
    legs = EquipmentFactory.create('Dashing Subligar'),
    feet = EquipmentFactory.create('Macu. Toe Sh. +3'),
    neck = EquipmentFactory.create('Loricate Torque +1'),
    waist = EquipmentFactory.create('Plat. Mog. Belt'),
    left_ear = EquipmentFactory.create('Cryptic Earring'),
    right_ear = EquipmentFactory.create('Enchntr. Earring +1'),
    left_ring = EquipmentFactory.create('Asklepian Ring'),
    right_ring = EquipmentFactory.create('Defending Ring'),
    back = EquipmentFactory.create('Toetapper Mantle')
}

sets.precast.Waltz['Healing Waltz'] = set_combine(sets.precast.Waltz, {})

sets.precast.Samba = {
    head = EquipmentFactory.create('Maxixi Tiara +3'),
    back = Senuna.STP
}

sets.precast.Jig = {
    legs = EquipmentFactory.create('horos tights +3'),
    feet = EquipmentFactory.create('Maxixi Toe Shoes +3')
}

sets.precast.Step = {
    ammo = EquipmentFactory.create('Ginsen'),
    head = EquipmentFactory.create('Maxixi Tiara +3'),
    body = EquipmentFactory.create('Macu. casaque +3'),
    hands = EquipmentFactory.create('maxixi bangles +3'),
    legs = EquipmentFactory.create('Maculele Tights +3'),
    feet = EquipmentFactory.create('Horos T. Shoes +3'),
    neck = EquipmentFactory.create('Sanctity Necklace'),
    waist = EquipmentFactory.create('Kentarch belt +1'),
    left_ear = EquipmentFactory.create('Mache Earring +1'),
    right_ear = EquipmentFactory.create('Crep. Earring'),
    left_ring = EquipmentFactory.create('Asklepian Ring'),
    right_ring = EquipmentFactory.create("Valseur's Ring"),
    back = EquipmentFactory.create('Toetapper Mantle')
}

sets.precast.Step['Feather Step'] = { feet = EquipmentFactory.create('Maculele toe shoes +3') }

sets.precast.Flourish1 = {}

sets.precast.Flourish1['Violent Flourish'] = {
    head = EquipmentFactory.create('Maculele Tiara +3'),
    body = EquipmentFactory.create('Horos Casaque +3'),
    hands = EquipmentFactory.create('Macu. Bangles +3'),
    legs = EquipmentFactory.create('Maculele Tights +3'),
    feet = EquipmentFactory.create('Macu. Toe Sh. +3'),
    neck = EquipmentFactory.create('Voltsurge Torque'),
    waist = EquipmentFactory.create('Skrymir Cord'),
    left_ear = EquipmentFactory.create('Enchntr. Earring +1'),
    right_ear = EquipmentFactory.create('Macu. Earring +1'),
    left_ring = EquipmentFactory.create('Mummu Ring'),
    right_ring = EquipmentFactory.create('Crepuscular Ring')
}

sets.precast.Flourish1['Animated Flourish'] = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    body = EquipmentFactory.create('Emet Harness +1'),
    hands = EquipmentFactory.create('Horos Bangles +3'),
    neck = EquipmentFactory.create('Unmoving Collar +1'),
    waist = EquipmentFactory.create('Trance Belt'),
    left_ear = EquipmentFactory.create('Friomisi Earring'),
    left_ring = EquipmentFactory.create('Provocare Ring'),
    right_ring = EquipmentFactory.create('Supershear Ring'),
    back = EquipmentFactory.create('Earthcry Mantle')
}

sets.precast.Flourish1['Desperate Flourish'] = {
    head = EquipmentFactory.create('Maculele Tiara +3'),
    body = EquipmentFactory.create('Macu. casaque +3'),
    hands = EquipmentFactory.create('Macu. Bangles +3'),
    legs = EquipmentFactory.create('Maculele Tights +3'),
    feet = EquipmentFactory.create('Macu. Toe Sh. +3'),
    neck = EquipmentFactory.create('Sanctity Necklace'),
    waist = EquipmentFactory.create('Kentarch belt +1'),
    left_ear = EquipmentFactory.create('Mache Earring +1'),
    right_ear = EquipmentFactory.create('Crep. Earring'),
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = EquipmentFactory.create('Toetapper Mantle')
}

sets.precast.Flourish2 = {}

sets.precast.Flourish2['Reverse Flourish'] = {
    hands = EquipmentFactory.create('Maculele Bangles +3'),
    back = EquipmentFactory.create('Toetapper Mantle')
}

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    head = HerculeanHelm,
    body = EquipmentFactory.create('Macu. Casaque +3'),
    hands = EquipmentFactory.create('Leyline Gloves'),
    legs = EquipmentFactory.create('Limbo Trousers'),
    feet = EquipmentFactory.create('Macu. Toe Sh. +3'),
    neck = EquipmentFactory.create('Voltsurge Torque'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    left_ear = EquipmentFactory.create('Loquac. Earring'),
    right_ear = EquipmentFactory.create('Enchntr. Earring +1'),
    left_ring = EquipmentFactory.create('Prolix Ring'),
    right_ring = EquipmentFactory.create('Defending Ring'),
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
    ammo = EquipmentFactory.create("Oshasha's Treatise"),
    head = EquipmentFactory.create('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' }),
    body = EquipmentFactory.create('Meg. Cuirie +2'),
    hands = EquipmentFactory.create('Meg. Gloves +2'),
    legs = EquipmentFactory.create('horos tights +3'),
    feet = EquipmentFactory.create('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' }),
    neck = EquipmentFactory.create('Fotia Gorget'),
    waist = EquipmentFactory.create('Fotia Belt'),
    left_ear = EquipmentFactory.create('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' }),
    right_ear = EquipmentFactory.create('Odr Earring'),
    left_ring = EquipmentFactory.create('Regal Ring'),
    right_ring = EquipmentFactory.create("Cornelia's Ring"),
    back = Senuna.WS1
}

sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Crepuscular Pebble"),
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Macu. Bangles +3"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Macu. Toe Sh. +3"),
    neck = EquipmentFactory.create("Fotia Gorget"),
    waist = EquipmentFactory.create("Fotia Belt"),
    ear1 = EquipmentFactory.create("Sherida Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Gere Ring"),
    ring2 = EquipmentFactory.create("Defending Ring"),
    back = Senuna.WS1,
})

sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Charis Feather"),
    head = EquipmentFactory.create("Adhemar Bonnet +1"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Adhemar Wrist. +1"),
    legs = EquipmentFactory.create("Gleti's Breeches"),
    feet = EquipmentFactory.create("Gleti's Boots"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Fotia Belt"),
    ear1 = EquipmentFactory.create("Odr Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Regal Ring"),
    ring2 = EquipmentFactory.create("Gere Ring"),
    back = Senuna.WS1,
})

sets.precast.WS["Rudra's Storm"] = {
    ammo = EquipmentFactory.create("Crepuscular Pebble"),
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Maxixi Bangles +3"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Lustra. Leggings +1"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Kentarch Belt +1"),
    ear1 = EquipmentFactory.create("Moonshade Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Epaminondas's Ring"),
    ring2 = EquipmentFactory.create("Cornelia's ring"),
    back = EquipmentFactory.create("Senuna's Mantle"),
}

sets.precast.WS["Rudra's Storm"].Clim = {
    ammo = EquipmentFactory.create("Charis Feather"),
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Meg. Cuirie +2"),
    hands = EquipmentFactory.create("Maxixi Bangles +3"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Lustra. Leggings +1"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Kentarch Belt +1"),
    ear1 = EquipmentFactory.create("Moonshade Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Epaminondas's Ring"),
    ring2 = EquipmentFactory.create("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS["Ruthless Stroke"] = {
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Maxixi Bangles +3"),
    legs = EquipmentFactory.create("Gleti's Breeches"),
    feet = EquipmentFactory.create("Macu. Toe Sh. +3"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Kentarch Belt +1"),
    ear1 = EquipmentFactory.create("Moonshade Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Defending Ring"),
    ring2 = EquipmentFactory.create("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Shark Bite'] = {
    ammo = EquipmentFactory.create("Crepuscular Pebble"),
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Maxixi Bangles +3"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Gleti's Boots"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Sailfi Belt +1"),
    ear1 = EquipmentFactory.create("Moonshade Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Epaminondas's Ring"),
    ring2 = EquipmentFactory.create("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Shark Bite'].Clim = {
    ammo = EquipmentFactory.create("Charis Feather"),
    head = EquipmentFactory.create("Maculele Tiara +3"),
    body = EquipmentFactory.create("Meg. Cuirie +2"),
    hands = EquipmentFactory.create("Maxixi Bangles +3"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Gleti's Boots"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Kentarch Belt +1"),
    ear1 = EquipmentFactory.create("Moonshade Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Epaminondas's Ring"),
    ring2 = EquipmentFactory.create("Cornelia's ring"),
    back = Senuna.WS1,
}

sets.precast.WS['Pyrrhic Kleos'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Crepuscular Pebble"),
    head = EquipmentFactory.create("Gleti's Mask"),
    body = EquipmentFactory.create("Gleti's Cuirass"),
    hands = EquipmentFactory.create("Gleti's Gauntlets"),
    legs = EquipmentFactory.create("Maculele Tights +3"),
    feet = EquipmentFactory.create("Lustra. Leggings +1"),
    neck = EquipmentFactory.create("Etoile Gorget +2"),
    waist = EquipmentFactory.create("Fotia Belt"),
    ear1 = EquipmentFactory.create("Sherida Earring"),
    ear2 = EquipmentFactory.create("Macu. Earring +1"),
    ring1 = EquipmentFactory.create("Epona's Ring"),
    ring2 = EquipmentFactory.create("Gere Ring"),
    back = Senuna.WS1,

})

sets.precast.WS['Aeolian Edge'] = {
    ammo = EquipmentFactory.create("Oshasha's Treatise"),
    head = EquipmentFactory.create('Nyame Helm'),
    body = EquipmentFactory.create('Nyame Mail'),
    hands = EquipmentFactory.create('Nyame Gauntlets'),
    legs = EquipmentFactory.create('Nyame Flanchard'),
    feet = EquipmentFactory.create('Nyame Sollerets'),
    neck = EquipmentFactory.create('Sibyl Scarf'),
    waist = EquipmentFactory.create("Orpheus's Sash"),
    left_ear = EquipmentFactory.create('Sortiarius Earring'),
    right_ear = EquipmentFactory.create('Friomisi Earring'),
    left_ring = EquipmentFactory.create('Metamor. Ring +1'),
    right_ring = EquipmentFactory.create("Cornelia's Ring"),
    back = Senuna.WS1
}

sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {
    head = EquipmentFactory.create('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' }),
    legs = EquipmentFactory.create('Herculean Trousers', nil, nil,
        { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
})

sets.precast.Skillchain = set_combine(sets.precast.WS["Rudra's Storm"], {
    hands = EquipmentFactory.create('Maculele Bangles +3'),
    legs = EquipmentFactory.create('maxixi tights +2'),
    right_ear = EquipmentFactory.create('Macu. Earring +1'),
})

-- =========================================================================================================
--                                           TPBonus Sets (Moonshade Earring)
-- =========================================================================================================

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = EquipmentFactory.create('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
}

-- TPBonus variants for weapon skills
sets.precast.WS["Rudra's Storm"].TPBonus = set_combine(sets.precast.WS["Rudra's Storm"], sets.precast.WS.TPBonus)
sets.precast.WS['Evisceration'].TPBonus = set_combine(sets.precast.WS['Evisceration'], sets.precast.WS.TPBonus)
sets.precast.WS['Exenterator'].TPBonus = set_combine(sets.precast.WS['Exenterator'], sets.precast.WS.TPBonus)
sets.precast.WS['Shark Bite'].TPBonus = set_combine(sets.precast.WS['Shark Bite'], sets.precast.WS.TPBonus)
sets.precast.WS['Pyrrhic Kleos'].TPBonus = set_combine(sets.precast.WS['Pyrrhic Kleos'], sets.precast.WS.TPBonus)

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = EquipmentFactory.create("Skadi's Jambeaux +1"),
    right_ring = EquipmentFactory.create('Defending Ring')
}

-- =========================================================================================================
--                                           Equipments - TreasureHunter Sets
-- =========================================================================================================
sets.TreasureHunter = {
    head = HerculeanHelm,
    legs = HerculeanLegs
}

-- Simple job loading notification
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("DNC")
