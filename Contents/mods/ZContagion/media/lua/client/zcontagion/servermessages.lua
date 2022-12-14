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
local Commands = {}

function Commands.infectPlayer()
    local player = getPlayer()
    if getSandboxOptions():getOptionByName('ZombieLore.Mortality'):getValue():intValue() == 7 then
        player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):SetFakeInfected(true)
    else
        player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):SetInfected(true)
    end
end

local function OnServerCommand(module, command, args)
    if module == 'ZContagion' then
        if args then
            Commands[command](unpack(args))
        else
            Commands[command]()
        end
    end
end
Events.OnServerCommand.Add(OnServerCommand)