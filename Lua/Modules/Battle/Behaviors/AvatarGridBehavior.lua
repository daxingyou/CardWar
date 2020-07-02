---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/2/20 16:59
--- 九宫格玩法-单位的基本行为
---

local BattleEvent = require("Game.Modules.Battle.Events.BattleEvents")
local BaseBehavior = require("Game.Modules.Common.Behavior.BaseBehavior")

---@class Game.Modules.Battle.Behaviors.AvatarGridBehavior : Game.Modules.Common.Behavior.BaseBehavior
---@field battleUnit Game.Modules.World.Items.BattleUnit
---@field target Game.Modules.World.Items.Avatar
---@field currArea Game.Modules.Battle.Layouts.GridArea
local AvatarGridBehavior = class("Game.Modules.Battle.Behaviors.AvatarGridBehavior",BaseBehavior)

---@param battleUnit Game.Modules.World.Items.BattleUnit
function AvatarGridBehavior:Ctor(battleUnit)
    AvatarGridBehavior.super.Ctor(self, battleUnit.gameObject)
    self.battleUnit = battleUnit
    local name = self.battleUnit.gameObject.name
    self:AppendBehavior(self:MoveToArea(),      name .. " AvatarGridBehavior MoveToArea")
    self:AppendBehavior(self:SelectSkill(),    name .. " AvatarGridBehavior SearchTarget")
    --self:AppendBehavior(self:MoveToTarget(),    name .. " AvatarGridBehavior MoveToTarget")
    self:AppendBehavior(self:AttackOnce(),     name .. " AvatarGridBehavior AttackOnce")
end

--目标的有效性
function AvatarGridBehavior:TargetIsValid(target)
    return BattleUtils.TargetValid(target)
end

--目标的有效性
function AvatarGridBehavior:isTargetValid()
    return BattleUtils.TargetValid(self.target)
end

--目标的是否符合被攻击的有效性
function AvatarGridBehavior:isTargetAttackValid()
    return BattleUtils.TargetAttackValid(self.target)
end

function AvatarGridBehavior:MoveToArea()
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        --self:_debug("AvatarGridBehavior MoveToArea")
        local currArea = self.battleUnit.context.battleBehavior:GetCurrArea()
        if self.currArea ~= nil and self.currArea == currArea then
            --self:_debug("Area not change")
        else
            --self:_debug("Area has changed")
            self.currArea = currArea
        end
        self.stateMachine:NextState()
    end)
    return behavior
end

function AvatarGridBehavior:SelectSkill()
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        --self:_debug("AvatarGridBehavior SelectSkill")
    end, function()
        --self:_debug("AvatarGridBehavior SelectSkill")
        if self.currArea and self.currArea.isActive then
            self.battleUnit.strategy:AutoSelectSkill()
            self.stateMachine:NextState()
        end
    end)
    return behavior
end

function AvatarGridBehavior:AttackOnce()
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        --self:_debug("AvatarGridBehavior AttackStart")
        BattleEvent.DispatchItemEvent(BattleEvent.EnterAttack, self.battleUnit)
        self:AppendSkill(behavior)
    end)
    self:AttackEnd(behavior)
    return behavior
end

---@param behavior Game.Modules.Common.Behavior.BaseBehavior
function AvatarGridBehavior:AppendSkill(behavior)
    local skill = self.battleUnit.strategy.currSelectedSkill
    self.battleUnit.strategy.currSelectedSkill = nil
    if skill == nil then
        self:_debug("当前没有可以使用的技能")
        behavior:NextState()
        return
    end
    local canUse = true
    if canUse then
        --self.battleUnit:EnterState(StateName.Attacking)
        self:OnSkillUse(behavior, skill)
    else
        behavior:NextState()
    end
end

--技能释放
---@param behavior Game.Modules.Common.Behavior.BaseBehavior
---@param skill Game.Modules.Battle.Vo.SkillVo
function AvatarGridBehavior:OnSkillUse(behavior, skill)
    skill.startTime = Time.time --是否成功开始计时
    skill.useCount = skill.useCount + 1
    -- 伤害结算
    --if target and target.layoutGrid then
    --    target.layoutGrid:SetAttackSelect(true)
    --end
    --self.battleUnit:_debug(string.format("use skill:[%s]",skill.skillInfo.id))
    self.battleUnit.accountCtrl:Account(skill,
            Handler.New(function()
                behavior:NextState()

            end, self))
    -- 技能名展示
    if self.battleUnit.avatarInfo.avatarType == AvatarType.Hero
            and skill.skillInfo.skillType == SkillType.Skill
            and not StringUtil.IsEmpty(skill.skillInfo.name) then
        self.battleUnit:ShowSkillNameFly(skill.skillInfo.name)
    end
end

--一轮攻击结束
---@param behavior Game.Modules.Common.Behavior.BaseBehavior
function AvatarGridBehavior:AttackEnd(behavior)
    if self.battleUnit.avatarInfo.attackInterval and self.battleUnit.avatarInfo.attackInterval > 0 then
        --攻击间隔
        behavior:AppendState(function()
            self.battleUnit:PlayIdle()
            behavior:NextState()
        end)
        behavior:AppendInterval(self.battleUnit.avatarInfo.attackInterval)
    end
    behavior:AppendState(function()
        --self:_debug("AvatarGridBehavior AttackOnce Over")
        self.battleUnit:PlayIdle()
        BattleEvent.DispatchItemEvent(BattleEvent.ExitAttack, self.battleUnit)
        if self.target and self.target.layoutGrid then
            self.target.layoutGrid:SetAttackSelect(false)
        end
        self.battleUnit:BackToBorn()
        self:Stop()
    end)
end

return AvatarGridBehavior