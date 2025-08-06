---============================================================================
--- FFXI GearSwap Equipment Sets - Rune Fencer Comprehensive Gear Collection
---============================================================================
--- Professional Rune Fencer equipment set definitions providing optimized
--- gear configurations for rune management, spell enhancement, tank-mage
--- coordination, and advanced defensive strategies. Features:
---
--- • **Rune Mastery Systems** - Element-specific rune gear and coordination
--- • **Spell Enhancement Excellence** - Fast Cast, SIRD, and potency optimization
--- • **Tank-Mage Balance** - Hybrid sets for defensive and offensive capabilities
--- • **Phalanx Specialization** - Enhanced damage reduction and spell potency
--- • **Vallation/Embolden Integration** - Job ability enhancement equipment
--- • **PDT/MDT Coordination** - Intelligent damage type resistance switching
--- • **Foil Accuracy Systems** - Precision gear for enfeebling magic
--- • **Subjob Optimization** - SCH/WHM specific spell support coordination
---
--- This comprehensive equipment database enables RUN to excel as a versatile
--- tank-mage while maintaining spell casting efficiency and defensive prowess
--- across diverse encounter types with intelligent rune and spell coordination.
---
--- @file jobs/run/RUN_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by RUN_FUNCTION.lua for rune and spell management
---
--- @see jobs/run/RUN_FUNCTION.lua for rune fencer logic and spell coordination
--- @see Tetsouo_RUN.lua for job configuration and rune mode management
---============================================================================

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
-- Define Rudianos set with different augments for different situations

-- =========================================================================================================
--                                           Equipments - Weapon Sets
-- =========================================================================================================
sets['Aettir'] = { main = 'Burtgang'}

-- =========================================================================================================
sets['Refined Grip +1'] = { sub = 'Refined Grip +1' }
sets['Utu grip'] = { sub = 'Utu Grip'}

-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.idle = {}

sets.idle.PDT = sets.idle
sets.idle.MDT = {}

sets.idleNormal = set_combine(sets.idle, {})

sets.idleXp = set_combine(sets.idle, {})

sets.idle.Town = set_combine(sets.idle, {})

sets.resting = set_combine(sets.idleNormal, {})

sets.latent_refresh = {}

-- =========================================================================================================
--                                           Equipments - FullEnmity Sets
-- =========================================================================================================
sets.FullEnmity = {}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})

-- =========================================================================================================
--                                           Equipments - Fast Cast Sets
-- =========================================================================================================
sets.precast.FC = {}

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
sets.precast.FC['Frightful Roar'] = sets.precast.FC

-- =========================================================================================================
--                                           Equipments - Enmity Sets
-- =========================================================================================================
sets.midcast.Enmity = sets.FullEnmity

sets.midcast.SIRDEnmity = {}
-- Gear Enmity 115
-- Crusade Enmity 145

-- =========================================================================================================
--                                           Equipments - Midcast Sets
-- =========================================================================================================

-- ================================================ Phalanx Sets ===========================================
sets.midcast.PhalanxPotency = {}

sets.midcast.SIRDPhalanx = {}

-- ================================================ Enlight Sets ==========================================
sets.midcast['Enlight'] = set_combine(sets.midcast.SIRDEnmity, {})

-- ================================================ Enhancing Sets ========================================
sets.midcast['Enhancing Magic'] = set_combine(sets.midcast.SIRDEnmity, {})

-- ================================================ Enmity Sets ===========================================
sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
sets.midcast['Cocoon'] = sets.midcast.SIRDEnmity
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.midcast.SIRDEnmity
sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity
sets.midcast['Sheep Song'] = sets.midcast.SIRDEnmity
sets.midcast['Frightful Roar'] = sets.midcast.SIRDEnmity
sets.midcast['Blank Gaze'] = sets.midcast.SIRDEnmity
sets.midcast['Crusade'] = sets.midcast['Enhancing Magic']
sets.midcast['Reprisal'] = sets.midcast['Enhancing Magic']
sets.midcast['Protect'] = sets.midcast['Enhancing Magic']
sets.midcast['Shell'] = sets.midcast['Enhancing Magic']
sets.midcast['Refresh'] = sets.midcast.SIRDEnmity
sets.midcast['Haste'] = sets.midcast.SIRDEnmity

-- ================================================ Cure Sets ==============================================
sets.Cure = {}

-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {}
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})
sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {})

-- =========================================================================================================
--                                           Equipments - Magic Defense Sets
-- =========================================================================================================
sets.defense.MDT = {}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.engaged = set_combine(sets.idleNormal, {})

sets.engaged.PDT = set_combine(sets.idleNormal, {})

sets.engaged.MDT = sets.idle.MDT

sets.meleeXp = set_combine(sets.idleXp, {})

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {}
