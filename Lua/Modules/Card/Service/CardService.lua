---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-01:33:53
---

local RoleEvents = require("Game.Modules.Role.Events.RoleEvents")
local CardVo = require("Game.Modules.Card.Vo.CardVo")
local DrawCardVo = require("Game.Modules.Card.Vo.DrawCardVo")
local CardPoolVo = require("Game.Modules.Card.Vo.CardPoolVo")
local BaseService = require("Game.Core.Ioc.BaseService")
---@class Game.Modules.Card.Service.CardService : Game.Core.Ioc.BaseService
---@field cardModel Game.Modules.Card.Model.CardModel
---@field roleModel Game.Modules.Role.Model.RoleModel
---@field roleService Game.Modules.Role.Service.RoleService
local CardService = class("CardService",BaseService)

function CardService:Ctor()
    
end

---@param roleId string
---@param callback fun()
function CardService:getCardList(roleId, callback)
    self:HttpRequest(Action.CardList, {roleId}, function(data)
        if self.roleModel.roleInfo.id == roleId then
            local cardList = List.New()
            for i = 1, #data.cardList do
                local cardVo = CardVo.New(data.cardList[i])
                cardList:Add(cardVo)
            end
            self.cardModel.cardList = cardList
        end
        invoke(callback, data)
    end)
end

---@param callback fun() | Handler
function CardService:getCardPool(callback)
    self:HttpRequest(Action.CardPoolInfo, EmptyParam, function(data)
        local cardPoolList = List.New()
        for i = 1, #data.cardPoolList do
            local vo = CardPoolVo.New(data.cardPoolList[i])
            cardPoolList:Add(vo)
        end
        self.cardModel.cardPoolList = cardPoolList
        invoke(callback, data)
    end)
end

---@param poolName string
---@param num number
---@param callback fun()
function CardService:drawCard(poolName, num, drawCardType, callback)
    self:HttpRequest(Action.DrawCard, {self.roleModel.roleId, poolName, drawCardType, num}, function(data)
        local drawCardList = List.New()
        for i = 1, #data.drawCardList do
            local cardVo = DrawCardVo.New(data.drawCardList[i])
            drawCardList:Add(cardVo)
        end
        self.cardModel.drawCardList = drawCardList
        invoke(callback, data)
        RoleEvents.DispatchEvent(RoleEvents.GetResource)--获取资源
    end)
end

return CardService
