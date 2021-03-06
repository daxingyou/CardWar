---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/5/21 22:58
---

local BaseBehavior = require('Game.Modules.Common.Behavior.BaseBehavior')
local HeroBehavior = require('Game.Modules.Battle.Behaviors.HeroBehavior')

---@class Game.Modules.Battle.Behaviors.MainHeroBehavior : Game.Modules.Battle.Behaviors.HeroBehavior
---@field New fun() : Game.Modules.Battle.Behaviors.MainHeroBehavior
---@field isAreaActive boolean
local MainHeroBehavior = class("Game.Modules.Battle.Behaviors.MainHeroBehavior",HeroBehavior)

---@param hero Game.Modules.Battle.Items.MainHero
function MainHeroBehavior:Ctor(hero)
    MainHeroBehavior.super.Ctor(self, hero)

    self:AppendBehavior(self:EnterArea(), "MainHeroBehavior EnterArea")
    self:AppendBehavior(self:MoveToArea(), "MainHeroBehavior MoveToArea")
    self:AppendBehavior(self:SearchTarget(), "MainHeroBehavior SearchTarget")
    self:AppendBehavior(self:MoveToTarget(), "MainHeroBehavior MoveToTarget")
    self:AppendBehavior(self:AttackUntilTargetDead(), "MainHeroBehavior AttackUntilTargetDead")
end

function MainHeroBehavior:Run()
    MainHeroBehavior.super.Run(self)
    self.hero:UpdateNode()
end

--移动到刷怪区域
function MainHeroBehavior:EnterArea()
    local behavior = self:CreateBehavior()

    behavior:AppendState(Handler.New(function()
        self.currArea = World.battleBehavior:GetCurrArea()

        self:NextState()
    end, self), "MainHeroBehavior EnterArea")

    return behavior
end

--移动到刷怪区域
function MainHeroBehavior:MoveToArea()
    local behavior = self:CreateBehavior()

    behavior:AppendState(Handler.New(self.DoMoveToArea, self))

    return behavior
end

function MainHeroBehavior:DoMoveToArea()
    if self.isAreaActive then
        self:NextState()
    else
        --self:Debug("MainHeroBehavior:DoMoveToArea")
        local tagNode = AStarTools.GetRectNearestNode(self.currArea.areaRect, self.hero.node)
        local tagPos = tagNode.worldPosition
        self.hero:PlayRun()
        self.autoMove:SmoothMove(tagPos, Handler.New(self.OnMoveToAreaEnd,self))
    end
end

function MainHeroBehavior:OnMoveToAreaEnd()
    self.currArea:Active()
    self.isAreaActive = true
    --self:Debug("MainHeroBehavior:OnMoveToAreaEnd")
    self.hero:PlayIdle()
    self:NextState()
end

--一轮攻击开始
---@param behavior Game.Modules.Common.Behavior.BaseBehavior
function MainHeroBehavior:AttackStart(behavior)
    behavior:AppendState(Handler.New(function()
        self:Debug("MainHeroBehavior AttackStart")
        if self:isTargetAttackValid() then
            --self:Debug("AttackStart")
            behavior:NextState()
        else
            self:NextState()
        end
    end, self))
end

--攻击单个目标知道目标死亡
function MainHeroBehavior:AttackUntilTargetDead()
    local behavior = self:CreateBehavior()

    local skills = self.hero.heroInfo.skills

    self:AttackStart(behavior)
    self:AppendSkill(behavior, skills[1])
    self:AppendSkill(behavior, skills[2])
    self:AppendSkill(behavior, skills[3])
    self:AttackEnd(behavior)

    return behavior
end

function MainHeroBehavior:Debug(msg)
    print(string.format("<color=#FFFF00FF> [%s-%s] </color>%s",self.gameObject.name, self.fastLuaBehavior.id, msg))
end

function MainHeroBehavior:NextState()
    MainHeroBehavior.super.NextState(self)
end

function MainHeroBehavior:Dispose()
    MainHeroBehavior.super.Dispose(self)
end

return MainHeroBehavior