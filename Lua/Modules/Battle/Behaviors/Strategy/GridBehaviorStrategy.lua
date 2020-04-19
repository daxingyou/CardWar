---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/2/25 9:54
--- 网格战斗策略
---

local BehaviorStrategyBase = require("Game.Modules.Battle.Behaviors.Strategy.BehaviorStrategyBase")

---@class Game.Modules.Battle.Behaviors.Strategy.GridBehaviorStrategy:Game.Modules.Battle.Behaviors.Strategy.BehaviorStrategyBase
---@field New fun(avatar : Game.Modules.World.Items.Avatar):Game.Modules.Battle.Behaviors.Strategy.GridBehaviorStrategy
---@field aiParam table<string, any> --AI参数
---@field skills table<number, Game.Modules.Battle.Vo.SkillVo>
---@field canUseList table<number, Game.Modules.Battle.Vo.SkillVo>
---@field currSelectedSkill Game.Modules.Battle.Vo.SkillVo 当前被选中的技能
---@field lastTarget Game.Modules.World.Items.Avatar
---@field lastTargetPos UnityEngine.Vector3
---@field currTargetAttackNum number 当前目标被攻击的次数
---@field targetStartAttackTime number 当前目标被攻击的时间
local GridBehaviorStrategy = class("Game.Modules.Battle.Behaviors.Strategy.GridBehaviorStrategy",BehaviorStrategyBase)


---@param avatar Game.Modules.World.Items.Avatar
function GridBehaviorStrategy:Ctor(avatar)
    GridBehaviorStrategy.super.Ctor(self, avatar)
end

---@return Game.Modules.Battle.Vo.SkillVo
function GridBehaviorStrategy:AutoSelectSkill()
    return GridBehaviorStrategy.super.AutoSelectSkill(self)
end

---@return Game.Modules.World.Items.Avatar
function GridBehaviorStrategy:AutoSelectTarget()
    local opposeCamp = BattleUtils.GetOpposeCamp(self.battleUnit.battleUnitVo.camp) --对立阵营
    --首先攻击对位
    local targetGrid = self.battleUnit.context.battleLayout:GetGridByCol(opposeCamp, self.battleUnit.layoutIndex)
    if targetGrid == nil then --再现在最表面的
        targetGrid = self.battleUnit.context.battleLayout:GetFirstGrid(opposeCamp)
    end
    if targetGrid then
        return targetGrid.owner
    else
        return nil
    end
end

--目标优先规则
---@return Game.Modules.World.Items.Avatar
function GridBehaviorStrategy:FetchTarget()

end

return GridBehaviorStrategy