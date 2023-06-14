local previousPrice = 0

local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self SandboxOptionsScreen
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    local trait = TraitFactory.getTrait("Carrier")
    local ccp = MainScreen.instance.charCreationProfession

    
    --cleanup old trait
    local label = trait:getLabel()
    
    --determine if trait is purchased before clearing ccp.listboxTraitSelected
    local traitIsPurchased = false
    for _,v in ipairs(ccp.listboxTraitSelected.items) do
        if v.item:getLabel() == label then 
            traitIsPurchased = true 
        end
    end

    --only remove traits if the price has actually changed
    local oldItem 
    if(previousPrice ~= trait:getCost()) then
        oldItem = ccp.listboxTrait:removeItem(label)
            or ccp.listboxBadTrait:removeItem(label)
            or ccp.listboxTraitSelected:removeItem(label)
    end

    if oldItem then -- readd it
        local newItem
        if trait:getCost() > 0 then
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
    end
    previousPrice = trait:getCost()
end