---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Refill Config
---   See WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════
---   BLM typical subjob: /SCH.
---   No Powder/Oil (BLM rarely melees).
---   Echo Drops + Vile Elixir + INT food.
---   Vile Elixir / +1 are Rare/Ex with stack=1 -> separate entries, target=1 each.

local M = {}

M.store_bag = 'case'

M.default = {
    {name = 'Panacea', target = 12},
    {name = 'Antacid', target = 12},
    {name = 'Holy Water', target = 12},
    {name = 'Remedy', target = 12},
    {name = 'Echo Drops', target = 12},
    {name = 'Vile Elixir', target = 1},
    {name = 'Vile Elixir +1', target = 1},
    {name = 'Tropical Crepe', target = 12}
}

return M
