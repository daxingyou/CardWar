﻿-- Anim 2020/4/20 0:20:49
local Data = {}
Data.table = {    ["micro_dragon_atk"] = {id = "micro_dragon_atk", animName = "dragon_bite", animSpeed = 1, accountPoint = 0.5, animEffect = ""},
    ["micro_dragon_skill"] = {id = "micro_dragon_skill", animName = "dragon_attack_repeatedly", animSpeed = 1, accountPoint = 0.5, animEffect = ""},
    ["Villager_B_Boy_atk"] = {id = "Villager_B_Boy_atk", animName = "Combo", animSpeed = 1, accountPoint = 0.5, animEffect = ""},
    ["Villager_B_Boy_Skill"] = {id = "Villager_B_Boy_Skill", animName = "Skill", animSpeed = 1, accountPoint = 0.5, animEffect = ""},
}

function Data.Get(id)
    if Data.table[id] == nil then
        logError(string.format('There is no id = %s data is table <Anim.xlsx>', id))
        return nil
    else
        return Data.table[id]
    end
end

return Data
                
