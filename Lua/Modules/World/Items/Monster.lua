---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/5/6 10:53
---

local MonsterStrategy = require("Module.World.Behaviors.Strategy.MonsterStrategy")
local GridMonsterStrategy = require("Module.Battle.Behaviors.Strategy.GridMonsterStrategy")
local BattleItemEvents = require("Game.Modules.Battle.Events.BattleItemEvents")
local MonsterBaseBehavior = require("Module.World.Behaviors.MonsterBaseBehavior")
local AvatarGridBehavior = require("Module.Battle.Behaviors.AvatarGridBehavior")
local Avatar = require("Module.World.Items.Avatar")

---@class Module.World.Items.Monster : Game.Modules.World.Items.Avatar
---@field New fun(monsterInfo:Module.World.Vo.MonsterVo, context:WorldContext) : Module.World.Items.Monster
---@field monsterInfo Module.World.Vo.MonsterVo
---@field behavior Module.World.Behaviors.MonsterBaseBehavior
local Monster = class("Module.World.Items.Monster", Avatar)

---@param monsterInfo Module.World.Vo.MonsterVo
---@param context WorldContext
function Monster:Ctor(monsterInfo,context)
    self:SetContext(context)
    self.monsterInfo = monsterInfo
    --self.monsterInfo.scared = self:CalcScared() -- 检测战力差，是否会被碾压
    self.monsterInfo.scared = false -- 屏蔽碾压机制
    Monster.super.Ctor(self, monsterInfo)
end

--重置属性
function Monster:ResetAttr()
    local maxHp = math.random(self.avatarInfo.hp_min, self.avatarInfo.hp_max)
    self.monsterInfo.curHp = maxHp
    self.monsterInfo.maxHp = maxHp
    if self.avatarInfo.avatarType == AvatarType.Collect then
        self.monsterInfo.curCollectTime = self.avatarInfo.collectTime
    end
    --for i = 1, #self.monsterInfo.skills do
    --    local skill = self.monsterInfo.skills[i]
    --    skill.animSpeed = skill.animSpeed or 1
    --end
end

function Monster:LoadObject()
    if self.avatarInfo.prefabUrl then
        self.renderObj = self.context.pool:CreateObjectByPool(self.avatarInfo.prefabUrl)
        self.renderObj.transform:SetParent(self.transform)
        self.renderObj:ResetTransform()
        self:OnRenderObjInit()
    end
end

function Monster:OnRenderObjInit()
    Monster.super.OnRenderObjInit(self)
    --self:SetBehaviorEnabled(true)
    if self.context.mode == BattleMode.Idle then
        self:SetLayer(Layers.Name.Monster)
    elseif self.context.mode == BattleMode.Grid then
        self:SetLayer(Layers.Name.Monster)
        --self:CreateGrid()
    else
        self:SetLayer(Layers.Name.Monster)
    end
    --下面应该是特殊处理
    if self.avatarInfo.id == "BlackDragon" then
        self.renderObj.transform.localEulerAngles = Vector3.New(0, 90, 0)
    end
end

--出生效果
function Monster:Born(callback)
    if not StringUtil.IsEmpty(self.avatarInfo.bornPerfomance) then
        self:SetRenderEnabled(false)
        self.performancePlayer:Play(self.avatarInfo.bornPerfomance, function()
            self:OnBorn(callback)
        end)
    elseif not StringUtil.IsEmpty(self.avatarInfo.bornEffect) then
        self:SetRenderEnabled(false)
        local bornEffectInfo = EffectConfig.Get(self.avatarInfo.bornEffect)
        self:PlayIdle()
        self.effectWidget:Play(self.avatarInfo.bornEffect, self)
        self.effectWidget:CreateDelay(bornEffectInfo.duration * 0.3,function()
            self:PlayIdle()
            self:SetRenderEnabled(true)
        end)
        self.effectWidget:CreateDelay(bornEffectInfo.duration,function()
            self:OnBorn(callback)
        end)
    else --无任何出生效果
        self:PlayIdle()
        self:SetRenderEnabled(true)
        self:OnBorn(callback)
    end
end

function Monster:OnBorn(callback)
    BattleItemEvents.DispatchItemEvent(BattleItemEvents.BattleItemBorn, self)
    if callback then
        callback()
    end
end

function Monster:SetRenderEnabled(enabled)
    self.renderObj:SetActive(enabled)
    --if not enabled then
    --    logError("SetRenderEnabled")
    --end
    if self.shadow then
        self.shadow:SetActive(enabled)
    end
end

function Monster:SetBehaviorEnabled(enabled)
    if not self.behavior then
        if self.context.mode == BattleMode.Idle then
            self.strategy = MonsterStrategy.New(self)
            self.behavior = MonsterBaseBehavior.New(self)
        elseif self.context.mode == BattleMode.Camp then
            self.strategy = MonsterStrategy.New(self)
            self.behavior = MonsterBaseBehavior.New(self)
        else
            self.strategy = GridMonsterStrategy.New(self)
            self.behavior = AvatarGridBehavior.New(self)
        end
    end
    if enabled then
        if self:IsDead() then
            --logError("This item is dead, can not set behavior enabled")
            return
        end
        --self.isMoving = true
        --self:UpdateAroundPos()
        --logError("SetBehaviorEnabled true")
        self.behavior:Play()
    else
        self.behavior:Stop()
    end
end

function Monster:PlayHit(callback)

end

function Monster:PlayDead()
    --if self.avatarInfo.quality == MonsterQuality.Boss then
    --    --死亡特写
    --    --self.effectWidget:Play("fx_die_boom",self)
    --    self.specialEffect:PlaySurround(0.8)
    --    Time.timeScale = 0.2
    --end
    --if self.context.mode == BattleMode.Idle then
    --    self:DropCheck(hurtInfo.atker) --放置模式才有掉落
    --end
    --if hurtInfo.crit > 1 and self.avatarInfo.quality == MonsterQuality.Normal then --暴击击飞
    --if self.monsterInfo.scared == true then --碾压击飞
    --    self:PlayIdle()
    --    self.animCtrl:Rebound( 0.8, Handler.New(self.OnMonsterDead, self))
    --    --logWarning(string.format("monster scared then fly"));
    --else
    local callback = Handler.New(self.OnMonsterDead, self)
    self.animCtrl:PlayAnim(self.avatarInfo.animDead)
    local length = self.animCtrl:GetAnimLength(self.avatarInfo.animDead)
    if self.avatarInfo.quality == MonsterQuality.Boss then
        self.animCtrl:CreateDelay(length, function()
            callback:Execute()
            end)
    else
        self.animCtrl:CreateDelay(length * 0.3, function()
            callback:Execute()
        end)
    end
end

---@field callBack function
function Monster:PlayDeadChapter(callBack)
    self.animCtrl:PlayAnim(self.avatarInfo.animDead)
    local length = self.animCtrl:GetAnimLength(self.avatarInfo.animDead)
    self.animCtrl:CreateDelay(length, function()
        self:SetRenderEnabled(false)
        if callBack then callBack() end
    end)
end

function Monster:DropCheck(killer)
    local dropIndex = 0
    for i = 1, #self.avatarInfo.drops do
        local dropId = self.avatarInfo.drops[i]
        local drop = DropItemDB.Get(dropId)
        local random = math.random()
        if random <= drop.probability then
            local dropNumInterval = drop.num
            local dropNums = string.split(dropNumInterval, "-")
            if dropNums and #dropNums > 0 then
                local minNum, maxNum = tonumber(dropNums[1]), tonumber(dropNums[2])
                local dropNum = maxNum and maxNum > 0 and math.random(minNum, maxNum) or minNum
                --TODO 执行掉落逻辑
                local itemDB = ItemDB.Get(drop.itemId)
                if itemDB.type == ItemType.BossTrace then           -- Boss踪迹
                    local event = {}
                    event.type = BattleEvents.DropBossTrace
                    event.monster = self
                    event.dropNum = dropNum
                    BattleEvents.Dispatch(event)
                elseif itemDB.type == ItemType.ExplorePoint then    -- 探索点数
                    if killer and killer.AddAreaFind then
                        killer:AddAreaFind(dropNum)
                    end
                else
                    --if self.avatarInfo.avatarType == AvatarType.Collect
                    --and self.avatarInfo.dropType ~= DropType.blowout
                    --then
                    --    FlyGainReward.GetInstance():AddReward(drop.itemId, dropNum)
                    --    World.model.itemModel:AddItem(drop.itemId, dropNum)
                    --else
                        for i = 1, dropNum do
                            local delay
                            if self.avatarInfo.dropType == DropType.blowout then
                                delay = dropIndex * 0.1
                                dropIndex = dropIndex + 1
                            end
                            local drop = DropItem.New(drop, killer, self:IsBoss() == true and 4 or 1, delay)
                            drop.gameObject.transform.position = self.gameObject.transform.position
                            self.context.dropList:Add(drop)
                        end
                    --end
                end
            end
        end
    end
end

--怪物死亡时
function Monster:OnMonsterDead()
    --if self.avatarInfo.quality == MonsterQuality.Boss then
    --    local sequence = self.animCtrl:CreateSequence()
    --    --sequence:AppendInterval(0.5)
    --    sequence:Append(Tool.DOTweenFloat(0.2,1,0.5,function(value)
    --        Time.timeScale = value
    --    end,function()
    --        Time.timeScale = 1
    --    end))
    --    sequence:AppendCallback(function()
    --        Time.timeScale = 1
    --        local event = {}
    --        event.type = ItemEvents.WorldBossDead
    --        event.monster = self
    --        BattleEvents.Dispatch(event)
    --        --vmgr:LoadView(ViewConfig.BossRstRank)
    --    end)
    --end
    --local event = {}
    --event.type = ItemEvents.MonsterDead
    --event.monster = self
    --ItemEvents.Dispatch(event)
    self:SetRenderEnabled(false)
    if StringUtil.IsEmpty(self.avatarInfo.deadEffect) then
        --print("OnMonsterDead Over 111  " .. self.gameObject.name)
        self:OnMonsterDeadOver()
    else
        --死亡爆炸
        self.effectWidget:Play(self.avatarInfo.deadEffect, self, function()
            --print("OnMonsterDead Over 222  " .. self.gameObject.name)
            self:OnMonsterDeadOver()
        end)
    end

    if self.hpBar then
        self.hpBar:Dispose()
        self.hpBar = nil
    end
end

function Monster:OnMonsterDeadOver()
    self.deadOver = true
end

-- 检测战力差，是否会被碾压
function Monster:CalcScared()
    if self.avatarInfo.quality == MonsterQuality.Normal then
        local heroCombatPower = World.mainHero.avatarInfo.combatPower
        local monsterCombatPower = self.avatarInfo.combatPower
        return heroCombatPower > monsterCombatPower
    end
end

function Monster:OnDead()
    Monster.super.OnDead(self)
    --if self.animCtrl then
    --    self.animCtrl:Clear()
    --end
    if self.behavior then
        self.behavior:Dispose()
    end
    if self.cc then
        self.cc.enabled = false
    end
    --if self.effectWidget then
    --    self.effectWidget:RemoveSingCircle()
    --end
    --print("Monster:OnDead " .. self.gameObject.name )
    local event = {}
    event.type = BattleItemEvents.BattleItemDead
    event.target = self
    BattleItemEvents.Dispatch(event)
    if self.layoutGrid then
        self.layoutGrid:ClearOwner()
    end
end

--回收
function Monster:Recovery()
    Monster.super.Recovery(self)
    local pool = self.context.pool:GetObjectPool(self.avatarInfo.prefabUrl)
    --把影子换回去
    if not isnull(self.shadow)  then
        self.shadow.transform:SetParent(self.renderObj.transform)
    end
    pool:Store(self.renderObj)
end

function Monster:Dispose()
    self:Recovery()
    Monster.super.Dispose(self)
    if self.behavior then
        self.behavior:Dispose()
    end
    if self.effectWidget then
        self.effectWidget:Dispose()
    end
    self.monsterInfo:Dispose()
    self.monsterInfo = nil
    --if self.gameObject.transform.childCount > 0 then
    --    logError("You must recovery the renderObj")
    --end
    Destroy(self.gameObject)
end

return Monster