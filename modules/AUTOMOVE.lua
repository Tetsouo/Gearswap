---============================================================================
--- FFXI GearSwap Module - Automatic Movement Speed Gear Detection
---============================================================================
--- Professional automatic movement detection system for GearSwap equipment
--- management. Provides intelligent movement-based gear swapping with
--- configurable thresholds and combat awareness. Core features include:
---
--- • **Smart Movement Detection** - Position-based movement calculation
--- • **Configurable Thresholds** - Distance and timing parameters
--- • **Combat State Awareness** - Engaged vs idle movement handling
--- • **City Optimization** - Special Adoulin movement speed gear
--- • **Performance Optimized** - Frame-based checking with minimal overhead
--- • **Safety Mechanisms** - Error handling and nil protection
--- • **Integration Ready** - Seamless job file integration
--- • **State Synchronization** - Movement state tracking across modules
---
--- This module automatically detects player movement and equips appropriate
--- movement speed gear while preserving combat effectiveness and providing
--- seamless integration with all job configurations.
---
--- @file modules/automove.lua
--- @author Tetsouo
--- @version 2.1
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires config/config for movement parameters
--- @requires GearSwap addon and Windower FFXI
---
--- @usage
---   include('modules/automove.lua') -- In job_setup()
---   sets.MoveSpeed = { legs="Carmine Cuisses +1" } -- Define movement gear
---   sets.Adoulin = set_combine(sets.MoveSpeed, { body="Councilor's Garb" })
---============================================================================

-- Do not modify the section below, unless you know what you are doing.

-- Load configuration with error handling
local config_success, config = pcall(require, 'config/config')
if not config_success then
    windower.add_to_chat(167, "AutoMove: Config module not found")
    return
end

-- Cache movement parameters for performance
local movement_threshold = config.get_movement_threshold and config.get_movement_threshold() or
    0.5 -- More sensitive to movement
local check_interval = config.get_movement_check_interval and config.get_movement_check_interval() or
    1 -- Check each frame for maximum responsiveness
local engaged_moving_enabled = config.get and config.get('movement.engaged_moving') or false

-- Safely create Adoulin set only if MoveSpeed exists
if sets.MoveSpeed then
    sets.Adoulin = set_combine(sets.MoveSpeed, { body = "Councilor's Garb" })
end

state.Moving = M('false', 'true')

-- Use cached config for engaged moving setting
local engaged_moving_default = engaged_moving_enabled and 'Enabled' or 'Disabled'
state.EngagedMoving = M(engaged_moving_default, 'Enabled', 'Disabled')

-- Initialize movement tracking with safe checks and cached position
mov = { counter = 0, x = 0, y = 0, z = 0, last_dist = 0, stable_counter = 0 }

-- Safe initialization of position
local function init_position()
    if player and player.index then
        local mob = windower.ffxi.get_mob_by_index(player.index)
        if mob and mob.x and mob.y and mob.z then
            mov.x = mob.x
            mov.y = mob.y
            mov.z = mob.z
            return true
        end
    end
    return false
end

-- Try to initialize position
init_position()

moving = false

windower.raw_register_event('prerender', function()
    mov.counter = mov.counter + 1
    -- Use cached config interval for performance
    if mov.counter > check_interval then
        -- Safe player check
        if not player or not player.index then
            mov.counter = 0
            return
        end

        -- Check if in a city zone first
        local in_city = world.area and (world.area:contains('Adoulin') or
            world.area:contains('San d\'Oria') or
            world.area:contains('Bastok') or
            world.area:contains('Windurst') or
            world.area:contains('Jeuno') or
            world.area:contains('Tavnazia') or
            world.area:contains('Aht Urhgan') or
            world.area:contains('Nashmau') or
            world.area:contains('Selbina') or
            world.area:contains('Mhaura') or
            world.area:contains('Kazham') or
            world.area:contains('Norg') or
            world.area:contains('Rabao'))

        -- In city: always keep movement gear equipped
        if in_city then
            -- Only update state if it changed (prevent constant equipment commands)
            if state.Moving.value ~= 'true' then
                state.Moving.value = 'true'
                moving = true

                -- Check which set to use based on specific city
                if world.area:contains('Adoulin') then
                    if sets.Adoulin then
                        send_command('gs equip sets.Adoulin')
                    end
                else
                    -- Other cities: use normal MoveSpeed
                    if sets.MoveSpeed then
                        send_command('gs equip sets.MoveSpeed')
                    end
                end
            end

            mov.counter = 0
            return -- Skip normal movement detection in cities
        end

        local pl = windower.ffxi.get_mob_by_index(player.index)
        if pl and pl.x and pl.y and pl.z and mov.x then
            -- Cache distance calculation
            local dx, dy, dz = pl.x - mov.x, pl.y - mov.y, pl.z - mov.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

            -- Stability check: avoid frequent toggle if distance is similar
            if math.abs(dist - mov.last_dist) < 0.1 then
                mov.stable_counter = mov.stable_counter + 1
            else
                mov.stable_counter = 0
            end
            mov.last_dist = dist

            ----------------------------------------------------------------------------
            -- If distance > threshold, character is considered in motion
            ----------------------------------------------------------------------------
            if dist > movement_threshold then
                -- First time detecting movement
                if not moving then
                    -- If EngagedMoving is 'Disabled' and we are Engaged, do not use MoveSpeed
                    if player.status == 'Engaged' and state.EngagedMoving.Value == 'Disabled' then
                        state.Moving.value = 'false'
                        moving = false
                    else
                        -- Otherwise, equip movement gear
                        state.Moving.value = 'true'
                        send_command('gs c update')
                        if world.area and world.area:contains('Adoulin') and sets.Adoulin then
                            send_command('gs equip sets.Adoulin')
                        elseif sets.MoveSpeed then
                            send_command('gs equip sets.MoveSpeed')
                        end
                        moving = true
                    end

                    -- Already moving: continuously check if Engaged status changes
                else
                    if player.status == 'Engaged' then
                        if state.EngagedMoving.Value == 'Disabled' then
                            -- Engaged and EngagedMoving is Disabled => remove MoveSpeed
                            state.Moving.value = 'false'
                            send_command('gs c update')
                            moving = false
                        else
                            -- Engaged + EngagedMoving = Enabled => keep MoveSpeed
                            if world.area and world.area:contains('Adoulin') and sets.Adoulin then
                                send_command('gs equip sets.Adoulin')
                            elseif sets.MoveSpeed then
                                send_command('gs equip sets.MoveSpeed')
                            end
                        end
                    else
                        -- If not Engaged, ensure MoveSpeed is equipped
                        if world.area and world.area:contains('Adoulin') and sets.Adoulin then
                            send_command('gs equip sets.Adoulin')
                        elseif sets.MoveSpeed then
                            send_command('gs equip sets.MoveSpeed')
                        end
                    end
                end

                ----------------------------------------------------------------------------
                -- If distance < threshold, character is considered stopped
                ----------------------------------------------------------------------------
            elseif dist < movement_threshold then -- Remove stable_counter to unequip instantly
                if moving then
                    -- Remove MoveSpeed gear immediately when stopped
                    state.Moving.value = 'false'
                    send_command('gs c update')
                    moving = false
                end
            end

            -- Update previous position for the next cycle
            mov.x = pl.x
            mov.y = pl.y
            mov.z = pl.z
        end

        mov.counter = 0
    end
end)

-- Handle job change events to re-equip movement gear in cities
windower.register_event('job change', function(main_job_id, main_job_level, sub_job_id, sub_job_level)
    -- Delay to let GearSwap finish job change processing
    coroutine.schedule(function()
        -- Check if we're in a city and need to equip movement gear
        local world = windower.ffxi.get_info().world
        if not world then return end

        local in_city = (world.area:contains('Bastok') or
            world.area:contains('San d\'Oria') or
            world.area:contains('Windurst') or
            world.area:contains('Jeuno') or
            world.area:contains('Adoulin') or
            world.area:contains('Aht Urhgan') or
            world.area:contains('Nashmau') or
            world.area:contains('Selbina') or
            world.area:contains('Mhaura') or
            world.area:contains('Kazham') or
            world.area:contains('Norg') or
            world.area:contains('Rabao'))

        if in_city then
            -- Force movement state to trigger gear swap
            if state and state.Moving then
                state.Moving.value = 'true'
                moving = true

                -- Equip appropriate city movement gear
                if world.area:contains('Adoulin') then
                    if sets.Adoulin then
                        send_command('gs equip sets.Adoulin')
                    end
                else
                    if sets.MoveSpeed then
                        send_command('gs equip sets.MoveSpeed')
                    end
                end
            end
        end
    end, 2) -- 2 second delay to ensure GearSwap job change is complete
end)

-- Also check movement status when addon loads (for reload scenarios)
windower.register_event('load', function()
    -- Small delay to ensure everything is initialized
    coroutine.schedule(function()
        local world = windower.ffxi.get_info()
        if not world then return end

        local in_city = (world.area:contains('Bastok') or
            world.area:contains('San d\'Oria') or
            world.area:contains('Windurst') or
            world.area:contains('Jeuno') or
            world.area:contains('Adoulin') or
            world.area:contains('Aht Urhgan') or
            world.area:contains('Nashmau') or
            world.area:contains('Selbina') or
            world.area:contains('Mhaura') or
            world.area:contains('Kazham') or
            world.area:contains('Norg') or
            world.area:contains('Rabao'))

        if in_city then
            -- Force movement state to trigger gear swap
            if state and state.Moving then
                state.Moving.value = 'true'
                moving = true

                -- Equip appropriate city movement gear
                if world.area:contains('Adoulin') then
                    if sets.Adoulin then
                        send_command('gs equip sets.Adoulin')
                    end
                else
                    if sets.MoveSpeed then
                        send_command('gs equip sets.MoveSpeed')
                    end
                end
            end
        end
    end, 1) -- 1 second delay for initialization
end)
