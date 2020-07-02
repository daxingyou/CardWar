---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-20:24:22
---

local Attribute = require("Game.Modules.Battle.Vo.Attribute")
local AvatarVo = require("Game.Modules.World.Vo.AvatarVo")
---@class Game.Modules.Battle.Vo.BattleUnitVo : Game.Modules.World.Vo.AvatarVo
---@field New fun():Game.Modules.Battle.Vo.BattleUnitVo
---@field battleUnitInfo BattleUnitInfo
---@field attributeBase Game.Modules.Battle.Vo.Attribute
---@field skills table<number, Game.Modules.Battle.Vo.SkillVo>
---@field normalSkill Game.Modules.Battle.Vo.SkillVo
---@field camp Camp 阵营 所属阵营
---@field atk number
---@field def number
---@field curHp number
---@field maxHp number
---@field curTp number
---@field maxTp number
local BattleUnitVo = class("Game.Modules.Battle.Vo.BattleUnitVo",AvatarVo)

function BattleUnitVo:Ctor()
    BattleUnitVo.super:Ctor(self)
    self.skills = {}
end

function BattleUnitVo:Init(battleUnitName)
    self.battleUnitInfo = BattleUnitConfig.Get(battleUnitName)
    self.attributeBase = self.battleUnitInfo
    BattleUnitVo.super.Init(self, self.battleUnitInfo.avatarName)
    --local skillInfoList = SkillConfig.GetList(battleUnitName)
    local skillInfoList = SkillConfig.GetList(self.battleUnitInfo.avatarName)--测试时按模型来选技能
    if skillInfoList then
        for i = 1, #skillInfoList do
            local skill = SkillVoPool:Get() ---@type Game.Modules.Battle.Vo.SkillVo
            skill:Init(skillInfoList[i])
            if skill.skillInfo.skillType == SkillType.Normal then
                self.normalSkill = skill
            end
            table.insert(self.skills, skill)
        end
    else
        logError("There is no skill with battle unit " .. battleUnitName)
    end
    self:Reset()
end

--伤害恢复tp
--实际获得 TP = 基础值 * (100 + TP 上升) / 100
--行动时获取TP = 90 * (1 + TP上升 / 100)
--被伤害时获取TP = (损失血量 / 最大血量) * 500 * (1 + TP上升 / 100)
---@param dam number 伤害
function BattleUnitVo:DamageRecoveryTP(dam)
    local tpRecover = (dam / self.maxHp) * 500 * (1 + self.attributeBase.tpUp / 100)
    self.curTp = math.min(self.curTp + tpRecover, self.maxTp)
end

--行动恢复Tp
function BattleUnitVo:ActionRecoveryTP()
    local tpRecover = 90 * (1 + self.attributeBase.tpUp / 100)
    self.curTp = math.min(self.curTp + tpRecover, self.maxTp)
end

--自动恢复Tp
function BattleUnitVo:AutoRecoveryTP()
    local tpRecover = self.tpRecover * (1 + self.attributeBase.tpUp / 100)
    self.curTp = math.min(self.curTp + tpRecover, self.maxTp)
end

function BattleUnitVo:Reset()
    for i = 1, #self.skills do
        local skill = self.skills[i] ---@type Game.Modules.Battle.Vo.SkillVo
        skill:Reset()
    end
    self.level = 0
    self.curHp = self.attributeBase.maxHp
    self.maxHp = self.attributeBase.maxHp
    self.curTp = 0
    self.maxTp = self.battleUnitInfo.maxTp
end

function BattleUnitVo:Dispose()
    BattleUnitVo.super.Dispose(self)
    self.skills = {}
    self.battleUnitInfo = nil
    self.attributeBase = nil
    self.normalSkill = nil
    self.level = 0
    self.curHp = 0
    self.maxHp = 0
    self.curTp = 0
    self.maxTp = 0
end

return BattleUnitVo
