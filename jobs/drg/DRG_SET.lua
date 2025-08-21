---============================================================================
--- FFXI GearSwap Equipment Sets - Dragoon Comprehensive Gear Collection
---============================================================================
--- Professional Dragoon equipment set definitions providing optimized
--- gear configurations for jump coordination, wyvern management, TP building,
--- and advanced dragoon combat strategies. Features:
---
--- • **Jump Optimization Systems** - Soul Jump, Spirit Jump, and Jump sets
--- • **Wyvern Support Equipment** - Pet coordination and Call Wyvern gear
--- • **TP Building Efficiency** - Rapid TP accumulation for weapon skills
--- • **Spirit Link Coordination** - Wyvern healing and buff transfer sets
--- • **Polearm Mastery Sets** - Specialized gear for polearm weapon skills
--- • **Defensive Jump Protection** - PDT sets for high-risk jump timing
--- • **Hybrid Combat Modes** - Balanced sets for dragoon versatility
--- • **Movement Speed Systems** - Mobility for optimal positioning
---
--- This comprehensive equipment database enables DRG to excel in both
--- solo combat and party coordination while maintaining peak performance
--- across diverse encounter types with intelligent jump and wyvern management.
---
--- @file jobs/drg/DRG_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-04-21 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment.lua for equipment creation utilities
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by DRG_FUNCTION.lua for jump and wyvern management
---
--- @see jobs/drg/DRG_FUNCTION.lua for dragoon logic and jump coordination
--- @see Tetsouo_DRG.lua for job configuration and dragoon mode management
---============================================================================

--=================================================================--
--                             IDLE SETS                           --
--=================================================================--

-- Load equipment factory
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

sets.idle = {
    main = "Trishula", -- Replace with your DRG weapon
    sub = "Utu Grip",
    head = "Meghanada Visor +2",
    body = "Meghanada Cuirie +2",
    hands = "Meghanada Gloves +2",
    legs = "Meghanada Chausses +2",
    feet = "Meghanada Jambeaux +2"
}
sets.idle.PDT = set_combine(sets.idle, {})
sets.idle.Town = set_combine(sets.idle, {})

--=================================================================--
--                            ENGAGED SETS                        --
--=================================================================--

sets.engaged = set_combine(sets.idle, {})
sets.engaged.Normal = sets.engaged
sets.engaged.PDT = set_combine(sets.engaged, {})
sets.engaged.PDTTP = set_combine(sets.engaged.PDT, {})

--=================================================================--
--                          WEAPON SETS                           --
--=================================================================--

sets['Trishula'] = { main = EquipmentFactory.create('Trishula'), sub = EquipmentFactory.create('Utu Grip') }
sets['Shining One'] = { main = EquipmentFactory.create('Shining One'), sub = EquipmentFactory.create('Utu Grip') }
sets['Ryunohige'] = { main = EquipmentFactory.create('Ryunohige'), sub = EquipmentFactory.create('Utu Grip') }
sets['Gungnir'] = { main = EquipmentFactory.create('Gungnir'), sub = EquipmentFactory.create('Utu Grip') }

sets['Utu Grip'] = { sub = EquipmentFactory.create('Utu Grip') }
sets['Hagneia Stone'] = { ammo = EquipmentFactory.create('Hagneia Stone') }

--=================================================================--
--                           MOVEMENT SET                         --
--=================================================================--

sets.MoveSpeed = set_combine(sets.idle, {
    feet = "Herald's Gaiters" -- Speed boots
})

--=================================================================--
--                          JOB ABILITIES                         --
--=================================================================--

sets.precast.JA = {}
sets.precast.JA['Jump'] = {}
sets.precast.JA['High Jump'] = {}
sets.precast.JA['Spirit Jump'] = {}
sets.precast.JA['Soul Jump'] = {}
sets.precast.JA['Spirit Link'] = {}
sets.precast.JA['Call Wyvern'] = {}
sets.precast.JA['Angon'] = {}
sets.precast.JA['Ancient Circle'] = {}
sets.precast.JA['Dragon Breaker'] = {}

--=================================================================--
--                          WEAPON SKILLS                         --
--=================================================================--

sets.precast.WS = {}

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    ear1 = "Moonshade Earring" -- TP Bonus +250
}
sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Impulse Drive'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Sonic Thrust'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Camlann\'s Torment'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Drakesbane'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Wheeling Thrust'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Skewer'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Vorpal Thrust'] = set_combine(sets.precast.WS, {})

-- TPBonus variants for weapon skills
sets.precast.WS['Stardiver'].TPBonus = set_combine(sets.precast.WS['Stardiver'], sets.precast.WS.TPBonus)
sets.precast.WS['Impulse Drive'].TPBonus = set_combine(sets.precast.WS['Impulse Drive'], sets.precast.WS.TPBonus)
sets.precast.WS['Sonic Thrust'].TPBonus = set_combine(sets.precast.WS['Sonic Thrust'], sets.precast.WS.TPBonus)
sets.precast.WS['Camlann\'s Torment'].TPBonus = set_combine(sets.precast.WS['Camlann\'s Torment'],
sets.precast.WS.TPBonus)
sets.precast.WS['Drakesbane'].TPBonus = set_combine(sets.precast.WS['Drakesbane'], sets.precast.WS.TPBonus)
sets.precast.WS['Wheeling Thrust'].TPBonus = set_combine(sets.precast.WS['Wheeling Thrust'], sets.precast.WS.TPBonus)
sets.precast.WS['Skewer'].TPBonus = set_combine(sets.precast.WS['Skewer'], sets.precast.WS.TPBonus)
sets.precast.WS['Vorpal Thrust'].TPBonus = set_combine(sets.precast.WS['Vorpal Thrust'], sets.precast.WS.TPBonus)

--=================================================================--
--                          BUFF SETS                             --
--=================================================================--

sets.buff = {}
sets.buff.Doom = {}
sets.buff['Empathy'] = {}
sets.buff['Fly High'] = {}

--=================================================================--
--                    OPTIONAL WYVERN SETS                       --
--=================================================================--

sets.HealingBreath = {}
sets.WyvernMelee = {}

-- Simple job loading notification
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("DRG")
