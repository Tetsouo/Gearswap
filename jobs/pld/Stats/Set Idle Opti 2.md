sets.idle = {
    ammo = createEquipment('Staunch Tathlum +1', 5),       -- DT -3%, Status resistance +11, Spell interruption rate -11%
    head = createEquipment('Chev. Armet +3', 12),          -- HP+145, DT -11%, Converts 8% of physical damage to MP
    body = createEquipment("Adamantite Armor", 13),        -- HP+182, DT -20%, Very high DEF
    hands = createEquipment("Chev. Gauntlets +3", 8),      -- HP+64, DT -11%, Shield block bonus
    legs = createEquipment('Chev. Cuisses +3', 11),        -- HP+127, DT -13%, Enmity+14
    feet = createEquipment('Chev. Sabatons +3', 7),        -- HP+52, Completes set bonus for damage absorption
    neck = createEquipment('Kgt. beads +2', 9),            -- HP+60, DT -7%, Enmity+10
    waist = createEquipment('Asklepian Belt', 1),          -- Magic defense bonus, Magic Evasion+20
    left_ear = createEquipment('Odnowa Earring +1', 10),   -- HP+110, DT -3%, MDT -2%
    right_ear = createEquipment('Chev. Earring +1', 4),    -- DT -3% ~ -5%, Cure potency +11%
    left_ring = createEquipment('Fortified Ring', 3),      -- MDT -5%, Reduces enemy critical hit rate -7%
    right_ring = createEquipment('Gelatinous Ring +1', 6), -- HP+100, PDT -7%, MDT +1%, VIT+15
    back = Rudianos.tank                                   -- PDT -10%, VIT+20, Enmity+10, Magic Evasion +10
}

-- Tableau récapitulatif des statistiques
-- | Statistique                  | Total |
-- |------------------------------|-------|
-- | Magic Evasion                |  650  |
-- | Vitality (VIT)               |  243  |
-- | Damage Taken (DT)            |   69  |
-- | Physical Damage Taken (PDT)  |   17  |
-- | Enemy Critical Hit Rate      |    7  |
-- | Magic Damage Taken (MDT)     |    6  |

-- Calcul détaillé :
-- DT Total: -3% (ammo) -11% (head) -20% (body) -11% (hands) -13% (legs) -7% (neck) -3% (left ear) -4% (right ear) = -69%
-- PDT Total: -7% (right ring) -10% (back) = -17%
-- MDT Total: -2% (left ear) -5% (left ring) +1% (right ring) = -6%
-- VIT Total: +58 (head) +51 (body) +54 (hands) +43 (legs) +40 (feet) +15 (neck) +3 (left ear) +15 (right ring) +20 (back) = +243
-- Enemy Critical Hit Rate: -7% (left ring)
-- Magic Evasion Total: +103 (head) +107 (body) +98 (hands) +136 (legs) +136 (feet) +20 (waist) +10 (back) = +650
