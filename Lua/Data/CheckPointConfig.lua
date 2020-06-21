---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/7/25 13:36
---


--场景关卡信息
---@class ChapterData
---@field name string
---@field type string 类型
---@field sections table<number, CheckPointData>
---@field uiLayoutUrl string

--场景关卡信息
---@class CheckPointData
---@field id string
---@field name string
---@field type string 类型
---@field chapter number 所属章节
---@field section number 消耗体力
---@field strength number 所属章节
---@field maxPassNum number 最大通关次数
---@field maxResetNum number 最大重置次数
---@field firstRewardId number 首次奖励id
---@field rewardId number 奖励id
---@field level string
---@field cameraDistance number
---@field cameraAngle UnityEngine.Vector3
---@field cameraOffset UnityEngine.Vector3
---@field layoutPrefabUrl string
---@field layoutPoints string
---@field layoutDistance number 对阵距离
---@field layoutGridSize number 对阵格子大小
---@field light string
---@field areas table<number, GridAreaInfo>
---@field iconUrl string

local CheckPointConfig = {}

CheckPointConfig.data = nil

CheckPointConfig.chapters = nil

function CheckPointConfig.Init()
    CheckPointConfig.data = require("Game.Data.Excel.CheckPoint")
    CheckPointConfig.chapters = {}
    for i, info in pairs(CheckPointConfig.data.table) do
        local chapterData = CheckPointConfig.chapters[info.chapter] ---@type ChapterData
        if chapterData == nil then
            chapterData = {}
            chapterData.sections = {}
            chapterData.name = info.chapter
            chapterData.type = info.type
            chapterData.uiLayoutUrl = info.uiLayoutUrl
            CheckPointConfig.chapters[info.chapter] = chapterData
        end
        if isString(info.cameraAngle) then
            info.cameraAngle = Tool.ToVector3(info.cameraAngle)
        end
        if isString(info.cameraOffset) then
            info.cameraOffset = Tool.ToVector3(info.cameraOffset)
        end
        table.insert(chapterData.sections, info)
    end
end

---@return CheckPointData
function CheckPointConfig.Get(name)
    local info = CheckPointConfig.data.Get(name) ---@type CheckPointData
    if info == nil then
        logError(string.format("There is not CheckPoint info named %s!", name))
    end

    return info
end

---@return CheckPointData
function CheckPointConfig.GetBattleSceneData(name)
    local list = CheckPointConfig.Get(name)
    list = ObjectUtil.clone(list)--克隆数据
    list.areas = BattleConfig.GetAreas(list.id)
    return list
end

---@return ChapterData
function CheckPointConfig.GetChapterData(chapter)
    local info = CheckPointConfig.chapters[chapter]
    return info
end

return CheckPointConfig