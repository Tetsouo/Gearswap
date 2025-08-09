---============================================================================
--- FFXI GearSwap Equipment Sets Template - JOB_NAME Comprehensive Gear Collection
---============================================================================
--- Professional JOB_NAME equipment set definitions template providing optimized
--- gear configurations for all aspects of gameplay.
---
--- @file templates/TEMPLATE_SET.lua
--- @author YOUR_NAME
--- @version 1.0
--- @date Created: DATE
--- @date Modified: DATE
---============================================================================

---============================================================================
--- UNIQUE EQUIPMENT DEFINITIONS
---============================================================================
--- Define equipment pieces that need special handling (multiple copies,
--- specific bags, augments, etc.). Use clear, descriptive variable names.

-- Example unique equipment definitions
UNIQUE_ITEM1 = createEquipment('Item Name', nil, 'inventory')
UNIQUE_ITEM2 = createEquipment('Item Name', nil, 'inventory', { 'Augment1', 'Augment2' })

-- Multiple copies of same item (rings, etc.)
RING1_VAR = createEquipment('Ring Name', nil, 'wardrobe 6')
RING2_VAR = createEquipment('Ring Name', nil, 'wardrobe 7')

---============================================================================
--- IDLE AND DEFENSIVE SETS
---============================================================================
--- Equipment sets for non-combat situations focusing on survivability,
--- movement speed, refresh, and general utility.

sets.idle = {
    main = createEquipment('Main Weapon'),
    sub = createEquipment('Sub Weapon'),
    ammo = createEquipment('Ammo'),
    head = createEquipment('Head Piece'),
    body = createEquipment('Body Piece'),
    hands = createEquipment('Hands Piece'),
    legs = createEquipment('Legs Piece'),
    feet = createEquipment('Feet Piece'),
    neck = createEquipment('Neck Piece'),
    waist = createEquipment('Waist Piece'),
    left_ear = createEquipment('Left Ear'),
    right_ear = createEquipment('Right Ear'),
    left_ring = createEquipment('Left Ring'),
    right_ring = createEquipment('Right Ring'),
    back = createEquipment('Back Piece'),
}

-- Idle variations
sets.idle.PDT = set_combine(sets.idle, {
    -- Physical Damage Taken reduction pieces
    head = createEquipment('PDT Head'),
    body = createEquipment('PDT Body'),
})

sets.idle.MDT = set_combine(sets.idle, {
    -- Magic Damage Taken reduction pieces
    head = createEquipment('MDT Head'),
    body = createEquipment('MDT Body'),
})

sets.idle.Town = set_combine(sets.idle, {
    -- Town-specific gear (movement speed, style, etc.)
    feet = createEquipment('Movement Feet'),
})

---============================================================================
--- ENGAGED SETS
---============================================================================
--- Equipment sets for melee combat situations with focus on accuracy,
--- attack, double attack, and other melee-enhancing stats.

sets.engaged = {
    main = createEquipment('Melee Main'),
    sub = createEquipment('Melee Sub'),
    ammo = createEquipment('Melee Ammo'),
    head = createEquipment('Melee Head'),
    body = createEquipment('Melee Body'),
    hands = createEquipment('Melee Hands'),
    legs = createEquipment('Melee Legs'),
    feet = createEquipment('Melee Feet'),
    neck = createEquipment('Melee Neck'),
    waist = createEquipment('Melee Waist'),
    left_ear = createEquipment('Melee Left Ear'),
    right_ear = createEquipment('Melee Right Ear'),
    left_ring = createEquipment('Melee Left Ring'),
    right_ring = createEquipment('Melee Right Ring'),
    back = createEquipment('Melee Back'),
}

-- Engaged variations
sets.engaged.Acc = set_combine(sets.engaged, {
    -- High accuracy pieces for difficult targets
    head = createEquipment('Acc Head'),
    hands = createEquipment('Acc Hands'),
})

sets.engaged.PDT = set_combine(sets.engaged, {
    -- Defensive melee with PDT
    head = createEquipment('Melee PDT Head'),
    body = createEquipment('Melee PDT Body'),
})

---============================================================================
--- PRECAST SETS
---============================================================================
--- Equipment sets used during spell/ability casting preparation phase.

-- Job Abilities
sets.precast.JA = {}

sets.precast.JA['Job Ability 1'] = {
    head = createEquipment('JA1 Head'),
    body = createEquipment('JA1 Body'),
}

-- Fast Cast sets for spell casting
sets.precast.FC = {
    main = createEquipment('FC Main'),
    head = createEquipment('FC Head'),
    body = createEquipment('FC Body'),
    hands = createEquipment('FC Hands'),
    legs = createEquipment('FC Legs'),
    feet = createEquipment('FC Feet'),
    neck = createEquipment('FC Neck'),
    left_ear = createEquipment('FC Left Ear'),
    right_ear = createEquipment('FC Right Ear'),
    left_ring = createEquipment('FC Left Ring'),
    right_ring = createEquipment('FC Right Ring'),
    back = createEquipment('FC Back'),
}

-- Weapon Skills
sets.precast.WS = {
    main = createEquipment('WS Main'),
    sub = createEquipment('WS Sub'),
    ammo = createEquipment('WS Ammo'),
    head = createEquipment('WS Head'),
    body = createEquipment('WS Body'),
    hands = createEquipment('WS Hands'),
    legs = createEquipment('WS Legs'),
    feet = createEquipment('WS Feet'),
    neck = createEquipment('WS Neck'),
    waist = createEquipment('WS Waist'),
    left_ear = createEquipment('WS Left Ear'),
    right_ear = createEquipment('WS Right Ear'),
    left_ring = createEquipment('WS Left Ring'),
    right_ring = createEquipment('WS Right Ring'),
    back = createEquipment('WS Back'),
}

---============================================================================
--- MIDCAST SETS
---============================================================================
--- Equipment sets used during spell casting execution phase.

sets.midcast = {}

-- Fast Cast for interrupted spells
sets.midcast.FastRecast = sets.precast.FC

-- Magic types
sets.midcast['Healing Magic'] = {
    main = createEquipment('Healing Main'),
    head = createEquipment('Healing Head'),
    body = createEquipment('Healing Body'),
}

---============================================================================
--- JOB-SPECIFIC SPECIALIZED SETS
---============================================================================
--- Sets specific to job mechanics and special situations.

-- Job specific feature sets
sets.FEATURE1_SET_NAME = {
    main = createEquipment('Feature1 Main'),
    head = createEquipment('Feature1 Head'),
    body = createEquipment('Feature1 Body'),
}

---============================================================================
--- MOVEMENT SPEED INTEGRATION
---============================================================================
--- Sets for automatic movement speed optimization.

sets.MoveSpeed = {
    feet = createEquipment('Movement Feet'),
    legs = createEquipment('Movement Legs'),
}
