local previousPrice = 0

local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self SandboxOptionsScreen
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    local trait = TraitFactory.getTrait("Carrier")
    local ccp = MainScreen.instance.charCreationProfession

    --cleanup old trait
    local label = trait:getLabel()
    local olditem = ccp.listboxTrait:removeItem(label)
            or ccp.listboxBadTrait:removeItem(label)
            or ccp.listboxTraitSelected:removeItem(label)

    if olditem then -- readd it
        local newItem
        if trait:getCost() > 0 then
            newItem = ccp.listboxTrait:addItem(label, trait)
        else
            newItem = ccp.listboxBadTrait:addItem(label, trait)
        end
        newItem.tooltip = trait:getDescription()
        ccp.pointToSpend = ccp.pointToSpend + previousPrice

        CharacterCreationMain.sort(ccp.listboxTrait.items)
        CharacterCreationMain.invertSort(ccp.listboxBadTrait.items)
        CharacterCreationMain.sort(ccp.listboxTraitSelected.items)
    end
    previousPrice = trait:getCost()
end