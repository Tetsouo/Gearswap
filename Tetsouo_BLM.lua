-------------------------------------------------------------------------------------------------------------
-- ***********************************************************
-- * Fonction Initial qui définie les sets et les variables. *
-- ***********************************************************

-- IMPORTANT: Soyez sur d'avoir le fichier Mote-Include.lua (Et les fichiers suplémentaires) qui vont avec.
-- Mote-Globals.lua
-- Mote-Mappings.lua
-- Mote-SelfCommands.lua
-- Mote-TreasureHunter.lua
-- Mote-Utility.lua
-- ils sont normalement dans le répertoire => Windower\addons\GearSwap\libs

function get_sets()
    -- Chargement et initialisation des fichiers inclus.
    mote_include_version = 2
    include('Mote-Include.lua')
    include('organizer-lib')
end
-------------------------------------------------------------------------------------------------------------
-- ********************************************************************
-- * Configuration des variables et des dépendences de l'utilisateur. *
-- ********************************************************************
function job_setup()
    include('0_AutoMove.lua')
end
-------------------------------------------------------------------------------------------------------------

-- **************************************************
-- * Configuration des variables de l'utilisateurs. *
-- **************************************************
function user_setup()
    state.CastingMode:options('MagicBurst', 'Normal') --gs c cycle CastmingMode
    select_default_macro_book()
end

-- ****************************
-- * Initialisation des Sets. *
-- ****************************
function init_gear_sets()
    include('BlmSet.lua')
end

include('BlmFunction.lua')

-- *************************************************************************************
-- * Selectionne le livre de Macro par defaut quand on choisi sont job ou sont subJob. *
-- *************************************************************************************
function select_default_macro_book()
    if player.sub_job == 'WHM' then
        set_macro_page(1, 9)
        send_command('wait 25;input /lockstyleset 14')
    elseif player.sub_job == 'RDM' then
        set_macro_page(1, 10)
        send_command('wait 25;input /lockstyleset 14')
    elseif player.sub_job == 'SCH' then
        set_macro_page(1, 11)
        send_command('wait 25;input /lockstyleset 14')
    else
        set_macro_page(1, 9)
        send_command('wait 25;input /lockstyleset 14')
    end
end
