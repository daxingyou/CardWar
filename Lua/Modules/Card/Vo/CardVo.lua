---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-01:33:47
---

local BaseVo = require("Game.Core.BaseVo")
---@class Game.Modules.Card.Vo.CardVo : Game.Core.BaseVo
---@field New fun(cardName:string):Game.Modules.Card.Vo.CardVo
---@field cardInfo CardInfo
---@field id string
---@field active boolean
---@field level number 等级
---@field star number 星级
---@field rank number 品阶
---@field ce number 战力
---@field camp Camp 阵营 所属阵营
---@field layoutIndex number
local CardVo = class("Module.Card.Vo.CardVo",BaseVo)

---@param card table
function CardVo:Ctor(card)
    if card then
        self:Init(card)
    end
end

---@param card table
function CardVo:Init(card)
    self.cardInfo = CardConfig.Get(card.cardId)
    self.id = card.id
    self.active = card.active
    self.level = card.level
    self.star = card.star
    self.rank = card.rank
    self.ce = card.ce
    self.camp = card.camp
    self.layoutIndex = card.layoutIndex
end

return CardVo
