---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2020/6/23 22:29
--- 导航
---

--导航页面
---@class NavigationPage
---@field label string
---@field views List | table<number, Game.Manager.ViewInfo>
---@field loadedViews List | table<number, Game.Manager.ViewInfo>

local LuaMonoBehaviour = require("Betel.LuaMonoBehaviour")
---@class Game.Modules.Lobby.View.Navigation : Betel.LuaMonoBehaviour
---@field New():Game.Modules.Lobby.View.Navigation
---@field navigationPages table<number, NavigationPage>
local Navigation = class("Game.Modules.Lobby.View.Navigation", LuaMonoBehaviour)

function Navigation:Ctor()

end

function Navigation:Init()
    if self.navigationPages == nil then
        self.navigationPages =
        {
            [1] = {
                label = "主页",
                views = List.New({ViewConfig.RoleInfo}),
                loadedViews = List.New(),
            },
            [2] = {
                label = "卡片",
                views = List.New({ViewConfig.CardList}),
                loadedViews = List.New(),
            },
            [3] = {
                label = "剧情",
                views = List.New(),
                loadedViews = List.New(),
            },
            [4] = {
                label = "冒险",
                views = List.New({ViewConfig.Adventure, ViewConfig.ResourceBar}),
                loadedViews = List.New(),
            },
            [5] = {
                label = "家园",
                views = List.New(),
                loadedViews = List.New(),
            },
            [6] = {
                label = "抽卡",
                views = List.New({ViewConfig.CardDraw, ViewConfig.ResourceBar}),
                loadedViews = List.New(),
            },
            [7] = {
                label = "物品",
                views = List.New(),
                loadedViews = List.New(),
            },
        }
    end
    self.currPageIndex = 0
end

function Navigation:NavigateTo(pageIndex, callback)
    self:PopAll(function()
        local newPage = self.navigationPages[pageIndex]
        self.currPageIndex = pageIndex
        --加载新页面的视图
        for i = 1, newPage.views:Size() do
            vmgr:LoadView(newPage.views[i])
            newPage.loadedViews:Add(newPage.views[i])
        end
        if callback then
            callback()
        end
    end)
end

--入栈
---@param viewInfo Game.Manager.ViewInfo
function Navigation:Push(viewInfo)
    local currPage = self.navigationPages[self.currPageIndex]
    if currPage.loadedViews:Contain(viewInfo) then
        logError("This view has already loaded! - " .. viewInfo.name)
    else
        vmgr:LoadView(viewInfo)
        currPage.loadedViews:Add(viewInfo)
    end
end

--出栈
function Navigation:Pop(viewInfo, callback)
    local currPage = self.navigationPages[self.currPageIndex]
    if currPage.loadedViews:Remove(viewInfo) > 0 then
        self:StartCoroutine(function()
            local loadedOver = false
            vmgr:UnloadView(viewInfo, function()
                loadedOver = true
            end)
            while not loadedOver do
                coroutine.step()
            end
            if callback then
                callback()
            end
        end)
    else
        logError("Pop view has not exit! - " .. viewInfo.name)
    end
end

function Navigation:PopAll(callback)
    local currPage = self.navigationPages[self.currPageIndex]
    if currPage then
        self:StartCoroutine(function()
            --卸载上个页面的所有视图
            local count = currPage.loadedViews:Size()
            for i = 1, currPage.loadedViews:Size() do
                vmgr:UnloadView(currPage.loadedViews[i], function()
                    count = count - 1
                end)
            end
            currPage.loadedViews:Clear()
            while count > 0 do
                coroutine.step()
            end
            if callback then
                callback()
            end
        end)
    else
        if callback then
            callback()
        end
    end
end

function Navigation:Clear(callback)
    self:PopAll(callback)
    vmgr:UnloadView(ViewConfig.Navigation)
end

return Navigation