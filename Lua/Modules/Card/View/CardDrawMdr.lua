---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-05-31-23:29:58
---

local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Card.View.CardDrawMdr : Game.Core.Ioc.BaseMediator
---@field cardModel Game.Modules.Card.Model.CardModel
---@field roleModel Game.Modules.Role.Model.RoleModel
---@field cardService Game.Modules.Card.Service.CardService
---@field cardPool Game.Modules.Card.Vo.CardPoolVo
local CardDrawMdr = class("Game.Modules.Card.View.CardDrawMdr",BaseMediator)

function CardDrawMdr:OnInit()
    self.cardService:getCardPool(Handler.New(self.OnCardPool, self))
end

function CardDrawMdr:OnCardPool(data)
    self.cardPool = self.cardModel.cardPoolList[1]

    self:InitCardPoolView()
end

function CardDrawMdr:InitCardPoolView()
    self.btn1 = self.gameObject:FindChild("Group/Btn11")
    self.btn2 = self.gameObject:FindChild("Group/Btn12")
    self.btn3 = self.gameObject:FindChild("Group/Btn13")
    self.gameObject:GetText("Panel/Group/Btn11/Cost/Text").text = "付费 " .. self.cardPool.limitDrawPrice;
    self.gameObject:GetText("Panel/Group/Btn12/Cost/Text").text = "" .. self.cardPool.singleDrawPrice;
    self.gameObject:GetText("Panel/Group/Btn13/Cost/Text").text = "" .. self.cardPool.seriesDrawPrice;
end

function CardDrawMdr:On_Click_Btn11()
    self.cardService:drawCard(self.cardPool.name, 1,DrawCardType.Limit_Single, function(data)
        vmgr:LoadView(ViewConfig.DrawCardList)
    end)
end

function CardDrawMdr:On_Click_Btn12()
    self.cardService:drawCard(self.cardPool.name, 1,DrawCardType.Normal_Single, function(data)
        vmgr:LoadView(ViewConfig.DrawCardList)
    end)
end

function CardDrawMdr:On_Click_Btn13()
    self.cardService:drawCard(self.cardPool.name, self.cardPool.maxTimes, DrawCardType.Normal_Series, function(data)
        vmgr:LoadView(ViewConfig.DrawCardList)
    end)
end

return CardDrawMdr
