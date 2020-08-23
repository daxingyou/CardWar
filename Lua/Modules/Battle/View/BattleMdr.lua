---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2019-05-18-23:22:49
---

local BattleItemEvents = require("Game.Modules.Battle.Events.BattleItemEvents")
local AttachCamera = require("Game.Modules.Common.Components.AttachCamera")
local PveBattleBehavior = require("Game.Modules.Battle.Behaviors.PveBattleBehavior")
local RoundBehavior = require("Game.Modules.Battle.Behaviors.RoundBehavior")
local BattleEvents = require("Game.Modules.Battle.Events.BattleEvents")
local BattleBaseMdr = require("Game.Modules.Battle.View.BattleMdrBase")
---@class Module.Battle.View.BattleGridMdr : Game.Modules.Battle.View.BattleMdrBase
---@field battleModel Game.Modules.Battle.Model.BattleModel
---@field battleService Game.Modules.Battle.Service.BattleService
local BattleMdr = class("Module.Battle.View.BattleGridMdr",BattleBaseMdr)

function BattleMdr:OnInit()
    BattleMdr.super.OnInit(self)
end

function BattleMdr:RegisterListeners()
    BattleMdr.super.RegisterListeners(self)
    AddEventListener(BattleEvents, BattleEvents.BattleStart, self.OnGridBattleStart, self)
    AddEventListener(BattleEvents, BattleEvents.BattlePause, self.OnBattlePause, self)
    AddEventListener(BattleEvents, BattleEvents.BattleResume, self.OnBattleResume, self)
    AddEventListener(BattleEvents, BattleEvents.AllMonsterDeadOver, self.OnAllMonsterDeadOver, self)
    AddEventListener(BattleEvents, BattleEvents.AllHeroDeadOver, self.OnAllHeroDeadOver, self)
    AddEventListener(BattleItemEvents, BattleItemEvents.BattleItemDead, self.OnBattleItemDead, self)
    AddEventListener(BattleItemEvents, BattleItemEvents.BattleItemBorn, self.OnBattleItemBorn, self)
end

---@param event Game.Modules.Battle.Events.BattleEvents
function BattleMdr:OnBattlePause(event)

end

---@param event Game.Modules.Battle.Events.BattleEvents
function BattleMdr:OnBattleResume(event)

end

---@param event Game.Modules.World.Events.BattleItemEvents
function BattleMdr:OnBattleItemBorn(event)
    if event.target.avatarInfo.quality == MonsterQuality.Boss then

    end
end

---@param event Game.Modules.World.Events.BattleItemEvents
function BattleMdr:OnBattleItemDead(event)
    --if event.target.avatarInfo.quality == MonsterQuality.Boss then
    --    self.context.battleLayout:SetAllGridVisible(Camp.Def,false)
    --    self:StartCoroutine(function()
    --        Time.timeScale = 0.2
    --        coroutine.wait(2 * 0.2)
    --        Time.timeScale = 1
    --    end)
    --end
end

function BattleMdr:OnGridBattleStart()

end

function BattleMdr:OnAllMonsterDeadOver()
    self:OnBattleOver(true)
end

function BattleMdr:OnAllHeroDeadOver()
    self:OnBattleOver(false)
end

function BattleMdr:OnBattleOver(win)
    self.battleModel.battleResult = win
    vmgr:LoadView(ViewConfig.BattleResult)
    vmgr:UnloadView(ViewConfig.PveBattleInfo)
    vmgr:UnloadView(ViewConfig.BattleInfo)
end


--初始化关卡数据
function BattleMdr:InitCheckPointData()
    BattleMdr.super.InitCheckPointData(self)
end
function BattleMdr:InitLayoutData()
    BattleMdr.super.InitLayoutData(self)
end

--初始化战斗模式
function BattleMdr:InitBattleMode()
    BattleMdr.super.InitBattleMode(self)
    if self.battleModel.currBattleMode == BattleMode.PVE then
        local behavior = PveBattleBehavior.New(self.battleModel.currCheckPointData, self.battleConfigModel.selectList, self.context)
        self.context.battleBehavior = behavior
    else
        --self.context.battleBehavior = PveBattleBehavior.New(self.checkPointData, self.context)
    end

end

function BattleMdr:InitObjectPool()
    self.context.battleBehavior:InitObjectPool()
end

function BattleMdr:StartBattle()
    BattleMdr.super.StartBattle(self)
    --self.context:CreateBattleItems(self.battleModel.playerVo.cards, Camp.Atk, CardState.GridBattle)
    self.context.battleBehavior:CreateBattle()

    vmgr:LoadView(ViewConfig.BattleInfo)
    vmgr:LoadView(ViewConfig.PveBattleInfo)

    self.context.attachCamera = AttachCamera.New(self.context.currSubScene:GetCamera(),
            self.battleSceneInfo.cameraDistance, self.battleSceneInfo.cameraAngle,self.battleSceneInfo.cameraOffset)
    self.context.currSubScene:GetCamera().enabled = true
    self.context.attachCamera:AttachPos(self.context.battleLayout.areaPointObj.transform.position)
    self.context.attachCamera:StopAttach()
    self.context.attachCamera:Reset()
    self.context.attachCamera:StartAttach()
    BattleEvents.Dispatch(BattleEvents.EnterScene)

    self:StartCoroutine(function()
        --local currArea = self.context.battleBehavior:GetCurrArea()
        --currArea:Active()
        --等待刷怪结束
        --while not currArea.isBornOver do
        --    coroutine.step(1)
        --end
        --coroutine.wait(0.2)
        --self.context.attachCamera:AttachPos(self.context.battleLayout.areaPointObj.transform.position)
        --vmgr:LoadView(ViewConfig.BattleArrayEditor)--布阵
        coroutine.step(1)
        --等待布局结束
        --while not self.battleModel.isEditBattleArrayComplete do
        --    coroutine.step(1)
        --end
        --coroutine.wait(1)
        self:OnBattleStart()
        log("Battle Start")
    end)
end

function BattleMdr:OnBattleStart()
    self.context.battleBehavior:StartBattle()
    self.context.currSubScene:SetAllColliderEnable(false)
end

function BattleMdr:OnRemove()
    RemoveEventListener(BattleEvents, BattleEvents.BattleStart, self.OnGridBattleStart, self)
    RemoveEventListener(BattleEvents, BattleEvents.BattlePause, self.OnBattlePause, self)
    RemoveEventListener(BattleEvents, BattleEvents.BattleResume, self.OnBattleResume, self)
    RemoveEventListener(BattleEvents, BattleEvents.AllMonsterDeadOver, self.OnAllMonsterDeadOver, self)
    RemoveEventListener(BattleEvents, BattleEvents.AllHeroDeadOver, self.OnAllHeroDeadOver, self)
    RemoveEventListener(BattleItemEvents, BattleItemEvents.BattleItemDead, self.OnBattleItemDead, self)
    RemoveEventListener(BattleItemEvents, BattleItemEvents.BattleItemBorn, self.OnBattleItemBorn, self)

    if self.battleModel.currBattleMode == BattleMode.PVE then
        vmgr:UnloadView(ViewConfig.BattleInfo)
        vmgr:UnloadView(ViewConfig.PveBattleInfo)
    else
        --self.context.battleBehavior = PveBattleBehavior.New(self.checkPointData, self.context)
    end

    BattleMdr.super.OnRemove(self)
end

return BattleMdr
