---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-06-27-18:12:43
---

local WorldEvents = require("Game.Modules.World.Events.WorldEvents")
local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Transition.View.TransitionMdr : Game.Core.Ioc.BaseMediator
local TransitionMdr = class("Game.Modules.Transition.View.TransitionMdr",BaseMediator)

local Duration = 0.5

function TransitionMdr:Ctor()
    TransitionMdr.super.Ctor(self)
    self.layer = UILayer.LAYER_TOP
end

function TransitionMdr:OnInit()
    self.blackImg = self.gameObject:GetImage("BlackBg")
    self.blackImg.color = Color.New(0,0,0,0)
    self.blackImg:DOFade(1,Duration):OnComplete(function()
        WorldEvents.Dispatch(WorldEvents.TransitionStart)
    end)
end

function TransitionMdr:RegisterListeners()
    AddEventListener(WorldEvents, WorldEvents.TransitionOver, self.OnTransitionOver, self)
end

function TransitionMdr:OnTransitionOver()
    self:DoHide()
end

function TransitionMdr:DoHide()
    self.blackImg:DOFade(0,Duration):OnComplete(function()
        self:Unload()
    end)
end

function TransitionMdr:OnRemove()
    RemoveEventListener(WorldEvents, WorldEvents.TransitionOver, self.OnTransitionOver, self)
end

return TransitionMdr