---
--- Generated by Tools
--- Created by zheng.
--- DateTime: 2020-04-12-18:19:57
---

local SceneItemVo = require("Game.Modules.World.Vo.SceneUnitVo")
---@class Game.Modules.World.Vo.AvatarVo : Game.Modules.World.Vo.SceneUnitVo
---@field New fun():Game.Modules.World.Vo.AvatarVo
---@field avatarInfo AvatarInfo
---@field level number
local AvatarVo = class("Game.Modules.World.Vo.AvatarVo",SceneItemVo)

function AvatarVo:Ctor()

end

---@param avatarName string
function AvatarVo:Init(avatarName)
    self.avatarInfo = AvatarConfig.Get(avatarName)
end

function AvatarVo:Dispose()

end

return AvatarVo
