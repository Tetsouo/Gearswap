--============================================================--
--=                    DNC_FUNCTION                          =--
--============================================================--
--=                    Author: Tetsouo                       =--
--=                     Version: 1.0                         =--
--=                  Created: 2023-07-10                     =--
--=               Last Modified: 2024/02/08                  =--
--============================================================--

-- Constants used throughout the script
local constants = {
    ABILITY_IDS = {
        -- ID for the "Contradance" ability
        CONTRADANCE = 229,
    },
    SPELL_NAMES = {
        -- Name of the "Divine Waltz II" spell
        DIVINE_WALTZ_II = "Divine Waltz II",
    }
}

--- Automatically uses the 'Presto' ability for 'Step' type spells when the main job level is 77 or above and 'Presto' is not on cooldown.
-- @param {table} spell - The spell object to attempt to cast. It must be a table with a 'type' field.
-- @param {table} eventArgs - The event arguments object. It must have a 'handled' field.
function handle_presto_and_step(spell, eventArgs)
    -- Attempt to cast the spell
    if try_cast_spell(spell, eventArgs) then
        -- If the spell type is 'Step'
        if spell.type == 'Step' then
            -- Use the 'Presto' ability
            auto_ability(spell, eventArgs, 236, 'Presto')
        end
    end
end

--- Maps spells to their corresponding automatic abilities.
-- @table auto_abilities
auto_abilities = {
    -- Uses 'Contradance' ability for 'Divine Waltz II' spell.
    [constants.SPELL_NAMES.DIVINE_WALTZ_II] = function(spell, eventArgs)
        -- If the player has less than 800 TP, cancel the spell and display a message.
        if player.tp < 800 then
            eventArgs.handled = true
            cancel_spell()
            local message = createFormattedMessage("", tostring(player.tp) .. ' TP', nil, "Not enough TP !!!", true)
            add_to_chat(057, message)
        else
            -- Otherwise, use the 'Contradance' ability.
            auto_ability(spell, eventArgs, constants.ABILITY_IDS.CONTRADANCE, 'Contradance')
        end
    end
}

--- Automatically triggers 'Climactic Flourish' when executing 'Rudra's Storm' or 'Shark Bite'.
-- @param {table} spell - The spell object to attempt to cast.
function auto_WS_flourish(spell)
    -- Retrieve the recast times for all abilities.
    local allRecasts = windower.ffxi.get_ability_recasts()

    -- Get the recast times for 'Climactic Flourish' and 'Building Flourish'.
    local ClimCD = allRecasts[226]
    local BuilCD = allRecasts[222]

    -- Check if the spell is 'Rudra's Storm' or 'Shark Bite', the player has more than 1000 TP, the target has more than 25% HP, and the player has at least 3 Finishing Moves.
    if (spell.name == "Rudra's Storm" or spell.name == 'Shark Bite') and player.tp > 1000 and player.target.hpp > 25 and (buffactive['Finishing Move (3+)'] or buffactive['Finishing Move (6+)']) then
        -- If 'Climactic Flourish' is off cooldown and not active, cancel the current spell, use 'Climactic Flourish', wait 2 seconds, then execute the original spell.
        if ClimCD < 1 and not climactic then
            cancel_spell()
            send_command('input /ja "Climactic Flourish" <me>; wait 2; input /ws "' ..
                spell.name .. '"' .. spell.target.id)
        end
    end
end

-- Add this new state at the beginning of your script
-- This state determines whether to use the alternate step.
state.UseAltStep = M(false, 'Use Alt Step')

--- Handles custom commands specific to the job.
-- It updates the altState object, handles a set of predefined commands, and handles job-specific and subjob-specific commands.
-- @param {table} cmdParams - The command parameters. The first element is expected to be the command name.
-- @param {table} eventArgs - Additional event arguments.
-- @param {table} spell - The spell currently being cast.
function job_self_command(cmdParams, eventArgs, spell)
    -- Update the altState object
    update_altState()
    local command = cmdParams[1]:lower()

    -- If the command is defined, execute it
    if commandFunctions[command] then
        commandFunctions[command](altPlayerName, mainPlayerName)
    else
        -- If the player's main job is 'DNC' and the command is 'step'
        if player.main_job == 'DNC' and command == 'step' then
            if cmdParams[2] == 't' then
                -- Use the value of state.MainStep or state.AltStep as the spell name to cast
                local step = state.UseAltStep.value and state.AltStep.value or state.MainStep.value
                send_command('input /ja "' .. step .. '" <t>')
                -- Toggle the state for the next call
                state.UseAltStep:toggle()
            end
        end
    end
end
