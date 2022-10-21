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
-- it's sort of dumb to send so much information to the server when the mod could just run on the client, but
-- if this mod ran on the client, the client would need the authority to directly infect other players
local detectedMasks = 'Zombie Contagion masks detected: '
for _,item in pairs(getAllItemsForBodyLocation('Mask')) do
    detectedMasks = detectedMasks .. item .. ', '
end
print(detectedMasks)
detectedMasks = nil

local playerInfectious = nil
local playerCanBeInfected = nil
local hasSetMaskModifier = false
local susceptibleOnly = false
local infectionProgress = nil
local injuries = nil

Events.OnGameStart.Add(function()
    susceptibleOnly = SandboxVars.ZContagion.SusceptibleOnly
end)

local function valueNeedsUpdating(value, oldValue)
    if type(oldValue) == 'nil' then
        return true
    elseif value ~= oldValue then 
        return true
    end
    return false
end

local function updatePlayerInfectious(player)
    local oldInfectious = playerInfectious

    playerInfectious = player:getBodyDamage():isInfected() or player:HasTrait("Carrier") or player:getBodyDamage():isIsFakeInfected()

    if valueNeedsUpdating(playerInfectious, oldInfectious) then sendClientCommand('ZContagion', 'setPlayerInfectious', {playerInfectious}) end
end

local function updatePlayerCanBeInfected(player)
    local oldCanBeInfected = playerCanBeInfected

    if susceptibleOnly and not player:HasTrait("Susceptible") then
        playerCanBeInfected = false
    elseif player:HasTrait("Carrier") then
        playerCanBeInfected = false
    else
        playerCanBeInfected = not (player:getBodyDamage():isInfected() or player:getBodyDamage():isIsFakeInfected())
    end

    if valueNeedsUpdating(playerCanBeInfected, oldCanBeInfected) then sendClientCommand('ZContagion', 'setPlayerCanBeInfected', {playerCanBeInfected}) end
end

local function countInjuries(player)
    local oldInjuries = injuries
    
    injuries = 0
    local bodyDamage = player:getBodyDamage()
    for i = 0, bodyDamage:getBodyParts():size() - 1 do
        local bodyPart = bodyDamage:getBodyParts():get(i)
        if not bodyPart:bandaged() then
            if bodyPart:getScratchTime() > 0 then
                injuries = injuries + 1
            end
            if bodyPart:getCutTime() > 0 then
                injuries = injuries + 2
            end
            if bodyPart:getDeepWoundTime() > 0 then
                injuries = injuries + 3
                if bodyPart:getStitchTime() > 0 then
                    injuries = injuries - 1
                end
            end
            if bodyPart:getBiteTime() > 0 then
                injuries = injuries + 1
            end
        end
    end

    if valueNeedsUpdating(injuries, oldInjuries) then sendClientCommand('ZContagion', 'updatePlayerInjuries', {injuries}) end
end

local function updateInfectionProgress(player)
    local lastInfectionProgress = infectionProgress
    infectionProgress = player:getBodyDamage():getInfectionLevel() + player:getBodyDamage():getFakeInfectionLevel()

    if valueNeedsUpdating(infectionProgress, lastInfectionProgress) then sendClientCommand('ZContagion', 'updatePlayerInfectionProgress', {infectionProgress}) end
end

local function setMaskModifier()
    local mask = getPlayer():getWornItem('Mask')
    local maskType = nil
    local isGasmask = false
    if mask then
        maskType = mask:getType()
        isGasmask = mask:hasTag('GasMask')
    end
    sendClientCommand('ZContagion', 'setMaskModifier', {maskType, isGasmask})
end

Events.OnClothingUpdated.Add(setMaskModifier)
Events.OnCreatePlayer.Add(setMaskModifier)

local function isPlayerInfectious()
    local player = getPlayer()
    updatePlayerInfectious(player)
    updatePlayerCanBeInfected(player)
    countInjuries(player)
    if playerInfectious then
        updateInfectionProgress(player)
    end
    if not hasSetMaskModifier then
        setMaskModifier()
        hasSetMaskModifier = true
    end
end
Events.EveryOneMinute.Add(isPlayerInfectious)