---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/1/28 0:04
---

GetComponent = {}

local RectTransform     = "RectTransform"
local Image             = "Image"
local Button            = "Button"
local Toggle            = "Toggle"
local CanvasGroup       = "CanvasGroup"
local Slider            = "Slider"
local Text              = "Text"
local ListView          = "ListView"
local ListPositionView  = "ListPositionView"
local Animator          = "Animator"
local TextMesh          = "TextMesh"

---@param go UnityEngine.GameObject
---@return UnityEngine.RectTransform
function GetRectTransform(go)
    return go:GetRect()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.RectTransform
function GetComponent.RectTransform(go)
    return go:GetRect()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Text
function GetText(go)
    return go:GetText()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Text
function GetComponent.Text(go)
    return go:GetText()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.InputField
function GetInputField(go)
    return go:GetInputField()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.InputField
function GetComponent.InputField(go)
    return go:GetInputField()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Image
function GetImage(go)
    return go:GetImage()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Image
function GetComponent.Image(go)
    return go:GetImage()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Button
function GetButton(go)
    return go:GetButton()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Button
function GetComponent.Button(go)
    return go:GetButton()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Toggle
function GetToggle(go)
    return go:GetCom(Toggle)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Toggle
function GetComponent.Toggle(go)
    return go:GetCom(Toggle)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.CanvasGroup
function GetCanvasGroup(go)
    return go:GetCanvasGroup()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.CanvasGroup
function GetComponent.CanvasGroup(go)
    return go:GetCanvasGroup()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Slider
function GetSlider(go)
    return go:GetSlider()
end

---@param go UnityEngine.GameObject
---@return UnityEngine.UI.Slider
function GetComponent.Slider(go)
    return go:GetSlider()
end

---@param go UnityEngine.GameObject
---@return EasyList.ListView
function GetListView(go)
    return go:GetCom(ListView)
end

---@param go UnityEngine.GameObject
---@return EasyList.ListPositionView
function GetListPositionView(go)
    return go:GetCom(ListPositionView)
end

---@param go UnityEngine.GameObject
---@return EasyList.ListViewBase
function GetComponent.ListView(go)
    return go:GetCom(ListView)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.Animator
function GetAnimator(go)
    return go:GetCom(Animator)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.Animator
function GetComponent.Animator(go)
    return go:GetCom(Animator)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.TextMesh
function GetText3D(go)
    return go:GetCom(TextMesh)
end

---@param go UnityEngine.GameObject
---@return UnityEngine.TextMesh
function GetComponent.TextMesh(go)
    return go:GetCom(TextMesh)
end