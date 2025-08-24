---============================================================================
--- FFXI GearSwap Equipment Sets - Bard (BRD)
---============================================================================
--- Professional BRD equipment set definitions providing optimized gear
--- configurations for all aspects of Bard gameplay. Includes comprehensive
--- song enhancement, casting, and melee sets with situational variations.
---
--- @file jobs/brd/BRD_SET.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-08-10
--- @date Modified: 2025-08-10
--- @requires Windower FFXI, GearSwap addon
--- @requires Mote-Include v2.0+, core/equipment.lua
---
--- Features:
---   - Song enhancement optimization (skill, duration, potency)
---   - Instrument-specific casting sets (harp vs horn songs)
---   - Casting time reduction and interruption resistance
---   - Melee accuracy and damage sets for TP phase
---   - Weapon skill sets for damage dealing
---   - Defensive sets (PDT/MDT/Magic Evasion)
---   - Idle and movement optimization sets
---   - Sub-job specific set variations
---
--- Set Categories:
---   - Precast: Fast Cast, Song enhancement
---   - Midcast: Song potency, skill, duration
---   - Aftercast: Idle, refresh, movement
---   - Melee: TP gain, accuracy, offensive
---   - WS: Weapon skill damage optimization
---   - Defense: Physical/Magical damage reduction
---============================================================================

--- @type table Global equipment factory for creating standardized equipment items
local success_EquipmentFactory, EquipmentFactory = pcall(require, 'utils/EQUIPMENT_FACTORY')
if not success_EquipmentFactory then
    error("Failed to load utils/equipment_factory: " .. tostring(EquipmentFactory))
end

--- @type table BRD equipment sets container
sets = {}

---============================================================================
--- AUGMENTED EQUIPMENT DEFINITIONS
---============================================================================

-- Intarabus's Cape with Specific Augments
Intarabus = {
    -- Fast Cast cape for song casting
    fc = EquipmentFactory.create("Intarabus\'s Cape", nil, nil, {
        "CHR+20",
        "Mag. Acc+20 /Mag. Dmg.+20",
        "Mag. Acc.+10",
        '"Fast Cast"+10',
        "Phys. dmg. taken-10%"
    }),
    -- Weapon Skill cape (STR-based)
    ws_str = EquipmentFactory.create("Intarabus\'s Cape", nil, nil, {
        "STR+20",
        "Accuracy+20 Attack+20",
        "STR+6",
        "Weapon skill damage +10%",
        "Phys. dmg. taken-10%"
    }),
    -- Store TP cape for melee
    stp = EquipmentFactory.create("Intarabus\'s Cape", nil, nil, {
        "DEX+20",
        "Accuracy+20 Attack+20",
        "DEX+10",
        '"Store TP"+10',
        "Phys. dmg. taken-10%"
    })
}

-- Ring Sets with Wardrobe Specification (for identical rings)
StikiRing1 = success_EquipmentFactory and EquipmentFactory.create('Stikini Ring +1', nil, 'wardrobe 6') or { name = 'Stikini Ring +1', bag = 'wardrobe 6' }
StikiRing2 = success_EquipmentFactory and EquipmentFactory.create('Stikini Ring +1', nil, 'wardrobe 7') or { name = 'Stikini Ring +1', bag = 'wardrobe 7' }
MoonlightRing1 = success_EquipmentFactory and EquipmentFactory.create('Moonlight Ring', nil, 'wardrobe 2') or { name = 'Moonlight Ring', bag = 'wardrobe 2' }
MoonlightRing2 = success_EquipmentFactory and EquipmentFactory.create('Moonlight Ring', nil, 'wardrobe 4') or { name = 'Moonlight Ring', bag = 'wardrobe 4' }

---============================================================================
--- PRECAST SETS - Song Preparation and Fast Cast
---============================================================================

--- Fast Cast set for song preparation phase
--- Maximizes casting speed for all BRD songs and abilities
--- Priority: Fast Cast % > Casting Time Reduction > Song Skill
sets.precast = {
    FC = {
        head = "Fili Calot +3",
        body = "Brioso Justau. +3",
        hands = { name = "Leyline Gloves", augments = { 'Accuracy+15', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15', '"Fast Cast"+3', } },
        legs = "Fili Rhingrave +3",
        feet = "Bihu Slippers +3",
        neck = "Orunmila\'s Torque",
        waist = "Witful Belt",
        left_ear = "Enchntr. Earring +1",
        right_ear = "Loquac. Earring",
        left_ring = "Prolix Ring",
        right_ring = "Defending Ring",
        back = Intarabus.fc
    }
}

--- Song-specific precast sets
sets.precast.BardSong = sets.precast.FC

--- Honor March precast (MUST have Marsyas equipped to cast)
sets.precast['Honor March'] = set_combine(sets.precast.FC, {
    range = "Marsyas"
})

--- Aria of Passion precast (MUST have Loughnashade equipped to cast)
--[[ sets.precast['Aria of Passion'] = set_combine(sets.precast.FC, {
    range = "Loughnashade"
}) ]]

--- Nightingale precast set (enhances song effect +1)
sets.precast.Nightingale = {
    feet = "Bihu Slippers +3"
}

--- Troubadour precast set (enhances song effect +1)
sets.precast.Troubadour = {
    body = "Bihu Justaucorps +3"
}

--- Marcato precast set (enhances next song potency)
sets.precast.Marcato = {
    head = "Fili Calot +3" -- Enhances Marcato effect
}

---============================================================================
--- MIDCAST SETS - Song Effect and Enhancement
---============================================================================

--- Base midcast song set - balanced song enhancement
--- General song casting for most situations
sets.midcast = {
    BardSong = {
        -- Add your song enhancement gear here
        main = "Kali",
        sub = "Legato Dagger", -- Will be overridden by job_post_midcast if needed
        range = "Gjallarhorn", -- Default instrument for all buff songs
        head = "Fili Calot +3",
        neck = "Mnbw. Whistle +1",
        ear1 = "Musical Earring",
        ear2 = "Fili Earring",
        body = "Fili Hongreline +3",
        hands = "Fili Manchettes +3",
        ring1 = StikiRing1,
        ring2 = StikiRing2,
        back = Intarabus.fc,
        waist = "Flume Belt",
        legs = "Inyanga Shalwar +2",
        feet = "Brioso Slippers +3"
    }
}

--- Honor March specific set (enhanced with Marsyas)
--- CRITICAL: Marsyas must be equipped throughout the entire cast
sets.midcast.HonorMarch = {
    -- Copy all BardSong equipment but force Marsyas
    main = "Kali",
    sub = "Legato Dagger",
    range = "Marsyas", -- MUST be Marsyas for Honor March
    head = "Fili Calot +3",
    neck = "Mnbw. Whistle +1",
    ear1 = "Musical Earring",
    ear2 = "Fili Earring",
    body = "Fili Hongreline +3",
    hands = "Fili Manchettes +3",
    ring1 = StikiRing1,
    ring2 = StikiRing2,
    back = Intarabus.fc,
    waist = "Flume Belt",
    legs = "Inyanga Shalwar +2",
    feet = "Brioso Slippers +3"
}

--- GearSwap auto-detects spell names, so we need this exact name
sets.midcast['Honor March'] = sets.midcast.HonorMarch

--- Aria of Passion specific set (enhanced with Loughnashade)
--- CRITICAL: Loughnashade must be equipped throughout the entire cast
sets.midcast.AriaOfPassion = {
    -- Copy all BardSong equipment but force Loughnashade
    main = "Kali",
    sub = "Legato Dagger",
    --[[  range = "Loughnashade", -- MUST be Loughnashade for Aria of Passion ]]
    head = "Fili Calot +3",
    neck = "Mnbw. Whistle +1",
    ear1 = "Musical Earring",
    ear2 = "Fili Earring",
    body = "Fili Hongreline +3",
    hands = "Fili Manchettes +3",
    ring1 = StikiRing1,
    ring2 = StikiRing2,
    back = Intarabus.fc,
    waist = "Flume Belt",
    legs = "Inyanga Shalwar +2",
    feet = "Brioso Slippers +3"
}

--- GearSwap auto-detects spell names, so we need this exact name
sets.midcast['Aria of Passion'] = sets.midcast.AriaOfPassion

--- Ballad specific sets for MP recovery songs
sets.midcast.Ballad = set_combine(sets.midcast.BardSong, {
    legs = "Fili Rhingrave +3"
})

--- Madrigal specific sets for accuracy songs
sets.midcast.Madrigal = set_combine(sets.midcast.BardSong, {
    head = "Fili Calot +3"
})

--- Minuet specific sets for attack songs
sets.midcast.Minuet = set_combine(sets.midcast.BardSong, {
    body = "Fili Hongreline +3"
})

--- Minne specific sets for defense songs
sets.midcast.Minne = set_combine(sets.midcast.BardSong, {
    legs = "Mousai Seraweels +1"
})

--- Etude specific sets for stat enhancement songs
sets.midcast.Etude = set_combine(sets.midcast.BardSong, {
    head = "Mousai Turban +1"
})

--- Threnody specific sets for resistance debuff songs
sets.midcast.Threnody = set_combine(sets.midcast.BardSong, {
    body = "Mousai Manteel +1"
})

--- Carol specific sets for resistance enhancement songs
sets.midcast.Carol = set_combine(sets.midcast.BardSong, {
    --[[ hands = "Mousai Gages +1" -- NOT OWNED YET - Enhances Carol effect ]]
})

--- Scherzo specific set for evasion songs
sets.midcast.Scherzo = set_combine(sets.midcast.BardSong, {
    feet = "Fili Cothurnes +3"
})

--- Mambo specific sets for evasion songs
sets.midcast.Mambo = set_combine(sets.midcast.BardSong, {
    --[[ feet = "Mousai Crackows +1" -- NOT OWNED YET - Enhances Mambo effect ]]
})

--- Dummy song set - for practicing or non-party situations
sets.midcast.DummySong = {
    range = "Daurdabla",
    head = { name = "Nyame Helm", augments = { 'Path: B', } },
    body = "Adamantite Armor",
    hands = "Fili Manchettes +3",
    legs = { name = "Nyame Flanchard", augments = { 'Path: B', } },
    feet = "Nyame Sollerets",
    neck = "Null Loop",
    waist = "Null Belt",
    left_ear = "Infused Earring",
    right_ear = { name = "Odnowa Earring +1", augments = { 'Path: A', } },
    left_ring = MoonlightRing1,
    right_ring = MoonlightRing2,
    back = "Solemnity Cape"
}

--- Specific dummy song sets for GearSwap auto-detection
-- Ultra-trash songs (completely useless - each has unique status ID)
sets.midcast['Gold Capriccio'] = sets.midcast.DummySong
sets.midcast['Goblin Gavotte'] = sets.midcast.DummySong
sets.midcast['Fowl Aubade'] = sets.midcast.DummySong
sets.midcast['Herb Pastoral'] = sets.midcast.DummySong

---============================================================================
--- SPECIAL INSTRUMENT SETS
---============================================================================

--- Lullaby set - Optimized for Magic Accuracy and sleep potency
sets.midcast.Lullaby = {
    range = "Daurdabla",          -- Wind instrument for sleep songs
    head = "Brioso Roundlet +3",  -- Magic Accuracy and Song skill
    body = "Fili Hongreline +3",  -- Song enhancement
    hands = "Fili Manchettes +3", -- Song skill
    legs = "Fili Rhingrave +3",   -- Song enhancement
    feet = "Brioso Slippers +3",  -- Song enhancement and Magic Accuracy
    neck = "Mnbw. Whistle +1",    -- Song skill and Magic Accuracy
    ear1 = "Regal Earring",       -- Magic Accuracy
    ear2 = "Crepuscular Earring", -- Magic Accuracy
    ring1 = StikiRing1,           -- Magic Accuracy and Song skill
    ring2 = StikiRing2,           -- Magic Accuracy +10, INT/MND/CHR +10
    waist = "Acuity Belt +1",     -- Magic Accuracy +15, INT +10
    back = Intarabus.fc           -- Fast Cast and Magic Accuracy cape
}

--- Debuff song set - For Elegy, Requiem, and all enfeebling songs
sets.midcast.DebuffSong = {
    range = "Gjallarhorn",        -- Default instrument for debuff songs
    head = "Brioso Roundlet +3",  -- Magic Accuracy and Song skill
    body = "Fili Hongreline +3",  -- Song enhancement
    hands = "Fili Manchettes +3", -- Song skill
    legs = "Fili Rhingrave +3",   -- Song enhancement
    feet = "Brioso Slippers +3",  -- Song enhancement and Magic Accuracy
    neck = "Mnbw. Whistle +1",    -- Song skill and Magic Accuracy
    ear1 = "Regal Earring",       -- Magic Accuracy
    ear2 = "Crepuscular Earring", -- Magic Accuracy
    ring1 = StikiRing1,           -- Magic Accuracy and Song skill
    ring2 = "Metamor. Ring +1",   -- Magic Accuracy +10, INT/MND/CHR +10
    waist = "Acuity Belt +1",     -- Magic Accuracy +15, INT +10
    back = Intarabus.fc           -- Fast Cast and Magic Accuracy cape
}

--- Specific debuff song sets for GearSwap auto-detection
sets.midcast['Battlefield Elegy'] = sets.midcast.DebuffSong
sets.midcast['Carnage Elegy'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem II'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem III'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem IV'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem V'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem VI'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem VII'] = sets.midcast.DebuffSong
sets.midcast['Maiden\'s Virelai'] = sets.midcast.DebuffSong
sets.midcast['Pining Nocturne'] = sets.midcast.DebuffSong

---============================================================================
--- MELEE AND COMBAT SETS
---============================================================================

--- Idle set for when not engaged
--- Optimizes for refresh, movement speed, and survivability

--- Get default weapon configuration based on manual SubSet state first, then subjob.
--- Respects player's manual choice via F7 SubSet cycling before falling back to subjob logic.
--- @return table Weapon configuration with main and sub weapon names
function get_default_weapons()
    -- First check if player has manually set SubSet state (F7 choice takes priority)
    if state and state.SubSet then
        if state.SubSet.value == 'Genmei Shield' then
            return {
                main = "Naegling",
                sub = "Genmei Shield" -- Manual choice: Shield
            }
        elseif state.SubSet.value == 'Demers. Degen +1' then
            return {
                main = "Naegling", 
                sub = "Demers. Degen +1" -- Manual choice: DualWield
            }
        end
    end
    
    -- Fallback to automatic subjob logic if no manual choice
    if player.sub_job == 'DNC' or player.sub_job == 'NIN' then
        return {
            main = "Naegling",
            sub = "Demers. Degen +1" -- Auto: Dual wield for DNC/NIN subjob
        }
    else
        return {
            main = "Naegling",
            sub = "Genmei Shield" -- Auto: Shield for non-DW subjobs
        }
    end
end

sets.idle = {
    head = "Fili Calot +3",
    body = "Fili Hongreline +3",
    hands = "Fili Manchettes +3",
    legs = "Fili Rhingrave +3",
    feet = "Fili Cothurnes +3",
    neck = "Lissome Necklace",
    waist = "Null Belt",
    left_ear = "Infused Earring",
    right_ear = "Eabani Earring",
    left_ring = MoonlightRing1,
    right_ring = MoonlightRing2,
    back = Intarabus.stp
}

--- Town idle set for cities (excluded in Dynamis)
sets.idle.Town = set_combine(sets.idle, {
    body = "Councilor\'s Garb", -- Movement speed in Adoulin
    feet = "Fili Cothurnes +3"  -- Movement speed
})

--- Melee TP set for engaged combat (weapons managed automatically)
sets.engaged = {
    ranged = "Linos",
    ammo = empty,
    head = "Aya. Zucchetto +2",
    body = "Ayanmo Corazza +2",
    hands = "Bunzi\'s Gloves",
    legs = "Fili Rhingrave +3",
    feet = "Fili Cothurnes +3",
    neck = "Bard\'s Charm +2",
    waist = "Sailfi Belt +1",
    ear1 = "Dedition Earring",
    ear2 = "Telos Earring",
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Intarabus.stp
}

--- Accuracy focused melee set
sets.engaged.Acc = set_combine(sets.engaged, {
    head = "Aya. Zucchetto +2",
    neck = "Combatant\'s Torque",
    ring1 = "Cacoethic Ring +1",
    ring2 = "Cacoethic Ring",
    waist = "Olseni Belt"
})

--- PDT focused engaged set (weapons managed automatically)
sets.engaged.PDT = {
    ranged = "Linos",
    ammo = empty,
    head = "Aya. Zucchetto +2",
    body = "Ayanmo Corazza +2",
    hands = "Bunzi\'s Gloves",
    legs = "Fili Rhingrave +3",
    feet = "Fili Cothurnes +3",
    neck = "Bard\'s Charm +2",
    waist = "Sailfi Belt +1",
    ear1 = "Dedition Earring",
    ear2 = "Telos Earring",
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Intarabus.stp
}

---============================================================================
--- WEAPON SKILL SETS
---============================================================================

--- Base weapon skill set
sets.precast.WS = {
    ammo = "Aurgelmir Orb +1",
    head = "Nyame Helm",
    body = "Bihu Justaucorps +3", -- +3 version (not +4)
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = "Bard\'s Charm +2", -- Bard\'s Charm +2 (not Rep. Plat. Medal)
    waist = "Sailfi Belt +1",
    ear1 = "Moonshade Earring",
    ear2 = "Ishvara Earring",
    ring1 = MoonlightRing1,
    ring2 = "Cornelia\'s Ring",
    back = Intarabus.ws_str
}

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    ear1 = "Moonshade Earring" -- TP Bonus +250
}

--- Mordant Rime weapon skill (magic damage)
sets.precast.WS['Mordant Rime'] = {
    head = "Aya. Zucchetto +2",
    neck = "Sanctity Necklace",
    ear1 = "Moonshade Earring",
    ear2 = "Hecate\'s Earring",
    body = "Ayanmo Corazza +2",
    hands = "Aya. Manopolas +2",
    ring1 = "Epaminondas\'s Ring",
    ring2 = "Metamor. Ring +1",
    back = Intarabus.ws_str,
    waist = "Eschan Stone",
    legs = "Aya. Cosciales +2",
    feet = "Aya. Gambieras +2"
}

--- Savage Blade weapon skill (STR-based, high damage)
sets.precast.WS['Savage Blade'] = {
    ammo = "Aurgelmir Orb +1",
    head = { name = "Nyame Helm", augments = { 'Path: B' } },
    body = { name = "Bihu Jstcorps. +3", augments = { 'Enhances "Troubadour" effect' } },
    hands = { name = "Nyame Gauntlets", augments = { 'Path: B' } },
    legs = { name = "Nyame Flanchard", augments = { 'Path: B' } },
    feet = { name = "Nyame Sollerets", augments = { 'Path: B' } },
    neck = { name = "Bard\'s Charm +2", augments = { 'Path: A' } },
    waist = { name = "Sailfi Belt +1", augments = { 'Path: A' } },
    ear1 = "Ishvara Earring", -- Moonshade will auto-equip if TP < 2750
    ear2 = "Crep. Earring",   -- Backup earring when Moonshade not needed
    ring1 = MoonlightRing1,
    ring2 = "Cornelia\'s Ring",
    back = Intarabus.ws_str
}

--- Rudra\'s Storm weapon skill (high damage dagger WS for Twashtar)
sets.precast.WS['Rudra\'s Storm'] = {
    ammo = "Aurgelmir Orb +1",
    head = "Nyame Helm",
    body = "Bihu Jstcorps. +3",
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = "Bard\'s Charm +2",
    waist = "Kentarch Belt +1",
    ear1 = "Mache Earring +1",
    ear2 = "Domin. Earring +1",
    ring1 = "Cornelia\'s Ring",
    ring2 = MoonlightRing2,
    back = Intarabus.ws_str
}

--- Evisceration weapon skill (critical hit dagger WS for Twashtar)
sets.precast.WS['Evisceration'] = {
    ranged = "Linos",
    ammo = "Empty",
    head = "Blistering Sallet +1",
    body = "Bihu Jstcorps. +3",
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Lustra. Leggings +1",
    neck = "Bard\'s Charm +2",
    waist = "Fotia Belt",
    ear1 = "Odnowa Earring +1",
    ear2 = "Domin. Earring +1",
    ring1 = "Defending Ring",
    ring2 = MoonlightRing2,
    back = "Intarabus\'s Cape"
}

-- TPBonus sets for weapon skills (Moonshade auto-equips when beneficial)
sets.precast.WS['Savage Blade'].TPBonus = set_combine(sets.precast.WS['Savage Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Rudra\'s Storm'].TPBonus = set_combine(sets.precast.WS['Rudra\'s Storm'], sets.precast.WS.TPBonus)
sets.precast.WS['Evisceration'].TPBonus = set_combine(sets.precast.WS['Evisceration'], sets.precast.WS.TPBonus)
sets.precast.WS['Mordant Rime'].TPBonus = set_combine(sets.precast.WS['Mordant Rime'], sets.precast.WS.TPBonus)

---============================================================================
--- DEFENSIVE SETS
---============================================================================

--- Physical damage taken reduction set (references engaged.PDT)
sets.defense = {
    PDT = sets.engaged.PDT -- Points to engaged.PDT for consistency
}

--- Magical damage taken reduction set (same as idle)
sets.defense.MDT = {
    head = "Fili Calot +3",
    body = "Fili Hongreline +3",
    hands = "Fili Manchettes +3",
    legs = "Fili Rhingrave +3",
    feet = "Fili Cothurnes +3",
    neck = "Lissome Necklace",
    waist = "Null Belt",
    left_ear = "Infused Earring",
    right_ear = "Eabani Earring",
    left_ring = MoonlightRing1,
    right_ring = MoonlightRing2,
    back = Intarabus.stp
}

---============================================================================
--- HYBRID SETS - Combined Offense and Defense
---============================================================================

--- Hybrid sets now reference the engaged.PDT directly
sets.engaged.Hybrid = {
    PDT = sets.engaged.PDT, -- Direct reference to engaged.PDT
    MDT = set_combine(sets.engaged, sets.defense.MDT)
}

sets.engaged.Acc.Hybrid = {
    PDT = sets.engaged.PDT, -- Use same PDT set for accuracy mode
    MDT = set_combine(sets.engaged.Acc, sets.defense.MDT)
}

---============================================================================
--- WEAPON SETS
---============================================================================

--- Main weapon sets for F6 cycling
sets.Naegling = { main = "Naegling" }
sets.Twashtar = { main = "Twashtar" }
sets.Tauret = { main = "Tauret" } -- Legacy weapon set

--- Sub weapon sets (managed automatically based on subjob)
sets.Shield = { sub = "Genmei Shield" }       -- For non-DW subjobs
sets.DualWield = { sub = "Demers. Degen +1" } -- For DNC/NIN subjobs

--- Basic engaged (melee) set
sets.engaged = {
    head = "Nyame Helm",
    body = "Nyame Mail", 
    hands = "Nyame Gauntlets",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = "Lissome Necklace",
    ear1 = "Cessance Earring",
    ear2 = "Telos Earring",
    ring1 = "Petrov Ring",
    ring2 = "Hetairoi Ring",
    back = "Intarabus's Cape",
    waist = "Windbuffet Belt +1"
}

---============================================================================
--- MOVEMENT SETS
---============================================================================

sets.MoveSpeed = { feet = "Fili Cothurnes +3" }
sets.Kiting = sets.MoveSpeed

---============================================================================
--- JOB LOADING MESSAGE
---============================================================================

-- Show loading message with keybinds
local success_JobLoader, JobLoader = pcall(require, 'utils/JOB_LOADER')
if not success_JobLoader then
    error("Failed to load utils/job_loader: " .. tostring(JobLoader))
end
JobLoader.show_loaded_message("BRD")
