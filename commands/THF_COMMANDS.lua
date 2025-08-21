---============================================================================
--- FFXI GearSwap Commands - Thief (THF) Specific Commands
---============================================================================
--- Thief command handlers for treasure hunter management, dual-boxing coordination,
--- subjob buffs automation, and alt player commands.
---
--- @file commands/THF_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-20
--- @requires utils/logger, config/config, core/dualbox
---============================================================================

local THFCommands = {}

-- Load critical dependencies
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end

local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end

local success_DualBoxUtils, DualBoxUtils = pcall(require, 'features/DUALBOX')
if not success_DualBoxUtils then
    error("Failed to load features/DUALBOX: " .. tostring(DualBoxUtils))
end

-- ===========================================================================================================
--                                     Thief Commands
-- ===========================================================================================================

--- Handles commands specific to the Thief (THF) job.
-- @param cmdParams (table): A table containing the command parameters.
-- @return (boolean): True if command was handled, false otherwise
function THFCommands.handle_thf_commands(cmdParams)
    if type(cmdParams) ~= 'table' or #cmdParams < 1 then
        log.debug("Invalid THF command parameters")
        return false
    end

    if type(cmdParams[1]) ~= 'string' then
        log.debug("THF command must be a string")
        return false
    end

    local cmd = cmdParams[1]:lower()

    -- Use the real THF buffSelf function if available
    local buffSelf_func = _G.buffSelf or function(ability)
        send_command('input /ja "' .. ability .. '" <me>')
    end

    local thfCommands = {
        thfbuff = function()
            -- THF buffSelf expects 'thfBuff' as parameter to chain Feint, Bully, Conspirator
            buffSelf_func('thfBuff')
            return true
        end,
        buff = function()
            -- Alias for thfbuff
            buffSelf_func('thfBuff')
            return true
        end,
        warbuff = function()
            -- WAR subjob buffs for THF/WAR: Berserk, Aggressor, Warcry
            if player.sub_job ~= 'WAR' then
                log.warn("WAR subjob buffs require /WAR subjob")
                return false
            end
            -- Cancel Defender if active (conflicts with Berserk)
            if buffactive['Defender'] then
                send_command('cancel defender')
                send_command(
                    'wait 1; input /ja "Berserk" <me>; wait 2; input /ja "Aggressor" <me>; wait 2; input /ja "Warcry" <me>')
            else
                send_command(
                    'input /ja "Berserk" <me>; wait 2; input /ja "Aggressor" <me>; wait 2; input /ja "Warcry" <me>')
            end
            return true
        end,
        subjob = function()
            -- Alias for warbuff
            if player.sub_job ~= 'WAR' then
                log.warn("Subjob buffs require /WAR subjob")
                return false
            end
            -- Cancel Defender if active (conflicts with Berserk)
            if buffactive['Defender'] then
                send_command('cancel defender')
                send_command(
                    'wait 1; input /ja "Berserk" <me>; wait 2; input /ja "Aggressor" <me>; wait 2; input /ja "Warcry" <me>')
            else
                send_command(
                    'input /ja "Berserk" <me>; wait 2; input /ja "Aggressor" <me>; wait 2; input /ja "Warcry" <me>')
            end
            return true
        end,
        altgeo = function()
            -- Cast Geo spell on alt player using current altPlayerGeo state
            local alt_name = config and config.get_alt_player() or 'Kaories'
            local alt_job = DualBoxUtils and DualBoxUtils.get_alt_job()

            if alt_job and alt_job ~= 'GEO' then
                add_to_chat(167, '[Alt Command] ' .. alt_name .. ' (' .. alt_job .. ') cannot cast Geo spells')
                return false
            end

            if not state or not state.altPlayerGeo then
                log.error("altPlayerGeo state not available")
                return false
            end

            local geoSpell = state.altPlayerGeo.value
            if not geoSpell then
                log.error("No Geo spell selected in altPlayerGeo state")
                return false
            end

            if DualBoxUtils and DualBoxUtils.bubble_buff_for_alt_geo then
                DualBoxUtils.bubble_buff_for_alt_geo(geoSpell, false, true)
                local job_display = alt_job and ('(' .. alt_job .. ')') or ''
                add_to_chat(158, '[Alt Command] ' .. alt_name .. ' ' .. job_display .. ' -> ' .. geoSpell)
                return true
            else
                log.error("DualBoxUtils not available for altgeo command")
                return false
            end
        end,
        altindi = function()
            -- Cast Indi spell on alt player using current altPlayerIndi state
            local alt_name = config and config.get_alt_player() or 'Kaories'
            local alt_job = DualBoxUtils and DualBoxUtils.get_alt_job()

            if alt_job and alt_job ~= 'GEO' then
                add_to_chat(167, '[Alt Command] ' .. alt_name .. ' (' .. alt_job .. ') cannot cast Indi spells')
                return false
            end

            if not state or not state.altPlayerIndi then
                log.error("altPlayerIndi state not available")
                return false
            end

            local indiSpell = state.altPlayerIndi.value
            if not indiSpell then
                log.error("No Indi spell selected in altPlayerIndi state")
                return false
            end

            if DualBoxUtils and DualBoxUtils.bubble_buff_for_alt_geo then
                DualBoxUtils.bubble_buff_for_alt_geo(indiSpell, false, false)
                local job_display = alt_job and ('(' .. alt_job .. ')') or ''
                add_to_chat(158, '[Alt Command] ' .. alt_name .. ' ' .. job_display .. ' -> ' .. indiSpell)
                return true
            else
                log.error("DualBoxUtils not available for altindi command")
                return false
            end
        end,
        altjob = function()
            -- Display or refresh alt job information
            local alt_name = config and config.get_alt_player() or 'Kaories'

            if not DualBoxUtils then
                log.error("DualBoxUtils not available")
                return false
            end

            local current_job_cached = DualBoxUtils.alt_player_job or nil
            if current_job_cached then
                add_to_chat(207, '[Alt Job] ' .. alt_name .. ' current job: ' .. current_job_cached)
            end

            DualBoxUtils.refresh_alt_job_info()
            return true
        end,
        altcast = function()
            -- Universal alt casting command that adapts to detected job
            local alt_name = config and config.get_alt_player() or 'Kaories'
            local alt_job = DualBoxUtils and DualBoxUtils.get_alt_job()
            local spell = cmdParams[2]

            if not alt_job then
                add_to_chat(167, '[Alt Cast] ' .. alt_name .. ' job unknown - use //gs c altjob to detect')
                return false
            end

            if not spell then
                add_to_chat(167, '[Alt Cast] Usage: //gs c altcast <spell_name>')
                return false
            end

            if alt_job == 'GEO' or alt_job == 'WHM' or alt_job == 'RDM' or alt_job == 'SCH' then
                send_command('send ' .. alt_name .. ' input /ma "' .. spell .. '" <t>')
                add_to_chat(158, '[Alt Cast] ' .. alt_name .. ' (' .. alt_job .. ') -> ' .. spell)
                return true
            else
                add_to_chat(167, '[Alt Cast] ' .. alt_name .. ' (' .. alt_job .. ') - spell casting not configured')
                return false
            end
        end,
        smartbuff = function()
            -- Smart subjob buff command that auto-detects subjob and applies appropriate buffs
            local subjob = player.sub_job

            if not subjob then
                log.error("Unable to detect subjob")
                return false
            end

            if subjob == 'DNC' then
                -- THF/DNC: Haste Samba
                local ability_recasts = windower.ffxi.get_ability_recasts()
                local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
                if not success_MessageUtils then
                    error("Failed to load utils/messages: " .. tostring(MessageUtils))
                end

                local messages_to_display = {}
                if not buffactive['Haste Samba'] then
                    local haste_samba_recast = ability_recasts[83] or 0
                    if haste_samba_recast == 0 then
                        send_command('input /ja "Haste Samba" <me>')
                    else
                        table.insert(messages_to_display,
                            { type = 'recast', name = 'Haste Samba', time = haste_samba_recast })
                    end
                else
                    table.insert(messages_to_display, { type = 'active', name = 'Haste Samba' })
                end

                if #messages_to_display > 0 then
                    MessageUtils.unified_status_message(messages_to_display, 'THF/DNC', true)
                end
                return true
            elseif subjob == 'WAR' then
                -- THF/WAR: Use warbuff command
                return THFCommands.handle_thf_commands({ 'warbuff' })
            elseif subjob == 'NIN' then
                -- THF/NIN: Utsusemi
                if not buffactive['Copy Image'] and not buffactive['Copy Image (2)'] and not buffactive['Copy Image (3)'] then
                    send_command('input /ma "Utsusemi: Ni" <me>')
                else
                    send_command('input /ma "Utsusemi: Ni" <me>')
                end
                return true
            elseif subjob == 'RDM' then
                -- THF/RDM: Phalanx, Stoneskin
                send_command('input /ma "Phalanx" <me>; wait 4; input /ma "Stoneskin" <me>')
                add_to_chat(158, '-> Phalanx > Stoneskin')
                return true
            elseif subjob == 'BLM' then
                -- THF/BLM: Stoneskin
                send_command('input /ma "Stoneskin" <me>')
                add_to_chat(158, '-> Stoneskin')
                return true
            elseif subjob == 'WHM' then
                -- THF/WHM: Stoneskin, Blink
                send_command('input /ma "Stoneskin" <me>; wait 4; input /ma "Blink" <me>')
                add_to_chat(158, '-> Stoneskin > Blink')
                return true
            else
                add_to_chat(167, '[Smart Buff] No configuration for THF/' .. subjob)
                return false
            end
        end,
        subbuff = function()
            -- Alias for smartbuff
            return THFCommands.handle_thf_commands({ 'smartbuff' })
        end,
        macros = function()
            -- Refresh macro book selection
            if select_default_macro_book and type(select_default_macro_book) == 'function' then
                select_default_macro_book()
                return true
            else
                add_to_chat(167, '[Macros] select_default_macro_book function not available')
                return false
            end
        end,
        setkaoriesjob = function()
            -- Manually set alt player job
            local job = cmdParams[2]
            if not job then
                add_to_chat(167, '[Set Job] Usage: //gs c setkaoriesjob <job>')
                add_to_chat(123, '[Set Job] Examples: COR, GEO, RDM, PLD')
                return false
            end

            job = job:upper()
            _G.kaories_current_job = job
            add_to_chat(207, '[Set Job] Alt player job set to: ' .. job)

            if select_default_macro_book and type(select_default_macro_book) == 'function' then
                select_default_macro_book()
            end
            return true
        end
    }

    if thfCommands[cmd] then
        local success, err = pcall(thfCommands[cmd])
        if success then
            log.info("Executed THF command: %s", cmd)
            return true
        else
            log.error("Error executing THF command %s: %s", cmd, err)
            return false
        end
    else
        log.debug("Unknown THF command: %s", cmd)
        return false
    end
end

-- Export function for global access (backward compatibility)
_G.handle_thf_commands = THFCommands.handle_thf_commands

return THFCommands
