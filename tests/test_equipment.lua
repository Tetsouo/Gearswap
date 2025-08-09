---============================================================================
--- Unit Tests for Equipment Module
---============================================================================
--- Comprehensive test suite for the equipment management module ensuring
--- all equipment functions work correctly with proper error handling.
---
--- @file tests/test_equipment.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
---============================================================================

local test = require('tests/test_framework')
local EquipmentUtils = require('core/equipment')

test.suite('EquipmentUtils', function()
    -- Test create_equipment
    test.case('create_equipment should create valid equipment object', function()
        local equip = EquipmentUtils.create_equipment('Excalibur')
        test.assert_not_nil(equip)
        test.assert_equals(equip.name, 'Excalibur')
        test.assert_nil(equip.priority)
        test.assert_nil(equip.bag)
        test.assert_nil(equip.augments)
    end)

    test.case('create_equipment should handle all parameters', function()
        local augments = { 'DMG+50', 'Accuracy+30' }
        local equip = EquipmentUtils.create_equipment('Excalibur', 10, 'inventory', augments)

        test.assert_equals(equip.name, 'Excalibur')
        test.assert_equals(equip.priority, 10)
        test.assert_equals(equip.bag, 'inventory')
        test.assert_equals(equip.augments, augments)
    end)

    test.case('create_equipment should reject invalid name', function()
        test.assert_nil(EquipmentUtils.create_equipment(nil))
        test.assert_nil(EquipmentUtils.create_equipment(123))
        test.assert_nil(EquipmentUtils.create_equipment({}))
    end)

    test.case('create_equipment should validate priority type', function()
        test.assert_nil(EquipmentUtils.create_equipment('Item', 'invalid'))
        test.assert_nil(EquipmentUtils.create_equipment('Item', {}))
    end)

    test.case('create_equipment should validate bag type', function()
        test.assert_nil(EquipmentUtils.create_equipment('Item', nil, 123))
        test.assert_nil(EquipmentUtils.create_equipment('Item', nil, {}))
    end)

    test.case('create_equipment should validate augments type', function()
        test.assert_nil(EquipmentUtils.create_equipment('Item', nil, nil, 'invalid'))
        test.assert_nil(EquipmentUtils.create_equipment('Item', nil, nil, 123))
    end)

    -- Test validate_equipment_set
    if EquipmentUtils.validate_equipment_set then
        test.case('validate_equipment_set should validate correct sets', function()
            local set = {
                main = EquipmentUtils.create_equipment('Excalibur'),
                sub = EquipmentUtils.create_equipment('Aegis'),
                head = EquipmentUtils.create_equipment('Valor Coronet')
            }

            local valid, errors = EquipmentUtils.validate_equipment_set('TestSet', set)
            test.assert_true(valid)
            test.assert_equals(#errors, 0)
        end)

        test.case('validate_equipment_set should detect invalid equipment', function()
            local set = {
                main = 'InvalidItem', -- Should be equipment object
                sub = 123,            -- Invalid type
                head = nil            -- Nil is okay
            }

            local valid, errors = EquipmentUtils.validate_equipment_set('TestSet', set)
            test.assert_false(valid)
            test.assert_true(#errors > 0)
        end)
    end

    -- Test safe_equip
    if EquipmentUtils.safe_equip then
        test.case('safe_equip should handle valid equipment set', function()
            local set = {
                main = EquipmentUtils.create_equipment('Excalibur'),
                sub = EquipmentUtils.create_equipment('Aegis')
            }

            test.assert_no_error(function()
                EquipmentUtils.safe_equip(set, 'TestAction')
            end)
        end)

        test.case('safe_equip should handle nil set gracefully', function()
            test.assert_no_error(function()
                EquipmentUtils.safe_equip(nil, 'TestAction')
            end)
        end)

        test.case('safe_equip should handle empty set', function()
            test.assert_no_error(function()
                EquipmentUtils.safe_equip({}, 'TestAction')
            end)
        end)
    end

    -- Test customize_set
    if EquipmentUtils.customize_set then
        test.case('customize_set should merge sets correctly', function()
            local base_set = {
                main = EquipmentUtils.create_equipment('Excalibur'),
                head = EquipmentUtils.create_equipment('Valor Coronet')
            }

            local custom_set = {
                sub = EquipmentUtils.create_equipment('Aegis'),
                head = EquipmentUtils.create_equipment('Kaiser Head') -- Override
            }

            local result = EquipmentUtils.customize_set({}, base_set, custom_set)

            test.assert_equals(result.main.name, 'Excalibur')
            test.assert_equals(result.sub.name, 'Aegis')
            test.assert_equals(result.head.name, 'Kaiser Head') -- Should be overridden
        end)

        test.case('customize_set should handle nil sets', function()
            local base_set = {
                main = EquipmentUtils.create_equipment('Excalibur')
            }

            test.assert_no_error(function()
                local result = EquipmentUtils.customize_set({}, base_set, nil)
                test.assert_not_nil(result)
            end)
        end)
    end

    -- Test check_ws_acc
    if EquipmentUtils.check_ws_acc then
        test.case('check_ws_acc should handle TP thresholds', function()
            -- Mock player TP
            _G.player = { tp = 1500 }

            local set = {
                left_ear = EquipmentUtils.create_equipment('Normal Earring'),
                right_ear = EquipmentUtils.create_equipment('Normal Earring')
            }

            -- Test with low TP (should add Moonshade)
            _G.player.tp = 1000
            local result = EquipmentUtils.check_ws_acc(set, {})
            test.assert_not_nil(result)

            -- Test with high TP
            _G.player.tp = 3000
            result = EquipmentUtils.check_ws_acc(set, {})
            test.assert_not_nil(result)

            -- Clean up
            _G.player = nil
        end)
    end

    -- Test edge cases
    test.case('equipment functions should handle circular references', function()
        local set1 = {}
        local set2 = { parent = set1 }
        set1.child = set2 -- Circular reference

        test.assert_no_error(function()
            -- Should not crash with circular references
            if EquipmentUtils.customize_set then
                EquipmentUtils.customize_set({}, set1, set2)
            end
        end)
    end)
end)
