---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2018-07-13-00:00:21
---

---@class ServerInfo
---@field type string
---@field name string
---@field host string
---@field port number

local ServerItem = require("Game.Modules.Login.View.ServerItem")
local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Login.View.ServerListMdr : Game.Core.Ioc.BaseMediator
---@field loginService Game.Modules.Login.Service.LoginService
---@field loginModel Game.Modules.Login.Model.LoginModel
local ServerListMdr = class("ServerListMdr",BaseMediator)

function ServerListMdr:OnInit()
    self:InitSrvList()
end

function ServerListMdr:RegisterListeners()
    --self:AddPush(Action.PlayerInfo, handler(self,self.onPlayerInfo));
end

function ServerListMdr:InitSrvList()
    self.srvList = TableList.New(self.gameObject:FindChild("ListView"),ServerItem)
    self.srvList:SetData(List.New(self.loginModel.serverList))
    self.srvList.eventDispatcher:AddEventListener(ListViewEvent.ItemClick,self.onSrvItemClick, self)
end

function ServerListMdr:onSrvItemClick(event, data)
    log(string.format("nmgr:Connect %s:%s - %s",data.host,data.port,data.type))
    if data.type == "http" then
        nmgr.httpUrl = string.format("http://%s:%s",data.host,data.port)
        self:onConnectSuccess()
    else
        nmgr:Connect(data.host, tonumber(data.port),
                handler(self,self.onConnectSuccess),
                handler(self,self.onConnectFail))
    end
end

function ServerListMdr:onConnectSuccess()
    print("onConnectSuccess")
    self.loginService:LoginGameServer(
            self.loginModel.aid,
            self.loginModel.token,
            handler(self,self.onLoginLobbyServerSuccess),
            handler(self,self.onLoginLobbyServerFail))
end

function ServerListMdr:onConnectFail()
    print("onConnectFail")
end

function ServerListMdr:onLoginLobbyServerSuccess(data)
    vmgr:UnloadView(ViewConfig.ServerList)
    if data.roleInfo == nil then
        vmgr:LoadView(ViewConfig.RoleCreate)--创建角色
    else
        --World.EnterScene(WorldConfig.Lobby)
        --World.EnterScene(WorldConfig.GuideScene)
        --vmgr:LoadView(ViewConfig.RoleSelect)--选择角色进入游戏
        World.EnterScene(WorldConfig.Battle)
    end
end

function ServerListMdr:onLoginLobbyServerFail(data)
    print("onLoginLobbyServerFail")
end

return ServerListMdr
