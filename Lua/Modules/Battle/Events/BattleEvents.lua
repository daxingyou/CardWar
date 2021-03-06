---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/5/23 22:51
---

---@class Game.Modules.Battle.Events.BattleEvents
---@field target Game.Modules.World.Items.BattleUnit
---@field hero Game.Modules.World.Items.Hero
---@field monster Module.World.Items.Monster
---@field callback Handler
local BattleEvents = {}

--进入场景
BattleEvents.EnterScene    = "Battle_EnterScene"

--开始战斗
BattleEvents.BattleStart    = "Battle_BattleStart"

--暂停战斗
BattleEvents.BattlePause    = "Battle_BattlePause"

--恢复暂停的战斗
BattleEvents.BattleResume    = "Battle_BattleResume"

--战斗结束
BattleEvents.BattleEnd      = "Battle_BattleEnd"

--单次攻击开始
BattleEvents.EnterAttack = "Battle_EnterAttack"

--单次攻击结束
BattleEvents.ExitAttack = "Battle_ExitAttack"

--所有怪物死亡
BattleEvents.AllMonsterDead    = "Battle_AllMonsterDead"

--所有怪物死亡结束
BattleEvents.AllMonsterDeadOver    = "Battle_AllMonsterDeadOver"

--所有英雄死亡结束
BattleEvents.AllHeroDeadOver    = "Battle_AllHeroDeadOver"

--战斗速度改变
BattleEvents.BattleSpeedChanged    = "Battle_BattleSpeedChanged"

function BattleEvents.Dispatch(event)
    DispatchEvent(BattleEvents,event,false, false)
end

---@param item Game.Modules.World.Items.BattleUnit
function BattleEvents.DispatchItemEvent(type, item)
    local event = {}
    event.type = type
    event.item = item
    DispatchEvent(BattleEvents,event,false, false)
end

return BattleEvents