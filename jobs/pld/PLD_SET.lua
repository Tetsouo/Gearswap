---============================================================================
--- FFXI GearSwap Equipment Sets - Paladin Comprehensive Gear Collection
---============================================================================
--- Professional Paladin equipment set definitions providing optimized
--- gear configurations for tanking excellence, spell casting efficiency,
--- enmity management, and advanced defensive strategies. Features:
---
--- • **Ultimate Tanking Systems** - PDT/MDT optimization for maximum survivability
--- • **Spell Casting Excellence** - Fast Cast, SIRD, and cure potency sets
--- • **Enmity Management** - Flash, Provoke, and threat generation equipment
--- • **Shield Mastery Integration** - Block rate and shield skill optimization
--- • **Divine/Majesty Coordination** - Job ability enhancement for spell power
--- • **Phalanx Specialization** - Enhanced damage reduction and spell potency
--- • **Weapon Skill Optimization** - STR and accuracy sets for offensive capability
--- • **MP Conservation Systems** - Refresh and mana management equipment
---
--- This comprehensive equipment database enables PLD to excel as the ultimate
--- tank while maintaining spell casting versatility and party protection
--- capabilities with intelligent defensive and offensive coordination.
---
--- @file jobs/pld/PLD_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by PLD_FUNCTION.lua for tanking and spell management
---
--- @see jobs/pld/PLD_FUNCTION.lua for paladin logic and defensive coordination
--- @see Tetsouo_PLD.lua for job configuration and tanking mode management
---============================================================================

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
-- Define Rudianos set with different augments for different situations
-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

Rudianos = {
    tank = EquipmentFactory.create("Rudianos's Mantle", 1, nil,
        { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', }),
    FCSIRD = EquipmentFactory.create("Rudianos's Mantle", 12, nil,
        { 'HP+60', 'HP+20', '"Fast Cast"+10', 'Spell interruption rate down-10%' }),
    STP = EquipmentFactory.create("Rudianos's Mantle", 0, nil,
        { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Occ. inc. resist. to stat. ailments+10' }),
    WS = EquipmentFactory.create("Rudianos's Mantle", 0, nil,
        { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%' }),
    cure = EquipmentFactory.create("Rudianos's Mantle", 0, nil,
        { 'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Phys. dmg. taken-10%' })
}

JumalikHead = EquipmentFactory.create('Jumalik Helm', 0, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = EquipmentFactory.create('Jumalik Mail', 0, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

ChirichRing1 = EquipmentFactory.create('Chirich Ring +1', 0, 'wardrobe 1')
ChirichRing2 = EquipmentFactory.create('Chirich Ring +1', 0, 'wardrobe 2')
StikiRing1 = EquipmentFactory.create('Stikini Ring +1', 0, 'wardrobe 6')
StikiRing2 = EquipmentFactory.create('Stikini Ring +1', 0, 'wardrobe 7')
Moonlight1 = EquipmentFactory.create('MoonLight Ring', 13, 'Wardrobe 2')
Moonlight2 = EquipmentFactory.create('MoonLight Ring', 12, 'Wardrobe 4')

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Burtgang'] = { main = EquipmentFactory.create('Burtgang') }
sets['Shining One'] = { main = EquipmentFactory.create('Shining One'), sub = EquipmentFactory.create('Alber Strap') }
sets['Naegling'] = { main = EquipmentFactory.create('Naegling') }
sets['Malevo'] = {
    main = EquipmentFactory.create("Malevolence", 0, nil,
        { 'INT+10', 'Mag. Acc.+10', '"Mag.Atk.Bns."+8', '"Fast Cast"+5' })
}
-- =========================================================================================================
sets['Ochain'] = { sub = EquipmentFactory.create('Ochain') }
sets['Alber'] = { sub = EquipmentFactory.create('Alber Strap') }
sets['Aegis'] = { sub = EquipmentFactory.create('Aegis') }
sets['Duban'] = { sub = EquipmentFactory.create('Duban') }
sets['Blurred'] = { sub = EquipmentFactory.create('Blurred Shield +1') }

sets['Staunch'] = { ammo = EquipmentFactory.create('Staunch Tathlum +1') }

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    ammo = EquipmentFactory.create('Staunch Tathlum +1', 0),        -- DT -3%, Status resistance +11, Spell interruption rate -11%
    head = EquipmentFactory.create('Chev. Armet +3', 12),           -- HP+145, DT -11%, Converts 8% of physical damage to MP
    body = EquipmentFactory.create("Adamantite Armor", 13),         -- HP+182, DT -20%, Very high DEF
    hands = EquipmentFactory.create("Chev. Gauntlets +3", 8),       -- HP+64, DT -11%, Shield block bonus
    legs = EquipmentFactory.create('Chev. Cuisses +3', 10),         -- HP+127, DT -13%, Enmity+14
    feet = EquipmentFactory.create('Chev. Sabatons +3', 6),         -- HP+52, Completes set bonus for damage absorption
    neck = EquipmentFactory.create('Kgt. beads +2', 7),             -- HP+60, DT -7%, Enmity+10
    waist = EquipmentFactory.create('Null Belt', 0),                -- Magic defense bonus, no HP gain
    left_ear = EquipmentFactory.create('Odnowa Earring +1', 9),     -- HP+110, DT -3%, MDT -2%
    right_ear = EquipmentFactory.create('Chev. Earring +1', 0),     -- DT -4%, Cure potency +11%
    left_ring = EquipmentFactory.create('Fortified Ring', 5),       -- MDT -5%, Reduces enemy critical hit rate
    right_ring = EquipmentFactory.create('Gelatinous Ring +1', 11), -- HP+100, PDT -7%, VIT+15
    back = Rudianos.tank                                            -- PDT -10%, VIT+20, Enmity+10
}

sets.idle_After_Cure = {
    ammo = EquipmentFactory.create('Staunch Tathlum +1', 0),        -- DT -3%, Status resistance +11, Spell interruption rate -11%
    head = EquipmentFactory.create('Chev. Armet +3', 12),           -- HP+145, DT -11%, Converts 8% of physical damage to MP
    body = EquipmentFactory.create("Adamantite Armor", 13),         -- HP+182, DT -20%, Very high DEF
    hands = EquipmentFactory.create("Chev. Gauntlets +3", 8),       -- HP+64, DT -11%, Shield block bonus
    legs = EquipmentFactory.create('Chev. Cuisses +3', 10),         -- HP+127, DT -13%, Enmity+14
    feet = EquipmentFactory.create('Chev. Sabatons +3', 6),         -- HP+52, Completes set bonus for damage absorption
    neck = EquipmentFactory.create('Kgt. beads +2', 7),             -- HP+60, DT -7%, Enmity+10
    waist = EquipmentFactory.create('Asklepian Belt', 0),           -- Magic defense bonus, no HP gain
    left_ear = EquipmentFactory.create('Odnowa Earring +1', 9),     -- HP+110, DT -3%, MDT -2%
    right_ear = EquipmentFactory.create('Chev. Earring +1', 0),     -- DT -4%, Cure potency +11%
    left_ring = EquipmentFactory.create('Fortified Ring', 5),       -- MDT -5%, Reduces enemy critical hit rate
    right_ring = EquipmentFactory.create('Gelatinous Ring +1', 11), -- HP+100, PDT -7%, VIT+15
    back = Rudianos.tank                                            -- PDT -10%, VIT+20, Enmity+10
}


sets.idle.PDT = sets.idle

sets.idle.MDT = {
    sub = EquipmentFactory.create('Aegis'),
    ammo = "Staunch Tathlum +1",
    head = { name = "Sakpata's Helm", augments = { 'Path: A', } },
    body = { name = "Sakpata's Plate", augments = { 'Path: A', } },
    hands = { name = "Sakpata's Gauntlets", augments = { 'Path: A', } },
    legs = { name = "Sakpata's Cuisses", augments = { 'Path: A', } },
    feet = { name = "Sakpata's Leggings", augments = { 'Path: A', } },
    neck = "Moonlight Necklace",
    waist = "Carrier's Sash",
    left_ear = "Tuisto Earring",
    right_ear = "Eabani Earring",
    left_ring = "Purity Ring",
    right_ring = { name = "Gelatinous Ring +1", augments = { 'Path: A', } },
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
}

sets.idleNormal = set_combine(sets.idle, {
    head = EquipmentFactory.create('Chev. Armet +3', 14),
    body = EquipmentFactory.create("Adamantite Armor", 15),
    legs = EquipmentFactory.create('Chev. Cuisses +3', 16),
    neck = EquipmentFactory.create("Kgt. beads +2", 17),
    waist = EquipmentFactory.create("Creed Baudrier", 18),
    Left_ring = Moonlight1,
    right_ring = Moonlight2,
})

sets.idleXp = set_combine(sets.idle, {
    main = "Burtgang",
    sub = "Duban",
    body = EquipmentFactory.create('Chev. Cuirass +3', 16),
})

sets.idle.Town = {
    ammo = EquipmentFactory.create("Staunch Tathlum +1", 0),
    head = EquipmentFactory.create("Chev. Armet +3", 0),
    body = EquipmentFactory.create("Jumalik Mail", 0),
    hands = EquipmentFactory.create("Regal Gauntlets", 13),
    legs = EquipmentFactory.create("Carmine Cuisses +1", 12),
    feet = EquipmentFactory.create("Chev. Sabatons +3", 1),
    neck = EquipmentFactory.create("Coatl Gorget +1", 0),
    waist = EquipmentFactory.create("Plat. Mog. Belt", 8),
    left_ear = EquipmentFactory.create("Etiolation Earring", 0),
    right_ear = EquipmentFactory.create("Chev. Earring +1", 0),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = Rudianos.tank,
}

sets.latent_refresh = {
    ammo = "Staunch Tathlum +1",
    head = "Chev. Armet +3",
    body = { name = "Jumalik Mail", augments = { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2', } },
    hands = "Regal Gauntlets",
    legs = { name = "Carmine Cuisses +1", augments = { 'HP+80', 'STR+12', 'INT+12', } },
    feet = "Chev. Sabatons +3",
    neck = "Coatl Gorget +1",
    waist = "Plat. Mog. Belt",
    left_ear = "Etiolation Earring",
    right_ear = { name = "Chev. Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+13', 'Mag. Acc.+13', 'Damage taken-4%', } },
    left_ring = "Stikini Ring +1",
    right_ring = "Stikini Ring +1",
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
    -- Total Refresh 5
}

-- =========================================================================================================
--                                           Equipments - FullEnmity Sets
-- =========================================================================================================
sets.FullEnmity = {
    --[[ sub = EquipmentFactory.create('Srivatsa', 14), ]]       -- Optional: Shield with high DT
    ammo = EquipmentFactory.create('Sapience Orb', 3),           -- Enmity+2, Fast Cast+2%
    head = EquipmentFactory.create('Loess Barbuta +1', 10),      -- HP+105, Enmity+14, DT-10%
    neck = EquipmentFactory.create('Moonlight Necklace', 2),     -- Enmity+15, SIRD+15%
    left_ear = EquipmentFactory.create("Trux Earring", 6),       -- Enmity+5
    right_ear = EquipmentFactory.create('Cryptic Earring', 8),   -- HP+40, Enmity+4
    body = EquipmentFactory.create('Souv. Cuirass +1', 11),      -- HP+66, Enmity+11, DT-10%
    hands = EquipmentFactory.create('Souv. Handsch. +1', 13),    -- HP+134, Enmity+9, MDT-5%
    left_ring = EquipmentFactory.create('Apeile Ring +1', 5),    -- Enmity+9, Regen+4
    right_ring = EquipmentFactory.create('Apeile Ring', 4),      -- Enmity+9, Regen+3
    back = Rudianos.tank,                                        -- VIT+20, Enmity+10, PDT-10%
    waist = EquipmentFactory.create('Creed Baudrier', 7),        -- HP+40, Enmity+5
    legs = EquipmentFactory.create('Souv. Diechlings +1', 12),   -- HP+57, Enmity+9, DT-4%
    feet = EquipmentFactory.create("Chevalier's Sabatons +3", 9) -- HP+52, Enmity+15, Fast Cast+13%
    -- Gear Enmity 159
    -- Crusade Enmity 189
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity,
    { feet = EquipmentFactory.create("Chevalier's Sabatons +3") })
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Vallation'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Valiance'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Pflug'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, { body = EquipmentFactory.create('Cab. Surcoat') })
sets.precast.JA['Invincible'] = set_combine(sets.FullEnmity,
    { legs = EquipmentFactory.create('Caballarius Breeches +3') })
sets.precast.JA['Holy Circle'] = set_combine(sets.FullEnmity, { feet = EquipmentFactory.create('Rev. Leggings +3') })
sets.precast.JA['Shield Bash'] = set_combine(sets.FullEnmity, { hands = EquipmentFactory.create('Cab. Gauntlets +3') })
sets.precast.JA['Sentinel'] = set_combine(sets.FullEnmity, { feet = EquipmentFactory.create('Cab. Leggings +3') })
sets.precast.JA['Rampart'] = set_combine(sets.FullEnmity, { head = EquipmentFactory.create('Cab. Coronet +3') })

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    ammo = EquipmentFactory.create('Sapience Orb', 5),               -- Fast Cast +2%, Enmity+2
    head = EquipmentFactory.create('Carmine Mask +1', 8),            -- HP+38, Fast Cast +14%
    neck = EquipmentFactory.create("Orunmila's Torque", 6),          -- MP+30, Fast Cast +5%
    left_ear = EquipmentFactory.create("Enchanter's Earring +1", 1), -- Fast Cast +2%
    right_ear = EquipmentFactory.create('Loquac. Earring', 2),       -- MP+30, Fast Cast +2%
    body = EquipmentFactory.create('Reverence Surcoat +3', 13),      -- **HP+254**, Fast Cast +10%, DT -11%
    hands = EquipmentFactory.create('Leyline Gloves', 7),            -- **HP+25**, Fast Cast +8%
    left_ring = EquipmentFactory.create('Kishar Ring', 4),           -- Fast Cast +4%
    right_ring = EquipmentFactory.create('Prolix Ring', 3),          -- Fast Cast +2%
    back = Rudianos.FCSIRD,                                          -- **HP+80**, Fast Cast +10%, SIRD -10%
    waist = EquipmentFactory.create('Platinum Moogle Belt', 11),     -- **HP+10%**, DT -3%
    legs = EquipmentFactory.create('Enif Cosciales', 9),             -- **HP+40**, Fast Cast +8%
    feet = EquipmentFactory.create("Chevalier's Sabatons +3", 10)    -- **HP+52**, Fast Cast +13%
}

sets.precast.FC['Healing Magic'] = sets.precast.FC
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Phalanx'] = sets.precast.FC
sets.precast.FC['Crusade'] = sets.precast.FC
sets.precast.FC['Cocoon'] = sets.precast.FC
sets.precast.FC['Flash'] = sets.precast.FC
sets.precast.FC['Banish'] = sets.precast.FC
sets.precast.FC['Banishga'] = sets.precast.FC
sets.precast.FC['Blank Gaze'] = sets.precast.FC
sets.precast.FC['Jettatura'] = sets.precast.FC
sets.precast.FC['Sheep Song'] = sets.precast.FC
sets.precast.FC['Geist Wall'] = sets.precast.FC
sets.precast.FC['Cold Wave'] = sets.precast.FC
sets.precast.FC['Stinking Gas'] = sets.precast.FC
sets.precast.FC['Frightful Roar'] = sets.precast.FC
sets.precast.FC['Metallic Body'] = sets.precast.FC
sets.precast.FC['Foil'] = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Enmity Sets
-- =========================================================================================================
sets.midcast.Enmity = sets.FullEnmity

sets.midcast.SIRDEnmity = {
    ammo = "Staunch Tathlum +1",
    head = { name = "Loess Barbuta +1", augments = { 'Path: A', } },
    body = "Chev. Cuirass +3",
    hands = { name = "Souv. Handsch. +1", augments = { 'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%', } },
    legs = { name = "Founder's Hose", augments = { 'MND+10', 'Mag. Acc.+15', 'Attack+15', 'Breath dmg. taken -5%', } },
    feet = { name = "Odyssean Greaves", augments = { 'Attack+19', 'Enmity+8', 'Accuracy+8', } },
    neck = "Moonlight Necklace",
    waist = "Creed Baudrier",
    left_ear = "Tuisto Earring",
    right_ear = "Knightly Earring",
    left_ring = "Apeile Ring +1",
    right_ring = { name = "Gelatinous Ring +1", augments = { 'Path: A', } },
    back = Rudianos.tank
}
-- Gear Enmity 119
-- Crusade Enmity 149
-- SIRD 105%

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================

-- ================================================ Phalanx Sets ===========================================
sets.midcast.PhalanxPotency = {
    --[[ main = cereateEquipment("Sakpata's Sword"), ]]
    ammo = EquipmentFactory.create('Staunch Tathlum +1'),
    head = EquipmentFactory.create('Odyssean helm', 13),
    neck = EquipmentFactory.create("Colossus's Torque"),
    left_ear = EquipmentFactory.create('Tuisto Earring', 12),
    right_ear = EquipmentFactory.create('Chev. Earring +1'),
    body = EquipmentFactory.create('Odyssean Chestplate'),
    hands = EquipmentFactory.create('Souv. Handsch. +1', 14),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = EquipmentFactory.create('Weard Mantle', 1),
    waist = EquipmentFactory.create("Audumbla Sash"),
    legs = EquipmentFactory.create("Sakpata's Cuisses", 1),
    feet = EquipmentFactory.create('Souveran Schuhs +1')
}

sets.midcast.SIRDPhalanx = {
    main = EquipmentFactory.create("Sakpata's Sword"),
    sub = EquipmentFactory.create("Priwen", 0, nil, { 'HP+50', 'Mag. Evasion+50', 'Damage Taken -3%' }),
    ammo = EquipmentFactory.create("Staunch Tathlum +1"),
    head = EquipmentFactory.create("Odyssean Helm"),
    body = EquipmentFactory.create("Odyssean Chestplate"),
    hands = EquipmentFactory.create("Souv. Handsch. +1"),
    legs = EquipmentFactory.create("Founder's Hose"),
    feet = { name = "Odyssean Greaves", augments = { 'Accuracy+21', 'Weapon skill damage +3%', 'Phalanx +4', } },
    neck = EquipmentFactory.create("Moonlight Necklace"),
    waist = EquipmentFactory.create("Audumbla Sash"),
    left_ear = EquipmentFactory.create("Knightly Earring"),
    right_ear = EquipmentFactory.create("Odnowa Earring +1"),
    left_ring = EquipmentFactory.create("Defending Ring"),
    right_ring = EquipmentFactory.create("Gelatinous Ring +1"),
    back = EquipmentFactory.create("Weard Mantle", 0, nil, { 'VIT+4', 'Phalanx +5' })
}

-- ================================================ Enlight Sets ==========================================
sets.midcast['Enlight'] = set_combine(sets.midcast.SIRDEnmity, {
    head = JumalikHead, --Refresh 1
    body = EquipmentFactory.create('Reverence surcoat +3'),
    hands = EquipmentFactory.create('Eschite Gauntlets'),
    waist = EquipmentFactory.create('Asklepian belt'),
    back = EquipmentFactory.create("Moonlight Cape", 16),
    left_ear = EquipmentFactory.create("Knight's Earring")
})

-- ================================================ Enhancing Sets ========================================
sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.SIRDEnmity, {
    body = EquipmentFactory.create('Shabti Cuirass')
})

-- ================================================ Enmity Sets ===========================================
sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
sets.midcast['Cocoon'] = sets.midcast.SIRDEnmity
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.midcast.SIRDEnmity
sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity
sets.midcast['Sheep Song'] = sets.midcast.SIRDEnmity
sets.midcast['Frightful Roar'] = sets.midcast.SIRDEnmity
sets.midcast['Cold Wave'] = sets.midcast.SIRDEnmity
sets.midcast['Stinking Gas'] = sets.midcast.SIRDEnmity
sets.midcast['Blank Gaze'] = sets.midcast.SIRDEnmity
sets.midcast['Crusade'] = sets.midcast['Enhancing Magic']
sets.midcast['Reprisal'] = sets.midcast['Enhancing Magic']
sets.midcast['Protect'] = sets.midcast['Enhancing Magic']
sets.midcast['Shell'] = sets.midcast['Enhancing Magic']
sets.midcast['Refresh'] = sets.midcast.SIRDEnmity
sets.midcast['Haste'] = sets.midcast.SIRDEnmity
sets.midcast['Foil'] = sets.midcast.SIRDEnmity

-- ================================================ Cure Sets ==============================================
sets.Cure = {
    ammo = EquipmentFactory.create('staunch Tathlum +1', 1),
    head = EquipmentFactory.create('Souv. Schaller +1', 8),
    left_ear = EquipmentFactory.create('tuisto Earring', 10),
    right_ear = EquipmentFactory.create('Chev. Earring +1', 0),
    hands = EquipmentFactory.create('Regal Gauntlets', 7),
    back = EquipmentFactory.create('Moonlight Cape', 12),
    legs = EquipmentFactory.create("Founder's Hose", 0),
    feet = EquipmentFactory.create('Odyssean Greaves', 5)
}

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = "Crepuscular Pebble",
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs = "Sakpata's Cuisses",
    feet = "Sulevia's Leggings +2",
    neck = "Knight's bead Necklace +2",
    waist = EquipmentFactory.create("Sailfi Belt +1", 3),
    left_ear = "Ishvara Earring",
    right_ear = "Thrud Earring",
    left_ring = "Cornelia's Ring",
    right_ring = "Sroda Ring",
    back = Rudianos.WS
}

sets.precast.WS.Acc = set_combine(sets.precast.WS, {})
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Atonement'] = sets.FullEnmity

sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("oshasha's treatise"),
    head = EquipmentFactory.create("Nyame Helm"),
    body = EquipmentFactory.create("Nyame Mail"),
    hands = EquipmentFactory.create("Nyame Gauntlets"),
    legs = EquipmentFactory.create("Nyame Flanchard"),
    feet = EquipmentFactory.create("Nyame Sollerets"),
    neck = EquipmentFactory.create("knight's bead Necklace +2"),
    waist = EquipmentFactory.create("Sailfi Belt +1"),
    left_ear = EquipmentFactory.create("thrud Earring"),
    right_ear = EquipmentFactory.create("Tuisto Earring"),
    left_ring = EquipmentFactory.create("Cornelia's Ring"),
    right_ring = EquipmentFactory.create("Regal Ring"),
    back = Rudianos.WS
})

sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {
    head = EquipmentFactory.create('Nyame Helm'),
    body = EquipmentFactory.create('Nyame Mail'),
    hands = EquipmentFactory.create('Nyame Gauntlets'),
    legs = EquipmentFactory.create('Nyame Flanchard'),
    feet = EquipmentFactory.create('Nyame Sollerets'),
    neck = EquipmentFactory.create('Sanctity Necklace'),
    waist = EquipmentFactory.create("Orpheus's Sash"),
    left_ear = EquipmentFactory.create('Friomisi Earring'),
    right_ring = EquipmentFactory.create('Regal Ring'),
    back = EquipmentFactory.create('Toro Cape')
})

sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Oshasha's treatise"),
    head = EquipmentFactory.create("Nyame Helm"),
    body = EquipmentFactory.create("Nyame Mail"),
    hands = EquipmentFactory.create("Nyame Gauntlets"),
    legs = EquipmentFactory.create("Nyame Flanchard"),
    feet = EquipmentFactory.create("Nyame Sollerets"),
    neck = EquipmentFactory.create("Baetyl Pendant"),
    waist = EquipmentFactory.create("Orpheus's Sash"),
    left_ear = EquipmentFactory.create("Crematio Earring"),
    right_ear = EquipmentFactory.create("Friomisi Earring"),
    left_ring = EquipmentFactory.create("Cornelia's Ring"),
    right_ring = EquipmentFactory.create("Defending ring"),
    back = EquipmentFactory.create("Moonlight Cape")
})

sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {
    ammo = EquipmentFactory.create("Staunch Tathlum +1"),
    head = EquipmentFactory.create("Nyame Helm"),
    body = EquipmentFactory.create("Nyame Mail"),
    hands = EquipmentFactory.create("Nyame Gauntlets"),
    legs = EquipmentFactory.create("Nyame Flanchard"),
    feet = EquipmentFactory.create("Nyame Sollerets"),
    neck = EquipmentFactory.create("Sibyl Scarf"),
    waist = EquipmentFactory.create("Orpheus's Sash"),
    left_ear = EquipmentFactory.create("Sortiarius Earring"),
    right_ear = EquipmentFactory.create("Chev. Earring +1"),
    left_ring = EquipmentFactory.create("Cornelia's Ring"),
    right_ring = EquipmentFactory.create("Regal Ring"),
    back = EquipmentFactory.create("Toro Cape")
})

-- =========================================================================================================
--                                           TPBonus Sets (Moonshade Earring)
-- =========================================================================================================

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = "Moonshade Earring" -- TP Bonus +250
}

-- TPBonus variants for weapon skills
sets.precast.WS['Savage Blade'].TPBonus = set_combine(sets.precast.WS['Savage Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Sanguine Blade'].TPBonus = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Aeolian Edge'].TPBonus = set_combine(sets.precast.WS['Aeolian Edge'], sets.precast.WS.TPBonus)
sets.precast.WS['Circle Blade'].TPBonus = set_combine(sets.precast.WS['Circle Blade'], sets.precast.WS.TPBonus)

-- =========================================================================================================
--                                           Equipments - Magic Defense Sets
-- =========================================================================================================
sets.defense.MDT = {
    sub = EquipmentFactory.create('Aegis'),
    ammo = "Staunch Tathlum +1",
    head = { name = "Sakpata's Helm", augments = { 'Path: A', } },
    body = { name = "Sakpata's Plate", augments = { 'Path: A', } },
    hands = { name = "Sakpata's Gauntlets", augments = { 'Path: A', } },
    legs = { name = "Sakpata's Cuisses", augments = { 'Path: A', } },
    feet = { name = "Sakpata's Leggings", augments = { 'Path: A', } },
    neck = "Moonlight Necklace",
    waist = "Carrier's Sash",
    left_ear = "Tuisto Earring",
    right_ear = "Eabani Earring",
    left_ring = "Purity Ring",
    right_ring = { name = "Gelatinous Ring +1", augments = { 'Path: A', } },
    back = { name = "Rudianos's Mantle", augments = { 'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%', } },
}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = set_combine(sets.idleNormal, {
    ammo = EquipmentFactory.create('Aurgelmir Orb +1', 2),       -- Pas de bonus HP
    head = EquipmentFactory.create("Sakpata's helm", 0),         -- HP+114
    body = EquipmentFactory.create("Sakpata's breastplate", 13), -- HP+228
    hands = EquipmentFactory.create("Sakpata's Gauntlets", 11),  -- HP+91
    legs = EquipmentFactory.create('Chev. Cuisses +3', 11),      -- HP+127
    feet = EquipmentFactory.create("Flamma Gambieras +2", 0),    -- HP+68
    neck = EquipmentFactory.create('Lissome necklace', 12),      -- Pas de bonus HP
    waist = EquipmentFactory.create('Sailfi Belt +1', 6),        -- Pas de bonus HP
    left_ear = EquipmentFactory.create('Cessance Earring', 0),   -- Pas de bonus HP
    right_ear = EquipmentFactory.create('Dedition Earring', 4),  -- Pas de bonus HP
    left_ring = MoonLightRing1,
    right_ring = MoonLightRing2,
    back = EquipmentFactory.create("Moonlight cape", 12)
})

sets.engaged.AFM3 = set_combine(sets.idleNormal, {
    ammo = EquipmentFactory.create('Aurgelmir Orb +1', 2),           -- Pas de bonus HP
    head = EquipmentFactory.create("Chevalier's Armet +3", 0),       -- HP+114
    body = EquipmentFactory.create('Flamma korazin +2', 13),         -- HP+228
    hands = EquipmentFactory.create("Chevalier's Gauntlets +3", 11), -- HP+91
    legs = EquipmentFactory.create('Chev. Cuisses +3', 11),          -- HP+127
    feet = EquipmentFactory.create("Flamma Gambieras +2", 0),        -- HP+68
    neck = EquipmentFactory.create('Null Loop', 12),                 -- Pas de bonus HP
    waist = EquipmentFactory.create('Kentarch Belt +1', 6),          -- Pas de bonus HP
    left_ear = EquipmentFactory.create('Telos Earring', 0),          -- Pas de bonus HP
    right_ear = EquipmentFactory.create('Dominance Earring +1', 4),  -- Pas de bonus HP
    left_ring = Moonlight1,
    right_ring = ChirichRing2,
    back = EquipmentFactory.create("Moonlight cape", 12)
})

sets.engaged.PDT = sets.engaged

sets.engaged.MDT = sets.idle.MDT

sets.meleeXp = set_combine(sets.idleXp, {
    main = EquipmentFactory.create('Malevolence', nil, nil,
        { 'INT+10', 'Mag. Acc.+10', '"Mag.Atk.Bns."+8', '"Fast Cast"+5' }),
})


-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
-- Movement set with more common base equipment
sets.MoveSpeed = {
    legs = "Carmine Cuisses +1", -- Common item for speed
}

-- Special set for Adoulin with body for additional speed
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb" -- Speed bonus in Adoulin city
})

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = EquipmentFactory.create("Nicander's Necklace"), -- Reduces Doom effects
    left_ring = EquipmentFactory.create("Purity Ring"),    -- Additional Doom resistance
    waist = EquipmentFactory.create("Gishdubar Sash"),     -- Enhances Doom recovery effects
}

-- Simple job loading notification
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("PLD")
