---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-06-01-22:42:27
---

local BaseMediator = require("Game.Core.Ioc.BaseMediator")
---@class Game.Modules.Lobby.View.LobbyMdr : Game.Core.Ioc.BaseMediator
---@field lobbyModel Game.Modules.Lobby.Model.LobbyModel
---@field roleModel Game.Modules.Role.Model.RoleModel
---@field lobbyService Game.Modules.Lobby.Service.LobbyService
---@field cardService Game.Modules.Card.Service.CardService
---@field itemService Game.Modules.Item.Service.ItemService
local LobbyMdr = class("Game.Modules.Lobby.View.LobbyMdr",BaseMediator)

function LobbyMdr:OnInit()
    self.cardService:getCardList(self.roleModel.roleInfo.id, handler(self, self.OnCardList))
    self.itemService:getItemList(self.roleModel.roleInfo.id, handler(self, self.OnItemList))
    vmgr:LoadView(ViewConfig.Navigation)
end

function LobbyMdr:OnCardList(data)

end

function LobbyMdr:OnItemList(data)

end

return LobbyMdr
