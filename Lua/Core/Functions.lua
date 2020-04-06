---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/5/26 0:58
---


local _handler = handler
local _EventMap = {} ---@type table<string, fun()>
local Ticker_Sid = 1

---
---@param type string
---@param callback fun()
---@param caller any
function AddEventListener(type, callback, caller)
    if callback == nil or caller == nil then
        logError("error params! callback or caller can not be nil!")
        return
    end
    local list = _EventMap[type]
    if list == nil then
        list = {}
        _EventMap[type] = list
    else
        for i = 1, #list do
            if tostring(list[i].callback) == tostring(callback) and tostring(list[i].caller) == tostring(caller) then
            --if list[i].callback == callback and list[i].caller == caller then
                --logError("re add EventListener!")
                return
            end
        end
    end
    local handler = Handler.New(callback, caller)
    table.insert(list, handler)
    if type == Event.Update then
        monoMgr:AddUpdateFun(handler.Delegate)
    elseif type == Event.LateUpdate then
        monoMgr:AddLateUpdateFun(handler.Delegate)
    elseif type == Event.FixedUpdate then
        monoMgr:AddFixedUpdateFun(handler.Delegate)
    end
end

function RemoveEventListener(type, callback, caller)
    if callback == nil then
        logError("error params! callback or caller can not be nil!")
        return
    end
    local list = _EventMap[type]
    if list == nil then
        return
    end
    local del = {}
    for i = 1, #list do
        if tostring(list[i].callback) == tostring(callback) and tostring(list[i].caller) == tostring(caller) then
        --if list[i].callback == callback and list[i].caller == caller then
            if type == Event.Update then
                monoMgr:RemoveUpdateFun(list[i].Delegate)
            elseif type == Event.LateUpdate then
                monoMgr:RemoveLateUpdateFun(list[i].Delegate)
            elseif type == Event.FixedUpdate then
                monoMgr:RemoveFixedUpdateFun(list[i].Delegate)
            end
            table.insert(del, i)
        end
    end
    for i = 1, #del do
        table.remove(list,del[i])
    end
end


---============================
--- Delay Call
---============================
local _DelayEventMap = {} ---@type table<string, Handler>

local function update()
    local del = {}
    for k, handler in pairs(_DelayEventMap) do
        if Time.time - handler.startTime > handler.delay then
            handler:Execute()
            table.insert(del, k)
        end
    end
    for i = 1, #del do
        table.remove(_DelayEventMap,del[i])
    end
end

local function delayStart()
    monoMgr:AddUpdateFun(update)
end

---@param delay number
---@param handler Handler
function DelayCallback(delay, handler)
    local id = Ticker_Sid;
    Ticker_Sid = Ticker_Sid + 1
    local key = tostring(handler)
    if ticker:Contain(id) then
        return
    end
    ticker:DelayCallback(id,delay,function()
        handler:Execute()
    end)
    --handler.startTime = Time.time
    --handler.delay = delay
    return handler
end

---@param handler Handler
function CancelDelayCallback(handler)
    local key = tostring(handler)
    ticker:CancelDelayCallback(key)
end

delayStart()