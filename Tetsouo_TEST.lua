---============================================================================
--- FFXI GearSwap Test Job - Fichier de test autonome
---============================================================================
--- Fichier special pour executer les tests des modules
--- Chargez ce "faux job" pour lancer les tests
---
--- Usage: //gs load Tetsouo_TEST
---============================================================================

function get_sets()
    -- Message de demarrage
    add_to_chat(050, "========================================")
    add_to_chat(050, "LANCEMENT DES TESTS GEARSWAP")
    add_to_chat(050, "========================================")

    -- Test des modules principaux
    local tests_passed = 0
    local tests_failed = 0

    -- Test 1: Config
    add_to_chat(160, "\nTest: Module Config")
    local success, config = pcall(function()
        return dofile(windower.addon_path .. 'data/Tetsouo/config/config.lua')
    end)

    if success and config then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Config charge avec succes")

        if type(config.get_main_player) == 'function' then
            local player = config.get_main_player()
            add_to_chat(158, "    Joueur principal: " .. tostring(player))
        end
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Config")
    end

    -- Test 2: Logger (avec require au lieu de dofile)
    add_to_chat(160, "\nTest: Module Logger")
    local logger
    success, logger = pcall(require, 'utils/logger')

    if success and logger then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Logger charge avec succes")
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Logger")
        add_to_chat(167, "    " .. tostring(logger))
    end

    -- Test 3: Validation
    add_to_chat(160, "\nTest: Module Validation")
    local validation
    success, validation = pcall(require, 'utils/validation')

    if success and validation then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Validation charge avec succes")

        -- Test de fonction
        if validation.validate_not_nil then
            local result = validation.validate_not_nil("test", "param")
            if result == true then
                add_to_chat(158, "    Fonction validate_not_nil OK")
            end
        end
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Validation")
        add_to_chat(167, "    " .. tostring(validation))
    end

    -- Test 4: Equipment
    add_to_chat(160, "\nTest: Module Equipment")
    local equipment
    success, equipment = pcall(require, 'core/equipment')

    if success and equipment then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Equipment charge avec succes")

        -- Test creation equipment
        if equipment.create_equipment then
            local item = equipment.create_equipment("Excalibur")
            if item and item.name == "Excalibur" then
                add_to_chat(158, "    Fonction create_equipment OK")
            end
        end
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Equipment")
        add_to_chat(167, "    " .. tostring(equipment))
    end

    -- Test 5: Messages
    add_to_chat(160, "\nTest: Module Messages")
    local messages
    success, messages = pcall(require, 'utils/messages')

    if success and messages then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Messages charge avec succes")

        -- Test format recast
        if messages.format_recast_duration then
            local result = messages.format_recast_duration(90)
            if result == "01:30 min" then
                add_to_chat(158, "    Fonction format_recast_duration OK")
            end
        end
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Messages")
        add_to_chat(167, "    " .. tostring(messages))
    end

    -- Test 6: Helpers
    add_to_chat(160, "\nTest: Module Helpers")
    local helpers
    success, helpers = pcall(require, 'utils/helpers')

    if success and helpers then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Helpers charge avec succes")
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Helpers")
        add_to_chat(167, "    " .. tostring(helpers))
    end

    -- Test 7: Spells
    add_to_chat(160, "\nTest: Module Spells")
    local spells
    success, spells = pcall(require, 'core/spells')

    if success and spells then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Spells charge avec succes")
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Spells")
        add_to_chat(167, "    " .. tostring(spells))
    end

    -- Test 8: State
    add_to_chat(160, "\nTest: Module State")
    local state_utils
    success, state_utils = pcall(require, 'core/state')

    if success and state_utils then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] State charge avec succes")
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement State")
        add_to_chat(167, "    " .. tostring(state_utils))
    end

    -- Test 9: Buffs
    add_to_chat(160, "\nTest: Module Buffs")
    local buffs
    success, buffs = pcall(require, 'core/buffs')

    if success and buffs then
        tests_passed = tests_passed + 1
        add_to_chat(158, "  [OK] Buffs charge avec succes")
    else
        tests_failed = tests_failed + 1
        add_to_chat(167, "  [ERREUR] Erreur chargement Buffs")
        add_to_chat(167, "    " .. tostring(buffs))
    end

    -- Resume
    add_to_chat(050, "\n========================================")
    add_to_chat(050, "RESUME DES TESTS")
    add_to_chat(050, "========================================")
    add_to_chat(158, string.format("Tests reussis: %d", tests_passed))
    add_to_chat(167, string.format("Tests echoues: %d", tests_failed))

    if tests_failed == 0 then
        add_to_chat(158, "\n[SUCCES] TOUS LES MODULES FONCTIONNENT")
    else
        add_to_chat(167, "\n[ECHEC] CERTAINS MODULES ONT DES PROBLEMES")
        add_to_chat(057, "Verifiez les messages d'erreur ci-dessus")
    end

    add_to_chat(057, "\nPour revenir a votre job: //gs load Tetsouo_WAR")

    -- Sets vides pour eviter les erreurs
    sets.precast = {}
    sets.midcast = {}
    sets.aftercast = {}
    sets.idle = {}
    sets.engaged = {}
end

function job_setup()
    -- Fonction vide requise
end

function user_setup()
    -- Fonction vide requise
end

function init_gear_sets()
    -- Fonction vide requise
end
