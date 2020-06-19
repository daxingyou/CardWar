---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-06-03-23:40:49
---

local CardItem = require("Game.Modules.Card.View.CardItem")
local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Card.View.CardListMdr : Game.Core.Ioc.BaseMediator
---@field cardModel Game.Modules.Card.Model.CardModel
---@field cardService Game.Modules.Card.Service.CardService
local CardListMdr = class("Game.Modules.Card.View.CardListMdr",BaseMediator)

function CardListMdr:OnInit()
    self:SetCloseBg(self.gameObject:FindChild("Bg"))
    self.cardList = TableList.New(self.gameObject:FindChild("List/ListView"), CardItem)
    self.cardList:SetData(self.cardModel:SortByActive())
    self.cardList.eventDispatcher:AddEventListener(ListViewEvent.ItemClick,self.onItemClick, self)
end


function CardListMdr:onItemClick(event, data, index)
    print(string.format("click card index %s",index))
end

return CardListMdr
