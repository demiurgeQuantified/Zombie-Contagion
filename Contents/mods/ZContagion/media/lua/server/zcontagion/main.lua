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
if isClient() then return end
local Config = require "zcontagion/mainvariables"
local ZContagion = {}
ZContagion.isTransmitting = false

local onlinePlayers = getOnlinePlayers()

---@param player IsoPlayer
function ZContagion.infectPlayer(player)
    sendServerCommand(player, 'ZContagion', 'infectPlayer', {index=player:getOnlineID() % 4})
end

---@param player IsoPlayer
---@return boolean
function ZContagion.canPlayerBeInfected(player)
    local modData = player:getModData()

    local lastInfected = modData.lastInfected
    if not lastInfected then
        return modData.canBeInfected
    end

    lastInfected = lastInfected + Config.PostInfectionImmuneHours
    --TODO: cache GameTime
    return modData.canBeInfected and lastInfected <= getGameTime():getWorldAgeHours()
end

---@param player1 IsoPlayer
---@param player2 IsoPlayer
---@return boolean
function ZContagion.playersIndoors(player1, player2)
	return player1:CanSee(player2) and player1:getBuilding() and player2:getBuilding() ~= nil
end

---@param transmitter IsoPlayer
---@return table<int, IsoPlayer>, table<int, IsoPlayer>
function ZContagion.getPlayersInRange(transmitter)
    local players = {}
    local indoorsPlayers = {}
    for i = 0, onlinePlayers:size()-1 do
        local player = onlinePlayers:get(i)
        if ZContagion.canPlayerBeInfected(player) then
            local distance = transmitter:DistToSquared(player)
            if distance <= Config.InfectionRange then
                table.insert(players, player)
            elseif distance <= Config.InfectionRangeIndoors and ZContagion.playersIndoors(transmitter, player) then
                table.insert(indoorsPlayers, player)
            end
        end
    end
    return players, indoorsPlayers
end

-- TODO: a lot of this code can be made more efficient by caching the modifiers to a player's infectivity/infection risk

---@param player IsoPlayer
---@return number
function ZContagion.calculateInfectivity(player)
    local modData = player:getModData()

    local infectivity = modData.infectionProgress
    if infectivity >= 1 then -- y = (log(x)^2)/4
        infectivity = math.log10(infectivity)
        infectivity = infectivity * infectivity
        infectivity = infectivity * 0.25
    end
    
    if player:HasTrait("Carrier") then
        -- TODO: don't use the math library, reimplement it
        infectivity = math.max(Config.CarrierInfectivity, infectivity)
    end

    local maskModifier = modData.maskModifier
    if maskModifier == 'gasmask' then maskModifier = 1 end
    if maskModifier ~= 1 then maskModifier = maskModifier / Config.TransmitterMaskEffectiveness end

    infectivity = infectivity * maskModifier
    return infectivity
end

---@param player IsoPlayer
---@param infectivity number
function ZContagion.tryInfectPlayer(player, infectivity)
    local modData = player:getModData()
    if (SandboxVars.ZContagion.SusceptibleMultiplier == 0 and player:HasTrait("Susceptible") and modData.maskModifier ~= 'gasmask') then
        ZContagion.infectPlayer(player)
    else
        local infectionRisk = modData.maskModifier
        if infectionRisk == 'gasmask' then infectionRisk = 0 end

        infectionRisk = infectionRisk + modData.injuries * Config.InjuryMultiplier
        if infectionRisk == 0 then return end

        if player:HasTrait("Resilient") then
            infectionRisk = infectionRisk * Config.ResilientMultiplier
        elseif player:HasTrait("ProneToIllness") then
            infectionRisk = infectionRisk * Config.ProneToIllnessMultiplier
        end
        if player:HasTrait("Susceptible") then
            infectionRisk = infectionRisk * SandboxVars.ZContagion.SusceptibleMultiplier
        end

        infectionRisk = infectionRisk * Config.InfectionChance
        if ZombRandFloat(0, 100) <= infectionRisk * infectivity then
            ZContagion.infectPlayer(player)
        end
    end 
end

function ZContagion.transmission()
    local hasInfectedPlayer = false
    for i = 0, onlinePlayers:size()-1 do
        local player = onlinePlayers:get(i)
        if player:getModData().infectious then
            hasInfectedPlayer = true
            local infectivity = ZContagion.calculateInfectivity(player)
            local players, indoorsPlayers = ZContagion.getPlayersInRange(player)

            for j = 1, #players do
                ZContagion.tryInfectPlayer(players[j], infectivity)
            end
            for j = 1, #indoorsPlayers do
                ZContagion.tryInfectPlayer(indoorsPlayers[j], infectivity * Config.InfectionChanceIndoorsMultiplier)
            end
        end
    end
    if not hasInfectedPlayer then
        Events.EveryOneMinute.Remove(ZContagion.transmission)
        ZContagion.isTransmitting = false
    end
end

function ZContagion.beginTransmission()
    if not ZContagion.isTransmitting then
        Events.EveryOneMinute.Add(ZContagion.transmission)
        ZContagion.isTransmitting = true
    end
end

return ZContagion