---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2019-05-18-23:23:12
---

local BattleReportVo = require("Game.Modules.Battle.Vo.BattleReportVo")
local BaseService = require("Game.Core.Ioc.BaseService")
---@class Game.Modules.Battle.Service.BattleService : Game.Core.Ioc.BaseService
---@field battleModel Game.Modules.Battle.Model.BattleModel
local BattleService = class("BattleService",BaseService)

function BattleService:Ctor()
    
end

--开始战斗
---@param roleId string
---@param chapterId number
---@param checkpointId string
---@param callback fun()
function BattleService:StartBattle(roleId, chapterId, checkpointId, callback)
    self:HttpRequest(Action.StartBattle, {roleId, chapterId, checkpointId}, function(data)
        invoke(callback, data)
    end)
end

--结束战斗
---@param roleId string
---@param chapterId number
---@param checkpointId string
---@param callback fun()
function BattleService:EndBattle(roleId, chapterId, checkpointId, star, callback)
    self:HttpRequest(Action.EndBattle, {roleId, chapterId, checkpointId, star}, function(data)
        invoke(callback, data)
    end)
end

--保存战斗
---@param roleId string
---@param chapterId number
---@param checkpointId string
---@param star number
---@param battleUnits table
---@param reportNodes table
---@param callback fun()
function BattleService:SaveBattleReport(roleId, roleLevel, chapterId, checkpointId, star, battleUnits, reportNodes, accountNodes, callback)
    --roleId,chapterId,checkpointId,battleStar,battleUnits,reportNodes, accountNodes
    self:HttpPost(Action.SaveBattleReport, {roleId, roleLevel, chapterId, checkpointId, star, battleUnits, reportNodes, accountNodes}, function(data)
        invoke(callback, data)
    end)
end

--获取关卡的战报列表
---@param chapterId number
---@param checkpointId string
---@param callback fun()
function BattleService:GetBattleReportList(chapterId, checkpointId, callback)
    self:HttpRequest(Action.GetBattleReportList, {chapterId, checkpointId}, function(data)
        self.battleModel.checkpointReports = {}
        for i = 1, #data.battleReportList do
            table.insert(self.battleModel.checkpointReports, BattleReportVo.New(data.battleReportList[i]))
        end
        invoke(callback, data)
    end)
end

--获取关卡的战报详细
---@param reportId string
---@param callback fun()
function BattleService:GetBattleReport(reportId, callback)
    self:HttpRequest(Action.GetBattleReport, {reportId}, function(data)
        for i = 1, #self.battleModel.checkpointReports do
            local report = self.battleModel.checkpointReports[i]
            if report.id == reportId then
                report:SetReport(data.battleReport)
                invoke(callback, report)
                break
            end
        end

    end)
end

return BattleService
