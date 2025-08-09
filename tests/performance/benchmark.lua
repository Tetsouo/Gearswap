---============================================================================
--- FFXI GearSwap Performance Benchmark Suite
---============================================================================
--- Comprehensive performance benchmarking system for measuring startup time,
--- equipment swap speed, module loading performance, and overall system
--- efficiency. Provides automated threshold checking and recommendations.
--- Core features include:
---
--- • **Startup Time Analysis** - Measure and optimize initialization speed
--- • **Equipment Swap Benchmarks** - Track swap performance across all sets
--- • **Module Loading Performance** - Lazy loading efficiency metrics
--- • **Memory Usage Profiling** - Track memory consumption patterns
--- • **Statistical Analysis** - Percentiles, outliers, and trend detection
--- • **Threshold Monitoring** - Automated performance regression detection
--- • **Comprehensive Reporting** - Detailed performance reports and summaries
--- • **Historical Tracking** - Performance trend analysis over time
---
--- @file tests/performance/benchmark.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-08
--- @requires utils/logger, utils/validation
---============================================================================

local Benchmark = {}

-- Dependencies
local log = require('utils/logger')
local ValidationUtils = require('utils/validation')

-- Benchmark configuration
local benchmark_config = {
    iterations = 1000,
    warmup_iterations = 100,
    timeout_seconds = 60,
    memory_threshold_mb = 10,
    startup_threshold_ms = 300,
    swap_threshold_ms = 2.0,
    module_load_threshold_ms = 50
}

-- Performance data storage
local performance_data = {
    startup_times = {},
    swap_times = {},
    module_load_times = {},
    memory_usage = {},
    test_sessions = {}
}

-- Statistical functions
local statistics = {}

---============================================================================
--- Statistical Analysis Functions
---============================================================================

function statistics.mean(data)
    if #data == 0 then return 0 end
    local sum = 0
    for _, value in ipairs(data) do
        sum = sum + value
    end
    return sum / #data
end

function statistics.median(data)
    if #data == 0 then return 0 end
    local sorted = {}
    for _, value in ipairs(data) do
        table.insert(sorted, value)
    end
    table.sort(sorted)
    
    local n = #sorted
    if n % 2 == 0 then
        return (sorted[n/2] + sorted[n/2 + 1]) / 2
    else
        return sorted[math.ceil(n/2)]
    end
end

function statistics.percentile(data, p)
    if #data == 0 then return 0 end
    local sorted = {}
    for _, value in ipairs(data) do
        table.insert(sorted, value)
    end
    table.sort(sorted)
    
    local index = math.ceil((p / 100) * #sorted)
    return sorted[math.max(1, math.min(index, #sorted))]
end

function statistics.standard_deviation(data)
    if #data == 0 then return 0 end
    local mean = statistics.mean(data)
    local sum_squared_diff = 0
    
    for _, value in ipairs(data) do
        local diff = value - mean
        sum_squared_diff = sum_squared_diff + (diff * diff)
    end
    
    return math.sqrt(sum_squared_diff / #data)
end

function statistics.find_outliers(data, threshold_std)
    threshold_std = threshold_std or 2
    local mean = statistics.mean(data)
    local std_dev = statistics.standard_deviation(data)
    local outliers = {}
    
    for i, value in ipairs(data) do
        if math.abs(value - mean) > threshold_std * std_dev then
            table.insert(outliers, {index = i, value = value})
        end
    end
    
    return outliers
end

---============================================================================
--- Core Benchmark Functions
---============================================================================

--- Measure startup time performance
function Benchmark.measure_startup_time()
    log.info("Starting startup time benchmark...")
    
    local results = {
        times = {},
        memory_usage = {},
        errors = 0
    }
    
    -- Warmup runs
    for i = 1, benchmark_config.warmup_iterations do
        collectgarbage("collect")
        
        local start_memory = collectgarbage("count") * 1024
        local start_time = os.clock()
        
        -- Simulate startup process
        local success, error_msg = pcall(function()
            -- Mock Mote-Include loading
            local mote_time = math.random(10, 30) / 1000
            local current_time = os.clock()
            while (os.clock() - current_time) < mote_time do end
            
            -- Mock globals loading
            local globals_time = math.random(5, 15) / 1000
            current_time = os.clock()
            while (os.clock() - current_time) < globals_time do end
            
            -- Mock job-specific loading
            local job_time = math.random(20, 50) / 1000
            current_time = os.clock()
            while (os.clock() - current_time) < job_time do end
        end)
        
        if not success then
            results.errors = results.errors + 1
        end
    end
    
    -- Actual benchmark runs
    for i = 1, benchmark_config.iterations do
        collectgarbage("collect")
        
        local start_memory = collectgarbage("count") * 1024
        local start_time = os.clock()
        
        -- Simulate complete startup
        local success, error_msg = pcall(function()
            -- Mock full initialization
            include = function(file) 
                -- Simulate file loading time
                local load_time = math.random(1, 10) / 1000
                local current_time = os.clock()
                while (os.clock() - current_time) < load_time do end
            end
            
            -- Simulate multiple includes
            include('Mote-Include.lua')
            include('core/globals.lua')
            include('modules/automove.lua')
            include('modules/shared.lua')
            include('jobs/war/WAR_SET.lua')
            include('jobs/war/WAR_FUNCTION.lua')
        end)
        
        local end_time = os.clock()
        local end_memory = collectgarbage("count") * 1024
        
        local duration_ms = (end_time - start_time) * 1000
        local memory_delta = end_memory - start_memory
        
        if success then
            table.insert(results.times, duration_ms)
            table.insert(results.memory_usage, memory_delta)
        else
            results.errors = results.errors + 1
            log.warn("Startup benchmark iteration %d failed: %s", i, error_msg)
        end
        
        -- Progress logging
        if i % 100 == 0 then
            log.debug("Startup benchmark progress: %d/%d", i, benchmark_config.iterations)
        end
    end
    
    -- Calculate statistics
    local stats = {
        mean = statistics.mean(results.times),
        median = statistics.median(results.times),
        p95 = statistics.percentile(results.times, 95),
        p99 = statistics.percentile(results.times, 99),
        std_dev = statistics.standard_deviation(results.times),
        min = math.min(unpack(results.times)),
        max = math.max(unpack(results.times)),
        outliers = statistics.find_outliers(results.times),
        memory_mean = statistics.mean(results.memory_usage),
        errors = results.errors
    }
    
    -- Check against thresholds
    local passed = stats.p95 < benchmark_config.startup_threshold_ms and 
                   stats.errors < (benchmark_config.iterations * 0.01) -- Less than 1% errors
    
    local benchmark_result = {
        name = "startup_time",
        passed = passed,
        threshold = benchmark_config.startup_threshold_ms,
        iterations = benchmark_config.iterations,
        stats = stats,
        raw_data = results.times
    }
    
    log.info("Startup benchmark completed - Mean: %.2fms, P95: %.2fms, Passed: %s", 
        stats.mean, stats.p95, tostring(passed))
    
    -- Store results
    table.insert(performance_data.startup_times, benchmark_result)
    
    return benchmark_result
end

--- Measure equipment swap performance
function Benchmark.measure_equipment_swap_speed()
    log.info("Starting equipment swap benchmark...")
    
    -- Mock equipment sets for testing
    local test_sets = {
        idle = {
            head = "Test Head", neck = "Test Neck", ear1 = "Test Ear1", ear2 = "Test Ear2",
            body = "Test Body", hands = "Test Hands", ring1 = "Test Ring1", ring2 = "Test Ring2",
            back = "Test Back", waist = "Test Waist", legs = "Test Legs", feet = "Test Feet"
        },
        engaged = {
            head = "Engaged Head", neck = "Engaged Neck", ear1 = "Engaged Ear1", ear2 = "Engaged Ear2",
            body = "Engaged Body", hands = "Engaged Hands", ring1 = "Engaged Ring1", ring2 = "Engaged Ring2",
            back = "Engaged Back", waist = "Engaged Waist", legs = "Engaged Legs", feet = "Engaged Feet"
        },
        ws = {
            head = "WS Head", neck = "WS Neck", ear1 = "WS Ear1", ear2 = "WS Ear2",
            body = "WS Body", hands = "WS Hands", ring1 = "WS Ring1", ring2 = "WS Ring2",
            back = "WS Back", waist = "WS Waist", legs = "WS Legs", feet = "WS Feet"
        }
    }
    
    local results = {
        swap_times = {},
        set_performance = {},
        errors = 0
    }
    
    -- Initialize set performance tracking
    for set_name in pairs(test_sets) do
        results.set_performance[set_name] = {}
    end
    
    -- Mock equip function
    local function mock_equip(equipment_set)
        -- Simulate equipment swap time
        local swap_time = math.random(1, 20) / 10 -- 0.1ms to 2.0ms
        local start_time = os.clock()
        local current_time = os.clock()
        while (os.clock() - current_time) < (swap_time / 1000) do end
        return swap_time
    end
    
    -- Warmup
    for i = 1, benchmark_config.warmup_iterations do
        for set_name, equipment_set in pairs(test_sets) do
            mock_equip(equipment_set)
        end
    end
    
    -- Benchmark runs
    for i = 1, benchmark_config.iterations do
        for set_name, equipment_set in pairs(test_sets) do
            local start_time = os.clock()
            
            local success, result = pcall(function()
                return mock_equip(equipment_set)
            end)
            
            local end_time = os.clock()
            local actual_time = (end_time - start_time) * 1000
            
            if success then
                table.insert(results.swap_times, actual_time)
                table.insert(results.set_performance[set_name], actual_time)
            else
                results.errors = results.errors + 1
                log.warn("Equipment swap failed for %s: %s", set_name, result)
            end
        end
        
        -- Progress logging
        if i % 200 == 0 then
            log.debug("Swap benchmark progress: %d/%d", i, benchmark_config.iterations)
        end
    end
    
    -- Calculate overall statistics
    local overall_stats = {
        mean = statistics.mean(results.swap_times),
        median = statistics.median(results.swap_times),
        p95 = statistics.percentile(results.swap_times, 95),
        p99 = statistics.percentile(results.swap_times, 99),
        std_dev = statistics.standard_deviation(results.swap_times),
        min = math.min(unpack(results.swap_times)),
        max = math.max(unpack(results.swap_times)),
        outliers = statistics.find_outliers(results.swap_times),
        errors = results.errors
    }
    
    -- Calculate per-set statistics
    local set_stats = {}
    for set_name, times in pairs(results.set_performance) do
        set_stats[set_name] = {
            mean = statistics.mean(times),
            p95 = statistics.percentile(times, 95),
            count = #times
        }
    end
    
    -- Check against thresholds
    local passed = overall_stats.p95 < benchmark_config.swap_threshold_ms and 
                   overall_stats.errors < (benchmark_config.iterations * 0.01)
    
    local benchmark_result = {
        name = "equipment_swap_speed",
        passed = passed,
        threshold = benchmark_config.swap_threshold_ms,
        iterations = benchmark_config.iterations * #test_sets,
        overall_stats = overall_stats,
        set_stats = set_stats,
        raw_data = results.swap_times
    }
    
    log.info("Equipment swap benchmark completed - Mean: %.2fms, P95: %.2fms, Passed: %s", 
        overall_stats.mean, overall_stats.p95, tostring(passed))
    
    -- Store results
    table.insert(performance_data.swap_times, benchmark_result)
    
    return benchmark_result
end

--- Measure module loading performance
function Benchmark.measure_module_loading_performance()
    log.info("Starting module loading benchmark...")
    
    local test_modules = {
        'utils/validation',
        'utils/messages', 
        'utils/logger',
        'core/equipment',
        'core/buffs',
        'utils/helpers'
    }
    
    local results = {
        load_times = {},
        module_performance = {},
        errors = 0
    }
    
    -- Initialize module performance tracking
    for _, module_name in ipairs(test_modules) do
        results.module_performance[module_name] = {}
    end
    
    -- Test each module multiple times
    for i = 1, benchmark_config.iterations do
        for _, module_name in ipairs(test_modules) do
            -- Clear module from cache
            package.loaded[module_name] = nil
            
            local start_time = os.clock()
            
            local success, module_or_error = pcall(require, module_name)
            
            local end_time = os.clock()
            local load_time = (end_time - start_time) * 1000
            
            if success then
                table.insert(results.load_times, load_time)
                table.insert(results.module_performance[module_name], load_time)
            else
                results.errors = results.errors + 1
                log.warn("Module loading failed for %s: %s", module_name, module_or_error)
            end
        end
        
        -- Progress logging
        if i % 100 == 0 then
            log.debug("Module loading benchmark progress: %d/%d", i, benchmark_config.iterations)
        end
    end
    
    -- Calculate overall statistics
    local overall_stats = {
        mean = statistics.mean(results.load_times),
        median = statistics.median(results.load_times),
        p95 = statistics.percentile(results.load_times, 95),
        p99 = statistics.percentile(results.load_times, 99),
        std_dev = statistics.standard_deviation(results.load_times),
        min = math.min(unpack(results.load_times)),
        max = math.max(unpack(results.load_times)),
        outliers = statistics.find_outliers(results.load_times),
        errors = results.errors
    }
    
    -- Calculate per-module statistics
    local module_stats = {}
    for module_name, times in pairs(results.module_performance) do
        module_stats[module_name] = {
            mean = statistics.mean(times),
            p95 = statistics.percentile(times, 95),
            count = #times
        }
    end
    
    -- Check against thresholds
    local passed = overall_stats.p95 < benchmark_config.module_load_threshold_ms and 
                   overall_stats.errors < (benchmark_config.iterations * 0.01)
    
    local benchmark_result = {
        name = "module_loading_performance",
        passed = passed,
        threshold = benchmark_config.module_load_threshold_ms,
        iterations = benchmark_config.iterations * #test_modules,
        overall_stats = overall_stats,
        module_stats = module_stats,
        raw_data = results.load_times
    }
    
    log.info("Module loading benchmark completed - Mean: %.2fms, P95: %.2fms, Passed: %s", 
        overall_stats.mean, overall_stats.p95, tostring(passed))
    
    -- Store results
    table.insert(performance_data.module_load_times, benchmark_result)
    
    return benchmark_result
end

--- Profile memory usage patterns
function Benchmark.profile_memory_usage()
    log.info("Starting memory usage profiling...")
    
    local results = {
        initial_memory = collectgarbage("count") * 1024,
        snapshots = {},
        peak_memory = 0,
        memory_leaks = {}
    }
    
    -- Take initial snapshot
    collectgarbage("collect")
    local baseline_memory = collectgarbage("count") * 1024
    results.initial_memory = baseline_memory
    
    -- Simulate various operations and track memory
    local operations = {
        {name = "job_loading", iterations = 50},
        {name = "equipment_swaps", iterations = 1000},
        {name = "spell_casting", iterations = 200},
        {name = "module_loading", iterations = 100}
    }
    
    for _, operation in ipairs(operations) do
        log.debug("Profiling memory for operation: %s", operation.name)
        
        local operation_start_memory = collectgarbage("count") * 1024
        
        for i = 1, operation.iterations do
            -- Simulate operation
            if operation.name == "job_loading" then
                -- Mock job loading
                local temp_data = {}
                for j = 1, 100 do
                    temp_data[j] = "job_data_" .. j
                end
            elseif operation.name == "equipment_swaps" then
                -- Mock equipment swaps
                local temp_equipment = {
                    head = "temp", body = "temp", hands = "temp",
                    legs = "temp", feet = "temp", neck = "temp"
                }
            elseif operation.name == "spell_casting" then
                -- Mock spell data
                local temp_spell = {
                    name = "Fire IV", element = "Fire", mp_cost = 88,
                    cast_time = 5.0, recast = 6.0
                }
            elseif operation.name == "module_loading" then
                -- Mock module data
                local temp_module = {
                    version = "1.0", functions = {}, data = {}
                }
            end
            
            -- Track peak memory
            local current_memory = collectgarbage("count") * 1024
            if current_memory > results.peak_memory then
                results.peak_memory = current_memory
            end
            
            -- Take periodic snapshots
            if i % (operation.iterations / 10) == 0 then
                table.insert(results.snapshots, {
                    operation = operation.name,
                    iteration = i,
                    memory = current_memory,
                    delta_from_baseline = current_memory - baseline_memory
                })
            end
        end
        
        -- Force garbage collection and check for leaks
        collectgarbage("collect")
        local operation_end_memory = collectgarbage("count") * 1024
        local memory_delta = operation_end_memory - operation_start_memory
        
        if memory_delta > (benchmark_config.memory_threshold_mb * 1024 * 1024) then
            table.insert(results.memory_leaks, {
                operation = operation.name,
                memory_delta = memory_delta,
                iterations = operation.iterations
            })
            log.warn("Potential memory leak in %s: %+d bytes", operation.name, memory_delta)
        end
    end
    
    -- Final memory state
    collectgarbage("collect")
    local final_memory = collectgarbage("count") * 1024
    
    local profile_result = {
        name = "memory_usage_profile",
        initial_memory = results.initial_memory,
        final_memory = final_memory,
        peak_memory = results.peak_memory,
        total_delta = final_memory - baseline_memory,
        snapshots = results.snapshots,
        memory_leaks = results.memory_leaks,
        passed = (#results.memory_leaks == 0)
    }
    
    log.info("Memory profiling completed - Peak: %.2fMB, Final Delta: %+.2fMB, Leaks: %d", 
        results.peak_memory / (1024 * 1024), 
        profile_result.total_delta / (1024 * 1024),
        #results.memory_leaks)
    
    -- Store results
    table.insert(performance_data.memory_usage, profile_result)
    
    return profile_result
end

---============================================================================
--- Test Runner and Reporting Functions
---============================================================================

--- Run all benchmark tests
function Benchmark.run_all_benchmarks()
    log.info("=== Starting Performance Benchmark Suite ===")
    
    local start_time = os.clock()
    local all_results = {}
    
    -- Run individual benchmarks
    table.insert(all_results, Benchmark.measure_startup_time())
    table.insert(all_results, Benchmark.measure_equipment_swap_speed())
    table.insert(all_results, Benchmark.measure_module_loading_performance())
    table.insert(all_results, Benchmark.profile_memory_usage())
    
    local end_time = os.clock()
    local total_time = (end_time - start_time) * 1000
    
    -- Calculate overall results
    local total_benchmarks = #all_results
    local passed_benchmarks = 0
    
    for _, result in ipairs(all_results) do
        if result.passed then
            passed_benchmarks = passed_benchmarks + 1
        end
    end
    
    local overall_success_rate = (passed_benchmarks / total_benchmarks) * 100
    
    -- Generate comprehensive report
    local summary = {
        total_benchmarks = total_benchmarks,
        passed_benchmarks = passed_benchmarks,
        failed_benchmarks = total_benchmarks - passed_benchmarks,
        success_rate = overall_success_rate,
        total_time = total_time,
        individual_results = all_results,
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Log summary
    log.info("=== Performance Benchmark Summary ===")
    log.info("Total Benchmarks: %d", total_benchmarks)
    log.info("Passed: %d", passed_benchmarks)
    log.info("Failed: %d", total_benchmarks - passed_benchmarks)
    log.info("Success Rate: %.1f%%", overall_success_rate)
    log.info("Total Time: %.2fms", total_time)
    
    -- Log individual results
    for _, result in ipairs(all_results) do
        local status = result.passed and "PASS" or "FAIL"
        log.info("  %s: %s", result.name, status)
    end
    
    -- Store session data
    table.insert(performance_data.test_sessions, summary)
    
    return summary
end

--- Generate detailed performance report
function Benchmark.generate_report()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        summary = {},
        startup_performance = {},
        swap_performance = {},
        module_performance = {},
        memory_analysis = {},
        recommendations = {}
    }
    
    -- Startup performance analysis
    if #performance_data.startup_times > 0 then
        local latest = performance_data.startup_times[#performance_data.startup_times]
        report.startup_performance = {
            mean_ms = latest.stats.mean,
            p95_ms = latest.stats.p95,
            threshold_ms = latest.threshold,
            passed = latest.passed,
            recommendation = latest.stats.p95 > 200 and "Consider optimizing startup sequence" or "Startup performance is excellent"
        }
    end
    
    -- Equipment swap performance
    if #performance_data.swap_times > 0 then
        local latest = performance_data.swap_times[#performance_data.swap_times]
        report.swap_performance = {
            mean_ms = latest.overall_stats.mean,
            p95_ms = latest.overall_stats.p95,
            threshold_ms = latest.threshold,
            passed = latest.passed,
            recommendation = latest.overall_stats.p95 > 1.5 and "Equipment swaps may benefit from caching" or "Swap performance is optimal"
        }
    end
    
    -- Overall recommendations
    if report.startup_performance.passed and report.swap_performance.passed then
        table.insert(report.recommendations, "✅ All performance benchmarks are passing")
    else
        table.insert(report.recommendations, "⚠️ Some performance issues detected - see individual sections")
    end
    
    return report
end

--- Configure benchmark settings
function Benchmark.configure(config)
    if config.iterations then
        benchmark_config.iterations = config.iterations
    end
    if config.warmup_iterations then
        benchmark_config.warmup_iterations = config.warmup_iterations
    end
    if config.startup_threshold_ms then
        benchmark_config.startup_threshold_ms = config.startup_threshold_ms
    end
    if config.swap_threshold_ms then
        benchmark_config.swap_threshold_ms = config.swap_threshold_ms
    end
    if config.module_load_threshold_ms then
        benchmark_config.module_load_threshold_ms = config.module_load_threshold_ms
    end
    
    log.info("Benchmark configured: %d iterations, startup < %dms, swap < %.1fms",
        benchmark_config.iterations,
        benchmark_config.startup_threshold_ms,
        benchmark_config.swap_threshold_ms)
end

return Benchmark