---============================================================================
--- FFXI GearSwap Job Module - Black Mage Advanced Functions
---============================================================================

-- Load Windower resources for spell data
local res = require('resources')
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
--- TEMPORARILY DISABLED - Always returns true to diagnose spell replacement issues
--- @param spellName string The name of the spell to check
--- @param currentTime number Current timestamp
--- @return boolean true if spell is safe to cast
local function isSpellSafeToCast(spellName, currentTime)
    -- DISABLED FOR DEBUGGING - Always allow casting
    return true
end

-- This function manages self-buff spells in the game Final Fantasy XI.
-- It checks the recast time of each spell and if the buff is active.
-- If the buff is not active or is about to expire, it queues the spell to be cast.
-- ENHANCED: Now includes lag compensation to prevent spell spam in laggy zones
function BuffSelf()
    -- Get the current time
    local currentTime = os.time()
    -- Get the recast times for all spells
    local SpellRecasts = windower.ffxi.get_spell_recasts()

    -- Assert that SpellRecasts is a table
    assert(type(SpellRecasts) == "table", "Failed to get spell recasts")

    -- Define the spells to manage
    local spells = {
        { name = 'Stoneskin',  recast = 54,  delay = 0, buffName = 'Stoneskin',  duration = 488 },
        { name = 'Blink',      recast = 53,  delay = 6, buffName = 'Blink',      duration = 488 },
        { name = 'Aquaveil',   recast = 55,  delay = 6, buffName = 'Aquaveil',   duration = 914 },
        { name = 'Ice Spikes', recast = 251, delay = 6, buffName = 'Ice Spikes', duration = 274 }
    }

    -- Initialize the list of spells ready to be cast
    local readySpells = {}
    -- Initialize the total delay for casting spells
    local totalDelay = 0

    -- For each spell
    for _, spell in ipairs(spells) do
        -- Get the recast time for the spell
        spell.recast = SpellRecasts[spell.recast]

        -- Only cast if buff is not active (simple and reliable logic)
        if spell.duration > 0 and not buffactive[spell.buffName] then
            -- Check if the spell is ready to be cast AND safe to cast (lag compensation)
            if spell.recast == 0 and isSpellSafeToCast(spell.name, currentTime) then
                if #readySpells > 0 then
                    -- Increase the total delay
                    totalDelay = totalDelay + spell.delay
                end
                -- Add the spell to the list of spells ready to be cast
                table.insert(readySpells, { spell = spell, delay = totalDelay })
            end
        end
    end

    -- For each spell ready to be cast
    for _, readySpell in ipairs(readySpells) do
        -- Send the command to cast the spell after the delay
        send_command('wait ' .. readySpell.delay .. '; input /ma "' .. readySpell.spell.name .. '" <me>')
        -- Update the last cast time for the spell
        lastCastTimes[readySpell.spell.name] = currentTime

        -- Log the cast attempt for debugging in laggy conditions
        local log = require('utils/logger')
        log.debug("BuffSelf: Casting %s (delay: %ds, safe: %s)",
            readySpell.spell.name, readySpell.delay, "true")
    end

    -- If no spells are ready, show recast times for spells that are on cooldown
    if #readySpells == 0 then
        local spellsOnCooldown = {}
        for _, spell in ipairs(spells) do
            -- Show recast for spells that are on cooldown, regardless of buff status
            if spell.recast > 0 then
                table.insert(spellsOnCooldown, spell)
            end
        end

        -- Display recast times for spells on cooldown
        if #spellsOnCooldown > 0 then
            for _, spell in ipairs(spellsOnCooldown) do
                local recastTime = spell.recast / 60  -- Convert to minutes
                local msg = createFormattedMessage(nil, spell.name, recastTime, nil, true)
                add_to_chat(123, msg)
            end
        else
            -- All spells are ready but buffs are active - inform user with colored message
            local MessageUtils = require('utils/messages')
            local colorGreen = MessageUtils.create_color_code(MessageUtils.colors.YELLOW)  -- Vert pour le texte principal
            local colorGray = MessageUtils.create_color_code(MessageUtils.colors.GRAY)     -- Gris pour les séparateurs
            
            local coloredMsg = string.format('%s[%sAll buff spells are ready%s] %sbut already active',
                colorGray,     -- [
                colorGreen,    -- All buff spells are ready (en vert)
                colorGray,     -- ]
                colorGray      -- but already active (en gris)
            )
            add_to_chat(123, coloredMsg)
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

    -- Keep trying lower tiers until we find one that works
    local maxIterations = 6 -- Prevent infinite loops (VI -> V -> IV -> III -> II -> I)
    local iterations = 0

    while currentLevel and iterations < maxIterations do
        iterations = iterations + 1

        -- Build the spell name for this tier
        local testSpellName = currentLevel == '' and spellCategory or spellCategory .. ' ' .. currentLevel

        -- Try to get spell info using Windower's resource tables
        local testSpell = res.spells:with('en', testSpellName)

        if testSpell then
            -- Check if this tier is available
            if spell_recasts[testSpell.recast_id] == 0 and player_mp >= (testSpell.mp_cost or 999) then
                -- This tier is available, use it
                newSpell = testSpellName
                break
            end
        end

        -- Get next lower tier from correspondence table
        local tier = correspondence[currentLevel]
        if not tier then
            break
        end

        currentLevel = tier.replace

        -- If we've reached the base tier (empty string = tier I)
        if currentLevel == '' then
            local tierOneSpell = spellCategory
            local tierOne = res.spells:with('en', tierOneSpell)
            if tierOne and spell_recasts[tierOne.recast_id] == 0 and player_mp >= (tierOne.mp_cost or 999) then
                newSpell = tierOneSpell
            end
            break
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
            jaUnavailable = true  -- Spell not found, treat as unavailable
        end
        
        -- Only downgrade to -ga series if the -ja spell is truly unavailable
        if jaUnavailable then
            local baseElement = string.gsub(spell.name, 'ja.*', '')  -- Fire, Stone, etc.
            local gaCorrespondence = spellCorrespondence[baseElement .. 'ga']
            
            if gaCorrespondence then
                -- Try to find available -ga spell starting from III
                local gaNewSpell, _ = handle_spell_replacement(
                    {english = baseElement .. 'ga III', name = baseElement .. 'ga III'},
                    spell_recasts, player_mp, gaCorrespondence, baseElement .. 'ga', 'III'
                )
                if gaNewSpell and gaNewSpell ~= baseElement .. 'ga III' then
                    newSpell = gaNewSpell
                else
                    newSpell = baseElement .. 'ga III'  -- Fallback to ga III
                end
            else
                newSpell = string.gsub(spell.name, 'ja', 'ga') .. ' III'  -- Original logic
            end
        end
    end

    -- Log the replacement for debugging
    if newSpell ~= originalSpell then
        local log = require('utils/logger')
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

    local currentTime = os.time()

    -- Skip replacement if we just replaced a spell (2 second cooldown)
    if (currentTime - lastReplacementTime) < 2 then
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
        windower.add_to_chat(123, createFormattedMessage(
            'Cannot cast spell:',
            newSpell,
            nil,
            'Not enough Mana: (' .. player_mp .. 'MP)',
            true,
            true
        ))
        return
    end

    if newSpell ~= spell.english then
        -- Update timestamp to prevent rapid replacements
        lastReplacementTime = currentTime

        -- Send the replacement spell command with a small delay
        send_command('wait 0.5; input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
        eventArgs.cancel = true

        -- Log replacement for debugging
        local log = require('utils/logger')
        log.info("Spell downgraded: %s -> %s (MP: %d)", spell.english, newSpell, player_mp)
    else
        -- No replacement found - check if original spell is on cooldown and show recast info
        local originalSpellData = res.spells:with('en', spell.english)
        if originalSpellData and correspondence then
            local recastTime = spell_recasts[originalSpellData.recast_id]
            if recastTime and recastTime > 0 then
                -- Original spell is on cooldown, show recast times for all tiers
                eventArgs.cancel = true
                
                -- Show recast for original spell
                local msg = createFormattedMessage(nil, spell.english, recastTime / 60, nil, true)
                windower.add_to_chat(123, msg)
                
                -- Also show recast for lower tiers if they exist and are on cooldown
                local currentLevel = spellLevel
                local maxIterations = 6
                local iterations = 0
                
                while currentLevel and correspondence[currentLevel] and iterations < maxIterations do
                    iterations = iterations + 1
                    local nextLevel = correspondence[currentLevel].replace
                    
                    if nextLevel == '' then
                        -- Check base tier (no roman numeral)
                        local baseTierSpell = res.spells:with('en', spellCategory)
                        if baseTierSpell then
                            local baseTierRecast = spell_recasts[baseTierSpell.recast_id]
                            if baseTierRecast and baseTierRecast > 0 then
                                local baseMsg = createFormattedMessage(nil, spellCategory, baseTierRecast / 60, nil, true)
                                windower.add_to_chat(123, baseMsg)
                            end
                        end
                        break
                    else
                        -- Check next tier
                        local nextTierSpellName = spellCategory .. ' ' .. nextLevel
                        local nextTierSpell = res.spells:with('en', nextTierSpellName)
                        if nextTierSpell then
                            local nextTierRecast = spell_recasts[nextTierSpell.recast_id]
                            if nextTierRecast and nextTierRecast > 0 then
                                local nextMsg = createFormattedMessage(nil, nextTierSpellName, nextTierRecast / 60, nil, true)
                                windower.add_to_chat(123, nextMsg)
                            end
                        end
                        currentLevel = nextLevel
                    end
                end
                
                return
            end
        end
    end
    
    -- Magic Burst announcement
    if state.CastingMode.value == 'MagicBurst' and spell.skill == 'Elemental Magic' then
        send_command((spellLevel == 'VI' and 'wait 2; ' or '') ..
            'input /p Casting: [' .. spellCategory .. ' ' .. spellLevel .. '] => Nuke')
    end

    if spell.english == 'Breakga' and spell_recasts[spell.recast_id] > 0 then
        -- LAG COMPENSATION: Secure Breakga -> Break replacement
        local breakKey = "Breakga_to_Break"
        if isSpellSafeToCast(breakKey, currentTime) then
            cancel_spell()
            newSpell = 'Break'
            if spell_recasts[255] > 0 then
                cancel_spell()
                eventArgs.cancel = true
                local recastTime = spell_recasts[255] / 60
                local msg = createFormattedMessage(nil, newSpell, recastTime)
                add_to_chat(123, msg)
            else
                send_command('@input /ma "' .. newSpell .. '" ' .. tostring(spell.target.raw))
                eventArgs.cancel = true
            end
        else
            -- Breakga replacement blocked
            eventArgs.cancel = true
            local log = require('utils/logger')
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

    -- Define the conditions and the corresponding sets
    local conditions = { Manawall = Manawall }
    local setTable = { Manawall = sets.buff['Mana Wall'] }

    assert(setTable.Manawall, "'Mana Wall' set must not be nil")

    -- Use the customize_set function to customize the idleSet
    local EquipmentUtils = require('core/equipment')
    return EquipmentUtils.customize_set(idleSet, conditions, setTable)
end

-- Function: mergeTables
-- This function merges two tables together.
function mergeTables(t1, t2)
    assert(t1 and type(t1) == 'table', "t1 must be a table")
    assert(t2 and type(t2) == 'table', "t2 must be a table")

    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Base equipment set
local baseSet = {
    main = "Bunzi's Rod",
    sub = "Ammurapi Shield",
    ammo = { name = "Ghastly Tathlum +1", augments = { 'Path: A', } },
    head = "Wicce Petasos +3",
    body = "Spaekona's Coat +3",
    hands = "Wicce Gloves +3",
    legs = "Wicce Chausses +3",
    feet = "Wicce Sabots +3",
    neck = { name = "Src. Stole +2", augments = { 'Path: A', } },
    waist = { name = "Acuity Belt +1", augments = { 'Path: A', } },
    left_ear = "Malignance Earring",
    right_ear = "Regal Earring",
    left_ring = "Freke Ring",
    right_ring = { name = "Metamor. Ring +1", augments = { 'Path: A', } },
    back = "Taranus's cape"
}

-- Equipment set for 'Elemental Magic' in 'Normal' mode when MP < 1000
-- This set merges the base set with an additional body piece.
local normalSetLowMP = mergeTables(baseSet, {
    body = "Spaekona's Coat +3",
    waist = "Orpheus's Sash"
})

-- Equipment set for 'Elemental Magic' in 'Normal' mode when MP >= 1000
-- This set merges the base set with a different body piece.
local normalSetHighMP = mergeTables(baseSet, {
    body = 'Wicce Coat +3',
    waist = "Orpheus's Sash"
})

-- Equipment set for 'Elemental Magic' in 'MagicBurst' mode when MP < 1000
-- This set merges the base set with additional pieces for body, ammo, feet, and waist.
local magicBurstSetLowMP = mergeTables(baseSet, {
    body = "Spaekona's Coat +3",
    head = "Ea Hat +1",
    hands = "Agwu's Gages",
    left_ring = "Mujin Band",
    ammo = 'Ghastly tathlum +1',
    feet = "Wicce Sabots +3",
    waist = 'Hachirin-no-obi'
})

-- Equipment set for 'Elemental Magic' in 'MagicBurst' mode when MP >= 1000
-- This set merges the base set with different pieces for body, and additional pieces for ammo, feet, and waist.
local magicBurstSetHighMP = mergeTables(baseSet, {
    body = 'Wicce Coat +3',
    head = "Ea Hat +1",
    hands = "Agwu's Gages",
    left_ring = "Mujin Band",
    ammo = 'Ghastly tathlum +1',
    feet = "Wicce Sabots +3",
    waist = 'Hachirin-no-obi'
})

-- Function: SaveMP
-- Adjusts player's gear based on current MP and casting mode.
function SaveMP()
    assert(player.mp, "player.mp must not be nil")
    assert(state and state.CastingMode and state.CastingMode.value, "state.CastingMode.value must not be nil")

    -- If MP is less than 1000, adjust gear based on casting mode.
    if player.mp < 1000 then
        -- If casting mode is 'Normal', use normalSetLowMP. Otherwise, use magicBurstSetLowMP.
        if state.CastingMode.value == 'Normal' then
            sets.midcast['Elemental Magic'] = normalSetLowMP
        else
            sets.midcast['Elemental Magic'].MagicBurst = magicBurstSetLowMP
        end
    else
        -- If MP is 1000 or more, adjust gear based on casting mode.
        -- If casting mode is 'Normal', use normalSetHighMP. Otherwise, use magicBurstSetHighMP.
        if state.CastingMode.value == 'Normal' then
            sets.midcast['Elemental Magic'] = normalSetHighMP
        else
            sets.midcast['Elemental Magic'].MagicBurst = magicBurstSetHighMP
        end
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
        local darkArtsRecast = windower.ffxi.get_ability_recasts()[232]
        -- Check if the player is casting an 'Elemental Magic' spell and doesn't have 'Dark Arts' or 'Addendum: Black' active,
        -- and if the 'Dark Arts' ability is available (recast time is less than 1).
        if
            spell.skill == 'Elemental Magic' and not (buffactive['Dark Arts'] or buffactive['Addendum: Black']) and
            darkArtsRecast < 1
        then
            -- LAG COMPENSATION: Check if Dark Arts activation is safe
            local currentTime = os.time()
            local artsKey = "DarkArts_" .. spell.name

            if isSpellSafeToCast(artsKey, currentTime) then
                -- Cancel the current spell.
                cancel_spell()
                -- Activate 'Dark Arts' and recast the original spell after a 2-second delay.
                send_command('input /ja "Dark Arts" <me>; wait 2; input /ma ' .. spell.name .. ' <t>')

                -- Log Dark Arts activation for debugging
                local log = require('utils/logger')
                log.debug("Dark Arts activated for spell: %s", spell.name)
            else
                -- Dark Arts activation blocked due to lag compensation
                local log = require('utils/logger')
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
    local command = cmdParams[1]:lower()

    -- Let standard GearSwap handle cycle commands for proper state management
    if command == 'cycle' then
        return -- Let GearSwap handle this natively
    end

    -- If the command is defined, execute it
    if commandFunctions[command] then
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
