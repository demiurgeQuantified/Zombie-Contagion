local previousPrice

-- TODO: it shows in the wrong list if you change the price and then go back to a preset difficulty (who cares, low prio)
-- TODO: we don't really need to remove the trait from the selection if it now grants more points
-- also consider not removing it the player can still afford it in general
local function updateTraitPrice()
    local ccp = MainScreen.instance.charCreationProfession
    local trait = TraitFactory.getTrait("Carrier")
    local label = trait:getLabel()

    if SandboxVars.ZContagion.CarrierChance == 2 then
        local newCost = trait:getCost()

        --only remove traits if the price has actually changed
        if previousPrice == newCost then return end

        --determine if trait is purchased before clearing ccp.listboxTraitSelected
        local traitIsPurchased = false
        local selectedItems = ccp.listboxTraitSelected.items
        for i=1, #selectedItems do
            if selectedItems[i].item == trait then
                traitIsPurchased = true
                break
            end
        end

        ccp.listboxTrait:removeItem(label)
        ccp.listboxBadTrait:removeItem(label)
        ccp.listboxTraitSelected:removeItem(label)

        -- readd it
        local item
        if newCost > 0 then
            item = ccp.listboxTrait:addItem(label, trait)
        else
            item = ccp.listboxBadTrait:addItem(label, trait)
        end
        item.tooltip = trait:getDescription()

        --adjust available points only if traitIsPurchased
        if traitIsPurchased then
            ccp.pointToSpend = ccp.pointToSpend + previousPrice
        end

        CharacterCreationMain.sort(ccp.listboxTrait.items)
        CharacterCreationMain.invertSort(ccp.listboxBadTrait.items)
        CharacterCreationMain.sort(ccp.listboxTraitSelected.items)
        previousPrice = newCost
    else
        ccp.listboxTrait:removeItem(label)
        ccp.listboxBadTrait:removeItem(label)
        ccp.listboxTraitSelected:removeItem(label)
        previousPrice = nil
    end
end

local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self SandboxOptionsScreen
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    updateTraitPrice()
end

Events.OnConnected.Add(updateTraitPrice)