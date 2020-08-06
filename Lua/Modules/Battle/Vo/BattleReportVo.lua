---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/7/20 23:35
---

local AccountNode = require("Game.Modules.Battle.Report.Nodes.AccountNode")
local CardVo = require("Game.Modules.Card.Vo.CardVo")
local ReportNode = require("Game.Modules.Battle.Report.Nodes.ReportNode")
local UnitNode = require("Game.Modules.Battle.Report.Nodes.UnitNode")

---@class Game.Modules.Battle.Vo.BattleReportVo
---@field New fun():Game.Modules.Battle.Vo.BattleReportVo
---@field id string --
---@field roleId number --上传者
---@field roleLevel number --上传者
---@field chapterId number 战斗所在章节
---@field checkpointId number
---@field star number 几星通关
---@field lastPassTime string 上次通关时间
---@field battleUnits table<number, Game.Modules.Battle.Report.Nodes.UnitNode>
---@field reportNodes table<number, Game.Modules.Battle.Report.Nodes.ReportNode>
local BattleReportVo = class("Game.Modules.Battle.Vo.BattleReportVo");

---@param data table
function BattleReportVo:Ctor(data)
    self.id = data.id
    self.roleId = data.roleId
    self.roleLevel = data.roleLevel
    self.chapterId = data.chapterId
    self.checkpointId = data.checkpointId
    self.star = data.star
    self.lastPassTime = data.lastPassTime

    self.battleUnits = {}
    for i = 1, #data.battleUnits do
        table.insert(self.battleUnits, UnitNode.New(data.battleUnits[i]))
    end
end

---@return table<number, Game.Modules.Card.Vo.CardVo>
function BattleReportVo:GetCardList()
    local list = List.New()
    for i = 1, #self.battleUnits do
        local cardVo = CardVo.New(self.battleUnits[i])
        list:Add(cardVo)
    end
    return list;
end

--战报详情
function BattleReportVo:SetReport(data)
    local accountNodeMap = {}
    for i = 1, #data.accountNodes do
        if accountNodeMap[data.accountNodes[i].pid] == nil then
            accountNodeMap[data.accountNodes[i].pid] = {}
        end
        table.insert(accountNodeMap[data.accountNodes[i].pid], data.accountNodes[i])
    end

    self.reportNodes = {}
    for i = 1, #data.reportNodes do
        local node = ReportNode.New(data.reportNodes[i])
        node:InitAccountMap(accountNodeMap[node.id])
        table.insert(self.reportNodes, node)
    end
end

return BattleReportVo