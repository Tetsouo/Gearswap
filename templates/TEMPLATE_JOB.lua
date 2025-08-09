---============================================================================
--- FFXI GearSwap Configuration Template - [JOB_NAME] ([JOB_CODE])
---============================================================================
--- Professional GearSwap configuration template for [JOB_NAME] job in FFXI.
--- Copy this template to create new job configurations following best practices.
---
--- @file templates/TEMPLATE_JOB.lua
--- @author [YOUR_NAME]
--- @version 1.0
--- @date Created: [DATE]
--- @date Modified: [DATE]
--- @requires Mote-Include v2.0+
--- @requires GearSwap addon
--- @requires Windower FFXI
---
--- INSTRUCTIONS FOR USE:
--- 1. Copy this file and rename it to YourName_[JOB_CODE].lua (e.g., Tetsouo_COR.lua)
--- 2. Replace all [PLACEHOLDER] values with actual job-specific content
--- 3. Customize gear sets in jobs/[job_code]/[JOB_CODE]_SET.lua
--- 4. Add job-specific functions in jobs/[job_code]/[JOB_CODE]_FUNCTION.lua
--- 5. Update dependencies section with any job-specific requirements
--- 6. Test thoroughly with //gs load YourName_[JOB_CODE]
---
--- Dependencies:
---   - modules/automove.lua     : Automatic movement detection and gear swapping
---   - modules/shared.lua       : Shared utility functions across jobs
---   - jobs/[job_code]/[JOB_CODE]_SET.lua    : [JOB_NAME]-specific equipment sets
---   - jobs/[job_code]/[JOB_CODE]_FUNCTION.lua : [JOB_NAME]-specific advanced functions
---
--- Features Template:
---   - [FEATURE_1] (e.g., Auto-weapon skill optimization)
---   - [FEATURE_2] (e.g., Buff tracking and gear adjustment)
---   - [FEATURE_3] (e.g., Sub-job specific macro management)
---   - Dual-boxing support for mage coordination
---   - Professional error handling and logging
---   - Full modular system integration
---
--- Usage:
---   Place in: Windower4/addons/GearSwap/data/[CharacterName]/
---   Load with: //gs load [CharacterName]_[JOB_CODE]
---   Test with: //gs c test
---   Unload with: //gs unload
---
--- Key Bindings Template:
---   F9  : [BINDING_1] (e.g., Cycle Casting Mode)
---   F10 : [BINDING_2] (e.g., Cycle Weapon Set)
---   F11 : [BINDING_3] (e.g., Toggle Defense Mode)
---
--- Console Commands Template:
---   //gs c test                    : Run module tests
---   //gs c cycle [STATE_NAME]      : Toggle job-specific states
---   //gs c [CUSTOM_COMMAND]        : Job-specific commands
---============================================================================

---============================================================================
--- CORE INITIALIZATION FUNCTIONS
---============================================================================

--- Initialize the GearSwap environment and load required dependencies.
--- This function is automatically called by GearSwap when the lua file is loaded.
--- Sets up Mote-Include v2 framework and loads all necessary job-specific modules.
---
--- Initialization Order:
---   1. Mote-Include v2 framework
---   2. Movement automation module
---   3. Shared utility functions
---   4. [JOB_NAME] equipment sets
---   5. [JOB_NAME] advanced functions
---
--- @usage Automatically called by GearSwap - do not call manually
--- @see Mote-Include.lua For framework documentation
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')                        -- Utility functions and structures for GearSwap
    include('modules/automove.lua')                    -- Automatic movement speed gear swapping
    include('modules/shared.lua')                      -- Functions shared across multiple jobs
    include('jobs/[job_code]/[JOB_CODE]_SET.lua')      -- Gear sets specific to [JOB_NAME]
    include('jobs/[job_code]/[JOB_CODE]_FUNCTION.lua') -- Advanced functions specific to [JOB_NAME]

    -- Include any additional job-specific modules here
    -- Example: include('Mote-TreasureHunter.lua') for jobs that use TH
end

--- Initialize gear sets for [JOB_NAME].
--- This function is intentionally minimal as gear sets are externally defined
--- in the [JOB_CODE]_SET.lua file for better organization and maintainability.
---
--- @usage Automatically called by Mote framework
--- @see jobs/[job_code]/[JOB_CODE]_SET.lua For complete equipment set definitions
function init_gear_sets()
    -- All gear sets are defined in jobs/[job_code]/[JOB_CODE]_SET.lua for better organization
end

---============================================================================
--- JOB SETUP AND STATE MANAGEMENT
---============================================================================

--- Configure job-specific logic, states, and core mechanics.
--- Initializes all [JOB_NAME]-specific functionality including state management,
--- buff tracking, and job ability coordination.
---
--- Key Features to Configure:
---   - Job-specific state variables and options
---   - Buff tracking for job abilities
---   - Weapon configurations and sets
---   - Defense mode options
---   - [ADD_JOB_SPECIFIC_FEATURES]
---
--- @usage Automatically called by Mote framework after dependency loading
--- @see user_setup For user preference configuration
function job_setup()
    -- Configure job-specific states
    -- Example: state.CastingMode:options('Normal', 'Resistant')
    -- state.[STATE_NAME]:options('[OPTION1]', '[OPTION2]', '[OPTION3]')

    -- Configure buff tracking
    -- Example: state.Buff['Boost'] = buffactive['boost'] or false
    -- state.Buff['[BUFF_NAME]'] = buffactive['[buff_name]'] or false

    -- Configure weapon sets
    -- Example: state.WeaponSet = M { ['description'] = 'Weapon', '[WEAPON1]', '[WEAPON2]' }

    -- Configure defense modes
    -- Example: state.DefenseMode:options('None', 'Physical', 'Magical')

    -- Configure job-specific options
    -- [ADD_JOB_SPECIFIC_SETUP_CODE]

    -- Configure dual-boxing states for mage coordination
    state.altPlayerLight = M('[ELEMENT1]', '[ELEMENT2]', '[ELEMENT3]')
    state.altPlayerDark = M('[ELEMENT1]', '[ELEMENT2]', '[ELEMENT3]')
    state.altPlayerTier = M('VI', 'V', 'IV', 'III', 'II', '')
    state.altPlayera = M('[SPELL1]a', '[SPELL2]a', '[SPELL3]a')
    state.altPlayerGeo = M('[GEO_SPELL1]', '[GEO_SPELL2]', '[GEO_SPELL3]')
    state.altPlayerIndi = M('[INDI_SPELL1]', '[INDI_SPELL2]', '[INDI_SPELL3]')
    state.altPlayerEntrust = M('[ENTRUST_SPELL1]', '[ENTRUST_SPELL2]')

    -- Set up keybindings
    send_command('bind F9 gs c cycle [STATE1]')
    send_command('bind F10 gs c cycle [STATE2]')
    send_command('bind F11 gs c cycle [STATE3]')
    -- Add more keybindings as needed
end

--- Configure user-specific settings and preferences.
--- Called after job_setup to handle user customizations and macro setup.
--- Primarily handles macro book selection based on subjob.
---
--- @usage Automatically called by Mote framework after job_setup
--- @see select_default_macro_book For macro and appearance configuration
function user_setup()
    select_default_macro_book() -- Selects the default macro book based on sub-job
end

--- Clean up resources when unloading the GearSwap file.
--- Unbinds all custom keybindings to prevent conflicts with other jobs.
--- Called automatically when changing jobs or reloading GearSwap.
---
--- @usage Automatically called by GearSwap during unload process
function file_unload()
    send_command('unbind F9')
    send_command('unbind F10')
    send_command('unbind F11')
    -- Unbind additional keys as needed
end

---============================================================================
--- CUSTOM COMMAND HANDLER
---============================================================================

--- Handle custom GearSwap commands including test execution.
--- Processes user commands sent via //gs c <command>
---
--- Available commands:
---   - test: Run unit tests for all modules
---   - [CUSTOM_COMMAND1]: [DESCRIPTION]
---   - [CUSTOM_COMMAND2]: [DESCRIPTION]
---
--- @param cmdParams table Command parameters split by spaces
--- @param eventArgs table Event arguments for command handling
--- @usage //gs c test (runs unit tests)
--- @usage //gs c [custom_command] (job-specific command)
function job_self_command(cmdParams, eventArgs)
    -- Run unit tests
    if cmdParams[1] == 'test' then
        add_to_chat(050, "Executing GearSwap module tests...")
        include('test_runner.lua')
        eventArgs.handled = true
        return
    end

    -- Add job-specific commands here
    -- Example:
    -- if cmdParams[1] == 'mybuff' then
    --     cast_job_buff()
    --     eventArgs.handled = true
    --     return
    -- end

    -- [ADD_CUSTOM_COMMANDS]
end

---============================================================================
--- SPELL CASTING EVENT HANDLERS
---============================================================================

--- Handle pre-casting logic and validations.
--- Performs comprehensive checks before spell/ability execution including:
--- - Action lock validation to prevent casting during other actions
--- - Spell/ability refinement and optimization based on current state
--- - Cooldown checking and display
--- - Job-specific pre-casting logic
---
--- @param spell table The spell/ability object being used
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell/ability classification mapping
--- @param eventArgs table Event arguments with cancel/handled flags
--- @usage Automatically called by GearSwap before spell/ability execution
function job_precast(spell, action, spellMap, eventArgs)
    -- Prevent casting during other actions
    if midaction() then
        return
    end

    -- Handle spell/ability processing
    handle_spell(spell, eventArgs, auto_abilities)
    checkDisplayCooldown(spell, eventArgs)

    -- Add job-specific pre-casting logic here
    -- Example: refine_[job_specific]_spells(spell, eventArgs)
    -- [ADD_JOB_SPECIFIC_PRECAST]
end

--- Handle mid-casting logic and gear optimization.
--- Executes during the casting animation phase to optimize performance
--- and prepare for potential interruptions.
---
--- @param spell table The spell/ability object being used
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell/ability classification mapping
--- @param eventArgs table Event arguments for handling
--- @usage Automatically called by GearSwap during casting
function job_midcast(spell, action, spellMap, eventArgs)
    -- Add job-specific mid-casting logic here
    -- Example: optimize_[job_specific]_casting(spell, eventArgs)
    -- [ADD_JOB_SPECIFIC_MIDCAST]
end

--- Handle post-casting cleanup and state management.
--- Executes after spell/ability completion or interruption.
---
--- @param spell table The spell/ability object that was used
--- @param action table The action object containing cast information
--- @param spellMap string Mote's spell/ability classification mapping
--- @param eventArgs table Event arguments for handling
--- @usage Automatically called by GearSwap after casting
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Add job-specific after-casting logic here
    -- Example: handle_[job_specific]_aftercast(spell, eventArgs)
    -- [ADD_JOB_SPECIFIC_AFTERCAST]
end

---============================================================================
--- BUFF MANAGEMENT
---============================================================================

--- Handle buff changes for job-specific optimizations.
--- Called whenever a buff is gained or lost to adjust equipment accordingly.
---
--- @param buff string Name of the buff that changed
--- @param gain boolean True if buff was gained, false if lost
--- @param eventArgs table Event arguments for handling
--- @usage Automatically called by GearSwap on buff changes
function job_buff_change(buff, gain, eventArgs)
    -- Add job-specific buff handling here
    -- Example:
    -- if buff == '[JOB_SPECIFIC_BUFF]' then
    --     handle_[job_specific]_buff(gain)
    --     return
    -- end

    -- [ADD_JOB_SPECIFIC_BUFF_HANDLING]
end

---============================================================================
--- STATUS CHANGE HANDLERS
---============================================================================

--- Handle player status changes (Idle, Engaged, Resting, etc.).
--- Called when player status changes to ensure appropriate gear sets.
---
--- @param newStatus string The new player status
--- @param oldStatus string The previous player status
--- @usage Automatically called by GearSwap on status changes
function job_status_change(newStatus, oldStatus)
    -- Add job-specific status change handling here
    -- Example: handle_[job_specific]_status(newStatus, oldStatus)
    -- [ADD_JOB_SPECIFIC_STATUS_HANDLING]
end

---============================================================================
--- MACRO AND APPEARANCE MANAGEMENT
---============================================================================

--- Select appropriate macro book based on subjob and apply appearance settings.
--- Automatically configures macro pages, lockstyles, and appearance addons
--- based on the current subjob configuration.
---
--- Macro Configuration:
---   - [SUBJOB1]: Page [X], Book [Y]
---   - [SUBJOB2]: Page [X], Book [Y]
---   - [SUBJOB3]: Page [X], Book [Y]
---
--- @usage Called automatically during user_setup
function select_default_macro_book()
    -- Safely unload dressup to prevent macro conflicts
    send_command('lua unload dressup')

    -- JOB_NAME macro pages based on subjob
    local macro_page = ({
        SUBJOB1 = PAGE_NUMBER,
        SUBJOB2 = PAGE_NUMBER,
        SUBJOB3 = PAGE_NUMBER
    })[player.sub_job] or DEFAULT_PAGE

    set_macro_page(1, macro_page)

    -- Apply lockstyle
    send_command('wait 3; input /lockstyleset [LOCKSTYLE_NUMBER]')

    -- Reload dressup with delay to avoid conflicts
    send_command('wait 20; lua load dressup')
end

---============================================================================
--- TEMPLATE COMPLETION CHECKLIST
---============================================================================
-- When creating a new job from this template, ensure you:
--
-- [ ] Replace all [PLACEHOLDER] values with job-specific content
-- [ ] Create jobs/[job_code]/[JOB_CODE]_SET.lua with equipment sets
-- [ ] Create jobs/[job_code]/[JOB_CODE]_FUNCTION.lua with job functions
-- [ ] Update @file header with correct filename and author
-- [ ] Configure job-specific states in job_setup()
-- [ ] Add job-specific keybindings and commands
-- [ ] Implement job-specific event handlers
-- [ ] Configure macro book mappings for all relevant subjobs
-- [ ] Test with //gs load [CharacterName]_[JOB_CODE]
-- [ ] Verify with //gs c test
-- [ ] Update this documentation to reflect actual implementation
--
-- Placeholders to replace:
-- - [JOB_NAME]: Full job name (e.g., "Corsair")
-- - [JOB_CODE]: 3-letter job code (e.g., "COR")
-- - [YOUR_NAME]: Author name
-- - [DATE]: Current date
-- - [job_code]: Lowercase job code for file paths (e.g., "cor")
-- - [FEATURE_X]: Job-specific features
-- - [BINDING_X]: Keybinding descriptions
-- - [STATE_NAME]: State variable names
-- - [BUFF_NAME]: Job-specific buff names
-- - [CUSTOM_COMMAND]: Job-specific commands
-- - [SUBJOB1], etc.: Relevant subjobs
-- - [PAGE_NUMBER]: Macro page numbers
-- - [LOCKSTYLE_NUMBER]: Lockstyle set number
-- - All other [PLACEHOLDER] values throughout the file
---============================================================================
