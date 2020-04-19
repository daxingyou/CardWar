---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/5/6 17:35
---


---@class AccountInfo
---@field id string
---@field name string
---@field type number
---@field gridSelect string
---@field targetMode string

local AccountConfig = {}

---@return AccountInfo
function AccountConfig.Get(name)
    if AccountConfig.data == nil then
        AccountConfig.data = require("Game.Data.Excel.Account")
    end
    local info = AccountConfig.data.Get(name) ---@type AccountInfo
    if info == nil then
        logError(string.format("There is not account info named %s!", name))
    end
    return info
end

return AccountConfig