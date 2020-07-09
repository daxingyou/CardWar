---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/5/21 22:48
---

local BaseBehavior = require('Game.Modules.Common.Behavior.BaseBehavior')

---@class Game.Modules.Battle.Behaviors.BattleBehavior : Game.Modules.Common.Behavior.BaseBehavior
---@field checkPointData CheckPointData
---@field context WorldContext
local BattleBehavior = class("Game.Modules.Battle.Behaviors.BattleBehavior",BaseBehavior)

---@param checkPointData CheckPointData
---@param context UnityEngine.GameObject
function BattleBehavior:Ctor(checkPointData, context)
    BattleBehavior.super.Ctor(self)
    self.context = context
    self.checkPointData = checkPointData
end

function BattleBehavior:InitObjectPool()

end

--创建战场
function BattleBehavior:CreateBattle()

end

function BattleBehavior:StartBattle()

end

--新的队列
function BattleBehavior:NewQueue()

end
--统计对象池
---@param sceneData CheckPointData
---@return table<number,PoolInfo>
function BattleBehavior:CalPoolsNum(sceneData)

end

--获取当前区域
---@return Game.Modules.Battle.Layouts.AreaBase
function BattleBehavior:GetCurrArea()

end

--下一区域
function BattleBehavior:NextArea()

end

--获取某阵营所有单位
---@param camp Camp
---@param includeDead boolean 是否包含死亡单位
---@return List | table<number, Game.Modules.World.Items.BattleUnit>
function BattleBehavior:GetCampAvatarList(camp, includeDead)
    local gridList = self.context.battleLayout.gridLayoutMap[camp] ---@type table<number, Game.Modules.Battle.Layouts.LayoutGrid>
    local tempList = List.New()
    for i = 1, #gridList do
        if gridList[i].owner then
            local checkDead = includeDead and true or (not gridList[i].owner:IsDead())
            if checkDead and gridList[i].owner.layoutIndex ~= 0 then
                tempList:Add(gridList[i].owner)
            end
        end
    end
    return tempList
end

--某阵营是否都以阵亡
---@param camp Camp
function BattleBehavior:IsCampAllDead(camp)
    local gridList = self.context.battleLayout.gridLayoutMap[camp] ---@type table<number, Game.Modules.Battle.Layouts.LayoutGrid>
    local allDead = true
    for i = 1, #gridList do
        if gridList[i].owner and not gridList[i].owner:IsDead() then
            allDead = false
            break;
        end
    end
    return allDead
end

function BattleBehavior:Clear()
    self:_debug("强制清场")
    if self:GetCurrArea() then
        self:GetCurrArea():Clear()
    end
end

function BattleBehavior:Dispose()
    BattleBehavior.super.Dispose(self)
end

return BattleBehavior