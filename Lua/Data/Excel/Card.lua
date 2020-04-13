﻿local Data = {
    [100001] = {id = 100001, name = "村民", type = "", avatarName = "Villager_B_Boy", star = 1, level = 1, rarity = 1, rarityLabel = "SR"},
}

function Data.Get(id)
    if Data[id] == nil then
        logError(string.Format('There is no id = %s data is table <Card.xlsx>', tostring(id)))
        return nil
    else
        return Data[id]
    end
end

return Data
                