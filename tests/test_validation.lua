---============================================================================
--- Unit Tests for Validation Module
---============================================================================
--- Comprehensive test suite for the validation utility module ensuring
--- all validation functions work correctly and handle edge cases properly.
---
--- @file tests/test_validation.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
---============================================================================

local test = require('tests/test_framework')
local ValidationUtils = require('utils/validation')

test.suite('ValidationUtils', function()
    -- Test validate_not_nil
    test.case('validate_not_nil should return true for non-nil values', function()
        test.assert_true(ValidationUtils.validate_not_nil("test", "param"))
        test.assert_true(ValidationUtils.validate_not_nil(123, "param"))
        test.assert_true(ValidationUtils.validate_not_nil({}, "param"))
        test.assert_true(ValidationUtils.validate_not_nil(false, "param"))
        test.assert_true(ValidationUtils.validate_not_nil(0, "param"))
    end)

    test.case('validate_not_nil should return false for nil values', function()
        test.assert_false(ValidationUtils.validate_not_nil(nil, "param"))
    end)

    -- Test validate_type
    test.case('validate_type should validate correct types', function()
        test.assert_true(ValidationUtils.validate_type("test", "string", "param"))
        test.assert_true(ValidationUtils.validate_type(123, "number", "param"))
        test.assert_true(ValidationUtils.validate_type({}, "table", "param"))
        test.assert_true(ValidationUtils.validate_type(true, "boolean", "param"))
        test.assert_true(ValidationUtils.validate_type(function() end, "function", "param"))
    end)

    test.case('validate_type should return false for incorrect types', function()
        test.assert_false(ValidationUtils.validate_type("test", "number", "param"))
        test.assert_false(ValidationUtils.validate_type(123, "string", "param"))
        test.assert_false(ValidationUtils.validate_type({}, "string", "param"))
    end)

    -- Test validate_string_not_empty
    test.case('validate_string_not_empty should accept non-empty strings', function()
        test.assert_true(ValidationUtils.validate_string_not_empty("test", "param"))
        test.assert_true(ValidationUtils.validate_string_not_empty(" ", "param")) -- Space is not empty
        test.assert_true(ValidationUtils.validate_string_not_empty("123", "param"))
    end)

    test.case('validate_string_not_empty should reject empty strings', function()
        test.assert_false(ValidationUtils.validate_string_not_empty("", "param"))
    end)

    test.case('validate_string_not_empty should reject non-strings', function()
        test.assert_false(ValidationUtils.validate_string_not_empty(123, "param"))
        test.assert_false(ValidationUtils.validate_string_not_empty(nil, "param"))
        test.assert_false(ValidationUtils.validate_string_not_empty({}, "param"))
    end)

    -- Test validate_number_range
    test.case('validate_number_range should accept numbers in range', function()
        test.assert_true(ValidationUtils.validate_number_range(5, 1, 10, "param"))
        test.assert_true(ValidationUtils.validate_number_range(1, 1, 10, "param"))  -- Min boundary
        test.assert_true(ValidationUtils.validate_number_range(10, 1, 10, "param")) -- Max boundary
        test.assert_true(ValidationUtils.validate_number_range(0, -5, 5, "param"))
        test.assert_true(ValidationUtils.validate_number_range(-3, -10, 0, "param"))
    end)

    test.case('validate_number_range should reject numbers outside range', function()
        test.assert_false(ValidationUtils.validate_number_range(0, 1, 10, "param"))
        test.assert_false(ValidationUtils.validate_number_range(11, 1, 10, "param"))
        test.assert_false(ValidationUtils.validate_number_range(-1, 0, 10, "param"))
    end)

    test.case('validate_number_range should reject non-numbers', function()
        test.assert_false(ValidationUtils.validate_number_range("5", 1, 10, "param"))
        test.assert_false(ValidationUtils.validate_number_range(nil, 1, 10, "param"))
        test.assert_false(ValidationUtils.validate_number_range({}, 1, 10, "param"))
    end)

    -- Test validate_table_not_empty (if it exists)
    if ValidationUtils.validate_table_not_empty then
        test.case('validate_table_not_empty should accept non-empty tables', function()
            test.assert_true(ValidationUtils.validate_table_not_empty({ 1 }, "param"))
            test.assert_true(ValidationUtils.validate_table_not_empty({ a = 1 }, "param"))
            test.assert_true(ValidationUtils.validate_table_not_empty({ 1, 2, 3 }, "param"))
        end)

        test.case('validate_table_not_empty should reject empty tables', function()
            test.assert_false(ValidationUtils.validate_table_not_empty({}, "param"))
        end)
    end

    -- Test validate_player_name (if it exists)
    if ValidationUtils.validate_player_name then
        test.case('validate_player_name should accept valid player names', function()
            test.assert_true(ValidationUtils.validate_player_name("Tetsouo"))
            test.assert_true(ValidationUtils.validate_player_name("Player"))
            test.assert_true(ValidationUtils.validate_player_name("A")) -- Single char
        end)

        test.case('validate_player_name should reject invalid player names', function()
            test.assert_false(ValidationUtils.validate_player_name(""))
            test.assert_false(ValidationUtils.validate_player_name(nil))
            test.assert_false(ValidationUtils.validate_player_name(123))
            test.assert_false(ValidationUtils.validate_player_name("VeryLongPlayerNameThatExceedsLimit"))
        end)
    end

    -- Test edge cases
    test.case('validation functions should handle nil parameter names gracefully', function()
        -- Should not crash when parameter name is nil
        test.assert_no_error(function()
            ValidationUtils.validate_not_nil("test", nil)
        end)

        test.assert_no_error(function()
            ValidationUtils.validate_type("test", "string", nil)
        end)
    end)
end)
