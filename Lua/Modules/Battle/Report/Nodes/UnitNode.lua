---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/7/5 0:53
--- 战斗单位
---

---@class Game.Modules.Battle.Report.Nodes.UnitNode
---@field New fun():Game.Modules.Battle.Report.Nodes.UnitNode
---@field sid number
---@field cardId number
---@field camp string
---@field layoutIndex number
---@field rank number
---@field level number
---@field star number
local UnitNode = class("Game.Modules.Battle.Report.Nodes.UnitNode");

function UnitNode:Ctor(data)
    self.sid = data.sid
    self.cardId = data.cardId
    self.camp = data.camp
    self.layoutIndex = data.layoutIndex
    self.rank = data.rank
    self.level = data.level
    self.star = data.star
end

return UnitNode