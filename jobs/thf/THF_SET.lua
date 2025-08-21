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
--- @requires utils/equipment_factory for standardized equipment creation
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by THF_FUNCTION.lua for TH and SA/TA management
---
--- @see jobs/thf/THF_FUNCTION.lua for thief logic and TH coordination
--- @see Tetsouo_THF.lua for job configuration and TH mode management
---============================================================================

-- Load the centralized equipment factory for standardized equipment creation
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
AdhemarBonnet = EquipmentFactory.create('Adhemar Bonnet +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
PlundererVest = EquipmentFactory.create("Plunderer's Vest +3", nil, nil, { 'Enhances "Ambush" effect' })
AdhemarWrist = EquipmentFactory.create('Adhemar Wrist. +1', nil, nil, { 'STR+12', 'DEX+12', 'Attack+20' })
SamnuhaTights = EquipmentFactory.create('Samnuha Tights', nil, nil,
    { 'STR+10', 'DEX+10', '"Dbl.Atk."+3', '"Triple Atk."+3' })
Toutatis = {}
Toutatis.STP = EquipmentFactory.create("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10', 'Phys. dmg. taken-10%' })
Toutatis.WS1 = EquipmentFactory.create("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', 'Phys. dmg. taken-10%' })
Toutatis.WS2 = EquipmentFactory.create("Toutatis's Cape", nil, nil,
    { 'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' })
PlundererCulotte = EquipmentFactory.create('Plun. Culottes +3', nil, nil, { 'Enhances "Feint" effect' })
PlundererArmlets = EquipmentFactory.create('Plun. Armlets +3', nil, nil, { 'Enhances "Perfect Dodge" effect' })
AssassinGorget = EquipmentFactory.create("Assassin's Gorget", nil, nil, { 'Path: A' })
CannyCape = EquipmentFactory.create('Canny Cape', nil, nil,
    { 'DEX+1', 'AGI+2', '"Dual Wield"+3', 'Crit. hit damage +3%' })
LustraLeggings = EquipmentFactory.create('Lustra. Leggings +1', nil, nil, { 'HP+65', 'STR+15', 'DEX+15' })
MoonShadeEarring = EquipmentFactory.create('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
PlundererPoulaines = EquipmentFactory.create('Plun. Poulaines +3', nil, nil, { "Enhances \"Assassin's Charge\" effect" })
HerculeanHelm = EquipmentFactory.create('Herculean Helm', nil, nil, { 'MND+1', 'Attack+23', '"Treasure Hunter"+2' })
HerculeanLegs = EquipmentFactory.create('Herculean Trousers', nil, nil,
    { 'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6' })
ChirichRing1 = EquipmentFactory.create('Chirich Ring +1', nil, 'wardrobe 1')
ChirichRing2 = EquipmentFactory.create('Chirich Ring +1', nil, 'wardrobe 2')
ShivaRing1 = EquipmentFactory.create('Shiva Ring', 'wardrobe 1')
ShivaRing2 = EquipmentFactory.create('Shiva Ring', 'wardrobe 2')
Moonlight1 = EquipmentFactory.create('MoonLight Ring', 0, 'Wardrobe 2')
Moonlight2 = EquipmentFactory.create('MoonLight Ring', 0, 'Wardrobe 4')
HercAeoHead = EquipmentFactory.create('Herculean Helm', nil, nil,
    { '"Mag.Atk.Bns."+20', 'Weapon skill damage +5%', 'INT+8', 'Mag. Acc.+1' })
HercAeoBody = EquipmentFactory.create('Herculean Vest', nil, nil,
    { '"Mag.Atk.Bns."+21', 'Weapon skill damage +5%', 'MND+9' })
HercAeoHands = EquipmentFactory.create('Herculean Gloves', nil, nil, { 'Rng.Acc.+25', 'Pet: Mag. Acc.+18',
    'Weapon skill damage +7%',
    'Mag. Acc.+20 "Mag.Atk.Bns."+20' })
HercAeoLegs = EquipmentFactory.create('Herculean Trousers', nil, nil,
    { '"Mag.Atk.Bns."+23', 'Weapon skill damage +4%', 'INT+10', 'Mag. Acc.+5' })
HercAeoFeet = EquipmentFactory.create('Herculean Boots', nil, nil,
    { '"Mag.Atk.Bns."+25', 'Weapon skill damage +4%', 'STR+9' })
sets.MoveSpeed = {
    feet = EquipmentFactory.create('Pill. Poulaines +3'),
    ring1 = EquipmentFactory.create('Defending Ring')
}


-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['TwashtarM'] = {
    main = EquipmentFactory.create('Twashtar')
}
sets['Mpu Gandring'] = {
    main = EquipmentFactory.create('Mpu Gandring')
}
sets['Vajra'] = {
    main = EquipmentFactory.create('Vajra')
}
sets['Tauret'] = {
    main = EquipmentFactory.create('Tauret')
}
sets['Malevolence'] = {
    main = EquipmentFactory.create('Malevolence')
}
sets['Dagger'] = {
    main = EquipmentFactory.create('Qutrub Knife')
}
sets['Naegling'] = {
    main = EquipmentFactory.create('Naegling')
}
sets['Tanmogayi'] = {
    sub = EquipmentFactory.create('Tanmogayi +1')
}
sets['TwashtarS'] = {
    sub = EquipmentFactory.create('Twashtar')
}
sets['Jugo'] = {
    sub = EquipmentFactory.create('Jugo Kukri +1')
}
sets['Crepu'] = {
    sub = EquipmentFactory.create('Crepuscular Knife')
}
sets['Centovente'] = {
    sub = EquipmentFactory.create('Centovente')
}
sets['Blurred'] = {
    sub = EquipmentFactory.create('Blurred Knife +1')
}

sets['Dagger2'] = {
    sub = EquipmentFactory.create('Qutrub Knife')
}
sets['Gleti'] = {
    sub = EquipmentFactory.create("Gleti's Knife")
}
sets['Sword'] = {
    main = EquipmentFactory.create('Excalipoor')
}
sets['Great Sword'] = {
    main = EquipmentFactory.create('Lament')
}
sets['Polearm'] = {
    main = EquipmentFactory.create('Iapetus')
}
sets['Club'] = {
    main = EquipmentFactory.create('Chac-Chacs')
}
sets['Staff'] = {
    main = EquipmentFactory.create('Ram staff')
}

sets['Scythe'] = {
    main = EquipmentFactory.create('Lost Sickle')
}

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
    ear1 = EquipmentFactory.create('Sherida Earring'),
    ear2 = EquipmentFactory.create('Eabani Earring'),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = EquipmentFactory.create('Solemnity Cape')
}
sets.idle.Town = set_combine(sets.idle, {
    feet = EquipmentFactory.create('Pill. Poulaines +3')
})
sets.idle.Regen = set_combine(sets.idle, {
    head = EquipmentFactory.create('Meghanada Visor +2'),
    body = EquipmentFactory.create('Meg. Cuirie +2'),
    hands = EquipmentFactory.create('Meg. Gloves +2'),
    legs = EquipmentFactory.create('Meg. Chausses +2'),
    feet = EquipmentFactory.create('Meg. Jam. +2'),
    ear1 = EquipmentFactory.create('Dawn Earring'),
    ear2 = EquipmentFactory.create('Infused Earring'),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2
})
sets.idle.PDT = set_combine(sets.idle, {
    ring1 = ChirichRing2,
    ring2 = EquipmentFactory.create('Defending Ring'),
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
    waist = EquipmentFactory.create('Kentarch belt +1'),
    ring1 = ChirichRing2,
    ring2 = EquipmentFactory.create('Gere Ring'),
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
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    head = EquipmentFactory.create("Skulker's Bonnet +3"),
    body = EquipmentFactory.create('Malignance Tabard'),
    hands = EquipmentFactory.create('Skulk. Armlets +3'),
    legs = EquipmentFactory.create('Pill. Culottes +3'),
    feet = EquipmentFactory.create('Skulk. Poulaines +3'),
    neck = EquipmentFactory.create("Assassin's Gorget +2"),
    waist = EquipmentFactory.create('Kentarch Belt +1'),
    ear1 = EquipmentFactory.create('Crep. Earring'),
    ear2 = EquipmentFactory.create('Skulk. Earring +1'),
    ring1 = ChirichRing1,
    ring2 = EquipmentFactory.create('Gere Ring'),
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
    range = EquipmentFactory.create('Exalted Crossbow'),
    ammo = EquipmentFactory.create('Acid Bolt'),
    head = EquipmentFactory.create('Malignance Chapeau'),
    body = EquipmentFactory.create('Malignance Tabard'),
    hands = EquipmentFactory.create('Malignance Gloves'),
    legs = EquipmentFactory.create('Malignance Tights'),
    feet = EquipmentFactory.create('Malignance Boots'),
    neck = EquipmentFactory.create('Null Loop'),
    waist = EquipmentFactory.create('Yemaya Belt'),
    ear1 = EquipmentFactory.create('Crepuscular Earring'),
    ear2 = EquipmentFactory.create('Telos Earring'),
    ring1 = EquipmentFactory.create('Cacoethic Ring'),
    ring2 = EquipmentFactory.create('Crepuscular Ring'),
    back = EquipmentFactory.create('Sacro mantle'),
}

sets.precast.RATH = set_combine(sets.precast.RA, {
    feet = EquipmentFactory.create("Skulker's Poulaines +3")
})

sets.midcast.RA = sets.precast.RA
sets.midcast.RA.Acc = sets.midcast.RA

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.buff['Sneak Attack'] = {
    ammo = EquipmentFactory.create('Yetshila +1'),
    head = AdhemarBonnet,
    body = EquipmentFactory.create("Pillager's Vest +4"),
    hands = EquipmentFactory.create("Skulker's Armlets +3"),
    legs = "Lustr. Subligar +1",
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
    neck = EquipmentFactory.create('Asn. Gorget +2'),
    waist = EquipmentFactory.create('Kentarch belt +1'),
    ear1 = EquipmentFactory.create('Mache Earring +1'),
    ear2 = EquipmentFactory.create('Odr Earring'),
    ring1 = EquipmentFactory.create('Ilabrat Ring'),
    ring2 = EquipmentFactory.create('Regal Ring'),
    back = Toutatis.STP,
}

sets.buff['Trick Attack'] = {
    ammo = EquipmentFactory.create('Yetshila +1'),
    head = EquipmentFactory.create("skulker's Bonnet +3"),
    body = PlundererVest,
    hands = EquipmentFactory.create('Pill. armlets +4'),
    legs = EquipmentFactory.create("Pillager's culottes +3"),
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
    neck = EquipmentFactory.create('Asn. Gorget +2'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    ear1 = EquipmentFactory.create('Dawn Earring'),
    ear2 = EquipmentFactory.create('Infused Earring'),
    ring1 = EquipmentFactory.create('Ilabrat Ring'),
    ring2 = EquipmentFactory.create('Regal Ring'),
    back = CannyCape,
}

sets.precast.JA['Collaborator'] = {
    head = EquipmentFactory.create("Skulker's bonnet +3"),
    body = PlundererVest,
    hands = PlundererArmlets,
    ear1 = EquipmentFactory.create('Friomisi Earring'),
    ring1 = EquipmentFactory.create('Cacoethic Ring')
}
sets.precast.JA['Accomplice'] = sets.precast.JA['Collaborator']

sets.precast.JA['Conspirator'] = { body = EquipmentFactory.create("skulker's Vest +3") }

sets.precast.JA['Animated Flourish'] = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    head = EquipmentFactory.create("Skulker's Bonnet +3"),
    body = EquipmentFactory.create("Plunderer's Vest +3"),
    hands = EquipmentFactory.create("Skulker's Armlets +3"),
    legs = EquipmentFactory.create("Skulker's culottes +3"),
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
    neck = EquipmentFactory.create('Unmoving Collar +1'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    ear1 = EquipmentFactory.create('Friomisi Earring'),
    ear2 = EquipmentFactory.create('Eabani Earring'),
    ring1 = EquipmentFactory.create('Provocare Ring'),
    ring2 = EquipmentFactory.create('Supershear Ring'),
    back = EquipmentFactory.create('Solemnity Cape')
}
sets.precast.JA['Flee'] = { feet = EquipmentFactory.create('Pill. Poulaines +3') }

-- Ensure the structure exists
sets.precast = sets.precast or {}
sets.precast.JA = sets.precast.JA or {}

-- Use bracket-free syntax to avoid parsing issues
sets.precast.JA.Hide = { body = EquipmentFactory.create("Pill. Vest +4") }

sets.precast.JA['Steal'] = {
    neck = EquipmentFactory.create('Pentalagus Charm'),
    hands = EquipmentFactory.create("Thief's Kote"),
    legs = EquipmentFactory.create("Assassin's Culottes"),
    feet = EquipmentFactory.create('Pill. Poulaines +3')
}
sets.precast.JA['Despoil'] = {
    legs = EquipmentFactory.create("Skulker's culottes +3"),
    feet = EquipmentFactory.create("Skulker's poulaines +3")
}

sets.precast.JA['Perfect Dodge'] = {
    hands = PlundererArmlets
}
sets.precast.JA['Feint'] = {
    legs = EquipmentFactory.create('Plun. Culottes +3')
}
sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

sets.precast.Waltz = {
    ammo = EquipmentFactory.create('Staunch Tathlum +1'),
    head = EquipmentFactory.create('Mummu Bonnet +2'),
    body = EquipmentFactory.create('Turms Harness'),
    hands = EquipmentFactory.create('Slither Gloves +1'),
    legs = EquipmentFactory.create('Dashing Subligar'),
    feet = EquipmentFactory.create('Meg. Jam. +2'),
    neck = EquipmentFactory.create('Elite Royal Collar'),
    waist = EquipmentFactory.create('Flume Belt'),
    ear1 = EquipmentFactory.create('Delta Earring'),
    ear2 = EquipmentFactory.create("Handler's Earring"),
    ring1 = EquipmentFactory.create('Asklepian Ring'),
    ring2 = EquipmentFactory.create("Valseur's Ring"),
    back = EquipmentFactory.create('Solemnity Cape')
}
sets.precast.Step = {
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    head = EquipmentFactory.create('Malignance Chapeau'),
    body = EquipmentFactory.create("Pillager's Vest +4"),
    hands = EquipmentFactory.create('Meg. Gloves +2'),
    legs = EquipmentFactory.create('Malignance Tights'),
    feet = EquipmentFactory.create('Malignance Boots'),
    neck = EquipmentFactory.create('Asn. Gorget +2'),
    waist = EquipmentFactory.create('Kentarch belt +1'),
    ear1 = EquipmentFactory.create('Crepuscular Earring'),
    ear2 = EquipmentFactory.create("Skulker's Earring +1"),
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Toutatis.STP
}
sets.precast.JA.Provoke = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    head = EquipmentFactory.create("Skulker's Bonnet +3"),
    body = EquipmentFactory.create("Plunderer's Vest +3"),
    hands = EquipmentFactory.create("Skulker's Armlets +3"),
    legs = EquipmentFactory.create("Skulker's culottes +3"),
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
    neck = EquipmentFactory.create('Unmoving Collar +1'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    ear1 = EquipmentFactory.create('Friomisi Earring'),
    ear2 = EquipmentFactory.create('Eabani Earring'),
    ring1 = EquipmentFactory.create('Provocare Ring'),
    ring2 = EquipmentFactory.create('Supershear Ring'),
    back = EquipmentFactory.create('Solemnity Cape')
}
sets.precast.Flourish1 = sets.precast.JA.Provoke
sets.precast.FC = {
    ammo = EquipmentFactory.create('Sapience Orb'),
    head = HerculeanHelm,
    body = EquipmentFactory.create('Dread Jupon'),
    hands = EquipmentFactory.create('Leyline Gloves'),
    legs = EquipmentFactory.create('Enif Cosciales'),
    neck = EquipmentFactory.create('Voltsurge Torque'),
    ear1 = EquipmentFactory.create('Enchntr. Earring +1'),
    ear2 = EquipmentFactory.create('Loquac. Earring'),
    ring2 = EquipmentFactory.create('Prolix Ring')
}
sets.precast.FC.Utsusemi = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = EquipmentFactory.create('Yetshila +1'),
    head = AdhemarBonnet,
    body = PlundererVest,
    hands = AdhemarWrist,
    legs = EquipmentFactory.create("Pillager's culottes +3"),
    feet = LustraLeggings,
    neck = EquipmentFactory.create('Fotia Gorget'),
    waist = EquipmentFactory.create('Fotia Belt'),
    ear1 = MoonShadeEarring,
    ear2 = EquipmentFactory.create('Odr Earring'),
    ring1 = EquipmentFactory.create("Cornelia's Ring"),
    ring2 = EquipmentFactory.create('Regal Ring'),
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
    hands = EquipmentFactory.create("Skulker's Armlets +3")
})

sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'].Mid, {
    hands = EquipmentFactory.create('Pill. Armlets +4')
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
    hands = EquipmentFactory.create("Skulker's Armlets +3")
})

sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'].Mid, {
    hands = EquipmentFactory.create('Pill. Armlets +4')
})

sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'].Mid, {
    hands = EquipmentFactory.create('Pill. Armlets +4')
})

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    head = EquipmentFactory.create('Pill. Bonnet +4'),
    body = EquipmentFactory.create("skulker's Vest +3"),
    hands = EquipmentFactory.create('Meg. Gloves +2'),
    legs = EquipmentFactory.create('Plun. Culottes +3'),
    neck = EquipmentFactory.create('Asn. Gorget +2'),
    waist = EquipmentFactory.create('Kentarch belt +1'),
    back = Toutatis.WS2,
    ammo = EquipmentFactory.create("Oshasha's treatise")
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
    hands = EquipmentFactory.create('Pill. Armlets +4'),
    ammo = EquipmentFactory.create('Yetshila +1')
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
    head = "Skulker's Bonnet +3",
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
    hands = EquipmentFactory.create('Pill. Armlets +4'),
    ammo = EquipmentFactory.create('Yetshila +1')
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
    hands = EquipmentFactory.create('Pill. Armlets +4'),
    ammo = EquipmentFactory.create('Yetshila +1')
})

sets.precast.WS['Aeolian Edge'] = {
    ammo = EquipmentFactory.create("Oshasha's treatise"),
    head = "Nyame Helm",
    neck = EquipmentFactory.create('Sibyl Scarf'),
    body = "Nyame Mail",
    legs = "Nyame Flanchard",
    hands = "Nyame Gauntlets",
    feet = "Nyame Sollerets",
    ear1 = EquipmentFactory.create('Sortiarius Earring'),
    ear2 = EquipmentFactory.create('Friomisi Earring'),
    ring1 = EquipmentFactory.create("Epaminondas's Ring"),
    ring2 = EquipmentFactory.create("Cornelia's Ring"),
    waist = EquipmentFactory.create("Orpheus's Sash"),
    back = Toutatis.WS2
}

sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Oshasha's Treatise"),
    head = EquipmentFactory.create("skulker's Bonnet +3"),
    body = EquipmentFactory.create("skulker's Vest +3"),
    hands = EquipmentFactory.create("Skulker's Armlets +3"),
    legs = EquipmentFactory.create('Pill. Culottes +3'),
    feet = PlundererPoulaines,
    neck = EquipmentFactory.create('Fotia Gorget'),
    waist = EquipmentFactory.create('Fotia Belt'),
    ear1 = EquipmentFactory.create('Ishvara Earring'),
    ear2 = EquipmentFactory.create("Skulker's Earring +1"),
    ring1 = EquipmentFactory.create('Ilabrat Ring'),
    ring2 = EquipmentFactory.create('Mummu Ring'),
    back = Toutatis.WS1
})

-- =========================================================================================================
--                                           TPBonus Sets (Moonshade Earring)
-- =========================================================================================================

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    ear2 = EquipmentFactory.create('Moonshade Earring', nil, nil, { 'Accuracy+4', 'TP Bonus +250' })
}

-- TPBonus variants for main weapon skills
sets.precast.WS["Rudra's Storm"].TPBonus = set_combine(sets.precast.WS["Rudra's Storm"], sets.precast.WS.TPBonus)
sets.precast.WS["Rudra's Storm"].SA.TPBonus = set_combine(sets.precast.WS["Rudra's Storm"].SA, sets.precast.WS.TPBonus)
sets.precast.WS["Rudra's Storm"].TA.TPBonus = set_combine(sets.precast.WS["Rudra's Storm"].TA, sets.precast.WS.TPBonus)
sets.precast.WS["Rudra's Storm"].SATA.TPBonus = set_combine(sets.precast.WS["Rudra's Storm"].SATA,
    sets.precast.WS.TPBonus)

sets.precast.WS['Evisceration'].TPBonus = set_combine(sets.precast.WS['Evisceration'], sets.precast.WS.TPBonus)
sets.precast.WS['Evisceration'].SA.TPBonus = set_combine(sets.precast.WS['Evisceration'].SA, sets.precast.WS.TPBonus)
sets.precast.WS['Evisceration'].TA.TPBonus = set_combine(sets.precast.WS['Evisceration'].TA, sets.precast.WS.TPBonus)
sets.precast.WS['Evisceration'].SATA.TPBonus = set_combine(sets.precast.WS['Evisceration'].SATA, sets.precast.WS.TPBonus)

sets.precast.WS['Exenterator'].TPBonus = set_combine(sets.precast.WS['Exenterator'], sets.precast.WS.TPBonus)
sets.precast.WS['Exenterator'].SA.TPBonus = set_combine(sets.precast.WS['Exenterator'].SA, sets.precast.WS.TPBonus)
sets.precast.WS['Exenterator'].TA.TPBonus = set_combine(sets.precast.WS['Exenterator'].TA, sets.precast.WS.TPBonus)
sets.precast.WS['Exenterator'].SATA.TPBonus = set_combine(sets.precast.WS['Exenterator'].SATA, sets.precast.WS.TPBonus)

sets.precast.WS['Dancing Edge'].TPBonus = set_combine(sets.precast.WS['Dancing Edge'], sets.precast.WS.TPBonus)
sets.precast.WS['Dancing Edge'].SA.TPBonus = set_combine(sets.precast.WS['Dancing Edge'].SA, sets.precast.WS.TPBonus)
sets.precast.WS['Dancing Edge'].TA.TPBonus = set_combine(sets.precast.WS['Dancing Edge'].TA, sets.precast.WS.TPBonus)
sets.precast.WS['Dancing Edge'].SATA.TPBonus = set_combine(sets.precast.WS['Dancing Edge'].SATA, sets.precast.WS.TPBonus)

sets.precast.WS['Shark Bite'].TPBonus = set_combine(sets.precast.WS['Shark Bite'], sets.precast.WS.TPBonus)
sets.precast.WS['Shark Bite'].SA.TPBonus = set_combine(sets.precast.WS['Shark Bite'].SA, sets.precast.WS.TPBonus)
sets.precast.WS['Shark Bite'].TA.TPBonus = set_combine(sets.precast.WS['Shark Bite'].TA, sets.precast.WS.TPBonus)
sets.precast.WS['Shark Bite'].SATA.TPBonus = set_combine(sets.precast.WS['Shark Bite'].SATA, sets.precast.WS.TPBonus)

-- Other weapon skills (no SA/TA variants)
sets.precast.WS['Aeolian Edge'].TPBonus = set_combine(sets.precast.WS['Aeolian Edge'], sets.precast.WS.TPBonus)
sets.precast.WS['Circle Blade'].TPBonus = set_combine(sets.precast.WS['Circle Blade'], sets.precast.WS.TPBonus)

-- =========================================================================================================
--                                           Equipments - TreasureHunter Sets
-- =========================================================================================================

-- Base TH set (TH pieces only)
sets.TreasureHunter = {
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
}

-- Specialized TH+SA/TA combinations for optimal performance
sets.TreasureHunter.SA = set_combine(sets.TreasureHunter, sets.buff['Sneak Attack'])

sets.TreasureHunter.TA = set_combine(sets.TreasureHunter, sets.buff['Trick Attack'])

sets.TreasureHunter.SATA = set_combine(sets.TreasureHunter, sets.buff['Sneak Attack'], sets.buff['Trick Attack'])


-- setup_dynamic_th() will be called from THF_FUNCTION.lua after it's loaded

sets.TreasureHunterRA = set_combine(sets.precast.RA, {
    feet = EquipmentFactory.create("Skulker's Poulaines +3")
})

sets.midcast.RA.TH = set_combine(sets.precast.RA, {
    feet = EquipmentFactory.create("Skulker's Poulaines +3")
})

sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {
    feet = EquipmentFactory.create("Skulker's Poulaines +3")
})

-- =========================================================================================================
--                                           Equipments - midcast.FastRecast Sets
-- =========================================================================================================
sets.midcast.FastRecast = {
    ammo = EquipmentFactory.create('Aurgelmir Orb +1'),
    head = EquipmentFactory.create("skulker's Bonnet +3"),
    body = EquipmentFactory.create('Nyame Mail'),
    hands = EquipmentFactory.create("Skulker's Armlets +3"),
    legs = EquipmentFactory.create("Skulker's culottes +3"),
    feet = EquipmentFactory.create("Skulker's Poulaines +3"),
    neck = EquipmentFactory.create('Elite Royal Collar'),
    waist = EquipmentFactory.create('Svelt. Gouriz +1'),
    ear1 = EquipmentFactory.create('Sherida Earring'),
    ear2 = EquipmentFactory.create('Eabani Earring'),
    ring1 = ChirichRing2,
    ring2 = EquipmentFactory.create('Defending Ring'),
    back = EquipmentFactory.create('Solemnity Cape')
}

sets.midcast.Utsusemi = sets.midcast.FastRecast

sets.buff.Doom = {
    neck = EquipmentFactory.create("Nicander's Necklace"), -- Reduces Doom effects
    ring1 = EquipmentFactory.create("Purity Ring"),        -- Additional Doom resistance
    waist = EquipmentFactory.create("Gishdubar Sash"),     -- Enhances Doom recovery effects
}

-- Simple job loading notification
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("THF")
