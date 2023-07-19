--============================================================--
--=                    BLM_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2023-07-18                  =--
--============================================================--


-- This function buffs the player with certain spells based on their recast time and current buffs.
    local function BuffSelf()
        -- Retrieve the spell recast times.
        local SpellRecasts = windower.ffxi.get_spell_recasts()
        -- Define an array of spells with their respective recasts and delays.
        local spells = {
            {name = 'Phalanx', recast = SpellRecasts[106], delay = 0},
            {name = 'Stoneskin', recast = SpellRecasts[54], delay = 5},
            {name = 'Blink', recast = SpellRecasts[53], delay = 5},
            {name = 'Aquaveil', recast = SpellRecasts[55], delay = 5},
            {name = 'Shock Spikes', recast = SpellRecasts[251], delay = 5}
        }
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
    local spellCorrespondence = {
        Fire = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Blizzard = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Aero = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Stone = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Thunder = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Water = {['VI'] = {replace = 'V'}, ['V'] = {replace = 'IV'}, ['IV'] = {replace = 'III'}, ['III'] = {replace = 'II'}, ['II'] = {replace = ''}},
        Sleepga = {['II'] = {replace = ''}},
        Sleep = {['II'] = {replace = ''}},
        Aspir = {['III'] = {replace = 'II'}, ['II'] = {replace = ''}}
    }

    -- Determines if the spell should be replaced.
    -- It takes the spell's name as a parameter and returns a boolean value.
    local function shouldReplaceSpell(spellName)
        -- Extract the spell category and level from the spell name using pattern matching.
        local spellCategory, spellLevel = spellName:match('(%a+)%s*(%a*)')

        -- Check if the spell category has corresponding replacements.
        local correspondence = spellCorrespondence[spellCategory]
        if correspondence then
            -- Check if the spell level has a replacement.
            local replacement = correspondence[spellLevel]
            if replacement then
                -- Check if the spell is on recast or if the player has insufficient MP.
                if spell_recasts[spell.recast_id] > 0 then
                    return true
                elseif player_mp < spell.mp_cost then
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
        local replacement = correspondence[spellLevel].replace
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
            newSpell = spellCategory .. ' ' .. replacement
        end
    end

    -- If the new spell is different from the original English name, cast the new spell.
    if newSpell ~= spell.english then
        -- Construct the command to cast the new spell with the appropriate target.
        send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        -- Cancel the event to prevent the original spell from being cast.
        eventArgs.cancel = true
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

-- Handles custom commands specific to the job.
-- Parameters:
--   cmdParams (table): The command parameters
--   eventArgs (table): Additional event arguments
function job_self_command(cmdParams)
    if cmdParams[1]:lower() == 'buffself' then
        BuffSelf()
    end
end