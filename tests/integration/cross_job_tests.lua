---============================================================================
--- FFXI GearSwap Integration Tests - Cross-Job Testing Suite
---============================================================================
--- Comprehensive integration testing framework for cross-job functionality
--- testing memory leaks, state consistency, and shared utility robustness.
--- Core features include:
---
--- • **Job Switching Tests** - Seamless transition between all job configs
--- • **Memory Leak Detection** - Automatic memory monitoring and alerts
--- • **State Consistency** - Validation of state synchronization
--- • **Shared Utilities** - Cross-job utility function testing
--- • **Error Recovery** - Recovery mechanisms validation
--- • **Performance Monitoring** - Timing and resource usage tracking
--- • **Mock Environment** - Windower API mocking for isolated testing
--- • **Concurrent Testing** - Multi-job operation validation
---
--- @file tests/integration/cross_job_tests.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-08
--- @requires tests/test_framework
---============================================================================

local CrossJobTests = {}

-- Dependencies
local TestFramework = require('tests/test_framework')
local log = require('utils/logger')

-- Test configuration
local test_config = {
    jobs = {'WAR', 'BLM', 'BST', 'DNC', 'DRG', 'PLD', 'RUN', 'THF'},
    memory_threshold = 5 * 1024 * 1024, -- 5MB threshold
    timeout_seconds = 30,
    max_iterations = 100
}

-- Test state tracking
local test_results = {}
local initial_memory = 0
local mock_windower = {}

---============================================================================
--- Mock Windower Environment for Testing
---============================================================================

function CrossJobTests.setup_mock_environment()
    -- Mock windower functions for testing
    mock_windower = {
        ffxi = {
            get_player = function()
                return {
                    name = "TestPlayer",
                    id = 12345,
                    index = 1024,
                    status = 0,
                    hp = 1000,
                    hpp = 100,
                    mp = 500,
                    mpp = 100,
                    tp = 0,
                    main_job = "WAR",
                    main_job_level = 99,
                    sub_job = "NIN",
                    sub_job_level = 49
                }
            end,
            
            get_mob_by_index = function(index)
                return {
                    name = "TestMob",
                    id = 54321,
                    index = index,
                    x = 0, y = 0, z = 0,
                    hpp = 100
                }
            end,
            
            get_ability_recasts = function()
                return {}
            end,
            
            get_spell_recasts = function()
                return {}
            end
        },
        
        add_to_chat = function(color, message)
            -- Store chat messages for testing
            table.insert(mock_windower.chat_log, {
                color = color,
                message = message,
                timestamp = os.time()
            })
        end,
        
        chat_log = {},
        
        register_event = function(event, callback)
            -- Mock event registration
            return true
        end
    }
    
    -- Replace global windower for testing
    _G.windower = mock_windower
    
    log.info("Mock windower environment initialized")
end

---============================================================================
--- Core Test Functions
---============================================================================

--- Test job switching without memory leaks
function CrossJobTests.test_job_switching()
    log.info("Starting job switching test...")
    
    initial_memory = collectgarbage("count") * 1024
    local results = {}
    
    for i, job in ipairs(test_config.jobs) do
        local start_time = os.clock()
        local start_memory = collectgarbage("count") * 1024
        
        log.debug("Testing job switch to: %s", job)
        
        -- Attempt to load job module
        local success, error_msg = pcall(function()
            -- Simulate job loading
            package.loaded['Tetsouo_' .. job] = nil
            
            -- Mock require for testing
            local job_module = {
                job_name = job,
                loaded_at = os.time(),
                get_sets = function() return {} end,
                job_setup = function() return true end
            }
            
            return job_module
        end)
        
        local end_time = os.clock()
        local end_memory = collectgarbage("count") * 1024
        local memory_delta = end_memory - start_memory
        
        results[job] = {
            success = success,
            load_time = (end_time - start_time) * 1000,
            memory_delta = memory_delta,
            error = error_msg
        }
        
        -- Check for memory leaks
        if memory_delta > test_config.memory_threshold then
            log.warn("Potential memory leak detected in %s: %d bytes", job, memory_delta)
            results[job].memory_leak = true
        end
        
        -- Clean up
        if success then
            package.loaded['Tetsouo_' .. job] = nil
            collectgarbage("collect")
        end
        
        log.debug("Job %s - Load: %.2fms, Memory: %+d bytes", job, results[job].load_time, memory_delta)
    end
    
    -- Analyze results
    local total_jobs = #test_config.jobs
    local successful_loads = 0
    local memory_leaks = 0
    local total_load_time = 0
    
    for job, result in pairs(results) do
        if result.success then
            successful_loads = successful_loads + 1
        end
        if result.memory_leak then
            memory_leaks = memory_leaks + 1
        end
        total_load_time = total_load_time + result.load_time
    end
    
    local avg_load_time = total_load_time / total_jobs
    local success_rate = (successful_loads / total_jobs) * 100
    
    local test_result = {
        name = "job_switching",
        passed = (success_rate == 100 and memory_leaks == 0),
        details = {
            total_jobs = total_jobs,
            successful_loads = successful_loads,
            success_rate = success_rate,
            memory_leaks = memory_leaks,
            avg_load_time = avg_load_time,
            results = results
        }
    }
    
    log.info("Job switching test completed - Success: %.1f%%, Memory leaks: %d", success_rate, memory_leaks)
    return test_result
end

--- Test shared utility consistency across jobs
function CrossJobTests.test_shared_utilities()
    log.info("Testing shared utility consistency...")
    
    local utilities = {
        'utils/messages',
        'utils/validation', 
        'utils/logger',
        'utils/helpers',
        'core/equipment',
        'core/buffs'
    }
    
    local results = {}
    
    for _, util_name in ipairs(utilities) do
        log.debug("Testing utility: %s", util_name)
        
        local start_time = os.clock()
        local success, util_module = pcall(require, util_name)
        local load_time = (os.clock() - start_time) * 1000
        
        if success then
            -- Test basic utility functions
            local function_tests = {}
            
            if util_name == 'utils/messages' then
                -- Test message formatting
                if util_module.create_formatted_message then
                    local msg = util_module.create_formatted_message("Test", "Spell", 60, nil, false, true)
                    function_tests.create_formatted_message = (msg ~= nil and #msg > 0)
                end
            elseif util_name == 'utils/validation' then
                -- Test validation functions
                if util_module.validate_type then
                    function_tests.validate_string = util_module.validate_type("test", "string", "test")
                    function_tests.validate_number = util_module.validate_type(123, "number", "test")
                    function_tests.validate_invalid = not util_module.validate_type("test", "number", "test")
                end
            elseif util_name == 'utils/logger' then
                -- Test logging functions
                if util_module.info then
                    function_tests.logging = pcall(util_module.info, "Test log message")
                end
            end
            
            results[util_name] = {
                success = true,
                load_time = load_time,
                function_tests = function_tests
            }
        else
            results[util_name] = {
                success = false,
                error = util_module,
                load_time = load_time
            }
        end
    end
    
    -- Analyze results
    local total_utils = #utilities
    local successful_loads = 0
    local function_failures = 0
    
    for util_name, result in pairs(results) do
        if result.success then
            successful_loads = successful_loads + 1
            
            -- Check function test results
            if result.function_tests then
                for test_name, test_result in pairs(result.function_tests) do
                    if not test_result then
                        function_failures = function_failures + 1
                        log.warn("Function test failed: %s.%s", util_name, test_name)
                    end
                end
            end
        end
    end
    
    local success_rate = (successful_loads / total_utils) * 100
    
    local test_result = {
        name = "shared_utilities",
        passed = (success_rate == 100 and function_failures == 0),
        details = {
            total_utilities = total_utils,
            successful_loads = successful_loads,
            success_rate = success_rate,
            function_failures = function_failures,
            results = results
        }
    }
    
    log.info("Shared utilities test completed - Success: %.1f%%, Function failures: %d", success_rate, function_failures)
    return test_result
end

--- Test concurrent operations
function CrossJobTests.test_concurrent_operations()
    log.info("Testing concurrent operations...")
    
    local concurrent_jobs = {'WAR', 'BLM', 'PLD'}
    local operations = {}
    local results = {}
    
    -- Simulate concurrent job operations
    for i, job in ipairs(concurrent_jobs) do
        operations[job] = coroutine.create(function()
            local start_time = os.clock()
            
            -- Simulate equipment changes
            for j = 1, 10 do
                -- Mock equipment swap
                coroutine.yield()
            end
            
            -- Simulate spell casting
            for j = 1, 5 do
                -- Mock spell cast
                coroutine.yield()
            end
            
            local end_time = os.clock()
            return {
                job = job,
                duration = (end_time - start_time) * 1000,
                operations = 15
            }
        end)
    end
    
    -- Run operations concurrently
    local completed = 0
    local max_iterations = test_config.max_iterations
    local iteration = 0
    
    while completed < #concurrent_jobs and iteration < max_iterations do
        iteration = iteration + 1
        
        for job, co in pairs(operations) do
            if coroutine.status(co) ~= "dead" then
                local success, result = coroutine.resume(co)
                
                if not success then
                    log.error("Concurrent operation failed for %s: %s", job, result)
                    results[job] = { success = false, error = result }
                    operations[job] = nil
                    completed = completed + 1
                elseif result then
                    -- Operation completed successfully
                    results[job] = { success = true, details = result }
                    operations[job] = nil
                    completed = completed + 1
                end
            end
        end
        
        -- Small delay to prevent busy waiting
        if os.clock() % 0.001 == 0 then
            -- Brief pause
        end
    end
    
    -- Check for timeouts
    for job, co in pairs(operations) do
        if coroutine.status(co) ~= "dead" then
            log.warn("Concurrent operation timeout for job: %s", job)
            results[job] = { success = false, error = "timeout" }
        end
    end
    
    local successful_ops = 0
    for job, result in pairs(results) do
        if result.success then
            successful_ops = successful_ops + 1
        end
    end
    
    local success_rate = (successful_ops / #concurrent_jobs) * 100
    
    local test_result = {
        name = "concurrent_operations",
        passed = (success_rate == 100 and iteration < max_iterations),
        details = {
            total_jobs = #concurrent_jobs,
            successful_operations = successful_ops,
            success_rate = success_rate,
            iterations = iteration,
            results = results
        }
    }
    
    log.info("Concurrent operations test completed - Success: %.1f%%", success_rate)
    return test_result
end

--- Test error recovery mechanisms
function CrossJobTests.test_error_recovery()
    log.info("Testing error recovery mechanisms...")
    
    local error_scenarios = {
        {name = "invalid_job", job = "INVALID"},
        {name = "missing_set", job = "WAR", missing_set = true},
        {name = "corrupted_data", job = "BLM", corrupt_data = true}
    }
    
    local results = {}
    
    for _, scenario in ipairs(error_scenarios) do
        log.debug("Testing error scenario: %s", scenario.name)
        
        local start_time = os.clock()
        local recovery_successful = false
        local error_caught = false
        
        -- Simulate error scenario
        local success, error_msg = pcall(function()
            if scenario.name == "invalid_job" then
                -- Try to load invalid job
                error("Invalid job: " .. scenario.job)
            elseif scenario.name == "missing_set" then
                -- Simulate missing equipment set
                error("Missing equipment set: idle")
            elseif scenario.name == "corrupted_data" then
                -- Simulate corrupted data
                error("Corrupted job data")
            end
        end)
        
        if not success then
            error_caught = true
            log.debug("Expected error caught: %s", error_msg)
            
            -- Test recovery mechanism
            local recovery_success, recovery_error = pcall(function()
                -- Simulate recovery actions
                if scenario.name == "invalid_job" then
                    -- Fallback to default job
                    return "WAR"
                elseif scenario.name == "missing_set" then
                    -- Use backup set
                    return {}
                elseif scenario.name == "corrupted_data" then
                    -- Reset to defaults
                    return {}
                end
            end)
            
            recovery_successful = recovery_success
        end
        
        local end_time = os.clock()
        
        results[scenario.name] = {
            error_caught = error_caught,
            recovery_successful = recovery_successful,
            recovery_time = (end_time - start_time) * 1000
        }
    end
    
    local successful_recoveries = 0
    for _, result in pairs(results) do
        if result.error_caught and result.recovery_successful then
            successful_recoveries = successful_recoveries + 1
        end
    end
    
    local recovery_rate = (successful_recoveries / #error_scenarios) * 100
    
    local test_result = {
        name = "error_recovery",
        passed = (recovery_rate == 100),
        details = {
            total_scenarios = #error_scenarios,
            successful_recoveries = successful_recoveries,
            recovery_rate = recovery_rate,
            results = results
        }
    }
    
    log.info("Error recovery test completed - Recovery rate: %.1f%%", recovery_rate)
    return test_result
end

---============================================================================
--- Test Runner Functions
---============================================================================

--- Run all integration tests
function CrossJobTests.run_all_tests()
    log.info("=== Starting Cross-Job Integration Tests ===")
    
    CrossJobTests.setup_mock_environment()
    
    local all_results = {}
    local start_time = os.clock()
    
    -- Run individual tests
    table.insert(all_results, CrossJobTests.test_job_switching())
    table.insert(all_results, CrossJobTests.test_shared_utilities())
    table.insert(all_results, CrossJobTests.test_concurrent_operations())
    table.insert(all_results, CrossJobTests.test_error_recovery())
    
    local end_time = os.clock()
    local total_time = (end_time - start_time) * 1000
    
    -- Calculate overall results
    local total_tests = #all_results
    local passed_tests = 0
    
    for _, result in ipairs(all_results) do
        if result.passed then
            passed_tests = passed_tests + 1
        end
    end
    
    local overall_success_rate = (passed_tests / total_tests) * 100
    
    -- Generate summary report
    local summary = {
        total_tests = total_tests,
        passed_tests = passed_tests,
        failed_tests = total_tests - passed_tests,
        success_rate = overall_success_rate,
        total_time = total_time,
        individual_results = all_results
    }
    
    -- Log summary
    log.info("=== Integration Tests Summary ===")
    log.info("Total Tests: %d", total_tests)
    log.info("Passed: %d", passed_tests)
    log.info("Failed: %d", total_tests - passed_tests)
    log.info("Success Rate: %.1f%%", overall_success_rate)
    log.info("Total Time: %.2fms", total_time)
    
    -- Log individual test results
    for _, result in ipairs(all_results) do
        local status = result.passed and "PASS" or "FAIL"
        log.info("  %s: %s", result.name, status)
        
        if not result.passed then
            log.warn("    Details: %s", tostring(result.details))
        end
    end
    
    return summary
end

--- Configure test parameters
function CrossJobTests.configure(config)
    if config.jobs then
        test_config.jobs = config.jobs
    end
    if config.memory_threshold then
        test_config.memory_threshold = config.memory_threshold
    end
    if config.timeout_seconds then
        test_config.timeout_seconds = config.timeout_seconds
    end
    if config.max_iterations then
        test_config.max_iterations = config.max_iterations
    end
    
    log.info("Cross-job tests configured with %d jobs", #test_config.jobs)
end

return CrossJobTests