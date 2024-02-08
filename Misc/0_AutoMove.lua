--[[Ajouter ce fichier dans Gearswap/data.

	Dans le lua de votre job (BLU.lua)...
	Ajouter la ligne suivante à la function job_setup()
		include('0_AutoMove.lua')

	Créer ce nouveau set qui contiendra que vos équipement de movement speed, comme suit :
		sets.MoveSpeed = {legs = "Carmine Cuisses +1"}

	Ajouter ce set tel quel :
	
	Maintenant, il faut mettre vos equip idle dans votre sets.Idle
	Puis mettre votre equipment movement speed dans le sets.MoveSpeed
	
	]]
    -- Ne rien toucher passé cette ligne.

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
windower.raw_register_event(
    'prerender',
    function()
        mov.counter = mov.counter + 1
        if mov.counter > 15 then
            local pl = windower.ffxi.get_mob_by_index(player.index)
            if pl and pl.x and mov.x and state.EngagedMoving.Value == 'Disabled' then
                --we want this to return a false value if these conditions were met, but we drew our weapons whilst moving.
                --we also want this value to become false if we Disable EngagedMovement while engaged.
                if state.Moving.value == 'true' and player.status == 'Engaged' then
                    state.Moving.value = 'false'
                end
                if player.status ~= 'Engaged' then
                    dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)
                    if dist > 1 and not moving then
                        state.Moving.value = 'true'
                        send_command('gs c update')
                        if world.area:contains('Adoulin') then
                            send_command('gs equip sets.Adoulin')
                        else
                            send_command('gs equip sets.MoveSpeed')
                        end

                        moving = true
                    elseif dist < 1 and moving then
                        state.Moving.value = 'false'
                        send_command('gs c update')
                        moving = false
                    end
                end
            elseif pl and pl.x and mov.x and state.EngagedMoving.Value == 'Enabled' then
                dist = math.sqrt((pl.x - mov.x) ^ 2 + (pl.y - mov.y) ^ 2 + (pl.z - mov.z) ^ 2)
                if dist > 1 and not moving then
                    state.Moving.value = 'true'
                    send_command('gs c update')
                    if world.area:contains('Adoulin') then
                        send_command('gs equip sets.Adoulin')
                    else
                        send_command('gs equip sets.MoveSpeed')
                    end

                    moving = true
                elseif dist < 1 and moving then
                    state.Moving.value = 'false'
                    send_command('gs c update')
                    moving = false
                end
            end
            if pl and pl.x then
                mov.x = pl.x
                mov.y = pl.y
                mov.z = pl.z
            end
            mov.counter = 0
        end
    end
)
