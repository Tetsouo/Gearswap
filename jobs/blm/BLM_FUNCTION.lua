---============================================================================
--- FFXI GearSwap Job Module - Black Mage Advanced Functions
---============================================================================

-- Load critical dependencies
local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
if not success_MessageUtils then
    error("Failed to load utils/messages: " .. tostring(MessageUtils))
end

-- Load Windower resources for spell data with error handling
local res_success, res = pcall(require, 'resources')
if not res_success then
    MessageUtils.blm_resource_error_message()
    return
end
--- Professional Black Mage job-specific functionality providing intelligent
--- elemental magic optimization, spell tier management, Magic Burst detection,
--- and advanced casting strategies. Core features include:
---
--- • **Intelligent Spell Tier Selection** - Automatic downgrade from VI to I
--- • **Magic Burst Detection** - Skillchain window timing and gear optimization
--- • **Elemental Spell Optimization** - Weather, day, and target resistance awareness
--- • **Mana Conservation Algorithms** - Efficient MP usage and spell selection
--- • **Spell Recast Management** - Cast timing optimization and cooldown tracking
--- • **Arts Integration** - Light/Dark Arts spell modification support
--- • **Elemental Wheel Logic** - Strategic element selection for maximum damage
--- • **Error Recovery Systems** - Robust handling of spell failures and interruptions
---
--- This module implements the advanced magical algorithms that make BLM
--- automation intelligent and efficient, handling complex spell selection
--- logic with weather awareness and mana conservation strategies.
---
--- @file jobs/blm/BLM_FUNCTION.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires Windower FFXI, GearSwap addon
--- @requires config/config.lua for BLM-specific settings
---
--- @usage
---   refine_various_spells(spell, eventArgs, spellCorrespondence)
---   checkArts(spell, eventArgs)
---   SaveMP() -- Mana conservation during midcast
---
--- @see jobs/blm/BLM_SET.lua for Magic Burst and elemental equipment sets
--- @see Tetsouo_BLM.lua for job configuration and state management
---============================================================================

---============================================================================
--- SPELL CASTING OPTIMIZATION TABLES
---============================================================================

--- Last cast timestamps for spell recast optimization
--- Tracks when each spell was last cast to prevent spam and optimize timing
--- @type table<string, number> Maps spell names to their last cast timestamps
local lastCastTimes = {}

--- Secure spell tracking for lag compensation
--- Prevents spell spam in laggy zones by adding extra security checks
--- @type table<string, table> Maps spell names to secure tracking data
local secureSpellTracking = {}

--- Timestamp to prevent infinite replacement loops
--- Stores the last time a spell was replaced to prevent rapid replacements
local lastReplacementTime = 0

--- Spell tier correspondence table for intelligent spell downgrading
--- Maps each elemental spell to its tier hierarchy, allowing automatic
--- downgrade from higher tiers (VI) to lower tiers (I) when higher versions
--- fail due to MP constraints, interruption, or other casting issues
--- @type table<string, table<string, table>> Spell name -> tier -> replacement data
spellCorrespondence = {
    Fire = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzard = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aero = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stone = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thunder = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Water = { ['VI'] = { replace = 'V' }, ['V'] = { replace = 'IV' }, ['IV'] = { replace = 'III' }, ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Sleepga = { ['II'] = { replace = '' } },
    Sleep = { ['II'] = { replace = '' } },
    Aspir = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Firaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aeroga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stonega = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thundaga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Waterga = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Firaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Blizzaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Aeroja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Stoneja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Thundaja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } },
    Waterja = { ['III'] = { replace = 'II' }, ['II'] = { replace = '' } }
}

--- Secure spell casting check for lag compensation
--- Prevents spell spam in laggy zones by tracking cast timestamps
--- Only blocks if spam is really too fast (< 0.2s)
--- @param spellName string The name of the spell to check
--- @param currentTime number Current timestamp
--- @return boolean true if spell is safe to cast
local function isSpellSafeToCast(spellName, currentTime)
    -- Initialize tracking for this spell if needed
    if not secureSpellTracking[spellName] then
        secureSpellTracking[spellName] = {
            lastCast = 0,
            minDelay = 0.2 -- Very short anti-spam delay (reduced from 2.5s → 0.2s)
        }
    end

    local spellData = secureSpellTracking[spellName]
    local timeSinceLastCast = currentTime - spellData.lastCast

    -- Allow cast if enough time has passed (even for very fast spam)
    if timeSinceLastCast >= spellData.minDelay then
        spellData.lastCast = currentTime
        return true
    end

    -- Only blocks extreme spam (< 0.2s)
    local success_log, log = pcall(require, 'utils/LOGGER')
    if not success_log then
        error("Failed to load utils/logger: " .. tostring(log))
    end
    log.debug("Spell %s blocked - spam too fast (%.1fs ago)", spellName, timeSinceLastCast)
    return false
end

-- This function manages self-buff spells in the game Final Fantasy XI.
-- It checks the recast time of each spell and if the buff is active.
-- If the buff is not active or is about to expire, it queues the spell to be cast.
-- ENHANCED: Now includes lag compensation and optimized loop processing
function BuffSelf()
    -- Cache frequently accessed values
    local currentTime = os.clock() -- More precise than os.time() for anti-spam
    local spellRecasts = windower.ffxi.get_spell_recasts()
    local buffActive = buffactive

    -- Assert that SpellRecasts is a table
    assert(type(spellRecasts) == "table", "Failed to get spell recasts")

    -- Pre-defined spell data (cached for performance)
    -- Get spell IDs dynamically
    local success_res, res = pcall(require, 'resources')
    if not success_res then
        error("Failed to load resources: " .. tostring(res))
    end
    local spells = {
        { name = 'Stoneskin',  delay = 0, buffName = 'Stoneskin',  duration = 488 },
        { name = 'Blink',      delay = 6, buffName = 'Blink',      duration = 488 },
        { name = 'Aquaveil',   delay = 6, buffName = 'Aquaveil',   duration = 914 },
        { name = 'Ice Spikes', delay = 6, buffName = 'Ice Spikes', duration = 274 }
    }

    -- Populate recast IDs dynamically
    for _, spell in ipairs(spells) do
        local spell_data = res.spells:with('en', spell.name)
        spell.recastId = spell_data and spell_data.id or
            (spell.name == 'Stoneskin' and 54 or
                spell.name == 'Blink' and 53 or
                spell.name == 'Aquaveil' and 55 or 251)
    end

    -- Pre-allocate arrays for better performance
    local readySpells = {}
    local spellsOnCooldown = {}
    local totalDelay = 0
    local readyCount = 0
    local cooldownCount = 0

    -- Single loop to process all spells (optimized iteration)
    for i = 1, #spells do
        local spell = spells[i]
        local recastTime_raw = spellRecasts[spell.recastId]
        local recastTime = recastTime_raw or 0
        local isBuffActive = buffActive[spell.buffName]

        -- Only process spells with valid duration and without active buff
        if spell.duration > 0 and not isBuffActive then
            -- Check if spell is ready and safe to cast
            if recastTime == 0 and isSpellSafeToCast(spell.name, currentTime) then
                -- Increment delay only if we have previous spells queued
                if readyCount > 0 then
                    totalDelay = totalDelay + spell.delay
                end

                -- Add to ready spells using pre-incremented count
                readyCount = readyCount + 1
                readySpells[readyCount] = { spell = spell, delay = totalDelay }
            elseif recastTime > 0 then
                -- Add to cooldown list using pre-incremented count
                cooldownCount = cooldownCount + 1
                spellsOnCooldown[cooldownCount] = { spell = spell, recast = recastTime }
            end
        elseif recastTime > 0 then
            -- Track cooldowns even for active buffs (for display purposes)
            cooldownCount = cooldownCount + 1
            spellsOnCooldown[cooldownCount] = { spell = spell, recast = recastTime }
        end
    end

    -- Process ready spells if any (optimized command building)
    if readyCount > 0 then
        -- Cache logger for performance
        local success_log, log = pcall(require, 'utils/LOGGER')
        if not success_log then
            error("Failed to load utils/logger: " .. tostring(log))
        end

        for i = 1, readyCount do
            local readySpell = readySpells[i]
            local spellName = readySpell.spell.name

            -- Build command string efficiently
            local command = readySpell.delay > 0 and
                ('wait ' .. readySpell.delay .. '; input /ma "' .. spellName .. '" <me>') or
                ('input /ma "' .. spellName .. '" <me>')

            send_command(command)
            lastCastTimes[spellName] = currentTime

            -- Log cast attempt
            log.debug("BuffSelf: Casting %s (delay: %ds, safe: true)", spellName, readySpell.delay)
        end
    else
        -- Always show complete status like WAR/THF/DNC (combine recasts + actives)
        local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
        if not success_MessageUtils then
            error("Failed to load utils/messages: " .. tostring(MessageUtils))
        end

        local messages_to_display = {}

        -- For each spell, show either ACTIVE or RECAST (not both)
        for _, spell in ipairs(spells) do
            if buffActive[spell.buffName] then
                -- Buff is active - show only active status
                table.insert(messages_to_display, { type = 'active', name = spell.name })
            else
                -- Buff not active - check if it's on recast
                local recastTime_raw = spellRecasts[spell.recastId]
                local recastTime = recastTime_raw or 0
                if recastTime > 0 then
                    -- Show recast only if not active
                    table.insert(messages_to_display, { type = 'recast', name = spell.name, time = recastTime })
                end
                -- If recastTime == 0 and not active, spell will be cast (no message)
            end
        end

        -- Display combined status
        if #messages_to_display > 0 then
            MessageUtils.unified_status_message(messages_to_display, nil, true)
        end
    end
end

--- Handles the replacement of a spell.
-- This function checks if a spell needs to be replaced based on the current recast time and player's MP.
-- If a replacement is needed, it modifies the spell name accordingly.
-- @param spell The spell to be checked for replacement.
-- @param spell_recasts The table containing the recast times for all spells.
-- @param player_mp The current MP of the player.
-- @param correspondence The table containing the correspondence between spells and their replacements.
-- @param spellCategory The category of the spell (e.g., 'Cure', 'Fire', etc.).
-- @param spellLevel The level of the spell (e.g., 'I', 'II', 'III', etc.).
-- @return newSpell The name of the new spell after replacement.
-- @return replacement The name of the replacement spell.
function handle_spell_replacement(spell, spell_recasts, player_mp, correspondence, spellCategory, spellLevel)
    assert(spell, "spell cannot be nil")
    assert(spell_recasts, "spell_recasts cannot be nil")
    assert(player_mp, "player_mp cannot be nil")
    assert(spellCategory, "spellCategory cannot be nil")
    assert(spellLevel, "spellLevel cannot be nil")

    local currentLevel = spellLevel
    local newSpell = spell.english
    local originalSpell = spell.english

    -- If no correspondence table, return original spell
    if not correspondence then
        return newSpell, nil
    end

    -- Optimized tier checking with early exit and cached lookups
    local maxIterations = 6 -- Prevent infinite loops (VI -> V -> IV -> III -> II -> I)

    -- Cache frequently accessed values for performance
    local resSpells = res.spells
    local playerMp = player_mp

    for iteration = 1, maxIterations do
        if not currentLevel then
            break
        end

        -- Build the spell name for this tier (optimized string concatenation)
        local testSpellName = (currentLevel == '') and spellCategory or (spellCategory .. ' ' .. currentLevel)

        -- Try to get spell info using cached resource table
        local testSpell = resSpells:with('en', testSpellName)

        if testSpell then
            local mpCost = testSpell.mp_cost or 999
            local recastId = testSpell.recast_id

            -- Check availability with cached values
            if spell_recasts[recastId] == 0 and playerMp >= mpCost then
                newSpell = testSpellName
                break -- Early exit on success
            end
        end

        -- Get next lower tier from correspondence table
        local tier = correspondence[currentLevel]
        if not tier then
            break -- Early exit if no more tiers
        end

        currentLevel = tier.replace

        -- Handle base tier (empty string = tier I) with early exit
        if currentLevel == '' then
            local tierOneSpell = spellCategory
            local tierOne = resSpells:with('en', tierOneSpell)
            if tierOne then
                local mpCost = tierOne.mp_cost or 999
                if spell_recasts[tierOne.recast_id] == 0 and playerMp >= mpCost then
                    newSpell = tierOneSpell
                end
            end
            break -- Always exit after checking base tier
        end
    end

    -- Special case for -ja spells: ONLY downgrade if the original -ja spell is unavailable
    if spell.name:find('ja') and newSpell == originalSpell then
        -- First check if the original -ja spell is actually unavailable
        local originalJaSpell = res.spells:with('en', originalSpell)
        local jaUnavailable = false

        if originalJaSpell then
            if spell_recasts[originalJaSpell.recast_id] > 0 or player_mp < (originalJaSpell.mp_cost or 999) then
                jaUnavailable = true
            end
        else
            jaUnavailable = true -- Spell not found, treat as unavailable
        end

        -- Only downgrade to -ga series if the -ja spell is truly unavailable
        if jaUnavailable then
            local baseElement = string.gsub(spell.name, 'ja.*', '') -- Fire, Stone, etc.
            local gaCorrespondence = spellCorrespondence[baseElement .. 'ga']

            if gaCorrespondence then
                -- Try to find available -ga spell starting from III
                local gaNewSpell, _ = handle_spell_replacement(
                    { english = baseElement .. 'ga III', name = baseElement .. 'ga III' },
                    spell_recasts, player_mp, gaCorrespondence, baseElement .. 'ga', 'III'
                )
                if gaNewSpell and gaNewSpell ~= baseElement .. 'ga III' then
                    newSpell = gaNewSpell
                else
                    newSpell = baseElement .. 'ga III' -- Fallback to ga III
                end
            else
                newSpell = string.gsub(spell.name, 'ja', 'ga') .. ' III' -- Original logic
            end
        end
    end

    -- Log the replacement for debugging
    if newSpell ~= originalSpell then
        local success_log, log = pcall(require, 'utils/LOGGER')
        if not success_log then
            error("Failed to load utils/logger: " .. tostring(log))
        end
        log.debug("Spell tier downgrade: %s -> %s", originalSpell, newSpell)
    end

    return newSpell, (newSpell ~= originalSpell and newSpell or nil)
end

--- Handles the cancellation of a spell.
-- This function checks if a spell needs to be cancelled based on the replacement spell and player's MP.
-- If a cancellation is needed, it cancels the spell and returns true.
-- @param newSpell The name of the new spell after replacement.
-- @param replacement The name of the replacement spell.
-- @param player_mp The current MP of the player.
-- @param spell The original spell before replacement.
-- @return A boolean indicating whether the spell was cancelled.
function handle_spell_cancellation(newSpell, replacement, player_mp, spell)
    assert(newSpell, "newSpell cannot be nil")
    assert(player_mp, "player_mp cannot be nil")
    assert(spell, "spell cannot be nil")

    if replacement == '' and newSpell ~= 'Aspir' and player_mp < (newSpell == 'Aspir' and 10 or 9) then
        cancel_spell()
        return true
    end

    return false
end

--- Refines various spells based on their recast times and player's MP.
-- This function checks if a spell needs to be replaced or cancelled based on the current recast time and player's MP.
-- If a replacement or cancellation is needed, it modifies the spell accordingly and updates the eventArgs.
-- ENHANCED: Now includes lag compensation to prevent spell replacement spam
-- @param spell The spell to be checked for replacement or cancellation.
-- @param eventArgs The event arguments to be updated if a replacement or cancellation is needed.
-- @param spellCorrespondence The table containing the correspondence between spells and their replacements.
function refine_various_spells(spell, eventArgs, spellCorrespondence)
    assert(spell, "spell cannot be nil")
    assert(eventArgs, "eventArgs cannot be nil")
    assert(spellCorrespondence, "spellCorrespondence cannot be nil")

    local currentTime = os.clock() -- More precise than os.time() for anti-spam

    -- Skip replacement if we just replaced a spell (reduced to 0.2s to allow normal recast)
    if (currentTime - lastReplacementTime) < 0.2 then
        return
    end

    local newSpell = spell.english
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local player_mp = player.mp

    local spellCategory, spellLevel = spell.name:match('(%a+)%s*(%a*)')
    local correspondence = spellCorrespondence[spellCategory]

    newSpell, replacement = handle_spell_replacement(spell, spell_recasts, player_mp, correspondence, spellCategory,
        spellLevel)

    if handle_spell_cancellation(newSpell, replacement, player_mp, spell) then
        eventArgs.cancel = true
        -- Use unified system for error messages
        local messages = { { type = 'error', name = newSpell, message = 'Not enough Mana: (' .. player_mp .. 'MP)' } }
        MessageUtils.unified_status_message(messages, nil, true)
        return
    end

    -- Magic Burst announcement - Now using the correct (refined) spell name
    if state.CastingMode.value == 'MagicBurst' and spell.skill == 'Elemental Magic' then
        -- Parse the final spell name to get category and level
        local finalSpellName = newSpell ~= spell.english and newSpell or spell.english
        local finalCategory, finalLevel = finalSpellName:match('(%a+)%s*(%a*)')

        -- Handle different spell types correctly
        local displayName
        if finalSpellName:find('ja') then
            -- For -ja spells, just use the full name (no tier)
            displayName = finalSpellName
        elseif not finalLevel or finalLevel == '' then
            -- For base tier spells (Fire, Cure, etc.), just use the category
            displayName = finalCategory
        else
            -- For tiered spells (Fire III, Cure IV, etc.), show category + level
            displayName = finalCategory .. ' ' .. finalLevel
        end

        send_command((finalLevel == 'VI' and 'wait 2; ' or '') ..
            'input /p Casting: [' .. displayName .. '] => Nuke')
    end

    if newSpell ~= spell.english then
        -- Update timestamp to prevent rapid replacements
        lastReplacementTime = currentTime

        -- Send the replacement spell command with minimal delay (reduced from 0.5s)
        send_command('wait 0.1; input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true

        -- Log replacement for debugging
        local success_log, log = pcall(require, 'utils/LOGGER')
        if not success_log then
            error("Failed to load utils/logger: " .. tostring(log))
        end
        log.info("Spell downgraded: %s -> %s (MP: %d)", spell.english, newSpell, player_mp)
    else
        -- No replacement found - check if original spell is on cooldown and show recast info
        local originalSpellData = res.spells:with('en', spell.english)
        if originalSpellData and correspondence then
            local recastTime_raw = spell_recasts[originalSpellData.recast_id]
            if recastTime_raw and recastTime_raw > 0 then
                -- Original spell is on cooldown, show recast times for all tiers
                eventArgs.cancel = true

                -- Show recast for original spell using unified system
                local recastTime = recastTime_raw / 100
                local messages = { { type = 'recast', name = spell.english, time = recastTime } }
                MessageUtils.unified_status_message(messages, nil, true)

                -- Optimized recast display for lower tiers
                local currentTier = spellLevel
                local resSpells = res.spells -- Cache resource table

                -- Use numeric for loop for better performance
                for iteration = 1, 6 do
                    if not currentTier or not correspondence[currentTier] then
                        break -- Early exit if no more tiers
                    end

                    local nextLevel = correspondence[currentTier].replace

                    if nextLevel == '' then
                        -- Check base tier (no roman numeral) with cached lookups
                        local baseTierSpell = resSpells:with('en', spellCategory)
                        if baseTierSpell then
                            local baseTierRecast_raw = spell_recasts[baseTierSpell.recast_id]
                            if baseTierRecast_raw and baseTierRecast_raw > 0 then
                                -- Convert centiseconds to seconds and use unified system
                                local baseTierRecast = baseTierRecast_raw / 100
                                local messages = { { type = 'recast', name = spellCategory, time = baseTierRecast } }
                                MessageUtils.unified_status_message(messages, nil, true)
                            end
                        end
                        break -- Always exit after base tier
                    else
                        -- Check next tier with optimized string building
                        local nextTierSpellName = spellCategory .. ' ' .. nextLevel
                        local nextTierSpell = resSpells:with('en', nextTierSpellName)
                        if nextTierSpell then
                            local nextTierRecast_raw = spell_recasts[nextTierSpell.recast_id]
                            if nextTierRecast_raw and nextTierRecast_raw > 0 then
                                -- Convert centiseconds to seconds and use unified system
                                local nextTierRecast = nextTierRecast_raw / 100
                                local messages = { { type = 'recast', name = nextTierSpellName, time = nextTierRecast } }
                                MessageUtils.unified_status_message(messages, nil, true)
                            end
                        end
                        currentTier = nextLevel -- Update for next iteration
                    end
                end

                return
            end
        end
    end

    -- Magic Burst announcement - MOVED to use refined spell name
    -- (Will be displayed after spell refinement below)

    if spell.english == 'Breakga' and spell_recasts[spell.recast_id] > 0 then
        -- LAG COMPENSATION: Secure Breakga -> Break replacement
        local breakKey = "Breakga_to_Break"
        if isSpellSafeToCast(breakKey, currentTime) then
            cancel_spell()
            newSpell = 'Break'
            -- Get Break spell ID dynamically
            local success_res, res = pcall(require, 'resources')
            if not success_res then
                error("Failed to load resources: " .. tostring(res))
            end
            local break_spell = res.spells:with('en', 'Break')
            local break_id = break_spell and break_spell.id or 255
            if spell_recasts[break_id] > 0 then
                cancel_spell()
                eventArgs.cancel = true
                local recastTime_raw = spell_recasts[break_id]
                -- Convert centiseconds to seconds and use unified system
                local recastTime = recastTime_raw / 100
                local messages = { { type = 'recast', name = newSpell, time = recastTime } }
                MessageUtils.unified_status_message(messages, nil, true)
            else
                send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
                eventArgs.cancel = true
            end
        else
            -- Breakga replacement blocked
            eventArgs.cancel = true
            local success_log, log = pcall(require, 'utils/LOGGER')
            if not success_log then
                error("Failed to load utils/logger: " .. tostring(log))
            end
            log.warn("Breakga replacement blocked (lag protection)")
        end
    end
end

--- Customizes the idle set based on the current conditions.
-- This function uses the `customize_set` function to modify the `idleSet` based on the current conditions and the corresponding sets. It checks if the 'Mana Wall' buff is active and, if so, it applies the 'Mana Wall' set to the `idleSet`.
-- @param idleSet The set to be customized. This should be a table that represents the current idle set. This parameter must not be `nil`.
-- @return The customized idle set. This will be a table that represents the idle set after it has been modified by the `customize_set` function.
-- @usage
-- -- Define the current idle set
-- local idleSet = { item1 = 'item1', item2 = 'item2' }
-- -- Customize the idle set
-- idleSet = customize_idle_set(idleSet)
function customize_idle_set(idleSet)
    assert(idleSet, "idleSet must not be nil")

    -- Use standardized Town/Dynamis logic with modular customization
    local success_EquipmentUtils, EquipmentUtils = pcall(require, 'equipment/EQUIPMENT')
    if not success_EquipmentUtils then
        error("Failed to load core/equipment: " .. tostring(EquipmentUtils))
    end
    local standardSet = EquipmentUtils.customize_idle_set_standard(
        idleSet,        -- Base idle set
        sets.idle.Town, -- Town set (used in cities, excluded in Dynamis)
        nil,            -- No XP set for BLM
        nil,            -- No PDT set for BLM idle
        nil             -- No MDT set for BLM idle
    )

    -- Apply BLM-specific Mana Wall logic
    local conditions = { Manawall = Manawall }
    local setTable = { Manawall = sets.buff['Mana Wall'] }
    assert(setTable.Manawall, "'Mana Wall' set must not be nil")

    return EquipmentUtils.customize_set(standardSet, conditions, setTable)
end

--- BLM job constants for MP conservation
--- @type table<string, number> Constants for BLM functionality
local BLM_CONSTANTS = {
    LOW_MP_THRESHOLD = 1000, -- MP threshold for switching to conservation gear
}

--- Get dynamic elemental magic set based on MP and casting mode.
--- Returns appropriate equipment set without mutating global sets.
---
--- @param castingMode string Current casting mode ('Normal' or other for MagicBurst)
--- @param currentMP number Player's current MP value
--- @return table Equipment set for current conditions
function get_dynamic_elemental_set(castingMode, currentMP)
    if currentMP < BLM_CONSTANTS.LOW_MP_THRESHOLD then
        return castingMode == 'Normal' and blm_dynamic_sets.normalSetLowMP or blm_dynamic_sets.magicBurstSetLowMP
    else
        return castingMode == 'Normal' and blm_dynamic_sets.normalSetHighMP or blm_dynamic_sets.magicBurstSetHighMP
    end
end

-- Function: SaveMP
-- Gets appropriate gear set based on current MP and casting mode without mutating global sets.
function SaveMP()
    assert(player.mp, "player.mp must not be nil")
    assert(state and state.CastingMode and state.CastingMode.value, "state.CastingMode.value must not be nil")

    -- Get appropriate set without mutating global sets
    local dynamicSet = get_dynamic_elemental_set(state.CastingMode.value, player.mp)

    -- Apply the set based on casting mode
    if state.CastingMode.value == 'Normal' then
        sets.midcast['Elemental Magic'] = dynamicSet
    else
        sets.midcast['Elemental Magic'].MagicBurst = dynamicSet
    end
end

-- Function: checkArts
-- This function checks if the player's sub-job is Scholar (SCH) and if the 'Dark Arts' ability is available.
-- If these conditions are met and the player is casting an 'Elemental Magic' spell without 'Dark Arts' or 'Addendum: Black' active,
-- it cancels the current spell, activates 'Dark Arts', and then recasts the original spell.
-- ENHANCED: Now includes lag compensation to prevent Dark Arts spam
-- Parameters:
--   spell (table): The spell being cast.
--   eventArgs (table): Additional event arguments.
function checkArts(spell, eventArgs)
    -- Check if the parameters are tables.
    assert(type(spell) == 'table', "Parameter 'spell' must be a table.")
    assert(type(eventArgs) == 'table', "Parameter 'eventArgs' must be a table.")

    -- Check if the necessary keys exist in the 'spell' table.
    assert(spell.name, "Key 'name' must exist in the 'spell' table.")

    -- Check if the player's sub-job is Scholar (SCH).
    if player.sub_job == 'SCH' and player.sub_job_level ~= 0 then
        -- Get the recast time for the 'Dark Arts' ability.
        -- Get Dark Arts ID dynamically
        local success_res, res = pcall(require, 'resources')
        if not success_res then
            error("Failed to load resources: " .. tostring(res))
        end
        local dark_arts_data = res.job_abilities:with('en', 'Dark Arts')
        local dark_arts_id = dark_arts_data and dark_arts_data.recast_id or 232
        local darkArtsRecast = windower.ffxi.get_ability_recasts()[dark_arts_id]
        -- Check if the player is casting an 'Elemental Magic' spell and doesn't have 'Dark Arts' or 'Addendum: Black' active,
        -- and if the 'Dark Arts' ability is available (recast time is less than 1).
        if
            spell.skill == 'Elemental Magic' and not (buffactive['Dark Arts'] or buffactive['Addendum: Black']) and
            darkArtsRecast < 1
        then
            -- LAG COMPENSATION: Check if Dark Arts activation is safe
            local currentTime = os.clock() -- More precise than os.time() for anti-spam
            local artsKey = "DarkArts_" .. spell.name

            if isSpellSafeToCast(artsKey, currentTime) then
                -- Cancel the current spell.
                cancel_spell()
                -- Activate 'Dark Arts' and recast the original spell after a 2-second delay.
                send_command('input /ja "Dark Arts" <me>; wait 2; input /ma ' .. spell.name .. ' <t>')

                -- Log Dark Arts activation for debugging
                local success_log, log = pcall(require, 'utils/LOGGER')
                if not success_log then
                    error("Failed to load utils/logger: " .. tostring(log))
                end
                log.debug("Dark Arts activated for spell: %s", spell.name)
            else
                -- Dark Arts activation blocked due to lag compensation
                local success_log, log = pcall(require, 'utils/LOGGER')
                if not success_log then
                    error("Failed to load utils/logger: " .. tostring(log))
                end
                log.warn("Dark Arts activation blocked (lag protection) for spell: %s", spell.name)
            end
        end
    end
end

-- ===========================================================================================================
--                                   Job-Specific Command Handling Functions
-- ===========================================================================================================
-- Handles custom commands specific to the job.
-- It updates the altState object, handles a set of predefined commands, and handles job-specific and subjob-specific commands.
-- @param cmdParams (table): The command parameters. The first element is expected to be the command name.
-- @param eventArgs (table): Additional event arguments.
-- @param spell (table): The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the altState object
    update_altState()
    local command = cmdParams[1] and cmdParams[1]:lower() or ""
    
    -- Helper function for colored element messages (like PLD's rune messages)
    local function show_element_message(state_type, element_name)
        local element_colors = {
            Fire = 057,      -- Orange
            Thunder = 012,   -- Yellow  
            Aero = 006,      -- Cyan
            Stone = 050,     -- Yellow/Gold (changed from 010)
            Earth = 050,     -- Yellow/Gold
            Water = 056,     -- Light Blue
            Blizzard = 005,  -- Blue
            Ice = 005,       -- Blue
            Light = 001,     -- White
            Dark = 201,      -- Purple
            -- Aja spells
            Firaja = 057,    -- Orange
            Thundaja = 012,  -- Yellow
            Aeroja = 006,    -- Cyan
            Stoneja = 050,   -- Yellow/Gold
            Waterja = 056,   -- Light Blue
            Blizzaja = 005,  -- Blue
            -- -ra spells for alt player
            Fira = 057,      -- Orange
            Thundara = 012,  -- Yellow
            Aera = 006,      -- Cyan
            Stonera = 050,   -- Yellow/Gold
            Watera = 056,    -- Light Blue
            Blizzara = 005,  -- Blue
        }
        local color_code = element_colors[element_name] or 001
        local gray = string.char(0x1F, 160)
        local job_color = string.char(0x1F, 207)
        local element_color = string.char(0x1F, color_code)
        
        local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                       gray .. 'Current ' .. state_type .. ': ' .. 
                       element_color .. element_name .. gray
        windower.add_to_chat(001, message)
    end
    
    -- Custom cycle commands like PLD's cyclerune
    if command == 'cyclemainlight' then
        state.MainLightSpell:cycle()
        show_element_message('MainLight', state.MainLightSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclemaindark' then
        state.MainDarkSpell:cycle()
        show_element_message('MainDark', state.MainDarkSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclesublight' then
        state.SubLightSpell:cycle()
        show_element_message('SubLight', state.SubLightSpell.value)
        eventArgs.handled = true
        return
    elseif command == 'cyclesubdark' then
        state.SubDarkSpell:cycle()
        show_element_message('SubDark', state.SubDarkSpell.value)
        eventArgs.handled = true
        return
    end
    
    -- Handle standard cycle commands with colored messages
    if command == 'cycle' and cmdParams[2] then
        local stateName = cmdParams[2]
        
        -- Aja cycle
        if stateName == 'Aja' then
            state.Aja:cycle()
            show_element_message('Aja', state.Aja.value)
            eventArgs.handled = true
            return
        -- Alt player cycles
        elseif stateName == 'altPlayerLight' then
            state.altPlayerLight:cycle()
            show_element_message('AltLight', state.altPlayerLight.value)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayerDark' then
            state.altPlayerDark:cycle()
            show_element_message('AltDark', state.altPlayerDark.value)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayera' then
            state.altPlayera:cycle()
            show_element_message('AltAra', state.altPlayera.value)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayerTier' then
            state.altPlayerTier:cycle()
            -- No color needed for tier, just show it normally
            local gray = string.char(0x1F, 160)
            local job_color = string.char(0x1F, 207)
            local tier_color = string.char(0x1F, 050) -- Yellow for tier
            local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                           gray .. 'Current AltTier: ' .. 
                           tier_color .. state.altPlayerTier.value .. gray
            windower.add_to_chat(001, message)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayerGeo' then
            state.altPlayerGeo:cycle()
            -- Geo spells in green
            local gray = string.char(0x1F, 160)
            local job_color = string.char(0x1F, 207)
            local geo_color = string.char(0x1F, 158) -- Green for geo
            local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                           gray .. 'Current AltGeo: ' .. 
                           geo_color .. state.altPlayerGeo.value .. gray
            windower.add_to_chat(001, message)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayerIndi' then
            state.altPlayerIndi:cycle()
            -- Indi spells in cyan
            local gray = string.char(0x1F, 160)
            local job_color = string.char(0x1F, 207)
            local indi_color = string.char(0x1F, 056) -- Cyan for indi
            local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                           gray .. 'Current AltIndi: ' .. 
                           indi_color .. state.altPlayerIndi.value .. gray
            windower.add_to_chat(001, message)
            eventArgs.handled = true
            return
        elseif stateName == 'altPlayerEntrust' then
            state.altPlayerEntrust:cycle()
            -- Entrust spells in purple
            local gray = string.char(0x1F, 160)
            local job_color = string.char(0x1F, 207)
            local entrust_color = string.char(0x1F, 201) -- Purple for entrust
            local message = gray .. '[' .. job_color .. 'BLM' .. gray .. '] ' ..
                           gray .. 'Current AltEntrust: ' .. 
                           entrust_color .. state.altPlayerEntrust.value .. gray
            windower.add_to_chat(001, message)
            eventArgs.handled = true
            return
        end
    end

    -- Let standard GearSwap handle cycle commands for proper state management
    if command == 'cycle' then
        return -- Let GearSwap handle this natively
    end

    -- Try universal commands first (test, modules, cache, metrics, help)
    local success_UniversalCommands, UniversalCommands = pcall(require, 'core/UNIVERSAL_COMMANDS')
    if not success_UniversalCommands then
        error("Failed to load core/universal_commands: " .. tostring(UniversalCommands))
    end
    if UniversalCommands.handle_command(cmdParams, eventArgs) then
        return -- Command handled by universal system
    end

    -- Handle alt player spell commands directly (case insensitive)
    if command == 'altlight' then
        if state.altPlayerLight and state.altPlayerTier then
            local tierToUse = state.altPlayerTier.value
            if tierToUse == 'VI' then tierToUse = 'V' end
            handle_altNuke(state.altPlayerLight.value, tierToUse, false)
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.blm_alt_cast_message('cast_light', state.altPlayerLight.value, tierToUse)
        else
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.blm_alt_cast_message('error_light')
        end
        eventArgs.handled = true
        return
    elseif command == 'altdark' then
        if state.altPlayerDark and state.altPlayerTier then
            local tierToUse = state.altPlayerTier.value
            if tierToUse == 'VI' then tierToUse = 'V' end
            handle_altNuke(state.altPlayerDark.value, tierToUse, false)
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.blm_alt_cast_message('cast_dark', state.altPlayerDark.value, tierToUse)
        else
            local success_MessageUtils, MessageUtils = pcall(require, 'utils/MESSAGES')
            if not success_MessageUtils then
                error("Failed to load utils/messages: " .. tostring(MessageUtils))
            end
            MessageUtils.blm_alt_cast_message('error_dark')
        end
        eventArgs.handled = true
        return
        -- If the command is defined, execute it
    elseif commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- Try BLM commands first
        local handled = handle_blm_commands(cmdParams)

        -- Try SCH subjob commands if BLM didn't handle it
        if not handled and player.sub_job == 'SCH' then
            handled = handle_sch_subjob_commands(cmdParams)
        end

        -- Note: No warning for unhandled commands since they might be
        -- handled by the base GearSwap system or other modules
    end
end
