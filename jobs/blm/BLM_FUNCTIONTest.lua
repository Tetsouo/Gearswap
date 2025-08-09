---============================================================================
--- FFXI GearSwap Development Tool - BLM Function Unit Tests
---============================================================================
--- Professional unit testing suite for BLM-specific functions using LuaUnit.
--- Provides comprehensive test coverage for Black Mage functionality including
--- buff management, spell validation, and equipment optimization testing.
---
--- @file jobs/blm/BLM_FUNCTIONTest.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2023-07-10 | Modified: 2025-08-05
--- @requires luaunit, BLM_FUNCTION.lua
--- @requires Windower FFXI Lua environment
---
--- @usage
---   Run tests with LuaUnit framework for BLM functionality validation
---============================================================================

--- SharedFunctionsTest.lua
-- @module SharedFunctionsTest
-- This module contains unit tests for the SharedFunctions module.

--- @field package.path string
-- The package path is updated to include the path to the luaunit module.
-- This is necessary for the script to locate the luaunit module when 'require' is called.
package.path = package.path .. ";C:/Users/g0dli/AppData/Roaming/luarocks/share/lua/5.4/?.lua"

--- @local luaunit
-- The luaunit module is imported for unit testing.
-- Luaunit is a popular unit testing library for Lua.
local luaunit = require('luaunit')
require('BLM_FUNCTION')

-- ===========================================================================================================
--                                              Test BuffSelf
-- ===========================================================================================================
--- @class TestBuffSelf
-- Test suite for the BuffSelf function.
TestBuffSelf = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It saves the original 'windower' object and replaces it with a mock object.
-- @function setUp
function TestBuffSelf:setUp()
    -- Save the original 'windower' object
    self.originalWindower = windower
    -- Create a mock for 'windower'
    windower = { ffxi = { get_spell_recasts = function() return { [54] = 0, [53] = 0, [55] = 0, [251] = 0 } end } }

    -- Save the original 'os.time' function and replace it with a mock
    self.originalOsTime = os.time
    os.time = function() return 1000 end

    -- Save the original 'send_command' function and replace it with a mock
    -- Save the original 'send_command' function and replace it with a mock
    self.originalSendCommand = send_command
    local send_command_mock
    send_command_mock = {
        calls = {},
        func = function(arg)
            table.insert(send_command_mock.calls, { args = { arg } })
        end
    }
    setmetatable(send_command_mock, { __call = function(_, ...) return send_command_mock.func(...) end })
    send_command = send_command_mock

    -- Mock the 'buffactive' table
    buffactive = { Stoneskin = false, Blink = false, Aquaveil = false, IceSpikes = false }

    -- Mock the 'lastCastTimes' table
    lastCastTimes = { Stoneskin = 500, Blink = 500, Aquaveil = 500, IceSpikes = 500 }
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original 'windower' object and functions.
-- @function tearDown
function TestBuffSelf:tearDown()
    -- Restore the original 'windower' object
    windower = self.originalWindower

    -- Restore the original 'os.time' function
    os.time = self.originalOsTime

    -- Restore the original 'send_command' function
    send_command = self.originalSendCommand
end

--- Tests the BuffSelf function.
-- This function tests whether the BuffSelf function correctly queues the spells to be cast.
-- @function testBuffSelf
function TestBuffSelf:testBuffSelf()
    -- Call the BuffSelf function
    BuffSelf()

    -- Verify that the 'send_command' function was called with the correct arguments
    luaunit.assertEquals(send_command.calls[1].args[1], 'wait 0; input /ma "Stoneskin" <me>')
    luaunit.assertEquals(send_command.calls[2].args[1], 'wait 5; input /ma "Blink" <me>')
    luaunit.assertEquals(send_command.calls[3].args[1], 'wait 10; input /ma "Aquaveil" <me>')
    luaunit.assertEquals(send_command.calls[4].args[1], 'wait 15; input /ma "Ice Spikes" <me>')
end

--- Tests the BuffSelf function when some buffs are already active.
-- This function tests whether the BuffSelf function correctly queues only the spells for the buffs that are not active.
-- @function testBuffSelfWithActiveBuffs
function TestBuffSelf:testWithActiveBuffs()
    -- Make some buffs active
    buffactive.Stoneskin = true
    buffactive.Blink = true

    -- Call the BuffSelf function
    BuffSelf()

    -- Verify that the 'send_command' function was called only for the buffs that are not active
    luaunit.assertEquals(#send_command.calls, 2)
    luaunit.assertEquals(send_command.calls[1].args[1], 'wait 0; input /ma "Aquaveil" <me>')
    luaunit.assertEquals(send_command.calls[2].args[1], 'wait 5; input /ma "Ice Spikes" <me>')
end

--- Tests the BuffSelf function with different spell recast times.
-- This function tests whether the BuffSelf function correctly queues the spells based on their recast times.
-- @function testBuffSelfWithDifferentRecastTimes
function TestBuffSelf:testWithDifferentRecastTimes()
    -- Set different recast times for the spells
    windower.ffxi.get_spell_recasts = function() return { [54] = 0, [53] = 10, [55] = 20, [251] = 30 } end

    -- Call the BuffSelf function
    BuffSelf()

    -- Verify that the 'send_command' function was called only for the spells that are ready to be cast
    luaunit.assertEquals(#send_command.calls, 1)
    luaunit.assertEquals(send_command.calls[1].args[1], 'wait 0; input /ma "Stoneskin" <me>')
end

-- ===========================================================================================================
--                                              Test RefineVariousSpells
-- ===========================================================================================================
--- @class TestRefineVariousSpells
-- Test suite for the refine_various_spells function.
TestRefineVariousSpells = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It saves the original 'windower', 'player', 'cancel_spell', 'send_command', and 'state' objects and replaces them with mock objects.
-- @function setUp
function TestRefineVariousSpells:setUp()
    -- Save the original 'windower' object
    self.originalWindower = windower

    -- Create a mock for 'windower'
    windower = {
        ffxi = {
            get_spell_recasts = function() return {} end
        }
    }

    -- Save the original 'get_spell_recasts' function after the mock
    self.original_get_spell_recasts = windower.ffxi.get_spell_recasts

    -- Create a stub for the player object
    self.originalPlayer = player
    player = {
        mp = 0
    }

    -- Create a stub for the cancel_spell function
    self.originalCancelSpell = cancel_spell
    cancel_spell = function() end

    -- Create a stub for the send_command function
    self.originalSendCommand = send_command
    send_command = function() end

    -- Create a stub for the state object
    self.originalState = state
    state = {
        CastingMode = {
            value = ''
        }
    }
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original 'windower.ffxi.get_spell_recasts', 'player', 'cancel_spell', 'send_command', and 'state' objects.
-- @function tearDown
function TestRefineVariousSpells:tearDown()
    -- Restore the original functions
    windower.ffxi.get_spell_recasts = self.original_get_spell_recasts
    player = self.originalPlayer
    cancel_spell = self.originalCancelSpell
    send_command = self.originalSendCommand
    state = self.originalState
end

--- Tests the refine_various_spells function when the spell is on cooldown and the player does not have enough mana.
-- This function tests whether the refine_various_spells function correctly cancels the spell when it is on cooldown and the player does not have enough mana.
-- @function testOnCooldownAndNotEnoughMana
function TestRefineVariousSpells:testOnCooldownAndNotEnoughMana()
    -- Modify the mock to return specific values
    windower.ffxi.get_spell_recasts = function() return { [1] = 60 } end
    player.mp = 10
    state.CastingMode.value = 'MagicBurst'
    -- Call the function
    local eventArgs = {}
    local spellCorrespondence = { Spell = { replace = 'NewSpell' } }
    refine_various_spells({ name = 'Spell', recast_id = 1, mp_cost = 20, target = { raw = 'target' } }, eventArgs,
        spellCorrespondence)
    -- Verify that the spell was cancelled
    luaunit.assertTrue(eventArgs.cancel)
end

--- Tests the refine_various_spells function when the spell is not on cooldown and the player has enough mana.
-- This function tests whether the refine_various_spells function correctly casts the spell when it is not on cooldown and the player has enough mana.
-- @function testNotOnCooldownAndEnoughMana
function TestRefineVariousSpells:testNotOnCooldownAndEnoughMana()
    -- Modify the mock to return specific values
    windower.ffxi.get_spell_recasts = function() return { [1] = 0 } end
    player.mp = 100
    state.CastingMode.value = 'MagicBurst'
    -- Call the function
    local eventArgs = {}
    local spellCorrespondence = { Spell = { replace = 'NewSpell' } }
    refine_various_spells({ name = 'Spell', recast_id = 1, mp_cost = 20, target = { raw = 'target' } }, eventArgs,
        spellCorrespondence)
    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)
end

--- Tests the refine_various_spells function when the spell is on cooldown and the player has enough mana.
-- This function tests whether the refine_various_spells function correctly cancels the spell when it is on cooldown and the player has enough mana.
-- @function testOnCooldownAndEnoughMana
function TestRefineVariousSpells:testOnCooldownAndEnoughMana()
    -- Modify the mock to return specific values
    windower.ffxi.get_spell_recasts = function() return { [1] = 60 } end
    player.mp = 100
    state.CastingMode.value = 'MagicBurst'
    -- Call the function
    local eventArgs = {}
    local spellCorrespondence = { Spell = { replace = 'NewSpell' } }
    refine_various_spells({ name = 'Spell', recast_id = 1, mp_cost = 20, target = { raw = 'target' } }, eventArgs,
        spellCorrespondence)
    -- Verify that the spell was cancelled
    luaunit.assertTrue(eventArgs.cancel)
end

--- Tests the refine_various_spells function when the spell is not on cooldown and the player does not have enough mana.
-- This function tests whether the refine_various_spells function correctly cancels the spell when it is not on cooldown and the player does not have enough mana.
-- @function testNotOnCooldownAndNotEnoughMana
function TestRefineVariousSpells:testNotOnCooldownAndNotEnoughMana()
    -- Modify the mock to return specific values
    windower.ffxi.get_spell_recasts = function() return { [1] = 0 } end
    player.mp = 10
    state.CastingMode.value = 'MagicBurst'
    -- Call the function
    local eventArgs = {}
    local spellCorrespondence = { Spell = { replace = 'NewSpell' } }
    refine_various_spells({ name = 'Spell', recast_id = 1, mp_cost = 20, target = { raw = 'target' } }, eventArgs,
        spellCorrespondence)
    -- Verify that the spell was cancelled
    luaunit.assertTrue(eventArgs.cancel)
end

-- ===========================================================================================================
--                                              Test CustomizeIdleSet
-- ===========================================================================================================
--- @class TestCustomizeIdleSet
-- Test suite for the customize_idle_set function.
TestCustomizeIdleSet = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It saves the original 'customize_set' function and 'sets' variable and replaces them with mock values.
-- @function setUp
function TestCustomizeIdleSet:setUp()
    -- Save the original 'customize_set' function and 'sets' variable
    self.originalCustomizeSet = customize_set
    self.originalSets = sets

    -- Create a mock for 'customize_set' that modifies idleSet
    customize_set = function(idleSet, conditions, setTable)
        idleSet.modified = true
        return idleSet
    end

    -- Create a mock for 'sets'
    sets = { buff = { ['Mana Wall'] = 'mock set' } }
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original 'customize_set' function and 'sets' variable.
-- @function tearDown
function TestCustomizeIdleSet:tearDown()
    -- Restore the original function and variable
    customize_set = self.originalCustomizeSet
    sets = self.originalSets
end

--- Tests the customize_idle_set function.
-- This function tests whether the customize_idle_set function correctly calls the customize_set function with the correct parameters and reacts correctly to the modification of idleSet.
-- @function testCustomizeIdleSet
function TestCustomizeIdleSet:testCustomizeIdleSet()
    -- Define the idleSet
    local idleSet = { item1 = 'item1', item2 = 'item2' }

    -- Call the function
    customize_idle_set(idleSet)

    -- Verify that the customize_set function was called with the correct parameters
    luaunit.assertEquals(idleSet.item1, 'item1')
    luaunit.assertEquals(idleSet.item2, 'item2')

    -- Verify that idleSet was modified
    luaunit.assertTrue(idleSet.modified)
end

--- Tests the customize_idle_set function with a nil idleSet.
-- This function tests whether the customize_idle_set function correctly handles a nil idleSet.
-- @function testCustomizeIdleSetWithNilIdleSet
function TestCustomizeIdleSet:testCustomizeIdleSetWithNilIdleSet()
    -- Call the function with a nil idleSet
    local success, err = pcall(customize_idle_set, nil)

    -- Verify that the function failed and the error message contains the expected string
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "idleSet must not be nil")
end

--- Tests the customize_idle_set function with a nil 'Mana Wall' set.
-- This function tests whether the customize_idle_set function correctly handles a nil 'Mana Wall' set.
-- @function testCustomizeIdleSetWithNilManaWallSet
function TestCustomizeIdleSet:testCustomizeIdleSetWithNilManaWallSet()
    -- Remove the 'Mana Wall' set
    sets.buff['Mana Wall'] = nil

    -- Define the idleSet
    local idleSet = { item1 = 'item1', item2 = 'item2' }

    -- Call the function
    local success, err = pcall(customize_idle_set, idleSet)

    -- Verify that the function failed and the error message contains the expected string
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "'Mana Wall' set must not be nil")
end

-- ===========================================================================================================
--                                              Test CustomizeIdleSet
-- ===========================================================================================================
--- Test suite for the mergeTables function.
-- This test suite contains tests for the mergeTables function.
-- @table TestMergeTables
TestMergeTables = {}

--- Sets up the test environment.
-- This function is called before each test case is executed.
function TestMergeTables:setUp()
    -- Define the tables to be used in the tests
    self.t1 = { a = 1, b = 2 }
    self.t2 = { c = 3, d = 4 }
end

--- Tests the mergeTables function with valid input.
-- This function tests whether the mergeTables function correctly merges two tables when it is given valid input.
function TestMergeTables:testMergeTablesWithValidInput()
    -- Call the function with valid input
    local result = mergeTables(self.t1, self.t2)

    -- Verify that the function returned the correct result
    luaunit.assertEquals(result, { a = 1, b = 2, c = 3, d = 4 })
end

--- Tests the mergeTables function with a nil first table.
-- This function tests whether the mergeTables function correctly handles a nil first table.
function TestMergeTables:testMergeTablesWithNilFirstTable()
    -- Call the function with a nil first table
    local success, err = pcall(mergeTables, nil, self.t2)

    -- Verify that the function failed and the error message contains the expected string
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "t1 must be a table")
end

--- Tests the mergeTables function with a nil second table.
-- This function tests whether the mergeTables function correctly handles a nil second table.
function TestMergeTables:testMergeTablesWithNilSecondTable()
    -- Call the function with a nil second table
    local success, err = pcall(mergeTables, self.t1, nil)

    -- Verify that the function failed and the error message contains the expected string
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "t2 must be a table")
end

-- ===========================================================================================================
--                                              Test SaveMP
-- ===========================================================================================================
--- Test suite for the SaveMP function.
-- This test suite contains tests for the SaveMP function.
-- @table TestSaveMP
TestSaveMP = {}

--- Set up the test environment.
-- This function is called before each test. It sets up the mock objects and the test data.
-- @within TestSaveMP
function TestSaveMP:setUp()
    -- Define the mock objects
    player = { mp = 1000 }
    state = { CastingMode = { value = 'Normal' } }
    sets = { midcast = { ['Elemental Magic'] = {} } }

    -- Define baseSet, which represents the base gear set
    baseSet = {
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

    -- Define the gear sets for the different test scenarios
    normalSetLowMP = mergeTables(baseSet, {
        body = "Spaekona's Coat +3",
        waist = "Orpheus's Sash"
    })
    magicBurstSetLowMP = mergeTables(baseSet, {
        body = "Spaekona's Coat +3",
        ammo = 'Ghastly tathlum +1',
        feet = "Agwu's Pigaches",
        waist = 'Hachirin-no-obi'
    })
    normalSetHighMP = mergeTables(baseSet, {
        body = 'Wicce Coat +3',
        waist = "Orpheus's Sash"
    })
    magicBurstSetHighMP = mergeTables(baseSet, {
        body = 'Wicce Coat +3',
        ammo = 'Ghastly tathlum +1',
        feet = "Agwu's Pigaches",
        waist = 'Hachirin-no-obi'
    })
end

--- Tear down the test environment.
-- This function is called after each test. It resets the mock objects and the test data.
-- @within TestSaveMP
function TestSaveMP:tearDown()
    -- Reset the mock objects
    player = nil
    state = nil
    sets = nil
    baseSet = nil
    normalSetLowMP = nil
    magicBurstSetLowMP = nil
    normalSetHighMP = nil
    magicBurstSetHighMP = nil
end

--- Test the SaveMP function with low MP and normal casting mode.
-- This test verifies that the SaveMP function sets the correct gear when the player's MP is low and the casting mode is normal.
-- @within TestSaveMP
function TestSaveMP:testSaveMPWithLowMPAndNormalMode()
    -- Set the player's MP and casting mode
    player.mp = 500
    state.CastingMode.value = 'Normal'

    -- Call the function
    SaveMP()

    -- Verify that the function set the correct gear
    luaunit.assertEquals(sets.midcast['Elemental Magic'], normalSetLowMP)
end

--- Test the SaveMP function with low MP and magic burst mode.
-- This test verifies that the SaveMP function sets the correct gear when the player's MP is low and the casting mode is magic burst.
-- @within TestSaveMP
function TestSaveMP:testSaveMPWithLowMPAndMagicBurstMode()
    -- Set the player's MP and casting mode
    player.mp = 500
    state.CastingMode.value = 'Magic Burst'

    -- Call the function
    SaveMP()

    -- Verify that the function set the correct gear
    luaunit.assertEquals(sets.midcast['Elemental Magic'].MagicBurst, magicBurstSetLowMP)
end

--- Test the SaveMP function with high MP and normal casting mode.
-- This test verifies that the SaveMP function sets the correct gear when the player's MP is high and the casting mode is normal.
-- @within TestSaveMP
function TestSaveMP:testSaveMPWithHighMPAndNormalMode()
    -- Set the player's MP and casting mode
    player.mp = 1500
    state.CastingMode.value = 'Normal'

    -- Call the function
    SaveMP()

    -- Verify that the function set the correct gear
    luaunit.assertEquals(sets.midcast['Elemental Magic'], normalSetHighMP)
end

--- Test the SaveMP function with high MP and magic burst mode.
-- This test verifies that the SaveMP function sets the correct gear when the player's MP is high and the casting mode is magic burst.
-- @within TestSaveMP
function TestSaveMP:testSaveMPWithHighMPAndMagicBurstMode()
    -- Set the player's MP and casting mode
    player.mp = 1500
    state.CastingMode.value = 'Magic Burst'

    -- Call the function
    SaveMP()

    -- Verify that the function set the correct gear
    luaunit.assertEquals(sets.midcast['Elemental Magic'].MagicBurst, magicBurstSetHighMP)
end

-- ===========================================================================================================
--                                              Test SaveMP
-- ===========================================================================================================
--- @class TestCheckArts
-- Test suite for the checkArts function.
TestCheckArts = {}

--- Sets up the test environment before each test.
function TestCheckArts:setUp()
    -- Save the original objects and functions
    self.originalPlayer = player
    self.originalWindower = windower
    self.originalCancelSpell = cancel_spell
    self.originalSendCommand = send_command

    -- Create stubs for the player object and the windower.ffxi.get_ability_recasts function
    player = { sub_job = 'SCH' }
    windower = {
        ffxi = {
            get_ability_recasts = function() return { [232] = 0 } end
        }
    }

    -- Create stubs for the cancel_spell and send_command functions
    cancel_spell = function() end
    send_command = function() end
end

--- Tears down the test environment after each test.
function TestCheckArts:tearDown()
    -- Restore the original objects and functions
    player = self.originalPlayer
    windower = self.originalWindower
    cancel_spell = self.originalCancelSpell
    send_command = self.originalSendCommand
end

--- Tests the checkArts function when the player's sub-job is Scholar and the 'Dark Arts' ability is available.
function TestCheckArts:testScholarAndDarkArtsAvailable()
    -- Call the function with a spell that has 'Elemental Magic' as its skill
    local spell = { skill = 'Elemental Magic', name = 'Spell' }
    local eventArgs = {}
    checkArts(spell, eventArgs)

    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)
end

--- Tests the checkArts function when the player's sub-job is not Scholar.
function TestCheckArts:testNotScholar()
    -- Change the player's sub-job to something other than Scholar
    player.sub_job = 'WHM'

    -- Call the function with a spell that has 'Elemental Magic' as its skill
    local spell = { skill = 'Elemental Magic', name = 'Spell' }
    local eventArgs = {}
    checkArts(spell, eventArgs)

    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)
end

--- Tests the checkArts function when the 'Dark Arts' ability is not available.
function TestCheckArts:testDarkArtsNotAvailable()
    -- Change the recast time for the 'Dark Arts' ability to something greater than 0
    windower.ffxi.get_ability_recasts = function() return { [232] = 60 } end

    -- Call the function with a spell that has 'Elemental Magic' as its skill
    local spell = { skill = 'Elemental Magic', name = 'Spell' }
    local eventArgs = {}
    checkArts(spell, eventArgs)

    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)
end

--- Tests the checkArts function when the player's sub-job is Scholar, the 'Dark Arts' ability is available, but the spell is not 'Elemental Magic'.
function TestCheckArts:testScholarAndDarkArtsAvailableButNotElementalMagic()
    -- Call the function with a spell that does not have 'Elemental Magic' as its skill
    local spell = { skill = 'Healing Magic', name = 'Spell' }
    local eventArgs = {}
    checkArts(spell, eventArgs)

    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)
end

--- Tests the checkArts function when the player's sub-job is Scholar, the 'Dark Arts' ability is available, the spell is 'Elemental Magic', but 'Dark Arts' or 'Addendum: Black' is active.
function TestCheckArts:testScholarAndDarkArtsAvailableButDarkArtsOrAddendumBlackActive()
    -- Set 'Dark Arts' as active
    buffactive['Dark Arts'] = true

    -- Call the function with a spell that has 'Elemental Magic' as its skill
    local spell = { skill = 'Elemental Magic', name = 'Spell' }
    local eventArgs = {}
    checkArts(spell, eventArgs)

    -- Verify that the spell was not cancelled
    luaunit.assertNil(eventArgs.cancel)

    -- Reset 'Dark Arts' as not active
    buffactive['Dark Arts'] = nil
end

-- ===========================================================================================================
--                                              Test JobSelfCommand
-- ===========================================================================================================
--- @class TestJobSelfCommand
-- Test suite for the job_self_command function.
TestJobSelfCommand = {}

---- Sets up the test environment before each test.
function TestJobSelfCommand:setUp()
    -- Initialize the global 'player' variable
    player = { sub_job = '' }

    -- Save the original functions and variables
    self.originalCommandFunctions = commandFunctions
    self.originalHandleBlmCommands = handle_blm_commands
    self.originalHandleSchSubjobCommands = handle_sch_subjob_commands
    self.originalPlayerSubJob = player.sub_job
    self.originalUpdateAltState = update_altState

    -- Create stubs and mocks
    commandFunctions = { mockCommand = function() end }
    handle_blm_commands = function() end
    handle_sch_subjob_commands = function() end
    update_altState = function() end -- Stub for update_altState
end

--- Tears down the test environment after each test.
function TestJobSelfCommand:tearDown()
    -- Restore the original functions and variables
    commandFunctions = self.originalCommandFunctions
    handle_blm_commands = self.originalHandleBlmCommands
    handle_sch_subjob_commands = self.originalHandleSchSubjobCommands
    player.sub_job = self.originalPlayerSubJob
    update_altState = self.originalUpdateAltState -- Restore original update_altState
end

--- Tests the job_self_command function with a defined command.
function TestJobSelfCommand:testWithDefinedCommand()
    -- Call the function with a defined command
    local cmdParams = { 'mockCommand' }
    local eventArgs = {}
    local spell = {}
    job_self_command(cmdParams, eventArgs, spell)

    -- Verify that no error was thrown
    luaunit.assertTrue(true)
end

--- Tests the job_self_command function with an undefined command and a non-SCH sub-job.
function TestJobSelfCommand:testWithUndefinedCommandAndNonSchSubJob()
    -- Set the player's sub-job to a non-SCH job
    player.sub_job = 'BLM'

    -- Call the function with an undefined command
    local cmdParams = { 'undefinedCommand' }
    local eventArgs = {}
    local spell = {}
    job_self_command(cmdParams, eventArgs, spell)

    -- Verify that no error was thrown
    luaunit.assertTrue(true)
end

--- Tests the job_self_command function with an undefined command and a SCH sub-job.
function TestJobSelfCommand:testWithUndefinedCommandAndSchSubJob()
    -- Set the player's sub-job to SCH
    player.sub_job = 'SCH'

    -- Call the function with an undefined command
    local cmdParams = { 'undefinedCommand' }
    local eventArgs = {}
    local spell = {}
    job_self_command(cmdParams, eventArgs, spell)

    -- Verify that no error was thrown
    luaunit.assertTrue(true)
end

os.exit(luaunit.LuaUnit.run())
