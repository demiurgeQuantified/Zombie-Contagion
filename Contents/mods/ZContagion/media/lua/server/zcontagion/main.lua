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
if not isServer() then return end
ZContagion = {}

ZContagion.isTransmitting = false
local onlinePlayers = getOnlinePlayers()
local arraySize = ArrayList.size
local arrayGet = ArrayList.get

local function infectPlayer(player)
    sendServerCommand(player, 'ZContagion', 'infectPlayer', {})
end

local function canPlayerBeInfected(player)
    local lastInfected = player:getModData()['lastInfected'] or -ZContagion.PostInfectionImmuneHours
    lastInfected = lastInfected + ZContagion.PostInfectionImmuneHours
    return player:getModData()['canBeInfected'] and (lastInfected <= getGameTime():getWorldAgeHours())
end

local function playersIndoors(player1, player2) -- could check if it was the same building, but seems like it would never matter
	return player1:CanSee(player2) and player1:getBuilding() and player2:getBuilding()
end

local function getPlayersInRange(transmitter)
    local playersList = {}
    for i = 0, arraySize(onlinePlayers)-1 do
        local player = arrayGet(onlinePlayers, i)
        if canPlayerBeInfected(player) then
            local distance = transmitter:DistToSquared(player)
            if distance <= ZContagion.InfectionRange then
                table.insert(playersList, player)
            elseif distance <= ZContagion.InfectionRangeIndoors and playersIndoors(transmitter, player) then
                table.insert(playersList, {player, true})
            end
        end
    end
    return playersList
end

local function calculateInfectivity(player)
    local playerModData = player:getModData()

    local infectivity = playerModData['infectionProgress']
    if infectivity >= 1 then -- y = (log(x)^2)/4
        infectivity = math.log10(infectivity)
        infectivity = infectivity * infectivity
        infectivity = infectivity * 0.25
    end
    
    if player:HasTrait("Carrier") then
        infectivity = math.max(ZContagion.CarrierInfectivity, infectivity)
    end

    local maskModifier = playerModData['maskModifier']
    if maskModifier == 'gasmask' then maskModifier = 1 end
    if maskModifier ~= 1 then maskModifier = maskModifier / ZContagion.TransmitterMaskEffectiveness end

    infectivity = infectivity * maskModifier
    return infectivity
end

local function tryInfectPlayer(player, infectivity)
    if (SandboxVars.ZContagion.SusceptibleMultiplier == 0 and player:HasTrait("Susceptible") and player:getModData()['maskModifier'] ~= 'gasmask') then
        infectPlayer(player)
    else
        local infectionRisk = player:getModData()['maskModifier']
        if infectionRisk == 'gasmask' then infectionRisk = 0 end

        infectionRisk = infectionRisk + (player:getModData()['injuries'] * ZContagion.InjuryMultiplier)
        if infectionRisk == 0 then return end

        if player:HasTrait("Resilient") then
            infectionRisk = infectionRisk * ZContagion.ResilientMultiplier
        elseif player:HasTrait("ProneToIllness") then
            infectionRisk = infectionRisk * ZContagion.ProneToIllnessMultiplier
        end
        if player:HasTrait("Susceptible") then
            infectionRisk = infectionRisk * SandboxVars.ZContagion.SusceptibleMultiplier
        end

        infectionRisk = infectionRisk * ZContagion.InfectionChance
        if ZombRandFloat(0, 100) <= infectionRisk * infectivity then
            infectPlayer(player)
        end
    end 
end

local function transmission()
    local hasInfectedPlayer = false
    for i = 0, arraySize(onlinePlayers)-1 do
        local player = arrayGet(onlinePlayers, i)
        if player:getModData()['infectious'] then
            hasInfectedPlayer = true
            local infectivity = calculateInfectivity(player)
            local players = getPlayersInRange(player)

            for _,receiver in ipairs(players) do
                local infectivity = infectivity
                if type(receiver) == 'table' then
                    if receiver[2] then
                        infectivity = infectivity * ZContagion.InfectionChanceIndoorsMultiplier
                        receiver = receiver[1]
                    end
                end
                tryInfectPlayer(receiver, infectivity)
            end
        end
    end
    if not hasInfectedPlayer then
        Events.EveryOneMinute.Remove(transmission)
        ZContagion.isTransmitting = false
    end
end

function ZContagion.beginTransmission()
    if not ZContagion.isTransmitting then
        Events.EveryOneMinute.Add(transmission)
        ZContagion.isTransmitting = true
    end
end