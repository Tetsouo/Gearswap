---============================================================================
--- FFXI GearSwap Equipment Sets - Black Mage Comprehensive Gear Collection
---============================================================================
--- Professional Black Mage equipment set definitions providing optimized
--- gear configurations for all magical disciplines, burst magic coordination,
--- elemental affinity management, and advanced nuking strategies. Features:
---
--- • **Elemental Magic Mastery** - T1-T6 nuking sets with element-specific optimization
--- • **Magic Burst Coordination** - Specialized burst sets for skillchain timing
--- • **Fast Cast Infrastructure** - Minimized casting delays for spell efficiency
--- • **MP Conservation Systems** - Refresh, Convert, and mana management sets
--- • **Enfeebling Magic Support** - Accuracy and potency sets for debuffing
--- • **Death/Manawall Emergency** - Crisis management and recovery equipment
--- • **Defensive Configurations** - PDT/MDT sets for dangerous encounters
--- • **Movement Speed Integration** - Seamless mobility during combat
---
--- This comprehensive equipment database enables BLM to excel in all magical
--- roles while maintaining optimal performance across diverse encounter types
--- with intelligent gear selection algorithms.
---
--- @file jobs/blm/BLM_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by BLM_FUNCTION.lua for dynamic set selection
---
--- @see jobs/blm/BLM_FUNCTION.lua for casting logic and set management
--- @see Tetsouo_BLM.lua for job configuration and spell coordination
---============================================================================

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

StikiRing1 = EquipmentFactory.create('Stikini Ring +1', nil, 'wardrobe 6')
StikiRing2 = EquipmentFactory.create('Stikini Ring +1', nil, 'wardrobe 7')

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {
    main = EquipmentFactory.create("Mpaca's Staff"),
    sub = EquipmentFactory.create('Enki Strap'),
    ammo = EquipmentFactory.create('Staunch Tathlum +1'),
    head = EquipmentFactory.create('Wicce Petasos +3'),
    body = EquipmentFactory.create('Wicce Coat +3'),
    hands = EquipmentFactory.create('Volte Gloves'),
    legs = EquipmentFactory.create('Nyame Flanchard'),
    feet = EquipmentFactory.create('Wicce Sabots +3'),
    neck = EquipmentFactory.create('Loricate torque +1'),
    waist = EquipmentFactory.create('Fucho-no-obi'),
    left_ear = EquipmentFactory.create('Ethereal Earring'),
    right_ear = EquipmentFactory.create('Odnowa earring +1'),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = EquipmentFactory.create("Solemnity Cape"),
}
sets.idle.PDT = set_combine(sets.idle, {})
sets.idle.Town = set_combine(sets.idle, {})
sets.defense.PDT = {}
sets.defense.MDT = {}
sets.resting = set_combine(sets.idle, {})

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = {
    main = EquipmentFactory.create("Malignance Pole"),
    sub = EquipmentFactory.create("Enki Strap"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Wicce Petasos +3"),
    body = EquipmentFactory.create("Wicce Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Sanctity Necklace"),
    waist = EquipmentFactory.create("Windbuffet Belt +1"),
    left_ear = EquipmentFactory.create("Crep. Earring"),
    right_ear = EquipmentFactory.create("Telos Earring"),
    left_ring = EquipmentFactory.create("Chirich Ring +1"),
    right_ring = EquipmentFactory.create("Chirich Ring +1"),
    back = EquipmentFactory.create("Taranus's Cape"),
}
sets.engaged.PDT = {
    main = EquipmentFactory.create("Malignance Pole"),
    sub = EquipmentFactory.create("Enki Strap"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Wicce Petasos +3"),
    body = EquipmentFactory.create("Wicce Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Sanctity Necklace"),
    waist = EquipmentFactory.create("Windbuffet Belt +1"),
    left_ear = EquipmentFactory.create("Crep. Earring"),
    right_ear = EquipmentFactory.create("Telos Earring"),
    left_ring = EquipmentFactory.create("Chirich Ring +1"),
    right_ring = EquipmentFactory.create("Chirich Ring +1"),
    back = EquipmentFactory.create("Taranus's cape"),
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA['Mana Wall'] = {
    feet = EquipmentFactory.create('Wicce Sabots +3'),
    back = EquipmentFactory.create("Taranus's Cape")
}
sets.precast.JA.Manafont = { body = EquipmentFactory.create("Archmage's Coat") }

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {
    main = "Grioavolr",                                                                                                  -- 06 FC
    sub = "Enki Strap",                                                                                                  -- 00 FC
    ammo = "Impatiens",                                                                                                  -- 02 QM
    head = { name = "Merlinic Hood", augments = { 'Attack+14', '"Fast Cast"+7', 'MND+3', } },                            -- 15 FC
    body = { name = "Merlinic Jubbah", augments = { 'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3', } },   -- 13 FC
    hands = { name = "Merlinic Dastanas", augments = { '"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4', } },          -- 07 FC
    legs = { name = "Merlinic Shalwar", augments = { '"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11', } },           -- 05 FC
    feet = { name = "Merlinic Crackows", augments = { '"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10', } }, -- 12 FC
    neck = "Orunmila's Torque",                                                                                          -- 05 FC
    waist = "Witful Belt",                                                                                               -- 03 FC
    left_ear = "Malignance Earring",                                                                                     -- 04 FC
    right_ear = "Loquac. Earring",                                                                                       -- 02 FC
    left_ring = "Kishar Ring",                                                                                           -- 04 FC
    right_ring = "Lebeche Ring",                                                                                         -- 02 QM
    back = "Perimede Cape",                                                                                              -- 04 QM
}
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Elemental Magic'] = sets.precast.FC
sets.precast.FC.Death = set_combine(sets.precast.FC, {})
sets.precast.FC.Cure = sets.precast.FC
sets.precast.FC.Curaga = sets.precast.FC.Cure
sets.precast.FC.Impact = set_combine(sets.precast.FC, {
    head = empty,
    body = EquipmentFactory.create('Twilight Cloak')
})

sets.precast.FC.Death.MagicBurst = sets.precast.FC.Death
sets.precast.FC.Stoneskin = set_combine(sets.precast.FC, {
    head = EquipmentFactory.create('Umuthi Hat'),
    legs = EquipmentFactory.create('Doyen Pants'),
    waist = EquipmentFactory.create('Siegel Sash')
})

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================
sets.midcast.FastRecast = sets.precast.FC

-- ================================================ Cure Sets ==============================================
sets.midcast.Cure = {
    main = EquipmentFactory.create('Daybreak'),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    ammo = EquipmentFactory.create('Staunch Tathlum +1'),
    head = EquipmentFactory.create('Wicce Petasos +3'),
    body = EquipmentFactory.create('Nyame Mail'),
    hands = EquipmentFactory.create('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = EquipmentFactory.create('Wicce Chausses +3'),
    feet = EquipmentFactory.create('Wicce Sabots +3'),
    neck = EquipmentFactory.create('Nodens Gorget'),
    waist = EquipmentFactory.create('Plat. Mog. Belt'),
    left_ear = EquipmentFactory.create("Handler's Earring"),
    right_ear = EquipmentFactory.create('Wicce Earring +1', nil, nil,
        { 'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4' }),
    left_ring = EquipmentFactory.create('Defending Ring'),
    right_ring = StikiRing2,
    back = EquipmentFactory.create('Solemnity Cape'),
}

sets.self_healing = set_combine(sets.midcast.Cure, {})
sets.midcast.Curaga = sets.midcast.Cure

-- ================================================ Enhancing Sets ========================================
sets.midcast['Enhancing Magic'] = {
    main = EquipmentFactory.create('Daybreak'),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    ammo = EquipmentFactory.create('Impatiens'),
    head = EquipmentFactory.create('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = EquipmentFactory.create('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = EquipmentFactory.create('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = EquipmentFactory.create('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = EquipmentFactory.create('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = EquipmentFactory.create('Loricate Torque +1'),
    waist = EquipmentFactory.create('Olympus Sash'),
    left_ear = EquipmentFactory.create('Andoaa Earring'),
    right_ear = EquipmentFactory.create('Regal Earring'),
    left_ring = StikiRing1,
    right_ring = EquipmentFactory.create('Evanescence ring'),
    back = EquipmentFactory.create('Fi Follet Cape +1')
}
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
    ammo = EquipmentFactory.create("Impatiens"),
    head = EquipmentFactory.create('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = EquipmentFactory.create('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = EquipmentFactory.create('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = EquipmentFactory.create('Shedir seraweels'),
    feet = EquipmentFactory.create('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = EquipmentFactory.create("Nodens Gorget"),
    waist = EquipmentFactory.create("Siegel Sash"),
    left_ear = EquipmentFactory.create("Ethereal Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = EquipmentFactory.create("Fi Follet Cape +1"),
})

sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Aquaveil = {
    main = EquipmentFactory.create('Daybreak'),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    ammo = EquipmentFactory.create("Impatiens"),
    head = EquipmentFactory.create("Amalric Coif +1"),
    body = EquipmentFactory.create("Telchine Chas.", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = EquipmentFactory.create("Telchine Gloves", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = EquipmentFactory.create('Shedir seraweels'),
    feet = EquipmentFactory.create("Telchine Pigaches", nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = EquipmentFactory.create("Loricate Torque +1"),
    waist = EquipmentFactory.create("Olympus Sash"),
    left_ear = EquipmentFactory.create("Andoaa Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = EquipmentFactory.create("Evanescence Ring"),
    back = EquipmentFactory.create("Fi Follet Cape +1"),
}
sets.midcast.Refresh = set_combine(sets.midcast.Aquaveil,
    {
        main = EquipmentFactory.create('Daybreak'),
        sub = EquipmentFactory.create('Ammurapi Shield'),
        ammo = EquipmentFactory.create('Impatiens'),
        head = EquipmentFactory.create('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        body = EquipmentFactory.create('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        hands = EquipmentFactory.create('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        legs = EquipmentFactory.create('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        feet = EquipmentFactory.create('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
        neck = EquipmentFactory.create('Loricate Torque +1'),
        waist = EquipmentFactory.create('Olympus Sash'),
        left_ear = EquipmentFactory.create('Andoaa Earring'),
        right_ear = EquipmentFactory.create('Regal Earring'),
        right_ring = EquipmentFactory.create('Evanescence Ring'),
        left_ring = StikiRing1,
        back = EquipmentFactory.create('Fi Follet Cape +1')
    })

sets.midcast.Haste = {
    main = EquipmentFactory.create('Daybreak'),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    ammo = EquipmentFactory.create('Impatiens'),
    head = EquipmentFactory.create('Telchine Cap', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    body = EquipmentFactory.create('Telchine Chas.', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    hands = EquipmentFactory.create('Telchine Gloves', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    legs = EquipmentFactory.create('Telchine Braconi', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    feet = EquipmentFactory.create('Telchine Pigaches', nil, nil, { 'Enh. Mag. eff. dur. +10' }),
    neck = EquipmentFactory.create('Loricate Torque +1'),
    waist = EquipmentFactory.create('Olympus Sash'),
    left_ear = EquipmentFactory.create('Andoaa Earring'),
    right_ear = EquipmentFactory.create('Regal Earring'),
    right_ring = EquipmentFactory.create('Evanescence Ring'),
    left_ring = StikiRing1,
    back = EquipmentFactory.create('Fi Follet Cape +1'),
}

-- ================================================ Debuffs Sets ========================================
sets.midcast.MndEnfeebles = {
    main = EquipmentFactory.create('Daybreak'),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    head = EquipmentFactory.create('Wicce Petasos +3'),
    neck = EquipmentFactory.create("Src. Stole +2"),
    ear1 = EquipmentFactory.create('Malignance Earring'),
    ear2 = EquipmentFactory.create('Regal Earring'),
    body = EquipmentFactory.create("Wicce Coat +3"),
    hands = EquipmentFactory.create('Wicce Gloves +3'),
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = EquipmentFactory.create("Aurist's Cape +1"),
    waist = EquipmentFactory.create('Sacro Cord'),
    legs = EquipmentFactory.create('Wicce Chausses +3'),
    feet = EquipmentFactory.create('Wicce Sabots +3')
}
sets.midcast.IntEnfeebles = {
    main = EquipmentFactory.create("Bunzi's Rod"),
    sub = EquipmentFactory.create("Ammurapi Shield"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Wicce Petasos +3"),
    body = EquipmentFactory.create("Wicce Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Src. Stole +2"),
    waist = EquipmentFactory.create("Acuity Belt +1"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Wicce Earring +1"),
    left_ring = EquipmentFactory.create("Metamor. Ring +1"),
    right_ring = StikiRing2,
    back = EquipmentFactory.create("Taranus's cape")
}
sets.midcast.Breakga = sets.midcast.IntEnfeebles
sets.midcast.Break = sets.midcast.Breakga
sets.midcast.Sleep = sets.midcast.IntEnfeebles
sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep
sets.midcast.Blind = sets.midcast.IntEnfeebles

sets.midcast['Dark Magic'] = {
    main = EquipmentFactory.create("Rubicundity", nil, nil, { 'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7' }),
    sub = EquipmentFactory.create("Ammurapi Shield"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Merlinic Hood", nil, nil,
        { 'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2' }),
    body = EquipmentFactory.create("Merlinic Jubbah", nil, nil,
        { '"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4' }),
    hands = EquipmentFactory.create("Merlinic Dastanas", nil, nil,
        { '"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14' }),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Agwu's Pigaches"),
    neck = EquipmentFactory.create("Erra Pendant"),
    waist = EquipmentFactory.create("Fucho-no-Obi"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Wicce Earring +1"),
    left_ring = EquipmentFactory.create("Metamor. Ring +1"),
    right_ring = EquipmentFactory.create("Evanescence Ring"),
    back = EquipmentFactory.create("Taranus's cape")
}
sets.midcast.Drain = sets.midcast['Dark Magic']
sets.midcast.Aspir = sets.midcast['Dark Magic']
sets.midcast.Raise = {}

-- ================================================ Elemental Sets ========================================
sets.midcast['Elemental Magic'] = {
    main = EquipmentFactory.create("Bunzi's Rod"),
    sub = EquipmentFactory.create("Ammurapi Shield"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Wicce Petasos +3"),
    body = EquipmentFactory.create("Spaekona's Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Src. Stole +2"),
    waist = EquipmentFactory.create("Acuity Belt +1"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = EquipmentFactory.create("Freke Ring"),
    right_ring = EquipmentFactory.create("Metamor. Ring +1"),
    back = EquipmentFactory.create("Taranus's cape")
}
sets.midcast['Elemental Magic'].MagicBurst = {
    main = EquipmentFactory.create("Bunzi's rod"),
    sub = EquipmentFactory.create('Ammurapi Shield'),
    ammo = EquipmentFactory.create('Ghastly tathlum +1'),
    head = EquipmentFactory.create("Ea Hat +1"),
    body = EquipmentFactory.create("Wicce Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Src. Stole +2"),
    waist = EquipmentFactory.create("Hachirin-no-obi"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = EquipmentFactory.create("Mujin Band"),
    right_ring = EquipmentFactory.create("Metamor. Ring +1"),
    back = EquipmentFactory.create("Taranus's Cape"),
}
sets.midcast['Impact'] = {
    main = EquipmentFactory.create("Bunzi's Rod"),
    sub = EquipmentFactory.create("Ammurapi Shield"),
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = empty,
    body = EquipmentFactory.create("Twilight Cloak"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Wicce Chausses +3"),
    feet = EquipmentFactory.create("Wicce Sabots +3"),
    neck = EquipmentFactory.create("Src. Stole +2"),
    waist = EquipmentFactory.create("Acuity Belt +1"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = EquipmentFactory.create("Metamor. Ring +1"),
    back = EquipmentFactory.create("Taranus's Cape", nil, nil,
        { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Spell interruption rate down-10%' }),
}
sets.midcast['Impact'].MagicBurst = sets.midcast['Impact']
sets.midcast['Meteor'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst
sets.midcast['Death'] = sets.midcast['Elemental Magic']
sets.midcast['Death'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- ================================================ Dot Sets ========================================
sets.midcast['Burn'] = {
    ammo = EquipmentFactory.create("Ghastly Tathlum +1"),
    head = EquipmentFactory.create("Wicce Petasos +3"),
    body = EquipmentFactory.create("Spaekona's Coat +3"),
    hands = EquipmentFactory.create("Wicce Gloves +3"),
    legs = EquipmentFactory.create("Arch. Tonban +3", nil, nil, { 'Increases Elemental Magic debuff time and potency' }),
    feet = EquipmentFactory.create("Arch. Sabots +3", nil, nil, { 'Increases Aspir absorption amount' }),
    neck = EquipmentFactory.create("Src. Stole +2"),
    waist = EquipmentFactory.create("Acuity Belt +1"),
    left_ear = EquipmentFactory.create("Malignance Earring"),
    right_ear = EquipmentFactory.create("Regal Earring"),
    left_ring = StikiRing1,
    right_ring = EquipmentFactory.create("Metamor. Ring +1"),
    back = EquipmentFactory.create("Taranus's Cape", nil, nil,
        { 'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'INT+10', '"Mag.Atk.Bns."+10', 'Spell interruption rate down-10%' }),
}
sets.midcast['Rasp'] = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = EquipmentFactory.create("Oshasha's Treatise"),
    head = EquipmentFactory.create('Nyame Helm'),
    body = EquipmentFactory.create('Nyame Mail'),
    hands = EquipmentFactory.create('Nyame Gauntlets'),
    legs = EquipmentFactory.create('Nyame Flanchard'),
    feet = EquipmentFactory.create('Nyame Sollerets'),
    neck = EquipmentFactory.create('Fotia Gorget'),
    waist = EquipmentFactory.create('Fotia Belt'),
    left_ear = EquipmentFactory.create('Moonshade Earring'),
    right_ear = EquipmentFactory.create('Mache Earring +1'),
    left_ring = EquipmentFactory.create("Cornelia's Ring"),
    right_ring = EquipmentFactory.create('Chirich Ring +1'),
    back = EquipmentFactory.create("Taranus's Cape"),
}

sets.test = {
    main = "Bunzi's Rod",
    sub = "Ammurapi Shield",
    ammo = { name = "Ghastly Tathlum +1", augments = { 'Path: A', } },
    head = "Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands = "Wicce Gloves +3",
    legs = "Wicce Chausses +3",
    feet = "Wicce Sabots +3",
    neck = { name = "Src. Stole +2", augments = { 'Path: A', } },
    waist = { name = "Acuity Belt +1", augments = { 'Path: A', } },
    left_ear = "Malignance Earring",
    right_ear = "Regal Earring",
    left_ring = "Freke Ring",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = "Taranus's cape"
}

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = { feet = EquipmentFactory.create("Herald's Gaiters") }
sets.Adoulin = set_combine(sets.MoveSpeed, { body = EquipmentFactory.create("Councilor's Garb") })

-- =========================================================================================================
--                                           Dynamic MP Conservation Sets
-- =========================================================================================================

-- Base set for MP conservation calculations
local baseSetForMP = {
    main = "Bunzi's Rod",
    sub = "Ammurapi Shield",
    ammo = { name = "Ghastly Tathlum +1", augments = { 'Path: A', } },
    head = "Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands = "Wicce Gloves +3",
    legs = "Wicce Chausses +3",
    feet = "Wicce Sabots +3",
    neck = { name = "Src. Stole +2", augments = { 'Path: A', } },
    waist = { name = "Acuity Belt +1", augments = { 'Path: A', } },
    left_ear = "Malignance Earring",
    right_ear = "Regal Earring",
    left_ring = "Freke Ring",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = "Taranus's cape"
}

-- Function to merge two tables (for set combination)
local function mergeTables(t1, t2)
    if type(t1) ~= "table" then
        error("t1 must be a table")
    end
    if type(t2) ~= "table" then
        error("t2 must be a table")
    end

    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Equipment sets for MP conservation - Normal casting mode
local normalSetLowMP = mergeTables(baseSetForMP, {
    body = "Spaekona's Coat +3",
    waist = "Orpheus's Sash"
})

local normalSetHighMP = mergeTables(baseSetForMP, {
    body = 'Wicce Coat +3',
    waist = "Orpheus's Sash"
})

-- Equipment sets for MP conservation - Magic Burst mode
local magicBurstSetLowMP = mergeTables(baseSetForMP, {
    body = "Spaekona's Coat +3",
    head = "Ea Hat +1",
    hands = "Agwu's Gages",
    left_ring = "Mujin Band",
    ammo = 'Ghastly tathlum +1',
    feet = "Wicce Sabots +3",
    waist = 'Hachirin-no-obi'
})

local magicBurstSetHighMP = mergeTables(baseSetForMP, {
    body = 'Wicce Coat +3',
    head = "Ea Hat +1",
    hands = "Agwu's Gages",
    left_ring = "Mujin Band",
    ammo = 'Ghastly tathlum +1',
    feet = "Wicce Sabots +3",
    waist = 'Hachirin-no-obi'
})

-- Sets exposed for use by BLM_FUNCTION.lua
blm_dynamic_sets = {
    normalSetLowMP = normalSetLowMP,
    normalSetHighMP = normalSetHighMP,
    magicBurstSetLowMP = magicBurstSetLowMP,
    magicBurstSetHighMP = magicBurstSetHighMP
}

-- =========================================================================================================
--                                           ManaWall Sets
-- =========================================================================================================
sets.buff['Mana Wall'] = {
    feet = EquipmentFactory.create('Wicce Sabots +3'),
    back = EquipmentFactory.create("Taranus's Cape"),
}

-- Simple job loading notification
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("BLM")
