-- Function BuffSelf2
function buffSelf2(w1, w2, w3)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local WarcryCD = allRecasts[2]
    local BloodRageCD = allRecasts[11]
    local RetalationCD = allRecasts[8]
    local RestraintCD = allRecasts[9]
    local AggressorActive = buffactive['Agressor']
    local WarcryActive = buffactive['Warcry']
    local BloodRageActive = buffactive['Bloodrage']
    local RetaliationActive = buffactive['Retaliation']
    local RestraintActive = buffactive['Restraint']
    if WarcryCD < 1 and (not WarcryActive or not BloodRageActive) then
        send_command(w1 .. 'input /ja "Warcry" <me>')
        if RetalationCD < 1 and not RetaliationActive then
            send_command(w2 .. 'input /ja "Retaliation" <me>')
            if RestraintCD < 1 and not RestraintActive then
                send_command(w3 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        else
            add_to_chat(123, "Retaliation n'est pas pret ou actif !")
            if RestraintCD < 1 and not RestraintActive then
                send_command(w2 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        end
    elseif (WarcryCD > 1 and BloodRageCD < 1) and (not WarcryActive and not BloodRageActive) then
        send_command(w1 .. 'input /ja "Bloodrage" <me>')
        if RetalationCD < 1 and not RetaliationActive then
            send_command(w2 .. 'input /ja "Retaliation" <me>')
            if RestraintCD < 1 and not RestraintActive then
                send_command(w3 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        else
            add_to_chat(123, "Retaliation n'est pas pret ou actif !")
            if RestraintCD < 1 and not RestraintActive then
                send_command(w2 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        end
    else
        add_to_chat(123, "Warcry ou Bloodrage ne sont pas ou l'un est actif")
        if RetalationCD < 1 and not RetaliationActive then
            send_command(w2 .. 'input /ja "Retaliation" <me>')
            if RestraintCD < 1 and not RestraintActive then
                send_command(w3 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        else
            add_to_chat(123, "Retaliation n'est pas pret ou actif !")
            if RestraintCD < 1 and not RestraintActive then
                send_command(w2 .. 'input /ja "Restraint" <me>')
            else
                add_to_chat(123, "Restraint n'est pas pret ou actif !")
            end
        end
    end
end
-- Function BuffSelf
function buffSelf(param1, CD, BuffActive1, BuffActive2, cmdParams, eventArgs)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local AggressorCD = allRecasts[4]
    local AggressorActive = buffactive['Agressor']
    if param1 == 'Berserk' then
        send_command('gs c set HybridMode Normal')
        if BuffActive2 then
            send_command('cancel defender')
        end
    elseif param1 == 'Defender' then
        send_command('gs c set HybridMode PDT')
        if BuffActive2 then
            send_command('cancel berserk')
        end
    end
    if CD < 1 and not BuffActive then
        equip({body = 'Pumm. Lorica +3', feet = 'Agoge Calligae +3'})
        send_command('input /ja ' .. param1 .. ' <me>')
        if AggressorCD < 1 and not AggressorActive then
            send_command('wait 1; input /ja "Aggressor" <me>')
            buffSelf2('wait 2 ; ', 'wait 3 ; ', 'wait 4 ; ')
        else
            add_to_chat(123, "Aggressor n'est pas pret ou actif")
            buffSelf2('wait 1 ; ', 'wait 2 ; ', 'wait 3 ; ')
        end
    else
        add_to_chat(123, param1 .. " n'est pas pret ou actif !")
        if AggressorCD < 1 and not AggressorActive then
            send_command('input /ja "Aggressor" <me>')
            buffSelf2('wait 1 ; ', 'wait 2 ; ', 'wait 3 ; ')
        else
            add_to_chat(123, "Aggressor n'est pas pret ou actif")
            buffSelf2('', 'wait 1 ; ', 'wait 2 ; ')
        end
    end
end
-- Function qui determine les buffs à faire
function job_self_command(cmdParams, eventArgs)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local BerserkCD = allRecasts[1]
    local DefenderCD = allRecasts[3]
    local BerserkActive = buffactive['Berserk']
    local DefenderActive = buffactive['Defender']

    if cmdParams[1] == 'Berserk' then
        buffSelf('Berserk', BerserkCD, BerserkActive, DefenderActive, cmdParams, eventArgs)
    elseif cmdParams[1] == 'Defender' then
        buffSelf('Defender', DefenderCD, DefenderActive, BerserkActive, cmdParams, eventArgs)
    elseif cmdParams[1] == 'ThirdEye' then
        ThirdEye(DefenderActive, BerserkActive)
    end
end

-- Function qui determine si on fait Seigan ou Hasso pour Third Eye
function ThirdEye(DefenderActive, BerserkActive)
    local allRecasts = windower.ffxi.get_ability_recasts()
    local SeiganCD = allRecasts[139]
    local HassoCD = allRecasts[138]
    local ThirdEyeCD = allRecasts[133]
    local SeiganActive = buffactive['Seigan']
    local HassoActive = buffactive['Hasso']
    local ThirdEyeActive = buffactive['Third Eye']
    if player.sub_job == 'SAM' then
        if state.HybridMode.value == 'PDT' then
            if not SeiganActive or SeiganCD < 1 then
                send_command('input /ja "Seigan" <me>')
                if not ThirdEyeActive and ThirdEyeCD < 1 then
                    send_command('wait 1; input /ja "Third Eye" <me>')
                else
                    add_to_chat(123, "Third Eye n'est pas pret ou actif")
                end
            elseif SeiganActive or SeiganCD > 1 then
                add_to_chat(123, "Seigan n'est pas pret ou actif")
                if not ThirdEyeActive and ThirdEyeCD < 1 then
                    send_command('wait 1; input /ja "Third Eye" <me>')
                else
                    add_to_chat(123, "Third Eye n'est pas pret ou actif")
                end
            end
        elseif state.HybridMode.value == 'Normal' then
            if not HassoActive or HassoCD < 1 then
                send_command('input /ja "Hasso" <me>')
                if not ThirdEyeActive and ThirdEyeCD < 1 then
                    send_command('wait 1; input /ja "Third Eye" <me>')
                else
                    add_to_chat(123, "Third Eye n'est pas pret ou actif")
                end
            elseif HassoActive or HassoCD > 1 then
                add_to_chat(123, "Hasso n'est pas pret ou actif")
                if not ThirdEyeActive and ThirdEyeCD < 1 then
                    send_command('wait 1; input /ja "Third Eye" <me>')
                else
                    add_to_chat(123, "Third Eye n'est pas pret ou actif")
                end
            end
        end
    end
end
