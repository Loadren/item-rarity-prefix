local AddonName, ItemRarityPrefix = ...

-- This ensures the table is globally accessible
_G[AddonName] = ItemRarityPrefix

-- Setup the rarity prefixes
ItemRarityPrefix.rarityPrefixes = {
    [Enum.ItemQuality.Poor] = ITEM_QUALITY0_DESC,
    [Enum.ItemQuality.Common] = ITEM_QUALITY1_DESC,
    [Enum.ItemQuality.Uncommon] = ITEM_QUALITY2_DESC,
    [Enum.ItemQuality.Rare] = ITEM_QUALITY3_DESC,
    [Enum.ItemQuality.Epic] = ITEM_QUALITY4_DESC,
    [Enum.ItemQuality.Legendary] = ITEM_QUALITY5_DESC,
    [Enum.ItemQuality.Artifact] = ITEM_QUALITY6_DESC,
    [Enum.ItemQuality.Heirloom] = ITEM_QUALITY7_DESC,
    [Enum.ItemQuality.WoWToken] = ITEM_QUALITY8_DESC,
}

-- Function to get item information from a tooltip and handle async loading
function ItemRarityPrefix:GetItemInfo(tooltip, onItemReady)
    local itemLink
    if tooltip.GetItem then
        local _, link = tooltip:GetItem()  -- This works for the main GameTooltip
        itemLink = link
    elseif tooltip.GetTooltipData then
        local data = tooltip:GetTooltipData()
        if data and data.id then
            itemLink = select(2, C_Item.GetItemInfo(data.guid))
        end
    end

    if itemLink then
        local item = Item:CreateFromItemLink(itemLink)
        item:ContinueOnItemLoad(function()
            local itemName = item:GetItemName()
            local itemRarity = item:GetItemQuality()
            if itemName and itemRarity then
                onItemReady(itemName, itemRarity, itemLink)
            end
        end)
    end
end

-- Function to process tooltip data and add an item rarity prefix to item tooltips
function ItemRarityPrefix:ProcessTooltipData(tooltip)
    self:GetItemInfo(tooltip, function(itemName, itemRarity, itemLink)
        local rarityPrefix = ItemRarityPrefix.rarityPrefixes[itemRarity]
        if not rarityPrefix then return end

        local numLines = tooltip:NumLines()

        for i = 1, numLines do
            local leftTextLine = _G[tooltip:GetName() .. "TextLeft" .. i]
            if leftTextLine then
                local tooltipText = leftTextLine:GetText()
                if tooltipText and (tooltipText:find(itemName) or tooltipText == itemName) then
                    -- Define the color you want to set (white in this case)
                    local whiteColorCode = "|cFFFFFFFF"

                    -- If we just have the item name, replace it with the prefixed item name in white
                    if tooltipText == itemName then
                        local newTooltipText = whiteColorCode .. "[" .. rarityPrefix .. "] " .. itemName .. "|r"
                        if newTooltipText ~= tooltipText then
                            leftTextLine:SetText(newTooltipText)
                        end
                        break -- Exit the loop as we've done what we needed
                    end
                end
            end
        end
    end)
end

-- Register the function for the main item tooltip
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
    if tooltip:GetName() == "GameTooltip" then
        ItemRarityPrefix:ProcessTooltipData(tooltip)
    end
end)

-- Register the function for the first comparison tooltip
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
    if tooltip:GetName() == "ShoppingTooltip1" then
        ItemRarityPrefix:ProcessTooltipData(tooltip)
    end
end)

-- Register the function for the second comparison tooltip (if it exists)
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
    if tooltip:GetName() == "ShoppingTooltip2" then
        ItemRarityPrefix:ProcessTooltipData(tooltip)
    end
end)
