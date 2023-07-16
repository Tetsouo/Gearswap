--============================================================--
--=                        WARRIOR                           =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-16                  =--
--============================================================--

-- Sets up the necessary libraries and files for Gearswap.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Includes the Mote-Include.lua library (Version 2).
    include('0_AutoMove.lua') -- Includes the AutoMove.lua file for movement speed gear management.
    include('SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions.
    include('WAR_FUNCTION.lua') -- Includes the WAR_FUNCTION.lua file for advanced functions specific to Warrior.
end

-- Handles user-specific configuration and setup.
function user_setup()
    -- Hybrid mode options: 'PDT' (Defense physical), 'Normal (Damage Dealer)'
    state.HybridMode:options('PDT', 'Normal')
    -- Main weapon choice: 'Lycurgos', 'Naegling', 'Shining', 'Loxotic'
    state.WeaponSet = M {['description'] = 'Main Weapon', 'Lycurgos', 'Shining', 'Naegling', 'Loxotic'} --gs c cycle WeaponSet
    -- Sub weapon choice: 'Utu Grip', 'Blurred Shield +1'
    --[[ state.SubSet = M {['description'] = 'Sub Weapon', 'Utu', 'Blurred'} --gs c cycle SubSet ]]
    -- Calls the function to select the default macro book
    select_default_macro_book()
    -- Binds F9 to cycle through hybrid modes
    send_command('bind F9 gs c cycle HybridMode')
    -- Binds F10 to cycle through main weapon sets
    send_command('bind F10 gs c cycle WeaponSet')
    -- Binds F11 to cycle through sub weapon sets
    send_command('bind F11 gs c cycle SubSet')

    -- OTHER SELF COMMAND Parameters to put in your in-game Macro or bind a key with it.
    --===================================================================================
        -- [gs c Berserk] Cast job ability with logic from WAR_FUNCTION.lua:
            -- state.HybridMode: Normal
            -- Berserk
            -- Aggressor
            -- Retaliation
            -- Restraint
            -- Warcry or Blood Rage
    --===================================================================================
        -- [gs c Defender] Cast job ability with logic from WAR_FUNCTION.lua:
            -- state.HybridMode: PDT
            -- Defender
            -- Aggressor
            -- Retaliation
            -- Restraint
            -- Warcry or Blood Rage
    --===================================================================================
        -- [gs c ThirdEye] Cast Third Eye with logic from WAR_FUNCTION.lua:
            -- with state.HybridMode: Normal
                -- Hasso + Third Eye
            -- with state.HybridMode: PDT
                -- Seigan + Third Eye
end

-- Handles the unload event when changing job or reloading the file.
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('unbind F9')
    send_command('unbind F10')
    send_command('unbind F11')
end

-- Loads the gear sets from the PLD_SET.lua file.
function init_gear_sets()
    include('WAR_SET.lua')
end

-- Handles actions and checks to perform before casting a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_precast(spell, action, spellMap, eventArgs)
    if incapacitated(spell, eventArgs, true) then
        -- Spell cannot be cast due to incapacitation, no further actions needed
    else
        checkDisplayCooldown(spell, eventArgs) -- Handle recast cooldown and display messages
    end
end

-- Handles actions to perform during the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell being cast
--   action (table): The action being performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    incapacitated(spell, eventArgs) -- Check for incapacitated state
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    -- If sub job is DRG
    if player.sub_job == 'DRG' then
        set_macro_page(1, 25)
        send_command('wait 20; input /lockstyleset 13')
        -- If sub job is SAM
    elseif player.sub_job == 'SAM' then
        set_macro_page(1, 27)
        send_command('wait 20; input /lockstyleset 13')
    end
end