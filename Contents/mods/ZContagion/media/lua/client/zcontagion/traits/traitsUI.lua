--[[ZOMBIE CONTAGION
    Copyright (C) 2023 albion

    This program is free software: you can redistribute it and/or modify
    it under the terms of Version 3 of the GNU Affero General Public License as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    For any questions, contact me through steam or on Discord - albion#0123
]]
local TraitsUI = {}

-- TODO: it shows in the wrong list if you change the price and then go back to a preset difficulty (who cares, low prio)
-- TODO: we don't really need to remove the trait from the selection if it now grants more points
-- also consider not removing if the player can still afford it in general
TraitsUI.updateTraitPrice = function()
    local ccp = MainScreen.instance.charCreationProfession
    local trait = TraitFactory.getTrait("Carrier")
    local label = trait:getLabel()

    if SandboxVars.ZContagion.CarrierChance == 2 then
        local newCost = trait:getCost()

        --only remove traits if the price has actually changed
        if TraitsUI.previousPrice == newCost then return end

        ccp.listboxTrait:removeItem(label)
        ccp.listboxBadTrait:removeItem(label)
        local traitIsPurchased = ccp.listboxTraitSelected:removeItem(label)

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
            ccp.pointToSpend = ccp.pointToSpend + TraitsUI.previousPrice
        end

        CharacterCreationMain.sort(ccp.listboxTrait.items)
        CharacterCreationMain.invertSort(ccp.listboxBadTrait.items)
        CharacterCreationMain.sort(ccp.listboxTraitSelected.items)
        TraitsUI.previousPrice = newCost
    else
        ccp.listboxTrait:removeItem(label)
        ccp.listboxBadTrait:removeItem(label)
        ccp.listboxTraitSelected:removeItem(label)
        TraitsUI.previousPrice = nil
    end
end

local old_setSandboxVars = SandboxOptionsScreen.setSandboxVars
---@param self SandboxOptionsScreen
SandboxOptionsScreen.setSandboxVars = function(self)
    old_setSandboxVars(self)
    TraitsUI.updateTraitPrice()
end

Events.OnConnected.Add(TraitsUI.updateTraitPrice)

return TraitsUI