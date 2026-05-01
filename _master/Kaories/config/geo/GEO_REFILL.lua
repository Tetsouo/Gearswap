---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Refill Config (Kaories)
---   See Tetsouo/config/war/WAR_REFILL.lua for the format reference.
---  ═══════════════════════════════════════════════════════════════════════════
---   Same kit as BLM: no Powder/Oil, with Echo Drops + Vile Elixir + INT food.

local M = {}

M.store_bag = 'case'

M.default = {
    { name = 'Panacea',                                    target = 12 },
    { name = 'Antacid',                                    target = 12 },
    { name = 'Holy Water',                                 target = 12 },
    { name = 'Remedy',                                     target = 12 },
    { name = 'Echo Drops',                                 target = 12 },
    { name = 'Vile Elixir',                                target = 1  },
    { name = 'Vile Elixir +1',                             target = 1  },
    { name = 'Tropical Crepe',                             target = 12 },
}

return M
