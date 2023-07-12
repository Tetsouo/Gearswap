-- Spell IDs for single target spells
local spellsSingle = {
    {name = 'Flash', id = 112},
    {name = 'Blank Gaze', id = 592}
}

-- Spell IDs for area of effect spells
local spellsAoe = {
    {name = 'Jettatura', id = 575},
    {name = 'Sheep Song', id = 584},
    {name = 'Geist Wall', id = 605}
}

-- Helper function to handle the command logic
local function handleCommand(spellTable)
    local messages = {}
    for _, spellData in ipairs(spellTable) do
        local spellName = spellData.name
        local spellId = spellData.id
        local recast = windower.ffxi.get_spell_recasts()[spellId] / 60
        if recast < 1 then
            send_command('input /ma "' .. spellName .. '" <stnpc>')
            return
        elseif recast > 0 then
            local message = createMessage(spellName, recast)
            table.insert(messages, {spell = spellName, recast = recast, message = message})
        end
    end
    if #messages > 0 then
        table.sort(
            messages,
            function(a, b)
                return a.recast < b.recast
            end
        )
        add_to_chat(159, 'No spells available')
        for _, msgData in ipairs(messages) do
            add_to_chat(167, msgData.message)
        end
        add_to_chat(259, '=================================================')
    else
        add_to_chat(159, 'All spells are unavailable')
    end
end

-- Handle Single command
function handleSingleCommand()
    handleCommand(spellsSingle)
end

-- Handle Aoe command
function handleAoeCommand()
    handleCommand(spellsAoe)
end

-- Automatically use "Divine Emblem" ability
function auto_divineEmblem(spell, eventArgs)
    if spell.name == 'Flash' then
        local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]
        local divineEmblemCD = windower.ffxi.get_ability_recasts()[80]
        if spellRecast < 1 and divineEmblemCD < 1 and not buffactive['Divine Emblem'] then
            cancel_spell()
            send_command(
                'input /ja "Divine Emblem" <me>; wait 1.2; input /ma "' .. spell.name .. '" ' .. spell.target.id
            )
        else
            incapacitated(spell, eventArgs)
        end
    end
end

-- Automatically cast the 'Majesty' ability before casting spells of the 'Healing Magic' category or the spell 'Protect V'
function auto_majesty(spell, eventArgs)
    local MajestyCD = windower.ffxi.get_ability_recasts()[150]
    local spellRecast = windower.ffxi.get_spell_recasts()[spell.id]

    if (spell.action_type == 'Magic' and spell.skill == 'Healing Magic') or spell.name == 'Protect V' then
        if spellRecast < 1 then
            if not (buffactive['Amnesia'] or buffactive['Silence']) and not state.Buff.Majesty then
                if MajestyCD < 1 then
                    cancel_spell()
                    send_command(
                        string.format(
                            'input /ja "Majesty" <me>; wait 1.2; input /ma "%s" %s',
                            spell.name,
                            spell.target.id
                        )
                    )
                end
            end
        else
            eventArgs.handled = true
            cancel_spell()
        end
    end
end