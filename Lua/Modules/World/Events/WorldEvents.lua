---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/4/7 23:58
---

---@class Game.Modules.World.Events.WorldEvents
local WorldEvents = {}

--进入某个场景
WorldEvents.EnterScene          = "WorldEnterScene"

--场景加载完成
WorldEvents.SceneLoadComplete    = "SceneLoadComplete"

--转场开始
WorldEvents.TransitionStart = "TransitionStart"

--转场结束
WorldEvents.TransitionOver    = "TransitionOver"

function WorldEvents.Dispatch(event)
    DispatchEvent(WorldEvents,event,false, false)
end

return WorldEvents