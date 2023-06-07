local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self CharacterCreationProfession
---@param visible boolean
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    local trait = TraitFactory.getTrait("Carrier")
    local ccp = MainScreen.instance.charCreationProfession

    --cleanup old trait
    local label = trait:getLabel()
    local olditem = ccp.listboxTrait:removeItem(label)
            or ccp.listboxBadTrait:removeItem(label)
            or ccp.listboxTraitSelected:removeItem(label)

    if not olditem then return end

    --readd it
    local newItem
    if trait:getCost() > 0 then
        newItem = ccp.listboxTrait:addItem(label, trait)
    else
        newItem = ccp.listboxBadTrait:addItem(label, trait)
    end
    newItem.tooltip = trait:getDescription()

    CharacterCreationMain.sort(ccp.listboxTrait.items)
    CharacterCreationMain.invertSort(ccp.listboxBadTrait.items)
    CharacterCreationMain.sort(ccp.listboxTraitSelected.items)
end