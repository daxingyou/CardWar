---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-20:24:22
---

local AvatarVo = require("Game.Modules.World.Vo.AvatarVo")
---@class Game.Modules.Battle.Vo.BattleUnitVo : Game.Modules.World.Vo.AvatarVo
---@field New fun():Game.Modules.Battle.Vo.BattleUnitVo
---@field battleUnitInfo BattleUnitInfo
---@field skills table<number, Game.Modules.Battle.Vo.SkillVo>
---@field normalSkill Game.Modules.Battle.Vo.SkillVo
---@field camp Camp 阵营 所属阵营
---@field atk number
---@field def number
---@field curHp number
---@field maxHp number
---@field curAnger number
---@field maxAnger number
local BattleUnitVo = class("Game.Modules.Battle.Vo.BattleUnitVo",AvatarVo)

function BattleUnitVo:Ctor()
    BattleUnitVo.super:Ctor(self)
    self.skills = {}
end

function BattleUnitVo:Init(battleUnitName)
    self.battleUnitInfo = BattleUnitConfig.Get(battleUnitName)
    BattleUnitVo.super.Init(self, self.battleUnitInfo.avatarName)
    local skillInfoList = SkillConfig.GetList(battleUnitName)
    for i = 1, #skillInfoList do
        local skill = SkillVoPool:Get() ---@type Game.Modules.Battle.Vo.SkillVo
        skill:Init(skillInfoList[i])
        if skill.skillInfo.skillType == SkillType.Normal then
            self.normalSkill = skill
        end
        table.insert(self.skills, skill)
    end
    self:Reset()
end

function BattleUnitVo:Reset()
    for i = 1, #self.skills do
        local skill = self.skills[i] ---@type Game.Modules.Battle.Vo.SkillVo
        skill:Reset()
    end
    self.level = 0
    self.curHp = self.battleUnitInfo.maxHp
    self.maxHp = self.battleUnitInfo.maxHp
    self.curAnger = 0
    self.maxAnger = self.battleUnitInfo.maxAnger
end

function BattleUnitVo:Dispose()
    BattleUnitVo.super.Dispose(self)
    self.skills = {}
    self.battleUnitInfo = nil
    self.normalSkill = nil
    self.level = 0
    self.curHp = 0
    self.maxHp = 0
end

return BattleUnitVo
