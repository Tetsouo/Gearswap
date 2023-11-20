--============================================================--
--=                    BLM_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--

-- This function buffs the player with certain spells based on their recast time and current buffs.
    function BuffSelf()
        -- Retrieve the spell recast times.
        local SpellRecasts = windower.ffxi.get_spell_recasts()
        local spells = {}
        if player.sub_job == 'RDM' then
            spells = {
                -- Define an array of spells with their respective recasts and delays.
                {name = 'Phalanx', recast = SpellRecasts[106], delay = 0},
                {name = 'Stoneskin', recast = SpellRecasts[54], delay = 5},
                {name = 'Blink', recast = SpellRecasts[53], delay = 5},
                {name = 'Aquaveil', recast = SpellRecasts[55], delay = 5},
                {name = 'Ice Spikes', recast = SpellRecasts[251], delay = 5}
            }
        else
            spells = {
                -- Define an array of spells with their respective recasts and delays.
                {name = 'Stoneskin', recast = SpellRecasts[54], delay = 0},
                {name = 'Blink', recast = SpellRecasts[53], delay = 5},
                {name = 'Aquaveil', recast = SpellRecasts[55], delay = 5},
                {name = 'Ice Spikes', recast = SpellRecasts[251], delay = 5}
            }
        end
        -- Initialize variables for spell delay, ready spell, and delayed spells.
        local spellDelay = 0
        local readySpell = nil
        local delayedSpells = {}

        -- Iterate over the spells array.
        for _, spell in ipairs(spells) do
            -- Check if the buff is currently active.
            local buffActive = buffactive[spell.name]
            -- Retrieve the spell recast time.
            local spellRecast = spell.recast
            -- Set the spell delay.
            spellDelay = spell.delay
            -- Check if the buff is not active and the spell is off recast.
            if not buffActive and spellRecast < 1 then
                -- If there is no ready spell, set the current spell as the ready spell.
                if not readySpell then
                    readySpell = spell
                else
                    -- Otherwise, add the current spell to the delayed spells.
                    table.insert(delayedSpells, spell)
                end
            end
        end

        -- If there is a ready spell, cast it on the player.
        if readySpell then
            send_command('input /ma "' .. readySpell.name .. '" <me>')
        end

        -- Iterate over the delayed spells.
        for _, spell in ipairs(delayedSpells) do
            -- Wait for the spell delay, then cast the spell on the player.
            send_command('wait ' .. spellDelay .. '; input /ma "' .. spell.name .. '" <me>')
            -- Update the spell delay for the next delayed spell.
            spellDelay = spellDelay + spell.delay
        end
    end    

-- Refines various spells based on certain conditions.
-- Parameters:
--   spell (table): The original spell.
--   eventArgs (table): Additional event arguments.
function refine_various_spells(spell, eventArgs)
    -- Copy the English name of the spell to a new variable.
    local newSpell = spell.english
    -- Retrieve the spell recasts and player's MP.
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp
    -- Define a table that maps spell categories and levels to replacement spells.
    local spellCorrespondence = {}
    if state.TierSpell.value == 'VI' then
        spellCorrespondence = {
            Fire = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Blizzard = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Aero = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Stone = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Thunder = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Water = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}},
            Sleepga = {['II'] = {replace = ''}},
            Sleep = {['II'] = {replace = ''}},
            Aspir = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Firaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Blizzaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Aeroga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Stonega = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Thundaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Waterga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Firaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Blizzaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Aeroja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Stoneja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Thundaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Waterja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        }
    else
        spellCorrespondence = {
            Fire = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Blizzard = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Aero = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Stone = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Thunder = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Water = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Sleepga = {['II'] = {replace = ''}},
            Sleep = {['II'] = {replace = ''}},
            Aspir = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Firaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Blizzaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Aeroga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Stonega = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Thundaga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Waterga = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Firaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Blizzaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Aeroja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Stoneja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Thundaja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
            Waterja = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        }
    end

    -- Determines if the spell should be replaced.
    -- It takes the spell's name as a parameter and returns a boolean value.
    local function shouldReplaceSpell(spellName)
        -- Extract the spell category and level from the spell name using pattern matching.
        local spellCategory, spellLevel = spellName:match('(%a+)%s*(%a*)')
        local correspondence
        local replacement
        correspondence = spellCorrespondence[spellCategory]
        -- Check if the spell category has corresponding replacements.
        if correspondence then
            if spellLevel ~= '' then
                replacement = correspondence[spellLevel]
            else
                replacement = correspondence
            end
            -- Check if the spell level has a replacement.
            if replacement then
                -- Check if the spell is on recast or if the player has insufficient MP.
                if spell_recasts[spell.recast_id] > 0 or player.mp < spell.mp_cost then
                    return true
                end
            end
        end
        return false
    end

    -- Displays a message indicating that the spell cannot be cast.
    -- It takes the name of the spell as a parameter.
    local function recastMessage(nameSpell)
        -- Construct the message with special characters and variables.
        local message =
            string.char(0x1F, 161) .. 'Cannot cast spell: [' ..
            string.char(0x1F, 057) .. nameSpell ..
            string.char(0x1F, 161) .. ']' ..
            ' Not enough Mana: ' .. '('..
            string.char(0x1F, 057) .. player_mp .. 'MP' ..
            string.char(0x1F, 161) ..')'..
            '\n' ..
            string.char(0x1F, SEPARATOR) .. '================================================='
        -- Display the message in the chat window.
        windower.add_to_chat(123, message)
    end

    -- Check if the spell should be replaced.
    if shouldReplaceSpell(spell.name) then
        -- Extract the spell category and level from the spell name.
        local spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
        -- Retrieve the replacement spell from the correspondence table.
        local correspondence = spellCorrespondence[spellCategory]
        if 
            spell.name == 'Firaja' or 
            spell.name == 'Blizzaja' or 
            spell.name == 'Aeroja' or 
            spell.name == 'Stoneja' or 
            spell.name == 'Thundaja' or
            spell.name == 'Waterja' then
                replacement = string.gsub(spell.name, "ja", "ga")
                replacement = replacement.." III"
        else
            if correspondence then
                if spellLevel ~= '' then
                    replacement = correspondence[spellLevel].replace
                else
                    replacement = ''
                end
            end
    end
        if replacement == '' then
            -- If there is no replacement, set the new spell to the spell category.
            newSpell = spellCategory
            if newSpell ~= 'Aspir' then
                -- For spells other than 'Aspir', check if the player has sufficient MP to cast.
                if player_mp < 9 then
                    -- Cancel the spell, display the recast message, and return.
                    cancel_spell()
                    recastMessage(newSpell)
                    return
                end
            else
                -- For 'Aspir', check if the player has sufficient MP to cast.
                if player_mp < 10 then
                    -- Cancel the spell, display the recast message, and return.
                    cancel_spell()
                    recastMessage(newSpell)
                    return
                end
            end
        else
            -- If there is a replacement, set the new spell to the category and replacement level.
            if 
            spell.name == 'Firaja' or 
            spell.name == 'Blizzaja' or 
            spell.name == 'Aeroja' or 
            spell.name == 'Stoneja' or 
            spell.name == 'Thundaja' or
            spell.name == 'Waterja' then
                newSpell = replacement
            else
                newSpell = spellCategory .. ' ' .. replacement
            end
        end
    end

    -- If the new spell is different from the original English name, cast the new spell.
    if newSpell ~= spell.english then
        -- Construct the command to cast the new spell with the appropriate target.
        send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        -- Cancel the event to prevent the original spell from being cast.
        eventArgs.cancel = true
    else
        spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
        if state.CastingMode.value == 'MagicBurst' and spell.skill == 'Elemental Magic' then
            if spellLevel == 'VI' then
                send_command('wait 2; input /p Casting => '..spellCategory..':'..spellLevel..' [Nuke]')
            else
                send_command('input /p Casting => '..spellCategory..' '..spellLevel..' [Nuke]')
            end
        end
    end
end

-- Customizes the idle gear set based on specific conditions.
-- Parameters:
--   idleSet (table): The base idle gear set to be customized.
function customize_idle_set(idleSet)
    -- Check if the "Manawall" condition is true.
    if Manawall then
        -- If "Manawall" is true, combine the base idle set with the "PDT" (Physical Damage Taken) idle set.
        idleSet = set_combine(idleSet, sets.idle.PDT)
    end
    -- Return the customized idle gear set.
    return idleSet
end

-- Handles actions to be performed when a spell is interrupted.
-- Parameters:
--   spell (table): The interrupted spell.
--   eventArgs (table): Additional event arguments.
function handleInterruptedSpell(spell, eventArgs)
    -- Equip the idle gear set.
    equip(sets.idle)
    -- Set the "handled" field of eventArgs to true.
    eventArgs.handled = true
    -- Create a formatted message indicating that the spell was interrupted.
    local message = createFormatMsg('Spell interrupted:', spell.name)
    -- Add the message to the chat log.
    add_to_chat(123, message)
end

-- This function is called SaveMP and appears to be related to setting a specific gear based on the player's current MP value.
    function SaveMP()
        if state.Xp.value == 'True' then
            sets.midcast['Dark Magic'] = {
                main = 'Malignance Pole',
                sub = 'Enki Strap',
                ammo = 'Ghastly Tathlum +1',
                head = 'Wicce Petasos +3',
                body = 'Wicce Coat +3',
                hands = 'wicce gloves +3',
                legs = 'Wicce Chausses +3',
                feet = 'Wicce Sabots +3',
                neck = 'Loricate Torque +1',
                waist = 'Acuity Belt +1',
                left_ear = 'Ethereal Earring',
                right_ear = 'Lugalbanda Earring',
                left_ring = StikiRing1,
                right_ring = StikiRing2,
                back = "Taranus's Cape",
            }
            sets.midcast.Aspir = {
                main = 'Malignance Pole',
                sub = 'Enki Strap',
                ammo = 'Ghastly Tathlum +1',
                head = 'Wicce Petasos +3',
                body = 'Wicce Coat +3',
                hands = 'wicce gloves +3',
                legs = 'Wicce Chausses +3',
                feet = 'Wicce Sabots +3',
                neck = 'Loricate Torque +1',
                waist = 'Acuity Belt +1',
                left_ear = 'Ethereal Earring',
                right_ear = 'Lugalbanda Earring',
                left_ring = StikiRing1,
                right_ring = StikiRing2,
                back = "Taranus's Cape",
            }
            sets.midcast['Elemental Magic'] = {
                main = "Bunzi's rod",
                sub = 'Ammurapi Shield',
                ammo = 'Ghastly tathlum +1',
                head = 'Wicce Petasos +3',
                body = "Spaekona's Coat +3",
                hands = 'wicce gloves +3',
                legs = 'Wicce Chausses +3',
                feet = 'Wicce Sabots +3',
                neck = 'Src. Stole +2',
                waist = "Orpheus's Sash",
                left_ear = 'Malignance Earring',
                right_ear= "Regal Earring",
                left_ring = 'Freke Ring',
                right_ring = 'Defending Ring',
                back = "Taranus's Cape",
            }
        else
            sets.midcast['Dark Magic'] = {
                main={ name="Rubicundity", augments={'Mag. Acc.+6','"Mag.Atk.Bns."+7','Dark magic skill +7',}},
                sub="Ammurapi Shield",
                ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
                head={ name="Merlinic Hood", augments={'Mag. Acc.+6','"Drain" and "Aspir" potency +10','INT+6','"Mag.Atk.Bns."+2',}},
                body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+30','"Drain" and "Aspir" potency +11','INT+3','Mag. Acc.+4',}},
                hands={ name="Merlinic Dastanas", augments={'"Drain" and "Aspir" potency +10','"Mag.Atk.Bns."+14',}},
                legs="Wicce Chausses +3",
                feet="Agwu's Pigaches",
                neck="Erra Pendant",
                waist="Fucho-no-Obi",
                left_ear="Malignance Earring",
                right_ear="Wicce Earring +1",
                left_ring="Metamor. Ring +1",
                right_ring="Evanescence Ring",
                back= "Taranus's Cape",
            }
            sets.midcast.Aspir = {
                main={ name="Rubicundity", augments={'Mag. Acc.+6','"Mag.Atk.Bns."+7','Dark magic skill +7',}},
                sub="Ammurapi Shield",
                ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
                head={ name="Merlinic Hood", augments={'Mag. Acc.+6','"Drain" and "Aspir" potency +10','INT+6','"Mag.Atk.Bns."+2',}},
                body={ name="Merlinic Jubbah", augments={'"Mag.Atk.Bns."+30','"Drain" and "Aspir" potency +11','INT+3','Mag. Acc.+4',}},
                hands={ name="Merlinic Dastanas", augments={'"Drain" and "Aspir" potency +10','"Mag.Atk.Bns."+14',}},
                legs="Wicce Chausses +3",
                feet="Agwu's Pigaches",
                neck="Erra Pendant",
                waist="Fucho-no-Obi",
                left_ear="Malignance Earring",
                right_ear="Wicce Earring +1",
                left_ring="Metamor. Ring +1",
                right_ring="Evanescence Ring",
                back= "Taranus's Cape",
            }
            -- Check if the player's MP is less than 1000.
            if player.mp < 1000 then
                if state.CastingMode.value == 'Normal' then
                    -- If the MP is below 1000, update the gear set for 'Elemental Magic' to include the body piece "Spaekona's Coat +3".
                    sets.midcast['Elemental Magic'] = {
                        main = "Bunzi's rod",
                        sub = 'Ammurapi Shield',
                        ammo = 'Sroda tathlum',
                        head = 'Wicce Petasos +3',
                        body = "Spaekona's Coat +3",
                        hands = 'wicce gloves +3',
                        legs = 'Wicce Chausses +3',
                        feet = 'Wicce Sabots +3',
                        neck = 'Src. Stole +2',
                        waist = "Orpheus's Sash",
                        left_ear = 'Malignance Earring',
                        right_ear= "Regal Earring",
                        left_ring = 'Freke Ring',
                        right_ring = 'Metamor. Ring +1',
                        back = "Taranus's Cape",
                        }
                else
                    sets.midcast['Elemental Magic'].MagicBurst = {
                        main = "Bunzi's rod",
                        sub = 'Ammurapi Shield',
                        ammo = 'Ghastly tathlum',
                        head="Wicce Petasos +3",
                        body="Spaekona's Coat +3",
                        hands="Wicce Gloves +3",
                        legs="Wicce Chausses +3",
                        feet = "Wicce sabots +3",
                        neck="Src. Stole +2",
                        waist = "Hachirin-no-obi",
                        left_ear="Malignance Earring",
                        right_ear= "Regal Earring",
                        left_ring="Freke Ring",
                        right_ring="Metamor. Ring +1",
                        back="Taranus's Cape",
                }
                end
            else
                if state.CastingMode.value == 'Normal' then
                    -- If the MP is 1000 or higher, update the gear set for 'Elemental Magic' to include the body piece "Wicce Coat +3".
                    sets.midcast['Elemental Magic'] = {
                        main = "Bunzi's rod",
                        sub = 'Ammurapi Shield',
                        ammo = 'Sroda tathlum',
                        head = 'Wicce Petasos +3',
                        body = 'Wicce Coat +3',
                        hands = 'wicce gloves +3',
                        legs = 'Wicce Chausses +3',
                        feet = 'Wicce Sabots +3',
                        neck = 'Src. Stole +2',
                        waist = "Orpheus's Sash",
                        left_ear = 'Malignance Earring',
                        right_ear= "Regal Earring",
                        left_ring = 'Freke Ring',
                        right_ring = 'Metamor. Ring +1',
                        back = "Taranus's Cape",
                    }
                else
                    sets.midcast['Elemental Magic'].MagicBurst = {
                        main = "Bunzi's rod",
                        sub = 'Ammurapi Shield',
                        ammo = 'Ghastly tathlum',
                        head="Wicce Petasos +3",
                        body="Wicce Coat +3",
                        hands="Wicce Gloves +3",
                        legs="Wicce Chausses +3",
                        feet = "Wicce sabots +3",
                        neck="Src. Stole +2",
                        waist = "Hachirin-no-obi",
                        left_ear="Malignance Earring",
                        right_ear= "Regal Earring",
                        left_ring="Freke Ring",
                        right_ring="Metamor. Ring +1",
                        back="Taranus's Cape",
                }
                end
            end
        end
    end

    function checkArts(spell, eventArgs)
        if spell.skill == 'Elemental Magic' and not (buffactive['Dark Arts'] or buffactive['Addendum: Black']) then
            cancel_spell()
            send_command('input /ja "Dark Arts" <me>; wait 3; input /ma '.. spell.name ..' <stnpc>')
        end
    end