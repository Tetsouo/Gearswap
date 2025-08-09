---============================================================================
--- GearSwap Test Runner
---============================================================================
--- Main test runner script that executes all unit tests for the GearSwap
--- modular system. Run this file to validate all critical modules.
---
--- @file tests/run_tests.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-06
---
--- Usage:
---   From GearSwap console: //gs exec tests/run_tests
---   Or include in a job file for automated testing
---============================================================================

-- Load test framework
local test = require('tests/test_framework')

-- Load and register all test suites
require('tests/test_validation')
require('tests/test_equipment')

-- Additional test suites can be added here as they are created:
-- require('tests/test_spells')
-- require('tests/test_buffs')
-- require('tests/test_messages')
-- require('tests/test_state')

-- Run all registered tests
local function run_all_tests()
    windower.add_to_chat(050, "========================================")
    windower.add_to_chat(050, "Starting GearSwap Module Tests")
    windower.add_to_chat(050, "========================================")

    -- Execute all test suites
    local success = test.run_all()

    if success then
        windower.add_to_chat(158, "\n✓ All tests passed successfully!")
    else
        windower.add_to_chat(167, "\n✗ Some tests failed. Please review the errors above.")
    end

    return success
end

-- Auto-run tests if this file is executed directly
if arg and arg[0] and arg[0]:match("run_tests%.lua$") then
    run_all_tests()
end

-- Export for use in other scripts
return {
    run = run_all_tests,
    framework = test
}
