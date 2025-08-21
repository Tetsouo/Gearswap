---============================================================================
--- FFXI GearSwap Core Module - Dual-Boxing Coordination Utilities
---============================================================================
--- Professional dual-boxing system for coordinating multiple FFXI characters.
--- Provides automated spell coordination, target selection, buff management,
--- and synchronized character actions. Core features include:
---
--- • **Multi-Character Coordination** - Synchronized actions between main/alt
--- • **Intelligent Target Selection** - Context-aware spell targeting
--- • **Geomancer Integration** - Geo-spell and Indi-spell automation
--- • **Scholar Stratagem Support** - Light/Dark arts coordination
--- • **Buff State Synchronization** - Cross-character buff tracking
--- • **Party Management** - Dynamic party member detection and targeting
--- • **Spell Sequence Automation** - Complex multi-character spell rotations
--- • **Error Recovery** - Robust handling of character disconnections
---
--- This module enables seamless dual-boxing experiences by automating the
--- complex coordination required between multiple characters, with special
--- emphasis on support job combinations (GEO/SCH supporting DD jobs).
---
--- @file core/dualbox.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-01-05 | Modified: 2025-08-05
--- @requires config/config, utils/logger, utils/messages
---
--- @usage
---   local DualBoxUtils = require('features/DUALBOX')
---   DualBoxUtils.bubble_buff_for_alt_geo('Geo-Haste', false, true)
---   DualBoxUtils.apply_spell_sequence_to_target(spell_sequence, target_name)
---
--- @see config/settings.lua for dual-boxing player name configuration
---============================================================================

local DualBoxUtils = {}

-- Load critical dependencies for dual-boxing coordination
local success_config, config = pcall(require, 'config/config')
if not success_config then
    error("Failed to load config/config: " .. tostring(config))
end
local success_log, log = pcall(require, 'utils/LOGGER')
if not success_log then
    error("Failed to load utils/logger: " .. tostring(log))
end
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end
local success_UtilityUtils, UtilityUtils = pcall(require, 'utils/HELPERS')
if not success_UtilityUtils then
    error("Failed to load utils/HELPERS: " .. tostring(UtilityUtils))
end

-- Get player names from config
local mainPlayerName = config.get_main_player()
local altPlayerName = config.get_alt_player()

-- Alt player job tracking
local alt_player_job = nil
local alt_job_last_check = 0
local alt_job_check_interval = 30 -- Check every 30 seconds

-- Expose alt_player_job for external access (read-only)
DualBoxUtils.alt_player_job = nil

-- Global variable for easy access across all modules
_G.kaories_current_job = nil

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

-- ===========================================================================================================
--                                     Dual-Box State Management
-- ===========================================================================================================

-- Define an object to store the current alt state values
DualBoxUtils.altState = {}

--- Updates the alt state object with the current state values.
-- This function synchronizes the alternate state with the main state variables.
function DualBoxUtils.update_alt_state()
    if type(state) ~= 'table' then
        log.error("State object not available for alt state update")
        return
    end

    local function update_state_field(stateField, altStateField)
        if state[stateField] and type(state[stateField]) == 'table' and state[stateField].value then
            DualBoxUtils.altState[altStateField] = state[stateField].value
        else
            log.warn("State field %s not found or invalid", stateField)
        end
    end

    -- Update all alt state fields
    update_state_field('altPlayerLight', 'Light')
    update_state_field('altPlayerTier', 'Tier')
    update_state_field('altPlayerDark', 'Dark')
    update_state_field('altPlayera', 'Ra')
    update_state_field('altPlayerGeo', 'Geo')
    update_state_field('altPlayerIndi', 'Indi')
    update_state_field('altPlayerEntrust', 'Entrust')
end

-- ===========================================================================================================
--                                     Alt Player Job Detection (Send Command Only)
-- ===========================================================================================================

--- Send job query to alt player and wait for send response
--- Alt player should respond with: send Tetsouo /tell <self> [ALTJOB_RESPONSE_<id>] <job>
function DualBoxUtils.query_alt_job()
    if not altPlayerName then
        return
    end

    local mainPlayerName = config.get_main_player()
    if not mainPlayerName then
        log.error("Main player name not configured")
        return
    end

    -- Send command to alt to report job back via send command
    local query_id = os.time() -- Use timestamp as unique ID

    -- Send command to Kaories to report her actual job
    -- Kaories must have the job_self_command that handles 'reportjob'
    send_command('send ' .. altPlayerName .. ' gs c reportjob ' .. mainPlayerName .. ' ' .. query_id)
    log.debug("Sent job query to %s with ID: %s", altPlayerName, query_id)

    -- Store the query ID for response matching
    DualBoxUtils.pending_job_query = query_id

    -- Set a timeout using send_command wait (more FFXI-friendly)
    send_command('wait 10; lua c "if DualBoxUtils and DualBoxUtils.pending_job_query == ' ..
    query_id ..
    ' then DualBoxUtils.pending_job_query = nil; add_to_chat(167, \'[Job Query] Timeout waiting for response\'); end"')
end

--- Process incoming tell messages to detect job responses
--- This should be called from an incoming_text event handler
--- @param message string The tell message received
function DualBoxUtils.process_tell_message(message)
    if not message then
        return
    end

    -- Look for job response pattern in tell
    local response_pattern = '%[ALTJOB_RESPONSE_(%d+)%] (%w+)'
    local query_id, job_name = message:match(response_pattern)

    if query_id and job_name then
        query_id = tonumber(query_id)

        -- Check if this response matches our pending query
        if DualBoxUtils.pending_job_query == query_id then
            DualBoxUtils.pending_job_query = nil
            job_name = job_name:upper() -- Normalize to uppercase
            DualBoxUtils.update_alt_job(job_name)
            add_to_chat(207, '[Job Query] ' .. altPlayerName .. ' responded: ' .. job_name)
            return true
        else
            log.debug("Received job response but query ID mismatch: %s vs %s", query_id, DualBoxUtils.pending_job_query)
        end
    end

    return false
end

--- Update alt player job information
--- @param job_name string The detected job name
function DualBoxUtils.update_alt_job(job_name)
    if job_name and job_name ~= alt_player_job then
        local old_job = alt_player_job or 'Unknown'
        alt_player_job = job_name
        alt_job_last_check = os.time()

        -- Update exposed variable for external access
        DualBoxUtils.alt_player_job = job_name

        -- Update global variable for easy access
        _G.kaories_current_job = job_name
        -- Removed debug message

        log.info("Alt player job updated: %s -> %s", old_job, job_name)

        -- Update available spells/commands based on new job
        DualBoxUtils.refresh_job_commands()
    end
end

--- Get current alt player job
--- @return string|nil Current job or nil if unknown
function DualBoxUtils.get_alt_job()
    return alt_player_job
end

--- Refresh alt player job information using send command method only
function DualBoxUtils.refresh_alt_job_info()
    -- Method 1: Try to read from file first
    local file = io.open('kaories_job.txt', 'r')
    if file then
        local job = file:read('*all')
        file:close()
        if job and job ~= '' then
            job = job:gsub('%s+', '') -- Remove whitespace
            DualBoxUtils.update_alt_job(job)
            return
        end
    end

    -- Method 2: Use send command method as fallback
    DualBoxUtils.query_alt_job()
end

--- Refresh available commands based on alt job
function DualBoxUtils.refresh_job_commands()
    if not alt_player_job then
        return
    end

    -- Update state options based on detected job
    if alt_player_job == 'GEO' then
        log.debug("Refreshing commands for GEO alt player")
        -- GEO commands are already configured
    elseif alt_player_job == 'WHM' then
        log.debug("Refreshing commands for WHM alt player")
        -- Could update healing spell options
    elseif alt_player_job == 'RDM' then
        log.debug("Refreshing commands for RDM alt player")
        -- Could update enfeebling/enhancing options
    elseif alt_player_job == 'SCH' then
        log.debug("Refreshing commands for SCH alt player")
        -- Could update stratagem options
    end
end

-- ===========================================================================================================
--                                     Target Management
-- ===========================================================================================================

--- Retrieves the ID and name of the current target.
-- @return (number, string) The ID and name of the current target, or nil if no target is selected.
function DualBoxUtils.get_current_target_id_and_name()
    local success, target = pcall(windower.ffxi.get_mob_by_target, 'lastst')
    if not success or not target then
        log.debug("No target found or error getting target")
        return nil, nil
    end

    return target.id, target.name
end

-- ===========================================================================================================
--                                     Geomancer Alt Functions
-- ===========================================================================================================

-- List of spells that should be targeted on the main player
local mainPlayerSpells = {
    'Geo-Voidance', 'Geo-Precision', 'Geo-Regen', 'Geo-Attunement', 'Geo-Focus',
    'Geo-Barrier', 'Geo-Refresh', 'Geo-CHR', 'Geo-MND', 'Geo-Fury', 'Geo-INT',
    'Geo-AGI', 'Geo-Fend', 'Geo-VIT', 'Geo-DEX', 'Geo-Acumen', 'Geo-Haste'
}

--- Buffing sequence handler for an alternate Geomancer character.
-- @param altSpell (string): The name of the spell to cast.
-- @param isEntrust (boolean): If true, the "Entrust" ability will be used before casting the spell.
-- @param isGeo (boolean): If true, the "Full Circle" ability will be used before casting the Geo spell.
function DualBoxUtils.bubble_buff_for_alt_geo(altSpell, isEntrust, isGeo)
    if type(altSpell) ~= 'string' or type(isEntrust) ~= 'boolean' or type(isGeo) ~= 'boolean' then
        log.error('Invalid input parameters for bubble_buff_for_alt_geo')
        return
    end

    local targetid, targetname = DualBoxUtils.get_current_target_id_and_name()

    if not targetid or not targetname then
        targetid = 0
        targetname = 'NoTarget'
    end

    local spellToCast = altSpell
    local targetForGeo = targetid

    -- Check if spell should target main player
    for _, spell in ipairs(mainPlayerSpells) do
        if altSpell == spell then
            targetForGeo = '<' .. mainPlayerName .. '>'
            break
        end
    end

    local command = 'send ' .. altPlayerName

    if isEntrust then
        if targetname ~= altPlayerName then
            command = command .. ' /ja "Entrust" <' .. altPlayerName .. '>'
        end
        command = command .. '; wait 2; send ' .. altPlayerName .. ' ' .. spellToCast .. ' ' .. targetid
    elseif isGeo then
        -- Check if alt player has pet (indicates party member)
        local has_pet = DualBoxUtils.find_member_and_pet_in_party(altPlayerName)

        if has_pet then
            command = command .. ' /ja "Full Circle" <' .. altPlayerName .. '>'
            command = command .. '; wait 2; send ' .. altPlayerName .. ' ' .. spellToCast .. ' ' .. targetForGeo
            command = command .. '; wait 4; send ' .. altPlayerName .. ' Cure <' .. mainPlayerName .. '>'
        else
            command = command .. ' ' .. spellToCast .. ' ' .. targetForGeo
            command = command .. '; wait 4; send ' .. altPlayerName .. ' Cure <' .. mainPlayerName .. '>'
        end
    else
        command = command .. ' ' .. spellToCast .. ' ' .. '<' .. altPlayerName .. '>'
    end

    local success, error_msg = pcall(send_command, command)
    if not success then
        log.error('Failed to send geo command: %s', error_msg or 'unknown error')
    else
        log.info('Sent geo command for %s: %s', altSpell, isEntrust and 'Entrust' or isGeo and 'Geo' or 'Indi')
    end
end

-- ===========================================================================================================
--                                     Nuking Alt Functions
-- ===========================================================================================================

--- Handles the casting of an alternate spell
-- @param altSpell (string): The name of the alternate spell to cast
-- @param altTier (string or nil): The tier of the alternate spell to cast
-- @param isRaSpell (boolean): Indicates whether the spell is a Ra spell
function DualBoxUtils.handle_alt_nuke(altSpell, altTier, isRaSpell)
    -- Input validation
    if type(altSpell) ~= 'string' or altSpell == '' then
        log.error("altSpell must be a non-empty string")
        return false
    end

    if altTier ~= nil and (type(altTier) ~= 'string' or altTier == '') then
        log.error("altTier must be a non-empty string or nil")
        return false
    end

    if type(isRaSpell) ~= 'boolean' then
        log.error("isRaSpell must be a boolean")
        return false
    end

    local spellToCast = altSpell .. (isRaSpell and ' III' or altTier or '')

    local targetid, targetname = UtilityUtils.get_current_target_id_and_name()

    if player.status == 'Engaged' then
        if targetid then
            local command = string.format(
                'send %s /assist <%s>; wait 1; send %s %s <t>',
                altPlayerName, mainPlayerName, altPlayerName, spellToCast
            )

            local success, err = pcall(send_command, command)
            if not success then
                log.error('Failed to send alt nuke command (engaged): %s', err or 'unknown error')
                return false
            end

            log.info('Alt nuke sent (engaged): %s', spellToCast)
            return true
        end
    else
        local mob = windower.ffxi.get_mob_by_target('lastst')
        if mob and mob.id then
            local command = string.format('send %s %s %d', altPlayerName, spellToCast, mob.id)

            local success, err = pcall(send_command, command)
            if not success then
                log.error('Failed to send alt nuke command (not engaged): %s', err or 'unknown error')
                return false
            end

            log.info('Alt nuke sent (not engaged): %s to target %d', spellToCast, mob.id)
            return true
        end
    end

    log.warn('No valid target found for alt nuke: %s', spellToCast)
    return false
end

-- ===========================================================================================================
--                                     Spell Sequence Functions
-- ===========================================================================================================

--- Casts a sequence of spells on a target
-- @param spells (table): A table of spells to cast
-- @return (boolean): True if successful, false otherwise
function DualBoxUtils.apply_spell_sequence_to_target(spells)
    if type(spells) ~= 'table' or #spells == 0 then
        log.error("spells must be a non-empty table")
        return false
    end

    local success, targetid, targetname = pcall(UtilityUtils.get_current_target_id_and_name)
    if not success then
        log.error("Failed to get target information")
        return false
    end

    for i, spell in ipairs(spells) do
        if type(spell) ~= 'table' or type(spell.name) ~= 'string' or type(spell.delay) ~= 'number' then
            log.error("Invalid spell at index %d: must have 'name' (string) and 'delay' (number)", i)
            return false
        end

        local command
        if spell.delay == 0 then
            command = string.format('send %s %s %s', altPlayerName, spell.name, tostring(targetid))
        else
            command = string.format('wait %d; send %s %s %s', spell.delay, altPlayerName, spell.name, tostring(targetid))
        end

        -- Special handling for Phalanx2 when target is main player and main job is PLD
        if spell.name == 'Phalanx2' and targetname == mainPlayerName and player.main_job == 'PLD' then
            local bothPhalanx
            if spell.delay == 0 then
                bothPhalanx = string.format(
                    'send %s Phalanx %s; send %s Phalanx2 %s',
                    mainPlayerName, tostring(targetid), altPlayerName, tostring(targetid)
                )
            else
                bothPhalanx = string.format(
                    'wait %d; send %s Phalanx %s; send %s Phalanx2 %s',
                    spell.delay, mainPlayerName, tostring(targetid), altPlayerName, tostring(targetid)
                )
            end

            local success, err = pcall(send_command, bothPhalanx)
            if not success then
                log.error("Failed to send Phalanx combo command: %s", err)
                return false
            end

            log.info("Sent Phalanx combo for PLD")
        else
            local success, err = pcall(send_command, command)
            if not success then
                log.error("Failed to send spell command for %s: %s", spell.name, err)
                return false
            end

            log.debug("Sent spell command: %s (delay: %d)", spell.name, spell.delay)
        end
    end

    log.info("Successfully applied spell sequence of %d spells", #spells)
    return true
end

-- ===========================================================================================================
--                                     RDM Buffing Functions
-- ===========================================================================================================

--- Handles the command sequence for a character (RDM alt)
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'buffmelee', 'buffrng', 'curaga', 'debuff')
-- @return (boolean): True if successful, false otherwise
function DualBoxUtils.buffer_role_for_alt_rdm(commandType)
    if type(commandType) ~= 'string' then
        log.error("commandType must be a string")
        return false
    end

    local success, targetid, targetname = pcall(UtilityUtils.get_current_target_id_and_name)
    if not success then
        log.error("Failed to get target information for RDM buffing")
        return false
    end

    local spells = {}

    if commandType == 'bufftank' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Refresh3', delay = 4 },
            { name = 'Phalanx2', delay = 9 },
            { name = 'Regen2',   delay = 13 },
        }
    elseif commandType == 'buffmelee' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'buffrng' then
        spells = {
            { name = 'flurry2',  delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'curaga' then
        spells = {
            { name = 'curaga3', delay = 0 }
        }
    elseif commandType == 'debuff' then
        spells = {
            { name = 'distract3', delay = 0 },
            { name = 'dia3',      delay = 4 },
            { name = 'slow2',     delay = 8 },
            { name = 'Blind2',    delay = 12 },
            { name = 'paralyze2', delay = 17 }
        }
    else
        log.error("Unknown RDM command type: %s", commandType)
        return false
    end

    local success = DualBoxUtils.apply_spell_sequence_to_target(spells)
    if success then
        log.info("Successfully executed RDM %s sequence", commandType)
    end

    return success
end

--- Helper function to check if member and pet are in party (referenced in geo functions)
-- @param name (string): The name to search for
-- @return (boolean): True if found, false otherwise
function DualBoxUtils.find_member_and_pet_in_party(name)
    return UtilityUtils.find_member_and_pet_in_party(name)
end

--- Handles the casting of an alternate spell (nuking).
-- @param altSpell (string): The name of the alternate spell to cast.
-- @param altTier (string or nil): The tier of the alternate spell to cast.
-- @param isRaSpell (boolean): Indicates whether the spell is a Ra spell.
function DualBoxUtils.handle_alt_nuke(altSpell, altTier, isRaSpell)
    if not altSpell or altSpell == '' then
        log.error("Invalid altSpell parameter")
        return
    end

    if altTier and altTier == '' then
        altTier = nil
    end

    if type(isRaSpell) ~= 'boolean' then
        log.error("isRaSpell must be boolean")
        return
    end

    local spellToCast = altSpell .. (isRaSpell and ' III' or (altTier or ''))
    local targetid, targetname = DualBoxUtils.get_current_target_id_and_name()

    if player and player.status == 'Engaged' then
        if targetid then
            local command = string.format(
                'send %s /assist <%s>; wait 1; send %s %s <t>',
                altPlayerName, mainPlayerName, altPlayerName, spellToCast
            )

            local success, err = pcall(send_command, command)
            if not success then
                log.error('Failed to send nuke command (engaged): %s', err or 'unknown error')
            else
                log.info('Alt nuke (engaged): %s', spellToCast)
            end
        end
    else
        local mob = windower.ffxi.get_mob_by_target('lastst')
        if mob and mob.id then
            targetid = mob.id
            local command = string.format('send %s %s %s', altPlayerName, spellToCast, targetid)

            local success, err = pcall(send_command, command)
            if not success then
                log.error('Failed to send nuke command: %s', err or 'unknown error')
            else
                log.info('Alt nuke: %s on target %s', spellToCast, targetid)
            end
        else
            log.warn('No target available for alt nuke')
        end
    end
end

-- ===========================================================================================================
--                                     Red Mage Alt Functions
-- ===========================================================================================================

--- Casts a sequence of spells on a target.
-- @param spells (table): A table of spells to cast.
-- @return (boolean): True if successful, false otherwise.
function DualBoxUtils.apply_spell_sequence_to_target(spells)
    if type(spells) ~= 'table' or #spells == 0 then
        log.error("Invalid spell sequence provided")
        return false
    end

    local success, targetid, targetname = pcall(DualBoxUtils.get_current_target_id_and_name)
    if not success then
        log.error("Failed to get target information")
        return false
    end

    if not targetid then
        log.warn("No target available for spell sequence")
        return false
    end

    for i, spell in ipairs(spells) do
        if type(spell) == 'table' and spell.name then
            local command
            if spell.delay and spell.delay > 0 then
                command = string.format('wait %d; send %s %s %s',
                    spell.delay, altPlayerName, spell.name, tostring(targetid))
            else
                command = string.format('send %s %s %s',
                    altPlayerName, spell.name, tostring(targetid))
            end

            -- Special handling for Phalanx2 + main player PLD
            if spell.name == 'Phalanx2' and targetname == mainPlayerName and
                player and player.main_job == 'PLD' then
                local bothPhalanx
                if spell.delay and spell.delay > 0 then
                    bothPhalanx = string.format(
                        'wait %d; send %s Phalanx %s; send %s Phalanx2 %s',
                        spell.delay, mainPlayerName, tostring(targetid),
                        altPlayerName, tostring(targetid)
                    )
                else
                    bothPhalanx = string.format(
                        'send %s Phalanx %s; send %s Phalanx2 %s',
                        mainPlayerName, tostring(targetid),
                        altPlayerName, tostring(targetid)
                    )
                end

                local cmd_success, message = pcall(send_command, bothPhalanx)
                if not cmd_success then
                    log.error("Failed to send dual Phalanx command: %s", message or 'unknown error')
                    return false
                end
            else
                local cmd_success, message = pcall(send_command, command)
                if not cmd_success then
                    log.error("Failed to send spell command %s: %s", spell.name, message or 'unknown error')
                    return false
                end
            end

            log.debug("Queued alt spell: %s (delay: %d)", spell.name, spell.delay or 0)
        else
            log.error("Invalid spell data in sequence at index %d", i)
        end
    end

    return true
end

--- Handles the command sequence for a Red Mage character.
-- @param commandType (string): The type of the command (e.g., 'bufftank', 'buffmelee', 'buffrng', 'curaga', 'debuff').
-- @return (boolean): True if successful, false otherwise.
function DualBoxUtils.buffer_role_for_alt_rdm(commandType)
    if type(commandType) ~= 'string' then
        log.error("Invalid command type for RDM buffer")
        return false
    end

    local success, targetid, targetname = pcall(DualBoxUtils.get_current_target_id_and_name)
    if not success then
        log.error("Failed to get target for RDM buffer")
        return false
    end

    local spells = {}

    -- Define spell sequences based on command type
    if commandType == 'bufftank' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Refresh3', delay = 4 },
            { name = 'Phalanx2', delay = 9 },
            { name = 'Regen2',   delay = 13 },
        }
    elseif commandType == 'buffmelee' then
        spells = {
            { name = 'Haste2',   delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'buffrng' then
        spells = {
            { name = 'flurry2',  delay = 0 },
            { name = 'Phalanx2', delay = 4 },
            { name = 'Regen2',   delay = 9 },
        }
    elseif commandType == 'curaga' then
        spells = {
            { name = 'curaga3', delay = 0 }
        }
    elseif commandType == 'debuff' then
        spells = {
            { name = 'distract3', delay = 0 },
            { name = 'dia3',      delay = 4 },
            { name = 'slow2',     delay = 8 },
            { name = 'Blind2',    delay = 12 },
            { name = 'paralyze2', delay = 17 }
        }
    else
        log.error("Unknown RDM command type: %s", commandType)
        return false
    end

    local success, message = pcall(DualBoxUtils.apply_spell_sequence_to_target, spells)
    if not success then
        log.error("Failed to apply RDM spell sequence: %s", message or 'unknown error')
        return false
    end

    log.info("Applied RDM buffer sequence: %s (%d spells)", commandType, #spells)
    return true
end

-- ===========================================================================================================
--                                     Utility Functions
-- ===========================================================================================================

--- Checks if a specific party member has a pet.
-- @param name (string): The name of the party member to check.
-- @return (boolean): True if the party member is found and they have a pet, false otherwise.
function DualBoxUtils.find_member_and_pet_in_party(name)
    if type(name) ~= 'string' then
        log.error("Party member name must be a string")
        return false
    end

    if type(party) ~= 'table' then
        log.debug("Party data not available")
        return false
    end

    for _, member in ipairs(party) do
        if type(member) == 'table' and member.mob and type(member.mob) == 'table' then
            if member.mob.name == name then
                local has_pet = member.mob.pet_index ~= nil
                log.debug("Party member %s %s pet", name, has_pet and "has" or "has no")
                return has_pet
            end
        end
    end

    log.debug("Party member %s not found", name)
    return false
end

--- Checks if a table contains a specific element.
-- @param tbl (table): The table to search in.
-- @param element (any): The element to search for in the table.
-- @return (boolean): True if the element is found in the table, false otherwise.
function DualBoxUtils.table_contains(tbl, element)
    if type(tbl) ~= 'table' then
        log.error("First parameter must be a table")
        return false
    end

    if element == nil then
        log.error("Element cannot be nil")
        return false
    end

    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end

    return false
end

return DualBoxUtils
