# GearSwap Module Testing Framework

## Overview

This testing framework provides automated unit testing for the GearSwap modular system. It ensures code reliability, prevents regressions, and validates critical functionality across all modules.

## Quick Start

### Running Tests

There are several ways to execute the tests:

#### Method 1: Through Job Command (Recommended)

If you're using BLM or have added the test command to your job file:

```text
//gs c test
```

#### Method 2: Direct Include

Add this line temporarily to any job file's `get_sets()` function:

```lua
include('test_runner.lua')
```

Then reload the job file:

```text
//gs reload
```

#### Method 3: Manual Include in Console

```text
//lua exec dofile("addons/GearSwap/data/Tetsouo/test_runner.lua")
```

## Test Structure

### Core Test Files

- **`test_framework.lua`**: Main testing framework with assertion methods
- **`test_runner.lua`**: Simplified test runner that executes all tests
- **`run_tests.lua`**: Advanced test runner with full framework features
- **`test_validation.lua`**: Tests for validation utility functions
- **`test_equipment.lua`**: Tests for equipment management module

### Test Coverage

Currently testing the following modules:

- ✅ Config Module (`config/config.lua`)
- ✅ Logger Module (`utils/logger.lua`)
- ✅ Validation Module (`utils/validation.lua`)
- ✅ Equipment Module (`core/equipment.lua`)
- ✅ Messages Module (`utils/messages.lua`)
- ✅ Spells Module (`core/spells.lua`)
- ✅ State Module (`core/state.lua`)
- ✅ Helpers Module (`utils/helpers.lua`)

## Writing New Tests

### Basic Test Structure

```lua
-- Create a new test file: tests/test_mymodule.lua

local test = require('tests/test_framework')
local MyModule = require('path/to/mymodule')

test.suite('MyModule', function()
    
    test.case('should do something correctly', function()
        -- Arrange
        local input = "test"
        
        -- Act
        local result = MyModule.myFunction(input)
        
        -- Assert
        test.assert_equals(result, "expected", "Function should return expected value")
    end)
    
    test.case('should handle errors gracefully', function()
        test.assert_error(function()
            MyModule.myFunction(nil)  -- Should throw error with nil input
        end, "Should throw error with nil input")
    end)
    
end)
```

### Available Assertions

- `assert_true(condition, message)` - Assert condition is true
- `assert_false(condition, message)` - Assert condition is false
- `assert_equals(actual, expected, message)` - Assert values are equal
- `assert_not_equals(actual, unexpected, message)` - Assert values are not equal
- `assert_nil(value, message)` - Assert value is nil
- `assert_not_nil(value, message)` - Assert value is not nil
- `assert_type(value, expected_type, message)` - Assert value is of specific type
- `assert_error(func, message)` - Assert function throws error
- `assert_no_error(func, message)` - Assert function doesn't throw error

## Test Output

### Successful Test Run

```text
========================================
Running GearSwap Module Tests
========================================

Testing: Config Module
  ✓ Config module tests passed

Testing: Logger Module
  ✓ Logger module tests passed

...

========================================
Test Summary
========================================
Total: 8 | Passed: 8 | Failed: 0

✓ All tests passed successfully!
```

### Failed Test Run

```text
Testing: Validation Module
  ✗ Validation module tests failed: Expected true, got false

========================================
Test Summary
========================================
Total: 8 | Passed: 7 | Failed: 1

✗ Some tests failed. Please review the errors above.
```

## Best Practices

1. **Test Isolation**: Each test should be independent and not rely on other tests
2. **Clear Names**: Use descriptive test case names that explain what is being tested
3. **Arrange-Act-Assert**: Structure tests with setup, execution, and verification phases
4. **Edge Cases**: Test boundary conditions, nil values, and error scenarios
5. **Fast Execution**: Keep tests lightweight and fast-running
6. **Regular Execution**: Run tests after making changes to verify nothing broke

## Troubleshooting

### Tests Not Running

- Ensure you're in a job that has the test command configured
- Check that all test files are in the `tests/` directory
- Verify file paths are correct in require statements

### False Positives/Negatives

- Some tests may require game state (like having a target)
- Module dependencies might not be loaded - check require statements
- Global variables might conflict - use local variables in tests

### Adding Test Command to Other Jobs

Add this function to any job file:

```lua
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'test' then
        windower.add_to_chat(050, "Executing GearSwap module tests...")
        include('test_runner.lua')
        eventArgs.handled = true
    end
end
```

## Contributing

When adding new modules or modifying existing ones:

1. Write tests for new functionality
2. Ensure existing tests still pass
3. Update test documentation
4. Add your module to the test coverage list

## Future Improvements

- [ ] Integration tests for job files
- [ ] Performance benchmarking
- [ ] Code coverage reporting
- [ ] Automated test execution on file changes
- [ ] Mock objects for game state simulation
- [ ] Test data fixtures
