---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-00:50:19
---

local PoolObject = require("Game.Modules.Common.Pools.PoolObject")
---@class Game.Modules.Battle.Vo.SkillVo : Game.Modules.Common.Pools.PoolObject
---@field New fun(skillName:string):Game.Modules.Battle.Vo.SkillVo
---@field skillInfo SkillInfo
---@field active boolean
---@field startTime number
---@field canUseCount number 当前可使用次数
---@field useCount number 使用次数
---@field isNecessary boolean 必然被触发的
local SkillVo = class("Game.Modules.Battle.Vo.SkillVo",PoolObject)

function SkillVo:Ctor()

end

---@param skillInfo SkillInfo
function SkillVo:Init(skillInfo)
    self.skillInfo = skillInfo
    self.active = true
    self:Reset()
end

function SkillVo:Reset()
    self.startTime = 0
    self.canUseCount = 0
    self.useCount = 0
end

function SkillVo:Dispose()
    self.skillInfo = nil
    self.active = false
    self:Reset()
end

return SkillVo
