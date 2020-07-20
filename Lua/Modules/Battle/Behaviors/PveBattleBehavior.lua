---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/6/25 23:53
---


local BattleEvents = require("Game.Modules.Battle.Events.BattleEvents")
local BattleItemEvents = require("Game.Modules.Battle.Events.BattleItemEvents")
local GridArea = require("Game.Modules.Battle.Layouts.GridArea")
local BattleBehavior = require("Game.Modules.Battle.Behaviors.BattleBehavior")
local PoolProxy = require("Game.Modules.Common.Pools.AssetPoolProxy")
local RoundBehavior = require("Game.Modules.Battle.Behaviors.RoundBehavior")
local ReportPlayer = require("Game.Modules.Battle.Behaviors.ReportPlayer")
local ReportContext = require("Game.Modules.Battle.Report.ReportContext")
local ReportBehavior = require("Game.Modules.Battle.Report.ReportBehavior")

---@class Game.Modules.Battle.Behaviors.PveBattleBehavior : Game.Modules.Battle.Behaviors.BattleBehavior
---@field New fun(checkPointData:CheckPointData, cardList : table, context:WorldContext):Game.Modules.Battle.Behaviors.BattleBehavior
---@field reportBehavior Game.Modules.Battle.Report.ReportBehavior
---@field reportReplay Game.Modules.Battle.Behaviors.ReportPlayer
---@field cardList List | table<number, Game.Modules.Card.Vo.CardVo> 上阵的卡牌
---@field reportContext Game.Modules.Battle.Report.ReportContext 战报上下文
---@field currAreaInfo GridAreaInfo --当前区域信息
local PveBattleBehavior = class("Game.Modules.Battle.Behaviors.PveBattleBehavior",BattleBehavior)

---@param checkPointData CheckPointData
---@param context WorldContext
function PveBattleBehavior:Ctor(checkPointData, cardList, context)
    PveBattleBehavior.super.Ctor(self, checkPointData, context)
    self.checkPointData = checkPointData
    self.cardList = cardList
end

--初始化对象池
function PveBattleBehavior:InitObjectPool()
    local poolObj = self.context.currSubScene:CreateGameObject("[Pool" .. self.context.id .. "]")
    self.context.pool = PoolProxy.New(poolObj)
    local battleUnitList = List.New() ---@type List | table<number,number> avatarName
    --怪物的对象池
    if self.checkPointData.areas then
        for i = 1, #self.checkPointData.areas do
            local areaInfo =  self.checkPointData.areas[i]
            for j = 1, #areaInfo.waves do
                local waveInfo = areaInfo.waves[j]
                for k = 1, #waveInfo.wavePoints do
                    local pointInfo = waveInfo.wavePoints[k]
                    if not battleUnitList:Contain(pointInfo.battleUnit) then
                        battleUnitList:Add(pointInfo.battleUnit)
                    end
                end
            end
        end
    end
    --英雄的对象池
    for i = 1, self.cardList:Size() do
        local battleUnit = self.cardList[i].cardInfo.battleUnit
        if not battleUnitList:Contain(battleUnit) then
            battleUnitList:Add(battleUnit)
        end
    end
    --其他
    local poolsInfos = PoolFactory.CalcPoolInfoMap(battleUnitList)
    table.insert(poolsInfos,{prefabUrl = Prefabs.LayoutGrid, initNum = 18})
    table.insert(poolsInfos,{prefabUrl = Prefabs.BattleUnitHUD, initNum = 8})
    table.insert(poolsInfos,{prefabUrl = Prefabs.FloatNumber, initNum = 1})
    self.context.pool:InitObjectPool(poolsInfos)
end

function PveBattleBehavior:CreateBattle()
    self.reportContext = ReportContext.New(self.context.mode)

    --创建上阵玩家英雄
    for i = 1, self.cardList:Size() do
        local battleUnitName = self.cardList[i].cardInfo.battleUnit
        local reportUnit = self.reportContext:AddBattleUnit(Camp.Atk, battleUnitName)
        reportUnit.ownerCardVo = self.cardList[i]
        local battleUnit = self.context:AddBattleUnit(Camp.Atk, battleUnitName, reportUnit.layoutIndex)
        battleUnit.ownerCardVo = self.cardList[i]
    end
end

function PveBattleBehavior:StartBattle()
    self.reportBehavior = ReportBehavior.New(self.reportContext)
    self.reportContext.reportBehavior = self.reportBehavior
    World.model.battleModel.startTime = Time.time
    --战斗流程
    local winCamp = nil
    self:StartCoroutine(function()
        for i = 1, #self.checkPointData.areas do
            World.model.battleModel.currAreaId = i
            self:RefreshArea(i)
            coroutine.wait(1)
            self.reportBehavior:Play()
            while not self.reportBehavior.isAllDead do
                coroutine.step(1)
            end
            local anyAllDead = self.context:IsCampAllDead(Camp.Atk) or self.context:IsCampAllDead(Camp.Def)
            while not anyAllDead do
                coroutine.step(1)
            end
            if self.context:IsCampAllDead(Camp.Atk) then
                --英雄阵亡战斗结束
                self:_debug("所有英雄已经死亡")
                winCamp = Camp.Def --怪物胜利
                break;
            elseif self.context:IsCampAllDead(Camp.Def) then
                self:_debug("当前区域怪物都已经死亡")
                while not self.context:IsCampAllDeadOver(Camp.Def) do
                    coroutine.step(1)
                end
                self:_debug("当前区域怪物都已经死亡 --- 结束,继续下一个区域")
            else
                logError("死亡一次")
            end
        end
        if winCamp == nil then
            self:_debug("所有怪物都已经死亡")
            winCamp = Camp.Atk --玩家英雄胜利
        end
        self:_debug("整场战斗结束 " .. winCamp)
        self:StopBattle(winCamp) --停止战斗
    end)
    self.reportReplay = ReportPlayer.New(self.context, self.reportContext)
    self.reportReplay:Play()
end

--开始录制战报
function PveBattleBehavior:RefreshArea(areaIndex)
    local areaInfo =  self.checkPointData.areas[areaIndex]
    self:_debug(("Area Refresh AreaId:" .. areaInfo.areaIndex))
    self.reportContext.layout:Clear(Camp.Def)
    for i = 1, #areaInfo.waves do
        local wave = areaInfo.waves[i]
        for j = 1, #wave.wavePoints do
            local reportUnit = self.reportContext:AddBattleUnit(Camp.Def, wave.wavePoints[i].battleUnit)
            local battleUnit = self.context:AddBattleUnit(Camp.Def, wave.wavePoints[i].battleUnit, reportUnit.layoutIndex)
        end
    end
end

--停止回合
function PveBattleBehavior:StopBattle(winCamp)
    if self.reportReplay then
        self.reportReplay:Stop()
    end
    if self.reportBehavior then
        self.reportBehavior:Stop()
    end
    if winCamp then
        if winCamp == Camp.Atk then
            BattleEvents.Dispatch(BattleEvents.AllMonsterDeadOver)
        else
            BattleEvents.Dispatch(BattleEvents.AllHeroDeadOver)
        end

        self.context.battleSpeed = 1

        ---@param unit Game.Modules.World.Items.BattleUnit
        self.context:ForEach(winCamp, function(unit)
            unit:PlayWin()
        end)
        print("获胜方:" .. winCamp)
    end
end

function PveBattleBehavior:Dispose()
    PveBattleBehavior.super.Dispose(self)
    self:Clear()
    self:StopBattle()

    if self.reportReplay then
        self.reportReplay:Dispose()
        self.reportReplay = nil
    end
    if self.reportBehavior then
        self.reportBehavior:Dispose()
        self.reportBehavior = nil
    end
end

return PveBattleBehavior