---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2020/3/19 14:34
---
---

local LuaMonoBehaviour = require("Core.LuaMonoBehaviour")
---@class Game.Modules.Battle.View.LayoutGrid : Core.LuaMonoBehaviour
---@field New fun(grid:UnityEngine.GameObject, index:number, forward:UnityEngine.Vector3):Game.Modules.Battle.View.LayoutGrid
---@field owner Game.Modules.World.Items.Avatar
---@field forward UnityEngine.Vector3
---@field gridMat UnityEngine.Material
---@field selectMat UnityEngine.Material
---@field index number
---@field indexTextMesh UnityEngine.TextMesh
local LayoutGrid = class("Module.Battle.View.LayoutGrid", LuaMonoBehaviour)

local Col_Default   = Color.New(1,1,1,0.2)
local Col_Empty     = Color.New(0,1,0,0.02)
local Shine_Duration = 0.5
local Shine_Duration_Select = 0.3
local Mat_Color_Prop = "_Color"

---@param gameObject UnityEngine.GameObject
---@param index number
---@param forward UnityEngine.Vector3
function LayoutGrid:Ctor(gameObject, index, forward)
    LayoutGrid.super.Ctor(self, gameObject)
    self.gameObject.transform.localScale = Vector3.New(1.6,1.6,1.6)

    self.index = index
    self.forward = forward
    self.gridObj = self.gameObject:FindChild("Grid")
    self.selectObj = self.gameObject:FindChild("Select")
    self.selectObj:SetActive(false)
    self.gridMat = self.gridObj:GetComponent(typeof(UnityEngine.MeshRenderer)).material
    self.gridMat:SetColor(Mat_Color_Prop,Col_Default)
    self.selectMat = self.selectObj:GetComponent(typeof(UnityEngine.MeshRenderer)).material

    self.indexTextMesh = self.gameObject:FindChild("Index"):GetComponent(typeof(UnityEngine.TextMesh))
    self.indexTextMesh.text = tostring(index)
end

---@param owner Game.Modules.World.Items.Avatar
function LayoutGrid:SetOwner(owner)
    self.owner = owner
    self.owner:SetBornPos(self.transform.position, self.forward)
    self.owner.transform.forward = self.forward
    self.owner.layoutIndex = self.index
    self.owner.layoutGrid = self
end

function LayoutGrid:ClearOwner()
    if self.owner then
        self.owner.layoutIndex = 0
        self.owner.layoutGrid = nil
    end
    self.owner = nil
    self:SetAttackSelect(false)
    self:SetGridVisible(true)
end

function LayoutGrid:SetSelect(bool)
    self.selectObj:SetActive(bool)
    if bool then
        self.selectObj.transform.localScale = Vector3.one
        self.selectObj.transform:DOScale(Vector3.New(0.8,0.8,1), Shine_Duration_Select):SetLoops(-1, DOTween_Enum.LoopType.Yoyo)
        self.gameObject.transform:DOShakePosition(Shine_Duration, Vector3.New(0,0,0.02),1,1):SetLoops(-1, DOTween_Enum.LoopType.Yoyo)
    else
        self.selectObj.transform.localScale = Vector3.one
        self.selectObj.transform:DOPause()
        self.gameObject.transform:DOPause()
    end
end

function LayoutGrid:SetAttackSelect(bool)
    self.gridObj:SetActive(false)
    self:SetSelect(bool)
end

function LayoutGrid:SetGridVisible(bool)
    self.gridObj:SetActive(bool)
    --self.selectObj:SetActive(bool)
end

function LayoutGrid:SetVisible(bool)
    self.gameObject:SetActive(bool)
end

function LayoutGrid:Reset()
    self.gridMat:SetColor(Mat_Color_Prop,Col_Default)
    self.gridMat:DOPause()
    self.gameObject.transform:DOPause()
end

function LayoutGrid:Shine()
    self.gridMat:SetColor(Mat_Color_Prop,Col_Empty)
    self.gridMat:DOColor(Col_Default, Shine_Duration):SetLoops(-1, DOTween_Enum.LoopType.Yoyo)
    --self.gridObj.transform:DOShakePosition(Shine_Duration, Vector3.New(0,0,0.01),1,1):SetLoops(-1, DOTween_Enum.LoopType.Incremental)
end

return LayoutGrid