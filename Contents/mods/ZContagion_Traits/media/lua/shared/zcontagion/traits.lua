--[[ZOMBIE CONTAGION
    Copyright (C) 2022 albion

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

Events.OnGameBoot.Add(function()
    TraitFactory.addTrait("Carrier", getText("UI_trait_carrier"), 2, getText("UI_trait_carrierdesc"), false)
    TraitFactory.setMutualExclusive("Carrier", "ProneToIllness")
    if getActivatedMods():contains("Susceptible") then
        TraitFactory.setMutualExclusive("Carrier", "Susceptible")
    end
end)

local metatable = __classmetatables[Trait.class].__index

local old_getCost = metatable.getCost
---@param self Trait
metatable.getCost = function(self)
    if self:getType() == "Carrier" then
        return SandboxVars.ZContagion.CarrierCost
    end
    return old_getCost(self)
end

local old_getRightLabel = metatable.getRightLabel
---@param self Trait
metatable.getRightLabel = function(self)
    if self:getType() == "Carrier" then
        local cost = SandboxVars.ZContagion.CarrierCost
        local label = "+"
        if cost > 0 then
            label = "-"
        elseif cost == 0 then
            label = ""
        end

        if cost < 0 then cost = cost * -1 end

        return label..cost
    end
    return old_getRightLabel(self)
end