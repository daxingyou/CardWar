---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/3/6 11:29
--- 多控制器相机，管理相机的多种控制器
---

local AttachCamera = require("Game.Modules.Common.Components.AttachCamera")
local Widget = require("Game.Modules.Common.Components.Widget")

---@class Module.Common.Widgets.MulitCameraCtrl : Game.Modules.Common.Components.Widget
---@field New fun(camera:UnityEngine.Camera)
---@field attachCamera Module.Common.Widgets.AttachCamera
---@field tic BitBenderGames.TouchInputController
---@field target UnityEngine.GameObject
local MulitCameraCtrl = class("Module.Common.Widgets.MulitCameraCtrl", Widget)

---@param camera UnityEngine.Camera
function MulitCameraCtrl:Ctor(camera, radius, angle, offset)
    self.attachCamera = AttachCamera.New(camera, radius, angle, offset)
    self.attachCamera:SetSmooth(true)
    self.tic = camera:GetComponent(typeof(BitBenderGames.TouchInputController))
    self.mtc = camera:GetComponent(typeof(BitBenderGames.MobileTouchCamera))
    self:SetTouchEnable(false)
end

function MulitCameraCtrl:DelayEnableTouch(delay)
    self:CreateDelay(delay,function()
        self:SetTouchEnable(true)
    end)
end

---@param target Game.Modules.World.Items.Avatar
function MulitCameraCtrl:StartAttachTarget(target, smooth)
    self.target = target
    self.attachCamera:Attach(target)
    if not smooth then
        self.attachCamera:StopAttach()
    end
    self.attachCamera:Reset()
    self.attachCamera:StartAttach()
end

function MulitCameraCtrl:StopAttach()
    self.attachCamera:StopAttach()
end

function MulitCameraCtrl:SetTouchEnable(enable)
    self.tic.enabled = enable
    self.mtc.enabled = enable
    if enable then
        self.attachCamera:StopAttach()
    else
        self.attachCamera:StartAttach()
    end
end

---@param pos UnityEngine.Vector3
function MulitCameraCtrl:AttachPos(pos, attachCallback)
    self.attachCamera:AttachPos(pos, attachCallback)
end

function MulitCameraCtrl:Dispose()
    MulitCameraCtrl.super.Dispose(self)
    self.attachCamera:Dispose()
end

return MulitCameraCtrl