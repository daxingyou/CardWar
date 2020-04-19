---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/5/6 17:35
---


---@class SkillInfo
---@field id string
---@field owner string
---@field name string
---@field type string
---@field performance string
---@field priority number
---@field damageAdd number
---@field crit number
---@field critPow number
---@field targetSelectType string
---@field triggerCondition string
---@field triggerConditionParam string
local SkillConfig = {}

---@return SkillInfo
function SkillConfig.Get(name)
    if SkillConfig.data == nil then
        SkillConfig.data = require("Game.Data.Excel.Skill")
    end
    local info = SkillConfig.data.Get(name) ---@type SkillInfo
    if info == nil then
        logError(string.format("There is not skill info named %s!", name))
    end

    return info
end

---@param battleUnitName string
---@return table<number, SkillInfo>
function SkillConfig.GetList(battleUnitName)
    if SkillConfig.map == nil then
        local map = require("Game.Data.Excel.Skill")
        SkillConfig.map = map
        ---@param skillInfo SkillInfo
        for _, skillInfo in pairs(map.table) do
            --促发条件
            local triggerCondition = skillInfo.triggerCondition
            local condition = string.split(triggerCondition, "|")
            skillInfo.triggerCondition = condition[1]
            skillInfo.triggerConditionParam = condition[2]


            local list = map[skillInfo.owner]
            if list == nil then
                list = {}
                map[skillInfo.owner] = list
            end
            table.insert(list, skillInfo)
        end
    end
    local info = SkillConfig.map[battleUnitName] ---@type table<number, SkillInfo>
    if info == nil then
        logError(string.format("There is not skill list info named %s!", battleUnitName))
    end
    return info
end

return SkillConfig