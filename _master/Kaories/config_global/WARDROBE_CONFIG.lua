---  ═══════════════════════════════════════════════════════════════════════════
---   Kaories - Wardrobe Organizer Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Per-character bag layout. Kaories has 4 wardrobes (W1-W4). Now that the
---   active job fits comfortably in 4 wardrobes, all four are PRIMARY and
---   overflow goes to Sack / Case / Satchel for unused items.
---
---   FFXI bag IDs (for reference):
---     0 = inventory      5 = satchel        6 = sack          7 = case
---     8 = wardrobe1     10 = wardrobe2     11 = wardrobe3    12 = wardrobe4
---
---   @file Kaories/config/WARDROBE_CONFIG.lua
---  ═══════════════════════════════════════════════════════════════════════════

return {
    -- ─── REGULAR MODE  (//gs c wo)  ─────────────────────────────────────────
    -- Active job's gear spreads across all 4 wardrobes.
    PRIMARY_BAGS  = {8, 10, 11, 12},            -- W1, W2, W3, W4

    -- Overflow for unused items: Sack > Case > Satchel.
    OVERFLOW_BAGS = {6, 7, 5},                  -- Sack, Case, Satchel

    -- Nothing protected (Kaories doesn't use a craft wardrobe).
    PROTECTED     = {},

    -- All wardrobes Kaories has unlocked.
    ALL_WARDROBES = {8, 10, 11, 12},

    -- ─── ALT MODE  (//gs c wo alt)  ─────────────────────────────────────────
    -- Same as regular for Kaories (4 wardrobes + bag overflow).
    -- Considers items used by ANY job in Kaories/sets/.
    ALT_PRIMARY_BAGS  = {8, 10, 11, 12},        -- W1, W2, W3, W4
    ALT_OVERFLOW_BAGS = {6, 7, 5},              -- Sack, Case, Satchel
}
