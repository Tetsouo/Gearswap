---============================================================================
--- FFXI GearSwap Commands - Scholar (SCH) Subjob Commands
---============================================================================
--- Scholar subjob command handlers for Arts management, storm spells,
--- status removal spells, and utility magic automation.
---
--- @file commands/SCH_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger, core/spells
---============================================================================

local SCHCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

-- ===========================================================================================================
--                                     Scholar Subjob Commands
-- ===========================================================================================================

--- Handles commands specific to the Scholar (SCH) subjob.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function SCHCommands.handle_sch_subjob_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.error("Invalid command parameters for SCH subjob")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.error("SCH command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    local function castStormSpell(spell)
        -- Load required dependencies
        local success_res, res = pcall(require, 'resources')
        if not success_res then
            error("Failed to load resources: " .. tostring(res))
        end
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end

        -- Normalize spell name to correct FFXI format
        local spell_normalized = spell
        if spell == 'FireStorm' then spell_normalized = 'Firestorm' end
        if spell == 'HailStorm' then spell_normalized = 'Hailstorm' end

        -- Get spell recast data using normalized name
        local spellRecasts = windower.ffxi.get_spell_recasts()
        local spell_data = res.spells:with('en', spell_normalized)
        local spell_id = spell_data and spell_data.id

        if not spell_id then
            local messages = { { type = 'error', name = spell_normalized, message = 'Spell not found' } }
            MessageUtils.unified_status_message(messages, nil, true)
            return
        end

        local recastTime_raw = spellRecasts[spell_id]
        local recastTime = recastTime_raw or 0

        -- Check if storm spell is already active
        local storm_buffs = {
            ['Firestorm'] = 'Firestorm',
            ['Sandstorm'] = 'Sandstorm',
            ['Thunderstorm'] = 'Thunderstorm',
            ['Hailstorm'] = 'Hailstorm',
            ['Rainstorm'] = 'Rainstorm',
            ['Windstorm'] = 'Windstorm',
            ['Voidstorm'] = 'Voidstorm',
            ['Aurorastorm'] = 'Aurorastorm'
        }

        local storm_buff_name = storm_buffs[spell_normalized]
        local isStormActive = storm_buff_name and buffactive[storm_buff_name]

        -- Check Klimaform status
        local klimaform_recasts = windower.ffxi.get_spell_recasts()
        local klimaform_recast_raw = klimaform_recasts[287] -- Klimaform spell ID
        local klimaform_recast = klimaform_recast_raw or 0
        local isKlimaformActive = buffactive['Klimaform']

        local messages_to_display = {}

        -- Add Klimaform status FIRST
        if isKlimaformActive then
            table.insert(messages_to_display, { type = 'active', name = 'Klimaform' })
        elseif klimaform_recast > 0 then
            table.insert(messages_to_display, { type = 'recast', name = 'Klimaform', time = klimaform_recast })
        end

        -- Add storm status SECOND
        if isStormActive then
            table.insert(messages_to_display, { type = 'active', name = spell_normalized })
        elseif recastTime > 0 then
            table.insert(messages_to_display, { type = 'recast', name = spell_normalized, time = recastTime })
        end

        -- Show combined status if either storm or Klimaform has status to display
        if #messages_to_display > 0 then
            MessageUtils.unified_status_message(messages_to_display, nil, true)
            if isStormActive or recastTime > 0 then
                return
            end
        end

        -- Storm is ready to cast - handle Klimaform first, then storm
        if not isKlimaformActive then
            if klimaform_recast <= 0 then
                send_command('input /ma "Klimaform" <me>; wait 5; input /ma "' .. spell_normalized .. '" <me>')
            else
                local klimaform_messages = { { type = 'recast', name = 'Klimaform', time = klimaform_recast } }
                MessageUtils.unified_status_message(klimaform_messages, nil, true)
                return
            end
        else
            send_command('input /ma "' .. spell_normalized .. '" <me>')
        end
    end

    local function castArtsOrAddendum(arts, addendum)
        local command
        if not buffactive[arts] then
            command = 'input /ja "' .. arts .. '" <me>'
        else
            command = 'input /ja "' .. addendum .. '" <me>'
        end
        send_command(command)
    end

    local function castSchSpell(spell, arts, addendum)
        local success_SpellUtils, SpellUtils = pcall(require, 'core/SPELLS')
        if not success_SpellUtils then
            error("Failed to load core/spells: " .. tostring(SpellUtils))
        end
        return SpellUtils.cast_sch_spell(spell, arts, addendum)
    end

    local schSpells = {
        storm = function()
            if state and state.Storm then
                castStormSpell(state.Storm.value)
                return true
            else
                log.error("state.Storm not available")
                return false
            end
        end,
        lightarts = function()
            castArtsOrAddendum('Light Arts', 'Addendum: White')
            return true
        end,
        darkarts = function()
            castArtsOrAddendum('Dark Arts', 'Addendum: Black')
            return true
        end,
        blindna = function()
            castSchSpell('Blindna', 'Light Arts', 'Addendum: White')
            return true
        end,
        poisona = function()
            castSchSpell('Poisona', 'Light Arts', 'Addendum: White')
            return true
        end,
        viruna = function()
            castSchSpell('Viruna', 'Light Arts', 'Addendum: White')
            return true
        end,
        stona = function()
            castSchSpell('Stona', 'Light Arts', 'Addendum: White')
            return true
        end,
        silena = function()
            castSchSpell('Silena', 'Light Arts', 'Addendum: White')
            return true
        end,
        paralyna = function()
            castSchSpell('Paralyna', 'Light Arts', 'Addendum: White')
            return true
        end,
        cursna = function()
            castSchSpell('Cursna', 'Light Arts', 'Addendum: White')
            return true
        end,
        erase = function()
            castSchSpell('Erase', 'Light Arts', 'Addendum: White')
            return true
        end,
        dispel = function()
            castSchSpell('Dispel', 'Dark Arts', 'Addendum: Black')
            return true
        end,
        sneak = function()
            castSchSpell('Sneak', 'Light Arts', 'Accession')
            return true
        end,
        invi = function()
            castSchSpell('Invisible', 'Light Arts', 'Accession')
            return true
        end
    }

    if schSpells[cmd] then
        local success = schSpells[cmd]()
        if success then
            log.info("Executed SCH subjob command: %s", cmd)
        end
        return success
    else
        log.debug("Unknown SCH subjob command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_sch_subjob_commands = SCHCommands.handle_sch_subjob_commands

return SCHCommands
