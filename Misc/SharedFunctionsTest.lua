-- ============================================================--
-- =                    SHARED FUNCTIONS TEST                 =--
-- ============================================================--
-- =                    Author: Tetsuo                        =--
-- =                     Version: 1.0                          =--
-- =                  Created: 2023/07/10                      =--
-- =               Last Modified: 2024/02/04                   =--
-- ============================================================--

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

--- @local SharedFunctions
-- The SharedFunctions module is imported for testing.
-- SharedFunctions is the module under test, which contains the shared functions to be tested.
-- Note: Replace 'SharedFunctions' with the actual path to the module.
local SharedFunctions = require 'SharedFunctions'

-- ===========================================================================================================
--                                     Constants and Global Variables
-- ===========================================================================================================
--- @class TestSharedFunctionsConstants
-- Test suite for SharedFunctions constants and global variables.
TestSharedFunctionsConstants = {}

--- Tests the constants defined in the SharedFunctions module.
-- This function asserts the equality of the defined constants in the SharedFunctions module and their expected values.
-- @function testConstants
function TestSharedFunctionsConstants:testConstants()
    -- Test the color constants
    luaunit.assertEquals(SharedFunctions.GRAY, 160)
    luaunit.assertEquals(SharedFunctions.ORANGE, 057)
    luaunit.assertEquals(SharedFunctions.YELLOW, 050)
    luaunit.assertEquals(SharedFunctions.RED, 028)

    -- Test the WAIT_TIME constant
    luaunit.assertEquals(SharedFunctions.WAIT_TIME, 1.2)

    -- Test the strat_charge_time array
    luaunit.assertEquals(SharedFunctions.strat_charge_time, { 240, 120, 80, 60, 48 })

    -- Test the ignoredSpells array
    luaunit.assertEquals(SharedFunctions.ignoredSpells, { 'Breakga', 'Aspir III', 'Aspir II' })

    -- Test the player names
    luaunit.assertEquals(SharedFunctions.mainPlayerName, 'Tetsouo')
    luaunit.assertEquals(SharedFunctions.altPlayerName, 'Kaories')

    -- Test the altState object
    luaunit.assertEquals(SharedFunctions.altState, {})

    -- Test the incapacitating_buffs_set object
    luaunit.assertEquals(SharedFunctions.incapacitating_buffs_set, {
        silence = true,
        stun = true,
        petrification = true,
        terror = true,
        sleep = true,
        mute = true,
    })
end

-- ===========================================================================================================
--                                    Equipment and Gear Set Functions
-- ===========================================================================================================
--- @class TestCreateEquipment
-- Test suite for the createEquipment function in the SharedFunctions module.
TestCreateEquipment = {}

--- Tests the createEquipment function.
-- This function tests the createEquipment function with different inputs and verifies the expected output.
-- It checks the function's handling of various input types and combinations, including nil values and incorrect types.
-- @function testCreateEquipment
function TestCreateEquipment:testCreateEquipment()
    -- Test 1: Check that createEquipment returns the correct result with specific inputs
    local equipment = createEquipment("Sword", 1, "Bag1", { "Augment1", "Augment2" })
    luaunit.assertEquals(equipment, {
        name = "Sword",
        priority = 1,
        bag = "Bag1",
        augments = { "Augment1", "Augment2" }
    })

    -- Test 2: Check that createEquipment handles nil inputs correctly
    equipment = createEquipment("Sword")
    luaunit.assertEquals(equipment, {
        name = "Sword",
        priority = nil,
        bag = nil,
        augments = {}
    })

    -- Test 3: Check that createEquipment throws an error if name is not a string
    luaunit.assertErrorMsgContains("Parameter 'name' must be a string", createEquipment, 123)

    -- Test 4: Check that createEquipment throws an error if priority is not a number
    luaunit.assertErrorMsgContains("Parameter 'priority' must be a number or nil", createEquipment, "Sword", "high")

    -- Test 5: Check that createEquipment throws an error if bag is not a string
    luaunit.assertErrorMsgContains("Parameter 'bag' must be a string or nil", createEquipment, "Sword", 1, 123)

    -- Test 6: Check that createEquipment throws an error if augments are not a table
    luaunit.assertErrorMsgContains("Parameter 'augments' must be a table", createEquipment, "Sword", 1, "Bag1",
        "Augment1")

    -- Test 7: Check that createEquipment handles nil priority correctly
    equipment = createEquipment("Sword", nil, "Bag1", { "Augment1", "Augment2" })
    luaunit.assertEquals(equipment, {
        name = "Sword",
        priority = nil,
        bag = "Bag1",
        augments = { "Augment1", "Augment2" }
    })

    -- Test 8: Check that createEquipment handles nil bag correctly
    equipment = createEquipment("Sword", 1, nil, { "Augment1", "Augment2" })
    luaunit.assertEquals(equipment, {
        name = "Sword",
        priority = 1,
        bag = nil,
        augments = { "Augment1", "Augment2" }
    })

    -- Test 9: Check that createEquipment handles nil augments correctly
    equipment = createEquipment("Sword", 1, "Bag1", nil)
    luaunit.assertEquals(equipment, {
        name = "Sword",
        priority = 1,
        bag = "Bag1",
        augments = {}
    })
end

-- ===========================================================================================================
--                              State Management and Basic Data Handling
-- ===========================================================================================================
-- ===========================================================================================================
--                                         Test UpdateAltState
-- ===========================================================================================================
--- @class TestUpdateAltState
-- Test suite for the update_altState function in the SharedFunctions module.
TestUpdateAltState = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It mocks the 'state' and 'SharedFunctions.altState' objects.
-- @function setUp
function TestUpdateAltState:setUp()
    self.oldState = state
    self.oldAltState = SharedFunctions.altState

    state = {
        altPlayerLight = { value = "LightValue" },
        altPlayerTier = { value = "TierValue" },
        altPlayerDark = { value = "DarkValue" },
        altPlayera = { value = "RaValue" },
        altPlayerGeo = { value = "GeoValue" },
        altPlayerIndi = { value = "IndiValue" },
        altPlayerEntrust = { value = "EntrustValue" },
    }

    SharedFunctions.altState = {}
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original 'state' and 'SharedFunctions.altState' objects.
-- @function tearDown
function TestUpdateAltState:tearDown()
    state = self.oldState
    SharedFunctions.altState = self.oldAltState
end

--- Tests the update_altState function.
-- This function tests whether the update_altState function correctly updates the 'SharedFunctions.altState' object.
-- @function testUpdateAltState
function TestUpdateAltState:testUpdateAltState()
    update_altState()

    luaunit.assertEquals(SharedFunctions.altState, {
        Light = "LightValue",
        Tier = "TierValue",
        Dark = "DarkValue",
        Ra = "RaValue",
        Geo = "GeoValue",
        Indi = "IndiValue",
        Entrust = "EntrustValue",
    })
end

--- Tests the error handling of the update_altState function.
-- This function tests whether the update_altState function correctly generates errors when 'state' is not a table or a field of 'state' is not a table.
-- @function testUpdateAltStateErrorHandling
function TestUpdateAltState:testErrorHandling()
    state = nil
    luaunit.assertErrorMsgContains("state is not a table", update_altState)

    state = { altPlayerLight = "not a table" }
    luaunit.assertErrorMsgContains("altPlayerLight is not a table", update_altState)
end

--- Tests the side effects of the update_altState function.
-- This function tests whether the update_altState function does not modify extra fields in 'state' and 'SharedFunctions.altState'.
-- @function testUpdateAltStateNoSideEffects
function TestUpdateAltState:testNoSideEffects()
    state.extraField = { value = "ExtraValue" }
    SharedFunctions.altState.extraField = "ExtraValue"

    update_altState()

    luaunit.assertEquals(state.extraField, { value = "ExtraValue" })
    luaunit.assertEquals(SharedFunctions.altState.extraField, "ExtraValue")
end

-- ===========================================================================================================
--                                         Test GetCurrentTargetIdAndName
-- ===========================================================================================================
--- @class TestGetCurrentTargetIdAndName
-- Test suite for the get_current_target_id_and_name function in the SharedFunctions module.
TestGetCurrentTargetIdAndName = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It saves the original 'windower' object and replaces it with a mock object.
-- @function setUp
function TestGetCurrentTargetIdAndName:setUp()
    -- Save the original 'windower' object
    self.originalWindower = windower

    -- Create a mock for 'windower'
    windower = {
        ffxi = {
            get_mob_by_target = function(target)
                if target == 'lastst' then return { id = 123, name = "TargetName" } end
                return nil
            end,
            get_spell_recasts = function() return {} end
        }
    }

    -- Save the original 'get_mob_by_target' function after the mock
    self.original_get_mob_by_target = windower.ffxi.get_mob_by_target
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original 'windower.ffxi.get_mob_by_target' function and 'windower' object.
-- @function tearDown
function TestGetCurrentTargetIdAndName:tearDown()
    -- Restore the original 'get_mob_by_target' function
    windower.ffxi.get_mob_by_target = self.original_get_mob_by_target
    windower = self.originalWindower
end

--- Tests the get_current_target_id_and_name function.
-- This function tests whether the get_current_target_id_and_name function correctly returns the id and name of the current target.
-- @function testGetCurrentTargetIdAndName
function TestGetCurrentTargetIdAndName:testGetCurrentTargetIdAndName()
    local id, name = get_current_target_id_and_name()

    luaunit.assertEquals(id, 123)
    luaunit.assertEquals(name, "TargetName")
end

--- Tests the get_current_target_id_and_name function when there is no target.
-- This function tests whether the get_current_target_id_and_name function correctly returns nil for the id and name when there is no target.
-- @function testGetCurrentTargetIdAndNameNoTarget
function TestGetCurrentTargetIdAndName:testNoTarget()
    -- Modify the mock to return nil
    windower.ffxi.get_mob_by_target = function(target)
        return nil
    end

    local id, name = get_current_target_id_and_name()

    luaunit.assertNil(id)
    luaunit.assertNil(name)
end

-- ===========================================================================================================
--                                         Test Incapacitated
-- ===========================================================================================================
--- @class TestIncapacitated
-- Test suite for the Incapacitated function in the SharedFunctions module.
TestIncapacitated = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It saves the original tables and functions and replaces them with mock objects.
-- @function setUp
function TestIncapacitated:setUp()
    -- Save the original tables and functions
    self.original_SharedFunctions = SharedFunctions
    self.original_buffactive = buffactive
    self.original_cancel_spell = cancel_spell
    self.original_add_to_chat = add_to_chat
    self.original_createFormattedMessage = createFormattedMessage
    self.original_incapacitating_buffs_set = SharedFunctions.incapacitating_buffs_set

    -- Mock the functions
    cancel_spell = function() return true end
    local chat_messages = {}
    add_to_chat = function(message) table.insert(chat_messages, message) end
    createFormattedMessage = function() return "Mocked message" end
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the original tables and functions.
-- @function tearDown
function TestIncapacitated:tearDown()
    -- Restore the original tables and functions
    SharedFunctions = self.original_SharedFunctions
    buffactive = self.original_buffactive
    cancel_spell = self.original_cancel_spell
    add_to_chat = self.original_add_to_chat
    createFormattedMessage = self.original_createFormattedMessage
    SharedFunctions.incapacitating_buffs_set = self.original_incapacitating_buffs_set
end

--- Tests the incapacitated function with invalid inputs.
-- This function tests whether the incapacitated function correctly returns false and an error message when the inputs are invalid.
-- @function testInvalidInputs
function TestIncapacitated:testInvalidInputs()
    local spell = "Invalid"
    local eventArgs = { handled = false }
    local result, error = incapacitated(spell, eventArgs)
    luaunit.assertEquals(result, false)
    luaunit.assertEquals(error, "Invalid inputs")
end

--- Tests the incapacitated function with 'Ability'/'Item' type and 'silence' or 'mute' buff.
-- This function tests whether the incapacitated function correctly returns false and nil when the spell type is 'Ability'/'Item' and the 'silence' or 'mute' buff is active.
-- @function testAbilityItemAndSilenceOrMuteBuff
function TestIncapacitated:testAbilityItemAndSilenceOrMuteBuff()
    buffactive = { silence = true }
    local spell = { action_type = "Ability", name = "Test" }
    local eventArgs = { handled = false }
    local result, buff = incapacitated(spell, eventArgs)
    luaunit.assertEquals(result, false)
    luaunit.assertEquals(buff, nil)
end

--- Tests the incapacitated function with incapacitating buff in buffactive.
-- This function tests whether the incapacitated function correctly returns true and the name of the buff when an incapacitating buff is active.
-- @function testIncapacitatingBuffInBuffactive
function TestIncapacitated:testIncapacitatingBuffInBuffactive()
    buffactive = { testbuff = true }
    SharedFunctions.incapacitating_buffs_set = { testbuff = true }
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }
    local result, buff = incapacitated(spell, eventArgs)
    luaunit.assertEquals(result, true)
    luaunit.assertEquals(buff, "testbuff")
    luaunit.assertEquals(eventArgs.handled, true)
end

--- Test the incapacitated function when there's an error in cancel_spell.
-- This function tests whether the incapacitated function correctly handles an error in the cancel_spell function.
-- @function testErrorInCancelSpell
function TestIncapacitated:testErrorInCancelSpell()
    -- Setup
    buffactive = { testbuff = true }
    SharedFunctions.incapacitating_buffs_set = { testbuff = true }
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }
    cancel_spell = function() error("Test error") end

    -- Test
    local result, error = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, false)
    luaunit.assertStrContains(error, "Error in cancel_spell: ")
end

--- Test the incapacitated function when there's an error in add_to_chat or createFormattedMessage.
-- This function tests whether the incapacitated function correctly handles an error in the add_to_chat or createFormattedMessage functions.
-- @function testErrorInChatFunctions
function TestIncapacitated:testErrorInChatFunctions()
    -- Setup
    buffactive = { testbuff = true }
    SharedFunctions.incapacitating_buffs_set = { testbuff = true }
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }
    add_to_chat = function() error("Test error") end

    -- Test
    local result, error = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, false)
    luaunit.assertStrContains(error, "Error in add_to_chat or createFormattedMessage: ")
end

--- Test the incapacitated function with an empty buffactive.
-- This function tests whether the incapacitated function correctly handles an empty buffactive.
-- @function testEmptyBuffactive
function TestIncapacitated:testEmptyBuffactive()
    -- Setup
    buffactive = {}
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }

    -- Test
    local result, buff = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, false)
    luaunit.assertEquals(buff, nil)
end

--- Test the incapacitated function with multiple incapacitating buffs active.
-- This function tests whether the incapacitated function correctly handles multiple incapacitating buffs.
-- @function testMultipleIncapacitatingBuffs
function TestIncapacitated:testMultipleIncapacitatingBuffs()
    -- Setup
    buffactive = { silence = true, stun = true }
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }

    -- Test
    local result, buff = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, true)
    luaunit.assertTrue(buff == "silence" or buff == "stun")
end

--- Test the incapacitated function with a non-incapacitating buff active.
-- This function tests whether the incapacitated function correctly handles a non-incapacitating buff.
-- @function testNonIncapacitatingBuff
function TestIncapacitated:testNonIncapacitatingBuff()
    -- Setup
    buffactive = { nonincapacitatingbuff = true }
    local spell = { action_type = "Magic", name = "Test" }
    local eventArgs = { handled = false }

    -- Test
    local result, buff = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, false)
    luaunit.assertEquals(buff, nil)
end

--- Test the incapacitated function with an unrecognized action type.
-- This function tests whether the incapacitated function correctly handles an unrecognized action type.
-- @function testUnrecognizedActionType
function TestIncapacitated:testUnrecognizedActionType()
    -- Setup
    buffactive = { silence = true }
    local spell = { action_type = "Unrecognized", name = "Test" }
    local eventArgs = { handled = false }

    -- Test
    local result, buff = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, true)
    luaunit.assertEquals(buff, "silence")
end

--- Test the incapacitated function with 'Ability'/'Item' type and no 'silence' or 'mute' buff active.
-- This function tests whether the incapacitated function correctly handles a spell of type 'Ability'/'Item' with no 'silence' or 'mute' buff active.
-- @function testAbilityItemWithoutSilenceOrMuteBuff
function TestIncapacitated:testAbilityItemWithoutSilenceOrMuteBuff()
    -- Setup
    buffactive = { testbuff = true }
    local spell = { action_type = "Ability", name = "Test" }
    local eventArgs = { handled = false }

    -- Test
    local result, buff = incapacitated(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(result, false)
    luaunit.assertEquals(buff, nil)
end

-- ===========================================================================================================
--                                         Test FindMemberAndPetInParty
-- ===========================================================================================================
--- @class TestFindMemberAndPetInParty
-- Test suite for the `find_member_and_pet_in_party` function in the SharedFunctions module.
TestFindMemberAndPetInParty = {}

--- Setup function for initializing the party data.
-- This function sets up the party data for the tests.
-- @function setUp
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:setUp()
    _G.party = {
        { mob = { name = "Alice", pet_index = 1 } },
        { mob = { name = "Bob" } },
        { mob = { name = "Charlie", pet_index = 2 } }
    }
end

--- Teardown function for cleaning up the party data.
-- This function cleans up the party data after the tests.
-- @function tearDown
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:tearDown()
    _G.party = nil
end

--- Test for a party member who has a pet.
-- This test checks if the function correctly identifies a party member who has a pet.
-- @function testMemberWithPet
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testMemberWithPet()
    local result = find_member_and_pet_in_party("Alice")
    luaunit.assertEquals(result, true)
end

--- Test for a party member who doesn't have a pet.
-- This test checks if the function correctly identifies a party member who doesn't have a pet.
-- @function testMemberWithoutPet
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testMemberWithoutPet()
    local result = find_member_and_pet_in_party("Bob")
    luaunit.assertEquals(result, false)
end

--- Test for a name that doesn't exist in the party.
-- This test checks if the function correctly handles a name that doesn't exist in the party.
-- @function testNonExistentMember
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testNonExistentMember()
    local result = find_member_and_pet_in_party("NonExistent")
    luaunit.assertEquals(result, false)
end

--- Test for a non-string name.
-- This test checks if the function correctly handles a non-string name.
-- @function testNonStringName
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testNonStringName()
    luaunit.assertErrorMsgContains("name must be a string", find_member_and_pet_in_party, 123)
end

--- Test for a non-table party.
-- This test checks if the function correctly handles a non-table party.
-- @function testNonTableParty
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testNonTableParty()
    _G.party = "not a table"
    luaunit.assertErrorMsgContains("party must be a table", find_member_and_pet_in_party, "Alice")
end

--- Test for a non-table party member.
-- This test checks if the function correctly handles a non-table party member.
-- @function testNonTablePartyMember
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testNonTablePartyMember()
    _G.party = { "not a table" }
    luaunit.assertErrorMsgContains("party member must be a table", find_member_and_pet_in_party, "Alice")
end

--- Test for a non-table mob.
-- This test checks if the function correctly handles a non-table mob.
-- @function testNonTableMob
-- @within TestFindMemberAndPetInParty
function TestFindMemberAndPetInParty:testNonTableMob()
    _G.party = { { mob = "not a table" } }
    luaunit.assertErrorMsgContains("mob must be a table", find_member_and_pet_in_party, "Alice")
end

-- ===========================================================================================================
--                                         Test TableContains
-- ===========================================================================================================
--- @class TestTableContains
-- Test suite for the `table.contains` function in the SharedFunctions module.
TestTableContains = {}

--- Test for the `table.contains` function with a table that contains the element.
-- This test checks if the function correctly identifies that a table contains a given element.
-- @function testContainsElement
-- @within TestTableContains
function TestTableContains:testContainsElement()
    local tbl = { "Alice", "Bob", "Charlie" }
    local result = table.contains(tbl, "Alice")
    luaunit.assertEquals(result, true)
end

--- Test for the `table.contains` function with a table that doesn't contain the element.
-- This test checks if the function correctly identifies that a table doesn't contain a given element.
-- @function testDoesNotContainElement
-- @within TestTableContains
function TestTableContains:testDoesNotContainElement()
    local tbl = { "Alice", "Bob", "Charlie" }
    local result = table.contains(tbl, "NonExistent")
    luaunit.assertEquals(result, false)
end

--- Test for the `table.contains` function with a non-table first argument.
-- This test checks if the function correctly handles a non-table first argument.
-- @function testNonTableFirstArgument
-- @within TestTableContains
function TestTableContains:testNonTableFirstArgument()
    luaunit.assertErrorMsgContains("tbl must be a table", table.contains, "not a table", "Alice")
end

--- Test for the `table.contains` function with a nil element.
-- This test checks if the function correctly handles a nil element.
-- @function testNilElement
-- @within TestTableContains
function TestTableContains:testNilElement()
    local tbl = { "Alice", "Bob", "Charlie" }
    luaunit.assertErrorMsgContains("element cannot be nil", table.contains, tbl, nil)
end

-- ===========================================================================================================
--                                         Test ThActionCheck
-- ===========================================================================================================
--- @class TestThActionCheck
-- Test suite for the `th_action_check` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestThActionCheck = {}

--- Setup function for initializing the global `info` table.
-- This function sets up the global `info` table for the tests.
-- @function setUp
-- @within TestThActionCheck
function TestThActionCheck:setUp()
    _G.info = {
        default_ja_ids = { contains = function(_, val) return val == 30 end },
        default_u_ja_ids = { contains = function(_, val) return val == 30 end }
    }
end

--- Teardown function for cleaning up the global `info` table.
-- This function cleans up the global `info` table after the tests.
-- @function tearDown
-- @within TestThActionCheck
function TestThActionCheck:tearDown()
    _G.info = nil
end

--- Test for the `th_action_check` function with a category that always triggers Treasure Hunter.
-- This test checks if the function correctly identifies categories that always trigger Treasure Hunter.
-- @function testAlwaysTriggers
-- @within TestThActionCheck
function TestThActionCheck:testAlwaysTriggers()
    local result = th_action_check(2, 1)
    luaunit.assertEquals(result, true)
    result = th_action_check(4, 1)
    luaunit.assertEquals(result, true)
end

--- Test for the `th_action_check` function with a category that triggers Treasure Hunter for a specific param.
-- This test checks if the function correctly identifies categories that trigger Treasure Hunter for a specific param.
-- @function testSpecificParamTriggers
-- @within TestThActionCheck
function TestThActionCheck:testSpecificParamTriggers()
    local result = th_action_check(3, 30)
    luaunit.assertEquals(result, true)
    result = th_action_check(6, 30)
    luaunit.assertEquals(result, true)
    result = th_action_check(14, 30)
    luaunit.assertEquals(result, true)
end

--- Test for the `th_action_check` function with a category that does not trigger Treasure Hunter.
-- This test checks if the function correctly identifies categories that do not trigger Treasure Hunter.
-- @function testDoesNotTrigger
-- @within TestThActionCheck
function TestThActionCheck:testDoesNotTrigger()
    local result = th_action_check(3, 1)
    luaunit.assertEquals(result, false)
    result = th_action_check(6, 1)
    luaunit.assertEquals(result, false)
    result = th_action_check(14, 1)
    luaunit.assertEquals(result, false)
end

--- Test for the `th_action_check` function with a non-number category.
-- This test checks if the function correctly handles a non-number category.
-- @function testNonNumberCategory
-- @within TestThActionCheck
function TestThActionCheck:testNonNumberCategory()
    luaunit.assertErrorMsgContains("category must be a number", th_action_check, "not a number", 1)
end

--- Test for the `th_action_check` function with a non-number param.
-- This test checks if the function correctly handles a non-number param.
-- @function testNonNumberParam
-- @within TestThActionCheck
function TestThActionCheck:testNonNumberParam()
    luaunit.assertErrorMsgContains("param must be a number", th_action_check, 1, "not a number")
end

-- ===========================================================================================================
--                                         Test FormatRecastDuration
-- ===========================================================================================================
--- @class TestFormatRecastDuration
-- Test suite for the `formatRecastDuration` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestFormatRecastDuration = {}

--- Test for the `formatRecastDuration` function with a recast time of more than 60 seconds.
-- This test checks if the function correctly formats a recast time of more than 60 seconds.
-- @function testMoreThanMinute
-- @within TestFormatRecastDuration
function TestFormatRecastDuration:testMoreThanMinute()
    local result = formatRecastDuration(90)
    luaunit.assertEquals(result, '01:30 min')
end

--- Test for the `formatRecastDuration` function with a recast time of less than 60 seconds.
-- This test checks if the function correctly formats a recast time of less than 60 seconds.
-- @function testLessThanMinute
-- @within TestFormatRecastDuration
function TestFormatRecastDuration:testLessThanMinute()
    local result = formatRecastDuration(30)
    luaunit.assertEquals(result, '30.0 sec')
end

--- Test for the `formatRecastDuration` function with a recast time of exactly 60 seconds.
-- This test checks if the function correctly formats a recast time of exactly 60 seconds.
-- @function testExactlyMinute
-- @within TestFormatRecastDuration
function TestFormatRecastDuration:testExactlyMinute()
    local result = formatRecastDuration(60)
    luaunit.assertEquals(result, '01:00 min')
end

--- Test for the `formatRecastDuration` function with a nil recast time.
-- This test checks if the function correctly handles a nil recast time.
-- @function testNilRecast
-- @within TestFormatRecastDuration
function TestFormatRecastDuration:testNilRecast()
    local result = formatRecastDuration(nil)
    luaunit.assertNil(result)
end

--- Test for the `formatRecastDuration` function with a non-number recast time.
-- This test checks if the function correctly handles a non-number recast time.
-- @function testNonNumberRecast
-- @within TestFormatRecastDuration
function TestFormatRecastDuration:testNonNumberRecast()
    luaunit.assertErrorMsgContains("recast must be a number or nil", formatRecastDuration, "not a number")
end

-- ===========================================================================================================
--                                         Test AssertType
-- ===========================================================================================================
--- @class TestAssertType
-- Test suite for the `assertType` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestAssertType = {}

--- Test for the `assertType` function with a value of the expected type.
-- This test checks if the function correctly handles a value of the expected type.
-- @function testExpectedType
-- @within TestAssertType
function TestAssertType:testExpectedType()
    assertType(10, 'number', 'value') -- Should not raise an error
end

--- Test for the `assertType` function with a value of a different type.
-- This test checks if the function correctly handles a value of a different type.
-- @function testDifferentType
-- @within TestAssertType
function TestAssertType:testDifferentType()
    luaunit.assertErrorMsgContains("value must be a number or nil, got string", assertType, "not a number", 'number',
        'value')
end

--- Test for the `assertType` function with a nil value.
-- This test checks if the function correctly handles a nil value.
-- @function testNilValue
-- @within TestAssertType
function TestAssertType:testNilValue()
    assertType(nil, 'number', 'value') -- Should not raise an error
end

-- ===========================================================================================================
--                                         Test createColorCode
-- ===========================================================================================================
--- @class TestCreateColorCode
-- Test suite for the `createColorCode` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCreateColorCode = {}

--- Test for the `createColorCode` function with a valid color.
-- This test checks if the function correctly creates a color code for a valid color.
-- @function testValidColor
-- @within TestCreateColorCode
function TestCreateColorCode:testValidColor()
    local result = createColorCode(10)
    luaunit.assertEquals(result, string.char(0x1F, 10))
end

--- Test for the `createColorCode` function with a nil color.
-- This test checks if the function correctly handles a nil color.
-- @function testNilColor
-- @within TestCreateColorCode
function TestCreateColorCode:testNilColor()
    luaunit.assertErrorMsgContains("color must not be nil", createColorCode, nil)
end

--- Test for the `createColorCode` function with a non-number color.
-- This test checks if the function correctly handles a non-number color.
-- @function testNonNumberColor
-- @within TestCreateColorCode
function TestCreateColorCode:testNonNumberColor()
    luaunit.assertErrorMsgContains("color must be a number or nil, got string", assertType, "not a number", 'number',
        'color')
end

-- ===========================================================================================================
--                                         Test addFormattedMessage
-- ===========================================================================================================
--- @class TestAddFormattedMessage
-- Test suite for the `addFormattedMessage` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestAddFormattedMessage = {}

--- Test for the `addFormattedMessage` function with valid inputs.
-- This test checks if the function correctly formats and adds a message to the messageParts table.
-- @function testValidInputs
-- @within TestAddFormattedMessage
function TestAddFormattedMessage:testValidInputs()
    local messageParts = {}
    addFormattedMessage(messageParts, "Hello, %s!", "World")
    luaunit.assertEquals(messageParts, { "Hello, World!" })
end

--- Test for the `addFormattedMessage` function with nil messageParts.
-- This test checks if the function correctly handles a nil messageParts table.
-- @function testNilMessageParts
-- @within TestAddFormattedMessage
function TestAddFormattedMessage:testNilMessageParts()
    luaunit.assertErrorMsgContains("messageParts must not be nil", addFormattedMessage, nil, "format", "args")
end

--- Test for the `addFormattedMessage` function with nil format.
-- This test checks if the function correctly handles a nil format string.
-- @function testNilFormat
-- @within TestAddFormattedMessage
function TestAddFormattedMessage:testNilFormat()
    luaunit.assertErrorMsgContains("format must not be nil", addFormattedMessage, {}, nil, "args")
end

--- Test for the `addFormattedMessage` function with non-table messageParts.
-- This test checks if the function correctly handles a non-table messageParts.
-- @function testNonTableMessageParts
-- @within TestAddFormattedMessage
function TestAddFormattedMessage:testNonTableMessageParts()
    luaunit.assertErrorMsgContains("messageParts must be a table or nil, got string", assertType, "not a table", 'table',
        'messageParts')
end

--- Test for the `addFormattedMessage` function with non-string format.
-- This test checks if the function correctly handles a non-string format.
-- @function testNonStringFormat
-- @within TestAddFormattedMessage
function TestAddFormattedMessage:testNonStringFormat()
    luaunit.assertErrorMsgContains("format must be a string or nil, got number", assertType, 123, 'string', 'format')
end

-- ===========================================================================================================
--                                         Test CreateFormattedMessage
-- ===========================================================================================================
--- @class TestCreateFormattedMessage
-- Test suite for the `createFormattedMessage` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCreateFormattedMessage = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and replaces `createColorCode` with a mock function that returns an empty string.
-- @function setUp
-- @within TestCreateFormattedMessage
function TestCreateFormattedMessage:setUp()
    -- Save the original functions
    self.originalAddFormattedMessage = addFormattedMessage
    self.originalCreateColorCode = createColorCode

    -- Replace createColorCode with a mock function that returns an empty string
    createColorCode = function(color)
        return ""
    end
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions.
-- @function tearDown
-- @within TestCreateFormattedMessage
function TestCreateFormattedMessage:tearDown()
    -- Restore the original functions
    addFormattedMessage = self.originalAddFormattedMessage
    createColorCode = self.originalCreateColorCode
end

--- Test the `createFormattedMessage` function.
-- This function tests the `createFormattedMessage` function with different combinations of arguments.
-- @function testCreateFormattedMessage
-- @within TestCreateFormattedMessage
function TestCreateFormattedMessage:testCreateFormattedMessage()
    -- Test with all arguments
    local result = createFormattedMessage("Start", "Spell", 10, "End", true, true)
    luaunit.assertEquals(result,
        "Start [Spell] Recast: (10.0 sec)\n=================================================")

    -- Test without recastTime
    local result = createFormattedMessage("Start", "Spell", nil, "End", true, true)
    luaunit.assertEquals(result,
        "Start [Spell] Due to: [End]\n=================================================")

    -- Test without endMessage
    result = createFormattedMessage("Start", "Spell", 10, nil, true, true)
    luaunit.assertEquals(result,
        "Start [Spell] Recast: (10.0 sec)\n=================================================")

    -- Test without isLastMessage
    result = createFormattedMessage("Start", "Spell", 10, "End", false, true)
    luaunit.assertEquals(result,
        "Start [Spell] Recast: (10.0 sec)")

    -- Test without isColored
    result = createFormattedMessage("Start", "Spell", 10, "End", true, false)
    luaunit.assertEquals(result,
        "Start [Spell] Recast: (10.0 sec)\n=================================================")

    -- Test with recastTime and without endMessage
    result = createFormattedMessage("Start", "Spell", 10, nil, true, true)
    luaunit.assertEquals(result,
        "Start [Spell] Recast: (10.0 sec)\n=================================================")

    -- Test without recastTime and without endMessage
    result = createFormattedMessage("Start", "Spell", nil, nil, true, true)
    luaunit.assertEquals(result,
        "Start [Spell]\n=================================================")
end

-- ===========================================================================================================
--                                         Test CanCastSpell
-- ===========================================================================================================
--- @class TestCanCastSpell
-- Test suite for the `can_cast_spell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCanCastSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and replaces them with mock functions.
-- @function setUp
-- @within TestCanCastSpell
function TestCanCastSpell:setUp()
    -- Save the original functions
    self.originalIncapacitated = incapacitated
    self.originalWindower = windower

    -- Create a mock for windower
    windower = { ffxi = { get_spell_recasts = function() return {} end } }

    -- Replace incapacitated with a mock function that returns false
    incapacitated = function(spell, eventArgs) return false, nil end
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions.
-- @function tearDown
-- @within TestCanCastSpell
function TestCanCastSpell:tearDown()
    -- Restore the original functions
    incapacitated = self.originalIncapacitated
    windower = self.originalWindower
end

--- Test the `can_cast_spell` function with a valid spell.
-- This test checks if the function correctly handles a valid spell.
-- @function testValidSpell
-- @within TestCanCastSpell
function TestCanCastSpell:testValidSpell()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `can_cast_spell` function with a spell on cooldown.
-- This test checks if the function correctly handles a spell on cooldown.
-- @function testCooldown
-- @within TestCanCastSpell
function TestCanCastSpell:testCooldown()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    windower.ffxi.get_spell_recasts = function()
        return { [1] = 1 }
    end
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `can_cast_spell` function with an incapacitated character.
-- This test checks if the function correctly handles an incapacitated character.
-- @function testIncapacitated
-- @within TestCanCastSpell
function TestCanCastSpell:testIncapacitated()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    incapacitated = function(spell, eventArgs)
        return true, "Stun"
    end
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `can_cast_spell` function with a nil spell.
-- This test checks if the function correctly handles a nil spell.
-- @function testNilSpell
-- @within TestCanCastSpell
function TestCanCastSpell:testNilSpell()
    local eventArgs = {}
    local result = can_cast_spell(nil, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `can_cast_spell` function when spell.id is nil.
-- This test checks if the function correctly handles a spell with a nil id.
-- @function testSpellIdIsNil
-- @within TestCanCastSpell
function TestCanCastSpell:testSpellIdIsNil()
    local spell = { id = nil, action_type = "Magic" }
    local eventArgs = {}
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `can_cast_spell` function when spell.action_type is nil.
-- This test checks if the function correctly handles a spell with a nil action_type.
-- @function testActionTypeIsNil
-- @within TestCanCastSpell
function TestCanCastSpell:testActionTypeIsNil()
    local spell = { id = 1, action_type = nil }
    local eventArgs = {}
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `can_cast_spell` function when incapacitated function does not exist.
-- This test checks if the function correctly handles the absence of the incapacitated function.
-- @function testIncapacitatedDoesNotExist
-- @within TestCanCastSpell
function TestCanCastSpell:testIncapacitatedDoesNotExist()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    incapacitated = nil
    local success, message = pcall(function()
        return can_cast_spell(spell, eventArgs)
    end)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(message, "incapacitated function does not exist or is not a function")
end

--- Test the `can_cast_spell` function when windower.ffxi.get_spell_recasts returns nil.
-- This test checks if the function correctly handles a nil return value from windower.ffxi.get_spell_recasts.
-- @function testGetSpellRecastsReturnsNil
-- @within TestCanCastSpell
function TestCanCastSpell:testGetSpellRecastsReturnsNil()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    windower.ffxi.get_spell_recasts = function()
        return nil
    end
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `can_cast_spell` function when windower.ffxi.get_spell_recasts does not contain spell.id.
-- This test checks if the function correctly handles the case where windower.ffxi.get_spell_recasts does not contain the spell id.
-- @function testGetSpellRecastsDoesNotContainSpellId
-- @within TestCanCastSpell
function TestCanCastSpell:testGetSpellRecastsDoesNotContainSpellId()
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    windower.ffxi.get_spell_recasts = function()
        return { [2] = 0 }
    end
    local result = can_cast_spell(spell, eventArgs)
    luaunit.assertTrue(result)
end

-- ===========================================================================================================
--                                         Test TryCastSpell
-- ===========================================================================================================
--- @class TestTryCastSpell
-- Test suite for the `try_cast_spell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestTryCastSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and replaces them with mock functions.
-- @function setUp
-- @within TestTryCastSpell
function TestTryCastSpell:setUp()
    -- Save the original functions
    self.old_cancel_spell = cancel_spell
    self.old_can_cast_spell = can_cast_spell
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions.
-- @function tearDown
-- @within TestTryCastSpell
function TestTryCastSpell:tearDown()
    -- Restore the original functions
    cancel_spell = self.old_cancel_spell
    can_cast_spell = self.old_can_cast_spell
end

--- Test the `try_cast_spell` function when `cancel_spell` function does not exist.
-- This test checks if the function correctly handles the absence of the `cancel_spell` function.
-- @function testCancelSpellDoesNotExist
-- @within TestTryCastSpell
function TestTryCastSpell:testCancelSpellDoesNotExist()
    cancel_spell = nil
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    local success, message = pcall(function()
        return try_cast_spell(spell, eventArgs)
    end)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(message, "cancel_spell function does not exist or is not a function")
end

--- Test the `try_cast_spell` function when `can_cast_spell` returns false.
-- This test checks if the function correctly handles a false return value from `can_cast_spell`.
-- @function testCanCastSpellReturnsFalse
-- @within TestTryCastSpell
function TestTryCastSpell:testCanCastSpellReturnsFalse()
    cancel_spell = function() end
    can_cast_spell = function() return false end
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    local result = try_cast_spell(spell, eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `try_cast_spell` function when `can_cast_spell` returns true.
-- This test checks if the function correctly handles a true return value from `can_cast_spell`.
-- @function testCanCastSpellReturnsTrue
-- @within TestTryCastSpell
function TestTryCastSpell:testCanCastSpellReturnsTrue()
    cancel_spell = function() end
    can_cast_spell = function() return true end
    local spell = { id = 1, action_type = "Magic" }
    local eventArgs = {}
    local result = try_cast_spell(spell, eventArgs)
    luaunit.assertTrue(result)
end

-- ===========================================================================================================
--                                         Test HandleUnableToCast
-- ===========================================================================================================
--- @class TestHandleUnableToCast
-- Test suite for the `handle_unable_to_cast` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleUnableToCast = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and replaces them with mock functions.
-- @function setUp
-- @within TestHandleUnableToCast
function TestHandleUnableToCast:setUp()
    -- Save the original functions
    self.old_try_cast_spell = try_cast_spell
    self.old_cancel_spell = cancel_spell
    self.old_job_handle_equipping_gear = job_handle_equipping_gear
    self.old_add_to_chat = add_to_chat
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions.
-- @function tearDown
-- @within TestHandleUnableToCast
function TestHandleUnableToCast:tearDown()
    -- Restore the original functions
    try_cast_spell = self.old_try_cast_spell
    cancel_spell = self.old_cancel_spell
    job_handle_equipping_gear = self.old_job_handle_equipping_gear
    add_to_chat = self.old_add_to_chat
end

--- Test the `handle_unable_to_cast` function when `try_cast_spell` returns false.
-- This test checks if the function correctly handles a false return value from `try_cast_spell`.
-- @function testTryCastSpellReturnsFalse
-- @within TestHandleUnableToCast
function TestHandleUnableToCast:testTryCastSpellReturnsFalse()
    -- Mock functions
    try_cast_spell = function() return false end
    cancel_spell = function() end
    job_handle_equipping_gear = function() end
    add_to_chat = function() end

    -- Test data
    local spell = { id = 1, action_type = "Magic", name = "Fire" }
    local eventArgs = { handled = false }

    -- Call the function under test
    handle_unable_to_cast(spell, eventArgs)

    -- Assert that the event was handled
    luaunit.assertTrue(eventArgs.handled)
end

--- Test the `handle_unable_to_cast` function when `try_cast_spell` returns true.
-- This test checks if the function correctly handles a true return value from `try_cast_spell`.
-- @function testTryCastSpellReturnsTrue
-- @within TestHandleUnableToCast
function TestHandleUnableToCast:testTryCastSpellReturnsTrue()
    -- Mock function
    try_cast_spell = function() return true end

    -- Test data
    local spell = { id = 1, action_type = "Magic", name = "Fire" }
    local eventArgs = { handled = false }

    -- Call the function under test
    handle_unable_to_cast(spell, eventArgs)

    -- Assert that the event was not handled
    luaunit.assertFalse(eventArgs.handled)
end

-- ===========================================================================================================
--                                         Test CheckDisplayCooldown
-- ===========================================================================================================
--- @class TestCheckDisplayCooldown
-- Test suite for the `checkDisplayCooldown` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCheckDisplayCooldown = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and variables and replaces them with mock functions and variables.
-- @function setUp
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:setUp()
    -- Save the original functions and variables
    self.old_windower = windower
    self.old_cancel_spell = cancel_spell
    self.old_add_to_chat = add_to_chat
    self.old_createFormattedMessage = createFormattedMessage
    self.old_SharedFunctions_ignoredSpells = SharedFunctions.ignoredSpells

    -- Define dummy functions and variables to isolate the function under test
    windower = { ffxi = { get_spell_recasts = function() return {} end, get_ability_recasts = function() return {} end } }
    cancel_spell = function() end
    add_to_chat = function() end
    createFormattedMessage = function() end
    SharedFunctions.ignoredSpells = {}
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions and variables.
-- @function tearDown
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:tearDown()
    -- Restore the original functions and variables
    windower = self.old_windower
    cancel_spell = self.old_cancel_spell
    add_to_chat = self.old_add_to_chat
    createFormattedMessage = self.old_createFormattedMessage
    SharedFunctions.ignoredSpells = self.old_SharedFunctions_ignoredSpells
end

--- Test the `checkDisplayCooldown` function with a magic spell that is ready.
-- This test checks if the function correctly handles a magic spell that is ready to be cast.
-- @function testMagicSpellReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testMagicSpellReady()
    -- Arrange
    local spell = { name = "Fire", type = "Magic", action_type = "Magic", id = 1 }
    local eventArgs = { handled = false }

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, false)
end

--- Test the `checkDisplayCooldown` function with a magic spell that is not ready.
-- This test checks if the function correctly handles a magic spell that is not ready to be cast.
-- @function testMagicSpellNotReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testMagicSpellNotReady()
    -- Arrange
    local spell = { name = "Fire", type = "Magic", action_type = "Magic", id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_spell_recasts = function() return { [spell.id] = 60 } end -- Set the recast time to 60 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, true)
end

--- Test the `checkDisplayCooldown` function with an ability that is ready.
-- This test checks if the function correctly handles an ability that is ready to be used.
-- @function testAbilityReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testAbilityReady()
    -- Arrange
    local spell = { name = "Provoke", type = "Ability", action_type = "Ability", id = 1, recast_id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_ability_recasts = function() return { [spell.recast_id] = 0 } end -- Set the recast time to 0 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, false)
end

--- Test the `checkDisplayCooldown` function with an ability that is not ready.
-- This test checks if the function correctly handles an ability that is not ready to be used.
-- @function testAbilityNotReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testAbilityNotReady()
    -- Arrange
    local spell = { name = "Provoke", type = "Ability", action_type = "Ability", id = 1, recast_id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_ability_recasts = function() return { [spell.recast_id] = 60 } end -- Set the recast time to 60 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, true)
end

--- Test the `checkDisplayCooldown` function with a spell that is in the ignored spells list.
-- This test checks if the function correctly handles a spell that is in the ignored spells list.
-- @function testIgnoredSpell
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testIgnoredSpell()
    -- Arrange
    local spell = { name = "IgnoredSpell", type = "Magic", action_type = "Magic", id = 1 }
    local eventArgs = { handled = false }
    SharedFunctions.ignoredSpells = { IgnoredSpell = true } -- Add the spell to the ignored spells list

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, false)
end

--- Test the `checkDisplayCooldown` function with an 'Elemental Magic' spell that is not ready.
-- This test checks if the function correctly handles an 'Elemental Magic' spell that is not ready to be cast.
-- @function testElementalMagicSpellNotReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testElementalMagicSpellNotReady()
    -- Arrange
    local spell = { name = "Fire", type = "Elemental Magic", action_type = "Magic", id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_spell_recasts = function() return { [spell.id] = 60 } end -- Set the recast time to 60 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, true)
end

--- Test the `checkDisplayCooldown` function with a 'Scholar' spell that is not ready.
-- This test checks if the function correctly handles a 'Scholar' spell that is not ready to be cast.
-- @function testScholarSpellNotReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testScholarSpellNotReady()
    -- Arrange
    local spell = { name = "Fire", type = "Scholar", action_type = "Magic", id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_spell_recasts = function() return { [spell.id] = 60 } end -- Set the recast time to 60 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, false)
end

--- Test the `checkDisplayCooldown` function with a 'Weapon Skill' that is not ready.
-- This test checks if the function correctly handles a 'Weapon Skill' that is not ready to be used.
-- @function testWeaponSkillNotReady
-- @within TestCheckDisplayCooldown
function TestCheckDisplayCooldown:testWeaponSkillNotReady()
    -- Arrange
    local spell = { name = "Provoke", type = "Weapon Skill", action_type = "Ability", id = 1, recast_id = 1 }
    local eventArgs = { handled = false }
    windower.ffxi.get_ability_recasts = function() return { [spell.recast_id] = 60 } end -- Set the recast time to 60 seconds

    -- Act
    checkDisplayCooldown(spell, eventArgs)

    -- Assert
    luaunit.assertEquals(eventArgs.handled, true)
end

-- ===========================================================================================================
--                                         Test HandleSpell
-- ===========================================================================================================
--- @class TestHandleSpell
-- Test suite for the `handle_spell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and variables and replaces them with mock functions and variables.
-- @function setUp
-- @within TestHandleSpell
function TestHandleSpell:setUp()
    -- Save the original functions and variables
    self.old_try_cast_spell = try_cast_spell

    -- Define dummy functions and variables to isolate the function under test
    try_cast_spell = function(spell, eventArgs)
        return true
    end

    -- Set up test data
    self.spell = { name = "Fire", type = "Magic", id = 1 }
    self.eventArgs = { handled = false }
    self.auto_abilities = {
        Fire = function(spell, eventArgs)
            eventArgs.handled = true
        end
    }
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions and variables.
-- @function tearDown
-- @within TestHandleSpell
function TestHandleSpell:tearDown()
    -- Restore the original functions and variables
    try_cast_spell = self.old_try_cast_spell

    -- Clear test data
    self.spell = nil
    self.eventArgs = nil
    self.auto_abilities = nil
end

--- Test the `handle_spell` function with valid arguments.
-- This test checks if the function correctly handles a valid spell and auto abilities.
-- @function testHandleSpellValid
-- @within TestHandleSpell
function TestHandleSpell:testValid()
    -- Act
    handle_spell(self.spell, self.eventArgs, self.auto_abilities)

    -- Assert
    luaunit.assertEquals(self.eventArgs.handled, true)
end

--- Test the `handle_spell` function with an error in the auto_ability_function.
-- This test checks if the function correctly handles an error in the auto ability function.
-- @function testHandleSpellErrorInAutoAbilityFunction
-- @within TestHandleSpell
function TestHandleSpell:testErrorInAutoAbilityFunction()
    -- Arrange
    self.auto_abilities.Fire = function(spell, eventArgs)
        error("Test error")
    end

    -- Act
    local status, errMessage = pcall(handle_spell, self.spell, self.eventArgs, self.auto_abilities)

    -- Assert
    luaunit.assertFalse(status)
    luaunit.assertStrContains(errMessage, "Test error")
end

--- Test the `handle_spell` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testHandleSpellInvalidArguments
-- @within TestHandleSpell
function TestHandleSpell:testInvalidArguments()
    -- Act
    local status, err = pcall(handle_spell, "invalid", "invalid", "invalid")

    -- Assert
    luaunit.assertFalse(status)
    luaunit.assertStrContains(err, "Error: spell must be a table")
end

-- ===========================================================================================================
--                                         Test AutoAbility
-- ===========================================================================================================
--- @class TestAutoAbility
-- Test suite for the `auto_ability` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestAutoAbility = {}

--- Set up the test environment.
-- This function is called before each test.
-- It saves the original functions and variables and replaces them with mock functions and variables.
-- @function setUp
-- @within TestAutoAbility
function TestAutoAbility:setUp()
    -- Save the original functions and variables
    self.old_try_cast_spell = try_cast_spell
    self.old_windower = windower
    self.old_buffactive = buffactive
    self.old_cancel_spell = cancel_spell
    self.old_send_command = send_command
    self.old_handle_unable_to_cast = handle_unable_to_cast

    -- Define dummy functions and variables to isolate the function under test
    try_cast_spell = function(spell, eventArgs)
        return true
    end

    windower = { ffxi = { get_ability_recasts = function() return { [1] = 0 } end } }
    buffactive = { ["Ability"] = false }
    cancel_spell = function() end
    send_command = function() end

    -- Set up test data
    self.spell = { name = "Fire", type = "Magic", id = 1, target = { id = 123 } }
    self.eventArgs = { handled = false }
    self.abilityId = 1
    self.waitTime = "1.5"
    self.abilityName = "Ability"
end

--- Tear down the test environment.
-- This function is called after each test.
-- It restores the original functions and variables.
-- @function tearDown
-- @within TestAutoAbility
function TestAutoAbility:tearDown()
    -- Restore the original functions and variables
    try_cast_spell = self.old_try_cast_spell
    windower = self.old_windower
    buffactive = self.old_buffactive
    cancel_spell = self.old_cancel_spell
    send_command = self.old_send_command
    handle_unable_to_cast = self.old_handle_unable_to_cast

    -- Clear test data
    self.spell = nil
    self.eventArgs = nil
    self.abilityId = nil
    self.waitTime = nil
    self.abilityName = nil
end

--- Test the `auto_ability` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testValid
-- @within TestAutoAbility
function TestAutoAbility:testValid()
    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    -- As the function does not return anything, we can only test that it does not raise any errors.
    luaunit.assertTrue(true)
end

--- Test the `auto_ability` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testInvalidArguments
-- @within TestAutoAbility
function TestAutoAbility:testInvalidArguments()
    -- Act
    auto_ability("invalid", "invalid", "invalid", "invalid", "invalid")

    -- Assert
    -- As the function does not return anything, we can only test that it does not raise any errors.
    luaunit.assertTrue(true)
end

--- Test the `auto_ability` function when `try_cast_spell` returns false.
-- This test checks if the function correctly handles the case when `try_cast_spell` returns false.
-- @function testTryCastSpellReturnsFalse
-- @within TestAutoAbility
function TestAutoAbility:testTryCastSpellReturnsFalse()
    -- Arrange
    try_cast_spell = function(spell, eventArgs)
        return false
    end
    local handle_unable_to_cast_called = false
    handle_unable_to_cast = function(spell, eventArgs)
        handle_unable_to_cast_called = true
    end

    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    luaunit.assertTrue(handle_unable_to_cast_called)
end

--- Test the `auto_ability` function when `windower.ffxi.get_ability_recasts()` throws an error.
-- This test checks if the function correctly handles an error thrown by `windower.ffxi.get_ability_recasts()`.
-- @function testGetAbilityRecastsThrowsError
-- @within TestAutoAbility
function TestAutoAbility:testGetAbilityRecastsThrowsError()
    -- Arrange
    windower.ffxi.get_ability_recasts = function()
        error("Test error")
    end

    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    -- As the function does not return anything, we can only test that it does not raise any errors.
    luaunit.assertTrue(true)
end

--- Test the `auto_ability` function when `abilityCooldown` is greater than or equal to 1.
-- This test checks if the function correctly handles the case when `abilityCooldown` is greater than or equal to 1.
-- @function testAbilityCooldownGreaterThanOrEqualToOne
-- @within TestAutoAbility
function TestAutoAbility:testAbilityCooldownGreaterThanOrEqualToOne()
    -- Arrange
    windower.ffxi.get_ability_recasts = function()
        return { [self.abilityId] = 1 }
    end

    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    -- As the function does not return anything, we can only test that it does not raise any errors.
    luaunit.assertTrue(true)
end

--- Test the `auto_ability` function when `buffactive[abilityName]` is true.
-- This test checks if the function correctly handles the case when `buffactive[abilityName]` is true.
-- @function testBuffactiveAbilityNameIsTrue
-- @within TestAutoAbility
function TestAutoAbility:testBuffactiveAbilityNameIsTrue()
    -- Arrange
    buffactive[self.abilityName] = true

    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    -- As the function does not return anything, we can only test that it does not raise any errors.
    luaunit.assertTrue(true)
end

--- Test the `auto_ability` function when `try_cast_spell` returns true, `abilityCooldown` is less than 1, and `buffactive[abilityName]` is false.
-- This test checks if the function correctly handles the case when `try_cast_spell` returns true, `abilityCooldown` is less than 1, and `buffactive[abilityName]` is false.
-- @function testTryCastSpellReturnsTrueAbilityCooldownLessThanOneBuffactiveAbilityNameIsFalse
-- @within TestAutoAbility
function TestAutoAbility:testAbilityReadyAndBuffInactive()
    -- Arrange
    try_cast_spell = function(spell, eventArgs)
        return true
    end
    windower.ffxi.get_ability_recasts = function()
        return { [self.abilityId] = 0 }
    end
    buffactive[self.abilityName] = false
    local cancel_spell_called = false
    cancel_spell = function()
        cancel_spell_called = true
    end
    local send_command_called = false
    send_command = function()
        send_command_called = true
    end

    -- Act
    auto_ability(self.spell, self.eventArgs, self.abilityId, self.waitTime, self.abilityName)

    -- Assert
    luaunit.assertTrue(cancel_spell_called)
    luaunit.assertTrue(send_command_called)
end

-- ===========================================================================================================
--                                         Test HandleInterruptedSpell
-- ===========================================================================================================
--- @class TestHandleInterruptedSpell
-- Test suite for the `handle_interrupted_spell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleInterruptedSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:setUp()
    -- Save the original functions and globals
    self.old_job_handle_equipping_gear = job_handle_equipping_gear
    self.old_add_to_chat = add_to_chat

    -- Mock the job_handle_equipping_gear and add_to_chat functions
    job_handle_equipping_gear = function(playerStatus, eventArgs)
        return true
    end
    add_to_chat = function(code, message)
        return true
    end

    -- Set up test data
    self.spell = { name = "Fire" }
    self.eventArgs = { handled = false }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:tearDown()
    -- Restore the original functions and globals
    job_handle_equipping_gear = self.old_job_handle_equipping_gear
    add_to_chat = self.old_add_to_chat

    -- Clear test data
    self.spell = nil
    self.eventArgs = nil
end

--- Test the `handle_interrupted_spell` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testHandleInterruptedSpellValid
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:testHandleInterruptedSpellValid()
    local result = handleInterruptedSpell(self.spell, self.eventArgs)
    luaunit.assertTrue(result)
    luaunit.assertTrue(self.eventArgs.handled)
end

--- Test the `handle_interrupted_spell` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testHandleInterruptedSpellInvalidArguments
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:testHandleInterruptedSpellInvalidArguments()
    local result = handleInterruptedSpell({}, self.eventArgs)
    luaunit.assertFalse(result)
    luaunit.assertFalse(self.eventArgs.handled)
end

--- Test the `handle_interrupted_spell` function when `job_handle_equipping_gear` throws an error.
-- This test checks if the function correctly handles an error thrown by `job_handle_equipping_gear`.
-- @function testGearEquipError
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:testGearEquipError()
    job_handle_equipping_gear = function(playerStatus, eventArgs)
        error("Error")
    end
    local result = handleInterruptedSpell(self.spell, self.eventArgs)
    luaunit.assertFalse(result)
    luaunit.assertFalse(self.eventArgs.handled)
end

--- Test the `handle_interrupted_spell` function when `add_to_chat` throws an error.
-- This test checks if the function correctly handles an error thrown by `add_to_chat`.
-- @function testHandleInterruptedSpellAddToChatThrowsError
-- @within TestHandleInterruptedSpell
function TestHandleInterruptedSpell:testHandleInterruptedSpellAddToChatThrowsError()
    add_to_chat = function(code, message)
        error("Error")
    end
    local result = handleInterruptedSpell(self.spell, self.eventArgs)
    luaunit.assertFalse(result)
    luaunit.assertTrue(self.eventArgs.handled)
end

-- ===========================================================================================================
--                                         Test HandleCompletedSpell
-- ===========================================================================================================
--- @class TestHandleCompletedSpell
-- Test suite for the `handleCompletedSpell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleCompletedSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:setUp()
    -- Save the original functions and globals
    self.old_send_command = send_command
    self.old_state = state

    -- Mock the send_command function
    send_command = function(command)
        return true
    end

    -- Set up test data
    self.spell = { name = "Fire" }
    self.eventArgs = { handled = false }
    state = { Moving = { value = 'false' } }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:tearDown()
    -- Restore the original functions and globals
    send_command = self.old_send_command
    state = self.old_state

    -- Clear test data
    self.spell = nil
    self.eventArgs = nil
end

--- Test the `handleCompletedSpell` function with valid arguments and state.Moving.value is 'false'.
-- This test checks if the function correctly handles valid arguments and state.Moving.value is 'false'.
-- @function testHandleCompletedSpellValidStateMovingValueIsFalse
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:testMovingValueIsFalse()
    local result = handleCompletedSpell(self.spell, self.eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `handleCompletedSpell` function with valid arguments and state.Moving.value is 'true'.
-- This test checks if the function correctly handles valid arguments and state.Moving.value is 'true'.
-- @function testHandleCompletedSpellValidStateMovingValueIsTrue
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:testMovingValueIsTrue()
    state.Moving.value = 'true'
    local result = handleCompletedSpell(self.spell, self.eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `handleCompletedSpell` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testHandleCompletedSpellInvalidArguments
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:testInvalidArguments()
    local result = handleCompletedSpell({}, self.eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `handleCompletedSpell` function when send_command throws an error.
-- This test checks if the function correctly handles an error thrown by send_command.
-- @function testHandleCompletedSpellSendCommandThrowsError
-- @within TestHandleCompletedSpell
function TestHandleCompletedSpell:testSendCommandThrowsError()
    send_command = function(command)
        error("Error")
    end
    state.Moving.value = 'true'
    local result = handleCompletedSpell(self.spell, self.eventArgs)
    luaunit.assertFalse(result)
end

-- ===========================================================================================================
--                                         Test HandleSpellAftercast
-- ===========================================================================================================
--- @class TestHandleSpellAftercast
-- Test suite for the `handleSpellAftercast` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleSpellAftercast = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:setUp()
    -- Save the original functions
    self.old_handleInterruptedSpell = handleInterruptedSpell
    self.old_handleCompletedSpell = handleCompletedSpell

    -- Mock the handleInterruptedSpell and handleCompletedSpell functions
    handleInterruptedSpell = function(spell, eventArgs)
        return true
    end

    handleCompletedSpell = function(spell, eventArgs)
        return true
    end

    -- Set up test data
    self.spell = { name = "Fire", interrupted = false }
    self.eventArgs = { handled = false }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:tearDown()
    -- Restore the original functions
    handleInterruptedSpell = self.old_handleInterruptedSpell
    handleCompletedSpell = self.old_handleCompletedSpell

    -- Clear test data
    self.spell = nil
    self.eventArgs = nil
end

--- Test the `handleSpellAftercast` function with valid arguments and spell.interrupted is false.
-- This test checks if the function correctly handles valid arguments and spell.interrupted is false.
-- @function testAftercastWithNonInterruptedSpell
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:testAftercastWithNonInterruptedSpell()
    local result = handleSpellAftercast(self.spell, self.eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `handleSpellAftercast` function with valid arguments and spell.interrupted is true.
-- This test checks if the function correctly handles valid arguments and spell.interrupted is true.
-- @function testAftercastWithInterruptedSpell
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:testAftercastWithInterruptedSpell()
    self.spell.interrupted = true
    local result = handleSpellAftercast(self.spell, self.eventArgs)
    luaunit.assertTrue(result)
end

--- Test the `handleSpellAftercast` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testAftercastWithInvalidArguments
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:testAftercastWithInvalidArguments()
    local result = handleSpellAftercast({}, self.eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `handleSpellAftercast` function when `handleInterruptedSpell` throws an error.
-- This test checks if the function correctly handles an error thrown by `handleInterruptedSpell`.
-- @function testAftercastWhenInterruptedSpellHandlerThrowsError
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:testAftercastWhenInterruptedSpellHandlerThrowsError()
    handleInterruptedSpell = function(spell, eventArgs)
        error("Error")
    end
    self.spell.interrupted = true
    local result = handleSpellAftercast(self.spell, self.eventArgs)
    luaunit.assertFalse(result)
end

--- Test the `handleSpellAftercast` function when `handleCompletedSpell` throws an error.
-- This test checks if the function correctly handles an error thrown by `handleCompletedSpell`.
-- @function testAftercastWhenCompletedSpellHandlerThrowsError
-- @within TestHandleSpellAftercast
function TestHandleSpellAftercast:testAftercastWhenCompletedSpellHandlerThrowsError()
    handleCompletedSpell = function(spell, eventArgs)
        error("Error")
    end
    self.spell.interrupted = false
    local result = handleSpellAftercast(self.spell, self.eventArgs)
    luaunit.assertFalse(result)
end

-- ===========================================================================================================
--                                         Test ApplySpellSequenceToTarget
-- ===========================================================================================================
--- @class TestApplySpellSequenceToTarget
-- Test suite for the `applySpellSequenceToTarget` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestApplySpellSequenceToTarget = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:setUp()
    -- Save the original functions
    self.old_get_current_target_id_and_name = get_current_target_id_and_name
    self.old_send_command = send_command

    -- Mock the get_current_target_id_and_name and send_command functions
    get_current_target_id_and_name = function()
        return true, 1, "target"
    end

    send_command = function(command)
        return true
    end

    -- Set up test data
    self.spells = { { name = "Fire", delay = 0 }, { name = "Phalanx2", delay = 0 } }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:tearDown()
    -- Restore the original functions
    get_current_target_id_and_name = self.old_get_current_target_id_and_name
    send_command = self.old_send_command

    -- Clear test data
    self.spells = nil
end

--- Test the `applySpellSequenceToTarget` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testApplySpellSequenceWithValidArguments
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:testWithValidArguments()
    local result = applySpellSequenceToTarget(self.spells)
    luaunit.assertTrue(result)
end

--- Test the `applySpellSequenceToTarget` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testApplySpellSequenceWithInvalidArguments
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:testWithInvalidArguments()
    local result = applySpellSequenceToTarget({})
    luaunit.assertFalse(result)
end

--- Test the `applySpellSequenceToTarget` function when `get_current_target_id_and_name` throws an error.
-- This test checks if the function correctly handles an error thrown by `get_current_target_id_and_name`.
-- @function testApplySpellSequenceWhenGetCurrentTargetThrowsError
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:testWhenGetCurrentTargetThrowsError()
    get_current_target_id_and_name = function()
        error("Error")
    end
    local result = applySpellSequenceToTarget(self.spells)
    luaunit.assertFalse(result)
end

--- Test the `applySpellSequenceToTarget` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testApplySpellSequenceWhenSendCommandThrowsError
-- @within TestApplySpellSequenceToTarget
function TestApplySpellSequenceToTarget:testWhenSendCommandThrowsError()
    send_command = function(command)
        error("Error")
    end
    local result = applySpellSequenceToTarget(self.spells)
    luaunit.assertFalse(result)
end

-- ===========================================================================================================
--                                         Test BufferRoleForAltRdm
-- ===========================================================================================================
--- @class TestBufferRoleForAltRdm
-- Test suite for the `bufferRoleForAltRdm` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestBufferRoleForAltRdm = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:setUp()
    -- Save the original functions
    self.old_get_current_target_id_and_name = get_current_target_id_and_name
    self.old_applySpellSequenceToTarget = applySpellSequenceToTarget

    -- Mock the get_current_target_id_and_name and applySpellSequenceToTarget functions
    get_current_target_id_and_name = function()
        return true, 1, "target"
    end

    applySpellSequenceToTarget = function(spells)
        return true
    end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:tearDown()
    -- Restore the original functions
    get_current_target_id_and_name = self.old_get_current_target_id_and_name
    applySpellSequenceToTarget = self.old_applySpellSequenceToTarget
end

--- Test the `bufferRoleForAltRdm` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testBufferRoleForAltRdmValidArguments
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:testBufferRoleForAltRdmValidArguments()
    local result = bufferRoleForAltRdm('bufftank')
    luaunit.assertTrue(result)
end

--- Test the `bufferRoleForAltRdm` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testBufferRoleForAltRdmInvalidArguments
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:testInvalidArguments()
    local result = bufferRoleForAltRdm({})
    luaunit.assertFalse(result)
end

--- Test the `bufferRoleForAltRdm` function when `get_current_target_id_and_name` throws an error.
-- This test checks if the function correctly handles an error thrown by `get_current_target_id_and_name`.
-- @function testBufferRoleForAltRdmGetCurrentTargetIdAndNameThrowsError
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:testGetCurrentTargetIdAndNameThrowsError()
    get_current_target_id_and_name = function()
        error("Error")
    end
    local result = bufferRoleForAltRdm('bufftank')
    luaunit.assertFalse(result)
end

--- Test the `bufferRoleForAltRdm` function when `applySpellSequenceToTarget` throws an error.
-- This test checks if the function correctly handles an error thrown by `applySpellSequenceToTarget`.
-- @function testBufferRoleForAltRdmApplySpellSequenceToTargetThrowsError
-- @within TestBufferRoleForAltRdm
function TestBufferRoleForAltRdm:testApplySpellSequenceToTargetThrowsError()
    applySpellSequenceToTarget = function(spells)
        error("Error")
    end
    local result = bufferRoleForAltRdm('bufftank')
    luaunit.assertFalse(result)
end

-- ===========================================================================================================
--                                         Test BubbleBuffForAltGeo
-- ===========================================================================================================
--- @class TestBubbleBuffForAltGeo
-- Test suite for the `bubbleBuffForAltGeo` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestBubbleBuffForAltGeo = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:setUp()
    -- Save the original functions
    self.old_get_current_target_id_and_name = get_current_target_id_and_name
    self.old_send_command = send_command

    -- Mock the get_current_target_id_and_name and send_command functions
    get_current_target_id_and_name = function()
        return 1, "target"
    end

    send_command = function(command)
        return true
    end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:tearDown()
    -- Restore the original functions
    get_current_target_id_and_name = self.old_get_current_target_id_and_name
    send_command = self.old_send_command
end

--- Test the `bubbleBuffForAltGeo` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testBubbleBuffForAltGeoValidArguments
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:testBubbleBuffForAltGeoValidArguments()
    local result = pcall(bubbleBuffForAltGeo, 'Geo-Regen', true, false)
    luaunit.assertTrue(result)
end

--- Test the `bubbleBuffForAltGeo` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testBubbleBuffForAltGeoInvalidArguments
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:testInvalidArguments()
    local result = pcall(bubbleBuffForAltGeo, {}, true, false)
    luaunit.assertFalse(result)
end

--- Test the `bubbleBuffForAltGeo` function when `get_current_target_id_and_name` returns nil.
-- This test checks if the function correctly handles a nil return value from `get_current_target_id_and_name`.
-- @function testBubbleBuffForAltGeoGetCurrentTargetIdAndNameReturnsNil
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:testGetCurrentTargetIdAndNameReturnsNil()
    get_current_target_id_and_name = function()
        return nil, nil
    end
    local result = pcall(bubbleBuffForAltGeo, 'Geo-Regen', true, false)
    luaunit.assertTrue(result)
end

--- Test the `bubbleBuffForAltGeo` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testBubbleBuffForAltGeoSendCommandThrowsError
-- @within TestBubbleBuffForAltGeo
function TestBubbleBuffForAltGeo:testSendCommandThrowsError()
    send_command = function(command)
        error("Error")
    end
    local result = pcall(bubbleBuffForAltGeo, 'Geo-Regen', true, false)
    luaunit.assertFalse(result)
end

-- ===========================================================================================================
--                                         Test HandleAltNuke
-- ===========================================================================================================
--- @class TestHandleAltNuke
-- Test suite for the `handle_altNuke` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestHandleAltNuke = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleAltNuke
function TestHandleAltNuke:setUp()
    -- Save the original functions and objects
    self.old_get_current_target_id_and_name = get_current_target_id_and_name
    self.old_send_command = send_command
    self.old_windower = windower
    self.old_player_status = player and player.status or nil

    -- Mock the get_current_target_id_and_name and send_command functions
    get_current_target_id_and_name = function()
        return 1, "target"
    end

    send_command = function(command)
        return true
    end

    -- Mock the windower object
    windower = windower or {}
    windower.ffxi = windower.ffxi or {}
    windower.ffxi.get_mob_by_target = function(target)
        return { id = 1 }
    end

    -- Mock the player object
    player = player or {}
    player.status = 'Engaged'
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleAltNuke
function TestHandleAltNuke:tearDown()
    -- Restore the original functions and objects
    get_current_target_id_and_name = self.old_get_current_target_id_and_name
    send_command = self.old_send_command
    windower = self.old_windower
    player.status = self.old_player_status
end

--- Test the `handle_altNuke` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testHandleAltNukeInvalidArguments
-- @within TestHandleAltNuke
function TestHandleAltNuke:testHandleAltNukeInvalidArguments()
    local success, err = pcall(handle_altNuke, {}, 'Tier', true)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Invalid input parameters')
end

--- Test the `handle_altNuke` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testHandleAltNukeSendCommandThrowsError
-- @within TestHandleAltNuke
function TestHandleAltNuke:testSendCommandThrowsError()
    send_command = function(command)
        error("Error")
    end
    local success, err = pcall(handle_altNuke, 'Spell', 'Tier', true)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Failed to send command')
end

--- Test the `handle_altNuke` function with nil arguments.
-- This test checks if the function correctly handles nil arguments.
-- @function testHandleAltNukeWithNilArguments
-- @within TestHandleAltNuke
function TestHandleAltNuke:testWithNilArguments()
    local success, err = pcall(handle_altNuke, nil, nil, nil)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Invalid input parameters')
end

--- Test the `handle_altNuke` function with empty string arguments.
-- This test checks if the function correctly handles empty string arguments.
-- @function testHandleAltNukeWithEmptyStringArguments
-- @within TestHandleAltNuke
function TestHandleAltNuke:testWithEmptyStringArguments()
    local success, err = pcall(handle_altNuke, '', '', true)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Invalid arguments: altSpell and altTier must not be empty strings')
end

-- ===========================================================================================================
--                                         Test CastElementalSpells
-- ===========================================================================================================
--- @class TestCastElementalSpells
-- Test suite for the `castElementalSpells` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCastElementalSpells = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestCastElementalSpells
function TestCastElementalSpells:setUp()
    -- Save the original send_command function
    self.old_send_command = send_command
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestCastElementalSpells
function TestCastElementalSpells:tearDown()
    -- Restore the original send_command function
    send_command = self.old_send_command
end

--- Test the `castElementalSpells` function with valid arguments.
-- This test checks if the function correctly handles valid arguments.
-- @function testCastElementalSpellsWithValidArguments
-- @within TestCastElementalSpells
function TestCastElementalSpells:testWithValidArguments()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ma "SpellTier" <stnpc>')
    end
    castElementalSpells('Spell', 'Tier')
end

--- Test the `castElementalSpells` function with nil for the tier parameter.
-- This test checks if the function correctly handles a nil tier parameter.
-- @function testCastElementalSpellsWithNilTier
-- @within TestCastElementalSpells
function TestCastElementalSpells:testWithNilTier()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ma "Spell" <stnpc>')
    end
    castElementalSpells('Spell', nil)
end

--- Test the `castElementalSpells` function with nil for the mainSpell parameter.
-- This test checks if the function correctly handles a nil mainSpell parameter.
-- @function testCastElementalSpellsWithInvalidMainSpell
-- @within TestCastElementalSpells
function TestCastElementalSpells:testWithInvalidMainSpell()
    luaunit.assertErrorMsgContains('Invalid mainSpell parameter', castElementalSpells, nil, 'Tier')
end

--- Test the `castElementalSpells` function with a non-string argument for the tier parameter.
-- This test checks if the function correctly handles a non-string tier parameter.
-- @function testCastElementalSpellsWithInvalidTier
-- @within TestCastElementalSpells
function TestCastElementalSpells:testWithInvalidTier()
    luaunit.assertErrorMsgContains('Invalid tier parameter', castElementalSpells, 'Spell', 123)
end

--- Test the `castElementalSpells` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testCastElementalSpellsWithSendCommandError
-- @within TestCastElementalSpells
function TestCastElementalSpells:testWithSendCommandError()
    send_command = function(command)
        error('Command error')
    end
    local success, err = pcall(castElementalSpells, 'Spell', 'Tier')
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Failed to send command:')
    luaunit.assertStrContains(err, 'Command error')
end

-- ===========================================================================================================
--                                         Test CastArtsOrAddendum
-- ===========================================================================================================
--- @class TestCastArtsOrAddendum
-- Test suite for the `castArtsOrAddendum` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCastArtsOrAddendum = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:setUp()
    -- Save the original send_command and buffactive functions
    self.old_send_command = send_command
    self.old_buffactive = buffactive
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:tearDown()
    -- Restore the original send_command and buffactive functions
    send_command = self.old_send_command
    buffactive = self.old_buffactive
end

--- Test the `castArtsOrAddendum` function with valid arguments and arts not active.
-- This test checks if the function correctly handles valid arguments and arts not active.
-- @function testCastArtsOrAddendumWithValidArgumentsAndArtsNotActive
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:testWithValidArgumentsAndArtsNotActive()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ja "Arts" <me>')
    end
    buffactive = {}
    castArtsOrAddendum('Arts', 'Addendum')
end

--- Test the `castArtsOrAddendum` function with valid arguments and arts active.
-- This test checks if the function correctly handles valid arguments and arts active.
-- @function testCastArtsOrAddendumWithValidArgumentsAndArtsActive
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:testWithValidArgumentsAndArtsActive()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ja "Addendum" <me>')
    end
    buffactive = { ['Arts'] = true }
    castArtsOrAddendum('Arts', 'Addendum')
end

--- Test the `castArtsOrAddendum` function with nil for the arts parameter.
-- This test checks if the function correctly handles a nil arts parameter.
-- @function testCastArtsOrAddendumWithInvalidArts
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:testWithInvalidArts()
    luaunit.assertErrorMsgContains('Invalid arts parameter', castArtsOrAddendum, nil, 'Addendum')
end

--- Test the `castArtsOrAddendum` function with nil for the addendum parameter.
-- This test checks if the function correctly handles a nil addendum parameter.
-- @function testCastArtsOrAddendumWithInvalidAddendum
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:testWithInvalidAddendum()
    luaunit.assertErrorMsgContains('Invalid addendum parameter', castArtsOrAddendum, 'Arts', nil)
end

--- Test the `castArtsOrAddendum` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testCastArtsOrAddendumWithSendCommandError
-- @within TestCastArtsOrAddendum
function TestCastArtsOrAddendum:testWithSendCommandError()
    send_command = function(command)
        error('Command error')
    end
    buffactive = {}
    local success, err = pcall(castArtsOrAddendum, 'Arts', 'Addendum')
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, 'Failed to send command:')
    luaunit.assertStrContains(err, 'Command error')
end

-- ===========================================================================================================
--                                         Test CastSchSpell
-- ===========================================================================================================
--- @class TestCastSchSpell
-- Test suite for the `castSchSpell` function in the SharedFunctions module.
-- @within TestSharedFunctions
TestCastSchSpell = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestCastSchSpell
function TestCastSchSpell:setUp()
    -- Save the original global functions and variables
    self.old_send_command = send_command
    self.old_buffactive = buffactive
    self.old_stratagems_available = stratagems_available
    self.old_add_to_chat = add_to_chat
    self.old_get_current_target_id_and_name = get_current_target_id_and_name

    -- Mock global functions
    send_command = function() end
    add_to_chat = function() end
    get_current_target_id_and_name = function() return 'targetid', 'targetname' end

    -- Mock windower
    windower = {
        ffxi = {
            get_player = function() return { id = 'playerid', name = 'playername' } end,
        },
    }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestCastSchSpell
function TestCastSchSpell:tearDown()
    -- Restore the original global functions and variables
    send_command = self.old_send_command
    buffactive = self.old_buffactive
    stratagems_available = self.old_stratagems_available
    add_to_chat = self.old_add_to_chat
    get_current_target_id_and_name = self.old_get_current_target_id_and_name

    -- Restore windower
    windower = nil
end

--- Test the `castSchSpell` function with valid arguments and Addendum active.
-- This test checks if the function correctly handles valid arguments and Addendum active.
-- @function testCastSchSpellWithValidArgumentsAndAddendumActive
-- @within TestCastSchSpell
function TestCastSchSpell:testWithValidArgumentsAndAddendumActive()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ma "Spell" targetid')
    end
    add_to_chat = function() end
    buffactive = { ['Addendum'] = true }
    castSchSpell('Spell', 'Arts', 'Addendum')
end

--- Test the `castSchSpell` function with valid arguments, Arts active, and stratagems available.
-- This test checks if the function correctly handles valid arguments, Arts active, and stratagems available.
-- @function testCastSchSpellWithValidArgumentsAndArtsActiveAndStratagemsAvailable
-- @within TestCastSchSpell
function TestCastSchSpell:testWithValidArgumentsAndArtsActiveAndStratagemsAvailable()
    send_command = function(command)
        luaunit.assertEquals(command, 'input /ja "Addendum" <me>; wait 2; input /ma "Spell" targetid')
    end
    buffactive = { ['Arts'] = true }
    stratagems_available = function() return true end
    castSchSpell('Spell', 'Arts', 'Addendum')
end

--- Test the `castSchSpell` function with valid arguments and stratagems available.
-- This test checks if the function correctly handles valid arguments and stratagems available.
-- @function testCastSchSpellWithValidArgumentsAndStratagemsAvailable
-- @within TestCastSchSpell
function TestCastSchSpell:testWithValidArgumentsAndStratagemsAvailable()
    send_command = function(command)
        luaunit.assertEquals(command,
            'input /ja "Arts" <me>; wait 2; input /ja "Addendum" <me>; wait 2.1; input /ma "Spell" targetid')
    end
    buffactive = {}
    stratagems_available = function() return true end
    castSchSpell('Spell', 'Arts', 'Addendum')
end

--- Test the `castSchSpell` function with invalid arguments.
-- This test checks if the function correctly handles invalid arguments.
-- @function testCastSchSpellWithInvalidArguments
-- @within TestCastSchSpell
function TestCastSchSpell:testWithInvalidArguments()
    luaunit.assertErrorMsgContains("Invalid parameters. 'spell' must be a string.", castSchSpell, 123, 'Arts', 'Addendum')
    luaunit.assertErrorMsgContains("Invalid parameters. 'arts' must be a string.", castSchSpell, 'Spell', 123, 'Addendum')
    luaunit.assertErrorMsgContains("Invalid parameters. 'addendum' must be a string.", castSchSpell, 'Spell', 'Arts', 123)
end

--- Test the `castSchSpell` function when `send_command` throws an error.
-- This test checks if the function correctly handles an error thrown by `send_command`.
-- @function testCastSchSpellWithSendCommandError
-- @within TestCastSchSpell
function TestCastSchSpell:testWithSendCommandError()
    local commandError = false
    send_command = function(command)
        commandError = true
        error('Command error')
    end
    buffactive = {}
    stratagems_available = function() return true end
    pcall(castSchSpell, 'Spell', 'Arts', 'Addendum')
    luaunit.assertTrue(commandError)
end

-- ===========================================================================================================
--                                         Test HandleBlmCommands
-- ===========================================================================================================
--- @class TestHandleBlmCommands
-- Test suite for the `handle_blm_commands` function.
TestHandleBlmCommands = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleBlmCommands
function TestHandleBlmCommands:setUp()
    -- Save the original global functions and variables
    self.old_BuffSelf = BuffSelf
    self.old_castElementalSpells = castElementalSpells
    self.old_state = state

    -- Mock global functions and variables
    self.buffSelfArgs = nil
    BuffSelf = function()
        self.buffSelfArgs = {}
    end

    self.castElementalSpellsArgs = nil
    castElementalSpells = function(...)
        self.castElementalSpellsArgs = { ... }
    end

    state = {
        MainLightSpell = { value = 'mainlight' },
        SubLightSpell = { value = 'sublight' },
        MainDarkSpell = { value = 'maindark' },
        SubDarkSpell = { value = 'subdark' },
        Aja = { value = 'aja' },
        TierSpell = { value = 'tier' },
    }
end

--- Test the `handle_blm_commands` function with valid commands.
-- This test checks if the function correctly handles valid commands.
-- @function testHandleBlmCommandsWithValidCommands
-- @within TestHandleBlmCommands
function TestHandleBlmCommands:testWithValidCommands()
    local commands = { 'buffself', 'mainlight', 'sublight', 'maindark', 'subdark', 'aja' }
    local expectedCastElementalSpellsArgs = {
        mainlight = { 'mainlight', 'tier' },
        sublight = { 'sublight', 'tier' },
        maindark = { 'maindark', 'tier' },
        subdark = { 'subdark', 'tier' },
        aja = { 'aja' },
    }

    for _, cmd in ipairs(commands) do
        handle_blm_commands({ cmd })

        if cmd == 'buffself' then
            luaunit.assertNotNil(self.buffSelfArgs)
        else
            luaunit.assertEquals(self.castElementalSpellsArgs, expectedCastElementalSpellsArgs[cmd])
        end
    end
end

--- Test the `handle_blm_commands` function with invalid commands.
-- This test checks if the function correctly handles invalid commands.
-- @function testHandleBlmCommandsWithInvalidCommands
-- @within TestHandleBlmCommands
function TestHandleBlmCommands:testWithInvalidCommands()
    local invalidCommands = { 123, {}, true }

    for _, cmd in ipairs(invalidCommands) do
        local success, err = pcall(handle_blm_commands, { cmd })
        luaunit.assertFalse(success)
        luaunit.assertStrContains(err, "Command must be a string.")
    end
end

-- ===========================================================================================================
--                                         Test HandleSchSubjobCommands
-- ===========================================================================================================
--- @class TestHandleSchSubjobCommands
-- Test suite for the `handle_sch_subjob_commands` function.
-- @within TestSharedFunctions
TestHandleSchSubjobCommands = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:setUp()
    -- Save the original global functions and variables
    self.old_send_command = send_command
    self.old_buffactive = buffactive
    self.old_windower = windower
    self.old_state = state             -- Save the original state
    self.old_add_to_chat = add_to_chat -- Save the original add_to_chat
    self.old_S = S                     -- Save the original S

    -- Mock global functions and variables
    send_command = function(cmd) end
    buffactive = { ['Klimaform'] = false }
    windower = {
        ffxi = {
            get_spell_recasts = function() return { [287] = 0 } end,
            get_ability_recasts = function()
                return { [15] = 0 }
            end
        }
    }

    -- Mock the add_to_chat and S functions
    add_to_chat = function() end
    S = function() return { contains = function() return false end } end

    -- Mock the state Storm
    state = {
        Storm = { value = 'Firestorm' }, -- Add necessary values for the commands
        -- Add other necessary values here
    }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:tearDown()
    -- Restore the original global functions and variables
    send_command = self.old_send_command
    buffactive = self.old_buffactive
    windower = self.old_windower
    state = self.old_state             -- Restore the original state
    add_to_chat = self.old_add_to_chat -- Restore the original add_to_chat
    S = self.old_S                     -- Restore the original S
end

--- Test the `handle_sch_subjob_commands` function with valid commands.
-- @function testWithValidCommands
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:testWithValidCommands()
    local validCommands = { 'storm', 'lightarts', 'darkarts', 'blindna', 'poisona', 'viruna', 'stona', 'silena',
        'paralyna', 'cursna', 'erase', 'dispel', 'sneak', 'invi' }

    for _, cmd in ipairs(validCommands) do
        local success, err = pcall(handle_sch_subjob_commands, { cmd })
        if not success then
            print("Error with command " .. cmd .. ": " .. err)
        end
        luaunit.assertTrue(success)
    end
end

--- Test the `handle_sch_subjob_commands` function with invalid commands.
-- @function testWithInvalidCommands
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:testWithInvalidCommands()
    local invalidCommands = { 123, {}, true }

    for _, cmd in ipairs(invalidCommands) do
        local success, err = pcall(handle_sch_subjob_commands, { cmd })
        luaunit.assertFalse(success)
        luaunit.assertStrContains(err, "Command must be a string.")
    end
end

--- Test the `handle_sch_subjob_commands` function with specific commands.
-- @function testWithSpecificCommands
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:testWithSpecificCommands()
    local commands = { 'storm', 'lightarts', 'darkarts', 'blindna', 'poisona', 'viruna', 'stona', 'silena',
        'paralyna', 'cursna', 'erase', 'dispel', 'sneak', 'invi' }
    local expectedCommands = {
        'input /ma "Klimaform" ; wait 4; input /ma "Firestorm" ',
        'input /ja "Light Arts" <me>',
        'input /ja "Dark Arts" <me>',
        -- ...
    }

    -- Create a table to store the sent commands
    local sentCommands = {}

    -- Save the original send_command function
    local old_send_command = send_command

    -- Create a stub for send_command
    send_command = function(cmd)
        -- Add the command to the sentCommands table
        table.insert(sentCommands, cmd)
    end

    -- Call handle_sch_subjob_commands with each command
    for i, cmd in ipairs(commands) do
        handle_sch_subjob_commands({ cmd })
    end

    -- Check that the sent commands match the expected commands
    luaunit.assertEquals(sentCommands, expectedCommands)

    -- Restore the original send_command function
    send_command = old_send_command
end

--- Test the `handle_sch_subjob_commands` function with buffactive['Klimaform'] = true.
-- @function testWithBuffactiveKlimaformTrue
-- @within TestHandleSchSubjobCommands
function TestHandleSchSubjobCommands:testWithBuffactiveKlimaformTrue()
    -- Save the original buffactive table
    local old_buffactive = buffactive

    -- Set buffactive['Klimaform'] to true
    buffactive['Klimaform'] = true

    -- Call handle_sch_subjob_commands and check that it behaves correctly
    -- ...

    -- Restore the original buffactive table
    buffactive = old_buffactive
end

-- ===========================================================================================================
--                                         Test HandleWarCommands
-- ===========================================================================================================
--- @class TestHandleWarCommands
-- Test suite for the `handle_war_commands` function.
-- @within TestSharedFunctions
TestHandleWarCommands = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleWarCommands
function TestHandleWarCommands:setUp()
    -- Save the original global functions and variables
    self.old_send_command = send_command
    self.old_buffactive = buffactive
    self.old_buffSelf = buffSelf
    self.old_ThirdEye = ThirdEye
    self.old_jump = jump
    self.old_state = state

    -- Mock global functions and variables
    send_command = function(cmd) end
    buffactive = { ['Defender'] = false, ['Berserk'] = false }
    buffSelf = function(buff) end
    ThirdEye = function() end
    jump = function() end
    state = { HybridMode = { value = 'Normal' } }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleWarCommands
function TestHandleWarCommands:tearDown()
    -- Restore the original global functions and variables
    send_command = self.old_send_command
    buffactive = self.old_buffactive
    buffSelf = self.old_buffSelf
    ThirdEye = self.old_ThirdEye
    jump = self.old_jump
    state = self.old_state
end

--- Test the `handle_war_commands` function with valid commands.
-- @function testWithValidCommands
-- @within TestHandleWarCommands
function TestHandleWarCommands:testWithValidCommands()
    luaunit.assertTrue(handle_war_commands({ 'berserk' }))
    luaunit.assertTrue(handle_war_commands({ 'defender' }))
    luaunit.assertTrue(handle_war_commands({ 'thirdeye' }))
    luaunit.assertTrue(handle_war_commands({ 'jump' }))
end

--- Test the `handle_war_commands` function with invalid commands.
-- @function testWithInvalidCommands
-- @within TestHandleWarCommands
function TestHandleWarCommands:testWithInvalidCommands()
    luaunit.assertFalse(handle_war_commands({ 'invalid' }))
    luaunit.assertFalse(handle_war_commands({ 123 }))
    luaunit.assertFalse(handle_war_commands({}))
    luaunit.assertFalse(handle_war_commands(nil))
end

-- ===========================================================================================================
--                                         Test HandleThfCommands
-- ===========================================================================================================
--- @class TestHandleThfCommands
-- Test suite for the `handle_thf_commands` function.
-- @within TestSharedFunctions
TestHandleThfCommands = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestHandleThfCommands
function TestHandleThfCommands:setUp()
    -- Save the original global functions and variables
    self.old_buffSelf = buffSelf

    -- Mock global functions and variables
    buffSelf = function(buff) end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestHandleThfCommands
function TestHandleThfCommands:tearDown()
    -- Restore the original global functions and variables
    buffSelf = self.old_buffSelf
end

--- Test the `handle_thf_commands` function with valid commands.
-- @function testWithValidCommands
-- @within TestHandleThfCommands
function TestHandleThfCommands:testWithValidCommands()
    luaunit.assertTrue(handle_thf_commands({ 'thfbuff' }))
end

--- Test the `handle_thf_commands` function with invalid commands.
-- @function testWithInvalidCommands
-- @within TestHandleThfCommands
function TestHandleThfCommands:testWithInvalidCommands()
    luaunit.assertFalse(handle_thf_commands({ 'invalid' }))
    luaunit.assertFalse(handle_thf_commands({ 123 }))
    luaunit.assertFalse(handle_thf_commands({}))
    luaunit.assertFalse(handle_thf_commands(nil))
end

-- ===========================================================================================================
--                                         Test AdjustGearBasedOnTPForWeaponSkill
-- ===========================================================================================================
--- @class TestAdjustGearBasedOnTPForWeaponSkill
-- Test suite for the `adjust_Gear_Based_On_TP_For_WeaponSkill` function.
-- @within TestSharedFunctions
TestAdjustGearBasedOnTPForWeaponSkill = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:setUp()
    -- Create mocks for spell, sets, player and treasureHunter
    self.old_spell = spell
    self.old_sets = sets
    self.old_player = player
    self.old_treasureHunter = treasureHunter

    spell = { type = 'WeaponSkill', name = 'Exenterator' }
    sets = { precast = { WS = { ['Exenterator'] = {} } } }
    player = { equipment = { sub = 'Centovente' }, tp = 1800 }
    treasureHunter = 'None'
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:tearDown()
    -- Restore the original values
    spell = self.old_spell
    sets = self.old_sets
    player = self.old_player
    treasureHunter = self.old_treasureHunter
end

--- Test the `adjust_Gear_Based_On_TP_For_WeaponSkill` function with a WeaponSkill spell and 'Centovente' equipped.
-- @function testWithWeaponSkillAndCentovente
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:testWithWeaponSkillAndCentovente()
    adjust_Gear_Based_On_TP_For_WeaponSkill(spell)
    luaunit.assertEquals(sets.precast.WS[spell.name].left_ear, 'MoonShade Earring')
end

--- Test the `adjust_Gear_Based_On_TP_For_WeaponSkill` function when player information is not available.
-- @function testWithMissingPlayerInfo
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:testWithMissingPlayerInfo()
    player = nil
    local success, err = pcall(adjust_Gear_Based_On_TP_For_WeaponSkill, spell)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "Player information is not available")
end

--- Test the `adjust_Gear_Based_On_TP_For_WeaponSkill` function when sets.precast.WS does not exist.
-- @function testWithMissingSets
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:testWithMissingSets()
    sets.precast.WS = nil
    local success, err = pcall(adjust_Gear_Based_On_TP_For_WeaponSkill, spell)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "Required tables do not exist")
end

--- Test the `adjust_Gear_Based_On_TP_For_WeaponSkill` function when spell is nil.
-- @function testWithNilSpell
-- @within TestAdjustGearBasedOnTPForWeaponSkill
function TestAdjustGearBasedOnTPForWeaponSkill:testWithNilSpell()
    spell = nil
    local success, err = pcall(adjust_Gear_Based_On_TP_For_WeaponSkill, spell)
    luaunit.assertFalse(success)
    luaunit.assertStrContains(err, "Spell is nil")
end

-- ===========================================================================================================
--                                         Test AdjustLeftEarEquipment
-- ===========================================================================================================
--- @class TestAdjustLeftEarEquipment
-- @description Test suite for the `adjust_Left_Ear_Equipment` function.
TestAdjustLeftEarEquipment = {}

--- @function TestAdjustLeftEarEquipment:testWithCentoventeAndTPInRange
-- @description Test the `adjust_Left_Ear_Equipment` function with 'Centovente' equipped and TP between 1750 and 2000.
function TestAdjustLeftEarEquipment:testWithCentoventeAndTPInRange()
    local spell = { name = 'Exenterator' }
    local player = { equipment = { sub = 'Centovente' }, tp = 1800 }
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'MoonShade Earring')
end

--- @function TestAdjustLeftEarEquipment:testWithoutCentoventeAndTPInRange
-- @description Test the `adjust_Left_Ear_Equipment` function without 'Centovente' equipped and TP between 1750 and 2000 or between 2750 and 3000.
function TestAdjustLeftEarEquipment:testWithoutCentoventeAndTPInRange()
    local spell = { name = 'Exenterator' }
    local player = { equipment = { sub = 'OtherWeapon' }, tp = 2800 }
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'MoonShade Earring')
end

--- @function TestAdjustLeftEarEquipment:testWithExenteratorSpell
-- @description Test the `adjust_Left_Ear_Equipment` function with the spell 'Exenterator'.
function TestAdjustLeftEarEquipment:testWithExenteratorSpell()
    local spell = { name = 'Exenterator' }
    local player = { equipment = { sub = 'OtherWeapon' }, tp = 1500 }
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'Dawn Earring')
end

--- @function TestAdjustLeftEarEquipment:testWithAeolianEdgeSpellAndTreasureHunter
-- @description Test the `adjust_Left_Ear_Equipment` function with the spell 'Aeolian Edge' and Treasure Hunter active.
function TestAdjustLeftEarEquipment:testWithAeolianEdgeSpellAndTreasureHunter()
    local spell = { name = 'Aeolian Edge' }
    local player = { equipment = { sub = 'OtherWeapon' }, tp = 1500 }
    treasureHunter = 'Active'
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'Sortiarius Earring')
end

--- @function TestAdjustLeftEarEquipment:testWithAeolianEdgeSpellWithoutTreasureHunter
-- @description Test the `adjust_Left_Ear_Equipment` function with the spell 'Aeolian Edge' and Treasure Hunter not active.
function TestAdjustLeftEarEquipment:testWithAeolianEdgeSpellWithoutTreasureHunter()
    local spell = { name = 'Aeolian Edge' }
    local player = { equipment = { sub = 'OtherWeapon' }, tp = 1500 }
    treasureHunter = 'None'
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'Sortiarius Earring')
end

--- @function TestAdjustLeftEarEquipment:testWithOtherSpell
-- @description Test the `adjust_Left_Ear_Equipment` function with a spell that is neither 'Exenterator' nor 'Aeolian Edge'.
function TestAdjustLeftEarEquipment:testWithOtherSpell()
    local spell = { name = 'OtherSpell' }
    local player = { equipment = { sub = 'OtherWeapon' }, tp = 1500 }
    luaunit.assertEquals(adjust_Left_Ear_Equipment(spell, player), 'Sherida Earring')
end

-- ===========================================================================================================
--                                         Test TestRefineUtsusemi
-- ===========================================================================================================
--- @class TestRefineUtsusemi
-- @description Test suite for the `refine_Utsusemi` function.
TestRefineUtsusemi = {}

--- @function TestRefineUtsusemi:setUp
-- @description Set up the test environment by mocking necessary functions and variables.
function TestRefineUtsusemi:setUp()
    -- Mock the necessary functions and variables
    self.old_windower = windower
    self.old_cancel_spell = cancel_spell
    self.old_cast_delay = cast_delay
    self.old_send_command = send_command
    self.old_add_to_chat = add_to_chat

    windower = { ffxi = { get_spell_recasts = function() return { [339] = 0, [338] = 0 } end } }
    cancel_spell = function() end
    cast_delay = function(delay) end
    send_command = function(command) end
    add_to_chat = function(code, message) end
end

--- @function TestRefineUtsusemi:tearDown
-- @description Tear down the test environment by restoring the original functions and variables.
function TestRefineUtsusemi:tearDown()
    -- Restore the original functions and variables
    windower = self.old_windower
    cancel_spell = self.old_cancel_spell
    cast_delay = self.old_cast_delay
    send_command = self.old_send_command
    add_to_chat = self.old_add_to_chat
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ni' spell and cooldowns off.
-- @function testWithUtsusemiNiAndCooldownsOff
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiNiAndCooldownsOff()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ni' }
    local eventArgs = { cancel = false }

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is false
    luaunit.assertFalse(eventArgs.cancel)
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ni' spell and cooldowns on.
-- @function testWithUtsusemiNiAndCooldownsOn
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiNiAndCooldownsOn()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ni' }
    local eventArgs = { cancel = false }

    -- Set the cooldowns on
    windower.ffxi.get_spell_recasts = function() return { [339] = 2, [338] = 2 } end

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is true
    luaunit.assertTrue(eventArgs.cancel)
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ichi' spell and cooldowns off.
-- @function testWithUtsusemiIchiAndCooldownsOff
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiIchiAndCooldownsOff()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ichi' }
    local eventArgs = { cancel = false }

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is false
    luaunit.assertFalse(eventArgs.cancel)
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ichi' spell and cooldowns on.
-- @function testWithUtsusemiIchiAndCooldownsOn
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiIchiAndCooldownsOn()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ichi' }
    local eventArgs = { cancel = false }

    -- Set the cooldowns on
    windower.ffxi.get_spell_recasts = function() return { [339] = 2, [338] = 2 } end

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is true
    luaunit.assertTrue(eventArgs.cancel)
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ni' spell, cooldowns on, but 'Utsusemi: Ichi' available.
-- @function testWithUtsusemiNiCooldownsOnButIchiAvailable
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiNiCooldownsOnButIchiAvailable()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ni' }
    local eventArgs = { cancel = false }

    -- Set the cooldowns on for 'Utsusemi: Ni' but off for 'Utsusemi: Ichi'
    windower.ffxi.get_spell_recasts = function() return { [339] = 2, [338] = 0 } end

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is true
    luaunit.assertTrue(eventArgs.cancel)
    -- Here you should also check that 'Utsusemi: Ichi' is cast, but this depends on how you implement the casting in your tests.
end

--- Test the `refine_Utsusemi` function with 'Utsusemi: Ni' spell and both spells on cooldown.
-- @function testWithUtsusemiNiAndBothSpellsOnCooldown
-- @within TestRefineUtsusemi
function TestRefineUtsusemi:testWithUtsusemiNiAndBothSpellsOnCooldown()
    -- Define the spell and eventArgs
    local spell = { name = 'Utsusemi: Ni' }
    local eventArgs = { cancel = false }

    -- Set the cooldowns on for both spells
    windower.ffxi.get_spell_recasts = function() return { [339] = 2, [338] = 2 } end

    -- Call the function to test
    refine_Utsusemi(spell, eventArgs)

    -- Assert that the eventArgs.cancel is true
    luaunit.assertTrue(eventArgs.cancel)
    -- Here you should also check that the appropriate message is displayed, but this depends on how you implement the messaging in your tests.
end

-- ===========================================================================================================
--                                         Test CheckWeaponset
-- ===========================================================================================================
--- @class TestCheckWeaponset
-- @description Test suite for the `check_weaponset` function.
TestCheckWeaponset = {} -- test suite

--- @function TestCheckWeaponset:setUp
-- @description Set up the test environment by mocking necessary functions and variables.
function TestCheckWeaponset:setUp()
    -- Setup mock data
    player = { main_job = 'THF' }
    state = {
        AbysseaProc = { value = false },
        WeaponSet1 = { current = 'set1' },
        WeaponSet2 = { current = 'set2' },
        SubSet = { current = 'subSet' }
    }
    sets = {
        set1 = { weapon = 'sword' },
        set2 = { weapon = 'axe' },
        subSet = { weapon = 'dagger' }
    }
    self.equipCalledWith = nil                           -- reset tracking variable
    equip = function(set) self.equipCalledWith = set end -- mock equip function
end

--- @function TestCheckWeaponset:tearDown
-- @description Tear down the test environment by restoring the original functions and variables.
function TestCheckWeaponset:tearDown()
    -- Cleanup mock data
    player = nil
    state = nil
    sets = nil
    equip = nil
end

--- @function TestCheckWeaponset:test_check_weaponset_main
-- @description Test the `check_weaponset` function with 'main' weapon type.
function TestCheckWeaponset:test_check_weaponset_main()
    -- Test with 'main' weapon type
    check_weaponset('main')
    luaunit.assertEquals(self.equipCalledWith, sets[state.WeaponSet1.current])
end

--- @function TestCheckWeaponset:test_check_weaponset_sub
-- @description Test the `check_weaponset` function with 'sub' weapon type.
function TestCheckWeaponset:test_check_weaponset_sub()
    -- Test with 'sub' weapon type
    check_weaponset('sub')
    luaunit.assertEquals(self.equipCalledWith, sets[state.SubSet.current])
end

--- @function TestCheckWeaponset:test_check_weaponset_invalid
-- @description Test the `check_weaponset` function with invalid weapon type.
function TestCheckWeaponset:test_check_weaponset_invalid()
    -- Test with invalid weapon type
    luaunit.assertErrorMsgContains('Invalid weaponType: bow', check_weaponset, 'bow')
end

-- ===========================================================================================================
--                                         Test CheckRangeLock
-- ===========================================================================================================
--- @class TestCheckRangeLock
-- @description Test suite for the `check_range_lock` function.
TestCheckRangeLock = {} -- test suite

--- @function TestCheckRangeLock:setUp
-- @description Set up the test environment by mocking necessary functions and variables.
function TestCheckRangeLock:setUp()
    -- Setup mock data
    player = { equipment = { range = 'bow' } }
    self.disableCalledWith = nil
    self.enableCalledWith = nil
    disable = function(...)
        self.disableCalledWith = { ... }; return '', 'No error' -- mock disable function
    end
    enable = function(...)
        self.enableCalledWith = { ... }; return '', 'No error' -- mock enable function
    end
end

--- @function TestCheckRangeLock:tearDown
-- @description Tear down the test environment by restoring the original functions and variables.
function TestCheckRangeLock:tearDown()
    -- Cleanup mock data
    player = nil
    disable = nil
    enable = nil
end

--- @function TestCheckRangeLock:test_check_range_lock_equipped
-- @description Test the `check_range_lock` function when a ranged weapon is equipped.
function TestCheckRangeLock:test_check_range_lock_equipped()
    check_range_lock()
    luaunit.assertEquals(self.disableCalledWith, { 'range', 'ammo' })
end

--- @function TestCheckRangeLock:test_check_range_lock_not_equipped
-- @description Test the `check_range_lock` function when no ranged weapon is equipped.
function TestCheckRangeLock:test_check_range_lock_not_equipped()
    player.equipment.range = 'empty'
    check_range_lock()
    luaunit.assertEquals(self.enableCalledWith, { 'range', 'ammo' })
end

--- @function TestCheckRangeLock:test_check_range_lock_no_player
-- @description Test the `check_range_lock` function when player or player.equipment or player.equipment.range is nil.
function TestCheckRangeLock:test_check_range_lock_no_player()
    player = nil
    luaunit.assertErrorMsgContains('player, player.equipment, or player.equipment.range is nil', check_range_lock)
end

-- ===========================================================================================================
--                                         Test ResetToDefaultEquipment
-- ===========================================================================================================
--- @class TestResetToDefaultEquipment
-- Test class for the `reset_to_default_equipment` function.
-- This class contains unit tests for the `reset_to_default_equipment` function.
TestResetToDefaultEquipment = {}

--- @section setup_teardown
-- Setup and teardown for the necessary mocks.

--- @function setUp
-- Setup function that is run before each test.
-- This function sets up the necessary mocks for the `reset_to_default_equipment` function.
function TestResetToDefaultEquipment:setUp()
    -- Mock the player object
    player = {
        status = 'Idle',
        equipment = { range = 'bow' }
    }

    -- Mock the sets object
    sets = {
        engaged = { weapon = 'sword' },
        idle = { weapon = 'staff' },
        MoveSpeed = { boots = 'speed boots' }
    }

    -- Mock the state object
    state = {
        Moving = { value = 'false' },
        HybridMode = { value = 'PDT' },
        Xp = { value = 'True' },
        OffenseMode = { value = 'Acc' }
    }

    -- Mock the equip function
    equip = function(...) end
end

--- @function tearDown
-- Teardown function that is run after each test.
-- This function resets the mocks to nil.
function TestResetToDefaultEquipment:tearDown()
    player = nil
    sets = nil
    state = nil
    equip = nil
end

-- ===========================================================================================================
--                                         Test JobHandleEquippingGear
-- ===========================================================================================================
--- @class TestJobHandleEquippingGear
-- Test class for the `job_handle_equipping_gear` function.
-- This class contains unit tests for the `job_handle_equipping_gear` function.
TestJobHandleEquippingGear = {}

--- @function setUp
-- Setup function that is run before each test.
-- This function saves the original `reset_to_default_equipment` function and initializes the mocks.
function TestJobHandleEquippingGear:setUp()
    -- Save the original function
    self.original_reset_to_default_equipment = reset_to_default_equipment

    -- Mock the state object
    state = {
        Xp = {
            value = 'True'
        }
    }

    -- Mock the player object
    player = { main_job = 'THF' }

    -- Mock the functions
    reset_to_default_equipment = function() end
    check_weaponset = function() end
    check_range_lock = function() end
end

--- @function tearDown
-- Teardown function that is run after each test.
-- This function restores the original `reset_to_default_equipment` function and resets the mocks.
function TestJobHandleEquippingGear:tearDown()
    -- Restore the original function
    reset_to_default_equipment = self.original_reset_to_default_equipment

    -- Reset the mocks
    state = nil
    check_weaponset = nil
    check_range_lock = nil
    player = nil
end

--- @function testCallsResetToDefaultEquipmentWhenXpTrue
-- Test that `job_handle_equipping_gear` calls `reset_to_default_equipment` when `state.Xp.value` is 'True'.
function TestJobHandleEquippingGear:testCallsResetToDefaultEquipmentWhenXpTrue()
    local wasCalled = false
    reset_to_default_equipment = function() wasCalled = true end
    job_handle_equipping_gear('Idle', {})
    luaunit.assertTrue(wasCalled)
end

--- @function testCallsCheckWeaponsetWhenXpNotTrue
-- Test that `job_handle_equipping_gear` calls `check_weaponset` for 'main' and 'sub' when `state.Xp.value` is not 'True'.
function TestJobHandleEquippingGear:testCallsCheckWeaponsetWhenXpNotTrue()
    state.Xp.value = 'False'
    local wasCalledMain = false
    local wasCalledSub = false
    check_weaponset = function(weapon)
        if weapon == 'main' then
            wasCalledMain = true
        elseif weapon == 'sub' then
            wasCalledSub = true
        end
    end
    job_handle_equipping_gear('Idle', {})
    luaunit.assertTrue(wasCalledMain)
    luaunit.assertTrue(wasCalledSub)
end

--- @function testCallsCheckRangeLockWhenMainJobTHF
-- Test that `job_handle_equipping_gear` calls `check_range_lock` when the player's main job is 'THF'.
function TestJobHandleEquippingGear:testCallsCheckRangeLockWhenMainJobTHF()
    state.Xp.value = 'False'
    local wasCalled = false
    check_range_lock = function() wasCalled = true end
    job_handle_equipping_gear('Idle', { main_job = 'THF' })
    luaunit.assertTrue(wasCalled)
end

-- ===========================================================================================================
--                                         Test JobStateChange
-- ===========================================================================================================
--- @class TestJobStateChange
-- Test class for the `job_state_change` function.
-- This class contains unit tests for the `job_state_change` function.
TestJobStateChange = {}

--- @function setUp
-- Setup function that is run before each test.
-- This function saves the original `check_weaponset` function and initializes the mocks.
function TestJobStateChange:setUp()
    -- Save the original function
    self.original_check_weaponset = check_weaponset

    -- Mock the check_weaponset function
    check_weaponset = function(weapon) end
end

--- @function tearDown
-- Teardown function that is run after each test.
-- This function restores the original `check_weaponset` function.
function TestJobStateChange:tearDown()
    -- Restore the original function
    check_weaponset = self.original_check_weaponset
end

--- @function testCallsCheckWeaponsetForMainAndSub
-- Test that `job_state_change` calls `check_weaponset` for 'main' and 'sub'.
function TestJobStateChange:testCallsCheckWeaponsetForMainAndSub()
    local wasCalledMain = false
    local wasCalledSub = false
    check_weaponset = function(weapon)
        if weapon == 'main' then
            wasCalledMain = true
        elseif weapon == 'sub' then
            wasCalledSub = true
        end
    end
    job_state_change('field', 'new_value', 'old_value')
    luaunit.assertTrue(wasCalledMain)
    luaunit.assertTrue(wasCalledSub)
end

--- @function testErrorWhenCheckWeaponsetIsNotAFunction
-- Test that an error is raised when `check_weaponset` is not a function.
function TestJobStateChange:testErrorWhenCheckWeaponsetIsNotAFunction()
    check_weaponset = nil
    luaunit.assertErrorMsgContains("Error: check_weaponset is not a function", job_state_change, 'field', 'new_value',
        'old_value')
end

--- @function testErrorWhenFieldIsNil
-- Test that an error is raised when `field` is `nil`.
function TestJobStateChange:testErrorWhenFieldIsNil()
    luaunit.assertErrorMsgContains("Error: field is nil", job_state_change, nil, 'new_value', 'old_value')
end

--- @function testErrorWhenNewValueIsNil
-- Test that an error is raised when `new_value` is `nil`.
function TestJobStateChange:testErrorWhenNewValueIsNil()
    luaunit.assertErrorMsgContains("Error: new_value is nil", job_state_change, 'field', nil, 'old_value')
end

--- @function testErrorWhenOldValueIsNil
-- Test that an error is raised when `old_value` is `nil`.
function TestJobStateChange:testErrorWhenOldValueIsNil()
    luaunit.assertErrorMsgContains("Error: old_value is nil", job_state_change, 'field', 'new_value', nil)
end

-- ===========================================================================================================
--                                         Test BuffChange
-- ===========================================================================================================
--- @class TestBuffChange
TestBuffChange = {}

--- @function setUp
-- Set up the test environment.
function TestBuffChange:setUp()
    -- Mock global functions and variables
    self.old_add_to_chat = add_to_chat
    self.old_send_command = send_command
    self.old_disable = disable
    self.old_enable = enable
    self.old_set_combine = set_combine
    self.old_equip = equip
    self.old_job_handle_equipping_gear = job_handle_equipping_gear
    self.old_sets = sets

    add_to_chat = function(...) end
    send_command = function(...) end
    disable = function(...) end
    enable = function(...) end
    set_combine = function(...) return {} end
    equip = function(...) end
    job_handle_equipping_gear = function(...) end

    -- Mock player, state, and sets
    player = { main_job = 'THF' }
    state = { Moving = { value = 'false' }, Buff = {}, TreasureMode = { value = 'SATA' } }
    sets = { buff = { Doom = {}, ['Sneak Attack'] = {}, ['Trick Attack'] = {} }, MoveSpeed = {}, precast = { JA = { ['Mana Wall'] = {} } }, TreasureHunter = {}, engaged = {}, idle = {} }
end

--- @function tearDown
-- Clean up the test environment.
function TestBuffChange:tearDown()
    -- Restore original global functions and variables
    add_to_chat = self.old_add_to_chat
    send_command = self.old_send_command
    disable = self.old_disable
    enable = self.old_enable
    set_combine = self.old_set_combine
    equip = self.old_equip
    job_handle_equipping_gear = self.old_job_handle_equipping_gear
    sets = self.old_sets

    -- Reset player and state
    player = nil
    state = nil
end

--- @function testBuffChange
-- Test the buff_change function.
function TestBuffChange:testBuffChange()
    -- Call buff_change with a buff and gain
    buff_change('doom', true)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

--- @function testBuffChangeDifferentBuff
-- Test the buff_change function with a different buff.
function TestBuffChange:testBuffChangeDifferentBuff()
    -- Call buff_change with a different buff and gain
    buff_change('Sneak Attack', true)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

--- @function testBuffChangeDifferentGain
-- Test the buff_change function with a different gain.
function TestBuffChange:testBuffChangeDifferentGain()
    -- Call buff_change with a buff and a different gain
    buff_change('doom', false)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

--- @function testBuffChangeDifferentJob
-- Test the buff_change function with a different player job.
function TestBuffChange:testBuffChangeDifferentJob()
    -- Change the player's main job
    player.main_job = 'WAR'

    -- Call buff_change with a buff and gain
    buff_change('doom', true)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

--- @function testBuffChangeMoving
-- Test the buff_change function when the player is moving.
function TestBuffChange:testBuffChangeMoving()
    -- Set the player to moving
    state.Moving.value = 'true'

    -- Call buff_change with a buff and gain
    buff_change('doom', true)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

--- @function testBuffChangeDifferentTreasureMode
-- Test the buff_change function with a different treasure mode.
function TestBuffChange:testBuffChangeDifferentTreasureMode()
    -- Change the treasure mode
    state.TreasureMode.value = 'None'

    -- Call buff_change with a buff and gain
    buff_change('doom', true)

    -- Assert that the function did not raise an error
    luaunit.assertTrue(true)
end

-- ===========================================================================================================
--                                         Test CustomizeSet
-- ===========================================================================================================
--- @class TestCustomizeSet
TestCustomizeSet = {}

--- @function setUp
-- Set up the test environment.
function TestCustomizeSet:setUp()
    -- Mock global functions and variables
    self.old_pairs = pairs

    pairs = function(t)
        local mock_pairs = { foo = true, bar = false }
        if t == mock_pairs then
            return next, mock_pairs, nil
        else
            return self.old_pairs(t)
        end
    end
end

--- @function tearDown
-- Clean up the test environment.
function TestCustomizeSet:tearDown()
    -- Restore original global functions and variables
    pairs = self.old_pairs
end

--- @function testCustomizeSet
-- Test the customize_set function.
function TestCustomizeSet:testCustomizeSet()
    local set = {}
    local conditions = { foo = true, bar = false }
    local setTable = { foo = { baz = 1 }, bar = { baz = 2 } }

    -- Call customize_set with valid parameters
    local result = customize_set(set, conditions, setTable)

    -- Assert that the function returned the correct set
    luaunit.assertEquals(result, setTable.foo)
end

--- @function testCustomizeSetInvalidParameters
-- Test the customize_set function with invalid parameters.
function TestCustomizeSet:testCustomizeSetInvalidParameters()
    -- Call customize_set with null parameters
    luaunit.assertErrorMsgContains("Invalid parameters", customize_set, nil, nil, nil)

    -- Call customize_set with non-table conditions
    luaunit.assertErrorMsgContains("Invalid parameters: conditions and setTable must be tables", customize_set, {}, "foo",
        {})

    -- Call customize_set with non-table setTable
    luaunit.assertErrorMsgContains("Invalid parameters: conditions and setTable must be tables", customize_set, {}, {},
        "foo")

    -- Call customize_set with a condition not present in setTable
    luaunit.assertErrorMsgContains("Invalid condition: foo", customize_set, {}, { foo = true }, { bar = {} })
end

-- ===========================================================================================================
--                                         Test GetConditionsAndSets
-- ===========================================================================================================
--- @class TestGetConditionsAndSets
TestGetConditionsAndSets = {}

--- @function setUp
-- Set up the test environment.
function TestGetConditionsAndSets:setUp()
    -- Mock global variables
    _G.state = {
        HybridMode = { value = 'PDT' },
        OffenseMode = { value = 'Acc' },
        Xp = { value = 'True' }
    }

    -- Save the original function
    self.originalResetToDefaultEquipment = ResetToDefaultEquipment

    -- Replace the function with a mock
    ResetToDefaultEquipment = function()
        -- Do nothing
    end
end

--- @function tearDown
-- Clean up the test environment.
function TestGetConditionsAndSets:tearDown()
    -- Restore original global variables
    _G.state = nil

    -- Restore the original function
    ResetToDefaultEquipment = self.originalResetToDefaultEquipment
end

function TestGetConditionsAndSets:testGetConditionsAndSets()
    local setPDT_XP = { test = 'PDT_XP' }
    local setPDT = { test = 'PDT' }
    local setPDT_ACC = { test = 'PDT_ACC' }
    local setMDT = { test = 'MDT' }

    -- Set the values of state.OffenseMode.value and state.HybridMode.value
    state.OffenseMode.value = 'Normal'
    state.HybridMode.value = 'PDT'

    -- Call get_conditions_and_sets with valid parameters
    local conditions, setTable = get_conditions_and_sets(setPDT_XP, setPDT, setPDT_ACC, setMDT)

    -- Assert that the function returned the correct conditions and setTable
    luaunit.assertEquals(conditions, {
        PDT_XP = true,
        PDT = false,
        PDT_ACC = false,
        MDT = false
    })
    luaunit.assertEquals(setTable, {
        PDT_XP = setPDT_XP,
        PDT = setPDT,
        PDT_ACC = setPDT_ACC,
        MDT = setMDT
    })
end

function TestGetConditionsAndSets:testGetConditionsAndSetsInvalidParameters()
    -- Set up the global state
    _G.state = {
        HybridMode = { value = 'PDT' },
        OffenseMode = { value = 'Acc' },
        Xp = { value = 'True' }
    }

    -- Call get_conditions_and_sets with invalid parameters
    local success, err = pcall(get_conditions_and_sets, "foo", {}, {}, {})

    -- Assert that the function generated an error
    luaunit.assertFalse(success)

    -- Assert that the error message is as expected
    local expectedErrorMsg = "Invalid parameters: setPDT_XP, setPDT, setPDT_ACC and setMDT must be either nil or tables"
    luaunit.assertStrContains(err, expectedErrorMsg)
end

-- ===========================================================================================================
--                                         Test CustomizeSetBasedOnState
-- ===========================================================================================================
--- @class TestCustomizeSetBasedOnState
TestCustomizeSetBasedOnState = {}

--- @function setUp
-- Set up the test environment.
function TestCustomizeSetBasedOnState:setUp()
    -- Mock global variables
    _G.state = {
        HybridMode = { value = 'PDT' },
        OffenseMode = { value = 'Acc' },
        Xp = { value = 'True' }
    }

    -- Save the original functions
    self.originalGetConditionsAndSets = get_conditions_and_sets
    self.originalCustomizeSet = customize_set

    -- Replace the functions with mocks
    get_conditions_and_sets = function(setXp, setPDT, setMDT)
        return { PDT_XP = true, PDT = false, PDT_ACC = false, MDT = false },
            { PDT_XP = setXp, PDT = setPDT, PDT_ACC = {}, MDT = setMDT }
    end
    customize_set = function(set, conditions, setTable)
        return set
    end
end

--- @function tearDown
-- Clean up the test environment.
function TestCustomizeSetBasedOnState:tearDown()
    -- Restore original global variables
    _G.state = nil

    -- Restore the original functions
    get_conditions_and_sets = self.originalGetConditionsAndSets
    customize_set = self.originalCustomizeSet
end

function TestCustomizeSetBasedOnState:testCustomizeSetBasedOnState()
    local set = { test = 'set' }
    local setXp = { test = 'setXp' }
    local setPDT = { test = 'setPDT' }
    local setMDT = { test = 'setMDT' }

    -- Call customize_set_based_on_state with valid parameters
    local result = customize_set_based_on_state(set, setXp, setPDT, setMDT)

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, set)
end

function TestCustomizeSetBasedOnState:testCustomizeSetBasedOnStateWithNilParameters()
    -- Call customize_set_based_on_state with nil parameters
    local result = customize_set_based_on_state(nil, nil, nil, nil)

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, nil)
end

function TestCustomizeSetBasedOnState:testCustomizeSetBasedOnStateWithDifferentBehavior()
    -- Replace the functions with mocks that behave differently
    get_conditions_and_sets = function(setXp, setPDT, setMDT)
        return { PDT_XP = false, PDT = true, PDT_ACC = true, MDT = true },
            { PDT_XP = {}, PDT = setPDT, PDT_ACC = setPDT, MDT = setMDT }
    end
    customize_set = function(set, conditions, setTable)
        return setTable.PDT
    end

    local set = { test = 'set' }
    local setXp = { test = 'setXp' }
    local setPDT = { test = 'setPDT' }
    local setMDT = { test = 'setMDT' }

    -- Call customize_set_based_on_state with valid parameters
    local result = customize_set_based_on_state(set, setXp, setPDT, setMDT)

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, setPDT)

    -- Restore the original functions
    get_conditions_and_sets = self.originalGetConditionsAndSets
    customize_set = self.originalCustomizeSet
end

-- ===========================================================================================================
--                                         Test GetMaxStratagemCount
-- ===========================================================================================================
--- @class TestGetMaxStratagemCount
-- This class contains unit tests for the get_max_stratagem_count function.
TestGetMaxStratagemCount = {}

--- Sets up the test environment before each test.
-- This function is called before each test. It mocks the global function 'S'.
function TestGetMaxStratagemCount:setUp()
    -- Mock global functions
    _G.S = function(t)
        return {
            contains = function(_, v)
                for _, value in pairs(t) do
                    if value == v then
                        return true
                    end
                end
                return false
            end
        }
    end
end

--- Tears down the test environment after each test.
-- This function is called after each test. It restores the global function 'S'.
function TestGetMaxStratagemCount:tearDown()
    -- Restore global functions
    _G.S = nil
end

--- Tests the get_max_stratagem_count function with a Scholar main job.
-- This test checks that the get_max_stratagem_count function returns the correct result when the player's main job is Scholar.
function TestGetMaxStratagemCount:testGetMaxStratagemCount()
    -- Mock global variables
    _G.player = {
        main_job = 'SCH',
        main_job_level = 99,
        sub_job = 'WAR',
        sub_job_level = 1
    }

    -- Call get_max_stratagem_count
    local result = get_max_stratagem_count()

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, 5)
end

--- Tests the get_max_stratagem_count function with a Scholar sub job.
-- This test checks that the get_max_stratagem_count function returns the correct result when the player's sub job is Scholar.
function TestGetMaxStratagemCount:testWithSubJob()
    -- Mock global variables
    _G.player = {
        main_job = 'WAR',
        main_job_level = 1,
        sub_job = 'SCH',
        sub_job_level = 99
    }

    -- Call get_max_stratagem_count
    local result = get_max_stratagem_count()

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, 5)
end

--- Tests the get_max_stratagem_count function with a non-Scholar job.
-- This test checks that the get_max_stratagem_count function returns the correct result when the player's job is not Scholar.
function TestGetMaxStratagemCount:testWithNonScholarJob()
    -- Mock global variables
    _G.player = {
        main_job = 'WAR',
        main_job_level = 1,
        sub_job = 'THF',
        sub_job_level = 1
    }

    -- Call get_max_stratagem_count
    local result = get_max_stratagem_count()

    -- Assert that the function returned the correct result
    luaunit.assertEquals(result, 0)
end

--- Tests the get_max_stratagem_count function with a Scholar main job at different levels.
function TestGetMaxStratagemCount:testAtDifferentLevels()
    local levels = { 99, 90, 70, 50, 30, 10 }
    local expectedResults = { 5, 5, 4, 3, 2, 1 }

    for i, lvl in ipairs(levels) do
        -- Mock global variables
        _G.player = {
            main_job = 'SCH',
            main_job_level = lvl,
            sub_job = 'WAR',
            sub_job_level = 1
        }

        -- Call get_max_stratagem_count
        local result = get_max_stratagem_count()

        -- Assert that the function returned the correct result
        luaunit.assertEquals(result, expectedResults[i])
    end
end

--- Tests the get_max_stratagem_count function with incorrect type for player.main_job.
function TestGetMaxStratagemCount:testWithIncorrectMainJobType()
    -- Mock global variables
    _G.player = {
        main_job = 123,
        main_job_level = 99,
        sub_job = 'WAR',
        sub_job_level = 1
    }

    -- Call get_max_stratagem_count and assert that it raises an error
    luaunit.assertErrorMsgContains("Erreur : 'player.main_job' n'est pas une chaîne.", get_max_stratagem_count)
end

--- Tests the get_max_stratagem_count function with incorrect type for player.main_job_level.
function TestGetMaxStratagemCount:testWithIncorrectMainJobLevelType()
    -- Mock global variables
    _G.player = {
        main_job = 'SCH',
        main_job_level = 'SCH',
        sub_job = 'WAR',
        sub_job_level = 1
    }

    -- Call get_max_stratagem_count and assert that it raises an error
    luaunit.assertErrorMsgContains("Erreur : 'player.main_job_level' n'est pas un nombre.", get_max_stratagem_count)
end

--- Tests the get_max_stratagem_count function with incorrect type for player.sub_job.
function TestGetMaxStratagemCount:testWithIncorrectSubJobType()
    -- Mock global variables
    _G.player = {
        main_job = 'SCH',
        main_job_level = 99,
        sub_job = 456,
        sub_job_level = 1
    }

    -- Call get_max_stratagem_count and assert that it raises an error
    luaunit.assertErrorMsgContains("Erreur : 'player.sub_job' n'est pas une chaîne.", get_max_stratagem_count)
end

--- Tests the get_max_stratagem_count function with incorrect type for player.sub_job_level.
function TestGetMaxStratagemCount:testWithIncorrectSubJobLevelType()
    -- Mock global variables
    _G.player = {
        main_job = 'SCH',
        main_job_level = 99,
        sub_job = 'WAR',
        sub_job_level = 'WAR'
    }

    -- Call get_max_stratagem_count and assert that it raises an error
    luaunit.assertErrorMsgContains("Erreur : 'player.sub_job_level' n'est pas un nombre.", get_max_stratagem_count)
end

--- Tests the get_max_stratagem_count function with player not defined.
function TestGetMaxStratagemCount:testWithPlayerNotDefined()
    -- Unset global variable
    _G.player = nil

    -- Call get_max_stratagem_count and assert that it raises an error
    luaunit.assertErrorMsgContains("Erreur : l'objet 'player' n'est pas défini.", get_max_stratagem_count)
end

-- ===========================================================================================================
--                                         Test GetStratagemRecastTime
-- ===========================================================================================================
--- @class TestGetStratagemRecastTime
-- Test suite for the `get_stratagem_recast_time` function.
TestGetStratagemRecastTime = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:setUp()
    -- Save the original global variables
    self.old_player = _G.player
    self.old_buffactive = _G.buffactive
    self.old_Storm = _G.Storm

    -- Mock global variables
    _G.player = {
        main_job = 'SCH',
        main_job_level = 99,
        sub_job = 'WAR',
        sub_job_level = 1
    }
    _G.buffactive = {
        ['Klimaform'] = true
    }
    _G.Storm = {
        ['Firestorm'] = true
    }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:tearDown()
    -- Restore the original global variables
    _G.player = self.old_player
    _G.buffactive = self.old_buffactive
    _G.Storm = self.old_Storm
end

--- Test the `get_stratagem_recast_time` function with a scholar main job.
-- @function testWithScholarMainJob
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:testWithScholarMainJob()
    _G.player = {
        main_job = 'SCH',
        main_job_level = 99,
        sub_job = 'WAR',
        sub_job_level = 1
    }
    luaunit.assertEquals(get_stratagem_recast_time(), 33)
end

--- Test the `get_stratagem_recast_time` function with a scholar sub job.
-- @function testWithScholarSubJob
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:testWithScholarSubJob()
    _G.player = {
        main_job = 'WAR',
        main_job_level = 1,
        sub_job = 'SCH',
        sub_job_level = 99
    }
    luaunit.assertEquals(get_stratagem_recast_time(), 33)
end

--- Test the `get_stratagem_recast_time` function with a non-scholar job.
-- @function testWithNonScholarJob
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:testWithNonScholarJob()
    _G.player = {
        main_job = 'WAR',
        main_job_level = 1,
        sub_job = 'THF',
        sub_job_level = 1
    }
    luaunit.assertEquals(get_stratagem_recast_time(), 240)
end

--- Test the `get_stratagem_recast_time` function at different levels.
-- @function testAtDifferentLevels
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:testAtDifferentLevels()
    _G.player = {
        main_job = 'SCH',
        main_job_level = 50,
        sub_job = 'WAR',
        sub_job_level = 1
    }
    luaunit.assertEquals(get_stratagem_recast_time(), 80)
end

--- Test the `get_stratagem_recast_time` function with player not defined.
-- @function testWithPlayerNotDefined
-- @within TestGetStratagemRecastTime
function TestGetStratagemRecastTime:testWithPlayerNotDefined()
    _G.player = nil
    luaunit.assertErrorMsgContains("Error: 'player' object is not defined.", get_stratagem_recast_time)
end

-- ===========================================================================================================
--                                         Test GetAvailableStratagemCount
-- ===========================================================================================================
--- @class TestGetAvailableStratagemCount
-- Test suite for the `get_available_stratagem_count` function.
TestGetAvailableStratagemCount = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestGetAvailableStratagemCount
function TestGetAvailableStratagemCount:setUp()
    -- Save the original global variables
    self.old_windower = _G.windower
    self.old_get_max_stratagem_count = _G.get_max_stratagem_count
    self.old_get_stratagem_recast_time = _G.get_stratagem_recast_time

    -- Mock global variables
    _G.windower = {
        ffxi = {
            get_ability_recasts = function() return { [231] = 60 } end
        }
    }
    _G.get_max_stratagem_count = function() return 5 end
    _G.get_stratagem_recast_time = function() return 48 end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestGetAvailableStratagemCount
function TestGetAvailableStratagemCount:tearDown()
    -- Restore the original global variables
    _G.windower = self.old_windower
    _G.get_max_stratagem_count = self.old_get_max_stratagem_count
    _G.get_stratagem_recast_time = self.old_get_stratagem_recast_time
end

--- Test the `get_available_stratagem_count` function.
-- @function testGetAvailableStratagemCount
-- @within TestGetAvailableStratagemCount
function TestGetAvailableStratagemCount:testGetAvailableStratagemCount()
    local available_stratagems = get_available_stratagem_count()
    luaunit.assertEquals(available_stratagems, 3)
end

-- ===========================================================================================================
--                                         Test StratagemsAvailable
-- ===========================================================================================================
--- @class TestStratagemsAvailable
-- Test suite for the `stratagems_available` function.
TestStratagemsAvailable = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:setUp()
    -- Save the original global variable
    self.old_get_available_stratagem_count = _G.get_available_stratagem_count

    -- Mock global variable
    _G.get_available_stratagem_count = function() return 5 end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:tearDown()
    -- Restore the original global variable
    _G.get_available_stratagem_count = self.old_get_available_stratagem_count
end

--- Test the `stratagems_available` function when stratagems are available.
-- @function testStratagemsAvailable
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:testStratagemsAvailable()
    luaunit.assertTrue(stratagems_available())
end

--- Test the `stratagems_available` function when no stratagems are available.
-- @function testStratagemsNotAvailable
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:testStratagemsNotAvailable()
    _G.get_available_stratagem_count = function() return 0 end
    luaunit.assertFalse(stratagems_available())
end

--- Test the `stratagems_available` function when `get_available_stratagem_count` is not a function.
-- @function testGetAvailableStratagemCountNotAFunction
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:testGetAvailableStratagemCountNotAFunction()
    _G.get_available_stratagem_count = nil
    luaunit.assertErrorMsgContains("Error: 'get_available_stratagem_count' is not a function.", stratagems_available)
end

--- Test the `stratagems_available` function when `get_available_stratagem_count` does not return a number.
-- @function testGetAvailableStratagemCountDoesNotReturnNumber
-- @within TestStratagemsAvailable
function TestStratagemsAvailable:testGetAvailableStratagemCountDoesNotReturnNumber()
    _G.get_available_stratagem_count = function() return "not a number" end
    luaunit.assertErrorMsgContains("Error: 'get_available_stratagem_count' did not return a number.",
        stratagems_available)
end

-- ===========================================================================================================
--                                         Test CommandFunctions
-- ===========================================================================================================
--- @class TestCommandFunctions
TestCommandFunctions = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestCommandFunctions
function TestCommandFunctions:setUp()
    -- Mock the functions that the commands are supposed to call
    self.bufferRoleForAltRdm = bufferRoleForAltRdm
    bufferRoleForAltRdm = function(role)
        return role
    end
    self.handle_altNuke = handle_altNuke
    handle_altNuke = function(spell, tier, isRa)
        return spell, tier, isRa
    end
    self.bubbleBuffForAltGeo = bubbleBuffForAltGeo
    bubbleBuffForAltGeo = function(state, isEntrust, isGeo)
        return state, isEntrust, isGeo
    end
    -- Initialize state
    state = {
        altPlayerLight = { value = 'some value' },
        altPlayerDark = { value = 'some value' },
        altPlayerTier = { value = 'some value' },
        altPlayera = { value = 'some value' },
        -- Add other fields if necessary
    }
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestCommandFunctions
function TestCommandFunctions:tearDown()
    -- Restore the original functions
    bufferRoleForAltRdm = self.bufferRoleForAltRdm
    handle_altNuke = self.handle_altNuke
    bubbleBuffForAltGeo = self.bubbleBuffForAltGeo
end

--- Test the `commandFunctions` table.
-- This test checks if each command in the `commandFunctions` table calls the corresponding function with the correct arguments.
-- @function testCommandFunctions
-- @within TestCommandFunctions
function TestCommandFunctions:testCommandFunctions()
    -- Test each command
    local result = commandFunctions.bufftank()
    luaunit.assertEquals(result, 'bufftank')
    -- Test each command
    luaunit.assertEquals(commandFunctions.bufftank(), 'bufftank')
    luaunit.assertEquals(commandFunctions.buffmelee(), 'buffmelee')
    luaunit.assertEquals(commandFunctions.buffrng(), 'buffrng')
    luaunit.assertEquals(commandFunctions.curaga(), 'curaga')
    luaunit.assertEquals(commandFunctions.debuff(), 'debuff')
    luaunit.assertEquals({ commandFunctions.altlight() },
        { state.altPlayerLight.value, state.altPlayerTier.value, false })
    luaunit.assertEquals({ commandFunctions.altdark() }, { state.altPlayerDark.value, state.altPlayerTier.value, false })
    luaunit.assertEquals({ commandFunctions.altra() }, { state.altPlayera.value, nil, true })
    luaunit.assertEquals({ commandFunctions.altindi() }, { SharedFunctions.altState.Indi, false, false })
    luaunit.assertEquals({ commandFunctions.altentrust() }, { SharedFunctions.altState.Entrust, true, false })
    luaunit.assertEquals({ commandFunctions.altgeo() }, { SharedFunctions.altState.Geo, false, true })
end

-- ===========================================================================================================
--                                         Test CommandFunctions
-- ===========================================================================================================
--- @class TestWs_range
TestWs_range = {}

--- Set up the test environment.
-- This function is called before each test.
-- @function setUp
-- @within TestWs_range
function TestWs_range:setUp()
    -- Mock the functions that the commands are supposed to call
    self.cancel_spell_called = false
    self.add_to_chat_called = false
    self.cancel_spell = cancel_spell
    self.add_to_chat = add_to_chat
    cancel_spell = function()
        self.cancel_spell_called = true
    end
    add_to_chat = function(code, message)
        self.add_to_chat_called = true
        return code, message
    end
end

--- Tear down the test environment.
-- This function is called after each test.
-- @function tearDown
-- @within TestWs_range
function TestWs_range:tearDown()
    -- Restore the original functions
    cancel_spell = self.cancel_spell
    add_to_chat = self.add_to_chat
end

--- Test Ws_range with a spell of type "WeaponSkill" that is within range
-- @function testWs_range_in_range
-- @within TestWs_range
function TestWs_range:testWs_range_in_range()
    local spell = {
        type = "WeaponSkill",
        range = 10,
        target = {
            distance = 5,
            model_size = 1
        }
    }
    Ws_range(spell)
    luaunit.assertFalse(self.cancel_spell_called)
    luaunit.assertFalse(self.add_to_chat_called)
end

--- Test Ws_range with a spell of type "WeaponSkill" that is out of range
-- @function testWs_range_out_of_range
-- @within TestWs_range
function TestWs_range:testWs_range_out_of_range()
    local spell = {
        type = "WeaponSkill",
        range = 10,
        target = {
            distance = 20,
            model_size = 1
        }
    }
    Ws_range(spell)
    luaunit.assertTrue(self.cancel_spell_called)
    luaunit.assertTrue(self.add_to_chat_called)
end

os.exit(luaunit.LuaUnit.run())
