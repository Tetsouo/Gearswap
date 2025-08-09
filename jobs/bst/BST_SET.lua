---============================================================================
--- FFXI GearSwap Equipment Sets - Beastmaster Comprehensive Gear Collection
---============================================================================
--- Professional Beastmaster equipment set definitions providing optimized
--- gear configurations for pet management, ecosystem specialization, ready
--- move coordination, and advanced pet-master synergy strategies. Features:
---
--- • **Pet Performance Optimization** - Ready move accuracy and damage sets
--- • **Ecosystem Specialization** - Aquan/Amorph/Beast/Bird/Lizard specific gear
--- • **Species-Adaptive Systems** - Pet type-specific equipment configurations
--- • **Call Beast Coordination** - Jug pet summoning and management sets
--- • **Master-Pet Balance** - Hybrid sets for simultaneous combat effectiveness
--- • **Ranged Attack Integration** - Crossbow and throwing weapon support
--- • **Defensive Pet Protection** - Pet survivability and damage mitigation
--- • **Movement Speed Systems** - Mobility for pet positioning and management
---
--- This comprehensive equipment database enables BST to excel in pet
--- coordination while maintaining versatility across all ecosystem types
--- with intelligent species-adaptive gear selection algorithms.
---
--- @file jobs/bst/BST_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires utils/equipment_factory for standardized equipment creation
---
--- @usage
---   All sets automatically loaded by Mote framework
---   Referenced by BST_FUNCTION.lua for ecosystem and species management
---
--- @see jobs/bst/BST_FUNCTION.lua for pet logic and ecosystem coordination
--- @see Tetsouo_BST.lua for job configuration and pet management modes
---============================================================================

---@diagnostic disable: lowercase-global

-- Load the centralized equipment factory for standardized equipment creation
require('utils/equipment_factory')

--============================================================--
--                    UTILITY FUNCTIONS                        --
--============================================================--

--============================================================--
--                  COMMON GEAR DEFINITIONS                    --
--============================================================--

-- Frequently used rings
local RINGS                          = {
    MoonLight1 = createEquipment("Moonlight Ring", nil, "wardrobe 2"),
    MoonLight2 = createEquipment("Moonlight Ring", nil, "wardrobe 3"),
    Chirich1 = createEquipment("Chirich Ring +1", nil, "wardrobe 1"),
    Chirich2 = createEquipment("Chirich Ring +1", nil, "wardrobe 2"),
    Stikini1 = createEquipment("Stikini Ring +1", nil, "wardrobe 6"),
    Stikini2 = createEquipment("Stikini Ring +1", nil, "wardrobe 7"),
    Varar2 = createEquipment("Varar Ring +1", nil, "wardrobe 7"),
    Defending = "Defending Ring",
    CPalug = "C. Palug Ring",
    Gere = "Gere Ring",
    Hetairoi = "Hetairoi Ring",
    Cornelia = "Cornelia's Ring",
    Metamorph = "Metamor. Ring +1",
    Purity = "Purity Ring",
    Tali = "Tali'ah Ring",
}

-- Aliases for backward compatibility
MoonLightRing1                       = RINGS.MoonLight1
MoonLightRing2                       = RINGS.MoonLight2
ChirichRing1                         = RINGS.Chirich1
ChirichRing2                         = RINGS.Chirich2
StikiniRing1                         = RINGS.Stikini1
StikiniRing2                         = RINGS.Stikini2
StikiRing1                           = RINGS.Stikini1 -- Legacy alias
VararRing2                           = RINGS.Varar2

-- Common earrings
local EARRINGS                       = {
    Odnowa = { name = "Odnowa Earring +1", augments = { 'Path: A' } },
    Nukumi = { name = "Nukumi Earring +1", augments = { 'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Pet: "Dbl. Atk."+6' } },
    Telos = "Telos Earring",
    Enmerkar = "Enmerkar Earring",
    Sroda = "Sroda Earring",
    Ferine = "Ferine Earring",
    Thrud = "Thrud Earring",
    Sortiarius = "Sortiarius Earring",
    Friomisi = "Friomisi Earring",
    Hija = "Hija Earring",
}

-- Common neck pieces
local NECK                           = {
    BstCollar = { name = "Bst. Collar +2", augments = { 'Path: A' } },
    EliteRoyal = "Elite Royal Collar",
    Adad = "Adad Amulet",
    Sibyl = "Sibyl Scarf",
    Nicander = "Nicander's Necklace"
}

-- Cape pieces (Artio's Mantle variations)
Artio                                = {
    STP = createEquipment("Artio's Mantle", nil, nil, {
        "DEX+20", "Accuracy+20 Attack+20", "Accuracy+10", '"Store TP"+10', "Damage taken-5%"
    }),
    WS1 = createEquipment("Artio's Mantle", nil, nil, {
        "STR+20", "Accuracy+20 Attack+20", "STR+10", "Weapon skill damage +10%", "Damage taken-5%"
    }),
    PETSTP = createEquipment("Artio's Mantle", nil, nil, {
        "Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20", "Accuracy+20 Attack+20",
        "Pet: Accuracy+10 Pet: Rng. Acc.+10", "Pet: Haste+10", "Pet: Damage taken -5%"
    }),
    PETMB = createEquipment("Artio's Mantle", nil, nil, {
        "Pet: M.Acc.+20 Pet: M.Dmg.+20", "Eva.+20 /Mag. Eva.+20",
        "Pet: Magic Damage+10", 'Pet: "Regen"+10', "Pet: Damage taken -5%"
    })
}

-- Alternative pet tanking mantle
Pastoralist                          = {
    petDT = createEquipment("Pastoralist's Mantle", nil, nil, {
        "STR+3 DEX+3", "Pet: Accuracy+18 Pet: Rng. Acc.+18", "Pet: Damage taken -4%"
    })
}

-- Additional reusable gear
JumalikHead                          = createEquipment("Jumalik Helm", nil, nil, {
    "MND+10", '"Mag.Atk.Bns."+15', "Magic burst dmg.+10%", '"Refresh"+1'
})

JumalikBody                          = createEquipment("Jumalik Mail", nil, nil, {
    "HP+50", "Attack+15", "Enmity+9", '"Refresh"+2'
})

-- Common augmented gear for pet multi-hit physical Ready moves
local PhysMultiGear                  = {
    head = { name = "Valorous Mask", augments = { 'Pet: "Dbl. Atk."+5', 'Pet: STR+6', 'Pet: Attack+15 Pet: Rng.Atk.+15', } },
    body = { name = "Valorous Mail", augments = { 'Pet: "Dbl. Atk."+5', 'Pet: STR+7', 'Pet: Accuracy+11 Pet: Rng. Acc.+11', 'Pet: Attack+8 Pet: Rng.Atk.+8', } },
    hands = { name = "Valorous Mitts", augments = { 'Pet: Attack+15 Pet: Rng.Atk.+15', 'Pet: "Dbl. Atk."+5', } },
    legs = { name = "Emicho Hose", augments = { "Pet: Accuracy+15", "Pet: Attack+15", "Pet: \"Dbl. Atk.\"+3" } },
    feet = { name = "Valorous Greaves", augments = { "Pet: Mag. Acc.+26", "Pet: \"Dbl. Atk.\"+5", "Pet: MND+8", "Pet: Attack+14 Pet: Rng.Atk.+14" } }
}

-- Aliases for the PhysMultiGear pieces
Emicho_Coronet_phys_multi            = PhysMultiGear.head
Valorous_Mail_phys_multi             = PhysMultiGear.body
Valorous_Mitts_phys_multi            = PhysMultiGear.hands
Emicho_Hose_phys_multi               = PhysMultiGear.legs
Valorous_Greaves_phys_multi          = PhysMultiGear.feet

-- Common augmented gear for pet MAB Ready moves
local MabGear                        = {
    head = { name = "Valorous Mask", augments = { 'Pet: "Mag.Atk.Bns."+28', 'Pet: INT+12', 'Pet: Attack+6 Pet: Rng.Atk.+6', }, },
    body = { name = "Valorous Mail", augments = { 'Pet: "Mag.Atk.Bns."+27', '"Dbl.Atk."+1', 'Pet: INT+13', }, },
    hands = { name = "Valorous Mitts", augments = { 'Pet: "Mag.Atk.Bns."+30', '"Store TP"+5', 'Pet: INT+14', 'Pet: Accuracy+14 Pet: Rng. Acc.+14', 'Pet: Attack+2 Pet: Rng.Atk.+2', }, },
    legs = { name = "Valorous Hose", augments = { 'Pet: "Mag.Atk.Bns."+27', 'Pet: "Subtle Blow"+7', 'Pet: INT+8', }, },
    feet = { name = "Valorous Greaves", augments = { 'Pet: "Mag.Atk.Bns."+29', 'Pet: INT+15', 'Pet: Accuracy+13 Pet: Rng. Acc.+13', }, },
}

-- Aliases for the MabGear pieces
Valorous_Mask_mab                    = MabGear.head
Valorous_Mail_mab                    = MabGear.body
Valorous_Mitts_mab                   = MabGear.hands
Valorous_Hose_mab                    = MabGear.legs
Gleti_Boots_mab                      = MabGear.feet

--============================================================--
--             WEAPON & AMMO VIRTUAL SETS (State.*)           --
--============================================================--
-- Define weapon/sub sets

-- Main/Sub weapon definitions
sets["Aymur"]                        = { main = createEquipment("Aymur") }
sets["Agwu's axe"]                   = { sub = createEquipment("Agwu's Axe") }
sets["Tauret"]                       = { main = createEquipment("Tauret") }
sets["Blur Knife"]                   = { sub = createEquipment("Blurred Knife +1") }
sets["Adapa"]                        = { sub = createEquipment("Adapa Shield") }
sets["Diamond Aspis"]                = { sub = createEquipment("Diamond Aspis") }
-- Define ammo sets
sets["Amiable Roche (Fish)"]         = { ammo = createEquipment("Airy Broth") }
sets["Jovial Edwin (Crab)"]          = { ammo = createEquipment("Pungent Broth") }
sets["Fluffy Bredo (Acuex)"]         = { ammo = createEquipment("Venomous Broth") }
sets["Sultry Patrice (Slime)"]       = { ammo = createEquipment("Putrescent Broth") }
sets["Fatso Fargann (Leech)"]        = { ammo = createEquipment("C. Plasma Broth") }
sets["Generous Arthur (Slug)"]       = { ammo = createEquipment("Dire Broth") }
sets["Blackbeard Randy (Tiger)"]     = { ammo = createEquipment("Meaty Broth") }
sets["Rhyming Shizuna (Sheep)"]      = { ammo = createEquipment("Lyrical Broth") }
sets["Pondering Peter (Rabbit)"]     = { ammo = createEquipment("Vis. Broth") }
sets["Vivacious Vickie (Raaz)"]      = { ammo = createEquipment("Tant. Broth") }
sets["Choral Leera (Colibri)"]       = { ammo = createEquipment("Glazed Broth") }
sets["Daring Roland (Hippogryph)"]   = { ammo = createEquipment("Feculent Broth") }
sets["Swooping Zhivago (Tulfaire)"]  = { ammo = createEquipment("Windy Greens") }
sets["Warlike Patrick (Lizard)"]     = { ammo = createEquipment("Livid Broth") }
sets["Suspicious Alice (Eft)"]       = { ammo = createEquipment("Furious Broth") }
sets["Brainy Waluis (Funguar)"]      = { ammo = createEquipment("Crumbly Soil") }
sets["Sweet Caroline (Mandragora)"]  = { ammo = createEquipment("Aged Humus") }
sets["Bouncing Bertha (Chapuli)"]    = { ammo = createEquipment("Bubbly Broth") }
sets["Threestar Lynn (Ladybug)"]     = { ammo = createEquipment("Muddy Broth") }
sets["Headbreaker Ken (Fly)"]        = { ammo = createEquipment("Blackwater Broth") }
sets["Energized Sefina (Beetle)"]    = { ammo = createEquipment("Gassy Sap") }
sets["Anklebiter Jedd (Diremite)"]   = { ammo = createEquipment("Crackling Broth") }
sets["Left-Handed Yoko (Mosquito)"]  = { ammo = createEquipment("Heavenly Broth") }
sets["Cursed Annabelle (Antlion)"]   = { ammo = createEquipment("Creepy Broth") }
sets["Weevil Familiar (Weevil)"]     = { ammo = createEquipment("T. Pristine Sap") }

--============================================================--
--                PET READY MOVE CATEGORY TABLES              --
--============================================================--
-- Single-hit physical moves
petPhysicalMoves                     = S {
    "Foot Kick", "Whirl Claws", "Sheep Charge", "Lamb Chop",
    "Head Butt", "Leaf Dagger", "Claw Cyclone", "Razor Fang", "Nimble Snap",
    "Cyclotail", "Rhino Attack", "Power Attack", "Mandibular Bite", "Big Scissors", "Grapple",
    "Spinning Top", "Double Claw", "Frogkick", "Blockhead", "Brain Crush", "Tail Blow",
    "??? Needles", "Needleshot", "Scythe Tail", "Ripper Fang", "Recoil Dive", "Sudden Lunge",
    "Spiral Spin", "Beak Lunge", "Suction", "Back Heel", "Choke Breath", "Fantod",
    "Tortoise Stomp", "Sensilla Blades", "Tegmina Buffet", "Swooping Frenzy",
    "Zealous Snort", "Somersault", "Sickle Slash",
    -- Tiger moves
    "Crossthrash"
}

-- Multi-hit physical moves
petPhysicalMultiMoves                = S {
    "Sweeping Gouge", "Tickling Tendrils", "Chomp Rush",
    "Pentapeck", "Wing Slap", "Pecking Flurry"
}

-- Magical nukes / damage-based spells
petMagicAtkMoves                     = S {
    "Cursed Sphere", "Venom", "Toxic Spit", "Bubble Shower",
    "Drainkiss", "Fireball", "Snow Cloud", "Charged Whisker", 
    "Purulent Ooze", "Corrosive Ooze", "Aqua Breath", "Choke Breath",
    "Stink Bomb", "Nectarous Deluge", "Nepenthic Plunge", "Pestilent Plume",
    "Foul Waters", "Acid Spray"
}

-- Magical accuracy-based moves (debuffs, status effects, buffs)
petMagicAccMoves                     = S {
    -- Debuffs
    "Sheep Song", "Scream", "Dream Flower", "Roar", "Gloeosuccus", "Palsy Pollen", "Soporific",
    "Geist Wall", "Numbing Noise", "Spoil", "Hi-Freq Field", "Sandpit", "Sandblast",
    "Venom Spray", "Filamented Hold", "Queasyshroom", "Numbshroom", "Spore", "Shakeshroom",
    "Infrasonics", "Chaotic Eye", "Blaster", "Intimidate", "Noisome Powder", "Acid Mist",
    "TP Drainkiss", "Jettatura", "Nihility Song", "Molting Plumage", "Spider Web", "Digest",
    "Silence Gas", "Dark Spore",
    -- Tiger moves
    "Predatory Glare",
    -- Healing/regen moves
    "Wild Carrot", "Wild Oats",
    -- Defensive buffs
    "Bubble Curtain", "Scissor Guard", "Metallic Body", "Rhino Guard", "Water Wall", "Harden Shell",
    -- Status enhancement
    "Secretion", "Rage"
}

--============================================================--
--                   BASE GEARSETS & TEMPLATES                --
--============================================================--

-- Initialize base tables
sets.me                              = sets.me or {}
sets.pet                             = sets.pet or {}

-- Standard pet defensive core gear (reused in multiple sets)
local petDTCore                      = {
    head = createEquipment("Anwig Salade", nil, nil, {
        "CHR+4", '"Waltz" ability delay -2', "Attack+3", "Pet: Damage taken -10%"
    }),
    body = "Tot. Jackcoat +3",
    hands = createEquipment("Ankusa Gloves +3", nil, nil, {
        'Enhances "Beast Affinity" effect'
    })
}

-- Malignance set (defensive master gear)
local malignanceSet                  = {
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Malignance Boots"
}

-- Base idle set used by both player and pet
local baseIdleSet                    = set_combine(malignanceSet, {
    ammo = "Hesperiidae",
    neck = NECK.BstCollar,
    waist = "Flume Belt",
    left_ear = EARRINGS.Odnowa,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Defending,
    right_ring = "Chirich Ring +1",
    back = Artio.STP
})

--============================================================--
--                   IDLE & DEFENSIVE GEARSETS                --
--============================================================--

-- Master idle sets
sets.idle                            = set_combine({}, baseIdleSet)
sets.me.idle                         = set_combine({}, baseIdleSet)
sets.me.idle.PDT                     = set_combine(sets.me.idle, {}) -- Override with PDT gear if needed
sets.me.idle.Town                    = set_combine(sets.me.idle, {
    feet = "Skd. Jambeaux +1"
})

-- Pet idle set (regen/defense focus)
sets.pet.idle                        = {
    head = "Nuk. Cabasset +3",
    body = "Gleti's Cuirass",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Ankusa Gaiters +3",
    neck = NECK.EliteRoyal,
    waist = "Isa Belt",
    left_ear = EARRINGS.Enmerkar,
    right_ear = EARRINGS.Odnowa,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Artio.PETMB
}

-- Pet PDT idle set (defensive variant)
sets.pet.idle.PDT                    = set_combine(sets.pet.idle, petDTCore, {
    neck = NECK.BstCollar,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Varar2,
    right_ring = RINGS.CPalug
})

--============================================================--
--                  ENGAGED (MELEE COMBAT) SETS               --
--============================================================--

-- Master engaged set (balanced ACC/DT hybrid)
sets.me.engaged                      = set_combine(malignanceSet, {
    neck = NECK.BstCollar,
    waist = "Kentarch Belt +1",
    left_ear = EARRINGS.Telos,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Artio.STP
})

-- Master engaged PDT variant (tankier)
sets.me.engaged.PDT                  = set_combine(sets.me.engaged, {
    head = "Nuk. Cabasset +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    back = Pastoralist.petDT
})

-- Pet engaged set (offensive focus)
sets.pet.engaged                     = {
    ammo = "Hesperiidae",
    head = "Nuk. Cabasset +3",
    body = "Nukumi Gausape +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Ankusa Gaiters +3",
    neck = NECK.BstCollar,
    waist = "Klouskap Sash",
    left_ear = EARRINGS.Enmerkar,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Pastoralist.petDT
}

-- Pet engaged PDT set (defensive variant)
sets.pet.engaged.PDT                 = set_combine(sets.pet.engaged, petDTCore, {
    ammo = "Hesperiidae",
    neck = NECK.BstCollar,
    waist = "Isa Belt",
    left_ring = RINGS.Varar2,
    right_ring = RINGS.CPalug,
    back = Artio.PETMB
})

-- Master + pet engaged set (used in synced combat)
sets.pet.engagedBoth                 = set_combine(malignanceSet, {
    ammo = "Hesperiidae",
    neck = NECK.BstCollar,
    waist = "Kentarch Belt +1",
    left_ear = EARRINGS.Telos,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Artio.STP
})

--============================================================--
--                  PRECAST JOB ABILITY SETS                  --
--============================================================--

-- Initialize precast tables
sets.precast                         = sets.precast or {}
sets.precast.JA                      = sets.precast.JA or {}

-- Define ability sets
-- Call Beast / Bestial Loyalty (pet summoning)
local summonSet                      = {
    head = "Acro Helm",
    body = "Mirke Wardecors",
    hands = "Ankusa Gloves +3",
    ear2 = EARRINGS.Nukumi,
    legs = "Acro Breeches",
    --[[ feet = "Armada Sollerets" ]]
}

-- Configure JA sets
sets.precast.JA['Sic']               = {
    hands = "Nukumi Manoplas +3",
    legs = "Gleti's Breeches"
}

sets.precast.JA['Ready']             = sets.precast.JA['Sic']
sets.precast.JA["Call Beast"]        = summonSet
sets.precast.JA["Bestial Loyalty"]   = summonSet

-- Reward (pet heal)
sets.precast.JA["Reward"]            = {
    ammo = "Pet Food Theta",
    head = "Khimaira Bonnet",
    body = { name = "An. Jackcoat +3", augments = { 'Enhances "Feral Howl" effect', } },
    hands = "Malignance Gloves",
    legs = { name = "Ankusa Trousers +3", augments = { 'Enhances "Familiar" effect', } },
    feet = { name = "Ankusa Gaiters +3", augments = { 'Enhances "Beast Healer" effect', } },
    neck = "Adad Amulet",
    waist = "Isa Belt",
    left_ear = "Enmerkar Earring",
    right_ear = { name = "Odnowa Earring +1", augments = { 'Path: A', } },
    left_ring = "Stikini Ring +1",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = Artio.PETMB,
}

-- Killer Instinct (buff)
sets.precast.JA["Killer Instinct"]   = {
    sub = "Diamond aspis",
    head = "Ankusa Helm +3",
    body = "Nukumi Gausape +3"
}

-- Spur (pet TP gain)
sets.precast.JA["Spur"]              = {
    feet = "Nukumi Ocreae +3",
    back = Artio.PETSTP
}

-- Default/fallback precast sets
sets.precast.JA["Misc Idle"]         = {
    hands = "Ankusa Gloves +3",
    legs = "Gleti's Breeches"
}
sets.precast.JA["Default"]           = sets.precast.JA["Misc Idle"]

--============================================================--
--                  PET READY MOVE GEAR SETS                  --
--============================================================--

-- Single-hit physical Ready moves
sets.midcast.pet_physical_moves      = {
    ammo = "Hesperiidae",
    head = PhysMultiGear.head,
    body = PhysMultiGear.body,
    hands = PhysMultiGear.hands,
    legs = PhysMultiGear.legs,
    feet = PhysMultiGear.feet,
    neck = NECK.BstCollar,
    waist = "Incarnation Sash",
    left_ear = EARRINGS.Sroda,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Varar2,
    right_ring = RINGS.CPalug,
    back = Artio.PETSTP
}

-- Multi-hit physical Ready moves (identical to physical but can be customized)
sets.midcast.pet_physicalMulti_moves = set_combine(sets.midcast.pet_physical_moves, {})

-- Magical attack Ready moves
sets.midcast.pet_magicAtk_moves      = {
    ammo = "Hesperiidae",
    head = MabGear.head,
    body = MabGear.body,
    hands = MabGear.hands,
    legs = MabGear.legs,
    feet = MabGear.feet,
    neck = NECK.Adad,
    waist = "Incarnation Sash",
    left_ear = EARRINGS.Hija,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Tali,
    right_ring = RINGS.CPalug,
    back = Artio.PETMB
}

-- Magical accuracy Ready moves (debuffs, buffs)
sets.midcast.pet_magicAcc_moves      = set_combine(sets.midcast.pet_magicAtk_moves, {})

-- Set for when pet uses magic while wielding a weapon (defined in BST_FUNCTION.lua)
sets.midcast.pet_magicAtk_moves_ww   = sets.midcast.pet_magicAtk_moves
sets.midcast.pet_magicAcc_moves_ww   = sets.midcast.pet_magicAcc_moves

--============================================================--
--                     WEAPON SKILL SETS                      --
--============================================================--

-- Default WS set (STR/DEX hybrid)
sets.precast.WS                      = {
    ammo = "Oshasha's Treatise",
    head = "Ankusa Helm +3",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Nukumi Ocreae +3",
    neck = NECK.BstCollar,
    waist = "Fotia Belt",
    left_ear = EARRINGS.Sroda,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Gere,
    right_ring = RINGS.Hetairoi,
    back = Artio.WS1
}

-- Primal Rend (MAB WS)
sets.precast.WS["Primal Rend"]       = {
    ammo = "Ghastly Tathlum +1",
    head = "Nyame Helm",
    body = "Nyame Mail",
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = NECK.Sibyl,
    waist = "Orpheus's Sash",
    left_ear = EARRINGS.Sortiarius,
    right_ear = EARRINGS.Friomisi,
    left_ring = RINGS.Cornelia,
    right_ring = RINGS.Metamorph,
    back = Artio.WS1
}

sets.precast.WS["Decimation"]        = {
    ammo = "Coiste Bodhar",
    head = "Nuk. Cabasset +3",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Nukumi Quijotes +3",
    feet = "Nukumi Ocreae +3",
    neck = "Bst. Collar +2",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Nukumi Earring +1",
    ring1 = "Sroda Ring",
    ring2 = "Gere Ring",
    back = Artio.WS1,
}

sets.precast.WS["Bora Axe"]          = {
    ammo = "Crepuscular Pebble",
    head = "Ankusa Helm +3",
    body = "Gleti's Cuirass",
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nukumi Ocreae +3",
    neck = "Bst. Collar +2",
    waist = "Sailfi Belt +1",
    ear1 = "Odnowa Earring +1",
    ear2 = "Nukumi Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Artio.WS1,
}

-- Calamity (physical WS)
sets.precast.WS["Calamity"]          = {
    ammo = "Crepuscular Pebble",
    head = "Nyame Helm",
    body = "Gleti's Cuirass",
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nukumi Ocreae +3",
    neck = NECK.BstCollar,
    waist = "Sailfi Belt +1",
    left_ear = EARRINGS.Thrud,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Cornelia,
    right_ring = RINGS.Defending,
    back = Artio.WS1
}

--============================================================--
--                     UTILITY GEARSETS                       --
--============================================================--

-- Movement speed set
sets.MoveSpeed                       = {
    feet = "Skd. Jambeaux +1"
}

-- Doom resistance set
sets.buff                            = sets.buff or {}
sets.buff.Doom                       = {
    neck = RINGS.Nicander,
    ring1 = RINGS.Purity,
    waist = "Gishdubar Sash"
}
