---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/4/10 23:37
---

---@class BattleContext
---@field battleScene Game.Modules.World.Scenes.BattleScene
---@field battleBehavior Game.Modules.Battle.Behaviors.BattleBehavior
---@field points table<number, UnityEngine.Vector3>
local WorldContexts = class("WorldContexts")

function WorldContexts:Ctor()

end

return WorldContexts