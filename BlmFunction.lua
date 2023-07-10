function BuffSelf(spell, eventArgs)
    local allRecasts = windower.ffxi.get_spell_recasts()
    local PhalanxCD = allRecasts[106]
    -- PHALANX EST PRET
    if spell.name == 'Phalanx' and (PhalanxCD < 1 and not buffactive['Phalanx']) then
        -- PHALANX N'EST PAS PRET
        -- STONESKIN EST PRET
        local StoneskinCD = allRecasts[54]
        if StoneskinCD < 1 and not buffactive['Stoneskin'] then
            send_command('wait 4; input /ma "Stoneskin" <me>')
            -- BLINK EST PRET
            local BlinkCD = allRecasts[53]
            if BlinkCD < 1 and not buffactive['Blink'] then
                send_command('wait 9; input /ma "Blink" <me>')
                -- AQUAVEIL EST PRET
                local AquaveilCD = allRecasts[55]
                if AquaveilCD < 1 and not buffactive['Aquaveil'] then
                    send_command('wait 14; input /ma "Aquaveil" <me>')
                    -- SHOCK SPIKES EST PRET
                    local ShockSpikeCD = allRecasts[251]
                    if ShockSpikeCD < 1 and not buffactive['Shock Spikes'] then
                        send_command('wait 19; input /ma "Shock Spikes" <me>')
                    end
                end
            end
        end
    elseif spell.name == 'Phalanx' and (PhalanxCD > 1 or buffactive['Phalanx']) then
        cancel_spell()
        eventArgs.handled = true
        local StoneskinCD = allRecasts[54]
        if StoneskinCD < 1 and not buffactive['Stoneskin'] then
            send_command('input /ma "Stoneskin" <me>')
            -- BLINK EST PRET
            local BlinkCD = allRecasts[53]
            if BlinkCD < 1 and not buffactive['Blink'] then
                send_command('wait 5; input /ma "Blink" <me>')
                -- AQUAVEIL EST PRET
                local AquaveilCD = allRecasts[55]
                if AquaveilCD < 1 and not buffactive['Aquaveil'] then
                    send_command('wait 10; input /ma "Aquaveil" <me>')
                    -- SHOCK SPIKES EST PRET
                    local ShockSpikeCD = allRecasts[251]
                    if ShockSpikeCD < 1 and not buffactive['Shock Spikes'] then
                        send_command('wait 15; input /ma "Shock Spikes" <me>')
                    end
                end
            end
        elseif StoneskinCD > 1 or buffactive['Stoneskin'] then
            cancel_spell()
            -- BLINK EST PRET
            local BlinkCD = allRecasts[53]
            if BlinkCD < 1 and not buffactive['Blink'] then
                send_command('input /ma "Blink" <me>')
                -- AQUAVEIL EST PRET
                local AquaveilCD = allRecasts[55]
                if AquaveilCD < 1 and not buffactive['Aquaveil'] then
                    send_command('wait 5; input /ma "Aquaveil" <me>')
                    -- SHOCK SPIKES EST PRET
                    local ShockSpikeCD = allRecasts[251]
                    if ShockSpikeCD < 1 and not buffactive['Shock Spikes'] then
                        send_command('wait 10; input /ma "Shock Spikes" <me>')
                    end
                end
            elseif BlinkCD > 1 or buffactive['Blink'] then
                cancel_spell()
                -- AQUAVEIL EST PRET
                local AquaveilCD = allRecasts[55]
                if AquaveilCD < 1 and not buffactive['Aquaveil'] then
                    send_command('input /ma "Aquaveil" <me>')
                    -- SHOCK SPIKES EST PRET
                    local ShockSpikeCD = allRecasts[251]
                    if ShockSpikeCD < 1 and not buffactive['Shock Spikes'] then
                        send_command('wait 5; input /ma "Shock Spikes" <me>')
                    end
                elseif AquaveilCD > 1 or buffactive['Aquaveil'] then
                    cancel_spell()
                    -- SHOCK SPIKES EST PRET
                    local ShockSpikeCD = allRecasts[251]
                    if ShockSpikeCD < 1 and not buffactive['Shock Spikes'] then
                        send_command('input /ma "Shock Spikes" <me>')
                    elseif ShockSpikeCD > 1 or buffactive['Shock Spikes'] then
                        cancel_spell()
                    end
                end
            end
        end
    end
end

function refine_various_spells(spell, action, spellMap, eventArgs)
    aspirs = S {'Aspir', 'Aspir II', 'Aspir III'}
    breakgas = {'Breakga', 'Break'}
    sleeps = S {'Sleep II', 'Sleep'}
    banish = S {'Banish II', 'Banish'}
    sleepgas = S {'Sleepga II', 'Sleepga'}
    nukes =
        S {
        'Fire',
        'Blizzard',
        'Aero',
        'Stone',
        'Thunder',
        'Water',
        'Fire II',
        'Blizzard II',
        'Aero II',
        'Stone II',
        'Thunder II',
        'Water II',
        'Fire III',
        'Blizzard III',
        'Aero III',
        'Stone III',
        'Thunder III',
        'Water III',
        'Fire IV',
        'Blizzard IV',
        'Aero IV',
        'Stone IV',
        'Thunder IV',
        'Water IV',
        'Fire V',
        'Blizzard V',
        'Aero V',
        'Stone V',
        'Thunder V',
        'Water V',
        'Fire VI',
        'Blizzard VI',
        'Aero VI',
        'Stone VI',
        'Thunder VI',
        'Water VI',
        'Firaga',
        'Blizzaga',
        'Aeroga',
        'Stonega',
        'Thundaga',
        'Waterga',
        'Firaga II',
        'Blizzaga II',
        'Aeroga II',
        'Stonega II',
        'Thundaga II',
        'Waterga II',
        'Firaga III',
        'Blizzaga III',
        'Aeroga III',
        'Stonega III',
        'Thundaga III',
        'Waterga III',
        'Firaja',
        'Blizzaja',
        'Aeroja',
        'Stoneja',
        'Thundaja',
        'Waterja'
    }

    if
        not sleepgas:contains(spell.english) and not banish:contains(spell.english) and
            not sleeps:contains(spell.english) and
            not aspirs:contains(spell.english) and
            not nukes:contains(spell.english)
     then
        return
    end

    local newSpell = spell.english
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local cancelling = 'All ' .. spell.english .. ' spells are on cooldown. Cancelling spell casting.'

    if spell.name == 'Fire VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Fire V'
        end
    elseif spell.name == 'Fire V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Fire IV'
        end
    elseif spell.name == 'Fire IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Fire III'
        end
    elseif spell.name == 'Fire III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Fire II'
        end
    elseif spell.name == 'Fire II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Fire'
        end
    end

    if spell.name == 'Blizzard VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Blizzard V'
        end
    elseif spell.name == 'Blizzard V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Blizzard IV'
        end
    elseif spell.name == 'Blizzard IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Blizzard III'
        end
    elseif spell.name == 'Blizzard III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Blizzard II'
        end
    elseif spell.name == 'Blizzard II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Blizzard'
        end
    end

    if spell.name == 'Aero VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Aero V'
        end
    elseif spell.name == 'Aero V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Aero IV'
        end
    elseif spell.name == 'Aero IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Aero III'
        end
    elseif spell.name == 'Aero III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Aero II'
        end
    elseif spell.name == 'Aero II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Aero'
        end
    end

    if spell.name == 'Stone VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Stone V'
        end
    elseif spell.name == 'Stone V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Stone IV'
        end
    elseif spell.name == 'Stone IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Stone III'
        end
    elseif spell.name == 'Stone III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Stone II'
        end
    elseif spell.name == 'Stone II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Stone'
        end
    end

    if spell.name == 'Thunder VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Thunder V'
        end
    elseif spell.name == 'Thunder V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Thunder IV'
        end
    elseif spell.name == 'Thunder IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Thunder III'
        end
    elseif spell.name == 'Thunder III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Thunder II'
        end
    elseif spell.name == 'Thunder II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Thunder'
        end
    end

    if spell.name == 'Water VI' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 400 then
            newSpell = 'Water V'
        end
    elseif spell.name == 'Water V' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 300 then
            newSpell = 'Water IV'
        end
    elseif spell.name == 'Water IV' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 200 then
            newSpell = 'Water III'
        end
    elseif spell.name == 'Water III' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 100 then
            newSpell = 'Water II'
        end
    elseif spell.name == 'Water II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 50 then
            newSpell = 'Water'
        end
    end

    if spell.name == 'Sleepga II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 58 then
            newSpell = 'Sleepga'
        end
    end

    if spell.name == 'Sleep II' then
        if spell_recasts[spell.recast_id] > 0 or player.mp < 29 then
            newSpell = 'Sleep'
        end
    end

    if spell.name == 'Aspir III' then
        if spell_recasts[spell.recast_id] > 0 then
            newSpell = 'Aspir II'
        end
    elseif spell.name == 'Aspir II' then
        if spell_recasts[spell.recast_id] > 0 then
            newSpell = 'Aspir'
        end
    end

    if newSpell ~= spell.english then
        send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true
        return
    end
end

function customize_idle_set(idleSet)
    if player.tp > 2950 then
        idleSet = set_combine(idleSet, sets.TPdown)
    end
    if player.mpp < 51 then
        idleSet = set_combine(idleSet, sets.latent_refresh)
    end
    state.Buff['Mana Wall'] = buffactive['Mana Wall'] or false
    if state.Buff['Mana Wall'] then
        idleSet = set_combine(idleSet, sets.idle.PDT)
    end
    return idleSet
end

function job_precast(spell, action, spellMap, eventArgs)
    BuffSelf(spell, eventArgs)
    refine_various_spells(spell, action, spellMap, eventArgs)
end

-- Met eventArgs.handled sur true si on ne veut pas que l'equipement soit changé automatiquement.
function job_midcast(spell, action, spellMap, eventArgs)
end

-- Ce lance après que midcast normal soit terminé.
-- eventArgs est le même que que celui utilisé dans le job_midcast, dans le cas ou l'on voudrait que l'information soit persisté.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
        if buffactive.silence then -- Annule la magie ou le Ninjutsu si on est Silence ou trop loin.
            cancel_spell()
            add_to_chat(123, spell.name .. ' Canceled: [Silenced]')
            return
        else
            if player.tp > 200 or buffactive['Aftermath: Lv.2'] then
                disable('main', 'sub')
            end
        end
    end

    function job_aftercast(spell, action, spellMap, eventArgs)
    end

    if spellMap == 'Cure' and spell.target.type == 'SELF' and sets.self_healing then
        equip(sets.self_healing)
    end

    if spell.skill == 'Elemental Magic' then
        if gearswap.res.weather[world.weather_id].intensity == 2 and not string.find(spell.english, 'helix') then
            equip({waist = 'Hachirin-No-Obi'})
            add_to_chat(8, '----- Obi Equipped. -----')
        end
        if player.target.distance then
            target_distance = math.floor(player.target.distance * 10) / 10
        else
            target_distance = 0
        end
        if target_distance > 13 then
            equip({waist = 'Acuity Belt +1'})
        end
    end

    if spell.skill == 'Elemental Magic' then
        if spell.english == 'Impact' then
            equip({body = 'Twilight Cloak'})
        else
        end
    end
end
