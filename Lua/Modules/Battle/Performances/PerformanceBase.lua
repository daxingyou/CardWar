---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/4/18 23:00
---

local Widget = require("Game.Modules.Common.Components.Widget")
---@class Game.Modules.Battle.Performances.PerformanceBase : Game.Modules.Common.Components.Widget
---@field battleUnit Game.Modules.World.Items.BattleUnit
---@field performanceInfo PerformanceInfo
---@field args table<number, any>
---@field param table<string, any>
---@field overCallback fun()
---@field startTime number
---@field duration number
local PerformanceBase = class("Game.Modules.Battle.Performances.PerformanceBase",Widget)

---@param battleUnit Game.Modules.World.Items.BattleUnit
---@param performanceInfo PerformanceInfo
function PerformanceBase:Ctor(battleUnit, performanceInfo)
    self.battleUnit = battleUnit
    self.performanceInfo = performanceInfo
    self.battleUnit:_debug("Play Performance " .. performanceInfo.id)
    PerformanceBase.super.Ctor(self, battleUnit.gameObject)
end

---@param overCallback fun()
function PerformanceBase:Play(overCallback, ...)
    self.param = Tool.String2Map(self.performanceInfo.param) -- 配表参数
    self.args = {...} -- 运行时传递的参数

    self.overCallback = overCallback
    self:StartCoroutine(function()
        if self.performanceInfo.mode ~= PerformanceMode.Buffer and self.performanceInfo.delay > 0 then
            coroutine.wait(self.performanceInfo.delay)
        end
        self.startTime = Time.time
        local sequence1 = self:CreateSequence()
        if self:OnBeginPerformance(sequence1) then
            self:OnWaitPerformance(sequence1) --阻塞
            local sequence2 = self:CreateSequence()
            self:OnPerformanceStop(sequence2, true)
        else
            self:OnPerformanceStop(sequence1, false)
        end


    end)
end

---@param sequence DG.Tweening.Sequence
function PerformanceBase:OnWaitPerformance(sequence)
    local sequenceOver = false
    sequence:AppendCallback(function()
        sequenceOver = true
    end)
    --等待开始阶段结束
    while not sequenceOver do
        coroutine.step(1)
    end
    if self.performanceInfo.mode == PerformanceMode.Buffer then
        --buffer的持续时间由buffer决定
        self.duration = self.args[1]
        while Time.time - self.startTime < self.duration do
            coroutine.step(1)
        end
    end
end

function PerformanceBase:CheckGhostEffect()
    --添加残影判断
    self.battleUnit.specialEffect:CheckGhostEffect(self.performanceInfo.ghostEffect)
end

---@param sequence DG.Tweening.Sequence
---@return boolean 是否执行下去
function PerformanceBase:OnBeginPerformance(sequence)
    --间隔触发表现
    if self.performanceInfo.interval > 0 then
        self.timer = Timer.New(self.performanceInfo.interval, Handler.Get(self.OnDisplayingPerformance,self, sequence))
        self.timer:Start()
    end
    return true
end

--间隔触发表现
---@param sequence DG.Tweening.Sequence
function PerformanceBase:OnDisplayingPerformance(sequence)

end

--表现结束
---@param sequence DG.Tweening.Sequence
---@param success boolean 是否可执行
function PerformanceBase:OnPerformanceStop(sequence, success)
    if self.overCallback then
        sequence:AppendCallback(function()
            self.overCallback(success)
        end)
    end
end

---@param sequence DG.Tweening.Sequence
function PerformanceBase:AppendEffect(sequence, effectName)
    if not StringUtil.IsEmpty(effectName) then
        sequence:AppendCallback(function()
            self.beginEffect = self.battleUnit.effectWidget:Play(effectName, self.battleUnit)
        end)
    end
end

---@param sequence DG.Tweening.Sequence
function PerformanceBase:AppendSound(sequence, soundName)
    if not StringUtil.IsEmpty(soundName) then
        sequence:AppendCallback(function()
            SoundPlayer:Play(soundName)
        end)
    end
end

---@param sequence DG.Tweening.Sequence
function PerformanceBase:AppendShake(sequence, shakeName)
    if not StringUtil.IsEmpty(shakeName) then
        sequence:AppendCallback(function()
            self.battleUnit.context.attachCamera:ShakeCamera(CameraShakeConfig.Get(shakeName))
        end)
    end
end

--打断某个状态
function PerformanceBase:BreakState(stateName)

end

function PerformanceBase:Dispose()
    PerformanceBase.super.Dispose(self)
    self.overCallback = nil
    if self.timer then
        self.timer:Dispose()
    end
    --if self.performanceInfo.ghostEffect and self.performanceInfo.ghostEffect.type then
    --    self.battleUnit.specialEffect:EndGhostEffect()
    --end
    --if not StringUtil.IsEmpty(self.performanceInfo.beginEffect) then
    --    self.battleUnit.effectWidget:RemoveEffect(self.beginEffect, self.battleUnit)
    --end
end

return PerformanceBase