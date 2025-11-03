-- Minimal RUN States for testing
local RUNStates = {}

function RUNStates.configure()
    -- Configure HybridMode (required for idle/engaged sets)
    state.HybridMode:options('PDT', 'Normal')
    state.HybridMode:set('PDT')

    -- MainWeapon state (required by keybinds)
    state.MainWeapon = M{['description']='Main Weapon', 'Sword1', 'Sword2'}

    -- SubWeapon state (required by keybinds)
    state.SubWeapon = M{['description']='Sub Weapon', 'Shield1', 'Shield2'}

    -- XP Mode (required by keybinds)
    state.Xp = M{['description']='Xp', 'Off', 'On'}

    -- RuneMode (required by keybinds)
    state.RuneMode = M{['description']='Rune Mode', 'Ignis', 'Gelus', 'Flabra', 'Tellus'}

    print('[RUN] States configured (MINIMAL MODE - all keybind states defined)')
end

return RUNStates
