---============================================================================
--- Bonecraft Equipment Sets - Tetsouo
---============================================================================
--- Multiple variants for different synthesis goals and sub-craft helpers.
--- Activated by:
---
---   //gs c craft           -> default variant (HQ rate, Confectioner's Ring)
---   //gs c craft nq        -> NQ guarantee (Bonecrafter's Ring)
---   //gs c craft success   -> Success rate (Patissiere's Ring)
---
---   --- HQ + sub-craft skill helpers (replace Bone. Torque with sub torque) ---
---   //gs c craft wood      -> HQ + Carver's Torque (woodworking sub)
---   //gs c craft smith     -> HQ + Smithy's Torque (smithing sub)
---   //gs c craft leather   -> HQ + Tanner's Torque (leathercraft sub)
---
--- File format consumed by shared/utils/craft/craft_manager.lua:
---   - default: variant key used when //gs c craft is invoked with no arg
---   - variants: keyed by command argument (lowercase). Each entry has:
---       * description : shown in chat after equip
---       * aliases     : alternate command keywords
---       * gear        : slot -> item-name table
---
--- @file    Tetsouo/sets/bonecraft_sets.lua
--- @author  Tetsouo
--- @version 1.1
--- @date    Created: 2026-05-01 | Updated: 2026-05-01 (sub-craft variants)
---============================================================================

---============================================================================
--- SHARED PIECES (common pieces across all variants)
---============================================================================
-- Default neck = Bone. Torque, default ring = (varies per variant).
-- Sub-craft variants override `neck` to swap in the sub-craft skill torque.
local BoneShared = {
    sub        = "Os. Escutcheon",
    head       = "Protective Specs.",
    body       = "Bonewrk. Smock",
    neck       = "Bone. Torque",
    waist      = "Boneworker's Blt.",
    left_ring  = "Orvail Ring +1",
}

--- Helper: clone shared pieces and override specific slots.
--- @param overrides table  partial slot table (e.g. {right_ring = 'X'})
--- @return table merged set
local function set_with(overrides)
    local set = {}
    for k, v in pairs(BoneShared) do set[k] = v end
    for k, v in pairs(overrides)   do set[k] = v end
    return set
end

---============================================================================
--- VARIANT DEFINITIONS
---============================================================================

return {
    -- Variant returned when //gs c craft is invoked without an argument.
    default = 'hq',

    variants = {
        ---  ── Pure-bonecraft variants (default neck = Bone. Torque) ──────────

        --- HQ rate (Confectioner's Ring)
        hq = {
            description = 'Bonecraft HQ',
            aliases     = { 'hq' },
            gear        = set_with({ right_ring = "Confectioner's Ring" }),
        },

        --- NQ guarantee (Bonecrafter's Ring)
        nq = {
            description = 'Bonecraft NQ',
            aliases     = { 'nq' },
            gear        = set_with({ right_ring = "Bonecrafter's Ring" }),
        },

        --- Success rate (Patissiere's Ring)
        success = {
            description = 'Bonecraft Success',
            aliases     = { 'success' },
            gear        = set_with({ right_ring = "Patissiere's Ring" }),
        },

        ---  ── HQ + sub-craft skill (Confectioner's Ring + sub torque) ───────

        --- Woodworking sub-craft (Carver's Torque)
        wood = {
            description = 'Bonecraft HQ - Wood sub',
            aliases     = { 'wood', 'woodworking', 'carver' },
            gear        = set_with({
                neck       = "Carver's Torque",
                right_ring = "Confectioner's Ring",
            }),
        },

        --- Smithing sub-craft (Smithy's Torque)
        smith = {
            description = 'Bonecraft HQ - Smith sub',
            aliases     = { 'smith', 'smithing', 'blacksmith' },
            gear        = set_with({
                neck       = "Smithy's Torque",
                right_ring = "Confectioner's Ring",
            }),
        },

        --- Leathercraft sub-craft (Tanner's Torque)
        leather = {
            description = 'Bonecraft HQ - Leather sub',
            aliases     = { 'leather', 'leathercraft', 'tanner' },
            gear        = set_with({
                neck       = "Tanner's Torque",
                right_ring = "Confectioner's Ring",
            }),
        },
    },
}
