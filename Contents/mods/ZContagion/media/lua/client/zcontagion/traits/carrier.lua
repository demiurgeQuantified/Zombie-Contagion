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
local Carrier = {}

---@type table<int, int>
Carrier.carrierChances = {
    [1] = 0,
    [2] = 0,
    [3] = 15,
    [4] = 30,
    [5] = 50
}

---@type table<string, number>
Carrier.traitModifiers = {
    ProneToIllness = -0.7,
    Resilient = 0.7,
    Lucky = 0.1,
    Unlucky = -0.1,
    Outdoorsman = 0.1,
    Asthmatic = -0.2,
    Smoker = -0.2
}

---@type table<string, boolean>
Carrier.bannedTraits = {
    Susceptible = true
}

---@param player IsoPlayer
Carrier.OnPlayerDeath = function(player)
    if not player:HasTrait("Carrier") then return end
    player:getBodyDamage():setInfectionLevel(1)
end

Events.OnPlayerDeath.Add(Carrier.OnPlayerDeath)

---@param player IsoPlayer
---@return int
Carrier.getCarrierChance = function(player)
    local chance = Carrier.carrierChances[SandboxVars.ZContagion.CarrierChance]
    if chance == 0 then return 0 end

    local traitMult = 1

    local traits = player:getTraits()
    for i = 0, traits:size()-1 do
        local trait = traits:get(i)

        if Carrier.bannedTraits[trait] then return 0 end

        local traitMod = Carrier.traitModifiers[trait]
        if traitMod then
            traitMult = traitMult + traitMod
        end
    end

    chance = chance * traitMult
    return math.max(math.floor(chance), 0)
end

---@param player IsoPlayer
---@param square IsoGridSquare
Carrier.OnNewGame = function(player, square)
    if ZombRand(100) + 1 <= Carrier.getCarrierChance(player) then
        player:getTraits():add("Carrier")
    end
end
Events.OnNewGame.Add(Carrier.OnNewGame)

return Carrier