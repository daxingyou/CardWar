---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/2/20 16:59
--- 九宫格玩法-单位的基本行为
---

local BattleItemEvents = require("Game.Modules.Battle.Events.BattleItemEvents")
local BattleEvent = require("Game.Modules.Battle.Events.BattleEvents")
local BaseBehavior = require("Game.Modules.Common.Behavior.BaseBehavior")

---@class Game.Modules.Battle.Behaviors.BattleUnitBehavior : Game.Modules.Common.Behavior.BaseBehavior
---@field battleUnit Game.Modules.World.Items.BattleUnit
---@field target Game.Modules.World.Items.Avatar
---@field currArea Game.Modules.Battle.Layouts.GridArea
---@field attackRound Game.Modules.Battle.Report.AttackRound --当前攻击回合
---@field deadItemList List | table<number, Game.Modules.World.Items.BattleUnit>
---@field hurtInfoMap table<string, table<number, Game.Modules.Battle.Report.ReportHurtInfo>>
local BattleUnitBehavior = class("Game.Modules.Battle.Behaviors.BattleUnitBehavior",BaseBehavior)

---@param battleUnit Game.Modules.World.Items.BattleUnit
function BattleUnitBehavior:Ctor(battleUnit)
    BattleUnitBehavior.super.Ctor(self, battleUnit.gameObject)
    self.battleUnit = battleUnit
    local name = self.battleUnit.gameObject.name
    self:AppendBehavior(self:OnAccountBegin(),      name .. " BattleUnitBehavior OnAccountBegin")
    self:AppendBehavior(self:OnAccountProcess(),    name .. " BattleUnitBehavior OnAccountProcess")
    self:AppendBehavior(self:OnAccountEnd(),        name .. " BattleUnitBehavior OnAccountEnd")

    --AddEventListener(BattleItemEvents, BattleItemEvents.AttackAccount, self.OnAttackAccount, self)
    --AddEventListener(BattleItemEvents, BattleItemEvents.AttackAccountEnd, self.OnAttackAccountEnd, self)

    self.deadItemList = List.New()
end

---@param attackRound Game.Modules.Battle.Report.AttackRound
function BattleUnitBehavior:Play(attackRound)
    BattleUnitBehavior.super.Play(self)
    self.attackRound = attackRound
    self.hurtInfoMap = self.attackRound.hurtInfoMap
end

function BattleUnitBehavior:OnAccountBegin()
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        local skillVo = self.attackRound.skill
        self.battleUnit:SetHudVisible(false)
        local tagPos = self.battleUnit.context.battleLayout.center
        self.battleUnit:PlayRun()
        self.battleUnit.transform:DOMove(tagPos, FRAME_TIME * 9 / self.battleUnit.context.battleSpeed):OnComplete(function()
            self.battleUnit:PlayIdle()
            self:NextState()
        end)
    end)
    return behavior
end

function BattleUnitBehavior:OnAccountProcess(skillVo)
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        local skillVo = self.attackRound.skill
        self.deadItemList:Clear()
        self.battleUnit.performancePlayer:Play(skillVo.skillInfo.performance,function()
            self:NextState()
        end, skillVo, self.attackRound)
    end)
    return behavior
end

function BattleUnitBehavior:OnAccountEnd()
    local behavior = self:CreateSubBehavior()
    behavior:AppendState(function()
        self.battleUnit:SetHudVisible(true)
        --self.battleUnit.context.battleLayout:SetAttackSelect(self.targetCamp, self.targetGridList, false)--设置选取效果
        self.battleUnit:BackToBorn()
        self.attackRound:RoundEnd()
        BattleEvent.DispatchItemEvent(BattleEvent.ExitAttack, self.battleUnit)
        self:Stop()
    end)
    return behavior
end

---@param accountInfo AccountInfo
function BattleUnitBehavior:OnAttackAccount(accountInfo)
    local hurtList = self.hurtInfoMap[accountInfo.id]
    if hurtList ~= nil then
        for i = 1, hurtList:Size() do
            local hurtInfo = hurtList[i]
            local battleUnit = self.battleUnit.context:GetBattleUnit(hurtInfo.defer.camp, hurtInfo.defer.layoutIndex)
            battleUnit:AccountHurt(hurtInfo)
            --self:_debug("Replay hurt info account:" .. hurtInfo.accountId)
            if battleUnit:IsDead() then
                self.deadItemList:Add(battleUnit)
                self:_debug(battleUnit.debugName .. " is Dead")
            else
                if hurtInfo.deferIsDead then
                    logError(battleUnit.debugName .. " is will Dead, but not")
                end
            end
        end
    else
        --logError("no hurt info with:" .. accountInfo.id)
    end
end

function BattleUnitBehavior:OnAttackAccountEnd()
    for i = 1, self.deadItemList:Size() do
        self.deadItemList[i]:OnDead()
        self:_debug(self.deadItemList[i].debugName .. " OnDead OnDead OnDead OnDead")
    end
    self.deadItemList:Clear()
end

function BattleUnitBehavior:Dispose()
    BattleUnitBehavior.super.Dispose(self)
    --RemoveEventListener(BattleItemEvents, BattleItemEvents.AttackAccount, self.OnAttackAccount, self)
end

return BattleUnitBehavior