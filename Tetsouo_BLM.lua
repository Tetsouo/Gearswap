--============================================================--
--=                      BLACK MAGE                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-13                  =--
--============================================================--

-- Sets up the necessary libraries and files for Gearswap.
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua') -- Includes the Mote-Include.lua library (Version 2)
    include('/Misc/0_AutoMove.lua') -- Includes the AutoMove.lua file for movement speed gear management
    include('/Misc/SharedFunctions.lua') -- Includes the SharedFunctions.lua file for shared functions
    include('/BLM/BLM_FUNCTION.lua') -- Includes the PLD_FUNCTION.lua file for advanced functions specific to Paladin
end
-------------------------------------------------------------------------------------------------------------

-- Handles user-specific configuration and setup.
function user_setup()
    -- Hybrid mode options: 'MagicBurst', 'Normal'
    state.CastingMode:options('MagicBurst', 'Normal') -- Command to change Casting mode: /console gs c cycle CastmingMode
    select_default_macro_book()
    -- Binds F9 to cycle through Casting Mode
    send_command('bind F9 gs c cycle CastmingMode')
end

-- Handles the unload event when changing job or reloading the file.
function file_unload()
    -- Unbinds the keys associated with the states.
    send_command('unbind F9')
end

-- Loads the gear sets from the PLD_SET.lua file.
function init_gear_sets()
    include('/BLM/BLM_SET.lua')
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

-- Handles actions to perform after the casting of a spell or ability.
-- Parameters:
--   spell (table): The spell that was cast
--   action (table): The action that was performed
--   spellMap (table): The spell mapping table
--   eventArgs (table): Additional event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    handleSpellAftercast(spell, eventArgs) -- Perform actions after the spell is cast
end

-- Sets the default macro book based on the player's sub job.
function select_default_macro_book()
    -- If sub job is WHM
    if player.sub_job == 'WHM' then
        set_macro_page(1, 9)
        send_command('wait 25;input /lockstyleset 14')
    -- If sub job is RDM
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 10)
        send_command('wait 25;input /lockstyleset 14')
    -- If sub job is SCH
    elseif player.sub_job == 'SCH' then
        set_macro_page(1, 11)
        send_command('wait 25;input /lockstyleset 14')
    -- For other sub jobs
    else
        set_macro_page(1, 9)
        send_command('wait 25;input /lockstyleset 14')
    end
end