---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/7/13 21:25
---

---@class Game.Modules.Battle.Report.UnitSnapshot
---@field New fun(battleUnitName, camp, layoutIndex) : Game.Modules.Battle.Report.UnitSnapshot
---@field battleUnitInfo BattleUnitInfo
---@field attribute Game.Modules.Battle.Vo.Attribute
---@field camp Camp 阵营 所属阵营
---@field layoutIndex number
---@field curHp number
---@field maxHp number
---@field curTp number
---@field maxTp number
local UnitSnapshot = class("Game.Modules.Battle.Report.UnitSnapshot");

function UnitSnapshot:Ctor(battleUnitName, camp, layoutIndex)
    self.battleUnitInfo = BattleUnitConfig.Get(battleUnitName)
    self.attribute = self.battleUnitInfo
    self.camp = camp
    self.layoutIndex = layoutIndex
end

--是否死亡
function UnitSnapshot:IsDead()
    return self.avatarVo.curHp <= 0
end

function UnitSnapshot:GetDebugName()
    return self.battleUnitInfo.name .. "_" .. self.camp .. "-" .. self.layoutIndex
end

return UnitSnapshot