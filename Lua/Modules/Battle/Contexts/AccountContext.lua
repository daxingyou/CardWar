---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/4/9 14:38
--- 攻击结算上下文
---

--伤害信息
---@class HurtInfo
---@field atker Game.Modules.Battle.Vo.BattleUnitVo
---@field defer Game.Modules.Battle.Vo.BattleUnitVo
---@field isHelpful boolean
---@field accountId string
---@field deferCamp Camp
---@field deferLayoutIndex number
---@field deferIsDead boolean
---@field dam number     伤害
---@field critDam number 暴击伤害
---@field atk number     攻击
---@field def number     防御
---@field crit number    暴击倍数
---@field miss boolean 是否命中
---@field acc number

local PoolVo = require("Game.Modules.Common.Pools.PoolObject")
---@class Game.Modules.World.Contexts.AccountContext : Game.Modules.Common.Pools.PoolObject
---@field New fun():Game.Modules.World.Contexts.AccountContext
---@field isReportMode boolean 录制模式
---@field battleUnit Game.Modules.World.Items.BattleUnit 攻击者
---@field targetList table<number, Game.Modules.World.Items.BattleUnit> 目标
---@field accountTargetList table<number, Game.Modules.World.Items.BattleUnit> 已经被结算的目标
---@field account AccountInfo
local AccountContext = class("Game.Modules.World.Contexts.AccountContext", PoolVo)

local Sid = 1

function AccountContext:Ctor()
    self.accountTargetList = List.New()
end

---@param skillVo Game.Modules.Battle.Vo.SkillVo
---@param attacker Game.Modules.World.Items.Avatar
---@param account AccountInfo
function AccountContext:Init(skillVo, attacker, account)
    self.id = Sid
    Sid = Sid + 1
    self.battleUnit = attacker
    self.account = account
    self.skillVo = skillVo
end

--开始
function AccountContext:Start(gridSelect)
    gridSelect = gridSelect or self.account.gridSelect
    local targetCamp = BattleUtils.GetTargetCamp(gridSelect, self.battleUnit) --对立阵营
    local targetGridList = GridUtils.GetTargetCampAndGrids(gridSelect, targetCamp, self.battleUnit)
    self.targetList = self.battleUnit.context.battleLayout:GetTargetList(targetCamp, targetGridList)
end

--统一结算
function AccountContext:ExecuteAccount()
    for i = 1, #self.targetList do
        self:OnAccount(self.targetList[i])
    end
end

--是否被结算过
function AccountContext:HasAccount(target)
    return self.accountTargetList:Contain(target)
end

--单个目标结算
---@param target Game.Modules.World.Items.BattleUnit
function AccountContext:OnAccount(target)
    if target:IsDead() then
        --target:_debug("target is be dead. can not be account")
    else
        --target:_debug("target is be account")
        self.accountTargetList:Add(target)
        self:DamageAccount(self.skillVo, self.account, target)
        --检查目标是否死亡
        self.battleUnit.accountCtrl:OnCheckDead(self.skillVo, target)
    end
end

--最终伤害结算
---@param target Game.Modules.World.Items.BattleUnit
---@param skillVo Game.Modules.Battle.Vo.SkillVo
---@param account AccountInfo
function AccountContext:DamageAccount(skillVo, account, target)
    --是否增益结算 例如加血  上buff等
    local isHelpful = account.targetMode == TargetMode.Self or account.targetMode == TargetMode.Friend
    local battleUnitVo = self.battleUnit.battleUnitVo
    local minDam = 1
    local unitAttribute = battleUnitVo.attributeBase --单位属性
    local hurtInfo = {} ---@type HurtInfo
    hurtInfo.atker = self.battleUnit
    hurtInfo.defer = target
    hurtInfo.isHelpful = isHelpful
    --伤害计算 (技能提供伤害*技能等级+面板魔法/物理攻击*技能倍率)
    if skillVo.skillInfo.attackType == AttackType.Physic then
        hurtInfo.atk = skillVo.skillInfo.damage * skillVo.level + unitAttribute.p_atk * (skillVo.skillInfo.damageAdd + 1) * (account.damageRatio / 1)
        hurtInfo.def = target.battleUnitVo.attributeBase.p_def
        hurtInfo.crit = (math.random() < unitAttribute.p_crit) and 2 or 1 --暴击
    else
        hurtInfo.atk = skillVo.skillInfo.damage * skillVo.level + unitAttribute.m_atk * (skillVo.skillInfo.damageAdd + 1) * (account.damageRatio / 1)
        hurtInfo.def = target.battleUnitVo.attributeBase.m_def
        hurtInfo.crit = (math.random() < unitAttribute.m_crit) and 2 or 1 --暴击
    end
    --伤害=攻击力/ ( 1 +防御力/ 100 )
    hurtInfo.dam = math.max(minDam, hurtInfo.atk / (1 + hurtInfo.def / 100))
    hurtInfo.acc = math.random() --命中率
    local isMiss = false
    --计算闪避
    --local signet = target.signetMap[self.battleUnit.sid .. "_" .. skillInfo.id]
    --if hurtInfo.acc > self.battleUnit.avatarInfo.acc
    --        or signet == SignetType.Dodge then
    --    isMiss = true
    --end
    --if signet ~= nil then
    --    target.performancePlayer:Play(account.signetPerformance,nil,self.battleUnit, account)
    --end

    if isMiss then
        hurtInfo.miss = true
        --print("miss")
        if target then
            target:DoHurt(hurtInfo)
            target.battleUnitVo:DamageRecoveryTP(hurtInfo.dam)--恢复Tp
        end
        return
    end
    hurtInfo.miss = false
    if target then
        target.battleUnitVo:DamageRecoveryTP(hurtInfo.dam)--恢复Tp
        if isHelpful then
            target.battleUnitVo.curHp = math.min(target.battleUnitVo.curHp + hurtInfo.dam, target.battleUnitVo.maxHp)
        else
            target.battleUnitVo.curHp = math.max(0,target.battleUnitVo.curHp - hurtInfo.dam)
        end
    end
    if self.isReportMode then --录制模式
        print(string.format("Atker:<color=#FFFFFFFF>%s</color> atk Defer:<color=#FFFFFFFF>%s</color> - dam:<color=#FFFF00FF>%s</color>",
                hurtInfo.atker.battleUnitVo.battleUnitInfo.name,
                hurtInfo.defer.battleUnitVo.battleUnitInfo.name,
                hurtInfo.dam))
        if target:IsDead() then
            print(string.format("<color=#FFFFFFFF>%s</color> is Dead",target.battleUnitVo.battleUnitInfo.name))
        end
    else
        self:DisplayHurt(target, hurtInfo, isHelpful)
    end
end

function AccountContext:DisplayHurt(target, hurtInfo, isHelpful)
    if target then
        if isHelpful then
            target.battleUnitVo.curHp = math.min(target.battleUnitVo.curHp + hurtInfo.dam, target.battleUnitVo.maxHp)
            target:DoHurt(hurtInfo)
        else
            target.battleUnitVo.curHp = math.max(0,target.battleUnitVo.curHp - hurtInfo.dam)
            target:DoHurt(hurtInfo)
            target:PlayIdle()
            target:PlayHit()
            --target.soundGroup:Play(skillInfo.hitSound)
        end
        --self:HurtPerformance(target, skillInfo, account)
    else
        --无目标结算
    end
end

--受击表现
---@param target Game.Modules.World.Items.Avatar
---@param skillInfo SkillInfo
---@param account AccountInfo
function AccountContext:HurtPerformance(target, skillInfo, account)
    target.performancePlayer:Play(account.targetPerformance,nil,self.battleUnit)
    --buff 计算
    if not StringUtil.IsEmpty(account.buffer) then
        target.bufferWidget:Add(account.buffer)
    end
    if not StringUtil.IsEmpty(skillInfo.hitEffect) then
        target.effectWidget:Play(skillInfo.hitEffect, target)
        target.specialEffect:PlaySurround() --播放受击包围效果
    end
end

--结束
function AccountContext:End()
    self:Dispose()
end

function AccountContext:Dispose()
    self.effect = nil
    self.isReportMode = false
    self.accountTargetList:Clear()
    AccountContextPool:Store(self)
end

return AccountContext