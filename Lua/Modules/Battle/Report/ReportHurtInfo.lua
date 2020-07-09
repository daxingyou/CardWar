---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/7/8 22:21
---


---@class Game.Modules.Battle.Report.ReportHurtInfo
---@field New fun():Game.Modules.Battle.Report.ReportHurtInfo
---@field atker Game.Modules.Battle.Vo.BattleUnitVo
---@field defer Game.Modules.Battle.Vo.BattleUnitVo
---@field skillVo Game.Modules.Battle.Vo.SkillVo
---@field isHelpful boolean
---@field accountId string
---@field deferIsDead boolean
---@field damRecoveryTP number 伤害恢复的TP
---@field dam number     伤害
---@field critDam number 暴击伤害
---@field atk number     攻击
---@field def number     防御
---@field crit number    暴击倍数
---@field miss boolean 是否命中
---@field acc number
local ReportHurtInfo = class("Game.Modules.Battle.Report.ReportHurtInfo");

function ReportHurtInfo.Ctor()

end

return ReportHurtInfo