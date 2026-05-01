---============================================================================
--- Fishing Equipment Set - Tetsouo
---============================================================================
--- Single-set fishing gear. Activated by command:
---
---   //gs c fish    -> equip fishing set
---
--- File format consumed by shared/utils/craft/craft_manager.lua:
---   - description : shown in chat after equip
---   - gear        : slot -> item-name table
---
--- @file    Tetsouo/sets/fishing_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-05-01
---============================================================================

return {
    description = 'Fishing',
    gear = {
        -- Weapon
        range      = "Ebisu F. Rod +1",
        -- Armor
        head       = "Tlahtlamah Glasses",
        body       = "Fisherman's Smock",
        hands      = "Angler's Gloves",
        legs       = "Fisherman's Hose",
        feet       = "Waders",
        -- Accessories
        neck       = "Fisher's Torque",
        waist      = "Fisher's Rope",
        left_ear   = "Infused Earring",
        right_ear  = "Eabani Earring",
        left_ring  = "Noddy Ring",
        right_ring = "Puffin Ring",
        back       = "Solemnity Cape",
    },
}
