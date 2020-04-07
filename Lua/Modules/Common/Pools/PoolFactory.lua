---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/6/25 14:15
---

---@class Module.Common.Pools.PoolFactory
local PoolFactory = {}

--统计对象池
---@param poolNumMap table<string,number> avatarName 和 数量的映射
---@return table<number,PoolInfo>
function PoolFactory.CalcPoolInfoMap(poolNumMap)
    local poolInfoMap = {} ---@type table<number, PoolInfo>

    --avatar数量 以最大刷怪数量为准
    local avatarMaxNums = {}
    for i = 1, #poolNumMap do
        local nums = poolNumMap[i]
        for avatarName, v in pairs(nums) do
            if avatarMaxNums[avatarName] == nil then
                avatarMaxNums[avatarName] = 0
            end
            if nums[avatarName] > avatarMaxNums[avatarName] then
                avatarMaxNums[avatarName] = nums[avatarName]
            end
        end
    end

    --计算特效数量
    local effectMaxNums = {}
    for avatarName, avatarNum in pairs(avatarMaxNums) do
        table.insert(poolInfoMap, { avatarName = avatarName, initNum = avatarNum})
        local avatarInfo = AvatarConfig.Get(avatarName)
        PoolFactory.GetAvatarPool(effectMaxNums,avatarInfo,avatarNum)
    end
    for effectName, v in pairs(effectMaxNums) do
        table.insert(poolInfoMap, v)
    end

    -- 缓存一个害怕抖动特效
    table.insert(poolInfoMap, {effectName = "fx_doudong", initNum = 1})
    return poolInfoMap
end

--获取Avatar的Effect Pool info
---@param effectMaxNums table<string, PoolInfo>
---@param avatarInfo AvatarInfo
---@return table<number, PoolInfo>
function PoolFactory.GetAvatarPool(effectMaxNums,avatarInfo,avatarNum)
    local addEffectNum
    addEffectNum = function(effectName, num)
        if StringUtil.IsEmpty(effectName) then
            return
        end
        local effectInfo = EffectConfig.Get(effectName)
        if effectInfo and not StringUtil.IsEmpty(effectInfo.endEffect) then
            addEffectNum(effectInfo.endEffect, num)
        end
        if effectMaxNums[effectName] == nil then
            effectMaxNums[effectName] = {effectName = effectName, initNum = 0}
        end
        effectMaxNums[effectName].initNum = effectMaxNums[effectName].initNum + num
    end
    addEffectNum(avatarInfo.bornEffect, avatarNum)
    addEffectNum(avatarInfo.deadEffect, avatarNum)
    if not StringUtil.IsEmpty(avatarInfo.skills) then
        local split = string.split(avatarInfo.skills, ",")
        for i = 1, #split do
            local skill = SkillConfig.Get(split[i])
            addEffectNum(skill.effect, avatarNum)
            for _, animEffect in ipairs(skill.animEffect) do
                addEffectNum(animEffect, avatarNum)
            end
            addEffectNum(skill.hitEffect, 10)
            for j = 1, #skill.accounts do
                if not StringUtil.IsEmpty(skill.accounts[j].buffer) then
                    local buffer = BufferConfig.Get(skill.accounts[j].buffer)
                    addEffectNum(buffer.effect, 10)
                end
            end
        end
    end
    return effectMaxNums
end

return PoolFactory