---============================================================================
--- FFXI GearSwap Equipment Sets - Thief Comprehensive Gear Collection
---============================================================================
--- Professional Thief equipment set definitions providing optimized
--- gear configurations for Treasure Hunter management, Sneak/Trick Attack
--- coordination, stealth operations, and advanced rogue strategies. Features:
---
--- • **Treasure Hunter Mastery** - TH+1-14 sets with SA/TA integration
--- • **SA/TA Optimization Systems** - Sneak Attack and Trick Attack coordination
--- • **Stealth Operation Equipment** - Hide, Invisible, and evasion sets
--- • **Weapon Skill Specialization** - Rudra's Storm, Shark Bite, Evisceration
--- • **Ranged TH Integration** - Crossbow and throwing weapon TH sets
--- • **Multi-Mode TH Support** - None/Tag/SATA/Fulltime TH configurations
--- • **Movement Speed Preservation** - SA/TA-aware mobility systems
--- • **Dual Wield Optimization** - Advanced weapon combination strategies
---
--- This comprehensive equipment database enables THF to excel in both
--- treasure hunting and combat roles while maintaining stealth capabilities
--- and versatility across diverse encounter types with intelligent coordination.
---
--- @file jobs/thf/THF_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by THF_FUNCTION.lua for TH and SA/TA management
---
--- @see jobs/thf/THF_FUNCTION.lua for thief logic and TH coordination
--- @see Tetsouo_THF.lua for job configuration and TH mode management
---============================================================================

-- Creates an equipment item with the given name, priority, bag, and augments.
-- Parameters:
--   name (string): The name of the equipment item
--   priority (number, optional): The priority of the equipment item. Defaults to 0.
--   bag (number, optional): The bag where the equipment item is located. Defaults to 0.
--   augments (table, optional): The augments of the equipment item. Defaults to an empty table.
-- Returns:
--   A table representing the equipment item
function createEquipment(name, priority, bag, augments)
    return {
        name = name,
        priority = priority or 0,
        bag = bag or 0,
        augments = augments or {}
    }
end

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
AdhemarBonnet = createEquipment('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
PlundererVest = createEquipment("Plunderer's Vest +3", nil, nil, { 'Enhances "Ambush" effect' })
AdhemarWrist = createEquipment('Adhemar Wrist. +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
SamnuhaTights = createEquipment('Samnuha Tights', nil, nil, { 'STR+10', 'DEX+10', '"Dbl.Atk."+3', '"Triple Atk."+3' })
Toutatis = {}
Toutatis.STP = createEquipment("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10', 'Phys. dmg. taken-10%' })
Toutatis.WS1 = createEquipment("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', 'Phys. dmg. taken-10%' })
Toutatis.WS2 = createEquipment("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' })
PlundererCulotte = createEquipment('Plun. Culottes +3', nil, nil, { 'Enhances "Feint" effect' })
PlundererArmlets = createEquipment('Plun. Armlets +3', nil, nil, { 'Enhances "Perfect Dodge" effect' })
AssassinGorget = createEquipment("Assassin's Gorget", nil, nil, { 'Path: A' })
CannyCape = createEquipment('Canny Cape', nil, nil, { 'DEX+1', 'AGI+2', '"Dual Wield"+3', 'Crit. hit damage +3%' })
LustraLeggings = createEquipment('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' })
MoonShadeEarring = createEquipment('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
PlundererPoulaines = createEquipment('Plun. Poulaines +3', nil, nil, { "Enhances \"Assassin's Charge\" effect" })
HerculeanHelm = createEquipment('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' })
HerculeanLegs = createEquipment('Herculean Trousers', nil, nil,
    { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
ChirichRing1 = createEquipment('Chirich Ring +1', nil, 'wardrobe 1')
ChirichRing2 = createEquipment('Chirich Ring +1', nil, 'wardrobe 2')
ShivaRing1 = createEquipment('Shiva Ring', 'wardrobe 1')
ShivaRing2 = createEquipment('Shiva Ring', 'wardrobe 2')
Moonlight1 = createEquipment('MoonLight Ring', 0, 'Wardrobe 2')
Moonlight2 = createEquipment('MoonLight Ring', 0, 'Wardrobe 4')
HercAeoHead = createEquipment('Herculean Helm', nil, nil,
    { '"Mag.Atk.Bns."+20', 'Weapon skill damage +5%', 'INT+8', 'Mag. Acc.+1' })
HercAeoBody = createEquipment('Herculean Vest', nil, nil, { '"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9' })
HercAeoHands = createEquipment('Herculean Gloves', nil, nil, { 'Rng.Acc.+25', 'Pet: Mag. Acc.+18',
    'Weapon skill damage +7%',
    'Mag. Acc.+20 "Mag.Atk.Bns."+20' })
HercAeoLegs = createEquipment('Herculean Trousers', nil, nil,
    { '"Mag.Atk.Bns."+23', 'Weapon skill damage +4%', 'INT+10', 'Mag. Acc.+5' })
HercAeoFeet = createEquipment('Herculean Boots', nil, nil, { '"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9' })
sets.MoveSpeed = {
    feet = createEquipment('Pill. Poulaines +3'),
    ring1 = createEquipment('Defending Ring')
}


-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['TwashtarM'] = {
    main = createEquipment('Twashtar')
}
sets['Mpu Gandring'] = {
    main = createEquipment('Mpu Gandring')
}
sets['Vajra'] = {
    main = createEquipment('Vajra')
}
sets['Tauret'] = {
    main = createEquipment('Tauret')
}
sets['Malevolence'] = {
    main = createEquipment('Malevolence')
}
sets['Dagger'] = {
    main = createEquipment('Qutrub Knife')
}
sets['Naegling'] = {
    main = createEquipment('Naegling')
}
sets['Tanmogayi'] = {
    sub = createEquipment('Tanmogayi +1')
}
sets['TwashtarS'] = {
    sub = createEquipment('Twashtar')
}
sets['Jugo'] = {
    sub = createEquipment('Jugo Kukri +1')
}
sets['Crepu'] = {
    sub = createEquipment('Crepuscular Knife')
}
sets['Centovente'] = {
    sub = createEquipment('Centovente')
}
sets['Blurred'] = {
    sub = createEquipment('Blurred Knife +1')
}

sets['Dagger2'] = {
    sub = createEquipment('Qutrub Knife')
}
sets['Gleti'] = {
    sub = createEquipment("Gleti's Knife")
}
sets['Sword'] = {
    main = createEquipment('Excalipoor')
}
sets['Great Sword'] = {
    main = createEquipment('Lament')
}
sets['Polearm'] = {
    main = createEquipment('Iapetus')
}
sets['Club'] = {
    main = createEquipment('Chac-Chacs')
}
sets['Staff'] = {
    main = createEquipment('Ram staff')
}

sets['Scythe'] = {
    main = createEquipment('Lost Sickle')
}

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
    ear1 = createEquipment('Sherida Earring'),
    ear2 = createEquipment('Eabani Earring'),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = createEquipment('Solemnity Cape')
}
sets.idle.Town = set_combine(sets.idle, {
    feet = createEquipment('Pill. Poulaines +3')
})
sets.idle.Regen = set_combine(sets.idle, {
    head = createEquipment('Meghanada Visor +2'),
    body = createEquipment('Meg. Cuirie +2'),
    hands = createEquipment('Meg. Gloves +2'),
    legs = createEquipment('Meg. Chausses +2'),
    feet = createEquipment('Meg. Jam. +2'),
    ear1 = createEquipment('Dawn Earring'),
    ear2 = createEquipment('Infused Earring'),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2
})
sets.idle.PDT = set_combine(sets.idle, {
    ring1 = ChirichRing2,
    ring2 = createEquipment('Defending Ring'),
    ear1 = createEquipment('Sherida Earring')
})

sets.idle.Weak = sets.idle

-- =========================================================================================================
--                                           Equipments - Engagement Sets
-- =========================================================================================================
sets.engaged = {
    ammo = "Crepuscular Pebble",
    head = "Skulker's Bonnet +3",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Skulk. Poulaines +3",
    neck = { name = "Asn. Gorget +2", augments = { 'Path: A', } },
    waist = { name = "Kentarch Belt +1", augments = { 'Path: A', } },
    ear1 = "Sherida Earring",
    ear2 = { name = "Skulk. Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Store TP"+4', } },
    ring1 = "Defending Ring",
    ring2 = "Moonlight Ring",
    back = Toutatis.STP,
}

sets.engaged.Acc = set_combine(sets.engaged, {
    waist = createEquipment('Kentarch belt +1'),
    ring1 = ChirichRing2,
    ring2 = createEquipment('Gere Ring'),
})

sets.engaged.PDT = {
    ammo = "Aurgelmir Orb +1",
    head = "Malignance Chapeau",
    body = "Pill. Vest +4",
    hands = "Malignance Gloves",
    legs = "Skulk. Culottes +3",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Gere Ring",
    ring2 = "Moonlight Ring",
    back = Toutatis.STP,
}

sets.engaged.PDTAFM3 = {
    ammo = "Crepuscular Pebble",
    head = "Skulker's Bonnet +3",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Gere Ring",
    ring2 = "Moonlight Ring",
    waist = { name = "Kentarch Belt +1", augments = { 'Path: A', } },
    back = Toutatis.STP,
}

sets.engaged.Acc.PDT = set_combine(sets.engaged.PDT, {
    ammo = createEquipment('Aurgelmir Orb +1'),
    head = createEquipment("Skulker's Bonnet +3"),
    body = createEquipment('Malignance Tabard'),
    hands = createEquipment('Skulk. Armlets +3'),
    legs = createEquipment('Pill. Culottes +3'),
    feet = createEquipment('Skulk. Poulaines +3'),
    neck = createEquipment("Assassin's Gorget +2"),
    waist = createEquipment('Kentarch Belt +1'),
    ear1 = createEquipment('Crep. Earring'),
    ear2 = createEquipment('Skulk. Earring +1'),
    ring1 = ChirichRing1,
    ring2 = createEquipment('Gere Ring'),
    back = Toutatis.STP,
})

-- Engaged sets with TH+SA/TA for tagging period
sets.engaged.TH = set_combine(sets.engaged, sets.TreasureHunter)
sets.engaged.TH.SA = set_combine(sets.engaged, sets.TreasureHunter.SA) 
sets.engaged.TH.TA = set_combine(sets.engaged, sets.TreasureHunter.TA)
sets.engaged.TH.SATA = set_combine(sets.engaged, sets.TreasureHunter.SATA)

-- =========================================================================================================
--                                           Equipments - Ranged Attack Sets
-- =========================================================================================================
sets.precast.RA = {
    range = createEquipment('Exalted Crossbow'),
    ammo = createEquipment('Acid Bolt'),
    head = createEquipment('Malignance Chapeau'),
    body = createEquipment('Malignance Tabard'),
    hands = createEquipment('Malignance Gloves'),
    legs = createEquipment('Malignance Tights'),
    feet = createEquipment('Malignance Boots'),
    neck = createEquipment('Null Loop'),
    waist = createEquipment('Yemaya Belt'),
    ear1 = createEquipment('Crepuscular Earring'),
    ear2 = createEquipment('Telos Earring'),
    ring1 = createEquipment('Cacoethic Ring'),
    ring2 = createEquipment('Crepuscular Ring'),
    back = createEquipment('Sacro mantle'),
}

sets.precast.RATH = set_combine(sets.precast.RA, {
    feet = createEquipment("Skulker's Poulaines +3")
})

sets.midcast.RA = sets.precast.RA
sets.midcast.RA.Acc = sets.midcast.RA

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.buff['Sneak Attack'] = {
    ammo = createEquipment('Yetshila +1'),
    head = AdhemarBonnet,
    body = createEquipment("Pillager's Vest +4"),
    hands = createEquipment("Skulker's Armlets +3"),
    legs = "Lustr. Subligar +1",
    feet = createEquipment('Pill. Poulaines +3'),
    neck = createEquipment('Asn. Gorget +2'),
    waist = createEquipment('Kentarch belt +1'),
    ear1 = createEquipment('Mache Earring +1'),
    ear2 = createEquipment('Odr Earring'),
    ring1 = createEquipment('Ilabrat Ring'),
    ring2 = createEquipment('Regal Ring'),
    back = Toutatis.STP,
}

sets.buff['Trick Attack'] = {
    ammo = createEquipment('Yetshila +1'),
    head = createEquipment("skulker's Bonnet +3"),
    body = PlundererVest,
    hands = createEquipment('Pill. armlets +4'),
    legs = createEquipment("Pillager's culottes +3"),
    feet = createEquipment('Pill. Poulaines +3'),
    neck = createEquipment('Asn. Gorget +2'),
    waist = createEquipment('Svelt. Gouriz +1'),
    ear1 = createEquipment('Dawn Earring'),
    ear2 = createEquipment('Infused Earring'),
    ring1 = createEquipment('Ilabrat Ring'),
    ring2 = createEquipment('Regal Ring'),
    back = CannyCape,
}

sets.precast.JA['Collaborator'] = {
    head = createEquipment("Skulker's bonnet +3"),
    body = PlundererVest,
    hands = PlundererArmlets,
    ear1 = createEquipment('Friomisi Earring'),
    ring1 = createEquipment('Cacoethic Ring')
}
sets.precast.JA['Accomplice'] = sets.precast.JA['Collaborator']

sets.precast.JA['Conspirator'] = { body = createEquipment("skulker's Vest +3") }

sets.precast.JA['Animated Flourish'] = {
    ammo = createEquipment('Sapience Orb'),
    head = createEquipment("Skulker's Bonnet +3"),
    body = createEquipment("Plunderer's Vest +3"),
    hands = createEquipment("Skulker's Armlets +3"),
    legs = createEquipment("Skulker's culottes +3"),
    feet = createEquipment("Skulker's Poulaines +3"),
    neck = createEquipment('Unmoving Collar +1'),
    waist = createEquipment('Svelt. Gouriz +1'),
    ear1 = createEquipment('Friomisi Earring'),
    ear2 = createEquipment('Eabani Earring'),
    ring1 = createEquipment('Provocare Ring'),
    ring2 = createEquipment('Supershear Ring'),
    back = createEquipment('Solemnity Cape')
}
sets.precast.JA['Flee'] = { feet = createEquipment('Pill. Poulaines +3') }

sets.precast.JA['Hide'] = { body = createEquipment("Pill. Vest +3") }

sets.precast.JA['Steal'] = {
    neck = createEquipment('Pentalagus Charm'),
    hands = createEquipment("Thief's Kote"),
    legs = createEquipment("Assassin's Culottes"),
    feet = createEquipment('Pill. Poulaines +3')
}
sets.precast.JA['Despoil'] = {
    legs = createEquipment("Skulker's culottes +3"),
    feet = createEquipment("Skulker's poulaines +3")
}

sets.precast.JA['Perfect Dodge'] = {
    hands = PlundererArmlets
}
sets.precast.JA['Feint'] = {
    legs = createEquipment('Plun. Culottes +3')
}
sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

sets.precast.Waltz = {
    ammo = createEquipment('Staunch Tathlum +1'),
    head = createEquipment('Mummu Bonnet +2'),
    body = createEquipment('Turms Harness'),
    hands = createEquipment('Slither Gloves +1'),
    legs = createEquipment('Dashing Subligar'),
    feet = createEquipment('Meg. Jam. +2'),
    neck = createEquipment('Elite Royal Collar'),
    waist = createEquipment('Flume Belt'),
    ear1 = createEquipment('Delta Earring'),
    ear2 = createEquipment("Handler's Earring"),
    ring1 = createEquipment('Asklepian Ring'),
    ring2 = createEquipment("Valseur's Ring"),
    back = createEquipment('Solemnity Cape')
}
sets.precast.Step = {
    ammo = createEquipment('Aurgelmir Orb +1'),
    head = createEquipment('Malignance Chapeau'),
    body = createEquipment("Pillager's Vest +4"),
    hands = createEquipment('Meg. Gloves +2'),
    legs = createEquipment('Malignance Tights'),
    feet = createEquipment('Malignance Boots'),
    neck = createEquipment('Asn. Gorget +2'),
    waist = createEquipment('Kentarch belt +1'),
    ear1 = createEquipment('Crepuscular Earring'),
    ear2 = createEquipment("Skulker's Earring +1"),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Toutatis.STP
}
sets.precast.JA.Provoke = {
    ammo = createEquipment('Sapience Orb'),
    head = createEquipment("Skulker's Bonnet +3"),
    body = createEquipment("Plunderer's Vest +3"),
    hands = createEquipment("Skulker's Armlets +3"),
    legs = createEquipment("Skulker's culottes +3"),
    feet = createEquipment("Skulker's Poulaines +3"),
    neck = createEquipment('Unmoving Collar +1'),
    waist = createEquipment('Svelt. Gouriz +1'),
    ear1 = createEquipment('Friomisi Earring'),
    ear2 = createEquipment('Eabani Earring'),
    ring1 = createEquipment('Provocare Ring'),
    ring2 = createEquipment('Supershear Ring'),
    back = createEquipment('Solemnity Cape')
}
sets.precast.Flourish1 = sets.precast.JA.Provoke
sets.precast.FC = {
    ammo = createEquipment('Sapience Orb'),
    head = HerculeanHelm,
    body = createEquipment('Dread Jupon'),
    hands = createEquipment('Leyline Gloves'),
    legs = createEquipment('Enif Cosciales'),
    neck = createEquipment('Voltsurge Torque'),
    ear1 = createEquipment('Enchntr. Earring +1'),
    ear2 = createEquipment('Loquac. Earring'),
    ring2 = createEquipment('Prolix Ring')
}
sets.precast.FC.Utsusemi = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = createEquipment('Yetshila +1'),
    head = AdhemarBonnet,
    body = PlundererVest,
    hands = AdhemarWrist,
    legs = createEquipment("Pillager's culottes +3"),
    feet = LustraLeggings,
    neck = createEquipment('Fotia Gorget'),
    waist = createEquipment('Fotia Belt'),
    ear1 = MoonShadeEarring,
    ear2 = createEquipment('Odr Earring'),
    ring1 = createEquipment("Cornelia's Ring"),
    ring2 = createEquipment('Regal Ring'),
    back = Toutatis.WS1
}
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
    ammo = "Aurgelmir Orb +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Meg. Chausses +2",
    feet = "Skulk. Poulaines +3",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Gere Ring",
    ring2 = "Regal Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Exenterator'].Mid = set_combine(sets.precast.WS['Exenterator'], {})

sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'].Mid, {})

sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'].Mid, {
    ammo = "C. Palug Stone",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Plun. Culottes +3",
    feet = "Skulk. Poulaines +3",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Ilabrat Ring",
    ring2 = "Regal Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'].Mid, {
    ammo = "C. Palug Stone",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Pill. Armlets +4",
    legs = "Meg. Chausses +2",
    feet = "Skulk. Poulaines +3",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Ilabrat Ring",
    ring2 = "Regal Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'].SA, {})

sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {})

sets.precast.WS['Dancing Edge'].Mid = set_combine(sets.precast.WS['Dancing Edge'], {})

sets.precast.WS['Dancing Edge'].Acc = set_combine(sets.precast.WS['Dancing Edge'], {})

sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {
    hands = createEquipment("Skulker's Armlets +3")
})

sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {
    hands = createEquipment('Pill. Armlets +4')
})

sets.precast.WS['Dancing Edge'].SATA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {})

sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Plunderer's Vest +3",
    hands = "Mummu Wrists +2",
    legs = "Gleti's Breeches",
    feet = "Lustra. Leggings +1",
    neck = "Fotia Gorget",
    waist = "Fotia Belt",
    ear1 = "Sherida Earring",
    ear2 = "Odr Earring",
    ring1 = "Mummu Ring",
    ring2 = "Regal Ring",
    back = "Toutatis's Cape",

})

sets.precast.WS['Evisceration'].Mid = set_combine(sets.precast.WS['Evisceration'], {})

sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})

sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'].Mid, {
    hands = createEquipment("Skulker's Armlets +3")
})

sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'].Mid, {
    hands = createEquipment('Pill. Armlets +4')
})

sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'].Mid, {
    hands = createEquipment('Pill. Armlets +4')
})

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    head = createEquipment('Pill. Bonnet +3'),
    body = createEquipment("skulker's Vest +3"),
    hands = createEquipment('Meg. Gloves +2'),
    legs = createEquipment('Plun. Culottes +3'),
    neck = createEquipment('Asn. Gorget +2'),
    waist = createEquipment('Kentarch belt +1'),
    back = Toutatis.WS2,
    ammo = createEquipment("Oshasha's treatise")
})

sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {
    ammo = "Aurgelmir Orb +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Plun. Culottes +3",
    feet = "Lustra. Leggings +1",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Regal Ring",
    back = Toutatis.WS2,
})

sets.precast.WS["Rudra's Storm"].Mid = set_combine(sets.precast.WS["Rudra's Storm"], {})

sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {})

sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Lustr. Subligar +1",
    feet = "Lustra. Leggings +1",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Domin. Earring +1",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Plun. Culottes +3",
    feet = "Gleti's Boots",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"].Mid, {
    hands = createEquipment('Pill. Armlets +4'),
    ammo = createEquipment('Yetshila +1')
})

sets.precast.WS['Mandalic Stab'] = set_combine(sets.precast.WS, {
    ammo = "Crepuscular Pebble",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Malignance Gloves",
    legs = "Gleti's Breeches",
    feet = "Gleti's Boots",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Dominance Earring +1",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,

})

sets.precast.WS['Mandalic Stab'].Mid = set_combine(sets.precast.WS['Mandalic Stab'], {})

sets.precast.WS['Mandalic Stab'].Acc = set_combine(sets.precast.WS['Mandalic Stab'], {})

sets.precast.WS['Mandalic Stab'].SA = set_combine(sets.precast.WS['Mandalic Stab'].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Malignance Gloves",
    legs = "Plun. Culottes +3",
    feet = "Lustra. Leggings +1",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Mandalic Stab'].TA = set_combine(sets.precast.WS['Mandalic Stab'].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker2's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Malignance Gloves",
    legs = "Plun. Culottes +3",
    feet = "Gleti's Boots",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Mandalic Stab'].SATA = set_combine(sets.precast.WS['Mandalic Stab'].Mid, {
    hands = createEquipment('Pill. Armlets +4'),
    ammo = createEquipment('Yetshila +1')
})

sets.precast.WS['Shark Bite'] = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = "Aurgelmir Orb +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Plun. Culottes +3",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Regal Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Shark Bite'].Acc = set_combine(sets.precast.WS['Shark Bite'], {})

sets.precast.WS['Shark Bite'].Mid = set_combine(sets.precast.WS['Shark Bite'], {})

sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Plun. Culottes +3",
    feet = "Gleti's Boots",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'].Mid, {
    ammo = "Yetshila +1",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Meg. Gloves +2",
    legs = "Plun. Culottes +3",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Ishvara Earring",
    ear2 = "Moonshade Earring",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Toutatis.WS2,
})

sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'].Mid, {
    hands = createEquipment('Pill. Armlets +4'),
    ammo = createEquipment('Yetshila +1')
})

sets.precast.WS['Aeolian Edge'] = {
    ammo = createEquipment("Oshasha's treatise"),
    head = "Nyame Helm",
    neck = createEquipment('Sibyl Scarf'),
    body = "Nyame Mail",
    legs = "Nyame Flanchard",
    hands = "Nyame Gauntlets",
    feet = "Nyame Sollerets",
    ear1 = createEquipment('Friomisi Earring'),
    ear2 = createEquipment('Moonshade Earring'),
    ring1 = createEquipment("Epaminondas's Ring"),
    ring2 = createEquipment("Cornelia's Ring"),
    waist = createEquipment("Orpheus's Sash"),
    back = Toutatis.WS2
}

sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {
    ammo = createEquipment("Oshasha's Treatise"),
    head = createEquipment("skulker's Bonnet +3"),
    body = createEquipment("skulker's Vest +3"),
    hands = createEquipment("Skulker's Armlets +3"),
    legs = createEquipment('Pill. Culottes +3'),
    feet = PlundererPoulaines,
    neck = createEquipment('Fotia Gorget'),
    waist = createEquipment('Fotia Belt'),
    ear1 = createEquipment('Ishvara Earring'),
    ear2 = createEquipment("Skulker's Earring +1"),
    ring1 = createEquipment('Ilabrat Ring'),
    ring2 = createEquipment('Mummu Ring'),
    back = Toutatis.WS1
})
-- =========================================================================================================
--                                           Equipments - TreasureHunter Sets
-- =========================================================================================================

-- Base TH set (TH pieces only)
sets.TreasureHunter = {
    feet = createEquipment("Skulker's Poulaines +3"),
}

-- Specialized TH+SA/TA combinations for optimal performance
sets.TreasureHunter.SA = set_combine(sets.TreasureHunter, sets.buff['Sneak Attack'])

sets.TreasureHunter.TA = set_combine(sets.TreasureHunter, sets.buff['Trick Attack'])

sets.TreasureHunter.SATA = set_combine(sets.TreasureHunter, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])


-- setup_dynamic_th() will be called from THF_FUNCTION.lua after it's loaded

sets.TreasureHunterRA = set_combine(sets.precast.RA, {
    feet = createEquipment("Skulker's Poulaines +3")
})

sets.midcast.RA.TH = set_combine(sets.precast.RA, {
    feet = createEquipment("Skulker's Poulaines +3")
})

sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {
    feet = createEquipment("Skulker's Poulaines +3")
})

-- =========================================================================================================
--                                           Equipments - midcast.FastRecast Sets
-- =========================================================================================================
sets.midcast.FastRecast = {
    ammo = createEquipment('Aurgelmir Orb +1'),
    head = createEquipment("skulker's Bonnet +3"),
    body = createEquipment('Nyame Mail'),
    hands = createEquipment("Skulker's Armlets +3"),
    legs = createEquipment("Skulker's culottes +3"),
    feet = createEquipment("Skulker's Poulaines +3"),
    neck = createEquipment('Elite Royal Collar'),
    waist = createEquipment('Svelt. Gouriz +1'),
    ear1 = createEquipment('Sherida Earring'),
    ear2 = createEquipment('Eabani Earring'),
    ring1 = ChirichRing2,
    ring2 = createEquipment('Defending Ring'),
    back = createEquipment('Solemnity Cape')
}

sets.midcast.Utsusemi = sets.midcast.FastRecast

sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace"), -- Reduces Doom effects
    ring1 = createEquipment("Purity Ring"),    -- Additional Doom resistance
    waist = createEquipment("Gishdubar Sash"),     -- Enhances Doom recovery effects
}
