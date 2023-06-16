local previousPrice = 0

-- TODO: it shows in the wrong list if you change the price and then go back to a preset difficulty (who cares, low prio)
-- TODO: we don't really need to remove the trait from the selection if it now grants more points
-- also consider not removing it the player can still afford it in general
local function updateTraitPrice()
    local trait = TraitFactory.getTrait("Carrier")
    local newCost = trait:getCost()

    --only remove traits if the price has actually changed
    if previousPrice == newCost then return end

    local ccp = MainScreen.instance.charCreationProfession
    local label = trait:getLabel()

    --determine if trait is purchased before clearing ccp.listboxTraitSelected
    local traitIsPurchased = false
    local selectedItems = ccp.listboxTraitSelected.items
    for i=1, #selectedItems do
        if selectedItems[i].item == trait then
            traitIsPurchased = true
            break
        end
    end

    local oldItem = ccp.listboxTrait:removeItem(label)
            or ccp.listboxBadTrait:removeItem(label)
            or traitIsPurchased and ccp.listboxTraitSelected:removeItem(label)
    if not oldItem then return end

    -- readd it
    local newItem
    if newCost > 0 then
        newItem = ccp.listboxTrait:addItem(label, trait)
    else
        newItem = ccp.listboxBadTrait:addItem(label, trait)
    end
    newItem.tooltip = trait:getDescription()

    --adjust available points only if traitIsPurchased
    if traitIsPurchased then
        ccp.pointToSpend = ccp.pointToSpend + previousPrice
    end

    CharacterCreationMain.sort(ccp.listboxTrait.items)
    CharacterCreationMain.invertSort(ccp.listboxBadTrait.items)
    CharacterCreationMain.sort(ccp.listboxTraitSelected.items)
    previousPrice = newCost
end

local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self SandboxOptionsScreen
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    updateTraitPrice()
end

Events.OnConnected.Add(updateTraitPrice)