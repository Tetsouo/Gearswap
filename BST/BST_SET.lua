--============================================================--
--=                      BST_SET                             =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

--- Creates an equipment object.
-- This function creates an equipment object with the given parameters.
-- If a parameter is not provided, it will be set to a default value.
-- @param name (string) The name of the equipment. This must be a string.
-- @param priority (number, optional) The priority of the equipment. This must be a number or nil. Defaults to nil if not provided.
-- @param bag (string, optional) The bag in which the equipment is stored. This must be a string or nil. Defaults to nil if not provided.
-- @param augments (table, optional) The augments of the equipment. This must be a table. Defaults to an empty table if not provided.
-- @return table A table representing the equipment, with fields for name, priority, bag, and augments.
-- @usage local equipment = createEquipment("Sword", 1, "Bag1", {"Augment1", "Augment2"})
function createEquipment(name, priority, bag, augments)
    assert(type(name) == 'string', "Parameter 'name' must be a string")
    assert(priority == nil or type(priority) == 'number', "Parameter 'priority' must be a number or nil")
    assert(bag == nil or type(bag) == 'string', "Parameter 'bag' must be a string or nil")
    assert(not augments or type(augments) == 'table', "Parameter 'augments' must be a table")

    return {
        name = name,
        priority = priority or nil,
        bag = bag or nil,
        augments = augments or {}
    }
end

-- =========================================================================================================
--                                           Equipments - Unique Items
-- =========================================================================================================
JumalikHead = createEquipment('Jumalik Helm', nil, nil,
    { 'MND+10', '"Mag.Atk.Bns."+15', 'Magic burst dmg.+10%', '"Refresh"+1' })
JumalikBody = createEquipment('Jumalik Mail', nil, nil, { 'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2' })

MoonbeamRing1 = createEquipment('Moonbeam Ring', nil, "wardrobe 2")
MoonbeamRing2 = createEquipment('Moonbeam Ring', nil, "wardrobe 3")
ChirichRing1 = createEquipment('Chirich Ring +1', nil, "wardrobe 1")
ChirichRing2 = createEquipment('Chirich Ring +1', nil, "wardrobe 2")
MoonbeamRing1 = createEquipment('Moonbeam Ring', nil, "wardrobe 2")
MoonbeamRing2 = createEquipment('Moonbeam Ring', nil, "wardrobe 3")
StikiniRing1 = createEquipment('Stikini Ring +1', nil, "wardrobe 6")
StikiniRing2 = createEquipment('Stikini Ring +1', nil, "wardrobe 7")
VararRing1 = createEquipment('Varar Ring +1', nil, "wardrobe 6")
VararRing2 = createEquipment('Varar Ring +1', nil, "wardrobe 7")

sets["Aymur"] = { main = createEquipment("Aymur") }
sets["Agwu's axe"] = { sub = createEquipment("Agwu's axe") }
sets["Arktoi"] = { main = createEquipment('Arktoi') }
sets["Izizoeksi"] = { sub = createEquipment('Izizoeksi') }
sets["Tauret"] = { main = createEquipment('Tauret') }
sets["Blur Knife"] = { sub = createEquipment('Blurred Knife +1') }

Artio = {
    STP = {
        name = "Artio's Mantle",
        augments = { 'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Damage taken-5%', }
    },

    WS1 = {
        name = "Artio's Mantle",
        augments = { 'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%',
        },

        PETSTP = {
            name = "Artio's Mantle",
            augments = { 'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20', 'Accuracy+20 Attack+20', 'Pet: Accuracy+2 Pet: Rng. Acc.+2', 'Pet: Haste+10', 'Pet: Damage taken -5%', }
        },
        PETMB = {
            name = "Artio's Mantle",
            augments = { 'Pet: M.Acc.+20 Pet: M.Dmg.+20', 'Eva.+20 /Mag. Eva.+20', 'Pet: Magic Damage+10', 'Pet: "Regen"+10', 'Pet: Damage taken -5%', },
        },
    }
}

Pastoralist = {
    petDT = { name = "Pastoralist's Mantle", augments = { 'STR+3 DEX+3', 'Pet: Accuracy+18 Pet: Rng. Acc.+18', 'Pet: Damage taken -4%', } },
}

sets["Chapuli"] = { ammo = createEquipment("Bubbly Broth") }
sets["Tulfaire"] = { ammo = createEquipment("Windy Greens") }
sets["Acuex"] = { ammo = createEquipment("Venomous Broth") }
sets["Slug"] = { ammo = createEquipment("Dire Broth") }
sets["Hippo"] = { ammo = createEquipment("Feculent Broth") }
sets["Slime"] = { ammo = createEquipment("Putrescent Broth") }
sets["Leech"] = { ammo = createEquipment("C. Plasma Broth") }
sets["Crab"] = { ammo = createEquipment("Pungent Broth") }



-- =========================================================================================================
--                                           PET - Sic & Ready Moves
-- =========================================================================================================
pet_physical_moves = S { 'Sic', 'Foot Kick', 'Whirl Claws', 'Wild Carrot', 'Sheep Charge', 'Lamb Chop', 'Head Butt',
    'Wild Oats', 'Leaf Dagger', 'Claw Cyclone', 'Razor Fang', 'Nimble Snap', 'Cyclotail', 'Rhino Attack', 'Power Attack',
    'Mandibular Bite', 'Big Scissors', 'Grapple', 'Spinning Top', 'Double Claw', 'Frogkick', 'Blockhead', 'Brain Crush',
    'Tail Blow', '??? Needles', 'Needleshot', 'Scythe Tail', 'Ripper Fang', 'Recoil Dive', 'Sudden Lunge',
    'Spiral Spin', 'Beak Lunge', 'Suction', 'Back Heel', 'Choke Breath', 'Fantod', 'Tortoise Stomp',
    'Harden Shell', 'Sensilla Blades', 'Tegmina Buffet', 'Swooping Frenzy',
    'Zealous Snort', 'Somersault', 'Sickle Slash', 'Mega Scissors' }

pet_physicalMulti_moves = S { 'Sweeping Gouge', 'Tickling Tendrils', 'Chomp Rush',
    'Pentapeck', 'Wing Slap', 'Pecking Flurry', }

pet_magicAtk_moves = S { 'Dust Cloud', 'Cursed Sphere', 'Venom', 'Toxic Spit', 'Bubble Shower', 'Drainkiss',
    'Silence Gas', 'Dark Spore', 'Fireball', 'Plague Breath', 'Snow Cloud', 'Charged Whisker', 'Purulent Ooze',
    'Corrosive Ooze', 'Aqua Breath', 'Stink Bomb', 'Nectarous Deluge', 'Nepenthic Plunge', 'Pestilent Plume',
    'Foul Waters', 'Infected Leech', 'Gloom Spray', 'Fluid Spread', 'Fluid Toss', 'Venom Shower' }

pet_magicAcc_moves = S { 'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus', 'Palsy Pollen',
    'Soporific', 'Geist Wall', 'Toxic Spit', 'Numbing Noise', 'Spoil', 'Hi-Freq Field', 'Sandpit', 'Sandblast',
    'Venom Spray', 'Filamented Hold', 'Queasyshroom', 'Numbshroom', 'Spore', 'Shakeshroom', 'Infrasonics',
    'Chaotic Eye', 'Blaster', 'Intimidate', 'Noisome Powder', 'Acid Mist', 'TP Drainkiss', 'Jettatura', 'Nihility Song',
    'Molting Plumage', 'Spider Web' }

petTp_moves = S { 'Sic', 'Foot Kick', 'Dust Cloud', 'Snow Cloud', 'Wild Carrot', 'Sheep Song', 'Sheep Charge',
    'Lamb Chop', 'Rage', 'Head Butt', 'Scream', 'Dream Flower', 'Wild Oats', 'Leaf Dagger', 'Claw Cyclone', 'Razor Fang',
    'Roar', 'Gloeosuccus', 'Palsy Pollen', 'Soporific', 'Cursed Sphere', 'Somersault', 'Geist Wall', 'Numbing Noise',
    'Frogkick', 'Nimble Snap', 'Cyclotail', 'Spoil', 'Rhino Guard', 'Rhino Attack', 'Hi-Freq Field', 'Sandpit', 'Sandblast',
    'Mandibular Bite', 'Metallic Body', 'Bubble Shower', 'Bubble Curtain', 'Scissor Guard', 'Grapple', 'Spinning Top',
    'Double Claw', 'Filamented Hold', 'Spore', 'Blockhead', 'Secretion', 'Fireball', 'Tail Blow', 'Plague Breath',
    'Brain Crush', 'Infrasonics', 'Needleshot', 'Chaotic Eye', 'Blaster', 'Ripper Fang', 'Intimidate', 'Recoil Dive',
    'Water Wall', 'Sudden Lunge', 'Noisome Powder', 'Wing Slap', 'Beak Lunge', 'Suction', 'Drainkiss', 'Acid Mist',
    'TP Drainkiss', 'Back Heel', 'Choke Breath', 'Fantod', 'Charged Whisker', 'Tortoise Stomp', 'Harden Shell', 'Aqua Breath', 'Sensilla Blades', 'Tegmina Buffet',
    'Sweeping Gouge', 'Zealous Snort', 'Tickling Tendrils', 'Pecking Flurry', 'Pestilent Plume', 'Foul Waters',
    'Spider Web', 'Gloom Spray' }
-- =========================================================================================================
--                                           Equipments - Idle and Defense Sets
-- =========================================================================================================
sets.me = {}
sets.pet = {}
sets.me.idle = {
    head = "Nuk. Cabasset +3",
    body = "Malignance Tabard",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    neck = "Elite Royal Collar",
    waist = "Asklepian Belt",
    left_ear = "Tuisto Earring",
    right_ear = "Infused Earring",
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Artio.STP,
}

sets.me.idle.PDT = set_combine(sets.me.idle, {})

sets.me.idle.Town = set_combine(
    sets.idle,
    {
        feet = createEquipment("Skd. Jambeaux +1")
    }
)

sets.pet.idle = {
    head = "Nuk. Cabasset +3",
    body = "Gleti's Cuirass",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    neck = "Elite Royal Collar",
    waist = "Isa Belt",
    left_ear = "Hypaspist Earring",
    right_ear = "Odnowa Earring +1",
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Artio.PETMB,
}

sets.pet.idle.PDT = {
    ammo = "Bubbly Broth",
    head = { name = "Anwig Salade", augments = { 'CHR+4', '"Waltz" ability delay -2', 'Attack+3', 'Pet: Damage taken -10%', } },
    body = "Tot. Jackcoat +3",
    hands = { name = "Ankusa Gloves +3", augments = { 'Enhances "Beast Affinity" effect', } },
    legs = "Tali'ah Sera. +2",
    feet = "Gleti's Boots",
    neck = { name = "Bst. Collar +2", augments = { 'Path: A', } },
    waist = "Isa Belt",
    left_ear = "Hypaspist Earring",
    right_ear = "Enmerkar Earring",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = { name = "Artio's Mantle", augments = { 'Pet: M.Acc.+20 Pet: M.Dmg.+20', 'Eva.+20 /Mag. Eva.+20', 'Pet: Magic Damage+10', 'Pet: "Regen"+10', 'Pet: Damage taken -5%', } },
}

-- =========================================================================================================
--                                           Equipments - Engaged Sets
-- =========================================================================================================
sets.me.engaged = {
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Malignance Boots",
    neck = { name = "Bst. Collar +2", augments = { 'Path: A', } },
    waist = { name = "Kentarch Belt +1", augments = { 'Path: A', } },
    left_ear = "Telos Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Artio.STP,
}

sets.me.engaged.PDT = set_combine(
    sets.me.engaged, {
        head = "Nuk. Cabasset +3",
        hands = "Nukumi Manoplas +3",
        legs = "Nukumi Quijotes +3",
        back = "Pastoralist's Mantle",
    }
)

sets.pet.engaged = {
    head = "Nuk. Cabasset +3",
    body = "Nukumi Gausape +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    neck = "Bst. Collar +2",
    waist = "Klouskap Sash",
    left_ear = "Enmerkar Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = "Pastoralist's Mantle",
}

sets.pet.engaged.PDT = set_combine(sets.pet.engaged, {
    ammo = "Bubbly Broth",
    head = { name = "Anwig Salade", augments = { 'CHR+4', '"Waltz" ability delay -2', 'Attack+3', 'Pet: Damage taken -10%', } },
    body = "Tot. Jackcoat +3",
    hands = { name = "Ankusa Gloves +3", augments = { 'Enhances "Beast Affinity" effect', } },
    legs = "Tali'ah Sera. +2",
    feet = "Gleti's Boots",
    neck = { name = "Bst. Collar +2", augments = { 'Path: A', } },
    waist = "Isa Belt",
    left_ear = "Hypaspist Earring",
    right_ear = "Enmerkar Earring",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = { name = "Artio's Mantle", augments = { 'Pet: M.Acc.+20 Pet: M.Dmg.+20', 'Eva.+20 /Mag. Eva.+20', 'Pet: Magic Damage+10', 'Pet: "Regen"+10', 'Pet: Damage taken -5%', } },
})

sets.pet.engagedBoth = {
    head = "Anwig Salade",
    body = "Malignance Tabard",
    hands = "Gleti's Gauntlets",
    legs = "Nukumi Quijotes +3",
    feet = "Ankusa Gaiters +3",
    neck = "Bst. Collar +2",
    waist = "Isa Belt",
    left_ear = "Enmerkar Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = Artio.PETSTP,
}

-- =========================================================================================================
--                                           Equipments - Job Ability Sets
-- =========================================================================================================
--[[ sets.precast.JA = {
    hands = "Ankusa Gloves +3",
    legs = "Gleti's Breeches",
} ]]

sets.precast.JA['Reward'] = {
    ammo = "Pet Food Theta",
    head = "Khimaira Bonnet",
    body = "An. Jackcoat +3",
    hands = "Ogre Gloves",
    legs = "Ankusa Trousers +3",
    feet = "Ankusa Gaiters +3",
    neck = "Elite Royal Collar",
    waist = "Asklepian Belt",
    left_ear = "Ferine Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = StikiRing1,
    right_ring = "Metamor. Ring +1",
    back = Artio.PETMB,
}

-- =========================================================================================================
--                                           Equipments - PET SIC & READY MOVES
-- =========================================================================================================

sets.midcast.Pet = {
    --[[     ammo = "Hesperiidae",
    head = "Nuk. Cabasset +3",
    body = "Nukumi Gausape +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    neck = "Shulmanu Collar",
    waist = "Incarnation Sash",
    left_ear = "Sroda Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETSTP, ]]
}

sets.midcast.pet_physical_moves = {
    ammo = "Hesperiidae",
    head = { name = "Valorous Mask", augments = { 'Pet: Accuracy+30 Pet: Rng. Acc.+30', 'Pet: "Dbl.Atk."+4 Pet: Crit.hit rate +4', 'Pet: Attack+15 Pet: Rng.Atk.+15', } },
    body = { name = "Valorous Mail", augments = { 'Pet: Accuracy+30 Pet: Rng. Acc.+30', 'Pet: "Dbl. Atk."+5', } },
    hands = "Nukumi Manoplas +3",
    legs = { name = "Valorous Hose", augments = { 'Pet: Accuracy+25 Pet: Rng. Acc.+25', 'Pet: "Dbl. Atk."+5', 'Pet: DEX+10', 'Pet: Attack+1 Pet: Rng.Atk.+1', } },
    feet = "Gleti's Boots",
    neck = "Shulmanu Collar",
    waist = "Incarnation Sash",
    left_ear = "Sroda Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETSTP,
}

sets.midcast.pet_physicalMulti_moves = set_combine(sets.midcast.pet_physical_moves, {
    neck = "Bst. Collar +2",
})

sets.midcast.pet_magicAtk_moves = {
    main = { name = "Kumbhakarna", augments = { 'Pet: "Mag.Atk.Bns."+25', 'Pet: Damage taken -4%', 'Pet: TP Bonus+200', } },
    sub = { name = "Kumbhakarna", augments = { 'Pet: "Mag.Atk.Bns."+22', 'Pet: Damage taken -4%', 'Pet: TP Bonus+200', } },
    ammo = "Hesperiidae",
    neck = "Adad Amulet",
    head = { name = "Valorous Mask", augments = { 'Pet: "Mag.Atk.Bns."+30', 'Pet: "Dbl. Atk."+4', 'Pet: INT+9', 'Pet: Accuracy+2 Pet: Rng. Acc.+2', } },
    body = { name = "Valorous Mail", augments = { 'Pet: "Mag.Atk.Bns."+28', 'Pet: "Store TP"+1', 'Pet: DEX+6', 'Pet: Accuracy+3 Pet: Rng. Acc.+3', } },
    hands = { name = "Valorous Mitts", augments = { 'Pet: "Mag.Atk.Bns."+25', 'Pet: "Dbl. Atk."+3', 'Pet: INT+10', 'Pet: Accuracy+1 Pet: Rng. Acc.+1', } },
    legs = { name = "Valorous Hose", augments = { 'Pet: "Mag.Atk.Bns."+27', 'Pet: "Subtle Blow"+7', 'Pet: INT+8', } },
    feet = { name = "Valorous Greaves", augments = { 'Pet: "Mag.Atk.Bns."+29', 'Pet: Haste+2', 'Pet: Accuracy+3 Pet: Rng. Acc.+3', 'Pet: Attack+5 Pet: Rng.Atk.+5', } },
    waist = "Incarnation Sash",
    left_ear = "Hija Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETMB,
}

sets.midcast.pet_magicAcc_moves = {
    main = { name = "Kumbhakarna", augments = { 'Pet: "Mag.Atk.Bns."+25', 'Pet: Damage taken -4%', 'Pet: TP Bonus+200', } },
    sub = { name = "Kumbhakarna", augments = { 'Pet: "Mag.Atk.Bns."+22', 'Pet: Damage taken -4%', 'Pet: TP Bonus+200', } },
    ammo = "Hesperiidae",
    head = "Nuk. Cabasset +3",
    neck = "Adad Amulet",
    body = "Nukumi Gausape +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    waist = "Incarnation Sash",
    left_ear = "Hija Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETMB,
}

sets.midcast.pet_magicAtk_moves_ww = {
    ammo = "Hesperiidae",
    neck = "Adad Amulet",
    head = { name = "Valorous Mask", augments = { 'Pet: "Mag.Atk.Bns."+30', 'Pet: "Dbl. Atk."+4', 'Pet: INT+9', 'Pet: Accuracy+2 Pet: Rng. Acc.+2', } },
    body = { name = "Valorous Mail", augments = { 'Pet: "Mag.Atk.Bns."+28', 'Pet: "Store TP"+1', 'Pet: DEX+6', 'Pet: Accuracy+3 Pet: Rng. Acc.+3', } },
    hands = { name = "Valorous Mitts", augments = { 'Pet: "Mag.Atk.Bns."+25', 'Pet: "Dbl. Atk."+3', 'Pet: INT+10', 'Pet: Accuracy+1 Pet: Rng. Acc.+1', } },
    legs = { name = "Valorous Hose", augments = { 'Pet: "Mag.Atk.Bns."+27', 'Pet: "Subtle Blow"+7', 'Pet: INT+8', } },
    feet = { name = "Valorous Greaves", augments = { 'Pet: "Mag.Atk.Bns."+29', 'Pet: Haste+2', 'Pet: Accuracy+3 Pet: Rng. Acc.+3', 'Pet: Attack+5 Pet: Rng.Atk.+5', } },
    waist = "Incarnation Sash",
    left_ear = "Hija Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETMB,
}

sets.midcast.pet_magicAcc_moves_ww = {
    ammo = "Hesperiidae",
    head = "Nuk. Cabasset +3",
    neck = "Adad Amulet",
    body = "Nukumi Gausape +3",
    hands = "Nukumi Manoplas +3",
    legs = "Nukumi Quijotes +3",
    feet = "Gleti's Boots",
    waist = "Incarnation Sash",
    left_ear = "Hija Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Varar Ring +1",
    right_ring = "C. Palug Ring",
    back = Artio.PETMB,
}

-- =========================================================================================================
--                                           Equipments - Movement Sets
-- =========================================================================================================
sets.MoveSpeed = {
    feet = createEquipment("Skd. Jambeaux +1")
}
-- =========================================================================================================
--                                           Equipments - Weapon Skill Sets
-- =========================================================================================================
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = "Ankusa Helm +3",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Nukumi Ocreae +3",
    neck = "Bst. Collar +2",
    waist = "Fotia Belt",
    left_ear = "Sroda Earring",
    right_ear = "Nukumi Earring +1",
    left_ring = "Gere Ring",
    right_ring = "Hetairoi Ring",
    back = WS1,
}

sets.precast.WS['Primal Rend'] = {
    ammo = createEquipment("Ghastly Tathlum +1"),
    head = createEquipment("Nyame Helm"),
    body = createEquipment("Nyame Mail"),
    hands = createEquipment("Nyame Gauntlets"),
    legs = createEquipment("Nyame Flanchard"),
    feet = createEquipment("Nyame Sollerets"),
    neck = createEquipment("Sibyl Scarf"),
    waist = createEquipment("Orpheus's Sash"),
    left_ear = createEquipment("Sortiarius Earring"),
    right_ear = createEquipment("Friomisi Earring"),
    left_ring = createEquipment("Cornelia's Ring"),
    right_ring = createEquipment("Metamor. Ring +1"),
    back = Artio.WS1,
}

-- =========================================================================================================
--                                           Equipments - Custom Buff Sets
-- =========================================================================================================
sets.buff.Doom = {
    neck = createEquipment("Nicander's Necklace"), -- Reduces Doom effects
    ring1 = createEquipment("Purity Ring"),        -- Additional Doom resistance
    waist = createEquipment("Gishdubar Sash"),     -- Enhances Doom recovery effects
}
