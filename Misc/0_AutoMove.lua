--------------------------------------------------------------------------------
-- 0_AutoMove.lua
--------------------------------------------------------------------------------
-- Description:
--   This file allows automatic equip of movement speed gear (sets.MoveSpeed)
--   when the character moves, and reverts gear when stopping or becoming engaged
--   (depending on the EngagedMoving state).
--
-- Usage:
--   1) Place this file in GearSwap/data.
--   2) In your job Lua (e.g. BLU.lua), within job_setup():
--        include('0_AutoMove.lua')
--   3) Create a movement speed set like:
--        sets.MoveSpeed = { legs="Carmine Cuisses +1" }
--   4) Optionally create an Adoulin set for city movement:
--        sets.Adoulin = set_combine(sets.MoveSpeed, { body="Councilor's Garb" })
--   5) Put your normal idle gear in sets.Idle and your movement gear in sets.MoveSpeed.
--------------------------------------------------------------------------------

-- Do not modify the section below, unless you know what you are doing.

sets.Adoulin = set_combine(sets.MoveSpeed, { body = "Councilor's Garb" })

state.Moving = M('false', 'true')
state.EngagedMoving = M('Disabled', 'Enabled')

mov = { counter = 0 }
if player and player.index and windower.ffxi.get_mob_by_index(player.index) then
    mov.x = windower.ffxi.get_mob_by_index(player.index).x
    mov.y = windower.ffxi.get_mob_by_index(player.index).y
    mov.z = windower.ffxi.get_mob_by_index(player.index).z
end

moving = false

windower.raw_register_event('prerender', function()
    mov.counter = mov.counter + 1
    -- Check every 15 prerender ticks to reduce spam
    if mov.counter > 15 then
        local pl = windower.ffxi.get_mob_by_index(player.index)
        if pl and pl.x and mov.x then
            local dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)

            ----------------------------------------------------------------------------
            -- If distance > 1, character is considered in motion
            ----------------------------------------------------------------------------
            if dist > 1 then
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
                -- If distance < 1, character is considered stopped
                ----------------------------------------------------------------------------
            elseif dist < 1 then
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
