---============================================================================
--- FFXI GearSwap Test Framework
---============================================================================
--- Lightweight unit testing framework for GearSwap modules validation.
--- Provides assertion methods, test runners, and result reporting for
--- ensuring code reliability and preventing regressions.
---
--- @file tests/test_framework.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
--- @requires utils/logger
---
--- Usage:
---   local test = require('tests/test_framework')
---
---   test.suite('Module Name', function()
---       test.case('should validate parameters', function()
---           test.assert_equals(2 + 2, 4, 'Basic math failed')
---           test.assert_not_nil(value, 'Value should exist')
---       end)
---   end)
---
---   test.run_all()
---============================================================================

local TestFramework = {}

-- Test statistics
TestFramework.stats = {
    total = 0,
    passed = 0,
    failed = 0,
    errors = {}
}

-- Test suites storage
TestFramework.suites = {}

-- Color codes for output
local COLORS = {
    GREEN = 158,
    RED = 167,
    YELLOW = 057,
    GRAY = 160
}

---============================================================================
--- ASSERTION METHODS
---============================================================================

--- Assert that a condition is true
--- @param condition boolean The condition to test
--- @param message string Optional failure message
function TestFramework.assert_true(condition, message)
    if not condition then
        error(message or "Expected true, got false", 2)
    end
end

--- Assert that a condition is false
--- @param condition boolean The condition to test
--- @param message string Optional failure message
function TestFramework.assert_false(condition, message)
    if condition then
        error(message or "Expected false, got true", 2)
    end
end

--- Assert that two values are equal
--- @param actual any The actual value
--- @param expected any The expected value
--- @param message string Optional failure message
function TestFramework.assert_equals(actual, expected, message)
    if actual ~= expected then
        error(string.format(
            "%s\nExpected: %s\nActual: %s",
            message or "Values not equal",
            tostring(expected),
            tostring(actual)
        ), 2)
    end
end

--- Assert that two values are not equal
--- @param actual any The actual value
--- @param unexpected any The value that should not match
--- @param message string Optional failure message
function TestFramework.assert_not_equals(actual, unexpected, message)
    if actual == unexpected then
        error(string.format(
            "%s\nValues should not be equal: %s",
            message or "Values should not be equal",
            tostring(actual)
        ), 2)
    end
end

--- Assert that a value is nil
--- @param value any The value to test
--- @param message string Optional failure message
function TestFramework.assert_nil(value, message)
    if value ~= nil then
        error(string.format(
            "%s\nExpected nil, got: %s",
            message or "Value should be nil",
            tostring(value)
        ), 2)
    end
end

--- Assert that a value is not nil
--- @param value any The value to test
--- @param message string Optional failure message
function TestFramework.assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil", 2)
    end
end

--- Assert that a value is of a specific type
--- @param value any The value to test
--- @param expected_type string The expected type
--- @param message string Optional failure message
function TestFramework.assert_type(value, expected_type, message)
    local actual_type = type(value)
    if actual_type ~= expected_type then
        error(string.format(
            "%s\nExpected type: %s\nActual type: %s",
            message or "Type mismatch",
            expected_type,
            actual_type
        ), 2)
    end
end

--- Assert that a function throws an error
--- @param func function The function to test
--- @param message string Optional failure message
function TestFramework.assert_error(func, message)
    local success = pcall(func)
    if success then
        error(message or "Expected function to throw error", 2)
    end
end

--- Assert that a function does not throw an error
--- @param func function The function to test
--- @param message string Optional failure message
function TestFramework.assert_no_error(func, message)
    local success, err = pcall(func)
    if not success then
        error(string.format(
            "%s\nUnexpected error: %s",
            message or "Function should not throw error",
            tostring(err)
        ), 2)
    end
end

---============================================================================
--- TEST SUITE MANAGEMENT
---============================================================================

--- Define a test suite
--- @param name string The name of the test suite
--- @param tests function The function containing test cases
function TestFramework.suite(name, tests)
    TestFramework.suites[name] = {
        name = name,
        cases = {},
        current_case = nil
    }

    -- Temporarily set current suite for case registration
    TestFramework.current_suite = TestFramework.suites[name]

    -- Execute the tests function to register cases
    local success, err = pcall(tests)
    if not success then
        windower.add_to_chat(COLORS.RED, string.format("Failed to register suite '%s': %s", name, err))
    end

    TestFramework.current_suite = nil
end

--- Define a test case within a suite
--- @param description string The test case description
--- @param test function The test function
function TestFramework.case(description, test)
    if not TestFramework.current_suite then
        error("Test case must be defined within a suite", 2)
    end

    table.insert(TestFramework.current_suite.cases, {
        description = description,
        test = test
    })
end

---============================================================================
--- TEST EXECUTION
---============================================================================

--- Run a single test case
--- @param suite table The test suite
--- @param test_case table The test case to run
--- @return boolean success Whether the test passed
local function run_test_case(suite, test_case)
    TestFramework.stats.total = TestFramework.stats.total + 1

    local success, err = pcall(test_case.test)

    if success then
        TestFramework.stats.passed = TestFramework.stats.passed + 1
        windower.add_to_chat(COLORS.GREEN, string.format("    ✓ %s", test_case.description))
        return true
    else
        TestFramework.stats.failed = TestFramework.stats.failed + 1
        windower.add_to_chat(COLORS.RED, string.format("    ✗ %s", test_case.description))
        windower.add_to_chat(COLORS.GRAY, string.format("      %s", err))

        table.insert(TestFramework.stats.errors, {
            suite = suite.name,
            case = test_case.description,
            error = err
        })
        return false
    end
end

--- Run all test suites
function TestFramework.run_all()
    -- Reset statistics
    TestFramework.stats = {
        total = 0,
        passed = 0,
        failed = 0,
        errors = {}
    }

    windower.add_to_chat(COLORS.YELLOW, "========================================")
    windower.add_to_chat(COLORS.YELLOW, "Running GearSwap Tests")
    windower.add_to_chat(COLORS.YELLOW, "========================================")

    for suite_name, suite in pairs(TestFramework.suites) do
        windower.add_to_chat(COLORS.GRAY, string.format("\n%s:", suite_name))

        for _, test_case in ipairs(suite.cases) do
            run_test_case(suite, test_case)
        end
    end

    -- Display summary
    windower.add_to_chat(COLORS.YELLOW, "\n========================================")
    windower.add_to_chat(COLORS.YELLOW, "Test Summary")
    windower.add_to_chat(COLORS.YELLOW, "========================================")

    local color = TestFramework.stats.failed > 0 and COLORS.RED or COLORS.GREEN
    windower.add_to_chat(color, string.format(
        "Total: %d | Passed: %d | Failed: %d",
        TestFramework.stats.total,
        TestFramework.stats.passed,
        TestFramework.stats.failed
    ))

    if TestFramework.stats.failed > 0 then
        windower.add_to_chat(COLORS.RED, "\nFailed tests:")
        for _, error_info in ipairs(TestFramework.stats.errors) do
            windower.add_to_chat(COLORS.RED, string.format(
                "  %s > %s",
                error_info.suite,
                error_info.case
            ))
        end
    end

    return TestFramework.stats.failed == 0
end

--- Run a specific test suite
--- @param suite_name string The name of the suite to run
function TestFramework.run_suite(suite_name)
    local suite = TestFramework.suites[suite_name]
    if not suite then
        windower.add_to_chat(COLORS.RED, string.format("Suite '%s' not found", suite_name))
        return false
    end

    windower.add_to_chat(COLORS.YELLOW, string.format("Running suite: %s", suite_name))

    for _, test_case in ipairs(suite.cases) do
        run_test_case(suite, test_case)
    end

    return true
end

return TestFramework
