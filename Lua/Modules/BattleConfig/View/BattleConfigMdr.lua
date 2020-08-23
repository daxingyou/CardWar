---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-06-17-21:31:19
---

local BattleCtrl = require("Game.Modules.Battle.Ctrl.BattleCtrl")
local ArrayCardItem = require("Game.Modules.BattleConfig.View.ArrayCardItem")
local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.BattleConfig.View.ArrayEditorMdr : Game.Core.Ioc.BaseMediator
---@field battleConfigModel Game.Modules.BattleConfig.Model.BattleConfigModel
---@field cardModel Game.Modules.Card.Model.CardModel
---@field roleModel Game.Modules.Role.Model.RoleModel
---@field battleModel Game.Modules.Battle.Model.BattleModel
---@field checkPointModel Game.Modules.CheckPoint.Model.CheckPointModel
---@field battleConfigService Game.Modules.BattleConfig.Service.BattleConfigService
---@field battleService Game.Modules.Battle.Service.BattleService
---@field ownerList List | table<number, Game.Modules.Card.Vo.CardVo>
---@field cardList Betel.UI.TableList
---@field selectList List | table<number, Game.Modules.Card.Vo.CardVo>
local BattleConfigMdr = class("Game.Modules.BattleConfig.View.BattleConfigMdr",BaseMediator)

function BattleConfigMdr:Ctor()
    BattleConfigMdr.super.Ctor(self)
    self.layer = UILayer.LAYER_FLOAT
end

function BattleConfigMdr:OnInit()
    self.ownerList = self.cardModel:SortByStar()

    self:SetCloseBg(self.gameObject:FindChild("Bg"))
    self.cardList = TableList.New(self.gameObject:FindChild("List/ListView"), ArrayCardItem)
    self.cardList:SetData(self.ownerList)
    self.cardList.eventDispatcher:AddEventListener(ListViewEvent.ItemClick, self.onItemClick, self)

    self.battleConfigService:GetBattleConfig(self.roleModel.roleId,self.battleConfigModel.battleType, handler(self, self.OnInitSelectList))
end

function BattleConfigMdr:OnClickBg()
    navigation:Pop(self.viewInfo)
end

function BattleConfigMdr:OnInitSelectList(data)
    self.selectList = self.battleConfigModel.selectList
    self.selectCardList = TableList.New(self.gameObject:FindChild("ListSelect/ListView"), ArrayCardItem)
    self.selectCardList:SetData(self.selectList)
    self.selectCardList:SetScrollEnable(false)
    self.selectCardList.eventDispatcher:AddEventListener(ListViewEvent.ItemClick,self.onSelectItemClick, self)
end

function BattleConfigMdr:onItemClick(event, data, index)
    if self.selectList:Size() < 5 and not self.selectList:Contain(data) then
        self.selectList:Add(data)
        self.selectCardList:SetData(self.selectList)
        local item = self.cardList:GetItemRenderByIndex(index) ---@type Game.Modules.BattleConfig.View.ArrayCardItem
        item.select = true
        item:UpdateItem(data, index)
    end
end

function BattleConfigMdr:onSelectItemClick(event, data, index)
    if self.selectList:Contain(data) then
        local item = self.cardList:GetItemRenderByData(data) ---@type Game.Modules.BattleConfig.View.ArrayCardItem
        self.selectList:Remove(data)
        self.selectCardList:Refresh()
        if item then
            item.select = false
            item:UpdateItem(data, index)
        end
        --self:CreateDelayedFrameCall(function()
        --    self.selectCardList:SetData(self.selectList)
        --end)
    end
end

function BattleConfigMdr:On_Click_BtnCancel()
    navigation:Pop(ViewConfig.BattleConfig)
end

function BattleConfigMdr:On_Click_BtnEnter()
    if self.selectList:Size() == 0 then
        Tips.Show("请选择上场英雄")
        return
    end
    local battleArray = {}
    for i = 1, self.selectList:Size() do
        table.insert(battleArray, self.selectList[i].id)
    end
    self.battleConfigService:SaveBattleArray(
            self.roleModel.roleId,
            self.battleConfigModel.battleType,
            battleArray,function(data)
                if data.battleArrayResult then
                    self:OfficialStartBattle()
                end
            end)

end

--正式进入战斗
function BattleConfigMdr:OfficialStartBattle()
    Transition:CleatNavigation(function()
        BattleCtrl.New():StartPveBattle(self.selectList)
    end)
end

return BattleConfigMdr
