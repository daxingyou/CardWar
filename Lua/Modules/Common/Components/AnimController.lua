---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/4/19 15:11
--- 动作状态机控制器
---

---@class Module.Common.ParamAnim
---@field name string
---@field type string Int Float Boolean
---@field value number|boolean

local Widget = require("Game.Modules.Common.Components.Widget")

---@class Game.Modules.Common.Components.AnimController : Game.Modules.Common.Components.Widget
---@field New fun(gameObject:UnityEngine.GameObject)
---@field animator UnityEngine.Animator
---@field rac UnityEngine.RuntimeAnimatorController
---@field animLength table<number, number>
---@field callbackList table<number, Handler>
---@field currAnimName string
local AnimController = class("Game.Modules.Common.Components.AnimController", Widget)

AnimController.ParamType =
{
    Integer = "Integer",
    Float = "Float",
    Bool = "Bool"
}
---@param avatar Game.Modules.World.Items.Avatar
function AnimController:Ctor(avatar, ctrlUrl)
    self.avatar = avatar
    self.gameObject = avatar.gameObject
    self.ctrlUrl = ctrlUrl
    AnimController.super.Ctor(self, avatar.gameObject)

    self.animator = GetComponent.Animator(self.avatar.renderObj)
    self.rac = self.animator.runtimeAnimatorController
    if not StringUtil.IsEmpty(ctrlUrl) then
        self:SetRuntimeAnimatorController(ctrlUrl)
    end
    self.animLength = {}
    self.callbackList = {}
    self.currAnimName = nil
    self.currAnimDelay = nil

    AddEventListener(Stage, Event.UPDATE,self.Update, self)
end

function AnimController:SetRuntimeAnimatorController(ctrlUrl)
    local newCtrl = Res.LoadAnimatorController(ctrlUrl)
    self.animator.runtimeAnimatorController = newCtrl
    self.rac = self.animator.runtimeAnimatorController
end

--手动更新动作
---@param animName string
function AnimController:PlayManualAnim(animName, speed)
    self.animator.updateMode = UnityEngine.AnimatorUpdateMode.UnscaledTime
    self:PlayAnim(animName, Handler.New(function()
        self.animator.updateMode = UnityEngine.AnimatorUpdateMode.Normal
    end,self), speed)
end

---@param animName string
---@param callback Handler
function AnimController:PlayAnim(animName,callback, speed, crossFade)
    if isnull(self.animator) or isnull(self.animator.gameObject) then
        return
    end
    if self.animator.gameObject.activeSelf then
        if crossFade and crossFade > 0 then
            self.animator:CrossFade(animName, crossFade)
        else
            self.animator:Play(animName)
        end
        self.animator:Update(0) --强制切换,方便获取动作时长
    end
    speed = speed == nil and 1 or speed
    if callback then
        local length = self:GetAnimLength(animName)
        if length then
            self:CreateDelay(length / speed, function()
                callback:Execute()
                callback:Recycl()
            end)
            --self:AddCallback(length / speed, callback)
            --if self.callbackList[callback.callback] then
            --    self.callbackList[callback.callback] = nil
            --end
            --self.callbackList[callback.callback] = {handler = callback, startTime = Time.time, length = length / speed}
        else
            logError("get anim lengtn error:" .. animName)
            callback:Execute()
            callback:Recycl()
        end
    end
    self.animator.speed = speed
end

---@param callback Handler
function AnimController:AddCallback(length, callback)
    self:CreateDelay(length, function()
        callback:Execute()
        callback:Recycl()
    end)
    --self.callbackList[callback.callback] = {handler = callback, startTime = Time.time, length = length}
end

function AnimController:Update()
    local del = {}
    for i, v in pairs(self.callbackList) do
        local call = self.callbackList[i]
        if call then
            if Time.time - call.startTime > call.length then
                --if call.handler then
                call.handler:Execute()
                --end
                table.insert(del, i)
            end
        end
    end
    for i = 1, #del do
        self.callbackList[del[i]] = nil
    end
end

---@param animName string
function AnimController:PlayAnimSpeed(animName,speed,callback)
    --if not isnull(self.animator) then
    self:PlayAnim(animName,callback, speed)
    --end
    --local state = self.animator:GetCurrentAnimatorStateInfo(0)
end

function AnimController:GetAnimLength(animName)
    if StringUtil.IsEmpty(animName) or isnull(self.animator) then
        return 0
    end
    if self.animLength[animName] == nil then
        self.animator:Play(animName)
        self.animator.speed = 1
        self.animator:Update(0) --强制切换,方便获取动作时长
        self.animLength[animName] = self.animator:GetCurrentAnimatorStateInfo(0).length
        if self.animLength[animName] == 0 then
            logError("error anim len:" .. animName)
        end
    end
    return self.animLength[animName]
end

---@param param Module.Common.ParamAnim
function AnimController:PlayParamAnim(param)
    if not isnull(self.animator) then
        if param.type == AnimController.Integer then
            self.animator:SetInteger(param.name,param.value)
        elseif param.type == AnimController.Float then
            self.animator:SetFloat(param.name,param.value)
        elseif param.type == AnimController.Bool then
            self.animator:SetBool(param.name,param.value)
        end
    end
end


function AnimController:JumpTo(destPos, callback, duration)
    duration = duration or 1
    local h = 3
    local d = Vector3.Distance(self.transform.position, destPos) / 2
    local path = BezierUtils.GetJumpPath1(self.transform.position, destPos, h, d, Convert.TimeToFrameNum(duration))
    Math3D.LookAt2DPos(self.transform, destPos)
    if self.avatar.shadow then
        self.avatar.shadow.transform:SetParent(self.transform.parent)
    end
    local org = self.transform.position
    Tool.DOTweenEaseFun(#path,duration,function(idx)
        local p = path[idx]
        self.transform.position = p
        --处理影子的移动
        p.y = org.y
        if self.avatar.shadow then
            self.avatar.shadow.transform.position = p
        end
    end,function()
        if self.avatar.shadow then
            self.avatar.shadow.transform:SetParent(self.transform)
        end
        if callback then
            callback()
        end
    end ,DOTween_Enum.Ease.Linear)
end

function AnimController:SlidingTo(seePos, endPos, duration, callback)
    Math3D.LookAt2DPos(self.transform, seePos)

    local sequence = self:CreateSequence()
    sequence:Append(self.transform:DOMove(endPos, duration):SetEase(DOTween_Enum.Ease.OutSine))
    sequence:AppendCallback(function ()
        if callback then callback() end
    end)
end

--倒地回弹
function AnimController:Rebound(duration,callback, h, d)
    duration = duration or 0.5
    h = h or 5
    d = d or 2.5

    if self.avatar.shadow then
        self.avatar.shadow.transform:SetParent(self.transform.parent)
    end

    local orgPos = self.transform.position
    local lastPos = self.transform.position
    local times = 2 --回弹次数

    local sequence = self:CreateSequence()
    self.avatar.renderObj.transform:DOLocalRotate(Vector3.New(-80,0,0),duration/3)
    for i = 1, times do
        if i > 1 then
            d = d * 0.5
            h = h * 0.6
            duration = duration * 0.6
        end
        local destPos = lastPos + -self.transform.forward * d
        if AStarUtils.Walkable(World.grid, destPos) then
            --lastPos = destPos
            --local ss = self:CreateSequence()
            --ss:Join(self.transform:DOMoveX(destPos.x, duration):SetEase(DOTween_Enum.Ease.Linear))
            --ss:Join(self.transform:DOMoveZ(destPos.z, duration):SetEase(DOTween_Enum.Ease.Linear))
            --ss:Join(self.transform:DOMoveY(orgPos.y + h, duration * 0.4):SetEase(DOTween_Enum.Ease.OutSine))
            --ss:Append(self.transform:DOMoveY(orgPos.y + 0.1, duration * 0.5):SetEase(DOTween_Enum.Ease.InSine))
            --sequence:Append(ss):OnUpdate(function()
            --    if self.avatar.shadow then
            --        local p = self.transform.position
            --        p.y = orgPos.y
            --        self.avatar.shadow.transform.position = p
            --    end
            --end)
            local path = BezierUtils.GetJumpPath1(lastPos, destPos, h, d / 2, Convert.TimeToFrameNum(duration))
            lastPos = destPos
            sequence:Append(Tool.DOTweenEaseFun(#path, duration,function(idx)
                local p = path[idx] or Vector3.zero
                p.y = p.y + 0.1
                self.transform.position = p
                if self.avatar.shadow and self.avatar.shadowOrgScale then
                    self.avatar.shadow.transform.localScale = self.avatar.shadowOrgScale / (1 + math.max(0, p.y - orgPos.y))
                end
                p.y = orgPos.y
                if self.avatar.shadow then
                    self.avatar.shadow.transform.position = p
                end
                --lastPos = self.transform.position
            end,function ()
                self.avatar.shadow.transform.localScale = self.avatar.shadowOrgScale
            end , DOTween_Enum.Ease.InSine))
        end
    end
    self:CreateDelay(duration, function()
        if self.avatar.shadow then
            self.avatar.shadow.transform:SetParent(self.transform)
        end
        if callback then
            callback:Execute()
            --callback:Recycl()
        end
    end)
end

function AnimController:ParaCure(orgPos, destPos, height, duration)
    local sequence = self:CreateSequence()
    sequence:Join(self.transform:DOMoveX(destPos.x, duration):SetEase(DOTween_Enum.Ease.InSine))
    sequence:Join(self.transform:DOMoveZ(destPos.z, duration):SetEase(DOTween_Enum.Ease.InSine))
    sequence:Join(self.transform:DOMoveY(orgPos.y + height, duration / 2):SetEase(DOTween_Enum.Ease.OutSine))
    sequence:Append(self.transform:DOMoveY(orgPos.y + 0.2, duration / 2):SetEase(DOTween_Enum.Ease.InSine))
    return sequence
end

--动作进度
---@param animInfo AnimInfo
function AnimController:PlayAnimInfo(animInfo, animOverCallback)
    self:PlayAnim(animInfo.animName, animOverCallback, animInfo.animSpeed,0.1)
end

function AnimController:Clear()
    self.callbackList = {}
end

function AnimController:Dispose()
    AnimController.super.Dispose(self)
    RemoveEventListener(Stage, Event.UPDATE,self.Update, self)
end
return AnimController