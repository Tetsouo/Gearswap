---============================================================================
--- FFXI GearSwap Messages - Beastmaster (BST) Specific Messages
---============================================================================
--- Beastmaster-specific messaging functions for pet management, ecosystem
--- selection, and broth handling.
---
--- @file messages/jobs/MESSAGE_BST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-08-22
--- @requires messages/MESSAGE_CORE, messages/MESSAGE_FORMATTING
---============================================================================

local MessageBST = {}

-- Load critical dependencies
local success_core, MessageCore = pcall(require, 'messages/MESSAGE_CORE')
if not success_core then
    error("Failed to load messages/MESSAGE_CORE: " .. tostring(MessageCore))
end

local success_formatting, MessageFormatting = pcall(require, 'messages/MESSAGE_FORMATTING')
if not success_formatting then
    error("Failed to load messages/MESSAGE_FORMATTING: " .. tostring(MessageFormatting))
end

-- Helper function for standardized job names
local function get_standardized_job_name(override_job_name)
    return MessageCore.get_standardized_job_name(override_job_name)
end

-- ===========================================================================================================
--                                     BST JOB-SPECIFIC MESSAGES
-- ===========================================================================================================

--- Creates BST resource error message
function MessageBST.bst_resource_error_message()
    MessageCore.error("BST", "Resources module not found")
end

--- Creates enhanced BST ecosystem change message with pets and correlation info (matching original format exactly)
-- @param ecosystem (string): Name of the ecosystem
-- @param pet_count (number): Number of available pets
function MessageBST.bst_ecosystem_message(ecosystem, pet_count)
    if not ecosystem or not pet_count then return end

    -- Show separator before ecosystem info
    MessageCore.show_separator()

    -- BST-specific ecosystem message with specialized colors
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)         -- Light Blue for job names
    local colorEcosystem = string.char(0x1F, 050)   -- Yellow for ecosystem
    local colorInfo = string.char(0x1F, 030)        -- Green for info
    local colorPet = string.char(0x1F, 087)         -- Light cyan for pet names
    local colorCorrelation = string.char(0x1F, 158) -- Orange for correlation

    local job_name = MessageCore.get_standardized_job_name()

    -- Main ecosystem message
    local main_message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] Ecosystem: ' ..
        colorEcosystem .. ecosystem .. colorGray .. ' | ' ..
        colorInfo .. pet_count .. ' pets available'
    windower.add_to_chat(001, main_message)

    -- Show monster correlation if ecosystem is not "All"
    if ecosystem ~= "All" then
        local success_correlation, MonsterCorrelation = pcall(require, 'jobs/bst/MONSTER_CORRELATION')
        if success_correlation and MonsterCorrelation then
            local correlation_summary = MonsterCorrelation.get_correlation_summary_colored(ecosystem)
            if correlation_summary and correlation_summary ~= "No correlation data available" then
                local correlation_message = colorGray ..
                    '[' .. colorJob .. job_name .. colorGray .. '] Correlation: ' ..
                    correlation_summary
                windower.add_to_chat(001, correlation_message)
            end
        end
    end

    -- Show separator after ecosystem info
    MessageCore.show_separator()
end

--- Creates BST species/pet selection message (matching original format exactly)
-- @param pet_name (string): Name of the selected pet
-- @param is_species_change (boolean): Whether this is a species change or pet info
function MessageBST.bst_pet_selection_message(pet_name, is_species_change)
    if not pet_name then return end

    -- Show separator before species change info
    MessageCore.show_separator()

    -- BST-specific pet selection message with specialized colors
    local colorGray = string.char(0x1F, 160)
    local colorJob = string.char(0x1F, 207)    -- Light Blue for job names
    local colorPet = string.char(0x1F, 050)    -- Yellow for pet name
    local colorAction = string.char(0x1F, 030) -- Green for action

    local job_name = MessageCore.get_standardized_job_name()
    local action_text = is_species_change and "Species changed to: " or "Selected pet: "
    local message = colorGray .. '[' .. colorJob .. job_name .. colorGray .. '] ' ..
        colorAction .. action_text .. colorPet .. pet_name

    windower.add_to_chat(001, message)

    -- Show separator after species change info
    MessageCore.show_separator()
end

--- Creates BST pet not found error message
-- @param species (string): Species that wasn't found
function MessageBST.bst_pet_not_found_message(species)
    if not species then return end

    MessageCore.error("BST", "No pets found for species: " .. species)
end

--- Creates BST broth equipped message
-- @param pet_name (string): Name of the pet the broth is for
function MessageBST.bst_broth_equipped_message(pet_name)
    if not pet_name then return end

    MessageCore.info("BST", "Equipped broth for " .. pet_name)
end

--- Creates BST ammo/broth error messages
-- @param error_type (string): Type of error ('no_ammo_set', 'broth_not_recognized')
-- @param additional_info (string): Additional info for broth_not_recognized
function MessageBST.bst_ammo_error_message(error_type, additional_info)
    if error_type == 'no_ammo_set' then
        MessageCore.error("BST", "No ammoSet or invalid ammo data")
    elseif error_type == 'broth_not_recognized' and additional_info then
        MessageCore.error("BST", "Broth name not recognized: " .. additional_info)
    end
end

--- Creates BST pet info message with detailed information
-- @param pet_name (string): Name of the pet
-- @param family (string): Pet family
-- @param jug_count (number): Number of jugs available
function MessageBST.bst_pet_info_message(pet_name, family, jug_count)
    if not pet_name or not family or not jug_count then return end

    local info = pet_name .. ' | Family: ' .. family .. ' | Jug(s): ' .. jug_count
    MessageCore.info("BST", "Pet Info: " .. info)
end

--- Creates BST ready move error message
-- @param slot_number (number): Ready move slot number that's unavailable
function MessageBST.bst_ready_move_error_message(slot_number)
    if not slot_number then return end

    MessageCore.error("BST", "Ready Move #" .. slot_number .. " unavailable")
end

--- Creates BST selection info message with multiple lines
-- @param ecosystem (string): Current ecosystem
-- @param species (string): Current species
-- @param current_pet (string): Current selected pet
-- @param available_count (number): Number of available pets
function MessageBST.bst_selection_info_message(ecosystem, species, current_pet, available_count)
    if not ecosystem or not species or not current_pet or not available_count then return end

    MessageCore.show_separator()

    MessageCore.multiline("BST", "Current Selection:", {
        "Ecosystem: " .. ecosystem,
        "Species: " .. species,
        "Pet: " .. current_pet,
        "Available: " .. available_count .. " pets"
    })

    MessageCore.show_separator()
end

return MessageBST