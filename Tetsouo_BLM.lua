--============================================================--
--=                      BLACK MAGE                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- Initialize libraries and files for Gearswap.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')          -- Utility functions and structures for GearSwap
    include('/Misc/0_AutoMove.lua')      -- Automatic movement speed gear swapping
    include('/Misc/SharedFunctions.lua') -- Functions shared across multiple jobs
    include('/BLM/BLM_SET.lua')          -- Gear sets specific to Black Mage
    include('/BLM/BLM_FUNCTION.lua')     -- Advanced functions specific to Black Mage
end

-------------------------------------------------------------------------------------------------------------

-- Handles user-specific configuration and setup.
function job_setup()
    -- Hybrid mode options: 'MagicBurst', 'Normal'
    -- Command to change Casting mode: /console gs c cycle CastingMode
    state.CastingMode:options('MagicBurst', 'Normal')
    state.Xp = M { ['description'] = 'XP', 'False', 'True' }
    -- Command to change MainLight mode: /console gs c cycle mainLightSpell
    state.MainLightSpell = M('Fire', 'Thunder', 'Aero')
    -- Command to change SubLight mode: /console gs c cycle subLightSpell
    state.SubLightSpell = M('Thunder', 'Fire', 'Aero')
    -- Command to change MainDark mode: /console gs c cycle mainDarkSpell
    state.MainDarkSpell = M('Stone', 'Blizzard', 'Water')
    -- Command to change SubDark mode: /console gs c cycle subDarkSpell
    state.SubDarkSpell = M('Blizzard', 'Stone', 'Water')
    -- Command to change TierSpell mode: /console gs c cycle tierSpell
    state.TierSpell = M('VI', 'V', 'IV', 'III', 'II', '')
    -- Command to change Aja mode: /console gs c cycle Aja
    state.Aja = M('Firaja', 'Stoneja', 'Blizzaja', 'Aeroja', 'Thundaja', 'Waterja')
    -- Command to change Storm mode: /console gs c cycle Storm
    state.Storm = M('FireStorm', 'Sandstorm', 'Thunderstorm', 'HailStorm', 'Rainstorm', 'Windstorm', 'Voidstorm',
        'Aurorastorm')
    Manawall = buffactive['Mana Wall'] or false

    --------------------------------------------------------------------------------------------
    --                              Alt_Player_State
    --------------------------------------------------------------------------------------------
    -- Command to change MainLight mode: /console gs c cycle AltPlayerLight
    state.altPlayerLight = M('Fire', 'Thunder', 'Aero')
    -- Command to change MainDark mode: /console gs c cycle altPlayerDark
    state.altPlayerDark = M('Stone', 'Blizzard', 'Water')
    -- Command to change TierSpell mode: /console gs c cycle altPlayerTier
    state.altPlayerTier = M('V', 'IV', 'III', 'II', '')
    -- Command to change Aja mode: /console gs c cycle altPlayera
    state.altPlayera = M('Fira', 'Stonera', 'Blizzara', 'Aera', 'Thundara', 'Watera')
    -- Command to change Aja mode: /console gs c cycle altPlayerGeo
    state.altPlayerGeo = M('Geo-Malaise', 'Geo-Refresh', 'Geo-Languor')
    -- Command to change Aja mode: /console gs c cycle altPlayerGeo
    state.altPlayerIndi = M('Indi-Acumen', 'Indi-Refresh',
        'Indi-Haste')
    -- Command to change Entrust Indi mode: /console gs c cycle altPlayerEntrust
    state.altPlayerEntrust = M('Indi-INT', 'Indi-Refresh')
    --------------------------------------------------------------------------------------------
    -- Binds F9 to cycle through Casting Mode
    send_command('bind F9 gs c cycle CastingMode')
end

function user_setup()
    if (player.main_job == 'SCH' or (player.sub_job == 'SCH' and player.sub_job_level > 0)) then
        send_command('lua l sch-hud')
    end
    select_default_macro_book()     -- Selects the default macro book based on sub-job
end

-- Handles the unload event when changing job or reloading the file.
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('lua unload sch-hud')
    send_command('unbind F9')
end

-- Loads the gear sets from the PLD_SET.lua file.
function init_gear_sets()

end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- If the player is currently performing an action, immediately return and do nothing else.
    if midaction() then
        return
    end

    handle_spell(spell, eventArgs, auto_abilities) -- Handle the spell casting
    checkDisplayCooldown(spell, eventArgs)         -- Check and display the recast cooldown
    refine_various_spells(spell, eventArgs, spellCorrespondence)
    checkArts(spell, eventArgs)
end

-- Handles actions to perform during the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    SaveMP()
end

-- Handles actions to perform after the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
lastSpell = nil

function job_aftercast(spell, action, spellMap, eventArgs)
    if lastSpell == spell.name then
        -- Ignore this call, it's a duplicate
        return
    end

    lastSpell = spell.name
    handleSpellAftercast(spell, eventArgs)
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    send_command('lua unload dressup')
    -- If sub job is SCH
    if player.sub_job == 'SCH' then
        set_macro_page(10, 14)
        send_command('wait 15;input /lockstyleset 6; wait 5; lua load dressup')
        -- For other sub jobs
    else
        set_macro_page(10, 14)
    end
    send_command('wait 15; lua load dressup')
end
