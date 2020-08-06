---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-06-28-23:55:51
---

local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Battle.View.BattleResultMdr : Game.Core.Ioc.BaseMediator
---@field battleModel Game.Modules.Battle.Model.BattleModel
---@field roleModel Game.Modules.Role.Model.RoleModel
---@field battleService Game.Modules.Battle.Service.BattleService
---@field context WorldContext
local BattleResultMdr = class("Game.Modules.Battle.View.BattleResultMdr",BaseMediator)

function BattleResultMdr:OnInit()
    self.context = self.battleModel.currentContext
    self.gameObject:GetText("Panel/Title/Text").text = self.battleModel.battleResult and "战斗胜利" or "战斗失败"
    self.battleService:EndBattle(
            self.roleModel.roleId,
            self.checkPointModel.currSection.checkPointData.chapter,
            self.checkPointModel.currSection.checkPointData.id, 3,Handler.New(self.OnEndBattle, self))
end

function BattleResultMdr:OnEndBattle()
    local record = self.context.battleBehavior.reportReplay.record
    if self.battleModel.isReplayReport then
        --重播不保存战报
    else
        self.battleService:SaveBattleReport(
                self.roleModel.roleInfo.id,
                self.roleModel.roleInfo.level,
                self.checkPointModel.currSection.checkPointData.chapter,
                self.checkPointModel.currSection.checkPointData.id,
                2,
                record.unitCards,
                record:GetReportNodes(),
                record:GetAccountNodes()
        )
    end
end

function BattleResultMdr:On_Click_BtnDone()
    self:Unload()
    World.worldScene:EnterLobby()--再次进入大厅
end

return BattleResultMdr
