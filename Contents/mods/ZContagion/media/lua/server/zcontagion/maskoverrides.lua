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
local ZContagion = require 'zcontagion/main'

ZContagion.maskOverrides = {
    ["Hat_BandanaMask"] = 0.44, ["Hat_BandanaMaskTINT"] = 0.44, ["Hat_DustMask"] = 0.44,
}

function ZContagion.AddMaskOverrides(overrides)
    for item,protection in pairs(overrides) do
        ZContagion.maskOverrides[item] = protection
    end
end