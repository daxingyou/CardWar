---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zheng.
--- DateTime: 2019/1/19 0:21
---

local ListItemRenderer = require("Betel.UI.ListItemRenderer")
---@class Game.Modules.CheckPoint.View.CheckPointItem: Betel.UI.ListItemRenderer
local CheckPointItem = class("Game.Modules.CheckPoint.View.CheckPointItem",ListItemRenderer)

---@param gameObject UnityEngine.GameObject
function CheckPointItem:Ctor(gameObject)
    CheckPointItem.super.Ctor(self,gameObject)
end

---@param sectionVo Game.Modules.CheckPoint.Vo.SectionVo
function CheckPointItem:UpdateItem(sectionVo, index)
    --local frameImg = self.gameObject:GetImage("")
    --frameImg.sprite = Res.LoadSprite(RankFrameUrl[cardVo.cardInfo.rarity])

    --local maskImg = self.gameObject:GetImage("Mask")
    --maskImg.gameObject:SetActive(not cardVo.active)

    local iconImg = self.gameObject:GetImage("Icon")
    iconImg.sprite = Res.LoadSprite(sectionVo.checkPointData.iconUrl)
    iconImg:SetNativeSize()

    local starBar = self.gameObject:FindChild("StarBar")
    self:SetStar(starBar, sectionVo.star)

    local text = self.gameObject:GetText("Text")
    text.text = sectionVo.name
end

---@param starBar UnityEngine.GameObject
function CheckPointItem:SetStar(starBar, starNum)
    for i = 1, starBar.transform.childCount do
        local starImg = starBar.transform:GetChild(i - 1).gameObject:GetImage()
        starImg.sprite = UITools.GetSprite(starImg.gameObject, i <= starNum and 1 or 0)
    end
end

function CheckPointItem:OnDestroy()

end

return CheckPointItem