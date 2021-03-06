---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/6/5 11:58
---

---@class TimeConvert
local TimeConvert = {}



--=------------------------------[ static ]------------------------------=--

--- 时间类型：毫秒
TimeConvert.TYPE_MS = "ms"
--- 时间类型：秒
TimeConvert.TYPE_S = "s"
--- 时间类型：分钟
TimeConvert.TYPE_M = "m"
--- 时间类型：小时
TimeConvert.TYPE_H = "h"


--- 当前程序已运行精确时间（秒.毫秒），不会受到 Time.timeScale 影响。由 Update / LateUpdate / FixedUpdate 事件更新
TimeConvert.time = 0
--- 当前程序已运行时间（毫秒）
TimeConvert.timeMsec = 0

--- 当前程序已运行帧数（ value = UnityEngine.Time.frameCount ）
TimeConvert.frameCount = UnityEngine.Time.frameCount
--- 距离上一帧的时间（秒.毫秒）
TimeConvert.deltaTime = 0



--- 转换时间类型
---@param typeFrom string
---@param typeTo string
---@param time number
---@return number
function TimeConvert.Convert(typeFrom, typeTo, time)
    if typeFrom == typeTo then
        return time
    end

    -- 转换成毫秒
    if typeFrom == TimeConvert.TYPE_S then
        time = time * 1000
    elseif typeFrom == TimeConvert.TYPE_M then
        time = time * 60000
    elseif typeFrom == TimeConvert.TYPE_H then
        time = time * 3600000
    end

    -- 返回指定类型
    if typeTo == TimeConvert.TYPE_S then
        return time / 1000
    elseif typeTo == TimeConvert.TYPE_M then
        return time / 60000;
    elseif typeTo == TimeConvert.TYPE_H then
        return time / 3600000;
    end

    return time
end

--返回时间转换后的 时分秒 数字
---@return number, number, number
function TimeConvert.Time_ConvertNum(t, typeFrom)
    local nt = t or 0
    local typeFrom = typeFrom or TimeConvert.TYPE_MS
    nt = TimeConvert.Convert(typeFrom, TimeConvert.TYPE_MS, nt)

    nt = math.ceil(nt /1000) -- 转为秒

    local s = nt % 60 -- 秒
    local ls = math.floor( nt / 60 ) --分钟

    local m = ls % 60 -- 分钟
    local lm = math.floor(ls / 60) --小时

    local h = lm  -- 小时

    return h,m,s
end

---时间转换为(00:000)格式字符串 0~59秒 0~999毫秒
---@param t number @时间
---@return string
function TimeConvert.Time_toString0(t,typeFrom)
    local nt = t or 0
    local typeFrom = typeFrom or TimeConvert.TYPE_MS
    nt = TimeConvert.Convert(typeFrom, TimeConvert.TYPE_MS, nt)
    --nt = math.ceil(nt /1000) -- 转为秒

    local ms = nt % 1000 -- 毫秒
    local ls = math.floor(nt / 1000) --秒

    return string.format("%02d:%03d", ls, ms)
end

---时间转换为(00:00)格式字符串
---@param t number @时间
---@return string
function TimeConvert.Time_toString1(t, typeFrom)
    local nt = t or 0
    local typeFrom = typeFrom or TimeConvert.TYPE_MS
    nt = TimeConvert.Convert(typeFrom, TimeConvert.TYPE_MS, nt)

    nt = math.ceil(nt /1000) -- 转为秒

    local s = nt % 60 -- 秒
    local ls = math.floor( nt / 60 ) --分钟

    local m = ls % 60 -- 分钟
    local lm = math.floor(ls / 60) --小时

    local h = lm  -- 小时

    local timeString

    if h > 0 then
        timeString = string.format("%02d:%02d", h, m)
    else
        timeString = string.format("%02d:%02d", m, s)
    end

    return timeString
end

---时间转换为(00:00:00)格式字符串
---@param t number @时间 毫秒
---@return string
function TimeConvert.Time_toString2(t, typeFrom)
    local nt = t or 0
    local typeFrom = typeFrom or TimeConvert.TYPE_MS
    nt = TimeConvert.Convert(typeFrom, TimeConvert.TYPE_MS, nt)

    nt = math.ceil(nt /1000) -- 转为秒

    local s = nt % 60 -- 秒
    local ls = math.floor( nt / 60 ) --分钟

    local m = ls % 60 -- 分钟
    local lm = math.floor(ls / 60) --小时

    local h = lm  -- 小时
    local timeString
    if h > 99 then
        --超过两位数则直接显示
        timeString = string.format("%d:%02d:%02d", h, m, s)
    else
        timeString = string.format("%02d:%02d:%02d", h, m, s)
    end

    return timeString
end

---时间转换为 00h00m | 00m00s 格式字符串
---@param t number @时间
---@return string
function TimeConvert.Time_toString3(t, typeFrom)
    local nt = t or 0
    local typeFrom = typeFrom or TimeConvert.TYPE_MS
    nt = TimeConvert.Convert(typeFrom, TimeConvert.TYPE_MS, nt)

    nt = math.ceil(nt /1000) -- 转为秒

    local s = nt % 60 -- 秒
    local ls = math.floor( nt / 60 ) --分钟

    local m = ls % 60 -- 分钟
    local lm = math.floor(ls / 60) --小时

    local h = lm  -- 小时

    local timeString

    if h > 0 then
        timeString = string.format("%02dh%02dm", h, m)
    else
        timeString = string.format("%02dm%02ds", m, s)
    end

    return timeString
end

--=----------------------------------------------------------------------=--



return TimeConvert