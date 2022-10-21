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

local Commands = {}

function Commands.setPlayerInfectious(player, isInfectious)
    local oldInfectious = player:getModData()['infectious']
    player:getModData()['infectious'] = isInfectious
    if isInfectious then
        ZContagion.beginTransmission()
    elseif oldInfectious then
        player:getModData()['lastInfected'] = getGameTime():getWorldAgeHours()
    end
end

function Commands.setPlayerCanBeInfected(player, canBeInfected)
    player:getModData()['canBeInfected'] = canBeInfected
end

function Commands.updatePlayerInfectionProgress(player, infectionProgress)
    infectionProgress = math.min(infectionProgress, 200)
    player:getModData()['infectionProgress'] = infectionProgress
end

function Commands.updatePlayerInjuries(player, injuries)
    injuries = math.max(injuries, 0)
    player:getModData()['injuries'] = injuries
end

function Commands.setMaskModifier(player, item, gasmask)
    local modData
    if item then
        local maskOverride = ZContagion.maskOverrides[item] or false
        if maskOverride then
            modData = maskOverride
        elseif gasmask then
            modData = 'gasmask'
        else
            modData = ZContagion.DefaultMaskMultiplier
        end
    else
        modData = 1
    end
    player:getModData()['maskModifier'] = modData
end

local function OnClientCommand(module, command, player, args)
    if module == 'ZContagion' then
        Commands[command](player, unpack(args))
    end
end
Events.OnClientCommand.Add(OnClientCommand)