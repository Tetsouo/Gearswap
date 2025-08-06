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
--- @version 2.0
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

-- Load configuration
local config = require('config/config')

-- Safely create Adoulin set only if MoveSpeed exists
if sets.MoveSpeed then
    sets.Adoulin = set_combine(sets.MoveSpeed, { body = "Councilor's Garb" })
end

state.Moving = M('false', 'true')

-- Use config for engaged moving setting
local engaged_moving_default = config.get('movement.engaged_moving') and 'Enabled' or 'Disabled'
state.EngagedMoving = M(engaged_moving_default, 'Enabled', 'Disabled')

-- Initialize movement tracking with safe checks
mov = { counter = 0, x = 0, y = 0, z = 0 }

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
    -- Check based on config interval
    local check_interval = config.get_movement_check_interval()
    if mov.counter > check_interval then
        -- Safe player check
        if not player or not player.index then
            mov.counter = 0
            return
        end
        
        local pl = windower.ffxi.get_mob_by_index(player.index)
        if pl and pl.x and pl.y and pl.z and mov.x then
            local dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)

            ----------------------------------------------------------------------------
            -- If distance > threshold, character is considered in motion
            ----------------------------------------------------------------------------
            local movement_threshold = config.get_movement_threshold()
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
                        if world.area and world.area:contains('Adoulin') then
                            send_command('gs equip sets.Adoulin')
                        else
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
                            if world.area and world.area:contains('Adoulin') then
                                send_command('gs equip sets.Adoulin')
                            else
                                send_command('gs equip sets.MoveSpeed')
                            end
                        end
                    else
                        -- If not Engaged, ensure MoveSpeed is equipped
                        if world.area and world.area:contains('Adoulin') then
                            send_command('gs equip sets.Adoulin')
                        else
                            send_command('gs equip sets.MoveSpeed')
                        end
                    end
                end

                ----------------------------------------------------------------------------
                -- If distance < threshold, character is considered stopped
                ----------------------------------------------------------------------------
            elseif dist < movement_threshold then
                if moving then
                    -- Remove MoveSpeed gear
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
