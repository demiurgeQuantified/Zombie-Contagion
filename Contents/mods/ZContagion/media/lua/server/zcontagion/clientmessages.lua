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
local ZContagion = require "zcontagion/main"
local Config = require "zcontagion/mainvariables"
local Commands = {}

---@param player IsoPlayer
---@param isInfectious boolean
function Commands.setPlayerInfectious(player, isInfectious)
    local oldInfectious = player:getModData().infectious
    player:getModData().infectious = isInfectious
    if isInfectious then
        ZContagion.beginTransmission()
    elseif oldInfectious then
        -- TODO: cache GameTime
        player:getModData().lastInfected = getGameTime():getWorldAgeHours()
    end
end

---@param player IsoPlayer
---@param canBeInfected boolean
function Commands.setPlayerCanBeInfected(player, canBeInfected)
    player:getModData().canBeInfected = canBeInfected
end

---@param player IsoPlayer
---@param infectionProgress number
function Commands.updatePlayerInfectionProgress(player, infectionProgress)
    -- TODO: don't use math library
    infectionProgress = math.min(infectionProgress, 200)
    player:getModData().infectionProgress = infectionProgress
end

---@param player IsoPlayer
---@param injuries number
function Commands.updatePlayerInjuries(player, injuries)
    -- TODO: don't use math library
    injuries = math.max(injuries, 0)
    player:getModData().injuries = injuries
end

---@param player IsoPlayer
---@param item Clothing
---@param gasmask boolean
function Commands.setMaskModifier(player, item, gasmask)
    local maskModifier
    if item then
        maskModifier = ZContagion.maskOverrides[item] or gasmask and "gasmask" or Config.DefaultMaskMultiplier
    else
        maskModifier = 1
    end
    player:getModData().maskModifier = maskModifier
end

---@param module string
---@param command string
---@param player IsoPlayer
---@param args table
function Commands.OnClientCommand(module, command, player, args)
    if module == 'ZContagion' then
        -- TODO: unpack is a bad idea, rewrite these to handle tables
        Commands[command](player, unpack(args))
    end
end
Events.OnClientCommand.Add(Commands.OnClientCommand)

return Commands