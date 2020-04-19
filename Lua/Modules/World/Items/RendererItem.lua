---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/5/2 17:38
--- 需要支持Unity相关操作的单位
---

local SceneItem = require("Game.Modules.World.Items.SceneUnit")

---@class Game.Modules.World.Items.RendererItem : Game.Modules.World.Items.SceneUnit
---@field renderObj UnityEngine.GameObject 用于渲染的Obj
---@field collider UnityEngine.Collider
---@field smrs table<number, UnityEngine.SkinnedMeshRenderer>
---@field bornPos UnityEngine.Vector3
---@field forward UnityEngine.Vector3
local RendererItem = class("Game.Modules.World.Items.RendererItem", SceneItem)

function RendererItem:Ctor(sceneItemData)
    RendererItem.super.Ctor(self, sceneItemData)
    self.aroundItems = {}
    self.aroundNodesMap = {}
    self.isMoving = false
    self:LoadObject()
end

function RendererItem:OnInitialize()
    RendererItem.super.OnInitialize(self)
end

function RendererItem:LoadObject()
end

function RendererItem:SetBornPos(pos, forward)
    self.bornPos = pos
    if forward then
        self.forward = forward
        self.transform.forward = forward
    end
    self.transform.position = pos
end

function RendererItem:BackToBorn()
    self.transform.position = self.bornPos
    if self.forward then
        self.transform.forward = self.forward
    end
end

function RendererItem:OnRenderObjInit()

end

function RendererItem:OnMoveStart()
    self.isMoving = true
    --self:UpdateNode()
    --self:UpdateAroundPos()
end

function RendererItem:OnMove()
    self.isMoving = true
    --self:UpdateAroundPos()
    --self:UpdateNode()
end

function RendererItem:OnMoveEnd()
    self.isMoving = false
    --self:UpdateNode()
    --self:UpdateAroundPos()
end

--调试
function RendererItem:_debug(msg)
    if self.gameObject then
        print(string.format("\n<color=#3A9BF8FF>[%s]</color><color=#FFFFFFFF>%s</color>",self.gameObject.name,msg))
    else
        print(string.format("\n<color=#3A9BF8FF>[%s]</color><color=#FFFFFFFF>%s</color>",self.__classname,msg))
    end
end

--调试
function RendererItem:_debugError(msg)
    if self.gameObject then
        logError(string.format("[%s]\n%s",self.gameObject.name,msg))
    else
        logError(string.format("[%s]\n%s",self.__classname,msg))
    end
end

function RendererItem:Dispose()

end

return RendererItem